// ignore_for_file: avoid_print

import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;

import 'time_utils.dart';
import 'path_utils.dart';

bool doLogRelease = false; // Set to true to enable logging in release mode
bool doLogTrace = false; // Set to true to enable trace logging
bool doLogComplexError = false; // Set to true to enable complex error logging

// Session-based logging variables
String? _sessionId;
File? _sessionLogFile;

/// Initialize logging session with a unique timestamp
/// Call this once at app startup
Future<void> initializeLoggingSession() async {
  try {
    // Create session ID with timestamp that's safe for filenames
    final sessionStart = DateTime.now();
    _sessionId = '${sessionStart.year}${sessionStart.month.toString().padLeft(2, '0')}${sessionStart.day.toString().padLeft(2, '0')}_${sessionStart.hour.toString().padLeft(2, '0')}${sessionStart.minute.toString().padLeft(2, '0')}${sessionStart.second.toString().padLeft(2, '0')}';

    // Ensure MiruRyoiki directory exists
    await initializeMiruRyoiokiSaveDirectory();

    // Create logs subdirectory
    final logsDir = Directory(p.join(miruRyoiokiSaveDirectory.path, 'logs'));
    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }

    // Create session log file
    final logFileName = 'log_$_sessionId.txt';
    _sessionLogFile = File(p.join(logsDir.path, logFileName));

    // Write session header
    await _writeToLogFile('=== MiruRyoiki Error Log Session Started ===');
    await _writeToLogFile('Session ID: $_sessionId');
    await _writeToLogFile('Start Time: ${sessionStart.toIso8601String()}');
    await _writeToLogFile('App Version: ${Platform.resolvedExecutable}');
    await _writeToLogFile('Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
    await _writeToLogFile('===========================================\n');
  } catch (e) {
    // Fallback logging to console if file operations fail
    developer.log('Failed to initialize logging session: $e');
  }
}

/// Logs a message with an optional text color and background color.
/// Normally used for very quick debugging purposes.
///
/// The `msg` parameter is the message to be logged.
/// The `color` parameter is the text color of the message (default is [Colors.purpleAccent] to make it more noticeable).
/// The `bgColor` parameter is the background color of the message (default is [Colors.transparent]).
void log(
  final dynamic msg, {
  final Color color = Colors.purpleAccent,
  final Color bgColor = Colors.transparent,
  Object? error,
  StackTrace? stackTrace,
  bool? splitLines = false,
}) {
  if (!doLogRelease && !kDebugMode) return;
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
      developer.log(lineMsg, error: error, stackTrace: stackTrace, time: now);
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

  developer.log(formattedMsg, error: error, stackTrace: stackTrace, time: now);
  if (!kDebugMode) print(msg);
}

/// Logs a trace message with the specified [msg] and sets the text color to Teal.
void logTrace(final dynamic msg, {bool? splitLines}) {
  if (!doLogTrace) return;
  log(msg, color: Colors.tealAccent, splitLines: splitLines);
}

/// Logs a debug message with the specified [msg]
void logDebug(final dynamic msg, {bool? splitLines}) {
  if (!doLogRelease && !kDebugMode) return;
  log(msg, color: Colors.amber, bgColor: Colors.transparent, splitLines: splitLines);
}

/// Safely write to the session log file with error handling
Future<void> _writeToLogFile(String content) async {
  if (_sessionLogFile == null) return;
  
  try {
    // Ensure file exists and append content with newline
    await _sessionLogFile!.writeAsString('$content\n', mode: FileMode.append, flush: true);
  } catch (e) {
    // Fallback to console logging if file write fails
    developer.log('Failed to write to log file: $e');
  }
}

/// Logs an error message with the specified [msg] and sets the text color to Red.
void logErr(final dynamic msg, [Object? error, StackTrace? stackTrace]) {
  final actualStackTrace = stackTrace ?? StackTrace.current;
  logger.e(msg, error: error, stackTrace: actualStackTrace, time: now);
  if (!kDebugMode) print(msg); // print error to terminal in release mode
  if (doLogComplexError) log(msg, color: Colors.red, bgColor: Colors.transparent, error: error, stackTrace: actualStackTrace);
  
  // Write to session log file asynchronously
  _writeErrorToSessionLog(msg, error, actualStackTrace);
}

/// Write error details to the session log file
void _writeErrorToSessionLog(dynamic msg, Object? error, StackTrace stackTrace) {
  if (_sessionLogFile == null || _sessionId == null) return;
  
  // Format error entry
  final timestamp = DateTime.now().toIso8601String();
  final errorContent = StringBuffer();
  errorContent.writeln('[$timestamp] ERROR: $msg');
  
  if (error != null) {
    errorContent.writeln('Exception: $error');
  }
  
  errorContent.writeln('Stack Trace:');
  errorContent.writeln(stackTrace.toString());
  errorContent.writeln('---');
  
  // Write asynchronously without blocking the main thread
  _writeToLogFile(errorContent.toString()).catchError((e) {
    // Silent catch to prevent infinite error loops
    developer.log('Failed to write error to session log: $e');
  });
}

/// Logs an info message with the specified [msg] and sets the text color to Very Light Blue.
void logInfo(final dynamic msg, {bool? splitLines}) => log(msg, color: Colors.white, splitLines: splitLines);

/// Logs a warning message with the specified [msg] and sets the text color to Orange.
void logWarn(final dynamic msg, {bool? splitLines}) => log(msg, color: Colors.amber, splitLines: splitLines);

/// Logs a success message with the specified [msg] and sets the text color to Green.
void logSuccess(final dynamic msg, {bool? splitLines}) => log(msg, color: Colors.green, splitLines: splitLines);

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

Logger logger = Logger();

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
  if (!doLogRelease && !kDebugMode) return;
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
  developer.log(logMessage);
}
