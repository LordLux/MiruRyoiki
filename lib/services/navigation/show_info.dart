
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as mat;

import '../../main.dart';
import '../../utils/logging.dart';

void snackBar(
  String message, {
  fluent.Color color = const mat.Color(0xFF333333),
  fluent.InfoBarSeverity severity = fluent.InfoBarSeverity.info,
  bool hasError = false,
  BuildContext? context,
}) {
  if (severity == fluent.InfoBarSeverity.error && kDebugMode) log("Error: $message");

  fluent.displayInfoBar(
    context ?? rootNavigatorKey.currentContext!,
    duration: severity == fluent.InfoBarSeverity.error ? const Duration(seconds: 10) : const Duration(seconds: 3),
    alignment: severity == fluent.InfoBarSeverity.error ? fluent.Alignment.bottomRight : fluent.Alignment.bottomCenter,
    builder: (context, close) => mat.Container(
      decoration: fluent.BoxDecoration(
        color: color,
        borderRadius: const mat.BorderRadius.all(mat.Radius.circular(8.0)),
      ),
      child: fluent.InfoBar(
        title: fluent.Text(message),
        severity: severity,
        isLong: hasError,
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
  );
}