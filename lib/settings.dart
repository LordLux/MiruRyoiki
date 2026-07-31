import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:miruryoiki/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database/database.dart';
import 'database/daos/settings_dao.dart';
import 'enums.dart';
import 'manager.dart';
import 'theme.dart';
import 'utils/time.dart';
import 'utils/logging.dart';
import 'utils/storage.dart';

class SettingsManager extends ChangeNotifier {
  static final SettingsManager _instance = SettingsManager._internal();
  factory SettingsManager() => _instance;
  SettingsManager._internal();

  // Underlying storage
  // ignore: prefer_final_fields
  Map<String, dynamic> _settings = {};
  SettingsDao? _settingsDao;
  SharedPreferences? _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String _sonarrApiKey = '';
  bool _initialized = false;

  /// True when running under `flutter test`. Used to suppress the expected
  /// "saved before SettingsDao initialized" log noise that only occurs in the
  /// DB-less test environment; the same condition in production is a real
  /// ordering bug worth logging loudly.
  static final bool _isTestEnv = Platform.environment.containsKey('FLUTTER_TEST');

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

  PageTransitionMode get pageTransitionMode => PageTransitionModeX.fromString(_getString('pageTransitionMode', defaultValue: PageTransitionMode.fade.name_));
  set pageTransitionMode(PageTransitionMode value) => _setString('pageTransitionMode', value.name_);

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

  DatePickerType get datePickerType => DatePickerTypeX.fromString(_getString('datePickerType', defaultValue: DatePickerType.calendar.name_));
  set datePickerType(DatePickerType value) => _setString('datePickerType', value.name_);

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

  // Defaults to false: a user who right-clicks -> Hide on a series expects
  // it to actually disappear, not remain visible until they also flip a setting.
  bool get showHiddenSeries => _getBool('showHiddenSeries', defaultValue: false);
  set showHiddenSeries(bool value) => _setBool('showHiddenSeries', value);

  // Defaults to true: private-on-AniList is the user's own account setting,
  // not something set from within this app, so there's no equivalent
  // "I just chose to hide this" expectation - a user wants to see their own
  // private series here by default.
  bool get showPrivateSeries => _getBool('showPrivateSeries', defaultValue: true);
  set showPrivateSeries(bool value) => _setBool('showPrivateSeries', value);

  bool get useInfiniteScroll => _getBool('useInfiniteScroll', defaultValue: true);
  set useInfiniteScroll(bool value) => _setBool('useInfiniteScroll', value);

  bool get suppressCloseWarning => _getBool('suppressCloseWarning', defaultValue: false);
  set suppressCloseWarning(bool value) => _setBool('suppressCloseWarning', value);

  // Window State
  double? get windowX => _prefs?.getDouble('window_x');
  set windowX(double? value) {
    if (value == null) {
      _prefs?.remove('window_x');
      return;
    }
    _prefs?.setDouble('window_x', value);
  }

  double? get windowY => _prefs?.getDouble('window_y');
  set windowY(double? value) {
    if (value == null) {
      _prefs?.remove('window_y');
      return;
    }
    _prefs?.setDouble('window_y', value);
  }

  double? get windowWidth => _prefs?.getDouble('window_width');
  set windowWidth(double? value) {
    if (value == null) {
      _prefs?.remove('window_width');
      return;
    }
    _prefs?.setDouble('window_width', value);
  }

  double? get windowHeight => _prefs?.getDouble('window_height');
  set windowHeight(double? value) {
    if (value == null) {
      _prefs?.remove('window_height');
      return;
    }
    _prefs?.setDouble('window_height', value);
  }

  bool get windowMaximized => _prefs?.getBool('window_maximized') ?? false;
  set windowMaximized(bool value) => _prefs?.setBool('window_maximized', value);

  // Media Player Settings
  List<String> get mediaPlayerPriority => _getStringList('mediaPlayerPriority', defaultValue: ['vlc', 'mpc-hc']);
  set mediaPlayerPriority(List<String> value) => _setStringList('mediaPlayerPriority', value);

  bool get enableMediaPlayerIntegration => _getBool('enableMediaPlayerIntegration', defaultValue: true);
  set enableMediaPlayerIntegration(bool value) => _setBool('enableMediaPlayerIntegration', value);

  bool get enableMpcHcSlaveMode => _getBool('enableMpcHcSlaveMode', defaultValue: true);
  set enableMpcHcSlaveMode(bool value) {
    // Re-enabling slave mode gives the one-time "locate MPC-HC" setup prompt another chance
    if (value && !enableMpcHcSlaveMode) mpcHcSlavePromptShown = false;
    _setBool('enableMpcHcSlaveMode', value);
  }

  String get mpcHcExecutablePath => _getString('mpcHcExecutablePath', defaultValue: '');
  set mpcHcExecutablePath(String value) => _setString('mpcHcExecutablePath', value);

  String get mpcHcDetectedPath => _getString('mpcHcDetectedPath', defaultValue: '');
  set mpcHcDetectedPath(String value) => _setString('mpcHcDetectedPath', value);

  bool get mpcHcSlavePromptShown => _getBool('mpcHcSlavePromptShown', defaultValue: false);
  set mpcHcSlavePromptShown(bool value) => _setBool('mpcHcSlavePromptShown', value);

  // AniList Episode Titles
  bool get enableAnilistEpisodeTitles => _getBool('enableAnilistEpisodeTitles', defaultValue: false);
  set enableAnilistEpisodeTitles(bool value) => _setBool('enableAnilistEpisodeTitles', value);

  // Sonarr
  String get sonarrBaseUrl => _getString('sonarrBaseUrl', defaultValue: '');
  set sonarrBaseUrl(String value) {
    if (sonarrBaseUrl != value) sonarrConnectionVerified = false;
    _setString('sonarrBaseUrl', value);
  }

