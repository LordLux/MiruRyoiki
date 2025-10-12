// ignore_for_file: avoid_print

import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:logger/logger.dart';
import 'package:synchronized/synchronized.dart';
import 'package:path/path.dart' as p;
import 'package:package_info_plus/package_info_plus.dart';

import '../enums.dart';
import '../manager.dart';
import 'time.dart';
import 'path.dart';

class LoggingConfig {
  static bool doLogRelease = true; // Set to true to enable logging in release mode
  static bool doLogTrace = true; // Set to true to enable trace logging; dotrace
  static bool doLogComplexError = false; // Set to true to enable complex error logging
  static bool usePrintForLogging = false; // If true, uses print() for all logging instead of logger package

  static void doTrace() => doLogTrace = true;
  static void doComplex() => doLogComplexError = true;
  static void doRelease() => doLogRelease = true;
  static void usePrint() => usePrintForLogging = true;

  static void disableTrace() => doLogTrace = false;
  static void disableComplex() => doLogComplexError = false;
  static void disableRelease() => doLogRelease = false;
  static void disablePrint() => usePrintForLogging = false;
}

// Session-based logging variables
String? _sessionId;
File? _sessionLogFile;
final Lock _fileWriteLock = Lock(); // Synchronize file writes

Logger logger = Logger();

/// Initialize logging session with a unique timestamp
/// Call this once at app startup
Future<void> initializeLoggingSession() async {
  try {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // Create session ID with timestamp that's safe for filenames
    final sessionStart = DateTime.now();
    _sessionId = '${sessionStart.year}${sessionStart.month.toString().padLeft(2, '0')}${sessionStart.day.toString().padLeft(2, '0')}_${sessionStart.hour.toString().padLeft(2, '0')}${sessionStart.minute.toString().padLeft(2, '0')}${sessionStart.second.toString().padLeft(2, '0')}';

    // Ensure MiruRyoiki directory exists
    await initializeMiruRyoikiSaveDirectory();

    // Create logs subdirectory
    final logsDir = Directory(p.join(miruRyoikiSaveDirectory.path, 'logs'));
    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }

    // Clean up old log files before creating new session
    await _cleanupOldLogs(logsDir);

    final logLevel = _getCurrentFileLogLevel();
    if (logLevel == LogLevel.none) {
      // If log level is none, skip creating log file
      _sessionId = null;
      _sessionLogFile = null;
      return;
    }

    // Create session log file
    final logFileName = 'log_$_sessionId.txt';
    _sessionLogFile = File(p.join(logsDir.path, logFileName));

    // Write session header using the new synchronized write method
    final sessionHeaderContent = StringBuffer();
    sessionHeaderContent.write('=== MiruRyoiki Log Session Started ===\n');
    sessionHeaderContent.write('Session ID: $_sessionId\n');
    sessionHeaderContent.write('Start Time: ${sessionStart.toIso8601String()}\n');
    sessionHeaderContent.write('App Version: ${packageInfo.version} (${packageInfo.buildNumber})\n');
    sessionHeaderContent.write('Arguments: ${[
      ...Manager.args,
      ...[if (kDebugMode) '--debug']
    ]}\n');
    sessionHeaderContent.write('Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}\n');
    sessionHeaderContent.write('File Log Level: ${logLevel.name_}\n');
    sessionHeaderContent.write('===========================================\n');

    await _writeToLogFile(sessionHeaderContent.toString());
  } catch (e) {
    // Fallback logging to console if file operations fail
    _log(LogLevel.error, 'Failed to initialize logging session', error: e);
  }
}

/// Clean up old log files based on retention settings
Future<void> _cleanupOldLogs(Directory logsDir) async {
  try {
    final retentionDays = _getLogRetentionDays();
    if (retentionDays <= 0) {
      _log(LogLevel.none, 'Log retention is disabled (0 days), skipping cleanup.');
      return;
    }

    final cutoffDate = DateTime.now().subtract(Duration(days: retentionDays));

    await for (final entity in logsDir.list()) {
      if (entity is File && entity.path.contains('log_') && entity.path.endsWith('.txt')) {
        try {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
            _log(LogLevel.none, 'Deleted old log file: ${p.basename(entity.path)}');
          }
        } catch (e) {
          // Skip files that can't be accessed
          _log(LogLevel.error, 'Could not check/delete log file ${entity.path}', error: e);
        }
      }
    }
  } catch (e) {
    _log(LogLevel.error, 'Error during log cleanup', error: e);
  }
}

