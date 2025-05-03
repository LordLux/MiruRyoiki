import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../enums.dart';
import '../functions.dart';
import '../main.dart';
import '../manager.dart';
import '../models/library.dart';
import '../screens/series.dart';

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

  void _handleKeyPress(RawKeyEvent event) {
    setState(() {
      if (event is RawKeyDownEvent) {
        if (isSuperPressed(event)) {
          isCtrlPressed = true;
          KeyboardState.ctrlPressedNotifier.value = true;
          print('Ctrl pressed');
        }
        if (event.logicalKey == LogicalKeyboardKey.shiftLeft || event.logicalKey == LogicalKeyboardKey.shiftRight) {
          isShiftPressed = true;
          print('Shift pressed');
          KeyboardState.shiftPressedNotifier.value = true;
        }

        /// Handle specific key combinations
        // Open settings
        if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.comma) {
          print('Ctrl + , pressed: Open settings');
        } else
        //
        // Open search Palette
        if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyF) {
          print('Ctrl + f pressed: Search');
        } else
        //
        // Reload
        if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyR) {
          print('Ctrl + r pressed: Reload');
          final library = Provider.of<Library>(context, listen: false);
          library.reloadLibrary();
        } else
        //
        // Esc
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          _exitSeriesView();
        } else
        //
        //
        if (event.logicalKey == LogicalKeyboardKey.enter) {
          print('Enter pressed');
        } else
        //
        // Rename
        if (event.logicalKey == LogicalKeyboardKey.f2) {
          print('F2 pressed: Rename');
        } else
        //
        // Modify path
        if (event.logicalKey == LogicalKeyboardKey.f4) {
          print('F4 pressed: Modify path');
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
    if (event.buttons == kBackMouseButton) {
      _exitSeriesView();
    } else if (event.buttons == kForwardMouseButton) {
      final homeState = homeKey.currentState;
      if (homeState != null && homeState.mounted && homeState.lastSelectedSeriesPath != null) {
        print('Forward button pressed: Navigate to series view');
        homeState.navigateToSeries(homeState.lastSelectedSeriesPath!);
      }
    }
  }

  void _exitSeriesView() {
    final homeState = homeKey.currentState;
    if (homeState != null && homeState.mounted) {
      print('Back button pressed: Exit series view');
      homeState.exitSeriesView();
    }
  }

  void _toggleSeason(int season) {
    final homeState = homeKey.currentState;
    if (homeState != null && homeState.mounted && homeState.isSeriesView) {
      final seriesScreenState = seriesScreenKey.currentState;
      
      if (seriesScreenState != null) {
        print('Ctrl + $season pressed: Toggling season $season');
        seriesScreenState.toggleSeasonExpander(season);
      } else {
        print('SeriesScreenState not found');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerSignal,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: _handleKeyPress,
        child: widget.child,
      ),
    );
  }
}
