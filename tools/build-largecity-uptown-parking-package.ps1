param(
    [string]$OutputPath = "dist/LargeCityUptownParkingPackage.rbxmx"
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$projectFile = Join-Path $projectRoot "largecity-uptown-parking.package.project.json"
$resolvedOutput = Join-Path $projectRoot $OutputPath
$outputDirectory = Split-Path -Parent $resolvedOutput

if (-not (Get-Command rojo -ErrorAction SilentlyContinue)) {
    throw "Rojo was not found in PATH. Install Rojo, then run this script again."
}

New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
rojo build $projectFile --output $resolvedOutput

if (-not (Test-Path $resolvedOutput)) {
    throw "Rojo finished without creating $resolvedOutput"
}

Write-Host "Large City Uptown Parking package created: $resolvedOutput"
