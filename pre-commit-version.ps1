#!/usr/bin/env pwsh
# pre-commit-version.ps1

# Check if pubspec.yaml is in the staged files
$stagedFiles = git diff --cached --name-only
if (-not ($stagedFiles -contains "pubspec.yaml")) {
    # pubspec.yaml not staged, proceed with auto-increment
    Write-Host "Auto-incrementing patch version..." -ForegroundColor Cyan
    pubversion patch --build none
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to increment version" -ForegroundColor Red
        exit $LASTEXITCODE
    }
    
    git add pubspec.yaml
    exit 0
}

# pubspec.yaml is staged, check if semantic version was manually changed
try {
    # Get the staged version (what's about to be committed)
    $stagedContent = git show :pubspec.yaml 2>$null
    $stagedVersionLine = $stagedContent | Select-String "^version:\s*(.+)$"
    $stagedFullVersion = $stagedVersionLine.Matches.Groups[1].Value.Trim()
    
    # Get the last committed version
    $committedContent = git show HEAD:pubspec.yaml 2>$null
    
    if ($committedContent) {
        $committedVersionLine = $committedContent | Select-String "^version:\s*(.+)$"
        $committedFullVersion = $committedVersionLine.Matches.Groups[1].Value.Trim()
        
        # Extract just X.Y.Z part (before the +)
        $stagedSemanticVer = ($stagedFullVersion -split '\+')[0]
        $committedSemanticVer = ($committedFullVersion -split '\+')[0]
        
        # If semantic version changed, user modified it manually
        if ($stagedSemanticVer -ne $committedSemanticVer) {
            Write-Host "Semantic version changed from $committedSemanticVer to $stagedSemanticVer." -ForegroundColor Yellow
            Write-Host "Skipping auto-increment." -ForegroundColor Yellow
            exit 0
        }
    }
}
catch {
    Write-Host "Error checking version history. Skipping auto-increment." -ForegroundColor Red
    exit 0
}

# No manual version change detected, proceed with auto-increment
Write-Host "Auto-incrementing patch version..." -ForegroundColor Cyan
pubversion patch --build reset # Increments patch and resets build to 0

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to increment version" -ForegroundColor Red
    exit $LASTEXITCODE
}

# Re-stage the modified pubspec.yaml
git add pubspec.yaml

exit 0
