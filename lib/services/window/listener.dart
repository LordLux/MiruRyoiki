import 'dart:io';

import 'package:window_manager/window_manager.dart';

import '../../manager.dart';
import '../../utils/logging.dart';
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
    logTrace('Window focused');
  }

  // onWindowBlur

  @override
  void onWindowMaximize() {
    update();
    WindowStateService.saveWindowState();
    super.onWindowMaximize();
    WindowStateService.toggleFullScreen(false);
    logTrace('Window maximized');
  }

  @override
  void onWindowUnmaximize() {
    update();
    WindowStateService.saveWindowState();
    super.onWindowUnmaximize();
    WindowStateService.toggleFullScreen(false);
    logTrace('Window unmaximized');
  }

  @override
  void onWindowMinimize() {
    update();
    super.onWindowMinimize();
    WindowStateService.toggleFullScreen(false);
    logTrace('Window minimized');
  }

  @override
  void onWindowRestore() {
    update();
    super.onWindowRestore();
    WindowStateService.toggleFullScreen(false);
    logTrace('Window restored');
  }

  @override
  void onWindowResize() {
    // update();
    super.onWindowResize();
  }

  @override
  void onWindowResized() {
    update();
    WindowStateService.saveWindowState();
    super.onWindowResized();
    WindowStateService.toggleFullScreen(false);
    logTrace('Window resized');
  }

  // onWindowMove

  // onWindowMoved

  @override
  void onWindowEnterFullScreen() {
    update();
    super.onWindowEnterFullScreen();
    logTrace('Window entered full screen');
  }

  @override
  void onWindowLeaveFullScreen() {
    update();
    super.onWindowLeaveFullScreen();
    logTrace('Window left full screen');
  }

  @override
  void onWindowDocked() {
    update();
    WindowStateService.toggleFullScreen(false);
    super.onWindowDocked();
    logTrace('Window docked');
  }

  @override
  void onWindowUndocked() {
    update();
    WindowStateService.toggleFullScreen(false);
    super.onWindowUndocked();
    logTrace('Window undocked');
  }
}
