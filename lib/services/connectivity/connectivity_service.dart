import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../utils/logging.dart';
import '../../utils/time.dart' show now;

/// Strategy for checking connectivity
abstract class ConnectivityStrategy {
  /// Stream of connectivity changes
  Stream<List<ConnectivityResult>> get onConnectivityChanged;

  /// Check if there is actual internet access
  Future<bool> hasInternetAccess();
}

class RealConnectivityStrategy implements ConnectivityStrategy {
  final Connectivity _connectivity = Connectivity();

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _connectivity.onConnectivityChanged;

  @override
  Future<bool> hasInternetAccess() async {
    try {
      final hosts = [
        'anilist.co', // Primary
        'google.com', // Fallback
      ];

      for (final host in hosts) {
        try {
          final result = await InternetAddress.lookup(host).timeout(const Duration(seconds: 5));
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) return true;
        } catch (_) {
          continue;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

/// Service to monitor network connectivity status with real-time updates
class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  ConnectivityStrategy _strategy = RealConnectivityStrategy();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _internetCheckTimer;

  /// Current connectivity status
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  /// Check if the connectivity service has been initialized
  bool get isInitialized => _lastConnectivityCheck != null;

  /// ValueNotifier for real-time UI updates
  final ValueNotifier<bool> isOnlineNotifier = ValueNotifier<bool>(true);
  bool isCheckingConnectivity = false;

  /// Last connectivity check time
  DateTime? _lastConnectivityCheck;
  static const Duration _connectivityCheckInterval = Duration(seconds: 5);

  /// Set a custom strategy for testing
  @visibleForTesting
  void setStrategy(ConnectivityStrategy strategy) {
    _strategy = strategy;
    // Re-initialize subscription if already initialized
    if (_connectivitySubscription != null) {
      _connectivitySubscription?.cancel();
      _connectivitySubscription = _strategy.onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: (error) {
          logErr('Connectivity stream error: $error');
        },
      );
    }
  }

  /// Initialize the connectivity service
  Future<void> initialize() async {
    logDebug('Initializing ConnectivityService...');

    // Check initial connectivity
    await _checkInternetConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription = _strategy.onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (error) {
        logErr('Connectivity stream error: $error');
      },
    );

    // Start periodic internet connectivity checks
    _startInternetCheckTimer();

    logInfo('ConnectivityService initialized - Online: $_isOnline');
  }

  /// Handle connectivity changes from connectivity_plus
  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    // logTrace('Connectivity changed: $results');

    // If any connection is available, check actual internet connectivity
    if (_hasActiveConnection(results)) {
      // Don't spam internet checks - wait at least 5 seconds between checks
      if (_lastConnectivityCheck != null && now.difference(_lastConnectivityCheck!) < _connectivityCheckInterval) {
        logTrace('Skipping internet check - too recent');
        return;
      }

      await _checkInternetConnectivity();
    } else {
      // No network interfaces available
      _updateConnectivityStatus(false, 'No network interfaces available');
    }
  }

  /// Returns true if any active connection type is present
  bool _hasActiveConnection(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi) || results.contains(ConnectivityResult.ethernet) || results.contains(ConnectivityResult.vpn);
  }

  /// Start timer for periodic internet connectivity checks
  void _startInternetCheckTimer() {
    _internetCheckTimer?.cancel();

    // Check internet connectivity every 30 seconds when online
    // Check every 10 seconds when offline (to detect when back online faster)
    final interval = _isOnline ? const Duration(seconds: 30) : const Duration(seconds: 10);

    _internetCheckTimer = Timer.periodic(interval, (_) async {
      await _checkInternetConnectivity();

      // Restart timer with potentially different interval
      _startInternetCheckTimer();
    });
  }

  /// Check internet connectivity by attempting to reach multiple hosts
  Future<void> _checkInternetConnectivity() async {
    _lastConnectivityCheck = now;

    // If we're already checking, don't start another check
    if (isCheckingConnectivity) return;

    isCheckingConnectivity = true;

    try {
      final hasConnection = await _strategy.hasInternetAccess();
      _updateConnectivityStatus(hasConnection, hasConnection ? 'Connected' : 'No internet access');
    } catch (e) {
      logErr('Error checking internet connectivity: $e');
      _updateConnectivityStatus(false, 'Connectivity check failed: $e');
    } finally {
      isCheckingConnectivity = false;
    }
  }

  /// Update connectivity status and notify listeners
  void _updateConnectivityStatus(bool isOnline, String reason) {
    final wasOnline = _isOnline;
    _isOnline = isOnline;

    // Only update ValueNotifier and log if status changed
    if (wasOnline != isOnline) {
      isOnlineNotifier.value = isOnline;

      if (isOnline)
        logInfo('Internet connection restored: $reason');
      else
        logWarn('Internet connection lost: $reason');

      notifyListeners();
    }
  }

  /// Manually trigger a connectivity check
  Future<void> checkConnectivity() async {
    logTrace('Manual connectivity check requested');
    isCheckingConnectivity = true;
    await _checkInternetConnectivity();
  }

  /// Get connectivity status as a Future
  Future<bool> getConnectivityStatus() async {
    await _checkInternetConnectivity();
    return _isOnline;
  }

  @override
  void dispose() {
    logTrace('Disposing ConnectivityService...');
    _connectivitySubscription?.cancel();
    _internetCheckTimer?.cancel();
    isOnlineNotifier.dispose();
    super.dispose();
  }
}
