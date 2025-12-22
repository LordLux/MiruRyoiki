import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:miruryoiki/utils/logging.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/settings.dart';
import 'package:miruryoiki/enums.dart';

class MockSettingsManager extends Mock implements SettingsManager {
  @override
  LogLevel get fileLogLevel => LogLevel.trace;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Manager.mockSettings = MockSettingsManager();
  });

  const MethodChannel('dev.fluttercommunity.plus/package_info').setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'getAll') {
      return <String, dynamic>{
        'appName': 'MiruRyoiki',
        'packageName': 'com.example.miruryoiki',
        'version': '0.0.1',
        'buildNumber': '1',
      };
    }
    return null;
  });

  const MethodChannel('plugins.flutter.io/path_provider').setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'getApplicationSupportDirectory') return 'build\\tests\\';
    return null;
  });

  // Helper to wait for logs
  Future<void> waitForLogs(File file, int expectedCount, String pattern) async {
    int retries = 0;
    while (retries < 50) {
      if (!file.existsSync()) {
        await Future.delayed(Duration(milliseconds: 200));
        retries++;
        continue;
      }
      final content = await file.readAsString();
      if (pattern.allMatches(content).length >= expectedCount) return;

      await Future.delayed(Duration(milliseconds: 200));
      retries++;
    }
  }

  group('Synchronized File Logging Tests', () {
    test('should handle concurrent logging without corruption', () async {
      // Initialize logging
      await initializeLoggingSession();

      // Create multiple concurrent logging operations
      final futures = <Future>[];

      // Simulate concurrent trace logs (like the video file scanning)
      for (int i = 0; i < 50; i++) {
        futures.add(Future(() {
          logTrace('Found video file: Episode $i - Test Episode Name.mkv');
        }));
      }

      // Simulate concurrent debug logs
      for (int i = 0; i < 25; i++) {
        futures.add(Future(() {
          logDebug('Debug message $i with some longer content to test truncation');
        }));
      }

      // Simulate concurrent error logs
      for (int i = 0; i < 10; i++) {
        futures.add(Future(() {
          logErr('Error message $i', Exception('Test exception $i'));
        }));
      }

      // Wait for all concurrent operations to complete
      await Future.wait(futures);

      // Verify that all log entries were written correctly
      final logsDir = Directory('build/tests/MiruRyoikiDev/logs');
      expect(logsDir.existsSync(), isTrue, reason: 'Logs directory should exist');

      final files = logsDir.listSync().whereType<File>().toList();
      expect(files.isNotEmpty, isTrue, reason: 'Should have created a log file');

      // Get the most recent file by name (timestamp)
      files.sort((a, b) => b.path.compareTo(a.path));
      final logFile = files.first;

      await waitForLogs(logFile, 50, 'Found video file');
      await waitForLogs(logFile, 25, 'Debug message');
      await waitForLogs(logFile, 10, 'Error message');

      final content = logFile.readAsStringSync();

      // Verify counts
      final traceCount = 'Found video file'.allMatches(content).length;
      expect(traceCount, equals(50), reason: 'Should have 50 trace logs');

      final debugCount = 'Debug message'.allMatches(content).length;
      expect(debugCount, equals(25), reason: 'Should have 25 debug logs');

      final errorCount = 'Error message'.allMatches(content).length;
      expect(errorCount, equals(10), reason: 'Should have 10 error logs');
    });

    test('should preserve complete log messages', () async {
      await initializeLoggingSession();

      const testMessage = 'This is a very long test message that should not be truncated and should appear completely in the log file without any missing characters at the beginning or end of the line.';

      logInfo(testMessage);
      logWarn(testMessage);
      logErr(testMessage, Exception('Test exception with long details'));

      final logsDir = Directory('build/tests/MiruRyoikiDev/logs');
      final files = logsDir.listSync().whereType<File>().toList();
      // Get the most recent file by name (timestamp)
      files.sort((a, b) => b.path.compareTo(a.path));
      final logFile = files.first;

      await waitForLogs(logFile, 3, testMessage);

      final content = logFile.readAsStringSync();

      expect(content.contains(testMessage), isTrue, reason: 'Log file should contain the full message');
      // Check it appears at least 3 times (Info, Warn, Error)
      expect(testMessage.allMatches(content).length, greaterThanOrEqualTo(3));
    });

    test('should handle rapid sequential logging', () async {
      await initializeLoggingSession();

      // Rapid sequential logs that previously caused issues
      for (int i = 0; i < 100; i++) {
        logTrace('Rapid log entry $i');
      }

      final logsDir = Directory('build/tests/MiruRyoikiDev/logs');
      final files = logsDir.listSync().whereType<File>().toList();
      // Get the most recent file by name (timestamp)
      files.sort((a, b) => b.path.compareTo(a.path));
      final logFile = files.first;

      await waitForLogs(logFile, 100, 'Rapid log entry');

      final content = logFile.readAsStringSync();

      final rapidCount = 'Rapid log entry'.allMatches(content).length;
      expect(rapidCount, equals(100), reason: 'Should have 100 rapid log entries');
    });
  });
}
