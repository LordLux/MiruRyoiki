// ignore_for_file: avoid_print
@Timeout(Duration(minutes: 3))
@Tags(['requires-player'])
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/services/players/slave/mpc_slave_bridge.dart';
import 'package:miruryoiki/services/players/slave/mpc_slave_payload.dart';

import 'support/mpc_test_harness.dart';

/// LIVE end-to-end check of the real [MpcSlaveBridge] against a real MPC-HC:
/// launches `mpc-hc64.exe /slave <hostHwnd> "<file>"`, captures the WM_COPYDATA
/// push trace, and exercises command send. Closes its instance at the end.
///
/// Self-skips if the exe or the test video (test/.env) can't be found.
/// Run: `powershell -File test/launch_scripts/requires_player.ps1 test/integration/mpc_slave_live_test.dart`
void main() {
  test('MPC-HC slave mode: launch, receive push notifications, send commands', () async {
    final mpcExe = MpcTestHarness.mpcPath;
    if (mpcExe == null) {
      print('[SKIP] MPC-HC not found — set MPC_HC_PATH in test/.env');
      return;
    }
    final video = MpcTestHarness.videoPath;
    if (video == null) {
      print('[SKIP] No test video — set TEST_VIDEO_PATH in test/.env');
      return;
    }
    print('[INFO] Video: $video');

    final bridge = MpcSlaveBridge.instance;
    final trace = <MpcIncomingMessage>[];
    int senderHwnd = 0;
    final connected = Completer<int>();

    final sub = bridge.incoming.listen((msg) {
      trace.add(msg);
      print('  << ${_decode(msg)}');
      if (msg.command == MpcCommand.connect && !connected.isCompleted) {
        senderHwnd = msg.senderHwnd;
        connected.complete(msg.senderHwnd);
      }
    });

    try {
      final hostHwnd = await bridge.start();
      print('[INFO] Host (message-only) window: $hostHwnd');
      expect(hostHwnd, isNotNull, reason: 'message-only host window failed to start');
      expect(hostHwnd, isNot(0));

      print('[INFO] Launching: mpc-hc64.exe /slave $hostHwnd "$video"');
      await Process.start(mpcExe, ['/slave', '$hostHwnd', video], mode: ProcessStartMode.detached);

      // 1. Handshake.
      await connected.future.timeout(const Duration(seconds: 20),
          onTimeout: () => throw TimeoutException('No CMD_CONNECT received — slave handshake failed'));
      print('[PASS] CMD_CONNECT received (MPC-HC hwnd: $senderHwnd)');

      // 2. Let the automatic notifications flow in.
      await Future.delayed(const Duration(seconds: 6));

      // 3. Exercise command send: pause, then play, watching for play-mode pushes.
      print('[INFO] Sending CMD_PAUSE');
      bridge.send(senderHwnd, MpcCommand.pause);
      await Future.delayed(const Duration(seconds: 2));
      print('[INFO] Sending CMD_PLAY');
      bridge.send(senderHwnd, MpcCommand.play);
      await Future.delayed(const Duration(seconds: 2));

      // 4. MPC-HC doesn't auto-push position; verify it answers requests.
      print('[INFO] Requesting position via CMD_GETCURRENTPOSITION x4');
      for (var i = 0; i < 4; i++) {
        bridge.send(senderHwnd, MpcCommand.getCurrentPosition);
        await Future.delayed(const Duration(milliseconds: 800));
      }

      // --- Report + assertions -------------------------------------------
      final byCmd = <int, int>{};
      for (final m in trace) {
        byCmd[m.command] = (byCmd[m.command] ?? 0) + 1;
      }
      print('[SUMMARY] message counts: ${byCmd.map((k, v) => MapEntry('0x${k.toRadixString(16)}', v))}');

      final nowPlaying = trace.where((m) => m.command == MpcCommand.nowPlaying).map((m) => MpcNowPlaying.parse(m.payload)).toList();
      final positions = trace.where((m) => m.command == MpcCommand.currentPosition).map((m) => parseMpcSeconds(m.payload)).toList();
      final playModes = trace.where((m) => m.command == MpcCommand.playMode).map((m) => MpcPlayState.fromCode(int.tryParse(m.payload.trim()) ?? -1)).toList();

      expect(senderHwnd, isNot(0), reason: 'handshake gave no MPC-HC window handle');
      expect(nowPlaying, isNotEmpty, reason: 'no CMD_NOWPLAYING received — file metadata not pushed');
      print('[PASS] CMD_NOWPLAYING: "${nowPlaying.last.file}" (duration ${nowPlaying.last.duration})');

      expect(positions, isNotEmpty, reason: 'CMD_GETCURRENTPOSITION yielded no CMD_CURRENTPOSITION reply');
      print('[PASS] position on request: ${positions.first} -> ${positions.last} (${positions.length} samples)');
      print('[INFO] play-mode pushes: $playModes');
      expect(playModes, isNotEmpty, reason: 'no CMD_PLAYMODE received around pause/play');
      print('[PASS] command send produced play-mode notifications');

      print('[DONE] Slave protocol verified.');
    } finally {
      // Close the instance this test launched, then tear down.
      if (senderHwnd != 0) {
        print('[INFO] Closing launched instance $senderHwnd');
        bridge.send(senderHwnd, MpcCommand.closeApp);
        await Future.delayed(const Duration(milliseconds: 500));
      }
      await sub.cancel();
      await bridge.stop();
    }
  });
}

/// Decodes a message into a readable line for the trace.
String _decode(MpcIncomingMessage m) {
  switch (m.command) {
    case MpcCommand.connect:
      return 'CMD_CONNECT hwnd=${m.payload}';
    case MpcCommand.state:
      return 'CMD_STATE ${MpcLoadState.fromCode(int.tryParse(m.payload.trim()) ?? -1)}';
    case MpcCommand.playMode:
      return 'CMD_PLAYMODE ${MpcPlayState.fromCode(int.tryParse(m.payload.trim()) ?? -1)}';
    case MpcCommand.nowPlaying:
      final np = MpcNowPlaying.parse(m.payload);
      return 'CMD_NOWPLAYING file="${np.file}" dur=${np.duration} title="${np.title}"';
    case MpcCommand.currentPosition:
      return 'CMD_CURRENTPOSITION ${parseMpcSeconds(m.payload)}';
    case MpcCommand.notifySeek:
      return 'CMD_NOTIFYSEEK ${parseMpcSeconds(m.payload)}';
    case MpcCommand.notifyEndOfStream:
      return 'CMD_NOTIFYENDOFSTREAM';
    case MpcCommand.disconnect:
      return 'CMD_DISCONNECT';
    default:
      return 'cmd=0x${m.command.toRadixString(16)} "${m.payload}"';
  }
}

