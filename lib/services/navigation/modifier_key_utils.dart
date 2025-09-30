import 'package:flutter/services.dart';
import '../../manager.dart';
import '../navigation/shortcuts.dart';

class ModifierKeyUtils {
  /// Checks and corrects stuck modifier keys (Ctrl/Shift) using hardware state.
  static void checkAndFixModifierKeys() {
    final hardwareKeyboard = HardwareKeyboard.instance;
    final bool actualCtrlPressed = Manager.isMacOS //
        ? (hardwareKeyboard.isMetaPressed)
        : (hardwareKeyboard.isControlPressed);
    final bool actualShiftPressed = hardwareKeyboard.isShiftPressed;

    if (KeyboardState.ctrlPressedNotifier.value != actualCtrlPressed) //
      KeyboardState.ctrlPressedNotifier.value = actualCtrlPressed;

    if (KeyboardState.shiftPressedNotifier.value != actualShiftPressed) //
      KeyboardState.shiftPressedNotifier.value = actualShiftPressed;
  }
}
