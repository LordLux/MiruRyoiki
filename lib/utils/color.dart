import 'dart:io';
import 'dart:ui';
import 'dart:isolate';

import 'package:flutter/material.dart' show ColorScheme, Colors, ThemeMode;
import 'package:flutter/widgets.dart' hide Image;
import 'package:provider/provider.dart';

import '../enums.dart';
import '../manager.dart';
import '../models/anilist/mapping.dart';
import '../models/series.dart';
import '../services/file_system/cache.dart';
import '../services/isolates/isolate_manager.dart';
import '../theme.dart';
import 'logging.dart';
import 'path.dart';
import 'image_color_extractor.dart';

/// Generate a color scheme from a dominant color
ColorScheme generateColorScheme(Color baseColor, {Brightness brightness = Brightness.dark}) {
  // For dark theme
  if (brightness == Brightness.dark) {
    // Adjust saturation for better visibility
    final HSLColor hsl = HSLColor.fromColor(baseColor);
    final adjustedColor = hsl
        .withSaturation((hsl.saturation * 0.8).clamp(0.0, 1.0)) // Reduce saturation slightly
        .withLightness((hsl.lightness * 0.7).clamp(0.0, 1.0)) // Make it darker
        .toColor();

    return ColorScheme.dark(
      primary: baseColor,
      secondary: adjustedColor,
      surface: Color.lerp(Colors.black, baseColor, 0.1) ?? Colors.black,
      background: Color.lerp(Colors.black, baseColor, 0.05) ?? Colors.black,
    );
  }

  // For light theme
  final HSLColor hsl = HSLColor.fromColor(baseColor);
  final adjustedColor = hsl.withSaturation((hsl.saturation * 0.9).clamp(0.0, 1.0)).withLightness((hsl.lightness * 1.2).clamp(0.0, 1.0)).toColor();

  return ColorScheme.light(
    primary: baseColor,
    secondary: adjustedColor,
    surface: Color.lerp(Colors.white, baseColor, 0.1) ?? Colors.white,
    background: Color.lerp(Colors.white, baseColor, 0.05) ?? Colors.white,
  );
}

Color darken(Color color, [double amount = 0.1]) {
  assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
  return _changeLighting(color, -amount);
}

Color _changeLighting(Color color, double amount) {
  if (amount < 0) return Color.lerp(color, Colors.black, -amount)!;
  return Color.lerp(color, Colors.white, amount)!;
}

Color lighten(Color color, [double amount = 0.1]) {
  assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
  return _changeLighting(color, amount);
}

Color shiftHue(Color color, double shift) {
  final hsvColor = HSVColor.fromColor(color);
  final newHue = (hsvColor.hue + shift) % 360;
  return hsvColor.withHue(newHue).toColor();
}

Color getDimmable(Color color, BuildContext context, [List<double> opacity = const [0.25, 0.15, 0]]) {
  final appTheme = Provider.of<AppTheme>(context, listen: false);
  if (appTheme.mode == ThemeMode.light) return Colors.transparent;
  return color.withOpacity(appTheme.dim == Dim.dimmed
      ? opacity[0]
      : appTheme.dim == Dim.normal
          ? opacity[1]
          : opacity[2]);
}

Color getDimmableBG(BuildContext context) {
  final appTheme = Provider.of<AppTheme>(context, listen: false);
  if (appTheme.mode == ThemeMode.light) return getDimmableWhite(context);
  return getDimmableBlack(context);
}

Color getDimmableBlack(BuildContext context) {
  return getDimmable(Colors.black, context, [0.35, 0.25, 0.1]);
}

Color getDimmableWhite(BuildContext context) {
  return getDimmable(Colors.white, context, [0.01, 0.015, 0.03]);
}

/// Returns white or black based on the brightness of the color
Color getPrimaryColorBasedOnAccent() {
  final Color accentColor = Manager.accentColor.lighter;
  final HSLColor hsl = HSLColor.fromColor(accentColor);
  final double brightness = hsl.lightness;
  return brightness > 0.5 ? Colors.black : Colors.white;
}

