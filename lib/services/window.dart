import 'dart:io';

import 'package:window_manager/window_manager.dart';

import '../manager.dart';
import '../utils/time_utils.dart';

class MyWindowListener extends WindowListener {
  @override
  void onWindowResize() {
    nextFrame(() => Manager.setState()); // Update the state when the window is resized
    super.onWindowResize();
  }

  @override
  void onWindowMaximize() {
    nextFrame(() => Manager.setState()); // Update the state when the window is maximized
    super.onWindowMaximize();
  }

  @override
  void onWindowUnmaximize() {
    nextFrame(() => Manager.setState()); // Update the state when the window is unmaximized
    super.onWindowUnmaximize();
  }

  @override
  void onWindowClose() async {
    windowManager.setPreventClose(false);
    windowManager.close();
    exit(0);
  }
}