/// Get current file log level from settings, with fallback
LogLevel _getCurrentFileLogLevel() {
  try {
    // Try to get from settings if available
    return Manager.settings.fileLogLevel;
  } catch (e) {
    // Fallback to error level if settings not available
    return LogLevel.error;
  }
}

/// Get log retention days from settings, with fallback
int _getLogRetentionDays() {
  try {
    return Manager.settings.logRetentionDays;
  } catch (e) {
    // Fallback to 7 days if settings not available
    return 7;
  }
}

void _log(LogLevel level, String msg, {Object? error, StackTrace? stackTrace, DateTime? time}) {
  if (kDebugMode)
    switch (level) {
      case LogLevel.none:
      case LogLevel.trace:
      case LogLevel.debug:
      case LogLevel.info:
      case LogLevel.warning:
        developer.log(msg);
      case LogLevel.error:
        logger.e(msg, error: error, stackTrace: stackTrace, time: time);
    }
  else
    switch (level) {
      case LogLevel.none:
      case LogLevel.trace:
      case LogLevel.debug:
      case LogLevel.info:
      case LogLevel.warning:
        logger.i(msg);
      case LogLevel.error:
        logger.e(msg, error: error, stackTrace: stackTrace, time: time);
    }
}

/// Logs a message with an optional text color and background color.
/// Normally used for very quick debugging purposes.
///
/// The `msg` parameter is the message to be logged.
/// The `color` parameter is the text color of the message (default is [Colors.purpleAccent] to make it more noticeable).
/// The `bgColor` parameter is the background color of the message (default is [Colors.transparent]).
void log(final dynamic msg, {final Color color = Colors.purpleAccent, final Color bgColor = Colors.transparent, Object? error, StackTrace? stackTrace, bool? splitLines = false, LogLevel level = LogLevel.none}) {
  if (!LoggingConfig.doLogRelease && !kDebugMode) return;
  if (LoggingConfig.usePrintForLogging) {
    // Simple print logging without colors or timestamps
    if (error != null) {
      print('$msg\nError: $error');
      if (stackTrace != null) print('Stack Trace:\n$stackTrace');
      return;
    }
    print(msg);
    return;
  }
  String escapeCode = getColorEscapeCode(color);
  String bgEscapeCode = getColorEscapeCodeBg(bgColor);

  String formattedMsg = msg.toString();

  if (splitLines == true && formattedMsg.contains('\n')) {
    final lines = formattedMsg.split('\n');
    for (var line in lines) {
      String lineMsg = '$escapeCode$bgEscapeCode$line';
      if (line.trim().isNotEmpty) {
        lineMsg = '$nowFormatted | $lineMsg\x1B[0m';
      } else {
        lineMsg = '$escapeCode$bgEscapeCode$line\x1B[0m';
      }
      _log(level, lineMsg, error: error, stackTrace: stackTrace, time: now);
      if (!kDebugMode) print(line);
    }
    return;
  }

  // Handle newlines by applying escape codes to each line
  if (formattedMsg.contains('\n'))
    formattedMsg = formattedMsg.split('\n').map((line) {
      if (line.trim().isNotEmpty) {
        return '$escapeCode$bgEscapeCode$nowFormatted | $line\x1B[0m';
      } else {
        return '$escapeCode$bgEscapeCode$line\x1B[0m';
      }
    }).join('\n');
  else if (formattedMsg.trim().isNotEmpty)
    formattedMsg = '$escapeCode$bgEscapeCode$nowFormatted | $formattedMsg\x1B[0m';
  else
    formattedMsg = '$escapeCode$bgEscapeCode$formattedMsg\x1B[0m';

  _log(level, formattedMsg, error: error, stackTrace: stackTrace, time: now);
  if (!kDebugMode) print(msg);
}

