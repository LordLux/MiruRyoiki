import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:miruryoiki/database/database.dart';
import 'package:miruryoiki/main.dart';
import 'package:miruryoiki/services/library/library_provider.dart';
import 'package:miruryoiki/services/navigation/navigation.dart';
import 'package:provider/provider.dart';
import 'package:args/args.dart';
import 'package:package_info_plus/package_info_plus.dart';
// ignore: unused_import
import 'package:flutter/scheduler.dart' as scheduler show timeDilation;

import 'enums.dart';
import 'services/anilist/episode_title_service.dart';
import 'services/episode_navigation/anilist_progress_manager.dart';
import 'services/episode_navigation/episode_navigator.dart';
import 'services/episode_navigation/ui_episode_service.dart';
import 'services/navigation/shortcuts.dart';
import 'settings.dart';
import 'theme.dart';
import 'utils/screen.dart';

class Manager {
  static void init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    lastUpdate = packageInfo.updateTime;
  }

  static Future<void> closeDB() async => await db.close();

  static AppDatabase get db => Provider.of<Library>(context, listen: false).database;

  static const String appTitle = "MiruRyoiki";
  static late final String appVersion;
  static late final String buildNumber;
  static late final DateTime? lastUpdate;

  /// Indicates if the current dialog can be popped, used when dialogs have multiple 'views'
  static bool canPopDialog = true;
  static bool notificationsPopping = false;
  static Color? currentDominantColor;

  static List<String> accounts = [];

  static Uri? initialDeepLink;

  static ArgParser parser = ArgParser()..addFlag('help', abbr: 'h', help: 'Show this help message.', negatable: false);
  static ArgResults? _args;
  static ArgResults parsedArgs(List<String> args) {
    _args = parser.parse(args);
    return _args!;
  }

  static List<String> get args => _args?.arguments ?? [];

  static void parseArgs() {
    if (_args == null) return;
    final ArgResults args = _args!;
    if (args.arguments.isEmpty) return;

    if (args.wasParsed('help')) {
      // ignore: avoid_print
      print(parser.usage);
      exit(0);
    }
  }

  static void setState([VoidCallback? fn]) => homeKey.currentState?.setState(() => fn?.call());

  static BuildContext get context => rootNavigatorKey.currentContext!;

  static NavigationManager get navigation => Provider.of<NavigationManager>(context, listen: false);

  static SettingsManager get settings => rootNavigatorKey.currentContext != null ? SettingsManager() : Provider.of<SettingsManager>(context, listen: false);

  static EpisodeNavigator get episodeNavigator => EpisodeNavigator.instance;

  static AnilistProgressManager get anilistProgress => AnilistProgressManager.instance;

  static EpisodeTitleService get episodeTitleService => EpisodeTitleService.instance;

  static UIEpisodeService get uiEpisodeService => UIEpisodeService.instance;

  static AppTheme? _cachedAppTheme;

  static AppTheme get appTheme {
    if (rootNavigatorKey.currentContext != null) {
      try {
        return Provider.of<AppTheme>(rootNavigatorKey.currentContext!, listen: false);
      } catch (e) {
        if (_cachedAppTheme != null) return _cachedAppTheme!;

        _cachedAppTheme = AppTheme();
        return _cachedAppTheme!;
      }
    }

    return _cachedAppTheme ?? (_cachedAppTheme = AppTheme());
  }

  static AccentColor get accentColor => kDebugMode ? Colors.red : settings.accentColor.toAccentColor();
  static Color get genericGray => FluentTheme.of(context).acrylicBackgroundColor.lerpWith(const Color.fromARGB(255, 35, 35, 35), 0.5);
  static Color get pastelDominantColor => Color.lerp(currentDominantColor ?? accentColor, Colors.white, .8)!;
  static Color get pastelAccentColor => Color.lerp(accentColor, Colors.white, .8)!;

  /// A notifier that indicates whether the database is currently being saved.
  static final ValueNotifier<bool> isDatabaseSaving = ValueNotifier(false);

  static ImageSource get defaultPosterSource => settings.defaultPosterSource;

  static ImageSource get defaultBannerSource => settings.defaultBannerSource;

  static DominantColorSource get dominantColorSource => settings.dominantColorSource;

  static bool get animationsEnabled => !settings.disableAnimations;

  static bool get enableAnilistEpisodeTitles => settings.enableAnilistEpisodeTitles;

  static double get fontSizeMultiplier => ScreenUtils.textScaleFactor * ((rootNavigatorKey.currentContext != null ? appTheme.fontSize : kDefaultFontSize) / kDefaultFontSize);

  /// Checks if the current platform is MacOS
  static bool get isMacOS => Platform.isMacOS;

  /// Checks if the current platform is Windows 11
  static bool get isWin11 => Platform.operatingSystemVersion.startsWith('11');

  static bool get isCtrlPressed => KeyboardState.ctrlPressedNotifier.value;
  static bool get isShiftPressed => KeyboardState.shiftPressedNotifier.value;

  static TextStyle get displayStyle => FluentTheme.of(context).typography.display!;
  static TextStyle get titleLargeStyle => FluentTheme.of(context).typography.titleLarge!;
  static TextStyle get titleStyle => FluentTheme.of(context).typography.title!;
  static TextStyle get subtitleStyle => FluentTheme.of(context).typography.subtitle!;
  static TextStyle get smallSubtitleStyle => FluentTheme.of(context).typography.subtitle!.copyWith(fontSize: 16 * Manager.fontSizeMultiplier);
  static TextStyle get bodyLargeStyle => FluentTheme.of(context).typography.bodyLarge!;
  static TextStyle get bodyStyle => FluentTheme.of(context).typography.body!;
  static TextStyle get bodyStrongStyle => FluentTheme.of(context).typography.bodyStrong!;
  static TextStyle get captionStyle => FluentTheme.of(context).typography.caption!;
  static TextStyle get miniBodyStyle => FluentTheme.of(context).typography.body!.copyWith(fontSize: 10 * fontSizeMultiplier);
}
