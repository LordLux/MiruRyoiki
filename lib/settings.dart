import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:miruryoiki/main.dart';
import 'package:provider/provider.dart';

import 'database/database.dart';
import 'database/daos/settings_dao.dart';
import 'enums.dart';
import 'manager.dart';
import 'theme.dart';
import 'utils/time.dart';
import 'utils/logging.dart';

class SettingsManager extends ChangeNotifier {
  static final SettingsManager _instance = SettingsManager._internal();
  factory SettingsManager() => _instance;
  SettingsManager._internal();

  // Underlying storage
  // ignore: prefer_final_fields
  Map<String, dynamic> _settings = {};
  SettingsDao? _settingsDao;
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
  set dim(Dim value) => _setString('dim', value.name_.toLowerCase());

  ThemeMode get themeMode => ThemeX.fromString(_getString('themeMode', defaultValue: ThemeMode.dark.name_));
  set themeMode(ThemeMode value) => _setString('themeMode', value.name_);

  Color get accentColor => _getString('accentColor', defaultValue: Color(0xFF7c52ff).toHex()).fromHex();
  set accentColor(Color value) => _setString('accentColor', value.toHex());

  bool get disableAnimations => _getBool('disableAnimations', defaultValue: false);
  set disableAnimations(bool value) => _setBool('disableAnimations', value);

  bool get squigglySliderEnabled => _getBool('squigglySliderEnabled', defaultValue: true);
  set squigglySliderEnabled(bool value) => _setBool('squigglySliderEnabled', value);

  bool get useAcrylicTooltips => _getBool('useAcrylicTooltips', defaultValue: false);
  set useAcrylicTooltips(bool value) => _setBool('useAcrylicTooltips', value);

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

  bool get returnToLibraryAfterSeriesScreen => _getBool('returnToLibraryAfterSeriesScreen', defaultValue: true);
  set returnToLibraryAfterSeriesScreen(bool value) => _setBool('returnToLibraryAfterSeriesScreen', value);

  bool get confirmClearAllThumbnails => _getBool('confirmClearAllThumbnails', defaultValue: false);
  set confirmClearAllThumbnails(bool value) => _setBool('confirmClearAllThumbnails', value);

  bool get showAiringIndicator => _getBool('showAiringIndicator', defaultValue: true);
  set showAiringIndicator(bool value) => _setBool('showAiringIndicator', value);

  bool get hoverExpandAiringIndicator => _getBool('hoverExpandAiringIndicator', defaultValue: false);
  set hoverExpandAiringIndicator(bool value) => _setBool('hoverExpandAiringIndicator', value);

  FirstDayOfWeek get firstDayOfWeek => FirstDayOfWeekX.fromString(_getString('firstDayOfWeek', defaultValue: FirstDayOfWeek.monday.name_));
  set firstDayOfWeek(FirstDayOfWeek value) => _setString('firstDayOfWeek', value.name_);

  // Logging
  LogLevel get fileLogLevel => LogLevelX.fromString(_getString('fileLogLevel', defaultValue: LogLevel.error.name_));
  set fileLogLevel(LogLevel value) {
    final oldLevel = fileLogLevel;
    _setString('fileLogLevel', value.name_);
    // Log the change to the file
    if (oldLevel != value) logFileSettingChanged(oldLevel, value);
  }

  int get logRetentionDays => _getInt('logRetentionDays', defaultValue: 7);
  set logRetentionDays(int value) => _setInt('logRetentionDays', value);

  bool get showHiddenSeries => _getBool('showHiddenSeries', defaultValue: false);
  set showHiddenSeries(bool value) => _setBool('showHiddenSeries', value);

  bool get showAnilistHiddenSeries => _getBool('showAnilistHiddenSeries', defaultValue: false);
  set showAnilistHiddenSeries(bool value) => _setBool('showAnilistHiddenSeries', value);

  // Window State
  double? get windowX => _getDoubleOrNull('window_x');
  set windowX(double? value) {
    if (value == null) return;
    _setDouble('window_x', value);
  }

  double? get windowY => _getDoubleOrNull('window_y');
  set windowY(double? value) {
    if (value == null) return;
    _setDouble('window_y', value);
  }

  double? get windowWidth => _getDoubleOrNull('window_width');
  set windowWidth(double? value) {
    if (value == null) return;
    _setDouble('window_width', value);
  }

  double? get windowHeight => _getDoubleOrNull('window_height');
  set windowHeight(double? value) {
    if (value == null) return;
    _setDouble('window_height', value);
  }

