import 'package:flutter/material.dart';

/// Generate a color scheme from a dominant color
ColorScheme generateColorScheme(Color baseColor, {Brightness brightness = Brightness.dark}) {
  // For dark theme
  if (brightness == Brightness.dark) {
    // Adjust saturation for better visibility
    final HSLColor hsl = HSLColor.fromColor(baseColor);
    final adjustedColor = hsl
        .withSaturation((hsl.saturation * 0.8).clamp(0.0, 1.0)) // Reduce saturation slightly
        .withLightness((hsl.lightness * 0.7).clamp(0.0, 1.0))   // Make it darker
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
    final adjustedColor = hsl
        .withSaturation((hsl.saturation * 0.9).clamp(0.0, 1.0))
        .withLightness((hsl.lightness * 1.2).clamp(0.0, 1.0))
        .toColor();
        
    return ColorScheme.light(
      primary: baseColor,
      secondary: adjustedColor,
      surface: Color.lerp(Colors.white, baseColor, 0.1) ?? Colors.white,
      background: Color.lerp(Colors.white, baseColor, 0.05) ?? Colors.white,
    );
  }
}