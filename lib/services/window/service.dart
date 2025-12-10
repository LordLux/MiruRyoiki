import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

import '../../settings.dart';

class WindowStateService {
  static final ValueNotifier<bool> isFullscreenNotifier = ValueNotifier<bool>(false);

  static Future<void> saveWindowState() async {
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

  static void toggleFullScreen([bool? isFullscreen]) async {
    windowManager.setFullScreen(isFullscreen ?? !isFullscreenNotifier.value);

    isFullscreenNotifier.value = await windowManager.isFullScreen(); // update state after toggling
    // isFullscreenNotifier.value = !isFullscreenNotifier.value; // update state after toggling
  }
}
