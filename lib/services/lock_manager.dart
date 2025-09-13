import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../utils/logging.dart';
import '../utils/time_utils.dart';

/// Operation types that can be locked
enum OperationType {
  libraryScanning, // includes scanning + fileProcessing + databaseSave
  dominantColorCalculation,
  databaseSave, // standalone quick database saves
}

/// A lock manager that prevents concurrent operations that could corrupt data
/// or cause conflicts between UI actions and background processes
class LockManager extends ChangeNotifier {
  static final LockManager _instance = LockManager._internal();
  factory LockManager() => _instance;
  LockManager._internal();

  final Map<OperationType, _OperationLock> _locks = {};
  final Map<OperationType, List<Completer<void>>> _waitingQueue = {};

  /// Check if any operations are currently locked
  bool get hasActiveOperations => _locks.values.any((lock) => lock.isLocked);

  /// Check if a specific operation type is locked
  bool isLocked(OperationType operationType) => _locks[operationType]?.isLocked ?? false;

  /// Get the description of the currently active operation, if any
  String? get currentOperationDescription {
    for (final entry in _locks.entries) {
      if (entry.value.isLocked) return entry.value.description;
    }
    return null;
  }

  /// Get all currently active operations
  List<String> get activeOperations => _locks.entries
      .where((entry) => entry.value.isLocked) //
      .map((entry) => entry.value.description)
      .toList();

  /// Acquire a lock for the specified operation
  /// Returns a [LockHandle] that must be disposed when the operation completes
  /// If [exclusive] is true, this operation will wait for all other operations to complete
  /// If [waitForOthers] is false, will return null immediately if other operations are running
  Future<LockHandle?> acquireLock(
    OperationType operationType, {
    required String description,
    bool exclusive = false,
    bool waitForOthers = true,
  }) async {
    logTrace('Lock request: $operationType - $description (exclusive: $exclusive, wait: $waitForOthers)');

    // Handle different operation types with specific logic
    switch (operationType) {
      case OperationType.libraryScanning:
      case OperationType.dominantColorCalculation:
        // These are dangerous operations - check what's currently running
        if (hasActiveOperations) {
          // Count actually active locks
          final activeLocks = _locks.values.where((lock) => lock.isLocked).toList();
          
          // If only a database save is running, we can queue behind it (max 1 in queue)
          if (isLocked(OperationType.databaseSave) && activeLocks.length == 1) {
            final waitingList = _waitingQueue[OperationType.databaseSave] ?? [];
            if (waitingList.isNotEmpty) {
              logTrace('Lock denied: Database save queue is full');
              return null;
            }
            if (!waitForOthers) {
              logTrace('Lock denied: Database save active and waitForOthers=false');
              return null;
            }
            // Queue behind the database save and wait
            logTrace('Queueing $operationType behind database save');
            await _waitForOperation(OperationType.databaseSave);
            // After database save completes, we can proceed to acquire the lock
            logTrace('Database save completed, proceeding with $operationType');
          } else {
            // Other dangerous operations are running - block
            logTrace('Lock denied: Dangerous operation blocked by active operations');
            return null;
          }
        }
        break;
        
      case OperationType.databaseSave:
        // Database saves can queue behind themselves, but only allow one in queue
        if (isLocked(OperationType.databaseSave)) {
          final waitingList = _waitingQueue[OperationType.databaseSave] ?? [];
          if (waitingList.isNotEmpty) {
            logTrace('Lock denied: Database save queue is full');
            return null;
          }
          if (!waitForOthers) {
            logTrace('Lock denied: Database save already active and waitForOthers=false');
            return null;
          }
          await _waitForOperation(OperationType.databaseSave);
        } else if (hasActiveOperations) {
          // Database saves should wait for dangerous operations (library scan, color calculation)
          // This handles the case where database save should queue behind library scan
          if (isLocked(OperationType.libraryScanning)) {
            if (!waitForOthers) {
              logTrace('Lock denied: Library scan active and waitForOthers=false');
              return null;
            }
            logTrace('Database save queueing behind library scan');
            await _waitForOperation(OperationType.libraryScanning);
          } else if (isLocked(OperationType.dominantColorCalculation)) {
            if (!waitForOthers) {
              logTrace('Lock denied: Color calculation active and waitForOthers=false');
              return null;
            }
            logTrace('Database save queueing behind color calculation');
            await _waitForOperation(OperationType.dominantColorCalculation);
          }
        }
        break;
    }

    // Create or update the lock
    final lock = _locks[operationType] ??= _OperationLock();
    lock.isLocked = true;
    lock.description = description;
    lock.startTime = now;

    logTrace('Lock acquired: $operationType - $description');
    notifyListeners();

    return LockHandle._(this, operationType);
  }

