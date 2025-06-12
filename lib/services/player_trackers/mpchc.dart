import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:miruryoiki/services/file_system/media_info.dart';
import 'package:miruryoiki/utils/logging.dart';
import 'package:win32/win32.dart';

import '../../utils/path_utils.dart';
import '../../utils/registry_utils.dart';

class _HistoryEntry {
  final String key; //          subkey name (the video‐path hash)
  final String path; //         the actual filename
  final double percentage; //   watched % (0.0–1.0)

  _HistoryEntry(this.key, this.path, this.percentage);
}

/// Simple container to pass arguments into the watcher isolate
class _WatcherParams {
  final String regPath;
  final SendPort sendPort;
  _WatcherParams(this.regPath, this.sendPort);
}

class MPCHCTracker with ChangeNotifier {
  static const String _mpcHcRegPath = r'SOFTWARE\MPC-HC\MPC-HC\MediaHistory';

  // Threshold for watched status (85%)
  static const double watchedThreshold = 0.85;

  // Maps file paths to their registry keys
  final Map<String, String> _fileToKey = {}; // filename → subkey

  // Maps registry keys to their FilePosition value (percentage watched)
  final Map<String, double> _keyToPosition = {}; // subkey → % watched

  /// Map to track manually completed videos (e.g., those removed from history when 100% of the video was watched)
  final Map<String, double> _manuallyCompletedVideos = {};

  // Flag to indicate if tracker is initialized
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // IPC for the watcher isolate
  late final ReceivePort _receivePort;
  Isolate? _watcherIsolate;

  /// Debounce timer to avoid excessive updates
  Timer? _debounceTimer;
  final Duration _debounceTime = const Duration(seconds: 5);
  final Set<PathString> _pendingWatchUpdates = {};
  bool _hasPendingChanges = false;

