#!/usr/bin/env python3
"""Local-only bridge: captures Roblox Studio and runs a Codex visual review."""

import ctypes
import json
import os
import pathlib
import shutil
import subprocess
import tempfile
import threading
import time
import uuid
from ctypes import wintypes
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

from PIL import ImageGrab

HOST = "127.0.0.1"
PORT = 43127
ROOT = pathlib.Path(__file__).resolve().parents[1] / "reviews"
REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
OUTPUT_SCHEMA = pathlib.Path(__file__).resolve().parent / "review-output.schema.json"
FIX_TARGET = pathlib.Path("src/ReplicatedStorage/TrenchbornAssetWorkshop/KaijuAwakenedGoldenMaster.lua")
SESSIONS = {}
LOCK = threading.Lock()


def studio_bounds():
    user32 = ctypes.windll.user32
    matches = []
    callback_type = ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.c_void_p, ctypes.c_void_p)

    def callback(hwnd, _):
        length = user32.GetWindowTextLengthW(hwnd)
        if length and user32.IsWindowVisible(hwnd):
            title = ctypes.create_unicode_buffer(length + 1)
            user32.GetWindowTextW(hwnd, title, length + 1)
            if "Roblox Studio" in title.value:
                rect = wintypes.RECT()
                user32.GetWindowRect(hwnd, ctypes.byref(rect))
                matches.append((rect.left, rect.top, rect.right, rect.bottom))
        return True

    user32.EnumWindows(callback_type(callback), 0)
    if not matches:
        raise RuntimeError("No visible Roblox Studio window was found")
    return max(matches, key=lambda box: (box[2] - box[0]) * (box[3] - box[1]))


def capture(path):
    image = ImageGrab.grab(bbox=studio_bounds(), all_screens=True)
    inset = os.environ.get("TRENCHBORN_CAPTURE_INSET")
    if inset:
        left, top, right, bottom = [int(value) for value in inset.split(",")]
        image = image.crop((left, top, image.width - right, image.height - bottom))
    image.save(path, "PNG")


def call_codex(session):
    codex = shutil.which("codex") or shutil.which("codex.cmd")
    if not codex:
        raise RuntimeError("Codex CLI is not installed or is not available on PATH")
    prompt = {
        "task": "Perform Trenchborn Quality Gate B visual review.",
        "instructions": [
            "Judge every visualReviewCriterion using all camera views.",
            "Distinguish deterministic findings from visual findings.",
            "Return JSON only with status, summary, findings, and criteria.",
            "Status must be PASS, PASS_WITH_WARNINGS, or FAIL.",
            "Do not claim Quality Gate B is approved; the user owns approval.",
        ],
        "technicalReport": session["technicalReport"],
        "cameraViews": [view for view, _ in session["captures"]],
    }
    output_path = pathlib.Path(session["folder"]) / "review.json"
    command = [
        codex, "exec", "--ephemeral", "--sandbox", "read-only",
        "--cd", str(REPO_ROOT), "--output-schema", str(OUTPUT_SCHEMA),
        "--output-last-message", str(output_path),
    ]
    model = os.environ.get("TRENCHBORN_REVIEW_MODEL")
    if model:
        command.extend(["--model", model])
    for _, file_path in session["captures"]:
        command.extend(["--image", file_path])
    # Use the explicit stdin sentinel so image-option parsing cannot consume or
    # hide the dynamically generated prompt on different Codex CLI versions.
    command.append("-")
    completed = subprocess.run(
        command,
        input=json.dumps(prompt, ensure_ascii=False),
        capture_output=True,
        text=True,
        timeout=300,
    )
    pathlib.Path(session["folder"], "codex-stderr.log").write_text(completed.stderr, encoding="utf-8")
    if completed.returncode != 0:
        raise RuntimeError("codex exec failed: " + completed.stderr[-2000:])
    return json.loads(output_path.read_text(encoding="utf-8"))


