# Run the fast, offline test suite
#
# Excludes the tag groups that need external resources:
#   - real-api        (live AniList API; see real_anilist.ps1)
#   - requires-player (a running media player; see requires_player.ps1)
#
# Usage (from repo root):
#   `powershell -File test/launch_scripts/unit.ps1`

Write-Host "Running offline unit suite (excluding real-api, requires-player)..." -ForegroundColor Cyan
fvm flutter test --exclude-tags "real-api || requires-player" @args
