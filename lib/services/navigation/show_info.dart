import 'dart:io';
import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as mat;
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';

import '../../main.dart';

void snackBar(String message, {fluent.Color color = const mat.Color(0xFF333333), fluent.InfoBarSeverity severity = fluent.InfoBarSeverity.info, bool hasError = false}) {
  if (severity == fluent.InfoBarSeverity.error && kDebugMode) print("Error: $message");

  fluent.displayInfoBar(
    duration: severity == fluent.InfoBarSeverity.error ? const Duration(seconds: 10) : const Duration(seconds: 3),
    alignment: severity == fluent.InfoBarSeverity.error ? fluent.Alignment.bottomRight : fluent.Alignment.bottomCenter,
    rootNavigatorKey.currentState!.context,
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
        ),
      ),
    ),
  );
}

// Overlay functions
mat.ValueNotifier<OverlayEntry?> overlayEntry = ValueNotifier(null);

void removeOverlay() {
  if (overlayEntry.value != null) overlayEntry.value!.remove();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    overlayEntry.value = null;
  });
}

void showNonModalDialog(BuildContext context, Widget dialogContent, BoxConstraints constraints) {
  final overlay = Overlay.of(context);

  overlayEntry.value = OverlayEntry(
    builder: (context) {
      return Stack(
        children: [
          // Dark semi-transparent background
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque, // Block taps from passing through the background
              onTap: () {
                debugPrint("Tapped background");
                removeOverlay(); // Dismiss the dialog
              }, // Block taps from passing through the background
              child: Container(
                color: mat.Colors.black54, // Semi-transparent black background
              ),
            ),
          ),
          // Top GestureDetector for dismissing the dialog
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 80.0, // Top 80px dismiss area
            child: GestureDetector(
              behavior: HitTestBehavior.translucent, // Allows the child to block tap events
              onTap: () {
                debugPrint("Tapped top of dialog");
                removeOverlay(); // Dismiss the dialog
              },
            ),
          ),
          // Centered Dialog
          Center(
            child: Builder(builder: (context) {
              double maxWidth = min(constraints.maxWidth - 200, 1200.0);
              double maxHeight = min(mat.MediaQuery.of(context).size.height - 180, 800.0);
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
                child: mat.Container(
                  //color: mat.Colors.amber,
                  width: maxWidth,
                  height: maxHeight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent, // Allows the child to block tap events
                    onTap: () {
                      debugPrint("Tapped inside dialog");
                    }, // Prevents dismissal when clicking inside the dialog
                    child: FluentTheme(
                      data: FluentTheme.of(context),
                      child: Center(
                        child: dialogContent,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      );
    },
  );

  overlay.insert(overlayEntry.value!);
}
