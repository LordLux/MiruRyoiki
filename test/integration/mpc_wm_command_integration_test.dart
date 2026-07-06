// ignore_for_file: avoid_print
@Timeout(Duration(minutes: 2))
@Tags(['requires-player'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:miruryoiki/services/players/slave/mpc_slave_bridge.dart';
import 'package:miruryoiki/services/players/slave/mpc_slave_payload.dart';

import 'support/mpc_test_harness.dart';

/// Verifies the **WM_COMMAND-to-the-window** control path that slave mode relies
/// on for the actions the slave API lacks (mute) and as a volume fallback.
///
/// Rather than eyeballing the player, this asserts the effect by reading
/// MPC-HC's own web interface (`variables.html`) before/after each command, so
/// it is a real pass/fail check of [MpcSlaveBridge.sendWmCommand] +
/// [MpcWmCommand] against a live MPC-HC.
///
/// Player lifecycle is handled by [MpcTestHarness]: an already-running MPC-HC
/// is used (and left open); otherwise one is spawned from `test/.env` paths and
/// closed again afterwards. Commands are sent to EVERY MPC-HC window found —
/// `FindWindow` alone returns only the topmost instance, which previously made
/// this test fail when a second (e.g. leftover slave) instance was running and
/// the web-interface owner never received the commands.
///
/// Prerequisites (otherwise the test self-skips, it does not fail):
///   1. MPC-HC available (running, or spawnable via test/.env)
///   2. Its web interface enabled on :13579 (Options ▸ Player ▸ Web Interface)
///
/// Run: `powershell -File test/launch_scripts/requires_player.ps1`
const String _baseUrl = MpcTestHarness.webUiBase;

void main() {
  setUpAll(() async {
    await MpcTestHarness.acquire();
  });

  tearDownAll(() async {
    await MpcTestHarness.release();
  });

  test('WM_COMMAND volume up/down and mute reach MPC-HC', () async {
    final initial = await _readVariables();
    if (initial == null) {
      print('[SKIP] MPC-HC web interface not reachable on :13579 — start MPC-HC, '
          'enable the web interface, and load a video to run this test.');
      return;
    }

    final hwnds = MpcTestHarness.findMpcWindows();
    if (hwnds.isEmpty) {
      print('[SKIP] Could not find an MPC-HC window (class "${MpcTestHarness.mpcWindowClass}").');
      return;
    }
    print('[INFO] Found ${hwnds.length} MPC-HC window(s): $hwnds');
    if (hwnds.length > 1) {
      print('[INFO] Multiple instances detected — broadcasting commands to all of '
          'them so the web-interface owner is guaranteed to receive them.');
    }

    final bridge = MpcSlaveBridge.instance;
    void broadcast(int command) {
      for (final hwnd in hwnds) {
        bridge.sendWmCommand(hwnd, command);
      }
    }

    // --- Make sure we are unmuted and have headroom to move the volume down ---
    if (_boolVar(initial, 'muted')) {
      broadcast(MpcWmCommand.mute); // toggle off
      await Future.delayed(const Duration(milliseconds: 300));
    }
    for (var i = 0; i < 4; i++) {
      broadcast(MpcWmCommand.volumeUp);
      await Future.delayed(const Duration(milliseconds: 120));
    }

    final base = await _pollVar((v) => true);
    final baseVolume = _intVar(base, 'volumelevel');
    print('[INFO] Baseline volume: $baseVolume%');

    // --- Volume DOWN should lower volumelevel ---
    for (var i = 0; i < 3; i++) {
      broadcast(MpcWmCommand.volumeDown);
      await Future.delayed(const Duration(milliseconds: 120));
    }
    final afterDown = await _pollVar((v) => _intVar(v, 'volumelevel') < baseVolume);
    final downVolume = _intVar(afterDown, 'volumelevel');
    print('[INFO] After volume down: $downVolume%');
    expect(downVolume, lessThan(baseVolume), reason: 'WM_COMMAND 908 (volume down) had no effect');

    // --- Volume UP should raise it again ---
    for (var i = 0; i < 3; i++) {
      broadcast(MpcWmCommand.volumeUp);
      await Future.delayed(const Duration(milliseconds: 120));
    }
    final afterUp = await _pollVar((v) => _intVar(v, 'volumelevel') > downVolume);
    print('[INFO] After volume up: ${_intVar(afterUp, 'volumelevel')}%');
    expect(_intVar(afterUp, 'volumelevel'), greaterThan(downVolume), reason: 'WM_COMMAND 907 (volume up) had no effect');

    // --- Mute should toggle the muted flag, then restore ---
    final muteBefore = _boolVar(afterUp, 'muted');
    broadcast(MpcWmCommand.mute);
    final afterMute = await _pollVar((v) => _boolVar(v, 'muted') != muteBefore);
    print('[INFO] muted: $muteBefore → ${_boolVar(afterMute, 'muted')}');
    expect(_boolVar(afterMute, 'muted'), isNot(muteBefore), reason: 'WM_COMMAND 909 (mute) had no effect');

    // Restore the original mute state so we leave MPC-HC as we found it.
    broadcast(MpcWmCommand.mute);
    await Future.delayed(const Duration(milliseconds: 200));
  });
}

/// Reads and parses MPC-HC's `variables.html`, or returns null if unreachable.
Future<Map<String, String>?> _readVariables() async {
  try {
    final response = await http.get(Uri.parse('$_baseUrl/variables.html')).timeout(const Duration(seconds: 2));
    if (response.statusCode != 200) return null;
    final vars = <String, String>{};
    for (final match in RegExp(r'<p id="([^"]+)">([^<]*)</p>').allMatches(response.body)) {
      vars[match.group(1)!] = match.group(2) ?? '';
    }
    return vars;
  } catch (_) {
    return null;
  }
}

/// Polls `variables.html` until [predicate] holds or ~2s elapses, returning the
/// last snapshot read.
Future<Map<String, String>> _pollVar(bool Function(Map<String, String>) predicate) async {
  Map<String, String> last = const {};
  for (var i = 0; i < 10; i++) {
    final vars = await _readVariables();
    if (vars != null) {
      last = vars;
      if (predicate(vars)) return vars;
    }
    await Future.delayed(const Duration(milliseconds: 200));
  }
  return last;
}

int _intVar(Map<String, String> vars, String key) => int.tryParse(vars[key] ?? '') ?? 0;
bool _boolVar(Map<String, String> vars, String key) => vars[key] == '1';
