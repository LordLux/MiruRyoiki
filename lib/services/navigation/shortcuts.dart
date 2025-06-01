import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miruryoiki/services/navigation/dialogs.dart';
import 'package:miruryoiki/theme.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../manager.dart';
import '../library/library_provider.dart';
import '../../settings.dart';
import '../../utils/logging.dart';
import '../../utils/screen_utils.dart';

class KeyboardState {
  static final ValueNotifier<bool> ctrlPressedNotifier = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> shiftPressedNotifier = ValueNotifier<bool>(false);
}

class CustomKeyboardListener extends StatefulWidget {
  final Widget child;

  const CustomKeyboardListener({super.key, required this.child});

  @override
  State<CustomKeyboardListener> createState() => _CustomKeyboardListenerState();
}

class _CustomKeyboardListenerState extends State<CustomKeyboardListener> {
  bool isCtrlPressed = false;
  bool isShiftPressed = false;

  bool isSuperPressed(RawKeyDownEvent event) {
    if (Manager.isMacOS) return event.logicalKey == LogicalKeyboardKey.metaLeft || event.logicalKey == LogicalKeyboardKey.metaRight;
    return event.logicalKey == LogicalKeyboardKey.controlLeft || event.logicalKey == LogicalKeyboardKey.controlRight;
  }

  BuildContext get ctx => homeKey.currentContext ?? rootNavigatorKey.currentContext ?? context;

  void _handleScrollSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent && isCtrlPressed) {
      // Scrolling up has negative delta.dy, scrolling down has positive
      final bool isScrollingUp = event.scrollDelta.dy < 0;

      // Get current font size from settings
      final appTheme = Provider.of<AppTheme>(context, listen: false);
      double newFontSize = appTheme.fontSize;

      // Adjust font size
      if (isScrollingUp)
        newFontSize = (newFontSize + 2).clamp(ScreenUtils.kMinFontSize, ScreenUtils.kMaxFontSize); // Increase (limit to max 24)
      else
        newFontSize = (newFontSize - 2).clamp(ScreenUtils.kMinFontSize, ScreenUtils.kMaxFontSize); // Decrease (limit to min 10)

      // Only update if changed
      if (newFontSize != appTheme.fontSize) {
        // Update settings
        appTheme.fontSize = newFontSize;

        Manager.setState();
      }
    }
  }

  void _handleKeyPress(RawKeyEvent event) {
    setState(() {
      if (event is RawKeyDownEvent) {
        if (isSuperPressed(event)) {
          isCtrlPressed = true;
          KeyboardState.ctrlPressedNotifier.value = true;
        }
        if (event.logicalKey == LogicalKeyboardKey.shiftLeft || event.logicalKey == LogicalKeyboardKey.shiftRight) {
          isShiftPressed = true;
          KeyboardState.shiftPressedNotifier.value = true;
        }

        /// Handle specific key combinations
        // Open settings
        if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.comma) {
          logTrace('Ctrl + , pressed: Open settings');
        } else
        //
        // Open search Palette
        if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyF) {
          logTrace('Ctrl + f pressed: Search');
        } else
        //
        // Reload
        if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyR) {
          final library = Provider.of<Library>(context, listen: false);
          library.reloadLibrary();
        } else
        //
        // Esc
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          _handleBackNavigation(isEsc: true);
        } else
        //
        //
        if (event.logicalKey == LogicalKeyboardKey.enter) {
          logTrace('Enter pressed');
        } else
        //
        // Debug
        if (event.logicalKey == LogicalKeyboardKey.f1) {
          logTrace('F1 pressed: Debug');
          showDebugDialog(ctx);
        } else
        //
        // Rename
        if (event.logicalKey == LogicalKeyboardKey.f2) {
          logTrace('F2 pressed: Rename');
        } else
        //
        // Modify path
        if (event.logicalKey == LogicalKeyboardKey.f4) {
          logTrace('F4 pressed: Modify path');
        } else
        //
        // ctrl + N to expand/collapse Nth season
        if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.digit1) {
          _toggleSeason(1);
        } else if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.digit2) {
          _toggleSeason(2);
        } else if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.digit3) {
          _toggleSeason(3);
        } else if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.digit4) {
          _toggleSeason(4);
        } else if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.digit5) {
          _toggleSeason(5);
        } else if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.digit6) {
          _toggleSeason(6);
        } else if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.digit7) {
          _toggleSeason(7);
        } else if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.digit8) {
          _toggleSeason(8);
        } else if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.digit9) {
          _toggleSeason(9);
        } else if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.digit0) {
          _toggleSeason(0);
        }
      } else if (event is RawKeyUpEvent) {
        // Update key states on key release
        if (event.logicalKey == LogicalKeyboardKey.controlLeft || event.logicalKey == LogicalKeyboardKey.controlRight) {
          isCtrlPressed = false;
          KeyboardState.ctrlPressedNotifier.value = false;
        }
        if (event.logicalKey == LogicalKeyboardKey.shiftLeft || event.logicalKey == LogicalKeyboardKey.shiftRight) {
          isShiftPressed = false;
          KeyboardState.shiftPressedNotifier.value = false;
        }
      }
    });
  }

  void _handlePointerSignal(PointerDownEvent event) {
    if (event.buttons == kBackMouseButton)
      _handleBackNavigation();
    else if (event.buttons == kForwardMouseButton) //
      _handleForwardNavigation();
  }

  void _handleBackNavigation({bool isEsc = false}) {
    final homeState = homeKey.currentState;

    if (homeState != null && homeState.mounted) {
      if (homeState.handleBackNavigation(isEsc: isEsc)) {
        // Handled by AppRoot
        return;
      }
    }
  }

  void _handleForwardNavigation() {
    // Implementation for forward navigation would go here
    // You'd need to track forward history separately
  }

  void _toggleSeason(int season) {
    final homeState = homeKey.currentState;
    if (homeState != null && homeState.mounted && homeState.isSeriesView) {
      final seriesScreenState = seriesScreenKey.currentState;

      if (seriesScreenState != null) {
        logTrace('Ctrl + $season pressed: Toggling season $season');
        seriesScreenState.toggleSeasonExpander(season);
      } else {
        logDebug('SeriesScreenState not found');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerSignal,
      onPointerSignal: _handleScrollSignal,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: _handleKeyPress,
        child: widget.child,
      ),
    );
  }
}