/// Generic logging function that handles all log levels
void _logWithLevel(
  LogLevel level,
  final dynamic msg, {
  final Color color = Colors.purpleAccent,
  final Color bgColor = Colors.transparent,
  Object? error,
  StackTrace? stackTrace,
  bool? splitLines = false,
}) {
  // Console logging with LoggingConfig checks
  bool shouldLogToConsole = true;

  // Apply LoggingConfig filtering for console output
  if (level == LogLevel.trace && !LoggingConfig.doLogTrace) shouldLogToConsole = false; // Skip trace logs if disabled
  if (level == LogLevel.debug && !LoggingConfig.doLogRelease && !kDebugMode) shouldLogToConsole = false; // Skip debug logs in release mode if disabled

  if (shouldLogToConsole) log(msg, color: color, bgColor: bgColor, error: error, stackTrace: stackTrace, splitLines: splitLines, level: level);

  // Check if we should write to file
  final currentFileLevel = _getCurrentFileLogLevel();

  // If file log level is none don't create log files at all
  if (currentFileLevel == LogLevel.none) return; // Don't write anything to file

  // Check if this message level should be logged based on the threshold
  // Message logs if its priority <= threshold priority
  // es. ERROR (1) <= ERROR (1) → true, TRACE (5) <= ERROR (1) → false
  // When threshold is TRACE (5), everything logs: ERROR (1) <= TRACE (5) → true
  if (level.shouldLog(currentFileLevel)) _writeLogToSessionFile(level, msg, error, stackTrace);
}

/// Write log entry to the session log file
void _writeLogToSessionFile(LogLevel level, dynamic msg, Object? error, StackTrace? stackTrace) {
  if (_sessionLogFile == null || _sessionId == null) return;

  // Format log entry with complete content built before writing
  final timestamp = DateTime.now().toIso8601String();
  final logContent = StringBuffer();

  // Build the complete log entry in memory first
  logContent.write('[$timestamp] ${level.name_.toUpperCase()}: $msg');

  if (error != null) {
    logContent.write('\nException: $error');
  }

  if (stackTrace != null && (level == LogLevel.error || level == LogLevel.debug || level == LogLevel.trace)) {
    logContent.write('\nStack Trace:\n$stackTrace');
  }

  logContent.write('\n---');

  // Write the complete entry asynchronously with proper error handling
  _writeToLogFile(logContent.toString()).catchError((e) {
    // Silent catch to prevent infinite error loops
    if (kDebugMode) {
      developer.log('Failed to write ${level.name_} to session log: $e');
    }
  });
}

/// Logs a trace message with the specified [msg] and sets the text color to Teal.
void logTrace(final dynamic msg, {bool? splitLines}) {
  _logWithLevel(LogLevel.trace, msg, color: Colors.tealAccent, splitLines: splitLines);
}

/// Logs a debug message with the specified [msg]
void logDebug(final dynamic msg, {bool? splitLines}) {
  _logWithLevel(LogLevel.debug, msg, color: Colors.amber, bgColor: Colors.transparent, splitLines: splitLines);
}

/// Safely write to the session log file with error handling and synchronization
Future<void> _writeToLogFile(String content) async {
  if (_sessionLogFile == null) return;

  await _fileWriteLock.synchronized(() async {
    try {
      // Ensure file exists and append content with newline in a single atomic operation
      await _sessionLogFile!.writeAsString('$content\n', mode: FileMode.append, flush: true);
    } catch (e) {
      // Fallback to console logging if file write fails
      _log(LogLevel.error, 'Failed to write to log file', error: e);
    }
  });
}

/// Log a message when file log level setting is changed
void logFileSettingChanged(LogLevel oldLevel, LogLevel newLevel) {
  if (_sessionLogFile == null || _sessionId == null) return;

  final timestamp = now.toIso8601String();
  final logContent = StringBuffer();

  logContent.write('[$timestamp] *** LOG LEVEL CHANGED: ${oldLevel.displayName} → ${newLevel.displayName} ***');
  logContent.write('\n---');

  // Always write directly the message about logging changes
  _writeToLogFile(logContent.toString()).catchError((e) {
    if (kDebugMode) developer.log('Failed to write log level change message: $e');
  });
}