  /// Release a lock for the specified operation
  void _releaseLock(OperationType operationType) {
    final lock = _locks[operationType];
    if (lock != null) {
      final duration = now.difference(lock.startTime);
      logTrace('Lock released: $operationType - ${lock.description} (duration: ${duration.inMilliseconds}ms)');

      lock.isLocked = false;
      lock.description = '';

      // Notify waiting operations
      final waitingList = _waitingQueue[operationType];
      if (waitingList != null && waitingList.isNotEmpty) {
        final completer = waitingList.removeAt(0);
        completer.complete();
      }
    }

    notifyListeners();
  }

  /// Wait for a specific operation to complete
  Future<void> _waitForOperation(OperationType operationType) async {
    final completer = Completer<void>();
    _waitingQueue.putIfAbsent(operationType, () => []).add(completer);
    await completer.future;
  }

  // Check if user actions should be disabled
  bool shouldDisableUserActions() => hasActiveOperations;

  /// Check if a specific user action should be disabled
  bool shouldDisableAction(UserAction action) {
    switch (action) {
      case UserAction.markEpisodeWatched:
      case UserAction.markSeriesWatched:
      case UserAction.updateSeriesInfo:
      case UserAction.seriesImageSelection:
        // These actions are blocked during any dangerous operation
        return shouldDisableUserActions();

      case UserAction.scanLibrary:
        // Library scan is blocked if:
        // 1. Library scan is already running, OR
        // 2. Dominant color calculation is running (dangerous operations are mutually exclusive)
        return isLocked(OperationType.libraryScanning) || isLocked(OperationType.dominantColorCalculation);

      case UserAction.calculateDominantColors:
        // Color calculation is blocked if:
        // 1. Color calculation is already running, OR  
        // 2. Library scan is running (dangerous operations are mutually exclusive)
        return isLocked(OperationType.dominantColorCalculation) || isLocked(OperationType.libraryScanning);

      case UserAction.anilistOperations:
        // AniList operations are blocked during any dangerous operation
        return shouldDisableUserActions();
    }
  }

  /// Get a user-friendly message explaining why an action is disabled
  String getDisabledReason(UserAction action) {
    final operation = currentOperationDescription;
    
    if (shouldDisableUserActions()) {
      return operation != null ? 'Please wait for the $operation to finish!' : 'Please wait for the current operation to complete!';
    }

    switch (action) {
      case UserAction.scanLibrary:
        if (isLocked(OperationType.libraryScanning)) return 'Library scan is already in progress';
        break;

      case UserAction.calculateDominantColors:
        if (isLocked(OperationType.dominantColorCalculation)) return 'Dominant color calculation is already in progress';
        break;

      default:
        break;
    }

    return 'Operation temporarily unavailable';
  }

  /// Clear all locks and queues (for testing purposes)
  @visibleForTesting
  void clearState() {
    _locks.clear();
    _waitingQueue.clear();
    notifyListeners();
  }
}

/// User actions that can be disabled during operations
enum UserAction {
  markEpisodeWatched,
  markSeriesWatched,
  updateSeriesInfo,
  scanLibrary,
  calculateDominantColors,
  anilistOperations,
  seriesImageSelection,
}

/// A handle representing an acquired lock that must be disposed
class LockHandle {
  final LockManager _lockManager;
  final OperationType _operationType;
  bool _disposed = false;

  LockHandle._(this._lockManager, this._operationType);

  /// Release the lock
  void dispose() {
    if (!_disposed) {
      _lockManager._releaseLock(_operationType);
      _disposed = true;
    }
  }
}

/// Internal class to track lock state
class _OperationLock {
  bool isLocked = false;
  String description = '';
  DateTime startTime = now;
}
