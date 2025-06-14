import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:miruryoiki/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'enums.dart';
import 'manager.dart';
import 'theme.dart';
import 'utils/time_utils.dart';

class SettingsManager extends ChangeNotifier {
  static final SettingsManager _instance = SettingsManager._internal();
  factory SettingsManager() => _instance;
  SettingsManager._internal();

  // Underlying storage
  // ignore: prefer_final_fields
  Map<String, dynamic> _settings = {};
  SharedPreferences? _prefs;
  bool _initialized = false;

  // // Typed getters/setters for settings
  // Appearance
  double get fontSize => (rootNavigatorKey.currentContext != null) ? Manager.appTheme.fontSize : kDefaultFontSize;
  set fontSize(double value) {
    if (rootNavigatorKey.currentContext != null) Manager.appTheme.fontSize = value;
    _setDouble('fontSize', value);
  }

  WindowEffect get windowEffect => WindowEffectX.fromString(_getString('windowEffect', defaultValue: WindowEffect.acrylic.name_));
  set windowEffect(WindowEffect value) => _setString('windowEffect', value.name_);

  Dim get dim => DimX.fromString(_getString('dim', defaultValue: Dim.normal.name_));
  set dim(Dim value) => _setString('dim', value.name_);

  ThemeMode get themeMode => ThemeX.fromString(_getString('themeMode', defaultValue: ThemeMode.dark.name_));
  set themeMode(ThemeMode value) => _setString('themeMode', value.name_);

  Color get accentColor => _getString('accentColor', defaultValue: Color(0xFF0078d4).toHex()).fromHex();
  set accentColor(Color value) => _setString('accentColor', value.toHex());

  bool get disableAnimations => _getBool('disableAnimations', defaultValue: false);
  set disableAnimations(bool value) => _setBool('disableAnimations', value);

  // Behavior
  bool get autoLoadAnilistPosters => _getBool('autoLoadAnilistPosters', defaultValue: true);
  set autoLoadAnilistPosters(bool value) => _setBool('autoLoadAnilistPosters', value);

  LibraryColorView get libColView => LibraryColorViewX.fromString(_getString('libColView', defaultValue: LibraryColorView.alwaysDominant.name_));
  set libColView(LibraryColorView value) => _setString('libColView', value.name_);

  ImageSource get defaultPosterSource => PosterSourceX.fromString(_getString('defaultPosterSource', defaultValue: ImageSource.autoAnilist.name_));
  set defaultPosterSource(ImageSource value) => _setString('defaultPosterSource', value.name_);

  ImageSource get defaultBannerSource => PosterSourceX.fromString(_getString('defaultBannerSource', defaultValue: ImageSource.autoAnilist.name_));
  set defaultBannerSource(ImageSource value) => _setString('defaultBannerSource', value.name_);

  DominantColorSource get dominantColorSource => DominantColorSourceX.fromString(_getString('dominantColorSource', defaultValue: DominantColorSource.poster.name_));
  set dominantColorSource(DominantColorSource value) => _setString('dominantColorSource', value.name_);

  // // Generic getters with type safety
  bool _getBool(String key, {required bool defaultValue}) {
    if (!_settings.containsKey(key)) {
      // logTrace('Key $key not found in settings, returning default value: $defaultValue');
      return defaultValue;
    }
    final value = _settings[key];
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return defaultValue;
  }

  double _getDouble(String key, {required double defaultValue}) {
    if (!_settings.containsKey(key)) {
      // logTrace('Key $key not found in settings, returning default value: $defaultValue');
      return defaultValue;
    }
    final value = _settings[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  String _getString(String key, {required String defaultValue}) {
    if (!_settings.containsKey(key)) {
      // logTrace('Key $key not found in settings, returning default value: $defaultValue');
      return defaultValue;
    }
    final value = _settings[key];
    return value?.toString() ?? defaultValue;
  }

  // Generic setters with auto-save
  void _setBool(String key, bool value) {
    if (_settings[key] == value) return; // No change
    _settings[key] = value;
    _saveToPrefs(key, value.toString());
    notifyListeners();
  }

  void _setDouble(String key, double value) {
    if (_settings[key] == value) return; // No change
    _settings[key] = value;
    _saveToPrefs(key, value.toString());
    notifyListeners();
  }

  void _setString(String key, String value) {
    if (_settings[key] == value) return; // No change
    _settings[key] = value;
    _saveToPrefs(key, value);
    notifyListeners();
  }

  // For any other type of setting
  dynamic get(String key, {dynamic defaultValue}) {
    return _settings[key] ?? defaultValue;
  }

  void set(String key, dynamic value) {
    if (_settings[key] == value) return;
    _settings[key] = value;
    _saveToPrefs(key, value.toString());
    notifyListeners();
  }

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    await loadSettings();
    _initialized = true;
  }

  // Load current settings as a map
  Future<void> loadSettings() async {
    _prefs ??= await SharedPreferences.getInstance();
    final List<String> settingsList = _prefs!.getStringList('settings') ?? [];

    for (String setting in settingsList) {
      final List<String> parts = setting.split(':');
      if (parts.length >= 2) {
        // Handle values with colons
        final String key = parts[0];
        final String value = parts.sublist(1).join(':');
        _settings[key] = value;
      }
    }

    notifyListeners();
  }

  // Save a single setting to SharedPreferences
  Future<void> _saveToPrefs(String key, String value) async {
    _prefs ??= await SharedPreferences.getInstance();
    final Map<String, String> currentSettings = {};

    final List<String> settingsList = _prefs!.getStringList('settings') ?? [];
    for (String setting in settingsList) {
      final List<String> parts = setting.split(':');
      if (parts.length >= 2) {
        final String key = parts[0];
        final String val = parts.sublist(1).join(':');
        currentSettings[key] = val;
      }
    }

    currentSettings[key] = value;
    final updatedSettingsList = currentSettings.entries.map((e) => '${e.key}:${e.value}').toList();
    await _prefs!.setStringList('settings', updatedSettingsList);
  }

  // Save all settings to SharedPreferences
  Future<void> saveAllSettings() async {
    _prefs ??= await SharedPreferences.getInstance();
    final List<String> settingsList = _settings.entries.map((e) => '${e.key}:${e.value}').toList();
    await _prefs!.setStringList('settings', settingsList);
  }

  // Reset a single setting
  Future<void> resetSetting(String setting) async {
    if (_settings.containsKey(setting)) {
      _settings.remove(setting);
      await saveAllSettings();
      notifyListeners();
    }
  }

  Future<void> clearSettings() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setStringList('settings', []);
    _settings.clear();
    notifyListeners();
  }

  // Apply settings to app components
  void applySettings(BuildContext context) {
    final AppTheme appTheme = Provider.of<AppTheme>(context, listen: false);
    appTheme.windowEffect = windowEffect;
    appTheme.mode = themeMode; // set to dark mode
    appTheme.dim = dim;
    appTheme.color = accentColor.toAccentColor();
    nextFrame(() => appTheme.fontSize = fontSize);
  }
}
