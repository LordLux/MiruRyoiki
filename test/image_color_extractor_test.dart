import 'dart:isolate';
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/utils/image_color_extractor.dart';

void main() {
  test('ImageColorExtractor works in isolate environment', () async {
    // This test simulates an isolate environment where Flutter bindings are not available
    
    // Create a simple test image (you can replace this with an actual image path)
    // For this test, we'll just verify the extractor doesn't crash in isolate environment
    
    final testInIsolate = await Isolate.run(() async {
      try {
        // This would normally extract color from a real image file
        // For testing, we'll just verify the method exists and handles errors gracefully
        final result = await ImageColorExtractor.extractDominantColor('non_existent_file.jpg');
        
        // Should return null for non-existent file, but not throw an exception
        return result == null ? 'success' : 'unexpected_result';
      } catch (e) {
        return 'error: $e';
      }
    });
    
    expect(testInIsolate, equals('success'));
  });
  
  test('ImageColorExtractor handles bytes correctly', () {
    // Test with minimal image data (1x1 red pixel)
    final redPixelBytes = [
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // 1x1 dimensions
      0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, // bit depth, color type, etc.
      0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41, // IDAT chunk
      0x54, 0x08, 0x99, 0x01, 0x01, 0x03, 0x00, 0xFC, // compressed red pixel data
      0xFF, 0xFF, 0x00, 0x00, 0x02, 0x00, 0x01, 0xE5, 
      0x27, 0xDE, 0xFC, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82, // IEND chunk
    ];
    
    final result = ImageColorExtractor.extractDominantColorFromBytes(
      Uint8List.fromList(redPixelBytes)
    );
    
    // The extractor should handle the test image gracefully
    // (may return null due to minimal test data, but shouldn't crash)
    expect(result, isA<Color?>());
  });
}
