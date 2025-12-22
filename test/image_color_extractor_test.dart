import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/utils/image_color_extractor.dart';
import 'package:image/image.dart' as img;

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
    // Create a 10x10 red image
    final image = img.Image(width: 10, height: 10);
    img.fill(image, color: img.ColorRgb8(255, 0, 0));
    final redPixelBytes = img.encodePng(image);
    
    final result = ImageColorExtractor.extractDominantColorFromBytes(
      Uint8List.fromList(redPixelBytes)
    );
    
    expect(result, isNotNull);
    // Check if it's red-ish
    expect(result!.red, greaterThan(200));
    expect(result.blue, lessThan(50));
    expect(result.green, lessThan(50));
  });
}
