$ErrorActionPreference = "Stop"

if (Get-Command py -ErrorAction SilentlyContinue) {
    & py -3 (Join-Path $PSScriptRoot "trenchborn-review-agent.py")
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
    & python (Join-Path $PSScriptRoot "trenchborn-review-agent.py")
} elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
    & python3 (Join-Path $PSScriptRoot "trenchborn-review-agent.py")
} else {
    throw "Python 3 is missing. Install it with: winget install -e --id Python.Python.3.12"
}
