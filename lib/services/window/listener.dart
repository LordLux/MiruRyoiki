import 'dart:io';

import 'package:window_manager/window_manager.dart';

import '../../manager.dart';
import '../../utils/time_utils.dart';
import 'service.dart';

class MyWindowListener extends WindowListener {
  void update() => nextFrame(() => Manager.setState());

  @override
  void onWindowClose() async {
    await WindowStateService.saveWindowState();
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
    WindowStateService.saveWindowState();
    super.onWindowMaximize();
  }

  @override
  void onWindowUnmaximize() {
    update();
    WindowStateService.saveWindowState();
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
    WindowStateService.saveWindowState();
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