/// Finds the best color for the text based on the background color
/// works on contrast, not brightness
Color getTextColor(
  Color backgroundColor, {
  double preferBlack = 0.5,
  double preferWhite = 0.5,
  Color lightColor = Colors.white,
  Color darkColor = Colors.black,
}) {
  // Ensure preferBlack and preferWhite are between 0 and 1
  preferBlack = preferBlack.clamp(0.0, 1.0);
  preferWhite = preferWhite.clamp(0.0, 1.0);

  // Calculate luminance of the background color
  double luminance = backgroundColor.computeLuminance();

  // Adjust luminance based on preferBlack and preferWhite
  double adjustedLuminance = luminance;

  // Preference for black - increase threshold to prefer black more
  if (preferBlack > preferWhite) {
    adjustedLuminance *= 1.0 + (preferBlack - 0.5); // Enhance black preference
  }
  // Preference for white - increase threshold to prefer white more
  else if (preferWhite > preferBlack) {
    adjustedLuminance *= 1.0 - (preferWhite - 0.5); // Enhance white preference
  }

  // Determine the text color based on luminance
  if (adjustedLuminance < 0.5) return lightColor;
  return darkColor;
}

/// Calculate and cache the dominant color from the image
/// Returns the colors and whether we need to overwrite the cached color
Future<((Color?, Color?)?, bool)> calculateLocalDominantColors(Series series, {bool forceRecalculate = false}) async {
  // If color already calculated and not forced, return cached color
  if (series.localPosterColor != null && series.localBannerColor != null && !forceRecalculate) {
    logTrace('   No need to extract color, using cached dominant colors: Pos${series.localPosterColor?.toHex()}, Ban${series.localBannerColor?.toHex()}!');
    return ((series.localPosterColor, series.localBannerColor), false);
  }

  // Skip if binding not initialized or no poster path
  try {
    //  final binding = WidgetsBinding.instance;
    //  if (!binding.isRootWidgetAttached) {
    if (!WidgetsBinding.instance.isRootWidgetAttached) {
      logDebug('   WidgetsBinding not initialized, initializing...');
      WidgetsFlutterBinding.ensureInitialized();
    }
  } catch (e) {
    // If we're in an isolate or WidgetsBinding is not available, skip this check
    logWarn('   WidgetsBinding not available (possibly in isolate), continuing...');
  }


  
  String? localPosterPath = PathString(series.posterImage).pathMaybe;
  String? localBannerPath = PathString(series.bannerImage).pathMaybe;

  // If no image path found, return null
  if (localPosterPath == null && localBannerPath == null) {
    logWarn('   No image available for dominant color extraction');
    return (null, false);
  }

  final imageCache = ImageCacheService();
  await imageCache.init();

  final cachedLocalPosterPath = await imageCache.getCachedImagePath(localPosterPath);
  final cachedLocalBannerPath = await imageCache.getCachedImagePath(localBannerPath);
  
  if (cachedLocalPosterPath == null && cachedLocalBannerPath == null) {
    logWarn('   Failed to get local cached image(s)');
    return (null, false);
  }

  final localPosterColor = await _extractColor(cachedLocalPosterPath);
  final localBannerColor = await _extractColor(cachedLocalBannerPath);
  
  return ((localPosterColor, localBannerColor), true);
}

/// Calculate dominant color for an Anilist mapping from its poster or banner image
/// Returns the colors and whether we need to overwrite the cached color
/// Pass [calculatePoster] and/or [calculateBanner] to specify which colors to calculate
Future<((Color?, Color?), bool)> calculateLinkColors(
  AnilistMapping mapping, {
  bool calculatePoster = false,
  bool calculateBanner = false,
  bool forceRecalculate = false,
}) async {
  // If neither is requested, return null
  if (!calculatePoster && !calculateBanner) {
    logWarn('   No color source specified for extraction');
    return ((null, null), false);
  }

  // Check if we already have cached colors and don't need to recalculate
  final hasPosterColor = mapping.posterColor != null;
  final hasBannerColor = mapping.bannerColor != null;
  
  final needsPosterCalculation = calculatePoster && (forceRecalculate || !hasPosterColor);
  final needsBannerCalculation = calculateBanner && (forceRecalculate || !hasBannerColor);

  if (!needsPosterCalculation && !needsBannerCalculation) {
    logTrace('   No need to extract color, using cached link colors: Pos${mapping.posterColor?.toHex()}, Ban${mapping.bannerColor?.toHex()}!');
    return ((mapping.posterColor, mapping.bannerColor), false);
  }

  // Calculate colors as needed
  Color? posterColor = hasPosterColor ? mapping.posterColor : null;
  Color? bannerColor = hasBannerColor ? mapping.bannerColor : null;
  bool updated = false;

  if (needsPosterCalculation) {
    posterColor = await _calculateLinkColor(mapping, source: DominantColorSource.poster, forceRecalculate: forceRecalculate);
    updated = true;
  }

  if (needsBannerCalculation) {
    bannerColor = await _calculateLinkColor(mapping, source: DominantColorSource.banner, forceRecalculate: forceRecalculate);
    updated = true;
  }

  return ((posterColor, bannerColor), updated);
}

