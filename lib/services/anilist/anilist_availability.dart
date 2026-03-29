import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../utils/logging.dart';

/// Tracks whether the AniList API is currently available
///
/// When a "temporarily disabled" response is received, this service sets [isUnavailable] to `true` and blocks further requests until the recheck timer clears it
class AnilistAvailabilityService {
  static final AnilistAvailabilityService _instance = AnilistAvailabilityService._();
  factory AnilistAvailabilityService() => _instance;
  AnilistAvailabilityService._();

  final ValueNotifier<bool> unavailableNotifier = ValueNotifier<bool>(false);

  bool get isUnavailable => unavailableNotifier.value;
  bool get isAvailable => !unavailableNotifier.value;

  Timer? _recheckTimer;

  /// Call when an AniList "temporarily disabled" (or similar service-level outage) response is detected
  ///
  /// Sets the unavailable flag and schedules a recheck after [recheckDelay]
  void markUnavailable({Duration recheckDelay = const Duration(minutes: 5)}) {
    if (isUnavailable) return; // already flagged
    logWarn('[AniList] API marked as unavailable — suppressing requests for ${recheckDelay.inMinutes}m');
    unavailableNotifier.value = true;

    _recheckTimer?.cancel();
    _recheckTimer = Timer(recheckDelay, _clearUnavailable);
  }

  /// Clears the unavailable flag so requests can resume
  void _clearUnavailable() {
    logTrace('[AniList] Availability recheck — allowing requests again');
    unavailableNotifier.value = false;
  }

  /// Manually clear the flag (e.g., user clicks "retry")
  void reset() {
    _recheckTimer?.cancel();
    _clearUnavailable();
  }

  void dispose() {
    _recheckTimer?.cancel();
  }
}
