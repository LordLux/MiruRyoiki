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
$analyzeOutput = fvm flutter analyze 2>&1
$analyzeOutput | ForEach-Object { Write-Host $_ }

$errorCount = ($analyzeOutput | Select-String -Pattern '^\s*error - ').Count
$warningCount = ($analyzeOutput | Select-String -Pattern '^\s*warning - ').Count
$infoCount = ($analyzeOutput | Select-String -Pattern '^\s*info - ').Count

Write-Host ""
Write-Host "Analyze summary: $errorCount error(s), $warningCount warning(s), $infoCount info(s)"

if ($errorCount -gt 0) {
    Write-Host "Static analysis failed: $errorCount error(s) found" -ForegroundColor Red
    exit 1
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
