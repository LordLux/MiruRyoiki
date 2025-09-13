import 'dart:io';
import 'dart:ui';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ColorScheme, Colors, ThemeMode;
import 'package:flutter/widgets.dart' hide Image;
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

import '../enums.dart';
import '../manager.dart';
import '../models/series.dart';
import '../services/file_system/cache.dart';
import '../services/isolates/isolate_manager.dart';
import '../theme.dart';
import 'logging.dart';
import 'path_utils.dart';
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
Color determineTextColor(
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

  logTrace('  Calculating dominant color for ${substringSafe(series.name, 0, 20, '"')}...');
  // Get source type
  final DominantColorSource sourceType = Manager.dominantColorSource;
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
    imagePath = await _getAnilistCachedImagePath(series);
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
Future<String?> _getAnilistCachedImagePath(Series series) async {
  final anilistData = series.anilistData;
  if (anilistData == null) return null;

  final imageCache = ImageCacheService();
  await imageCache.init();

  // Try poster first
  if (anilistData.posterImage != null) {
    final path = await imageCache.getCachedImagePath(anilistData.posterImage!);
    if (path != null) return path;
  }

  // Try banner next
  if (anilistData.bannerImage != null) {
    return await imageCache.getCachedImagePath(anilistData.bannerImage!);
  }

  return null;
}

/// Extract dominant color from an image file
Future<(Color?, bool)> _extractColorFromPath(Series series, String imagePath) async {
  // Calculate color using compute to avoid UI blocking
  try {
    // Check if we can use Flutter's painting system
    bool canUseFlutterPainting = false;
    try {
      if (WidgetsBinding.instance.isRootWidgetAttached) {
        canUseFlutterPainting = true;
      }
    } catch (e) {
      // We're likely in an isolate or Flutter binding isn't available
      canUseFlutterPainting = false;
    }

    final imageFile = File(imagePath);
    if (await imageFile.exists()) {
      Color? newColor;

      if (canUseFlutterPainting) {
        // Use the existing Flutter-based approach
        final Uint8List imageBytes = await imageFile.readAsBytes();
        final Image image = (await decodeImageFromList(imageBytes));
        final ByteData byteData = (await image.toByteData())!;

        // Force UI update by using a separate isolate
        newColor = await compute(_isolateExtractColor, (byteData, image.width, image.height));
      } else {
        // Use the pure Dart approach that works in isolates
        // For banners, prefer background colors; for posters, prefer vibrant colors
        final sourceType = Manager.dominantColorSource;
        final preferBackground = sourceType == DominantColorSource.banner;
        newColor = await ImageColorExtractor.extractDominantColor(imagePath, preferBackground: preferBackground);
      }

      logMulti([
        ['   Dominant color calculated: '],
        [newColor?.toHex() ?? 'None', newColor ?? Colors.yellow, newColor == null ? Colors.red : Colors.transparent],
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

/// Corrects dark dominant colors by making them lighter and more vibrant
Color _correctDarkDominantColor(Color color) {
  final HSLColor hsl = HSLColor.fromColor(color);

  // Define thresholds and correction parameters
  const double minLightness = 0.3; // Colors below this lightness will be corrected
  const double targetLightness = 0.45; // Target lightness for corrected colors
  const double saturationBoost = 0.15; // Amount to boost saturation

  // Only correct if the color is too dark
  if (hsl.lightness < minLightness) {
    // Calculate the correction amount based on how dark the color is
    final lightnessDeficit = minLightness - hsl.lightness;
    final correctionFactor = (lightnessDeficit / minLightness).clamp(0.0, 1.0);

    // Apply progressive lightness correction
    final newLightness = hsl.lightness + (targetLightness - hsl.lightness) * correctionFactor;

    // Apply saturation boost, but less for already saturated colors
    final saturationMultiplier = 1.0 - hsl.saturation; // Less boost for already saturated colors
    final newSaturation = (hsl.saturation + (saturationBoost * saturationMultiplier)).clamp(0.0, 1.0);

    final correctedHsl = hsl.withLightness(newLightness).withSaturation(newSaturation);
    final correctedColor = correctedHsl.toColor();

    log('   Color correction applied: ${color.toHex()} → ${correctedColor.toHex()} (lightness: ${hsl.lightness.toStringAsFixed(2)} → ${newLightness.toStringAsFixed(2)}, saturation: ${hsl.saturation.toStringAsFixed(2)} → ${newSaturation.toStringAsFixed(2)})');
    return correctedColor;
  }

  // Return original color if it's not too dark
  return color;
}

/// Entry point for extracting color in an isolate
Future<Color?> _isolateExtractColor((ByteData, int, int) data) async {
  try {
    final byteData = data.$1;
    final width = data.$2;
    final height = data.$3;
    final EncodedImage encoded_image = EncodedImage(byteData, height: height, width: width);

    final paletteGenerator = await PaletteGenerator.fromByteData(encoded_image);

    // Try vibrant color first, fall back to dominant
    Color? extractedColor = paletteGenerator.vibrantColor?.color ?? paletteGenerator.dominantColor?.color;

    // Apply dark color correction if we found a color
    if (extractedColor != null) extractedColor = _correctDarkDominantColor(extractedColor);

    return extractedColor;
  } catch (e) {
    logErr('Error extracting color from image', e);
    return null;
  }
}
