param([switch]$Start)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$pluginBuild = Join-Path $repoRoot "TrenchbornReviewPlugin.rbxm"
$pluginFolder = Join-Path $env:LOCALAPPDATA "Roblox\Plugins"

if (-not (Get-Command rojo -ErrorAction SilentlyContinue)) {
    throw "Rojo is not available on PATH. Install Rojo before running this installer."
}
$pythonExe = $null
$pythonPrefix = @()
if (Get-Command py -ErrorAction SilentlyContinue) {
    $pythonExe = "py"
    $pythonPrefix = @("-3")
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
    $pythonExe = "python"
} elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
    $pythonExe = "python3"
} else {
    throw "Python 3 is missing. Install it with: winget install -e --id Python.Python.3.12"
}
if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        throw "Codex CLI is missing. Install Node.js, then run: npm install -g @openai/codex"
    }
    npm install -g @openai/codex
}

& $pythonExe @pythonPrefix -m pip install --user Pillow
rojo build (Join-Path $repoRoot "plugin.project.json") -o $pluginBuild
New-Item -ItemType Directory -Force -Path $pluginFolder | Out-Null
Copy-Item -Force $pluginBuild (Join-Path $pluginFolder "TrenchbornReviewPlugin.rbxm")

Write-Host "Installed TrenchbornReviewPlugin. Restart Roblox Studio."
Write-Host "Enable Game Settings > Security > Allow HTTP Requests."
Write-Host "Run 'codex login' once and sign in with your ChatGPT account."

if ($Start) {
    & (Join-Path $PSScriptRoot "start-review-agent.ps1")
}
