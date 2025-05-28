import 'dart:io';

import 'package:window_manager/window_manager.dart';

import '../manager.dart';
import '../utils/time_utils.dart';

class MyWindowListener extends WindowListener {
  void update() => nextFrame(() => Manager.setState());

  @override
  void onWindowClose() async {
    windowManager.setPreventClose(false);
    windowManager.close();
    exit(0);
  }

  @override
  void onWindowFocus() {
    update();
    super.onWindowFocus();
  }

  // onWindowBlur

  @override
  void onWindowMaximize() {
    update();
    super.onWindowMaximize();
  }

  @override
  void onWindowUnmaximize() {
    update();
    super.onWindowUnmaximize();
  }

  @override
  void onWindowMinimize() {
    update();
    super.onWindowMinimize();
  }

  @override
  void onWindowRestore() {
    update();
    super.onWindowRestore();
  }

  @override
  void onWindowResize() {
    update();
    super.onWindowResize();
  }

  @override
  void onWindowResized() {
    update();
    super.onWindowResized();
  }

  // onWindowMove

  // onWindowMoved

  @override
  void onWindowEnterFullScreen() {
    update();
    super.onWindowEnterFullScreen();
  }

  @override
  void onWindowLeaveFullScreen() {
    update();
    super.onWindowLeaveFullScreen();
  }

  @override
  void onWindowDocked() {
    update();
    super.onWindowDocked();
  }

  @override
  void onWindowUndocked() {
    update();
    super.onWindowUndocked();
  }
}
