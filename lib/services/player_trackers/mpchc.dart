import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:miruryoiki/services/file_system/media_info.dart';
import 'package:miruryoiki/utils/logging.dart';
import 'package:path/path.dart';
import 'package:win32/win32.dart';
import 'package:win32_registry/win32_registry.dart';

import '../../manager.dart';
import '../../utils/path_utils.dart';
import '../../utils/registry_utils.dart';

class MPCHCTracker with ChangeNotifier {
  static const String _mpcHcRegPath = r'SOFTWARE\MPC-HC\MPC-HC\MediaHistory';

  // Maps file paths to their registry keys
  final Map<String, String> _fileToKeyMap = {};

  // Maps registry keys to their FilePosition value (percentage watched)
  final Map<String, double> _keyToPositionMap = {};

  // Map to track manually completed videos
  final Map<String, double> _manuallyCompletedVideos = {};

  // Flag to indicate if tracker is initialized
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Registry key subscription
  StreamSubscription<void>? _registrySubscription;
  RegistryKey? _registryKey;

  // Debounce timer to avoid excessive updates
  Timer? _debounceTimer;
  final Duration _debounceTime = const Duration(seconds: 5);
  bool _hasPendingChanges = false;

  /// Threshold for watched status (85%)
  static const double watchedThreshold = 0.85;

  /// Threshold to set videos to be fully watched to override registry missing value (95%)
  static const double fullyWatchedThreshold = 0.95;

  // Constructor
  MPCHCTracker() {
    indexRegistry();
    _startRegistryWatcher();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _registrySubscription?.cancel();
    _registryKey?.close();
    super.dispose();
  }

  /// Initialize the tracker by scanning the registry
  Future<void> indexRegistry() async {
    try {
      await _scanRegistryEntries(clearExisting: true);
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      logErr('Error indexing MPC-HC registry', e);
    }
  }

  /// Scans registry entries and updates internal maps
  /// Returns true if any percentage values were changed
  Future<bool> _scanRegistryEntries({
    List<PathString>? watchedFiles,
    required bool clearExisting,
  }) async {
    if (clearExisting) {
      _fileToKeyMap.clear();
      _keyToPositionMap.clear();
    }

    bool anyPercentageChanged = false;

    try {
      final hMediaHistory = RegistryUtils.openKey(HKEY_CURRENT_USER, _mpcHcRegPath);
      if (hMediaHistory == 0) return anyPercentageChanged;

      try {
        final subKeys = RegistryUtils.enumSubKeys(hMediaHistory);

        for (final subKey in subKeys) {
          final hFileKey = RegistryUtils.openKey(hMediaHistory, subKey);
          if (hFileKey == 0) continue;

          try {
            // Process both new and existing keys
            final isNewKey = !_keyToPositionMap.containsKey(subKey);

            if (isNewKey) {
              // New key
              final filename = RegistryUtils.getStringValue(hFileKey, 'Filename');

              if (filename != null && filename.isNotEmpty) {
                final pathString = PathString(filename);
                _fileToKeyMap[pathString.path] = subKey;

                final position = RegistryUtils.getDwordValue(hFileKey, 'FilePosition') ?? 0;
                final durationValue = (await MediaInfo.getVideoDuration(pathString)).inMilliseconds;

                final percentage = durationValue > 0 ? (position / durationValue).clamp(0.0, 1.0) : 0.0;
                final previousPercentage = _keyToPositionMap[subKey] ?? 0.0;

                if (previousPercentage != percentage) {
                  _keyToPositionMap[subKey] = percentage;
                  anyPercentageChanged = true;

                  if (watchedFiles != null && percentage >= watchedThreshold) {
                    watchedFiles.add(pathString);
                  }
                }
              }
            } else {
              // Existing key
              final filePath = _fileToKeyMap.entries.firstWhere((entry) => entry.value == subKey, orElse: () => const MapEntry('', '')).key;

              if (filePath.isNotEmpty) {
                final filename = PathString(filePath);

                final position = RegistryUtils.getDwordValue(hFileKey, 'FilePosition') ?? 0;
                final durationValue = (await MediaInfo.getVideoDuration(filename)).inMilliseconds;

                final percentage = durationValue > 0 ? (position / durationValue).clamp(0.0, 1.0) : 0.0;
                final previousPercentage = _keyToPositionMap[subKey] ?? 0.0;

                if (previousPercentage != percentage) {
                  _keyToPositionMap[subKey] = percentage;
                  anyPercentageChanged = true;
                  logMulti([
                    ['Updated entry: ', Colors.white],
                    [basename(filename.path), Colors.tealAccent],
                    [' (${(percentage * 100).toStringAsFixed(1)}%)', Colors.amber]
                  ]);

                  // Check for threshold crossing (in either direction)
                  if (watchedFiles != null && //
                      ((percentage >= watchedThreshold && previousPercentage < watchedThreshold) || //
                          (percentage < watchedThreshold && previousPercentage >= watchedThreshold))) {
                    watchedFiles.add(filename);
                  }
                }
              }
            }
          } finally {
            RegistryUtils.closeKey(hFileKey);
          }
        }
      } finally {
        RegistryUtils.closeKey(hMediaHistory);
      }
    } catch (e) {
      logDebug('Error scanning MPC-HC registry: $e');
    }

    return anyPercentageChanged;
  }

