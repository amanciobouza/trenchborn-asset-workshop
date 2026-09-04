param([switch]$Start)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$pluginBuild = Join-Path $repoRoot "TrenchbornReviewPlugin.rbxm"
$pluginFolder = Join-Path $env:LOCALAPPDATA "Roblox\Plugins"

if (-not (Get-Command rojo -ErrorAction SilentlyContinue)) {
    throw "Rojo is not available on PATH. Install Rojo before running this installer."
}
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    throw "Python is not available on PATH."
}

python -m pip install --user Pillow
rojo build (Join-Path $repoRoot "plugin.project.json") -o $pluginBuild
New-Item -ItemType Directory -Force -Path $pluginFolder | Out-Null
Copy-Item -Force $pluginBuild (Join-Path $pluginFolder "TrenchbornReviewPlugin.rbxm")

Write-Host "Installed TrenchbornReviewPlugin. Restart Roblox Studio."
Write-Host "Enable Game Settings > Security > Allow HTTP Requests."
Write-Host "Set OPENAI_API_KEY locally before starting the agent."

if ($Start) {
    python (Join-Path $PSScriptRoot "trenchborn-review-agent.py")
}
