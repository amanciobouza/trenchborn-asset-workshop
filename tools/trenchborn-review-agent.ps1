$ErrorActionPreference = "Stop"

$hostAddress = "127.0.0.1"
$port = 43127
$repoRoot = Split-Path -Parent $PSScriptRoot
$reviewRoot = Join-Path $repoRoot "reviews"
$outputSchema = Join-Path $PSScriptRoot "review-output.schema.json"
$sessions = @{}

Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class TrenchbornWindowCapture {
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);
}
"@

function Send-JsonResponse {
    param($Context, [int]$StatusCode, $Payload)
    $body = $Payload | ConvertTo-Json -Depth 100 -Compress
    $bytes = [Text.Encoding]::UTF8.GetBytes($body)
    $Context.Response.StatusCode = $StatusCode
    $Context.Response.ContentType = "application/json; charset=utf-8"
    $Context.Response.ContentLength64 = $bytes.Length
    $Context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $Context.Response.OutputStream.Close()
}

function Read-JsonRequest {
    param($Context)
    $reader = [IO.StreamReader]::new($Context.Request.InputStream, $Context.Request.ContentEncoding)
    try { $body = $reader.ReadToEnd() } finally { $reader.Dispose() }
    if ([string]::IsNullOrWhiteSpace($body)) { return @{} }
    return $body | ConvertFrom-Json
}

function Get-RobloxStudioWindow {
    $candidate = Get-Process -ErrorAction SilentlyContinue |
        Where-Object { $_.MainWindowHandle -ne 0 -and $_.MainWindowTitle -like "*Roblox Studio*" } |
        Sort-Object { $_.MainWindowTitle.Length } -Descending |
        Select-Object -First 1
    if (-not $candidate) { throw "No visible Roblox Studio window was found." }
    return $candidate.MainWindowHandle
}

function Save-StudioCapture {
    param([string]$Path)
    $handle = Get-RobloxStudioWindow
    $rect = New-Object TrenchbornWindowCapture+RECT
    if (-not [TrenchbornWindowCapture]::GetWindowRect($handle, [ref]$rect)) {
        throw "Could not read the Roblox Studio window bounds."
    }
    $width = $rect.Right - $rect.Left
    $height = $rect.Bottom - $rect.Top
    if ($width -le 0 -or $height -le 0) { throw "Roblox Studio has invalid window bounds." }
    $bitmap = New-Object Drawing.Bitmap $width, $height
    $graphics = [Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
        $bitmap.Save($Path, [Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

function Invoke-CodexReview {
    param($Session)
    if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
        throw "Codex CLI is not installed or is not available on PATH."
    }
    $outputPath = Join-Path $Session.Folder "review.json"
    $stderrPath = Join-Path $Session.Folder "codex-stderr.log"
    $prompt = @{
        task = "Perform Trenchborn Quality Gate B visual review."
        instructions = @(
            "Judge every visualReviewCriterion using all camera views.",
            "Distinguish deterministic findings from visual findings.",
            "Return the requested structured result.",
            "Do not claim Quality Gate B is approved; the user owns approval."
        )
        technicalReport = $Session.TechnicalReport
        cameraViews = @($Session.Captures | ForEach-Object { $_.View })
    } | ConvertTo-Json -Depth 100 -Compress

    $arguments = @(
        "exec", "--ephemeral", "--sandbox", "read-only",
        "--cd", $repoRoot,
        "--output-schema", $outputSchema,
        "--output-last-message", $outputPath
    )
    if ($env:TRENCHBORN_REVIEW_MODEL) { $arguments += @("--model", $env:TRENCHBORN_REVIEW_MODEL) }
    foreach ($capture in $Session.Captures) { $arguments += @("--image", $capture.Path) }
    $arguments += $prompt

    & codex @arguments 2> $stderrPath
    if ($LASTEXITCODE -ne 0) {
        $details = if (Test-Path $stderrPath) { Get-Content $stderrPath -Raw } else { "No diagnostics returned." }
        throw "codex exec failed: $details"
    }
    return Get-Content $outputPath -Raw | ConvertFrom-Json
}

New-Item -ItemType Directory -Force -Path $reviewRoot | Out-Null
$listener = [Net.HttpListener]::new()
$listener.Prefixes.Add("http://${hostAddress}:${port}/")
$listener.Start()
Write-Host "Trenchborn Review Agent listening on http://${hostAddress}:${port} (PowerShell + Codex CLI)"

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        try {
            if ($context.Request.HttpMethod -ne "POST") {
                Send-JsonResponse $context 405 @{ error = "POST required" }
                continue
            }
            $payload = Read-JsonRequest $context
            switch ($context.Request.Url.AbsolutePath) {
                "/session/start" {
                    $sessionId = [Guid]::NewGuid().ToString("N")
                    $folder = Join-Path (Join-Path $reviewRoot (Get-Date -Format "yyyy-MM-dd")) $sessionId
                    New-Item -ItemType Directory -Force -Path $folder | Out-Null
                    $sessions[$sessionId] = @{
                        Folder = $folder
                        TechnicalReport = $payload.technicalReport
                        Captures = [Collections.ArrayList]::new()
                    }
                    $payload.technicalReport | ConvertTo-Json -Depth 100 |
                        Set-Content (Join-Path $folder "technical-report.json") -Encoding UTF8
                    Send-JsonResponse $context 200 @{ sessionId = $sessionId }
                }
                "/session/capture" {
                    $session = $sessions[$payload.sessionId]
                    if (-not $session) { throw "Unknown review session." }
                    $path = Join-Path $session.Folder ($payload.view + ".png")
                    Save-StudioCapture $path
                    [void]$session.Captures.Add(@{ View = $payload.view; Path = $path })
                    Send-JsonResponse $context 200 @{ captured = $payload.view }
                }
                "/session/finish" {
                    $session = $sessions[$payload.sessionId]
                    if (-not $session) { throw "Unknown review session." }
                    $review = Invoke-CodexReview $session
                    $review | ConvertTo-Json -Depth 100 |
                        Set-Content (Join-Path $session.Folder "review.json") -Encoding UTF8
                    Send-JsonResponse $context 200 $review
                }
                default { Send-JsonResponse $context 404 @{ error = "Unknown endpoint" } }
            }
        } catch {
            Send-JsonResponse $context 500 @{ error = $_.Exception.Message }
        }
    }
} finally {
    $listener.Stop()
    $listener.Close()
}
