// ignore_for_file: avoid_print

import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'time_utils.dart';

bool doLogRelease = false; // Set to true to enable logging in release mode
bool doLogTrace = false; // Set to true to enable trace logging
bool doLogComplexError = false; // Set to true to enable complex error logging

/// Logs a message with an optional text color and background color.
/// Normally used for very quick debugging purposes.
///
/// The `msg` parameter is the message to be logged.
/// The `color` parameter is the text color of the message (default is [Colors.purpleAccent] to make it more noticeable).
/// The `bgColor` parameter is the background color of the message (default is [Colors.transparent]).
void log(final dynamic msg, [final Color color = Colors.purpleAccent, final Color bgColor = Colors.transparent, Object? error, StackTrace? stackTrace]) {
  if (!doLogRelease && !kDebugMode) return;
  String escapeCode = getColorEscapeCode(color);
  String bgEscapeCode = getColorEscapeCodeBg(bgColor);

  String formattedMsg = msg.toString();
  // Handle newlines by applying escape codes to each line
  if (formattedMsg.contains('\n'))
    formattedMsg = formattedMsg.split('\n').map((line) => '$escapeCode$bgEscapeCode$line').join('\n');
  else
    formattedMsg = '$escapeCode$bgEscapeCode$formattedMsg';
    
    formattedMsg = '$nowFormatted | $formattedMsg\x1B[0m'; // Reset color at the end

  developer.log(formattedMsg, error: error, stackTrace: stackTrace, time: now);
  if (!kDebugMode) print(msg);
}

/// Logs a trace message with the specified [msg] and sets the text color to Teal.
void logTrace(final dynamic msg) {
  if (!doLogTrace) return;
  log(msg, Colors.tealAccent);
}

/// Logs a debug message with the specified [msg]
void logDebug(final dynamic msg) {
  if (!doLogRelease && !kDebugMode) return;
  log(msg, Colors.amber, Colors.transparent);
}

/// Logs an error message with the specified [msg] and sets the text color to Red.
void logErr(final dynamic msg, [Object? error, StackTrace? stackTrace]) {
  logger.e(msg, error: error, stackTrace: StackTrace.current, time: now);
  if (!kDebugMode) print(msg); // print error to terminal in release mode
  if (doLogComplexError) log(msg, Colors.red, Colors.transparent, error, stackTrace);
}

/// Logs an info message with the specified [msg] and sets the text color to Very Light Blue.
void logInfo(final dynamic msg) => log(msg, Colors.white);

/// Logs a warning message with the specified [msg] and sets the text color to Orange.
void logWarn(final dynamic msg) => log(msg, Colors.amber);

/// Logs a success message with the specified [msg] and sets the text color to Green.
void logSuccess(final dynamic msg) => log(msg, Colors.green);

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
///  ['Message 3', Colors.blue, Colors.yellow],
/// ]);
/// ```
/// This will log three messages with different text and background colors.
void logMulti(List<List<dynamic>> messages) {
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
  developer.log(logMessage);
}
