import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;

import '../../main.dart';
import '../../utils/logging.dart';

// Global variable to track the current InfoBar overlay
OverlayEntry? _currentInfoBarOverlay;

void snackBar(
  String message, {
  fluent.Color color = const mat.Color(0xFF333333),
  fluent.InfoBarSeverity severity = fluent.InfoBarSeverity.info,
  BuildContext? context,
  Object? exception,
  StackTrace? stackTrace,
  Widget? action,
}) {
  if (severity == fluent.InfoBarSeverity.error && exception != null) logErr("Error: $message", exception, stackTrace);

  // Remove existing InfoBar overlay if it exists
  if (_currentInfoBarOverlay != null && _currentInfoBarOverlay!.mounted) {
    _currentInfoBarOverlay!.remove();
    _currentInfoBarOverlay = null;
  }

  final targetContext = context ?? rootNavigatorKey.currentContext!;

  // Create a new overlay entry using similar logic to displayInfoBar
  late OverlayEntry entry;
  var isFading = true;
  var alreadyInitialized = false;
  final theme = fluent.FluentTheme.of(targetContext);
  final alignment = severity == fluent.InfoBarSeverity.error ? fluent.Alignment.bottomRight : fluent.Alignment.bottomCenter;
  final duration = severity == fluent.InfoBarSeverity.error ? const Duration(seconds: 10) : const Duration(seconds: 3);

  entry = OverlayEntry(
    builder: (context) {
      return SafeArea(
        child: Align(
          alignment: alignment,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            child: StatefulBuilder(
              builder: (context, setState) {
                Future<void> close() async {
                  if (!entry.mounted) return;

                  setState(() => isFading = true);
                  await Future.delayed(theme.mediumAnimationDuration);

                  if (!entry.mounted) return;
                  entry.remove();

                  // Clear the global reference when this overlay is removed
                  if (_currentInfoBarOverlay == entry) _currentInfoBarOverlay = null;
                }

                if (!alreadyInitialized) {
                  alreadyInitialized = true;
                  () async {
                    await Future.delayed(theme.mediumAnimationDuration);
                    if (!entry.mounted) return;

                    setState(() => isFading = false);

                    await Future.delayed(duration);
                    await close();
                  }();
                }

                return AnimatedSwitcher(
                  duration: theme.mediumAnimationDuration,
                  switchInCurve: theme.animationCurve,
                  switchOutCurve: theme.animationCurve,
                  child: isFading
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
                              // onClose: close,
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

  // Store reference to the current overlay and insert it
  _currentInfoBarOverlay = entry;
  Overlay.of(targetContext).insert(entry);
}
