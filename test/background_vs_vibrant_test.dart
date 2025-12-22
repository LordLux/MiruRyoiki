// ignore_for_file: avoid_print

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/utils/image_color_extractor.dart';
import 'package:image/image.dart' as img;

void main() {
  test('Background vs Vibrant color extraction produces different results', () {
    // Create a simple test image: blue background with red center
    // This simulates a banner with blue background and colorful characters
    final testImageBytes = _createTestImageBytes();
    
    // Extract using vibrant mode (for posters)
    final vibrantColor = ImageColorExtractor.extractDominantColorFromBytes(
      testImageBytes, 
      preferBackground: false
    );
    
    // Extract using background mode (for banners)
    final backgroundColor = ImageColorExtractor.extractDominantColorFromBytes(
      testImageBytes, 
      preferBackground: true
    );
    
    // Both should return colors
    expect(vibrantColor, isNotNull, reason: 'Vibrant extraction should return a color');
    expect(backgroundColor, isNotNull, reason: 'Background extraction should return a color');
    
    print('Vibrant extraction: ${vibrantColor?.toString()}');
    print('Background extraction: ${backgroundColor?.toString()}');

    // In this specific test case (Blue background, Red center),
    // Background mode should pick Blue
    // Vibrant mode should pick Red
    expect(vibrantColor != backgroundColor, isTrue, reason: 'Vibrant and Background extraction should differ for this image');
  });
}

/// Create a simple test image with blue background and red center
Uint8List _createTestImageBytes() {
  // Create a 100x100 image
  final image = img.Image(width: 100, height: 100);
  
  // Fill with Dark Blue (Background) - Less vibrant
  // package:image v4 uses ColorRgb8
  img.fill(image, color: img.ColorRgb8(0, 0, 100));
  
  // Draw Red circle in center (Vibrant subject)
  img.fillCircle(image, x: 50, y: 50, radius: 30, color: img.ColorRgb8(255, 0, 0));
  
  return Uint8List.fromList(img.encodePng(image));
}
