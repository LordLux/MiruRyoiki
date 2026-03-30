import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../utils/logging.dart';

/// Tracks whether the AniList API is currently available.
///
/// Once an outage is detected the flag stays set permanently — the UI
/// (status bar, banners) remains visible until either:
///   1. The user clicks "Try Again" → [reset()]
///   2. A silent background probe confirms AniList is back → [markAvailable()]
///
/// A periodic probe timer pings AniList with exponential back-off
/// (5 → 10 → 20 → 30 min cap) without touching the UI flag.
class AnilistAvailabilityService {
  static final AnilistAvailabilityService _instance = AnilistAvailabilityService._();
  factory AnilistAvailabilityService() => _instance;
  AnilistAvailabilityService._();

  static const Duration _initialProbeDelay = Duration(minutes: 5);
  static const Duration _maxProbeDelay = Duration(minutes: 30);

  final ValueNotifier<bool> unavailableNotifier = ValueNotifier<bool>(false);

  bool get isUnavailable => unavailableNotifier.value;
  bool get isAvailable => !unavailableNotifier.value;

  Timer? _probeTimer;
  int _consecutiveOutages = 0;

  /// Callback set by the AniList layer to perform a lightweight probe request.
  /// Should return `true` if AniList responded successfully.
  Future<bool> Function()? probeCallback;

  /// Call when an AniList "temporarily disabled" response is detected.
  ///
  /// Sets the flag and starts a background probe timer. The UI flag is NOT
  /// cleared by the timer — only by a successful probe or manual [reset()].
  void markUnavailable() {
    final wasAlreadyUnavailable = isUnavailable;
    if (wasAlreadyUnavailable) return;

    _consecutiveOutages++;
    logWarn('[AniList] API marked as unavailable (attempt $_consecutiveOutages)');
    unavailableNotifier.value = true;

    _scheduleProbe();
  }

  /// Schedule a silent background probe with exponential back-off.
  void _scheduleProbe() {
    _probeTimer?.cancel();

    final delay = Duration(
      milliseconds: min(
        _maxProbeDelay.inMilliseconds,
        _initialProbeDelay.inMilliseconds * pow(2, _consecutiveOutages - 1).toInt(),
      ),
    );

    logTrace('[AniList] Next availability probe in ${delay.inMinutes}m');
    _probeTimer = Timer(delay, _runProbe);
  }

  /// Runs the probe. On success → clear. On failure → reschedule.
  Future<void> _runProbe() async {
    if (probeCallback == null) return;

    logTrace('[AniList] Running availability probe...');
    try {
      final ok = await probeCallback!();
      if (ok) {
        logTrace('[AniList] Probe succeeded — service is back online');
        _consecutiveOutages = 0;
        unavailableNotifier.value = false;
        return;
      }
    } catch (_) {
      // probe failed
    }

    // Still down — bump counter and reschedule
    _consecutiveOutages++;
    logTrace('[AniList] Probe failed — still unavailable');
    _scheduleProbe();
  }

  /// Called when a normal (non-probe) request succeeds while the flag is set.
  /// This means AniList came back. Clear everything.
  void markAvailable() {
    if (isAvailable) return;
    _probeTimer?.cancel();
    _consecutiveOutages = 0;
    logTrace('[AniList] API is available again');
    unavailableNotifier.value = false;
  }

  /// Manually clear the flag (e.g., user clicks "Try Again").
  void reset() {
    _probeTimer?.cancel();
    _consecutiveOutages = 0;
    logTrace('[AniList] Availability manually reset');
    unavailableNotifier.value = false;
  }

  void dispose() {
    _probeTimer?.cancel();
  }
}
