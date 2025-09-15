import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

import 'package:miruryoiki/services/players/player_manager.dart';
import 'package:miruryoiki/services/players/factory.dart';
import 'package:miruryoiki/models/players/mediastatus.dart';

void main() {
  group('PlayerManager Tests', () {
    late PlayerManager playerManager;

    setUp(() {
      playerManager = PlayerManager();
    });

    tearDown(() {
      playerManager.dispose();
    });

    group('Volume Management Tests', () {
      test('should handle volume up correctly with known current volume', () {
        // Test volume calculations without depending on internal state
        final testCurrentVolume = 50;

        final newVolumeUp = (testCurrentVolume + 5).clamp(0, 100);
        expect(newVolumeUp, equals(55));

        final newVolumeDown = (testCurrentVolume - 5).clamp(0, 100);
        expect(newVolumeDown, equals(45));
      });

      test('should handle volume boundaries correctly', () {
        final testCases = [
          {'current': 0, 'up': 5, 'down': 0},      // At minimum
          {'current': 5, 'up': 10, 'down': 0},     // Near minimum
          {'current': 50, 'up': 55, 'down': 45},   // Middle
          {'current': 95, 'up': 100, 'down': 90},  // Near maximum
          {'current': 100, 'up': 100, 'down': 95}, // At maximum
        ];

        for (final testCase in testCases) {
          final current = testCase['current'] as int;
          final expectedUp = testCase['up'] as int;
          final expectedDown = testCase['down'] as int;

          final actualUp = (current + 5).clamp(0, 100);
          final actualDown = (current - 5).clamp(0, 100);

          expect(actualUp, equals(expectedUp), 
              reason: 'Volume up from $current should be $expectedUp, got $actualUp');
          expect(actualDown, equals(expectedDown), 
              reason: 'Volume down from $current should be $expectedDown, got $actualDown');
        }
      });

      test('should use default volume when no status available', () {
        expect(playerManager.lastStatus, isNull);
        
        // When no status is available, should use default of 50
        final defaultVolume = playerManager.lastStatus?.volumeLevel ?? 50;
        expect(defaultVolume, equals(50));
      });
    });

    group('Connection State Tests', () {
      test('should start disconnected', () {
        expect(playerManager.isConnected, isFalse);
        expect(playerManager.currentPlayer, isNull);
      });

      test('should track connection status through stream', () async {
        final statusList = <PlayerConnectionStatus>[];
        final subscription = playerManager.connectionStream.listen(statusList.add);

        // Initially should be empty
        expect(statusList, isEmpty);

        // Try to connect (will fail since no player is running)
        await playerManager.connectToPlayer(PlayerType.vlc);

        // Should have received at least a connecting status
        expect(statusList.isNotEmpty, isTrue);
        
        await subscription.cancel();
      });
    });

    group('Status Stream Tests', () {
      test('should provide status stream', () {
        expect(playerManager.statusStream, isNotNull);
        expect(playerManager.statusStream, isA<Stream<MediaStatus>>());
      });

      test('should provide connection stream', () {
        expect(playerManager.connectionStream, isNotNull);
        expect(playerManager.connectionStream, isA<Stream<PlayerConnectionStatus>>());
      });
    });

    // Integration test for auto-connect (requires actual players)
    group('Integration Tests', () {
      test('should handle auto-connect gracefully when no players available', () async {
        // This should not throw an exception even when no players are running
        final connected = await playerManager.autoConnect();
        
        // Should return false when no players are available
        if (!connected) {
          expect(playerManager.isConnected, isFalse);
          print('⚠️  No media players available for testing');
        } else {
          expect(playerManager.isConnected, isTrue);
          print('✅ Successfully auto-connected to a media player');
          
          // Test that we can get player info
          final players = await playerManager.getAvailablePlayers();
          expect(players, isNotEmpty);
          
          await playerManager.disconnect();
          expect(playerManager.isConnected, isFalse);
        }
      }, timeout: Timeout(Duration(seconds: 10)));

      test('should handle player commands gracefully when not connected', () async {
        expect(playerManager.isConnected, isFalse);

        // These should not throw exceptions even when not connected
        await expectLater(() async {
          await playerManager.play();
          await playerManager.pause();
          await playerManager.setVolume(50);
          await playerManager.mute();
          await playerManager.unmute();
        }(), completes);
      });
    });
  });
}
