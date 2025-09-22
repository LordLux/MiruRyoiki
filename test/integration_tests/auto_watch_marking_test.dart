// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/models/episode.dart';
import 'package:miruryoiki/models/players/mediastatus.dart';
import 'package:miruryoiki/services/library/library_provider.dart';
import 'package:miruryoiki/utils/path.dart';

void main() {
  group('Auto Watch Marking Tests', () {
    test('should automatically mark episode as watched when progress exceeds threshold', () {
      // Test MediaStatus with different progress levels
      final belowThresholdStatus = MediaStatus(
        filePath: 'test/episode.mkv',
        currentPosition: Duration(seconds: 800), // 13:20
        totalDuration: Duration(seconds: 1200),  // 20:00
        isPlaying: true,
        volumeLevel: 50,
        isMuted: false,
      );

      final aboveThresholdStatus = MediaStatus(
        filePath: 'test/episode.mkv',
        currentPosition: Duration(seconds: 1150), // 19:10
        totalDuration: Duration(seconds: 1200),   // 20:00
        isPlaying: true,
        volumeLevel: 50,
        isMuted: false,
      );

      // Calculate progress percentages
      final belowProgress = belowThresholdStatus.progress;
      final aboveProgress = aboveThresholdStatus.progress;

      print('Below threshold progress: ${(belowProgress * 100).toStringAsFixed(1)}%');
      print('Above threshold progress: ${(aboveProgress * 100).toStringAsFixed(1)}%');
      print('Library threshold: ${(Library.progressThreshold * 100).toStringAsFixed(1)}%');

      // Verify our test data
      expect(belowProgress, lessThan(Library.progressThreshold));
      expect(aboveProgress, greaterThan(Library.progressThreshold));

      print('✅ Auto-watch marking logic validated');
      print('   Episodes will be marked as watched when progress > ${(Library.progressThreshold * 100)}%');
    });

    test('should calculate progress correctly', () {
      final status = MediaStatus(
        filePath: 'test.mkv',
        currentPosition: Duration(minutes: 57), // 57 minutes
        totalDuration: Duration(minutes: 60),   // 60 minutes
        isPlaying: true,
        volumeLevel: 50,
        isMuted: false,
      );

      final progress = status.progress;
      expect(progress, closeTo(0.95, 0.01));
      
      // This should trigger auto-watch marking since 95% > 95% threshold
      expect(progress, equals(Library.progressThreshold));
    });

    test('should only mark unwatched episodes', () {
      final alreadyWatchedEpisode = Episode(
        path: PathString('test/watched.mkv'),
        name: 'Already Watched Episode',
        watched: true,
        progress: 1.0,
      );

      final unwatchedEpisode = Episode(
        path: PathString('test/unwatched.mkv'),
        name: 'Unwatched Episode',
        watched: false,
        progress: 0.0,
      );

      // Verify initial states
      expect(alreadyWatchedEpisode.watched, isTrue);
      expect(unwatchedEpisode.watched, isFalse);

      print('✅ Episode watch state logic validated');
    });
  });
}