import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

import '../../settings.dart';

class WindowStateService {
  /// Controls whether `saveWindowState` is allowed to persist the current window
  /// geometry to settings. This is intentionally initialized to `false` so that
  /// window state is *not* saved during startup/initialization, while the window
  /// size and position are still being configured. It should only be set to `true`
  /// after the window has finished its initial setup (e.g. from `splash_screen.dart`
  /// once the window has been shown and positioned) to avoid persisting transient
  /// or incorrect geometry.
  static final ValueNotifier<bool> isFullscreenNotifier = ValueNotifier<bool>(false);
  static bool shouldSaveWindowState = false;

  static Future<void> saveWindowState() async {
    if (!shouldSaveWindowState) return;
    final settings = SettingsManager();
    final isMaximized = await windowManager.isMaximized();
    final size = await windowManager.getSize();
    final position = await windowManager.getPosition();

    settings.windowMaximized = isMaximized;
    settings.windowWidth = size.width;
    settings.windowHeight = size.height;
    settings.windowX = position.dx;
    settings.windowY = position.dy;
  }

  static Future<Map<String, dynamic>?> loadWindowState() async {
    final settings = SettingsManager();
    if (settings.windowWidth == null || settings.windowHeight == null) return null;

    return {
      'x': settings.windowX,
      'y': settings.windowY,
      'width': settings.windowWidth,
      'height': settings.windowHeight,
      'maximized': settings.windowMaximized, // TODO remember size and position even when restored from maximized
    };
  }

  // TODO completely remove fullscreen feature in the future
  static Future<void> toggleFullScreen([bool? isFullscreen]) async {
    await windowManager.setFullScreen(isFullscreen ?? !isFullscreenNotifier.value);

    isFullscreenNotifier.value = await windowManager.isFullScreen(); // update state after toggling
    // isFullscreenNotifier.value = !isFullscreenNotifier.value; // update state after toggling
  }
}
