/// Process-global token-bucket that limits AniList requests to 20/minute.
///
/// This is deliberately conservative (AniList's degraded cap is 30/min) so that
/// even with a small burst at isolate boundaries (files running back-to-back via
/// --concurrency=1) we stay safely under the hard limit.
///
/// Usage: every GraphQL link call goes through [RateLimitLink], which awaits
/// [AnilistRateLimiter.instance.acquire] before forwarding the request.
class AnilistRateLimiter {
  AnilistRateLimiter._();
  static final AnilistRateLimiter instance = AnilistRateLimiter._();

  // 20 requests per minute → 1 slot every 3 000 ms
  static const int _minIntervalMs = 3000;

  DateTime? _lastRequestAt;
  bool _paused = false;
  Future<void>? _pauseFuture;

  /// Await a free rate-limit slot.
  ///
  /// Blocks until at least [_minIntervalMs] has elapsed since the previous
  /// request **and** any active [pauseFor] has completed.
  Future<void> acquire() async {
    if (_paused) await _pauseFuture;

    final now = DateTime.now();
    if (_lastRequestAt != null) {
      final elapsed = now.difference(_lastRequestAt!).inMilliseconds;
      if (elapsed < _minIntervalMs) {
        await Future.delayed(Duration(milliseconds: _minIntervalMs - elapsed));
      }
    }
    _lastRequestAt = DateTime.now();
  }

  /// Block all subsequent [acquire] calls for [duration].
  ///
  /// Called when a 429 response is detected so the whole limiter
  /// pauses until the server-side window resets.
  Future<void> pauseFor(Duration duration) async {
    if (_paused) return;
    _paused = true;
    _pauseFuture = Future.delayed(duration).then((_) {
      _paused = false;
      _lastRequestAt = DateTime.now();
    });
    await _pauseFuture;
  }
}
