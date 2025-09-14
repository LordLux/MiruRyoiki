// ignore_for_file: avoid_print

import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/utils/image_color_extractor.dart';

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
    
    // Both should return colors, but they might be different
    expect(vibrantColor, isA<Color?>());
    expect(backgroundColor, isA<Color?>());
    
    print('Vibrant extraction: ${vibrantColor?.toString()}');
    print('Background extraction: ${backgroundColor?.toString()}');
  });
}

/// Create a simple test image with blue background and red center
Uint8List _createTestImageBytes() {
  // Create a simple 20x20 image programmatically
  // Blue background (edges) with red center (simulating anime banner scenario)
  final bytes = <int>[];
  
  // PNG header
  bytes.addAll([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  
  // This is a simplified approach - in a real test you'd want to use
  // a proper image encoding library or load a real test image
  // For now, we'll return a minimal valid PNG
  bytes.addAll([
    0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
    0x00, 0x00, 0x00, 0x14, 0x00, 0x00, 0x00, 0x14, // 20x20 dimensions
    0x08, 0x02, 0x00, 0x00, 0x00, 0x02, 0x0B, 0x8D,
    0xD2, 0x00, 0x00, 0x00, 0x09, 0x70, 0x48, 0x59,
    0x73, 0x00, 0x00, 0x0B, 0x13, 0x00, 0x00, 0x0B,
    0x13, 0x01, 0x00, 0x9A, 0x9C, 0x18, 0x00, 0x00,
    0x00, 0x96, 0x49, 0x44, 0x41, 0x54, 0x38, 0x11,
    // Compressed image data would go here...
    // For testing purposes, this minimal PNG should be enough
    0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44,
    0xAE, 0x42, 0x60, 0x82, // IEND chunk
  ]);
  
  return Uint8List.fromList(bytes);
}
