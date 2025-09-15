import 'package:flutter_test/flutter_test.dart';

/// Standalone unit tests for VLC player volume conversion logic
/// These tests run independently of the main application
void main() {
  group('VLC Volume Conversion Tests (Standalone)', () {
    test('should convert percentage to VLC volume correctly', () {
      // Test conversion from percentage (0-100) to VLC range (0-256)
      expect(_convertPercentageToVlc(0), equals(0));
      expect(_convertPercentageToVlc(25), equals(64));
      expect(_convertPercentageToVlc(50), equals(128));
      expect(_convertPercentageToVlc(75), equals(192));
      expect(_convertPercentageToVlc(100), equals(256));
      
      // Test edge cases
      expect(_convertPercentageToVlc(1), equals(3));
      expect(_convertPercentageToVlc(99), equals(253));
    });

    test('should convert VLC volume to percentage correctly', () {
      // Test conversion from VLC range (0-256) to percentage (0-100)
      expect(_convertVlcToPercentage(0), equals(0));
      expect(_convertVlcToPercentage(64), equals(25));
      expect(_convertVlcToPercentage(128), equals(50));
      expect(_convertVlcToPercentage(192), equals(75));
      expect(_convertVlcToPercentage(256), equals(100));
      
      // Test edge cases
      expect(_convertVlcToPercentage(3), equals(1));
      expect(_convertVlcToPercentage(253), equals(99));
    });

    test('should handle boundary values correctly', () {
      // Test that we don't go outside valid ranges
      expect(_convertPercentageToVlc(-1), equals(0));
      expect(_convertPercentageToVlc(101), equals(256));
      
      expect(_convertVlcToPercentage(-1), equals(0));
      expect(_convertVlcToPercentage(300), equals(100));
    });

    test('should maintain precision in round-trip conversion', () {
      // Test that converting back and forth doesn't lose too much precision
      for (int percentage in [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]) {
        final vlcVolume = _convertPercentageToVlc(percentage);
        final backToPercentage = _convertVlcToPercentage(vlcVolume);
        
        // Allow for small rounding differences (±1%)
        expect((backToPercentage - percentage).abs(), lessThanOrEqualTo(1),
            reason: 'Round-trip conversion failed for $percentage%: $percentage → $vlcVolume → $backToPercentage');
      }
    });

    test('should calculate progress correctly', () {
      // Test MediaStatus-like progress calculation
      expect(_calculateProgress(0, 100), equals(0.0));
      expect(_calculateProgress(25, 100), equals(0.25));
      expect(_calculateProgress(50, 100), equals(0.5));
      expect(_calculateProgress(100, 100), equals(1.0));
      
      // Test edge cases
      expect(_calculateProgress(0, 0), equals(0.0)); // Avoid division by zero
      expect(_calculateProgress(50, 0), equals(0.0)); // Avoid division by zero
    });

    test('should handle real-world VLC volume scenarios', () {
      // Test common volume levels that users might set
      final commonLevels = [10, 25, 50, 75, 100];
      
      for (final level in commonLevels) {
        final vlcValue = _convertPercentageToVlc(level);
        final backToLevel = _convertVlcToPercentage(vlcValue);
        
        print('Volume test: $level% → VLC:$vlcValue → Back:$backToLevel%');
        
        // Should be very close to original value
        expect((backToLevel - level).abs(), lessThanOrEqualTo(1),
            reason: 'Volume conversion inaccurate for $level%');
      }
    });
  });
}

/// Convert percentage (0-100) to VLC volume (0-256)
int _convertPercentageToVlc(int percentage) {
  if (percentage <= 0) return 0;
  if (percentage >= 100) return 256;
  return (percentage * 256 / 100).round();
}

/// Convert VLC volume (0-256) to percentage (0-100)
int _convertVlcToPercentage(int vlcVolume) {
  if (vlcVolume <= 0) return 0;
  if (vlcVolume >= 256) return 100;
  return (vlcVolume * 100 / 256).round();
}

/// Calculate progress like MediaStatus does
double _calculateProgress(int current, int total) {
  if (total <= 0) return 0.0;
  return current / total;
}
