import 'package:flutter/material.dart';
import '../database/database.dart';
import '../widgets/dialogs/database_recovery.dart';
import '../utils/logging.dart';

/// Simple extension to add database lock detection to AppDatabase
extension DatabaseLockDetection on AppDatabase {
  /// Execute a database operation with automatic lock detection and recovery
  Future<T?> safeExecute<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    try {
      return await operation();
    } catch (error) {
      if (_isDatabaseLockError(error)) {
        logWarn('Database lock detected during: ${operationName ?? 'database operation'}');

        final recovered = await showDatabaseRecoveryDialog(context);
        if (recovered == true) {
          // Retry after recovery
          try {
            logInfo('Retrying operation $operationName after database recovery');
            return await operation();
          } catch (retryError) {
            logErr('Operation $operationName even after recovery', retryError);
            rethrow;
          }
        }
      }
      rethrow;
    }
  }

  /// Check if an error indicates a database lock
  bool _isDatabaseLockError(Object error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('database is locked') || //
        errorString.contains('database lock') ||
        errorString.contains('sqlite_busy') ||
        errorString.contains('disk i/o error');
  }
}

/// Mixin for widgets that need database lock handling
mixin DatabaseLockHandler<T extends StatefulWidget> on State<T> {
  /// Handle database errors with automatic recovery dialog
  Future<bool> handleDatabaseError(Object error) async {
    if (_isDatabaseLockError(error)) {
      logWarn('Database lock detected, showing recovery dialog');

      final result = await showDatabaseRecoveryDialog(context); //TODO see if this mixin on State is ok or if we should use rootnavigatorkey
      if (result == true) {
        logInfo('Database recovery completed successfully');
        return true;
      }
    }
    return false;
  }

  bool _isDatabaseLockError(Object error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('database is locked') || //
        errorString.contains('database lock') ||
        errorString.contains('sqlite_busy') ||
        errorString.contains('disk i/o error');
  }
}
