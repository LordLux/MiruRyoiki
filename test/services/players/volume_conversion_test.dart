// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/services/players/players/vlc_player.dart';

/// Exercises the REAL VLC volume conversion used in production
/// ([VLCPlayer.percentToVlc] / [VLCPlayer.vlcToPercent]) rather than a local
/// reimplementation, so the test breaks if the production formula changes.
void main() {
  group('VLCPlayer volume conversion', () {
    test('percentToVlc maps 0-100% onto the 0-256 VLC scale', () {
      expect(VLCPlayer.percentToVlc(0), 0);
      expect(VLCPlayer.percentToVlc(25), 64);
      expect(VLCPlayer.percentToVlc(50), 128);
      expect(VLCPlayer.percentToVlc(75), 192);
      expect(VLCPlayer.percentToVlc(100), 256);
    });

    test('vlcToPercent maps the 0-256 VLC scale back onto 0-100%', () {
      expect(VLCPlayer.vlcToPercent(0), 0);
      expect(VLCPlayer.vlcToPercent(64), 25);
      expect(VLCPlayer.vlcToPercent(128), 50);
      expect(VLCPlayer.vlcToPercent(192), 75);
      expect(VLCPlayer.vlcToPercent(256), 100);
    });

    test('round-trips within 1% across the range', () {
      for (final percent in [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]) {
        final roundTripped = VLCPlayer.vlcToPercent(VLCPlayer.percentToVlc(percent));
        expect(
          (roundTripped - percent).abs(),
          lessThanOrEqualTo(1),
          reason: 'round-trip drifted for $percent%: '
              '$percent → ${VLCPlayer.percentToVlc(percent)} → $roundTripped',
        );
      }
    });
  });
}
