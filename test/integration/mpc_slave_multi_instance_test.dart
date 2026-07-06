// ignore_for_file: avoid_print
@Timeout(Duration(minutes: 3))
@Tags(['requires-player'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/services/players/slave/mpc_slave_bridge.dart';
import 'package:miruryoiki/services/players/slave/mpc_slave_payload.dart';

import 'support/mpc_test_harness.dart';

/// LIVE multi-instance check: launches TWO MPC-HC windows in slave mode and
/// confirms each reports its OWN window handle via a distinct CMD_CONNECT (the
/// foundation that makes correct multi-instance tracking possible — what the
/// single-server web interface could not do). Closes both instances at the end.
///
/// Requires MPC-HC's "allow multiple instances" to be on (otherwise the second
/// launch is forwarded to the first and only one CMD_CONNECT arrives — the test
/// reports that case rather than hard-failing). Self-skips without the exe/videos
/// (needs TEST_VIDEO_PATH in test/.env plus a second video in the same folder).
/// Run: `powershell -File test/launch_scripts/requires_player.ps1 test/integration/mpc_slave_multi_instance_test.dart`
void main() {
  test('two MPC-HC slave instances each connect with their own handle', () async {
    final mpcExe = MpcTestHarness.mpcPath;
    if (mpcExe == null) {
      print('[SKIP] MPC-HC not found — set MPC_HC_PATH in test/.env');
      return;
    }
    final videos = MpcTestHarness.sampleVideos(2);
    if (videos.length < 2) {
      print('[SKIP] Need two videos (TEST_VIDEO_PATH plus a sibling in its folder, found ${videos.length})');
      return;
    }
    print('[INFO] Videos:\n  - ${videos[0]}\n  - ${videos[1]}');

    final bridge = MpcSlaveBridge.instance;
    final connects = <int>[];
    final filesByHwnd = <int, String>{};

    final sub = bridge.incoming.listen((msg) {
      if (msg.command == MpcCommand.connect) {
        connects.add(msg.senderHwnd);
        print('  << CMD_CONNECT from ${msg.senderHwnd}');
      } else if (msg.command == MpcCommand.nowPlaying) {
        filesByHwnd[msg.senderHwnd] = MpcNowPlaying.parse(msg.payload).file;
      }
    });

    try {
      final hostHwnd = await bridge.start();
      expect(hostHwnd, isNot(0));
      print('[INFO] Host window: $hostHwnd');

      for (final video in videos) {
        await Process.start(mpcExe, ['/slave', '$hostHwnd', video], mode: ProcessStartMode.detached);
        await Future.delayed(const Duration(seconds: 3)); // let each connect before the next
      }
      await Future.delayed(const Duration(seconds: 3));

      final distinct = connects.toSet();
      print('[SUMMARY] CMD_CONNECT handles: $distinct');
      print('[SUMMARY] files by handle: $filesByHwnd');

      expect(connects, isNotEmpty, reason: 'no slave instance connected at all');

      if (distinct.length >= 2) {
        print('[PASS] two distinct MPC-HC windows connected — multi-instance tracking works');
        expect(filesByHwnd.length, greaterThanOrEqualTo(2), reason: 'each instance should report its own file');
      } else {
        print('[WARN] only one instance connected — MPC-HC likely has "allow multiple instances" OFF; '
            'multi-instance needs it ON. Single-instance path still works.');
      }
    } finally {
      // Close every instance this test launched, then tear down.
      for (final hwnd in connects.toSet()) {
        print('[INFO] Closing launched instance $hwnd');
        bridge.send(hwnd, MpcCommand.closeApp);
      }
      await Future.delayed(const Duration(milliseconds: 500));
      await sub.cancel();
      await bridge.stop();
    }
  });
}