  MPCHCTracker() {
    _indexRegistry();
    if (!kDebugMode) {
      _receivePort = ReceivePort()..listen((_) => _onRegistryChanged());
      _startRegistryWatcher();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _watcherIsolate?.kill(priority: Isolate.immediate);
    _receivePort.close();
    super.dispose();
  }

  /// Scan registry once and fill both maps
  Future<void> _indexRegistry() async {
    final entries = await _scanHistory();
    _fileToKey
      ..clear()
      ..addEntries(entries.map((e) => MapEntry(e.path, e.key)));
    _keyToPosition
      ..clear()
      ..addEntries(entries.map((e) => MapEntry(e.key, e.percentage)));

    _isInitialized = true;
    notifyListeners();
  }

  /// Called whenever the watcher isolate sends a “something changed” ping
  Future<void> _onRegistryChanged() async {
    // Cancel any existing timer
    _debounceTimer?.cancel();

    final justWatched = await _processChanges();
    if (justWatched.isNotEmpty) {
      _pendingWatchUpdates.addAll(justWatched);
      _hasPendingChanges = true;
    }

    // Start a new timer
    _debounceTimer = Timer(_debounceTime, () {
      if (_hasPendingChanges) {
        // Only notify listeners after the debounce period
        _hasPendingChanges = false;
        if (_pendingWatchUpdates.isNotEmpty) {
          logDebug('Processing ${_pendingWatchUpdates.length} registry updates after debounce');
          notifyListeners();
          _pendingWatchUpdates.clear();
        }
      }
    });
  }

  /// Core diff logic: compare the newly‐scanned entries against our old maps
  Future<List<PathString>> _processChanges() async {
    final entries = await _scanHistory();
    final watchedNow = <PathString>[];

    // Check for entries that were previously tracked but now removed
    final currentPaths = entries.map((e) => e.path).toSet();
    final removedPaths = _fileToKey.keys.where((path) => !currentPaths.contains(path)).toList();

    // For each removed path, check if it was close to completion
    for (var path in removedPaths) {
      final key = _fileToKey[path];
      if (key != null) {
        final lastPercentage = _keyToPosition[key] ?? 0.0;

        // If the video was almost complete (over 95%), consider it fully watched
        if (lastPercentage > 0.95) {
          logDebug('Video was almost complete before removal: $path ($lastPercentage)');
          _manuallyCompletedVideos[path] = 1.0; // Mark as 100% complete
          watchedNow.add(PathString(path));
        }
      }
    }

    // Build quick lookup for the new state
    final newKeyToPct = {
      for (var e in entries) e.key: e.percentage,
    };

    for (var e in entries) {
      final oldPct = _keyToPosition[e.key];
      if (oldPct == null) {
        // brand‐new file
        _fileToKey[e.path] = e.key;
        _keyToPosition[e.key] = e.percentage;
        if (e.percentage >= watchedThreshold) {
          watchedNow.add(PathString(e.path));
        }
      } else {
        log('MPCHCTracker: Processing change for ${e.path} (${e.percentage * 100}%)');
        // existing file: check if it just crossed the threshold
        if (e.percentage >= watchedThreshold && oldPct != e.percentage) {
          watchedNow.add(PathString(e.path));
        }
        _keyToPosition[e.key] = e.percentage;
      }
    }

    final removedKeys = _keyToPosition.keys.toSet()..removeAll(newKeyToPct.keys);
    for (var key in removedKeys) {
      _keyToPosition.remove(key);
      final removedPath = _fileToKey.entries.firstWhere((ent) => ent.value == key, orElse: () => MapEntry('', '')).key;

      if (removedPath.isNotEmpty) {
        _fileToKey.remove(removedPath);
      }
    }

    return watchedNow;
  }

  /// Reads *all* subkeys under MediaHistory, returning [_HistoryEntry]s
  Future<List<_HistoryEntry>> _scanHistory() async {
    final results = <_HistoryEntry>[];

    // 1) Open the main key for reading
    final phkRoot = calloc<IntPtr>();
    final openRoot = RegOpenKeyEx(
      HKEY_CURRENT_USER,
      TEXT(_mpcHcRegPath),
      0,
      KEY_READ,
      phkRoot,
    );
    if (openRoot != ERROR_SUCCESS) {
      calloc.free(phkRoot);
      return results;
    }
    final hRoot = phkRoot.value;
    calloc.free(phkRoot);

    try {
      // 2) Enumerate all subkeys (hash‐named keys)
      final subKeys = RegistryUtils.enumSubKeys(hRoot);

      for (final subKey in subKeys) {
        // open each video‐specific key
        final phkFile = calloc<IntPtr>();
        final openFile = RegOpenKeyEx(
          hRoot,
          TEXT(subKey),
          0,
          KEY_READ,
          phkFile,
        );
        if (openFile == ERROR_SUCCESS) {
          final hFile = phkFile.value;
          try {
            final filename = RegistryUtils.getStringValue(hFile, 'Filename') ?? '';
            if (filename.isNotEmpty) {
              final posMs = RegistryUtils.getDwordValue(hFile, 'FilePosition') ?? 0;
              final durationMs = (await MediaInfo.getVideoDuration(PathString(filename))).inMilliseconds;
              final pct = durationMs > 0 ? (posMs / durationMs).clamp(0.0, 1.0) : 0.0;

              results.add(_HistoryEntry(subKey, filename, pct));
            }
          } finally {
            RegistryUtils.closeKey(hFile);
          }
        }
        calloc.free(phkFile);
      }
    } finally {
      RegCloseKey(hRoot);
    }

    return results;
  }

  //--------------------------------------------------------------------
  // Subscriber (Isolate) setup
  //--------------------------------------------------------------------

  void _startRegistryWatcher() async {
    log('Starting MPC-HC registry watcher on $_mpcHcRegPath');
    _watcherIsolate = await Isolate.spawn<_WatcherParams>(
      _registryWatchIsolate,
      _WatcherParams(_mpcHcRegPath, _receivePort.sendPort),
    );
  }

  /// Runs *in a separate isolate*; blocks on RegNotifyChangeKeyValue, then
  /// pings back via [sendPort].
  static void _registryWatchIsolate(_WatcherParams params) {
    final path = params.regPath;
    final sendPort = params.sendPort;
    
    log('Registry watcher started for $path');

    // open for KEY_NOTIFY
    final phk = calloc<IntPtr>();
    final openRes = RegOpenKeyEx(
      HKEY_CURRENT_USER,
      TEXT(path),
      0,
      KEY_NOTIFY,
      phk,
    );
    if (openRes != ERROR_SUCCESS) {
      calloc.free(phk);
      return;
    }
    final hKey = phk.value;
    calloc.free(phk);
    log('Opened registry key $path for notifications');

    // loop until an error or isolate is killed
    while (true) {
      log('Waiting for registry changes on $path');
      final notifyRes = RegNotifyChangeKeyValue(
        hKey,
        TRUE, // <- recurse into subkeys
        REG_NOTIFY_CHANGE_LAST_SET, // <- any value‐change
        NULL, // <- blocking call
        FALSE,
      );
      if (notifyRes != ERROR_SUCCESS) {
        log('Finished listening for changes: $notifyRes');
        break;
      }
      // ping back: “something changed”
      sendPort.send(null);
    }

    RegCloseKey(hKey);
  }

  /// Public helpers
  bool isWatched(PathString file) {
    if (_manuallyCompletedVideos.containsKey(file.path)) //
      return _manuallyCompletedVideos[file.path]! >= watchedThreshold;

    final key = _fileToKey[file.path];
    if (key == null) return false;
    return (_keyToPosition[key] ?? 0.0) >= watchedThreshold;
  }

  double getWatchPercentage(PathString file) {
    if (_manuallyCompletedVideos.containsKey(file.path)) //
      return _manuallyCompletedVideos[file.path]!;

    final key = _fileToKey[file.path];
    return key == null ? 0.0 : (_keyToPosition[key] ?? 0.0);
  }
}