def call_codex_fix(session, review, iteration):
    """Let Codex revise an isolated copy, then publish only the approved builder file."""
    codex = shutil.which("codex") or shutil.which("codex.cmd")
    if not codex:
        raise RuntimeError("Codex CLI is not installed or is not available on PATH")

    source_root = REPO_ROOT / "src"
    live_target = REPO_ROOT / FIX_TARGET
    if not live_target.is_file():
        raise RuntimeError(f"Golden Master builder is missing: {live_target}")

    session_folder = pathlib.Path(session["folder"])
    with tempfile.TemporaryDirectory(prefix="trenchborn-autofix-") as temp_name:
        worktree = pathlib.Path(temp_name)
        shutil.copytree(source_root, worktree / "src")
        capture_folder = worktree / "captures"
        capture_folder.mkdir()
        copied_captures = []
        for view, original_path in session["captures"]:
            copied_path = capture_folder / f"{view}.png"
            shutil.copy2(original_path, copied_path)
            copied_captures.append((view, copied_path))

        subprocess.run(
            ["git", "init", "--quiet"],
            cwd=worktree,
            check=True,
            capture_output=True,
            text=True,
        )
        subprocess.run(
            ["git", "add", "."],
            cwd=worktree,
            check=True,
            capture_output=True,
            text=True,
        )
        subprocess.run(
            [
                "git",
                "-c",
                "user.name=Trenchborn Review Agent",
                "-c",
                "user.email=review-agent@localhost",
                "commit",
                "--quiet",
                "-m",
                "autofix baseline",
            ],
            cwd=worktree,
            check=True,
            capture_output=True,
            text=True,
        )
        isolated_target = worktree / FIX_TARGET
        original_source = isolated_target.read_text(encoding="utf-8")
        prompt = {
            "task": "Correct the Trenchborn Phase 4 Bound Chimera Golden Master from the review evidence.",
            "iteration": iteration,
            "editableFile": FIX_TARGET.as_posix(),
            "hardConstraints": [
                "Actually edit the editableFile; do not merely describe changes.",
                "Do not edit specifications, review profiles, validators, schemas, plugins, or any other file.",
                "Never weaken, remove, or bypass a review criterion or deterministic check.",
                "Keep this a geometry-only Phase 4 Golden Master: no particles, lights, sounds, textures, or dressing.",
                "Preserve the public Builder.Build and Builder.Validate APIs, asset identity, rig connectivity, and performance budgets.",
                "Address every blocker and failed or partial visual criterion using the supplied views.",
                "The lowest visible geometry must contact expected ground Y=0 without sinking below it.",
                "Quality Gate B remains Pending; only the user can approve it.",
            ],
            "technicalReport": session["technicalReport"],
            "visualReview": review,
            "cameraViews": [view for view, _ in copied_captures],
        }
        model = os.environ.get("TRENCHBORN_REVIEW_MODEL")
        attempt_summaries = []
        revised_source = original_source
        for attempt in range(1, 3):
            summary_path = worktree / f"fix-summary-{attempt}.txt"
            command = [
                codex,
                "exec",
                "--ephemeral",
                "--sandbox",
                "workspace-write",
                "--cd",
                str(worktree),
                "--output-last-message",
                str(summary_path),
            ]
            if model:
                command.extend(["--model", model])
            for _, copied_path in copied_captures:
                command.extend(["--image", str(copied_path)])
            command.append("-")
            attempt_prompt = dict(prompt)
            if attempt == 2:
                attempt_prompt["retryDirective"] = (
                    "Your previous run made no file change. This is an implementation task, "
                    "not a review-only task. Open the editableFile now and use your editing "
                    "tool to implement concrete geometry corrections before responding."
                )
            completed = subprocess.run(
                command,
                input=json.dumps(attempt_prompt, ensure_ascii=False),
                capture_output=True,
                text=True,
                timeout=600,
            )
            (session_folder / f"fix-{iteration}-attempt-{attempt}-codex-stderr.log").write_text(
                completed.stderr, encoding="utf-8"
            )
            summary = (
                summary_path.read_text(encoding="utf-8")
                if summary_path.is_file()
                else completed.stdout
            )
            attempt_summaries.append(summary.strip())
            if completed.returncode != 0:
                raise RuntimeError("codex autofix failed: " + completed.stderr[-2000:])
            revised_source = isolated_target.read_text(encoding="utf-8")
            if revised_source != original_source:
                break

        if revised_source == original_source:
            diagnostic = " | ".join(value for value in attempt_summaries if value)
            raise RuntimeError(
                "Codex made no builder change after two attempts. Codex response: "
                + (diagnostic[-1800:] or "No final response was recorded.")
            )

        # Only this single reviewed file leaves the isolated workspace. Any
        # attempted edits to validators or specifications are discarded.
        previous_live_source = live_target.read_text(encoding="utf-8")
        live_target.write_text(revised_source, encoding="utf-8")
        with LOCK:
            session["previousSource"] = previous_live_source
            session["appliedSource"] = revised_source
        (session_folder / f"fix-{iteration}-builder.lua").write_text(
            revised_source, encoding="utf-8"
        )
        summary = attempt_summaries[-1] or "Golden Master builder updated."
        return {"status": "COMPLETE", "source": revised_source, "summary": summary}


