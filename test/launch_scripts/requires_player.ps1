# Run the tests that need a real media player (VLC / MPC-HC)
#
# Player lifecycle (see test/integration/support/mpc_test_harness.dart):
#   - An already-running player is used and left open
#   - Otherwise each test file spawns its own MPC-HC and closes it afterwards,
#     using these keys in test/.env:
#       MPC_HC_PATH=C:\Program Files\MPC-HC\mpc-hc64.exe   (optional, falls back to common install paths)
#       TEST_VIDEO_PATH=M:\path\to\some\video.mkv          (required for spawning)
#   - The web-UI tests additionally need MPC-HC's web interface enabled on :13579
#     (a persisted MPC-HC setting); without it they self-skip (they do not fail)
#   - The slave-mode test (mpc_slave_integration_test) needs NO web interface but
#     requires that no MPC-HC is already running
#
# Runs serially (--concurrency=1) because a single player instance cannot serve multiple parallel test isolates at once
#
# Usage (from repo root):
#   `powershell -File test/launch_scripts/requires_player.ps1`

Write-Host "Running media-player integration tests (concurrency=1)..." -ForegroundColor Cyan
fvm flutter test --concurrency=1 --tags requires-player @args
