#!/usr/bin/env python3
"""Local-only bridge: captures Roblox Studio and sends a review bundle to OpenAI."""

import ctypes
import json
import os
import pathlib
import shutil
import subprocess
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
    command.append(json.dumps(prompt, ensure_ascii=False))
    completed = subprocess.run(command, capture_output=True, text=True, timeout=300)
    pathlib.Path(session["folder"], "codex-stderr.log").write_text(completed.stderr, encoding="utf-8")
    if completed.returncode != 0:
        raise RuntimeError("codex exec failed: " + completed.stderr[-2000:])
    return json.loads(output_path.read_text(encoding="utf-8"))


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
                with LOCK: SESSIONS[session_id] = session
                (folder / "technical-report.json").write_text(json.dumps(payload.get("technicalReport"), indent=2), encoding="utf-8")
                self.send_json(200, {"sessionId": session_id})
            elif self.path == "/session/capture":
                with LOCK: session = SESSIONS[payload["sessionId"]]
                view = payload["view"]
                path = pathlib.Path(session["folder"]) / (view + ".png")
                capture(path)
                session["captures"].append((view, str(path)))
                self.send_json(200, {"captured": view})
            elif self.path == "/session/finish":
                with LOCK: session = SESSIONS[payload["sessionId"]]
                review = call_codex(session)
                pathlib.Path(session["folder"], "review.json").write_text(json.dumps(review, indent=2), encoding="utf-8")
                self.send_json(200, review)
            else:
                self.send_json(404, {"error": "Unknown endpoint"})
        except Exception as error:
            self.send_json(500, {"error": str(error)})


if __name__ == "__main__":
    ROOT.mkdir(parents=True, exist_ok=True)
    print(f"Trenchborn Review Agent listening on http://{HOST}:{PORT} (Codex CLI mode)")
    ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()
