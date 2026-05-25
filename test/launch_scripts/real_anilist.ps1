# Run the real-AniList-API test suite
#
# Prerequisites:
#   - `test/.env` must contain `ACCESS_TOKEN` and `USERNAME` for the debug account
#   - An internet connection is required
#
# Tests run serially (--concurrency=1) so the in-process rate limiter (3s between requests, ~20 req/min) is the single authority for the whole suite
# This keeps the combined request rate safely below AniList's degraded cap of 30 req/min even across file boundaries
#
# Usage (from repo root):
#   `powershell -File test/run_real_anilist.ps1`

Write-Host "Running real-AniList API tests (concurrency=1)..." -ForegroundColor Cyan
fvm flutter test --concurrency=1 --tags real-api @args
