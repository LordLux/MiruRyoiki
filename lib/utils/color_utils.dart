import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums.dart';
import '../manager.dart';
import '../theme.dart';

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
  else {
    final HSLColor hsl = HSLColor.fromColor(baseColor);
    final adjustedColor = hsl.withSaturation((hsl.saturation * 0.9).clamp(0.0, 1.0)).withLightness((hsl.lightness * 1.2).clamp(0.0, 1.0)).toColor();

    return ColorScheme.light(
      primary: baseColor,
      secondary: adjustedColor,
      surface: Color.lerp(Colors.white, baseColor, 0.1) ?? Colors.white,
      background: Color.lerp(Colors.white, baseColor, 0.05) ?? Colors.white,
    );
  }
}

Color darken(Color color, [double amount = 0.1]) {
  assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
  return _changeLighting(color, amount);
}

Color _changeLighting(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
  return hslLight.toColor();
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
  if (adjustedLuminance < 0.5) {
    return Colors.white;
  } else {
    return Colors.black;
  }
}
