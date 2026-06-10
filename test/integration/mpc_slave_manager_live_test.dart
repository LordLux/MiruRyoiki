// ignore_for_file: avoid_print
@Timeout(Duration(minutes: 3))
@Tags(['requires-player'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/services/players/slave/mpc_slave_bridge.dart';
import 'package:miruryoiki/services/players/slave/mpc_slave_manager.dart';
import 'package:miruryoiki/services/players/slave/mpc_slave_payload.dart';
import 'package:miruryoiki/utils/path.dart';
import 'package:path/path.dart' as p;

/// LIVE test of the real [MpcSlaveManager] against real MPC-HC (no fakes):
/// launches two instances and verifies the manager tracks both, routes commands
/// to the active one, and falls back when an instance closes.
///
/// Requires MPC-HC's "allow multiple instances" to be on; otherwise the second
/// launch is forwarded to the first and the test reports that rather than failing.
/// Self-skips without the exe/videos.
/// Run: `powershell -File test/launch_scripts/requires_player.ps1 test/integration/mpc_slave_manager_live_test.dart`
const String _mpcExe = r'C:\Program Files (x86)\K-Lite Codec Pack\MPC-HC64\mpc-hc64.exe';
const String _seriesRoot = r'M:\Videos\Series';
const int _cmdCloseApp = 0xA0004006; // MPCAPI CMD_CLOSEAPP

void main() {
  test('MpcSlaveManager: tracks two real instances, targets commands, falls back on close', () async {
    if (!File(_mpcExe).existsSync()) {
      print('[SKIP] MPC-HC not found at $_mpcExe');
      return;
    }
    final videos = _findSampleVideos(2);
    if (videos.length < 2) {
      print('[SKIP] need two sample videos under $_seriesRoot\\*\\S01 (found ${videos.length})');
      return;
    }

    final bridge = MpcSlaveBridge.instance;
    final connectedHwnds = <int>[];
    final sub = bridge.incoming.listen((m) {
      if (m.command == MpcCommand.connect) connectedHwnds.add(m.senderHwnd);
    });

    final manager = MpcSlaveManager();
    try {
      expect(await manager.ensureStarted(), isTrue, reason: 'bridge should start');

      await manager.launch(_mpcExe, PathString(videos[0]));
      await _waitUntil(() => manager.instanceCount >= 1);
      await manager.launch(_mpcExe, PathString(videos[1]));
      await _waitUntil(() => manager.instanceCount >= 2);

      print('[INFO] instanceCount = ${manager.instanceCount}');
      if (manager.instanceCount < 2) {
        print('[WARN] only one instance tracked — MPC-HC "allow multiple instances" is likely OFF; '
            'single-instance path still works. Skipping multi-instance assertions.');
        return;
      }
      expect(manager.instanceCount, 2);

      // The active instance exposes a real status with a file.
      expect(manager.activeInstance, isNotNull);
      expect(manager.lastStatus?.filePath ?? '', isNotEmpty);
      print('[PASS] two instances tracked; active file: ${manager.lastStatus!.filePath}');

      // Command targeting: a pause reaches whichever instance is active.
      manager.pause();
      final paused = await _waitUntil(() => manager.lastStatus?.isPlaying == false);
      expect(paused, isTrue, reason: 'pause() should pause the active instance');
      manager.play();
      print('[PASS] commands reach the active instance (pause observed)');

      // Disconnect fallback: close the active instance; another stays active.
      final closedHwnd = manager.activeInstance!.hwnd;
      bridge.send(closedHwnd, _cmdCloseApp);
      final droppedToOne = await _waitUntil(() => manager.instanceCount == 1);
      expect(droppedToOne, isTrue, reason: 'closing an instance should drop the tracked count');
      expect(manager.activeInstance, isNotNull, reason: 'active should fall back to the remaining instance');
      print('[PASS] instance close handled; active fell back (file: ${manager.lastStatus?.filePath})');
    } finally {
      // Close every instance this test opened, then tear down.
      for (final hwnd in connectedHwnds) {
        bridge.send(hwnd, _cmdCloseApp);
      }
      await Future.delayed(const Duration(milliseconds: 300));
      await sub.cancel();
      await manager.dispose();
    }
  });
}

/// Polls [condition] until true or [timeout] elapses; returns its final value.
Future<bool> _waitUntil(bool Function() condition, {Duration timeout = const Duration(seconds: 15)}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (condition()) return true;
    await Future.delayed(const Duration(milliseconds: 200));
  }
  return condition();
}

List<String> _findSampleVideos(int count) {
  final root = Directory(_seriesRoot);
  if (!root.existsSync()) return const [];
  const exts = {'.mkv', '.mp4', '.avi', '.m4v', '.mov'};
  final found = <String>[];
  for (final series in root.listSync().whereType<Directory>()) {
    final season = Directory(p.join(series.path, 'S01'));
    if (!season.existsSync()) continue;
    for (final entity in season.listSync().whereType<File>()) {
      if (exts.contains(p.extension(entity.path).toLowerCase())) {
        found.add(entity.path);
        if (found.length >= count) return found;
      }
    }
  }
  return found;
}
