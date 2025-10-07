#!/usr/bin/env pwsh
# build-release.ps1

Write-Host "Incrementing build number..."
pubversion build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to increment build number" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Building Flutter Windows app in release mode..."
flutter build windows --release

exit $LASTEXITCODE
