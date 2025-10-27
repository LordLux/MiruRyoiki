import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;

import '../../main.dart';
import '../../utils/logging.dart';

/// Manager class for displaying and controlling InfoBar snackbars
class SnackBarManager {
  static final SnackBarManager _instance = SnackBarManager._internal();
  factory SnackBarManager() => _instance;
  SnackBarManager._internal();

  OverlayEntry? _currentOverlay;
  bool _isFading = true;
  bool _isClosing = false;
  void Function(void Function())? _setState;

  /// Hides the currently visible snackbar/InfoBar if one exists
  Future<void> hideCurrentSnackBar() async {
    if (_currentOverlay == null || !_currentOverlay!.mounted) {
      logTrace('No InfoBar to hide');
      return;
    }

    if (_isClosing) {
      logTrace('InfoBar is already closing');
      return;
    }

    await _closeCurrentSnackBar();
  }

  Future<void> _closeCurrentSnackBar() async {
    if (_currentOverlay == null || !_currentOverlay!.mounted || _isClosing) return;

    logTrace('Closing current InfoBar');
    _isClosing = true;

    // Trigger fade out animation
    if (_setState != null) {
      _setState!(() => _isFading = true);
    }

    // Wait for fade animation
    await Future.delayed(const Duration(milliseconds: 200));

    // Remove overlay
    if (_currentOverlay != null && _currentOverlay!.mounted) {
      _currentOverlay!.remove();
      logTrace('Removed InfoBar overlay');
    }

    // Reset state
    _currentOverlay = null;
    _setState = null;
    _isFading = true;
    _isClosing = false;
  }

  /// Shows a new snackbar with the specified parameters
  Future<void> show(
    String message, {
    fluent.Color color = const mat.Color(0xFF333333),
    fluent.InfoBarSeverity severity = fluent.InfoBarSeverity.info,
    BuildContext? context,
    Object? exception,
    StackTrace? stackTrace,
    Widget? action,
    Duration? duration,
    bool autoHide = true,
  }) async {
    if (severity == fluent.InfoBarSeverity.error && exception != null) {
      logErr("Error: $message", exception, stackTrace);
    }

    final targetContext = context ?? rootNavigatorKey.currentContext!;
    final theme = fluent.FluentTheme.of(targetContext);

    // Determine duration based on severity if not explicitly provided
    final effectiveDuration = duration ??
        (severity == fluent.InfoBarSeverity.error
            ? const Duration(seconds: 10)
            : const Duration(seconds: 3));

    // If there's an existing InfoBar, fade it out gracefully before showing the new one
    if (_currentOverlay != null && _currentOverlay!.mounted) {
      logTrace('Closing previous InfoBar before showing new one');
      await _closeCurrentSnackBar();
      // Extra delay to ensure clean transition
      await Future.delayed(theme.mediumAnimationDuration);
    }

    // Show the new InfoBar
    _showNewInfoBar(
      message,
      color: color,
      severity: severity,
      // ignore: use_build_context_synchronously
      targetContext: targetContext,
      theme: theme,
      exception: exception,
      action: action,
      duration: effectiveDuration,
      autoHide: autoHide,
    );
  }

  void _showNewInfoBar(
    String message, {
    required fluent.Color color,
    required fluent.InfoBarSeverity severity,
    required BuildContext targetContext,
    required fluent.FluentThemeData theme,
    Object? exception,
    Widget? action,
    required Duration duration,
    required bool autoHide,
  }) {
    _isFading = true;
    _isClosing = false;
    var alreadyInitialized = false;
    final alignment = severity == fluent.InfoBarSeverity.error
        ? fluent.Alignment.bottomRight
        : fluent.Alignment.bottomCenter;

    logTrace('Creating new InfoBar: "$message"');

    _currentOverlay = OverlayEntry(
      builder: (context) {
        return SafeArea(
          child: Align(
            alignment: alignment,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: StatefulBuilder(
                builder: (context, setState) {
                  // Store setState for external control
                  _setState = setState;

                  Future<void> close() async {
                    if (_currentOverlay == null || !_currentOverlay!.mounted || _isClosing) return;
                    await _closeCurrentSnackBar();
                  }

                  if (!alreadyInitialized) {
                    alreadyInitialized = true;
                    () async {
                      // Fade in animation
                      await Future.delayed(theme.mediumAnimationDuration);
                      if (_currentOverlay == null || !_currentOverlay!.mounted || _isClosing) return;

                      setState(() => _isFading = false);

                      // Auto-hide after duration if enabled
                      if (autoHide) {
                        // logTrace('InfoBar will auto-hide after $duration');
                        final checkInterval = const Duration(milliseconds: 250);
                        var elapsed = Duration.zero;
                        while (elapsed < duration && !_isClosing) {
                          await Future.delayed(checkInterval);
                          elapsed += checkInterval;
                        }
                        if (!_isClosing) await close();
                      }
                    }();
                  }

                  return AnimatedSwitcher(
                    duration: theme.mediumAnimationDuration,
                    switchInCurve: theme.animationCurve,
                    switchOutCurve: theme.animationCurve,
                    child: _isFading
                        ? const SizedBox.shrink()
                        : PhysicalModel(
                            color: Colors.transparent,
                            elevation: 8.0,
                            child: mat.Container(
                              decoration: fluent.BoxDecoration(
                                color: color,
                                borderRadius: const mat.BorderRadius.all(mat.Radius.circular(8.0)),
                              ),
                              child: fluent.InfoBar(
                                title: fluent.Text(message),
                                severity: severity,
                                isLong: exception != null,
                                action: action,
                                style: fluent.InfoBarThemeData(
                                  icon: (severity) {
                                    switch (severity) {
                                      case fluent.InfoBarSeverity.info:
                                        return mat.Icons.info;
                                      case fluent.InfoBarSeverity.warning:
                                        return mat.Icons.warning;
                                      case fluent.InfoBarSeverity.error:
                                        return mat.Icons.error;
                                      case fluent.InfoBarSeverity.success:
                                        return mat.Icons.check_circle;
                                    }
                                  },
                                  iconColor: (severity) {
                                    switch (severity) {
                                      case fluent.InfoBarSeverity.info:
                                        return fluent.Colors.blue;
                                      case fluent.InfoBarSeverity.warning:
                                        return fluent.Colors.yellow;
                                      case fluent.InfoBarSeverity.error:
                                        return fluent.Colors.red;
                                      case fluent.InfoBarSeverity.success:
                                        return fluent.Colors.green;
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(targetContext).insert(_currentOverlay!);
  }
}

// Global instance for easy access
final _snackBarManager = SnackBarManager();

/// Global function to show a snackbar
void snackBar(
  String message, {
  fluent.Color color = const mat.Color(0xFF333333),
  fluent.InfoBarSeverity severity = fluent.InfoBarSeverity.info,
  BuildContext? context,
  Object? exception,
  StackTrace? stackTrace,
  Widget? action,
  Duration? duration,
  bool autoHide = true,
}) {
  _snackBarManager.show(
    message,
    color: color,
    severity: severity,
    context: context,
    exception: exception,
    stackTrace: stackTrace,
    action: action,
    duration: duration,
    autoHide: autoHide,
  );
}

/// Hides the currently visible snackbar/InfoBar if one exists
Future<void> hideCurrentSnackBar() async {
  await _snackBarManager.hideCurrentSnackBar();
}
