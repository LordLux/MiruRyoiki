import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../database/database.dart';
import '../utils/database_recovery.dart';
import '../utils/logging.dart';
import '../utils/path.dart';
import '../utils/shell.dart';
import '../utils/time.dart';
import '../utils/units.dart';
import 'navigation/dialogs.dart';

/// Service for managing database backups and storage operations
class DataStorageService {
  /// Get the app data directory path for display
  static String getAppDataPath() {
    try {
      return miruRyoikiSaveDirectory.path;
    } catch (e) {
      logErr('Error getting app data path', e);
      return 'Error: Path not available';
    }
  }

  /// Open the app data folder in file explorer
  static Future<bool> openAppDataFolder() async {
    try {
      final appDataPath = miruRyoikiSaveDirectory.path;
      return await ShellUtils.openFolder(appDataPath);
    } catch (e) {
      logErr('Error opening app data folder', e);
      return false;
    }
  }

  /// Create a manual database backup
  static Future<String?> createBackup() async {
    try {
      // Open folder picker to select save location (default to Documents)
      final String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select the location to create a backup',
        lockParentWindow: true,
        initialDirectory: await _getDocumentsPath(),
      );

      if (selectedDirectory == null) return null; // User cancelled

      final appDataDir = miruRyoikiSaveDirectory;
      final sourceDb = File(p.join(appDataDir.path, dbFileName));

      if (!sourceDb.existsSync()) throw Exception('Database file not found');

      // Create backup filename with timestamp
      final timestamp = now.toIso8601String().replaceAll(':', '-').split('.').first;
      final backupFileName = 'miruryoiki_backup_$timestamp.db';
      final backupPath = p.join(selectedDirectory, backupFileName);

      // Copy database file
      await sourceDb.copy(backupPath);

      logInfo('Database backup created: $backupPath');
      return backupPath;
    } catch (e) {
      logErr('Error creating backup', e);
      rethrow;
    }
  }

  /// Restore database from a backup file
  static Future<String?> restoreFromBackup(final File backupFile) async {
    try {
      final backupPath = backupFile.path;

      if (!backupFile.existsSync()) throw Exception('Backup file not found');

      final appDataDir = miruRyoikiSaveDirectory;
      final targetDb = File(miruRyoikiSaveDirectory.path + ps + dbFileName);

      // Create backup of current database before restore
      if (targetDb.existsSync()) {
        final currentBackupPath = p.join(appDataDir.path, '$dbFileName.pre-restore_${now.toIso8601String().replaceAll(':', '-').split('.').first}');
        await targetDb.copy(currentBackupPath);
        logInfo('Current database backed up to: $currentBackupPath');
      }

      // Remove journal file if it exists
      final journalFile = File(p.join(appDataDir.path, '$dbFileName-journal'));
      if (journalFile.existsSync()) await journalFile.delete();

      // Copy backup to database location
      await backupFile.copy(targetDb.path);

      logInfo('Database restored from: $backupPath');
      return backupPath;
    } catch (e) {
      logErr('Error restoring backup', e);
      rethrow;
    }
  }

  /// Get available automatic backups created by the app
  static List<File> getAutomaticBackups() => DatabaseRecovery.getAvailableBackups();

  /// Get database lock status
  static bool isDatabaseLocked() => DatabaseRecovery.isDatabaseLocked();

  /// Get the size of the database file
  static String getDatabaseSize() {
    try {
      final appDataDir = miruRyoikiSaveDirectory;
      final dbFile = File(p.join(appDataDir.path, dbFileName));

      if (!dbFile.existsSync()) return 'N/A';

      final bytes = dbFile.lengthSync();
      return fileSize(bytes);
    } catch (e) {
      logErr('Error getting database size', e);
      return 'Error';
    }
  }

  /// Get the total size of the app data directory
  static String getAppDataSize() {
    try {
      final appDataDir = miruRyoikiSaveDirectory;
      int totalBytes = 0;

      final files = appDataDir.listSync(recursive: true).whereType<File>();
      for (final file in files) {
        try {
          totalBytes += file.lengthSync();
        } catch (e) {
          // Skip files that can't be read
        }
      }

      return fileSize(totalBytes);
    } catch (e) {
      logErr('Error calculating app data size', e);
      return 'Error';
    }
  }

  /// Get the Documents folder path
  static Future<String?> _getDocumentsPath() async {
    if (!Platform.isWindows) throw UnimplementedError('Documents path retrieval not implemented for this platform');

    // Windows
    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile != null) return p.join(userProfile, 'Documents');
    return null;
  }

  /// Check if a file is a valid database backup
  static bool isValidBackupFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) return false;

    final extension = p.extension(filePath).toLowerCase();
    return extension == '.db';
  }
}
