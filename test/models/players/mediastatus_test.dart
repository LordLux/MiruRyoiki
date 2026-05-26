import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/models/players/mediastatus.dart';

void main() {
  group('MediaStatus.progress', () {
    test('is the ratio of current position to total duration', () {
      final status = MediaStatus(
        filePath: 'test.mp4',
        currentPosition: Duration(seconds: 150),
        totalDuration: Duration(seconds: 300),
        isPlaying: true,
        volumeLevel: 50,
        isMuted: false,
      );

      expect(status.progress, closeTo(0.5, 0.01));
    });

    test('is 0 when total duration is zero (no division by zero)', () {
      final status = MediaStatus(
        filePath: 'test.mp4',
        currentPosition: Duration(seconds: 150),
        totalDuration: Duration.zero,
        isPlaying: true,
        volumeLevel: 50,
        isMuted: false,
      );

      expect(status.progress, equals(0.0));
    });
  });
}
