import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Color;
import 'dart:math' as math;
import 'package:image/image.dart' as img;

/// Pure Dart implementation for extracting dominant colors from images
/// This works in isolates without requiring Flutter bindings
class ImageColorExtractor {
  /// Extract the dominant color from an image file
  static Future<Color?> extractDominantColor(String imagePath, {bool preferBackground = false}) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      return extractDominantColorFromBytes(bytes, preferBackground: preferBackground);
    } catch (e) {
      return null;
    }
  }

  /// Extract the dominant color from image bytes
  static Color? extractDominantColorFromBytes(Uint8List bytes, {bool preferBackground = false}) {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      // Resize image for faster processing (max 100x100)
      final resized = _resizeForProcessing(image);
      
      Color? finalColor;
      
      if (preferBackground) {
        // For banners: prioritize background/area colors over vibrant details
        final backgroundColor = _extractBackgroundColor(resized);
        final areaColor = _extractLargestAreaColor(resized);
        
        // Choose the best background color
        finalColor = backgroundColor ?? areaColor ?? _extractUsingColorClustering(resized);
      } else {
        // For posters: prioritize vibrant colors over background
        final dominantColor = _extractUsingColorClustering(resized);
        final vibrantColor = _extractMostVibrantColor(resized);
        
        // Choose the better color (prefer vibrant if available)
        finalColor = vibrantColor ?? dominantColor;
      }
      
      return finalColor != null ? _correctDarkColor(finalColor) : null;
    } catch (e) {
      return null;
    }
  }

  /// Resize image for faster processing while maintaining aspect ratio
  static img.Image _resizeForProcessing(img.Image image) {
    const maxSize = 100;
    
    if (image.width <= maxSize && image.height <= maxSize) {
      return image;
    }
    
    final aspectRatio = image.width / image.height;
    late int newWidth, newHeight;
    
    if (aspectRatio > 1) {
      newWidth = maxSize;
      newHeight = (maxSize / aspectRatio).round();
    } else {
      newHeight = maxSize;
      newWidth = (maxSize * aspectRatio).round();
    }
    
    return img.copyResize(image, width: newWidth, height: newHeight);
  }

  /// Extract dominant color using k-means clustering approach
  static Color? _extractUsingColorClustering(img.Image image) {
    final colorCounts = <int, int>{};
    
    // Sample pixels (skip some for performance)
    final step = math.max(1, (image.width * image.height) ~/ 1000);
    
    for (int y = 0; y < image.height; y += math.max(1, step ~/ image.width)) {
      for (int x = 0; x < image.width; x += math.max(1, step % image.width + 1)) {
        final pixel = image.getPixel(x, y);
        final color = _quantizeColor(pixel);
        colorCounts[color] = (colorCounts[color] ?? 0) + 1;
      }
    }
    
    if (colorCounts.isEmpty) return null;
    
    // Find the most frequent color, excluding very dark/light colors
    final sortedColors = colorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (final entry in sortedColors) {
      final color = Color(entry.key);
      if (_isValidDominantColor(color)) {
        return color;
      }
    }
    
    // Fallback to most frequent color
    return sortedColors.isNotEmpty ? Color(sortedColors.first.key) : null;
  }

  /// Extract the most vibrant/saturated color
  static Color? _extractMostVibrantColor(img.Image image) {
    Color? bestColor;
    double bestScore = 0;
    
    final step = math.max(1, (image.width * image.height) ~/ 500);
    
    for (int y = 0; y < image.height; y += math.max(1, step ~/ image.width)) {
      for (int x = 0; x < image.width; x += math.max(1, step % image.width + 1)) {
        final pixel = image.getPixel(x, y);
        final color = Color.fromARGB(255, pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
        
        final score = _calculateVibrancyScore(color);
        if (score > bestScore && _isValidDominantColor(color)) {
          bestScore = score;
          bestColor = color;
        }
      }
    }
    
    return bestColor;
  }

  /// Extract background color by sampling edges and corners
  static Color? _extractBackgroundColor(img.Image image) {
    final edgeColors = <int, int>{};
    
    // Sample edges of the image where background is most likely
    final samples = <(int, int)>[];
    
    // Top and bottom edges
    for (int x = 0; x < image.width; x += math.max(1, image.width ~/ 20)) {
      samples.add((x, 0)); // Top edge
      samples.add((x, image.height - 1)); // Bottom edge
    }
    
    // Left and right edges
    for (int y = 0; y < image.height; y += math.max(1, image.height ~/ 20)) {
      samples.add((0, y)); // Left edge
      samples.add((image.width - 1, y)); // Right edge
    }
    
    // Sample corners more heavily
    final cornerSamples = [
      (0, 0), (image.width - 1, 0), // Top corners
      (0, image.height - 1), (image.width - 1, image.height - 1), // Bottom corners
    ];
    
    // Add corner samples multiple times to weight them more heavily
    for (int i = 0; i < 3; i++) {
      samples.addAll(cornerSamples);
    }
    
    // Count edge colors
    for (final (x, y) in samples) {
      final pixel = image.getPixel(x, y);
      final color = _quantizeColor(pixel);
      edgeColors[color] = (edgeColors[color] ?? 0) + 1;
    }
    
    if (edgeColors.isEmpty) return null;
    
    // Find the most frequent edge color that's valid
    final sortedEdgeColors = edgeColors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (final entry in sortedEdgeColors) {
      final color = Color(entry.key);
      if (_isValidBackgroundColor(color)) {
        return color;
      }
    }
    
    return null;
  }

  /// Extract color that covers the largest area using flood-fill approach
  static Color? _extractLargestAreaColor(img.Image image) {
    final colorAreas = <int, int>{};
    final visited = List.generate(image.height, (_) => List.filled(image.width, false));
    
    // Sample grid points to find large color areas
    final step = math.max(2, (image.width * image.height) ~/ 400);
    
    for (int y = 0; y < image.height; y += math.max(1, step ~/ image.width)) {
      for (int x = 0; x < image.width; x += math.max(1, step % image.width + 1)) {
        if (visited[y][x]) continue;
        
        final pixel = image.getPixel(x, y);
        final baseColor = Color.fromARGB(255, pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
        
        // Skip if this color is too similar to already processed colors
        bool skipColor = false;
        for (final existingColor in colorAreas.keys) {
          if (_colorsAreSimilar(baseColor, Color(existingColor))) {
            skipColor = true;
            break;
          }
        }
        if (skipColor) continue;
        
        // Use simplified flood fill to estimate area
        final area = _estimateColorArea(image, x, y, baseColor, visited);
        if (area > 0) {
          final quantizedColor = _quantizeColor(pixel);
          colorAreas[quantizedColor] = (colorAreas[quantizedColor] ?? 0) + area;
        }
      }
    }
    
    if (colorAreas.isEmpty) return null;
    
    // Find the color with the largest area that's valid for background
    final sortedAreas = colorAreas.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (final entry in sortedAreas) {
      final color = Color(entry.key);
      if (_isValidBackgroundColor(color)) {
        return color;
      }
    }
    
    return null;
  }

  /// Estimate the area of a color using a simplified flood-fill
  static int _estimateColorArea(img.Image image, int startX, int startY, Color targetColor, List<List<bool>> visited) {
    final queue = <(int, int)>[(startX, startY)];
    int area = 0;
    const maxArea = 200; // Limit to prevent excessive computation
    
    while (queue.isNotEmpty && area < maxArea) {
      final (x, y) = queue.removeAt(0);
      
      if (x < 0 || x >= image.width || y < 0 || y >= image.height || visited[y][x]) continue;
      
      final pixel = image.getPixel(x, y);
      final currentColor = Color.fromARGB(255, pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
      
      if (!_colorsAreSimilar(currentColor, targetColor)) continue;
      
      visited[y][x] = true;
      area++;
      
      // Add neighbors (simplified - only check cardinal directions)
      queue.addAll([(x + 2, y), (x - 2, y), (x, y + 2), (x, y - 2)]);
    }
    
    return area;
  }

  /// Check if two colors are similar enough to be considered the same area
  static bool _colorsAreSimilar(Color a, Color b) {
    const threshold = 30; // Adjust for color similarity sensitivity
    
    final rDiff = (a.red - b.red).abs();
    final gDiff = (a.green - b.green).abs();
    final bDiff = (a.blue - b.blue).abs();
    
    return rDiff < threshold && gDiff < threshold && bDiff < threshold;
  }

  /// Check if a color is valid for use as a background color
  static bool _isValidBackgroundColor(Color color) {
    final hsl = _colorToHsl(color);
    
    // Background colors can be less saturated and more varied in lightness
    // but still exclude pure black/white and very desaturated grays
    return hsl.lightness > 0.05 && 
           hsl.lightness < 0.95 && 
           hsl.saturation > 0.05; // Allow less saturated colors for backgrounds
  }

  /// Calculate vibrancy score for a color (higher = more vibrant)
  static double _calculateVibrancyScore(Color color) {
    final hsl = _colorToHsl(color);
    
    // Prefer colors with:
    // - High saturation
    // - Medium lightness (not too dark, not too light)
    // - Avoid grays
    
    final saturationScore = hsl.saturation;
    final lightnessScore = 1.0 - (hsl.lightness - 0.5).abs() * 2;
    final grayPenalty = hsl.saturation < 0.2 ? 0.1 : 1.0;
    
    return saturationScore * lightnessScore * grayPenalty;
  }

  /// Check if a color is valid for use as a dominant color
  static bool _isValidDominantColor(Color color) {
    final hsl = _colorToHsl(color);
    
    // Exclude very dark, very light, or very desaturated colors
    return hsl.lightness > 0.1 && 
           hsl.lightness < 0.9 && 
           hsl.saturation > 0.1;
  }

  /// Quantize color to reduce similar colors
  static int _quantizeColor(img.Pixel pixel) {
    const factor = 8; // Reduce color depth
    
    final r = (pixel.r.toInt() ~/ factor) * factor;
    final g = (pixel.g.toInt() ~/ factor) * factor;
    final b = (pixel.b.toInt() ~/ factor) * factor;
    
    return Color.fromARGB(255, r, g, b).value;
  }

  /// Convert Color to HSL
  static IsolateHSLColor _colorToHsl(Color color) {
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;
    
    final max = math.max(r, math.max(g, b));
    final min = math.min(r, math.min(g, b));
    final diff = max - min;
    
    // Lightness
    final lightness = (max + min) / 2.0;
    
    // Saturation
    double saturation = 0.0;
    if (diff != 0.0) {
      saturation = lightness > 0.5 
        ? diff / (2.0 - max - min)
        : diff / (max + min);
    }
    
    // Hue
    double hue = 0.0;
    if (diff != 0.0) {
      if (max == r) {
        hue = ((g - b) / diff) % 6.0;
      } else if (max == g) {
        hue = (b - r) / diff + 2.0;
      } else {
        hue = (r - g) / diff + 4.0;
      }
      hue /= 6.0;
    }
    
    return IsolateHSLColor.fromAHSL(1.0, hue * 360.0, saturation, lightness);
  }

  /// Correct dark colors by making them lighter and more vibrant
  static Color _correctDarkColor(Color color) {
    final hsl = _colorToHsl(color);
    
    const double minLightness = 0.3;
    const double targetLightness = 0.45;
    const double saturationBoost = 0.15;
    
    if (hsl.lightness < minLightness) {
      final lightnessDeficit = minLightness - hsl.lightness;
      final correctionFactor = (lightnessDeficit / minLightness).clamp(0.0, 1.0);
      
      final newLightness = hsl.lightness + (targetLightness - hsl.lightness) * correctionFactor;
      final saturationMultiplier = 1.0 - hsl.saturation;
      final newSaturation = (hsl.saturation + (saturationBoost * saturationMultiplier)).clamp(0.0, 1.0);
      
      return hsl.withLightness(newLightness).withSaturation(newSaturation).toColor();
    }
    
    return color;
  }
}

/// Custom HSL Color representation for calculations in isolates
class IsolateHSLColor {
  final double alpha;
  final double hue;
  final double saturation;
  final double lightness;
  
  const IsolateHSLColor.fromAHSL(this.alpha, this.hue, this.saturation, this.lightness);
  
  IsolateHSLColor withLightness(double lightness) {
    return IsolateHSLColor.fromAHSL(alpha, hue, saturation, lightness);
  }
  
  IsolateHSLColor withSaturation(double saturation) {
    return IsolateHSLColor.fromAHSL(alpha, hue, saturation, lightness);
  }
  
  Color toColor() {
    final h = hue / 360.0;
    final s = saturation;
    final l = lightness;
    
    double hue2rgb(double p, double q, double t) {
      if (t < 0) t += 1;
      if (t > 1) t -= 1;
      if (t < 1/6) return p + (q - p) * 6 * t;
      if (t < 1/2) return q;
      if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
      return p;
    }
    
    if (s == 0) {
      // Achromatic
      final gray = (l * 255).round();
      return Color.fromARGB(255, gray, gray, gray);
    } else {
      final q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      final p = 2 * l - q;
      final r = hue2rgb(p, q, h + 1/3);
      final g = hue2rgb(p, q, h);
      final b = hue2rgb(p, q, h - 1/3);
      
      return Color.fromARGB(
        255,
        (r * 255).round(),
        (g * 255).round(),
        (b * 255).round(),
      );
    }
  }
}
