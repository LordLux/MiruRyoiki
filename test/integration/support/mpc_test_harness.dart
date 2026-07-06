// ignore_for_file: avoid_print

/// Shared MPC-HC lifecycle for the `requires-player` integration tests.
///
/// Behavior:
///   * If an MPC-HC instance is already running (the user's own), tests use it
///     and the harness will NOT close it.
///   * Otherwise, if `test/.env` provides the paths below, the harness spawns
///     its own MPC-HC with a video loaded and closes ONLY the window(s) it
///     spawned in [release] — no more manually closing the player after runs.
///   * If neither is possible, [acquire] returns false and the caller should
///     self-skip (matching the existing convention of these tests).
///
/// `test/.env` keys:
///   MPC_HC_PATH=C:\Program Files\MPC-HC\mpc-hc64.exe   (falls back to common install paths)
///   TEST_VIDEO_PATH=M:\path\to\some\video.mkv          (required for spawning)
///
/// Note: the web-interface tests additionally need "Listen on port 13579"
/// enabled in MPC-HC's Options ▸ Player ▸ Web Interface — that is a persisted
/// MPC-HC setting, not something the harness can pass on the command line.
library;

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:win32/win32.dart';

abstract final class MpcTestHarness {
  static const String mpcWindowClass = 'MediaPlayerClassicW';
  static const String webUiBase = 'http://localhost:13579';

  static bool _envLoaded = false;
  static String? _mpcPath;
  static String? _videoPath;

  static bool _spawned = false;
  static final Set<int> _preExistingHwnds = {};

  /// MPC-HC executable path from test/.env or common install locations.
  static String? get mpcPath {
    _loadEnv();
    return _mpcPath;
  }

  /// Test video path from test/.env (required for spawning an instance).
  static String? get videoPath {
    _loadEnv();
    return _videoPath;
  }

  /// Whether the current MPC-HC instance was spawned by this harness.
  static bool get spawnedOwnInstance => _spawned;

  static void _loadEnv() {
    if (_envLoaded) return;
    _envLoaded = true;

    final envFile = File('test/.env');
    if (envFile.existsSync()) {
      for (final line in envFile.readAsStringSync().split('\n')) {
        final eqIdx = line.indexOf('=');
        if (eqIdx < 0) continue;
        final key = line.substring(0, eqIdx).trim();
        var value = line.substring(eqIdx + 1).trim();
        // Strip surrounding quotes ("C:\..." style values)
        if (value.length >= 2 && (value.startsWith('"') && value.endsWith('"') || value.startsWith("'") && value.endsWith("'"))) {
          value = value.substring(1, value.length - 1);
        }
        if (key == 'MPC_HC_PATH' && value.isNotEmpty) _mpcPath = value;
        if (key == 'TEST_VIDEO_PATH' && value.isNotEmpty) _videoPath = value;
      }
    }

    // Fall back to common install locations for the executable
    if (_mpcPath == null || !File(_mpcPath!).existsSync()) {
      const candidates = [
        r'C:\Program Files\MPC-HC\mpc-hc64.exe',
        r'C:\Program Files (x86)\MPC-HC\mpc-hc.exe',
        r'C:\Program Files (x86)\K-Lite Codec Pack\MPC-HC64\mpc-hc64.exe',
      ];
      _mpcPath = null;
      for (final candidate in candidates) {
        if (File(candidate).existsSync()) {
          _mpcPath = candidate;
          break;
        }
      }
    }

    if (_videoPath != null && !File(_videoPath!).existsSync()) {
      print('[harness] TEST_VIDEO_PATH does not exist: $_videoPath');
      _videoPath = null;
    }
  }

  /// Up to [count] test videos: TEST_VIDEO_PATH first, then other videos in
  /// the same folder. Used by tests that need more than one file (e.g. the
  /// multi-instance slave tests).
  static List<String> sampleVideos(int count) {
    _loadEnv();
    if (_videoPath == null) return const [];

    const exts = {'.mkv', '.mp4', '.avi', '.m4v', '.mov'};
    final found = <String>[_videoPath!];

    final dir = File(_videoPath!).parent;
    if (dir.existsSync()) {
      for (final entity in dir.listSync().whereType<File>()) {
        if (found.length >= count) break;
        if (entity.path == _videoPath) continue;
        if (exts.contains(p.extension(entity.path).toLowerCase())) found.add(entity.path);
      }
    }
    return found;
  }

  /// All top-level MPC-HC windows, enumerated via FindWindowEx (handles
  /// multiple instances — FindWindow alone only returns the topmost one).
  static List<int> findMpcWindows() {
    final classNamePtr = mpcWindowClass.toNativeUtf16();
    try {
      final hwnds = <int>[];
      var hwnd = FindWindowEx(0, 0, classNamePtr, nullptr);
      while (hwnd != 0) {
        hwnds.add(hwnd);
        hwnd = FindWindowEx(0, hwnd, classNamePtr, nullptr);
      }
      return hwnds;
    } finally {
      calloc.free(classNamePtr);
    }
  }

  /// True when MPC-HC's web interface responds on :13579.
  static Future<bool> webUiReachable() async {
    try {
      final response = await http.get(Uri.parse('$webUiBase/variables.html')).timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Ensures an MPC-HC instance with a video is available.
  ///
  /// Uses an already-running instance when present; otherwise spawns one from
  /// [mpcPath] + [videoPath]. Returns false when neither is possible (caller
  /// should self-skip).
  static Future<bool> acquire() async {
    if (findMpcWindows().isNotEmpty) {
      print('[harness] Using already-running MPC-HC instance (will not close it).');
      return true;
    }

    _loadEnv();
    if (_mpcPath == null || _videoPath == null) {
      print('[harness] No running MPC-HC and cannot spawn one — set MPC_HC_PATH '
          'and TEST_VIDEO_PATH in test/.env to let tests manage their own player.');
      return false;
    }

    _preExistingHwnds
      ..clear()
      ..addAll(findMpcWindows());

    print('[harness] Spawning MPC-HC: $_mpcPath "$_videoPath"');
    await Process.start(_mpcPath!, [_videoPath!, '/play'], mode: ProcessStartMode.detached);
    _spawned = true;

    // Wait for the window to appear (and give the file a moment to load)
    for (var i = 0; i < 30; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (findMpcWindows().any((h) => !_preExistingHwnds.contains(h))) {
        await Future.delayed(const Duration(seconds: 2)); // let the file load
        return true;
      }
    }

    print('[harness] MPC-HC window did not appear within 15s.');
    return findMpcWindows().isNotEmpty;
  }

  /// Closes ONLY the window(s) this harness spawned; a user's own instance is
  /// left untouched. Safe to call unconditionally from tearDownAll.
  static Future<void> release() async {
    if (!_spawned) return;

    for (final hwnd in findMpcWindows()) {
      if (!_preExistingHwnds.contains(hwnd)) {
        print('[harness] Closing spawned MPC-HC window $hwnd');
        PostMessage(hwnd, WM_CLOSE, 0, 0);
      }
    }
    _spawned = false;
    // Give MPC-HC a moment to shut down before the next test file runs
    await Future.delayed(const Duration(seconds: 1));
  }
}
