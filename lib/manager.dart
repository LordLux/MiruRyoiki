import 'dart:io';
import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/main.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'enums.dart';
import 'services/shortcuts.dart';
import 'theme.dart';

class Manager {
  static const double titleBarHeight = 40.0;
  static const int dynMouseScrollDuration = 150;
  static const double dynMouseScrollScrollSpeed = 1;
  static const String appTitle = "MiruRyoiki";

  static bool get isMacOS => Platform.isMacOS;

  static bool get isCtrlPressed => KeyboardState.ctrlPressedNotifier.value;
  static bool get isShiftPressed => KeyboardState.shiftPressedNotifier.value;
}

class SettingsManager {
  static Map<String, dynamic> settings = {};
  // Load current settings as a map
  static Future<Map<String, String>> _loadCurrentSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> settingsList = prefs.getStringList('settings') ?? [];
    Map<String, String> settingsMap = {};

    for (String setting in settingsList) {
      final List<String> parts = setting.split(':');
      if (parts.length >= 2) {
        // Handle values with colons
        final String key = parts[0];
        final String value = parts.sublist(1).join(':');
        settingsMap[key] = value;
      }
    }

    return settingsMap;
  }

  static Future<void> resetSingleSetting(String setting) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, String> currentSettings = await _loadCurrentSettings();
    if (currentSettings.containsKey(setting))
      currentSettings.remove(setting);
    else
      return;

    final List<String> settingsList = currentSettings.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList('settings', settingsList);
  }

  // Save one or more settings
  static Future<void> saveSettings(Map<String, dynamic> newSettings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Load current settings and merge with new ones
    final Map<String, String> currentSettings = await _loadCurrentSettings();
    newSettings.forEach((key, value) {
      currentSettings[key] = value.toString();
    });
    final List<String> settingsList = currentSettings.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList('settings', settingsList);
  }

  // Load settings
  static Future<Map<String, String>> loadSettings() async {
    return await _loadCurrentSettings();
  }

  static Future<void> assignSettings(BuildContext context) async {
    final AppTheme appTheme = Provider.of<AppTheme>(context, listen: false);
    if (_settingCheck(settings["windowEffect"])) appTheme.windowEffect = WindowEffectX.fromString(settings["windowEffect"]);
    if (_settingCheck(settings["themeMode"])) appTheme.mode = ThemeX.fromString(settings["themeMode"]);
    if (_settingCheck(settings["accentColor"])) appTheme.color = settings["accentColor"].fromHex();
    if (_settingCheck(settings["fontSize"])) appTheme.fontSize = double.parse(settings["fontSize"]);
  }

  static void clearSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('settings', []);
    settings = {};
  }

  static bool _settingCheck(String? setting) => setting != null && setting != "" && setting != "null";
}