/// Calculate a single dominant color for an Anilist mapping
Future<Color?> _calculateLinkColor(
  AnilistMapping mapping, {
  required DominantColorSource source,
  bool forceRecalculate = false,
}) async {
  // Skip if binding not initialized
  try {
    //  final binding = WidgetsBinding.instance;
    //  if (!binding.isRootWidgetAttached) {
    if (!WidgetsBinding.instance.isRootWidgetAttached) {
      logDebug('   WidgetsBinding not initialized, initializing...');
      WidgetsFlutterBinding.ensureInitialized();
    }
  } catch (e) {
    // If we're in an isolate or WidgetsBinding is not available, skip this check
    logTrace('   WidgetsBinding not available (possibly in isolate), continuing...');
  }

  // Get the appropriate image path based on source
  String? imagePath;
  if (source == DominantColorSource.poster) {
    imagePath = mapping.anilistData?.posterImage;
  } else {
    imagePath = mapping.anilistData?.bannerImage;
  }

  // If no image path found, return null
  if (imagePath == null) {
    logWarn('   No ${source == DominantColorSource.poster ? "poster" : "banner"} image available for dominant color extraction');
    return null;
  }

  final imageCache = ImageCacheService();
  await imageCache.init();

  imagePath = await imageCache.getCachedImagePath(imagePath);
  if (imagePath == null) {
    logWarn('   Failed to get cached Anilist image');
    return null;
  }

  return await _extractColor(imagePath);
}

/// Calculate dominant colors for multiple series using isolate manager with progress
/// Returns a map of anilist ID to dominant color and whether it was updated
Future<Map<int, Map<String, dynamic>>> calculateMappingDominantColorsWithProgress({
  required List<AnilistMapping> mappings,
  required bool forceRecalculate,
  void Function()? onStart,
  void Function(int processed, int total)? onProgress,
}) async {
  final isolateManager = IsolateManager();

  // Serialize series for the isolate
  final serializedMappings = mappings.map((s) => s.toJson()).toList();

  return await isolateManager.runIsolateWithProgress<CalculateDominantColorsParams, Map<int, Map<String, dynamic>>>(
    task: calculateDominantColorsIsolate,
    params: CalculateDominantColorsParams(
      serializedMappings: serializedMappings,
      forceRecalculate: forceRecalculate,
      replyPort: ReceivePort().sendPort, // This will be replaced by the isolate manager
    ),
    onStart: onStart,
    onProgress: onProgress,
  );
}

/// Extract dominant color from an image file
Future<Color?> _extractColor(String? imagePath) async {
  if (imagePath == null) return null;
  
  // Use the unified color extraction system
  try {
    final imageFile = File(imagePath);
    if (await imageFile.exists()) {
      // Use the pure Dart approach that works everywhere (main thread and isolates)
      // For banners, prefer background colors; for posters, prefer vibrant colors
      final sourceType = Manager.dominantColorSource;
      final preferBackground = sourceType == DominantColorSource.banner;

      final newColor = await ImageColorExtractor.extractDominantColor(
        imagePath,
        preferBackground: preferBackground,
      );

      logMulti([
        ['   Dominant color calculated: '],
        [newColor?.toHex(), getTextColor(newColor ?? Colors.white), newColor ?? Colors.black],
      ]);

      return newColor;
    }
  } catch (e) {
    logErr('Error extracting dominant color', e);
  }
  return null;
}
