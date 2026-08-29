$ErrorActionPreference = "Continue"
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

Write-Host "Trenchborn GitHub synchronization active."

while ($true) {
    git fetch origin main --quiet 2>$null
    if ($LASTEXITCODE -eq 0) {
        $localRevision = git rev-parse HEAD 2>$null
        $remoteRevision = git rev-parse origin/main 2>$null

        if ($localRevision -and $remoteRevision -and $localRevision -ne $remoteRevision) {
            git merge --ff-only origin/main
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Trenchborn workshop updated to $remoteRevision"
            } else {
                Write-Warning "Automatic update paused because the local branch cannot be fast-forwarded safely."
            }
        }
    }

    Start-Sleep -Seconds 10
}
