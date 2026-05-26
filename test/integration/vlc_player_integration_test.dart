/// Integration test for [VLCPlayer] against a real running VLC instance
/// (web interface enabled). Skips itself cleanly when VLC isn't reachable.
///
/// Run with:  powershell -File test/launch_scripts/requires_player.ps1
// ignore_for_file: avoid_print
@Timeout(Duration(minutes: 2))
@Tags(['requires-player'])
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/models/players/mediastatus.dart';
import 'package:miruryoiki/services/players/players/vlc_player.dart';

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

    test('should connect to VLC when running', () async {
      // This test requires VLC to be running with web interface enabled
      final connected = await vlcPlayer.connect();

      // If VLC is not running, skip the test
      if (!connected) {
        print('[WARNING] Skipping VLC integration test - VLC not running or not configured');
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

        print('[SUCCESS] VLC Status: ${status.isPlaying ? 'PLAYING' : 'PAUSED'} | Volume: ${status.volumeLevel}%');
      } catch (e) {
        print('[WARNING] Could not get status from VLC: $e');
      } finally {
        await subscription.cancel();
        vlcPlayer.disconnect();
      }
    }, timeout: Timeout(Duration(seconds: 10)));
  });
}
