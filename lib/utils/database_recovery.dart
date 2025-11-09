import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/services/navigation/show_info.dart';
import 'package:path/path.dart' as p;
import '../database/database.dart';
import '../utils/logging.dart';
import '../utils/path.dart';
import 'time.dart';

/// Utility class for detecting and recovering from database lock issues
class DatabaseRecovery {
  static const String _journalFileName = '$dbFileName-journal';

  /// Check if the database appears to be locked by looking for journal files
  static bool isDatabaseLocked() {
    try {
      final dbDir = miruRyoikiSaveDirectory;
      final journalFile = File(p.join(dbDir.path, _journalFileName));
      return journalFile.existsSync();
    } catch (e, st) {
      handleDatabaseError(e, st, 'checking database lock status');
      return false;
    }
  }

  /// Get the path to the database directory for user instructions
  static String getDatabaseDirectoryPath() {
    try {
      return miruRyoikiSaveDirectory.path;
    } catch (e) {
      // Fallback for when path isn't initialized
      if (Platform.isWindows) return r'%USERPROFILE%\AppData\Roaming\MiruRyoiki';
      return 'Unknown';
    }
  }

  /// Attempt to safely remove the journal file to unlock the database
  static Future<DatabaseRecoveryResult> attemptAutomaticRecovery() async {
    try {
      // SingleInstance package already ensures single instance,
      // if (await hasRunningProcesses()) {
      // return DatabaseRecoveryResult.failed('Other MiruRyoiki processes are still running. Please close all instances first.');
      // }

      final dbDir = miruRyoikiSaveDirectory;
      final journalFile = File(p.join(dbDir.path, _journalFileName));

      if (!journalFile.existsSync()) return DatabaseRecoveryResult.success('No journal file found - database should be unlocked.');

      // Create a backup of the journal file before deleting
      final backupPath = p.join(dbDir.path, '$dbFileName-journal.backup.${now.millisecondsSinceEpoch}');
      await journalFile.copy(backupPath);

      // Delete the journal file
      await journalFile.delete();

      logInfo('Database journal file removed successfully. Backup created at: $backupPath');

      return DatabaseRecoveryResult.success('Database unlocked successfully. Journal backup created for safety.');
    } catch (e) {
      snackBar('Failed to perform automatic database recovery', exception: e, severity: InfoBarSeverity.error);
      return DatabaseRecoveryResult.failed('Automatic recovery failed: ${e.toString()}');
    }
  }

  /// Get manual recovery instructions for the user
  static List<String> getManualRecoveryInstructions() {
    final dbPath = getDatabaseDirectoryPath();

    return [
      '1. Close MiruRyoiki completely (check Task Manager if needed)',
      '2. Open File Explorer and navigate to:',
      '   $dbPath',
      '3. Look for a file named "$dbFileName-journal"',
      '4. If found, delete this file',
      '5. Restart MiruRyoiki',
    ];
  }

  /// Get available database backups for emergency recovery
  static List<File> getAvailableBackups() {
    try {
      final dbDir = miruRyoikiSaveDirectory;
      return dbDir //
          .listSync()
          .whereType<File>()
          .where((file) => file.path.contains('$dbFileName.bak') || file.path.endsWith('.db.bak'))
          .toList()
        ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    } catch (e, st) {
      handleDatabaseError(e, st, 'listing database backups');
      return [];
    }
  }

  /// Restore database from a backup file
  static Future<DatabaseRecoveryResult> restoreFromBackup(File backupFile) async {
    try {
      final dbDir = miruRyoikiSaveDirectory;
      final dbFile = File(p.join(dbDir.path, dbFileName));
      final journalFile = File(p.join(dbDir.path, _journalFileName));

      // Remove journal file if it exists
      if (journalFile.existsSync()) await journalFile.delete();

      // Create backup of current database
      if (dbFile.existsSync()) {
        final currentBackup = File(p.join(dbDir.path, '$dbFileName.pre-restore.${DateTime.now().millisecondsSinceEpoch}.db.bak'));
        await dbFile.copy(currentBackup.path);
      }

      // Restore from backup
      await backupFile.copy(dbFile.path);

      logInfo('Database restored from backup: ${backupFile.path}');

      return DatabaseRecoveryResult.success('Database restored successfully from backup created on ${backupFile.statSync().modified}');
    } catch (e, st) {
      handleDatabaseError(e, st, 'restoring database from backup', customMessage: 'Failed to restore database from backup');
      return DatabaseRecoveryResult.failed('Backup restoration failed: ${e.toString()}');
    }
  }
}

/// Result of a database recovery operation
class DatabaseRecoveryResult {
  final bool success;
  final String message;

  const DatabaseRecoveryResult._(this.success, this.message);

  factory DatabaseRecoveryResult.success(String message) => DatabaseRecoveryResult._(true, message);

  factory DatabaseRecoveryResult.failed(String message) => DatabaseRecoveryResult._(false, message);
}