/// Logs an error message with the specified [msg] and sets the text color to Red.
void logErr(final dynamic msg, [Object? error, StackTrace? stackTrace]) {
  final actualStackTrace = stackTrace ?? StackTrace.current;
  // logger.e(msg, error: error, stackTrace: actualStackTrace, time: now);
  if (!kDebugMode) print(msg); // print error to terminal in release mode
  if (LoggingConfig.doLogComplexError) log(msg, color: Colors.red, bgColor: Colors.transparent, error: error, stackTrace: actualStackTrace);

  // Use new level-based logging
  _logWithLevel(LogLevel.error, msg, color: Colors.red, error: error, stackTrace: actualStackTrace);
}

/// Logs a warning message with the specified [msg] and sets the text color to Orange.
void logWarn(final dynamic msg, {bool? splitLines}) {
  _logWithLevel(LogLevel.warning, msg, color: Colors.orange, splitLines: splitLines);
}

/// Logs an info message with the specified [msg] and sets the text color to Very Light Blue.
void logInfo(final dynamic msg, {bool? splitLines}) {
  _logWithLevel(LogLevel.info, msg, color: Colors.white, splitLines: splitLines);
}

/// Logs a success message with the specified [msg] and sets the text color to Green.
void logSuccess(final dynamic msg, {bool? splitLines}) {
  _logWithLevel(LogLevel.info, msg, color: Colors.green, splitLines: splitLines);
}

/// Returns the escape code for the specified text color.
///
/// The `color` parameter is the text color.
/// Returns the escape code as a string.
String getColorEscapeCode(Color color) {
  int r = color.red;
  int g = color.green;
  int b = color.blue;
  return '\x1B[38;2;$r;$g;${b}m';
}

/// Returns the escape code for the specified background color.
///
/// The `color` parameter is the background color.
/// Returns the escape code as a string.
String getColorEscapeCodeBg(Color color) {
  if (color == Colors.transparent) return '\x1B[49m'; // Reset background color (transparent)
  int r = color.red;
  int g = color.green;
  int b = color.blue;
  return '\x1B[48;2;$r;$g;${b}m';
}

/// Logs multiple messages with optional text colors and background colors.
///
/// The `messages` parameter is a list of lists, where each inner list contains the String `message`,
/// the Color `text color` (optional, defaults to [Colors.white]),
/// and the Color `background color` (optional, defaults to [Colors.transparent]).
///
/// example:
/// ```dart
/// logMulti([
///   ['Message 1', Colors.red],
///   ['Message 2', Colors.green, Colors.black],
///   ['Message 3', Colors.blue, Colors.yellow],
/// ]);
/// ```
/// This will log three messages with different text and background colors.
void logMulti(List<List<dynamic>> messages, {bool showTime = true}) {
  if (!LoggingConfig.doLogRelease && !kDebugMode) return; // Skip logging in release mode if disabled
  String logMessage = '';
  for (var innerList in messages) {
    String msg = innerList[0];
    Color color = innerList.length > 1 ? innerList[1] : Colors.white;
    Color bgColor = innerList.length > 2 ? innerList[2] : Colors.transparent;

    String escapeCode = getColorEscapeCode(color);
    String bgEscapeCode = getColorEscapeCodeBg(bgColor);

    logMessage += '$escapeCode$bgEscapeCode$msg';
  }
  if (showTime) logMessage = '$nowFormatted | $logMessage';
  _log(LogLevel.none, logMessage);
}

/// Parses known Anilist API errors and logs appropriate warnings.
/// Returns true if a known error was detected and handled, false otherwise.
bool parseKnownAnilistErrors(Object? error) {
  if (error == null) return false;
  if (error is! Exception) return false;
  if (error is graphql.OperationException) {
    if (error.linkException != null && error.linkException is graphql.ServerException) {
      final serverEx = (error.linkException as graphql.ServerException).toString().toLowerCase();
      if (serverEx.contains('too many requests.')) {
        logWarn('⚠️ Anilist API rate limit reached. Consider setting up your own client ID/secret in settings to avoid this.');
        return true;
      }
    }
  }
  return false;
}
