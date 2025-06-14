import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class WindowStateService {
  static const _keyX = 'window_x';
  static const _keyY = 'window_y';
  static const _keyWidth = 'window_width';
  static const _keyHeight = 'window_height';
  static const _keyMaximized = 'window_maximized';

  static Future<void> saveWindowState() async {
    final prefs = await SharedPreferences.getInstance();
    final isMaximized = await windowManager.isMaximized();
    final size = await windowManager.getSize();
    final position = await windowManager.getPosition();

    await prefs.setBool(_keyMaximized, isMaximized);
    await prefs.setDouble(_keyWidth, size.width);
    await prefs.setDouble(_keyHeight, size.height);
    await prefs.setDouble(_keyX, position.dx);
    await prefs.setDouble(_keyY, position.dy);
  }

  static Future<Map<String, dynamic>?> loadWindowState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_keyWidth) || !prefs.containsKey(_keyHeight)) return null;
    return {
      'x': prefs.getDouble(_keyX),
      'y': prefs.getDouble(_keyY),
      'width': prefs.getDouble(_keyWidth),
      'height': prefs.getDouble(_keyHeight),
      'maximized': prefs.getBool(_keyMaximized) ?? false,
    };
  }
}