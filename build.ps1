#!/usr/bin/env pwsh
# build-release.ps1
cls

Write-Host "Incrementing build number..."
pubversion build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to increment build number" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Running static analysis..."
fvm flutter analyze

if ($LASTEXITCODE -ne 0) {
    Write-Host "Static analysis failed" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Running tests..."
powershell -File test/launch_scripts/unit.ps1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Tests failed" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Building Flutter Windows app in release mode..."
fvm flutter build windows --release --no-pub

exit $LASTEXITCODE
