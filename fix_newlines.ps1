$status = git status -s
$files = $status | Where-Object { $_ -match "^ M (.*)" } | ForEach-Object { $matches[1] }
foreach ($file in $files) {
    if ($file.Trim() -ne "lib/utils/shell.dart" -and $file.Trim() -ne "lib/services/library/scanner/scanner_service.dart") {
        $diff = git diff -w $file
        if (-not $diff) {
            Write-Host "Reverting $file (only whitespace changes)"
            git checkout -- $file
        }
    }
}
