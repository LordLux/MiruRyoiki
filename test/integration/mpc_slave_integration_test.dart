// ignore_for_file: avoid_print
@Timeout(Duration(minutes: 3))
@Tags(['requires-player'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/services/players/slave/mpc_slave_bridge.dart';
import 'package:miruryoiki/services/players/slave/mpc_slave_manager.dart';
import 'package:miruryoiki/services/players/slave/mpc_slave_payload.dart';
import 'package:miruryoiki/utils/path.dart';

import 'support/mpc_test_harness.dart';

/// End-to-end test of the push-based **slave mode**: launches MPC-HC with
/// `/slave <hwnd>`, and asserts the full handshake + notification flow that
/// [MpcSlaveManager] relies on:
///
///   1. CMD_CONNECT arrives (instance registers itself);
///   2. CMD_NOWPLAYING arrives with the launched file and a real duration;
///   3. play/pause via the slave API round-trips through CMD_PLAYMODE;
///   4. the launched instance is closed again on teardown.
///
/// Unlike the web-UI tests this needs NO web interface — that is the point of
/// slave mode. It spawns its own MPC-HC instance and closes it afterwards.
///
/// Prerequisites (otherwise the test self-skips, it does not fail):
///   * MPC_HC_PATH + TEST_VIDEO_PATH available (test/.env or default install paths)
///   * NO MPC-HC instance already running — MPC-HC's "use the same player for
///     each media file" option can hand the /slave launch off to the existing
///     instance, which would break the handshake assertion.
///
/// Run: `powershell -File test/launch_scripts/requires_player.ps1`
void main() {
  late MpcSlaveManager manager;
  int launchedHwnd = 0;

  tearDownAll(() async {
    // Close the instance we launched via the slave API (CMD_CLOSEAPP).
    if (launchedHwnd != 0) {
      print('[INFO] Closing launched slave instance $launchedHwnd');
      MpcSlaveBridge.instance.send(launchedHwnd, MpcCommand.closeApp);
      await Future.delayed(const Duration(seconds: 1));
    }
    await manager.dispose();
  });

  test('slave launch connects, pushes now-playing, and responds to play/pause', () async {
    manager = MpcSlaveManager();

    final mpcPath = MpcTestHarness.mpcPath;
    final videoPath = MpcTestHarness.videoPath;
    if (mpcPath == null || videoPath == null) {
      print('[SKIP] MPC_HC_PATH / TEST_VIDEO_PATH not available — set them in '
          'test/.env to run the slave-mode integration test.');
      return;
    }

    // Wait briefly for any instance a previous test file just closed to
    // finish shutting down before declaring the slate dirty.
    final clean = await _poll(() => MpcTestHarness.findMpcWindows().isEmpty, const Duration(seconds: 5));
    if (!clean) {
      print('[SKIP] An MPC-HC instance is already running. Slave-mode launch '
          'behavior depends on MPC-HC\'s "use same instance" setting, so this '
          'test only runs against a clean slate — close MPC-HC and rerun.');
      return;
    }

    // --- 1. Bridge starts and MPC-HC connects ---
    expect(await manager.ensureStarted(), isTrue, reason: 'WM_COPYDATA bridge failed to start');
    expect(await manager.launch(mpcPath, PathString(videoPath)), isTrue, reason: 'Failed to launch MPC-HC in slave mode');

    final connected = await _poll(() => manager.hasInstances, const Duration(seconds: 20));
    expect(connected, isTrue, reason: 'MPC-HC never sent CMD_CONNECT — is "$mpcPath" a real MPC-HC?');
    launchedHwnd = manager.activeInstance!.hwnd;
    print('[INFO] Slave instance connected: hwnd $launchedHwnd');

    // --- 2. Now-playing push with the launched file and a real duration ---
    final loaded = await _poll(
      () => (manager.lastStatus?.totalDuration ?? Duration.zero) > Duration.zero,
      const Duration(seconds: 20),
    );
    expect(loaded, isTrue, reason: 'CMD_NOWPLAYING with a duration never arrived');

    final status = manager.lastStatus!;
    print('[INFO] Now playing: ${status.filePath} (${status.totalDuration})');
    expect(status.filePath.toLowerCase(), videoPath.toLowerCase(), reason: 'Slave instance reports a different file than launched');

    // --- 3. Play/pause round-trips through CMD_PLAYMODE ---
    final wasPlaying = await _poll(() => manager.lastStatus?.isPlaying ?? false, const Duration(seconds: 10));
    expect(wasPlaying, isTrue, reason: 'Playback never started (launched with /play)');

    manager.pause();
    final paused = await _poll(() => !(manager.lastStatus?.isPlaying ?? true), const Duration(seconds: 5));
    expect(paused, isTrue, reason: 'CMD_PAUSE had no effect (no CMD_PLAYMODE push received)');
    print('[INFO] Paused via slave API');

    manager.play();
    final resumed = await _poll(() => manager.lastStatus?.isPlaying ?? false, const Duration(seconds: 5));
    expect(resumed, isTrue, reason: 'CMD_PLAY had no effect (no CMD_PLAYMODE push received)');
    print('[INFO] Resumed via slave API');
  });
}

/// Polls [condition] every 200ms until it holds or [timeout] elapses.
Future<bool> _poll(bool Function() condition, Duration timeout) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (condition()) return true;
    await Future.delayed(const Duration(milliseconds: 200));
  }
  return condition();
}
