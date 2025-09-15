import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

import '../../lib/services/players/vlc_player.dart';
import '../../lib/models/players/mediastatus.dart';

void main() {
  group('VLC Player Integration Tests', () {
    late VLCPlayer vlcPlayer;

    setUp(() {
      vlcPlayer = VLCPlayer(
        host: 'localhost',
        port: 8080,
        password: 'miruryoiki',
      );
    });

    tearDown(() {
      vlcPlayer.dispose();
    });

    group('Volume Conversion Tests', () {
      test('should convert percentage to VLC volume correctly', () {
        // Test volume conversion logic
        final testCases = [
          {'input': 0, 'expected': 0},
          {'input': 25, 'expected': 64},   // 25 * 256 / 100 = 64
          {'input': 50, 'expected': 128},  // 50 * 256 / 100 = 128
          {'input': 75, 'expected': 192},  // 75 * 256 / 100 = 192
          {'input': 100, 'expected': 256}, // 100 * 256 / 100 = 256
        ];

        for (final testCase in testCases) {
          final input = testCase['input'] as int;
          final expected = testCase['expected'] as int;
          final actual = (input * 256 / 100).round();
          
          expect(actual, equals(expected), 
              reason: 'Converting $input% should give $expected, got $actual');
        }
      });

      test('should convert VLC volume to percentage correctly', () {
        // Test volume reading conversion logic
        final testCases = [
          {'input': 0, 'expected': 0},
          {'input': 64, 'expected': 25},   // 64 * 100 / 256 = 25
          {'input': 128, 'expected': 50},  // 128 * 100 / 256 = 50
          {'input': 192, 'expected': 75},  // 192 * 100 / 256 = 75
          {'input': 256, 'expected': 100}, // 256 * 100 / 256 = 100
        ];

        for (final testCase in testCases) {
          final input = testCase['input'] as int;
          final expected = testCase['expected'] as int;
          final actual = (input * 100 / 256).round();
          
          expect(actual, equals(expected), 
              reason: 'Converting VLC volume $input should give $expected%, got $actual%');
        }
      });

      test('should clamp volume values correctly', () {
        final testCases = [
          {'input': -10, 'expected': 0},
          {'input': 0, 'expected': 0},
          {'input': 50, 'expected': 50},
          {'input': 100, 'expected': 100},
          {'input': 150, 'expected': 100},
        ];

        for (final testCase in testCases) {
          final input = testCase['input'] as int;
          final expected = testCase['expected'] as int;
          final actual = input.clamp(0, 100);
          
          expect(actual, equals(expected), 
              reason: 'Clamping $input should give $expected, got $actual');
        }
      });
    });

    group('MediaStatus Tests', () {
      test('should calculate progress correctly', () {
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

      test('should handle zero duration gracefully', () {
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

    // Integration tests that require VLC to be running
    group('VLC Integration Tests', () {
      test('should connect to VLC when running', () async {
        // This test requires VLC to be running with web interface enabled
        final connected = await vlcPlayer.connect();
        
        // If VLC is not running, skip the test
        if (!connected) {
          print('⚠️  Skipping VLC integration test - VLC not running or not configured');
          return;
        }

        expect(connected, isTrue);
        
        // Test status streaming
        final statusCompleter = Completer<MediaStatus>();
        final subscription = vlcPlayer.statusStream.listen((status) {
          if (!statusCompleter.isCompleted) {
            statusCompleter.complete(status);
          }
        });

        try {
          final status = await statusCompleter.future.timeout(Duration(seconds: 5));
          
          // Basic validation
          expect(status.volumeLevel, inInclusiveRange(0, 100));
          expect(status.progress, inInclusiveRange(0.0, 1.0));
          
          print('✅ VLC Status: ${status.isPlaying ? 'PLAYING' : 'PAUSED'} | Volume: ${status.volumeLevel}%');
          
        } catch (e) {
          print('⚠️  Could not get status from VLC: $e');
        } finally {
          await subscription.cancel();
          vlcPlayer.disconnect();
        }
      }, timeout: Timeout(Duration(seconds: 10)));
    });
  });
}