  String get sonarrApiKey => _sonarrApiKey;
  set sonarrApiKey(String value) {
    if (_sonarrApiKey == value) return;
    _sonarrApiKey = value;
    sonarrConnectionVerified = false;
    _secureStorage.write(key: secureKey('sonarrApiKey'), value: value);
    notifyListeners();
  }

  int get sonarrQualityProfileId => _getInt('sonarrQualityProfileId', defaultValue: 0);
  set sonarrQualityProfileId(int value) => _setInt('sonarrQualityProfileId', value);

  String get sonarrRootFolderPath => _getString('sonarrRootFolderPath', defaultValue: '');
  set sonarrRootFolderPath(String value) => _setString('sonarrRootFolderPath', value);

  /// Whether the last Sonarr connection test succeeded with the current credentials
  bool get sonarrConnectionVerified => _getBool('sonarrConnectionVerified', defaultValue: false);
  set sonarrConnectionVerified(bool value) => _setBool('sonarrConnectionVerified', value);

  bool get isSonarrConfigured => sonarrApiKey.isNotEmpty;

  // qBittorrent
  String get qbitBaseUrl => _getString('qbitBaseUrl', defaultValue: '');
  set qbitBaseUrl(String value) {
    if (qbitBaseUrl != value) qbitConnectionVerified = false;
    _setString('qbitBaseUrl', value);
  }

  String get qbitUsername => _getString('qbitUsername', defaultValue: '');
  set qbitUsername(String value) {
    if (qbitUsername != value) qbitConnectionVerified = false;
    _setString('qbitUsername', value);
  }

  String _qbitPassword = '';
  String get qbitPassword => _qbitPassword;
  set qbitPassword(String value) {
    if (_qbitPassword == value) return;
    _qbitPassword = value;
    qbitConnectionVerified = false;
    _secureStorage.write(key: secureKey('qbitPassword'), value: value);
    notifyListeners();
  }

  bool get qbitConnectionVerified => _getBool('qbitConnectionVerified', defaultValue: false);
  set qbitConnectionVerified(bool value) => _setBool('qbitConnectionVerified', value);

  bool get isQbitConfigured => qbitPassword.isNotEmpty;

  /// Whether any torrent client is configured
  bool get isTorrentClientConfigured => isQbitConfigured; // Expand when adding more clients

  /// Whether all download services (Sonarr + a torrent client) are configured
  bool get isDownloadsFullyConfigured => isSonarrConfigured && isTorrentClientConfigured;

  // Knaben
  bool get knabenUseAnimeCategories => _getBool('knabenUseAnimeCategories', defaultValue: true);
  set knabenUseAnimeCategories(bool value) => _setBool('knabenUseAnimeCategories', value);

  bool get knabenLiveSearch => _getBool('knabenLiveSearch', defaultValue: false);
  set knabenLiveSearch(bool value) => _setBool('knabenLiveSearch', value);

  // Speed Graph
  Set<String> get graphMetrics {
    final list = _getStringList('graphMetrics', defaultValue: ['totalDownload', 'totalUpload']);
    return list.toSet();
  }

  set graphMetrics(Set<String> value) => _setStringList('graphMetrics', value.toList());

  int get graphTimeframeMinutes => _getInt('graphTimeframeMinutes', defaultValue: 10);
  set graphTimeframeMinutes(int value) => _setInt('graphTimeframeMinutes', value);

  int get graphUpdateFrequencySeconds => _getInt('graphUpdateFrequencySeconds', defaultValue: 1);
  set graphUpdateFrequencySeconds(int value) => _setInt('graphUpdateFrequencySeconds', value);

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
    _prefs = await SharedPreferences.getInstance();
    await loadSettings();
    await _loadSecureSettings();
    _initialized = true;
  }

  // Load current settings as a map
  Future<void> loadSettings() async {
    if (_settingsDao == null) return;
    final settingsMap = await _settingsDao!.getAll();
    _settings.addAll(settingsMap);
    notifyListeners();
  }

  /// Load secrets from encrypted storage
  Future<void> _loadSecureSettings() async {
    _sonarrApiKey = await _secureStorage.read(key: secureKey('sonarrApiKey')) ?? '';
    _qbitPassword = await _secureStorage.read(key: secureKey('qbitPassword')) ?? '';
  }

  // Save a single setting to DB
  Future<void> _saveToDb(String key, String value) async {
    if (_settingsDao == null) {
      if (!_isTestEnv) logErr('Attempted to save setting $key before SettingsDao was initialized.');
      return;
    }
    await _settingsDao!.set(key, value);
  }

  // Save all settings to DB
  Future<void> saveAllSettings() async {
    if (_settingsDao == null) {
      if (!_isTestEnv) logErr('Attempted to save all settings before SettingsDao was initialized.');
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

  /// Reset all torrent/download config (qBit, Sonarr, Knaben) but preserve episode link mappings
  Future<void> resetTorrentConfig() async {
    const keys = [
      'qbitBaseUrl', 'qbitUsername', 'qbitConnectionVerified',
      'sonarrBaseUrl', 'sonarrConnectionVerified',
      'sonarrQualityProfileId', 'sonarrRootFolderPath',
      'knabenUseAnimeCategories', 'knabenLiveSearch',
    ];
    for (final key in keys) {
      _settings.remove(key);
      _settingsDao?.deleteKey(key);
    }
    // Clear secure storage secrets
    await _secureStorage.delete(key: secureKey('qbitPassword'));
    await _secureStorage.delete(key: secureKey('sonarrApiKey'));
    _qbitPassword = '';
    _sonarrApiKey = '';
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
