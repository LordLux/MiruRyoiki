import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/main.dart';
import 'package:miruryoiki/services/navigation/navigation.dart';
import 'package:provider/provider.dart';

import 'enums.dart';
import 'services/navigation/shortcuts.dart';
import 'settings.dart';
import 'theme.dart';
import 'utils/logging.dart';
import 'utils/screen_utils.dart';

class Manager {
  static const int dynMouseScrollDuration = 150;
  static const double dynMouseScrollScrollSpeed = 2;
  static const String appTitle = "MiruRyoiki";

  /// Indicates if the current dialog can be popped, used when dialogs have multiple 'views'
  static bool canPopDialog = true;
  static Color? currentDominantColor;

  static List<String> accounts = [];

  static Uri? initialDeepLink;
  static bool skipRegistryIndexing = false;

  static void parseArgs(List<String> args) {
    if (args.isEmpty) return;

    for (var arg in args) {
      if (arg == '--skip-registry-indexing') {
        skipRegistryIndexing = true;
      }
    }
  }

  static void setState() => homeKey.currentState?.setState(() {});

  static BuildContext get context => rootNavigatorKey.currentContext!;

  static NavigationManager get navigation => Provider.of<NavigationManager>(context, listen: false);

  static SettingsManager get settings => Provider.of<SettingsManager>(context, listen: false);

  static AppTheme? _cachedAppTheme;
  static AppTheme get appTheme {
    if (rootNavigatorKey.currentContext != null) {
      try {
        return Provider.of<AppTheme>(rootNavigatorKey.currentContext!, listen: false);
      } catch (e) {
        // If we have a cached instance, return it
        if (_cachedAppTheme != null) return _cachedAppTheme!;

        // Otherwise create a new default instance
        _cachedAppTheme = AppTheme();
        return _cachedAppTheme!;
      }
    }

    // If context is null, use cached or create new
    return _cachedAppTheme ?? (_cachedAppTheme = AppTheme());
  }

  static AccentColor get accentColor => settings.accentColor.toAccentColor();

  static Color get genericGray => FluentTheme.of(context).acrylicBackgroundColor.lerpWith(const Color.fromARGB(255, 21, 35, 35), 0.5);

  static ImageSource get defaultPosterSource => settings.defaultPosterSource;

  static ImageSource get defaultBannerSource => settings.defaultBannerSource;

  static bool get animationsEnabled => !settings.disableAnimations;

  static DominantColorSource get dominantColorSource => settings.dominantColorSource;

  static double get fontSizeMultiplier => ScreenUtils.textScaleFactor * ((rootNavigatorKey.currentContext != null ? appTheme.fontSize : kDefaultFontSize) / kDefaultFontSize);

  /// Checks if the current platform is MacOS
  static bool get isMacOS => Platform.isMacOS;

  /// Checks if the current platform is Windows 11
  static bool get isWin11 => Platform.operatingSystemVersion.startsWith('11');

  static bool get isCtrlPressed => KeyboardState.ctrlPressedNotifier.value;
  static bool get isShiftPressed => KeyboardState.shiftPressedNotifier.value;

  static TextStyle get bodyStyle => FluentTheme.of(context).typography.body!;
  static TextStyle get bodyLargeStyle => FluentTheme.of(context).typography.bodyLarge!;
  static TextStyle get bodyStrongStyle => FluentTheme.of(context).typography.bodyStrong!;
  static TextStyle get captionStyle => FluentTheme.of(context).typography.caption!;
  static TextStyle get displayStyle => FluentTheme.of(context).typography.display!;
  static TextStyle get subtitleStyle => FluentTheme.of(context).typography.subtitle!;
  static TextStyle get titleStyle => FluentTheme.of(context).typography.title!;
  static TextStyle get titleLargeStyle => FluentTheme.of(context).typography.titleLarge!;
}
