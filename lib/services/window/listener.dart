import 'package:fluent_ui/fluent_ui.dart';

import '../navigation/dialogs.dart';
import '../navigation/modifier_key_utils.dart';
import 'dart:io';

import 'package:miruryoiki/main.dart';
import 'package:window_manager/window_manager.dart';

import '../../manager.dart';
import '../../utils/logging.dart';
import '../../utils/time.dart';
import 'service.dart';

class MyWindowListener extends WindowListener {
  void update() => nextFrame(() => Manager.setState());

  @override
  void onWindowClose() async {
    if (Manager.isDatabaseSaving.value) {
      logDebug('Window close requested while database is saving, waiting...');
      await windowManager.setPreventClose(true);
      if (Manager.context.mounted && Manager.navigation.currentView?.id == 'SavingDatabaseDialog') {
        final title = 'Saving Database';
        showManagedDialog(
          context: Manager.context,
          id: 'SavingDatabaseDialog',
          title: title,
          dialogDoPopCheck: () => false,
          canUserPopDialog: false,
          closeExistingDialogs: true,
          builder: (context) {
            return ManagedDialog(
              popContext: context,
              title: Text(title),
              contentBuilder: (p0, p1) => Text('Please wait while the database is being saved...\nThe program will close automatically once the process is complete.'),
              constraints: const BoxConstraints(maxWidth: 500, minWidth: 300),
              actions: (popContext) => [],
            );
          },
        );
      }

      while (Manager.isDatabaseSaving.value) await Future.delayed(const Duration(milliseconds: 50));
    }
    logDebug('Window close requested, saving window state and closing...');
    await WindowStateService.saveWindowState();
    windowManager.setPreventClose(false);
    windowManager.close();
    await Manager.closeDB();
    await windowManager.destroy();
    exit(0);
  }

  @override
  void onWindowFocus() {
    update();
    // Fix stuck modifier keys when regaining focus
    ModifierKeyUtils.checkAndFixModifierKeys();
    super.onWindowFocus();
    // logTrace('Window focused');
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
    libraryScreenKey.currentState?.measureCardSize();
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