  void _startRegistryWatcher() async {
    try {
      // Open the registry key we want to monitor
      final hMediaHistory = RegistryUtils.openKey(HKEY_CURRENT_USER, _mpcHcRegPath);

      if (hMediaHistory == 0) {
        logWarn('Failed to open MPC-HC MediaHistory registry key for monitoring');
        return;
      }

      log('Starting registry watcher for HKEY_CURRENT_USER\\$_mpcHcRegPath');

      // Subscribe to changes
      _registrySubscription = RegistryUtils.onChanged(
        HKEY_CURRENT_USER,
        _mpcHcRegPath,
        onChanged: (_) {
          log('Registry change detected');
          _onRegistryChanged();
        },
        onError: (e) {
          logErr('Error in registry watcher', e);
        },
      );
    } catch (e) {
      logErr('Failed to start registry watcher', e);
    }
  }

  /// Called whenever the watcher isolate sends a "something changed" ping
  Future<void> _onRegistryChanged() async {
    // Cancel any existing timer
    _debounceTimer?.cancel();

    // Mark that we have pending changes
    _hasPendingChanges = true;

    // Start a new timer
    _debounceTimer = Timer(_debounceTime, () async {
      if (_hasPendingChanges) {
        try {
          log('Processing registry changes after debounce');

          // Process changes directly using the original checkForUpdates method
          final updatedFiles = await checkForUpdates();

          // Handle completed videos that might have been removed from registry
          _checkForRemovedButCompleteVideos();

          if (updatedFiles.isNotEmpty) {
            log('Updated watch status for ${updatedFiles.length} episodes');
          }
        } catch (e, stack) {
          logErr('Error processing registry changes', e, stack);
        }
        _hasPendingChanges = false;
      }
    });
  }

  /// Check for videos that were almost complete but were removed from registry
  void _checkForRemovedButCompleteVideos() {
    try {
      final hMediaHistory = RegistryUtils.openKey(HKEY_CURRENT_USER, _mpcHcRegPath);
      if (hMediaHistory == 0) return;

      try {
        // Get current registry keys
        final currentKeys = RegistryUtils.enumSubKeys(hMediaHistory).toSet();

        // Find keys that were in our map but are now gone from registry
        final removedKeys = _keyToPositionMap.keys.where((key) => !currentKeys.contains(key)).toList();

        for (final key in removedKeys) {
          // Find the file path for this key
          final filePath = _fileToKeyMap.entries.firstWhere((e) => e.value == key, orElse: () => const MapEntry('', '')).key;

          if (filePath.isNotEmpty) {
            final lastPercentage = _keyToPositionMap[key] ?? 0.0;

            // If the video was almost complete (>95%), consider it fully watched
            if (lastPercentage > fullyWatchedThreshold) {
              log('Video was complete before removal: $filePath ($lastPercentage)');
              _manuallyCompletedVideos[filePath] = 1.0; // Mark as 100% complete
            }

            // Clean up maps
            _fileToKeyMap.remove(filePath);
            _keyToPositionMap.remove(key);
          }
        }
      } finally {
        RegistryUtils.closeKey(hMediaHistory);
      }
    } catch (e) {
      logErr('Error checking for removed but complete videos', e);
    }
  }

  /// Check for updates in the registry and identify completed videos
  Future<List<PathString>> checkForUpdates({bool fullReindex = false}) async {
    if (!_isInitialized || fullReindex) {
      await indexRegistry();
    }

    final watchedFiles = <PathString>[];
    await _scanRegistryEntries(watchedFiles: watchedFiles, clearExisting: false);

    notifyListeners();
    Manager.setState();

    return watchedFiles;
  }

  /// Check if a specific file has been watched
  bool isWatched(PathString filePath) {
    final normalizedPath = filePath.path;

    if (_manuallyCompletedVideos.containsKey(normalizedPath)) //
      return _manuallyCompletedVideos[normalizedPath]! >= watchedThreshold;

    final key = _fileToKeyMap[normalizedPath];
    if (key == null) return false;

    final percentage = _keyToPositionMap[key] ?? 0.0;
    return percentage >= watchedThreshold;
  }

  /// Get the watch percentage for a file
  double getWatchPercentage(PathString filePath) {
    final normalizedPath = filePath.path;

    if (_manuallyCompletedVideos.containsKey(normalizedPath)) //
      return _manuallyCompletedVideos[normalizedPath]!;

    final key = _fileToKeyMap[normalizedPath];
    if (key == null) return 0.0;

    return _keyToPositionMap[key] ?? 0.0;
  }
}
