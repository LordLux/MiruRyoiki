# PowerShell script to regenerate .si files from .svg files
# This script deletes all .si files and regenerates them using dart run jovial_svg:svg_to_si command

param(
    [string]$AssetsPath = ".\assets"
)

Write-Host "=== Icon Regeneration Script ===" -ForegroundColor Cyan
Write-Host "Assets folder: $AssetsPath" -ForegroundColor Yellow

# Check if assets folder exists
if (-not (Test-Path $AssetsPath)) {
    Write-Error "Assets folder not found: $AssetsPath"
    exit 1
}

# Check if dart and jovial_svg is available
try {
    $null = & dart run jovial_svg:svg_to_si --help 2>&1
    Write-Host "checkmark jovial_svg:svg_to_si found" -ForegroundColor Green
} catch {
    Write-Error "dart run jovial_svg:svg_to_si command not available. Please ensure Dart and jovial_svg package are installed."
    exit 1
}

Write-Host ""
Write-Host "--- Step 1: Deleting existing .si files ---" -ForegroundColor Yellow

# Find and delete all .si files recursively
$siFiles = Get-ChildItem -Path $AssetsPath -Filter "*.si" -Recurse
$siCount = $siFiles.Count

if ($siCount -gt 0) {
    Write-Host "Found $siCount .si files to delete:" -ForegroundColor White
    foreach ($file in $siFiles) {
        $relativePath = $file.FullName.Replace((Get-Location).Path, ".")
        Write-Host "  - $relativePath" -ForegroundColor Gray
        Remove-Item $file.FullName -Force
    }
    Write-Host "checkmark Deleted $siCount .si files" -ForegroundColor Green
} else {
    Write-Host "No .si files found to delete" -ForegroundColor Gray
}

Write-Host ""
Write-Host "--- Step 2: Generating .si files from .svg files ---" -ForegroundColor Yellow

# Find all .svg files recursively
$svgFiles = Get-ChildItem -Path $AssetsPath -Filter "*.svg" -Recurse
$svgCount = $svgFiles.Count

if ($svgCount -gt 0) {
    Write-Host "Found $svgCount .svg files to process:" -ForegroundColor White
    
    $successCount = 0
    $errorCount = 0
    
    foreach ($file in $svgFiles) {
        $relativePath = $file.FullName.Replace((Get-Location).Path, ".")
        Write-Host "  Processing: $relativePath" -ForegroundColor White
        
        try {
            # Run jovial_svg:svg_to_si command on the SVG file
            $result = & dart run jovial_svg:svg_to_si $file.FullName 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "    checkmark Success" -ForegroundColor Green
                $successCount++
            } else {
                Write-Host "    X Error: $result" -ForegroundColor Red
                $errorCount++
            }
        } catch {
            Write-Host "    X Exception: $($_.Exception.Message)" -ForegroundColor Red
            $errorCount++
        }
    }
    
    Write-Host ""
    Write-Host "--- Summary ---" -ForegroundColor Cyan
    Write-Host "Total SVG files processed: $svgCount" -ForegroundColor White
    Write-Host "Successful conversions: $successCount" -ForegroundColor Green
    Write-Host "Failed conversions: $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Gray" })
    
    if ($errorCount -eq 0) {
        Write-Host ""
        Write-Host "checkmark All icons regenerated successfully!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "warning Some conversions failed. Check the output above for details." -ForegroundColor Yellow
    }
} else {
    Write-Host "No .svg files found to process" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=== Script completed ===" -ForegroundColor Cyan