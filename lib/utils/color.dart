import 'dart:io';
import 'dart:ui';
import 'dart:isolate';

import 'package:flutter/material.dart' show ColorScheme, Colors, ThemeMode;
import 'package:flutter/widgets.dart' hide Image;
import 'package:provider/provider.dart';

import '../enums.dart';
import '../manager.dart';
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
  return getDimmable(Colors.black, context, [0.25, 0.15, 0]);
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
/// Returns the color and whether we need to overwrite the cached color
Future<(Color?, bool)> calculateDominantColor(Series series, {bool forceRecalculate = false}) async {
  // If color already calculated and not forced, return cached color
  if (series.dominantColor != null && !forceRecalculate) {
    logTrace('   No need to extract color, using cached dominant color: ${series.dominantColor?.toHex()}!');
    return (series.dominantColor, false);
  }

  // Skip if binding not initialized or no poster path
  try {
    if (!WidgetsBinding.instance.isRootWidgetAttached) {
      logDebug('   WidgetsBinding not initialized, initializing...');
      WidgetsFlutterBinding.ensureInitialized();
    }
  } catch (e) {
    // If we're in an isolate or WidgetsBinding is not available, skip this check
    logTrace('   WidgetsBinding not available (possibly in isolate), continuing...');
  }

  // Get source type
  final DominantColorSource sourceType = Manager.dominantColorSource;
  logTrace('  Calculating dominant color for ${substringSafe(series.name, 0, 20, '"')} with source ${sourceType == DominantColorSource.poster ? "poster" : "banner"}...');
  String? imagePath;

  // Use the existing logic from effectivePosterPath/effectiveBannerPath
  if (sourceType == DominantColorSource.poster) {
    // For poster source, use the effectivePosterPath
    imagePath = series.effectivePosterPath;
    if (imagePath != null) {
      logTrace(series.isAnilistPoster ? '   Using Anilist poster for dominant color calculation' : '   Using local poster for dominant color calculation: "$imagePath"');
    }
  } else {
    // For banner source, use the effectiveBannerPath
    imagePath = series.effectiveBannerPath;
    if (imagePath != null) {
      logTrace(series.isAnilistBanner ? '   Using Anilist banner for dominant color calculation' : '   Using local banner for dominant color calculation: "$imagePath"');
    }
  }

  // If no image path found, return null
  if (imagePath == null) {
    logTrace('   No image available for dominant color extraction');
    return (null, false);
  }

  // For Anilist images, we need to get the cached path
  if ((sourceType == DominantColorSource.poster && series.isAnilistPoster) || (sourceType == DominantColorSource.banner && series.isAnilistBanner)) {
    imagePath = await _getAnilistCachedImagePath(series, poster: sourceType == DominantColorSource.poster);
    if (imagePath == null) {
      logTrace('   Failed to get cached Anilist image');
      return (null, false);
    }
  }

  return await _extractColorFromPath(series, imagePath);
}

/// Calculate dominant colors for multiple series using isolate manager with progress
/// Returns a map of series ID to dominant color and whether it was updated
Future<Map<String, Map<String, dynamic>>> calculateDominantColorsWithProgress({
  required List<Series> series,
  required bool forceRecalculate,
  required int dominantColorSourceIndex,
  void Function()? onStart,
  void Function(int processed, int total)? onProgress,
}) async {
  final isolateManager = IsolateManager();

  // Serialize series for the isolate
  final serializedSeries = series.map((s) => s.toJson()).toList();

  return await isolateManager.runIsolateWithProgress<CalculateDominantColorsParams, Map<String, Map<String, dynamic>>>(
    task: calculateDominantColorsIsolate,
    params: CalculateDominantColorsParams(
      serializedSeries: serializedSeries,
      forceRecalculate: forceRecalculate,
      dominantColorSourceIndex: dominantColorSourceIndex,
      replyPort: ReceivePort().sendPort, // This will be replaced by the isolate manager
    ),
    onStart: onStart,
    onProgress: onProgress,
  );
}

/// Helper method to get cached Anilist images
Future<String?> _getAnilistCachedImagePath(Series series, {bool poster = true}) async {
  final anilistData = series.anilistData;
  if (anilistData == null) return null;

  final imageCache = ImageCacheService();
  await imageCache.init();

  if (poster) {
    // Try poster first
    if (anilistData.posterImage != null) {
      final path = await imageCache.getCachedImagePath(anilistData.posterImage!);
      if (path != null) return path;
    }

    // Try banner next
    if (anilistData.bannerImage != null) return await imageCache.getCachedImagePath(anilistData.bannerImage!);
  } else {
    // Try banner first
    if (anilistData.bannerImage != null) {
      final path = await imageCache.getCachedImagePath(anilistData.bannerImage!);
      if (path != null) return path;
    }

    // Try poster next
    if (anilistData.posterImage != null) return await imageCache.getCachedImagePath(anilistData.posterImage!);
  }

  // No cached image found
  return null;
}

/// Extract dominant color from an image file
Future<(Color?, bool)> _extractColorFromPath(Series series, String imagePath) async {
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

      // Only update if the color actually changed
      if (newColor != null && (series.dominantColor?.value != newColor.value)) {
        return (newColor, true);
      }
      return (series.dominantColor, false);
    }
  } catch (e) {
    logErr('Error extracting dominant color', e);
  }
  return (null, false);
}