  bool get windowMaximized => _getBool('window_maximized', defaultValue: false);
  set windowMaximized(bool value) => _setBool('window_maximized', value);

  // Media Player Settings
  List<String> get mediaPlayerPriority => _getStringList('mediaPlayerPriority', defaultValue: ['vlc', 'mpc-hc']);
  set mediaPlayerPriority(List<String> value) => _setStringList('mediaPlayerPriority', value);

  bool get enableMediaPlayerIntegration => _getBool('enableMediaPlayerIntegration', defaultValue: true);
  set enableMediaPlayerIntegration(bool value) => _setBool('enableMediaPlayerIntegration', value);

  // AniList Episode Titles
  bool get enableAnilistEpisodeTitles => _getBool('enableAnilistEpisodeTitles', defaultValue: false);
  set enableAnilistEpisodeTitles(bool value) => _setBool('enableAnilistEpisodeTitles', value);

  // Genres
  List<String> get genres => _getStringList('genres', defaultValue: []);
  set genres(List<String> value) => _setStringList('genres', value);

  // Dialog Heights
  double get genresFilterHeight => _getDouble('genresFilterHeight', defaultValue: 329.0);
  set genresFilterHeight(double value) => _setDouble('genresFilterHeight', value);

  double get listsDialogHeight => _getDouble('listsDialogHeight', defaultValue: 346.0);
  set listsDialogHeight(double value) => _setDouble('listsDialogHeight', value);

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

  double? _getDoubleOrNull(String key) {
    if (!_settings.containsKey(key)) return null;
    final value = _settings[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
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

  int _getInt(String key, {required int defaultValue}) {
    if (!_settings.containsKey(key)) {
      // logTrace('Key $key not found in settings, returning default value: $defaultValue');
      return defaultValue;
    }
    final value = _settings[key];
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
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
    _saveToDb(key, value.toString());
    notifyListeners();
  }

  void _setDouble(String key, double value) {
    if (_settings[key] == value) return; // No change
    _settings[key] = value;
    _saveToDb(key, value.toString());
    notifyListeners();
  }

  void _setInt(String key, int value) {
    if (_settings[key] == value) return; // No change
    _settings[key] = value;
    _saveToDb(key, value.toString());
    notifyListeners();
  }

  void _setString(String key, String value) {
    if (_settings[key] == value) return; // No change
    _settings[key] = value;
    _saveToDb(key, value);
    notifyListeners();
  }

  List<String> _getStringList(String key, {required List<String> defaultValue}) {
    if (!_settings.containsKey(key)) return defaultValue;

    final value = _settings[key];
    if (value is List<String>) return value;
    if (value is String) return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(); // Parse comma-separated string
    return defaultValue;
  }

  void _setStringList(String key, List<String> value) {
    final currentValue = _getStringList(key, defaultValue: []);
    if (currentValue.length == value.length && currentValue.every((element) => value.contains(element))) return; // No change
    _settings[key] = value;
    _saveToDb(key, value.join(','));
    notifyListeners();
  }

  // For any other type of setting
  dynamic get(String key, {dynamic defaultValue}) => _settings[key] ?? defaultValue;

  void set(String key, dynamic value) {
    if (_settings[key] == value) return;

    _settings[key] = value;
    _saveToDb(key, value.toString());
    notifyListeners();
  }

  Future<void> init(AppDatabase db) async {
    if (_initialized) return;

    _settingsDao = SettingsDao(db);
    await loadSettings();
    _initialized = true;
  }

  // Load current settings as a map
  Future<void> loadSettings() async {
    if (_settingsDao == null) return;
    final settingsMap = await _settingsDao!.getAll();
    _settings.addAll(settingsMap);
    notifyListeners();
  }

  // Save a single setting to DB
  Future<void> _saveToDb(String key, String value) async {
    if (_settingsDao == null) {
      logErr('Attempted to save setting $key before SettingsDao was initialized.');
      return;
    }
    await _settingsDao!.set(key, value);
  }

  // Save all settings to DB
  Future<void> saveAllSettings() async {
    if (_settingsDao == null) {
      logErr('Attempted to save all settings before SettingsDao was initialized.');
      return;
    }
    
    for (var entry in _settings.entries) {
      await _settingsDao!.set(entry.key, entry.value.toString());
    }
  }

  // Reset a single setting
  Future<void> resetSetting(String setting) async {
    if (_settings.containsKey(setting)) {
      _settings.remove(setting);
      // TODO: Implement delete in DAO if needed
      notifyListeners();
    }
  }

  Future<void> clearSettings() async {
    _settings.clear();
    // TODO: Implement clear in DAO if needed
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
