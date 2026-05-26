# Run the tests that need a real, running media player (VLC / MPC-HC)
#
# Prerequisites:
#   - VLC or MPC-HC running with its web/HTTP interface enabled and a video loaded
#   - Without a reachable player the tests self-skip (they do not fail)
#
# Runs serially (--concurrency=1) because a single player instance cannot serve multiple parallel test isolates at once
#
# Usage (from repo root):
#   `powershell -File test/launch_scripts/requires_player.ps1`

Write-Host "Running media-player integration tests (concurrency=1)..." -ForegroundColor Cyan
fvm flutter test --concurrency=1 --tags requires-player @args