def start_fix(session, review, iteration):
    with LOCK:
        current = session.get("fixJob")
        if current and current.get("status") == "RUNNING":
            raise RuntimeError("An autofix job is already running for this session")
        job = {"status": "RUNNING", "iteration": iteration}
        session["fixJob"] = job

    def worker():
        try:
            result = call_codex_fix(session, review, iteration)
            with LOCK:
                job.update(result)
        except Exception as error:
            with LOCK:
                job.update({"status": "FAILED", "error": str(error)})

    threading.Thread(target=worker, name=f"trenchborn-fix-{iteration}", daemon=True).start()
    return job


class Handler(BaseHTTPRequestHandler):
    def log_message(self, pattern, *args):
        print("[bridge] " + pattern % args)

    def send_json(self, status, payload):
        body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        try:
            size = int(self.headers.get("Content-Length", "0"))
            payload = json.loads(self.rfile.read(size) or b"{}")
            if self.path == "/session/start":
                session_id = uuid.uuid4().hex
                folder = ROOT / time.strftime("%Y-%m-%d") / session_id
                folder.mkdir(parents=True, exist_ok=True)
                session = dict(payload, sessionId=session_id, folder=str(folder), captures=[])
                with LOCK:
                    SESSIONS[session_id] = session
                (folder / "technical-report.json").write_text(
                    json.dumps(payload.get("technicalReport"), indent=2), encoding="utf-8"
                )
                self.send_json(200, {"sessionId": session_id})
            elif self.path == "/session/capture":
                with LOCK:
                    session = SESSIONS[payload["sessionId"]]
                view = payload["view"]
                path = pathlib.Path(session["folder"]) / (view + ".png")
                capture(path)
                session["captures"].append((view, str(path)))
                self.send_json(200, {"captured": view})
            elif self.path == "/session/finish":
                with LOCK:
                    session = SESSIONS[payload["sessionId"]]
                review = call_codex(session)
                pathlib.Path(session["folder"], "review.json").write_text(
                    json.dumps(review, indent=2), encoding="utf-8"
                )
                self.send_json(200, review)
            elif self.path == "/session/fix":
                with LOCK:
                    session = SESSIONS[payload["sessionId"]]
                job = start_fix(session, payload["review"], int(payload["iteration"]))
                self.send_json(202, {"status": job["status"], "iteration": job["iteration"]})
            elif self.path == "/session/fix-status":
                with LOCK:
                    session = SESSIONS[payload["sessionId"]]
                    job = dict(session.get("fixJob") or {"status": "NOT_STARTED"})
                self.send_json(200, job)
            elif self.path == "/session/rollback":
                with LOCK:
                    session = SESSIONS[payload["sessionId"]]
                    previous_source = session.get("previousSource")
                    applied_source = session.get("appliedSource")
                live_target = REPO_ROOT / FIX_TARGET
                if previous_source is None or applied_source is None:
                    raise RuntimeError("No applied autofix is available to roll back")
                if live_target.read_text(encoding="utf-8") != applied_source:
                    raise RuntimeError("Builder changed after autofix; refusing unsafe rollback")
                live_target.write_text(previous_source, encoding="utf-8")
                self.send_json(200, {"status": "ROLLED_BACK"})
            else:
                self.send_json(404, {"error": "Unknown endpoint"})
        except Exception as error:
            self.send_json(500, {"error": str(error)})


if __name__ == "__main__":
    ROOT.mkdir(parents=True, exist_ok=True)
    print(f"Trenchborn Review Agent listening on http://{HOST}:{PORT} (Python + Codex CLI)")
    ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()
