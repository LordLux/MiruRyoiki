import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;
import 'package:win32/win32.dart';

import 'logging.dart';
import 'path.dart';

/// Which media player Windows is configured to open a file type with.
enum DefaultPlayerKind { mpcHc, vlc, mpv, unknown }

/// The OS default player for a file type, plus the resolved executable path.
class DefaultPlayer {
  final DefaultPlayerKind kind;
  final String? executablePath;

  const DefaultPlayer(this.kind, this.executablePath);

  @override
  String toString() => 'DefaultPlayer($kind, $executablePath)';
}

// RegGetValue flags: accept REG_SZ and REG_EXPAND_SZ (auto-expanded since
// RRF_NOEXPAND is not set). App Paths entries are sometimes REG_EXPAND_SZ.
const int _rrfStringFlags = 0x0000000A; // RRF_RT_REG_SZ | RRF_RT_REG_EXPAND_SZ

/// Resolves the default video player Windows uses for a given file, **read-only**.
///
/// Resolution honors the per-user choice first, then the classic association:
///   1. ProgId from `HKCU\…\Explorer\FileExts\<ext>\UserChoice`, else
///      the default value of `HKCR\<ext>`, then
///   2. that ProgId's `HKCR\<progId>\shell\open\command`, from which the
///      executable is extracted.
///
/// The resolved exe doubles as the path to launch MPC-HC in slave mode, so no
/// separate executable discovery is needed for the common case.
abstract final class DefaultPlayerResolver {
  static DefaultPlayer resolveForPath(PathString path) => resolve(p.extension(path.path));

  static DefaultPlayer resolve(String extension) {
    if (!Platform.isWindows) return const DefaultPlayer(DefaultPlayerKind.unknown, null);
    if (extension.isEmpty) return const DefaultPlayer(DefaultPlayerKind.unknown, null);

    final ext = (extension.startsWith('.') ? extension : '.$extension').toLowerCase();

    // 1. ProgId: per-user choice first, then the classic HKCR\<ext> default.
    var progId = _regGetString(
      HKEY_CURRENT_USER,
      r'Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\' '$ext' r'\UserChoice',
      'ProgId',
    );
    if (progId == null || progId.isEmpty) progId = _regGetString(HKEY_CLASSES_ROOT, ext, '');
    if (progId == null || progId.isEmpty) return const DefaultPlayer(DefaultPlayerKind.unknown, null);

    // 2. ProgId -> open command -> executable.
    final command = _regGetString(HKEY_CLASSES_ROOT, '$progId\\shell\\open\\command', '');
    final exe = command == null ? null : _exeFromCommand(command);

    if (exe == null || exe.isEmpty) return const DefaultPlayer(DefaultPlayerKind.unknown, null);
    return DefaultPlayer(_classify(exe), exe);
  }

  static DefaultPlayerKind _classify(String exePath) {
    final name = exePath.split(RegExp(r'[\\/]')).last.toLowerCase();
    if (name.startsWith('mpc-hc')) return DefaultPlayerKind.mpcHc; // mpc-hc.exe / mpc-hc64.exe / portable
    if (name == 'vlc.exe') return DefaultPlayerKind.vlc;
    if (name == 'mpv.exe' || name == 'mpvnet.exe' || name == 'mpv.net.exe') return DefaultPlayerKind.mpv;
    return DefaultPlayerKind.unknown;
  }

  /// Extracts the executable from a `shell\open\command` string such as
  /// `"C:\Program Files\MPC-HC\mpc-hc64.exe" "%1"`.
  static String? _exeFromCommand(String command) {
    final trimmed = command.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('"')) {
      final end = trimmed.indexOf('"', 1);
      if (end > 1) return trimmed.substring(1, end);
    }
    final space = trimmed.indexOf(' ');
    return space > 0 ? trimmed.substring(0, space) : trimmed;
  }

  static String? _regGetString(int hive, String subKey, String valueName) {
    final subKeyPtr = subKey.toNativeUtf16();
    final valuePtr = valueName.toNativeUtf16();
    const capacityChars = 1024;
    final buffer = calloc<Uint16>(capacityChars);
    final sizePtr = calloc<Uint32>()..value = capacityChars * 2; // bytes
    try {
      final result = RegGetValue(hive, subKeyPtr, valuePtr, _rrfStringFlags, nullptr, buffer.cast(), sizePtr);
      if (result != ERROR_SUCCESS) return null;
      return buffer.cast<Utf16>().toDartString();
    } catch (e, st) {
      logErr('Registry read failed for $subKey\\$valueName', e, st);
      return null;
    } finally {
      calloc.free(subKeyPtr);
      calloc.free(valuePtr);
      calloc.free(buffer);
      calloc.free(sizePtr);
    }
  }

  /// Best-effort discovery of an installed MPC-HC executable, independent of the
  /// OS default association. Order: App Paths registry (installer-registered),
  /// then common install folders (incl. K-Lite's bundled MPC-HC64). Returns an
  /// existing path, or null if not found.
  ///
  /// `where.exe` is intentionally not used: GUI players are virtually never on
  /// PATH, so it would only be dead weight.
  static String? locateMpcHc() {
    if (!Platform.isWindows) return null;

    // 1. App Paths registry (full exe path), across the registry views.
    const appPaths = r'Software\Microsoft\Windows\CurrentVersion\App Paths\';
    const appPathsWow = r'Software\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\';
    for (final exe in const ['mpc-hc64.exe', 'mpc-hc.exe']) {
      for (final entry in [
        (HKEY_LOCAL_MACHINE, '$appPaths$exe'),
        (HKEY_LOCAL_MACHINE, '$appPathsWow$exe'),
        (HKEY_CURRENT_USER, '$appPaths$exe'),
      ]) {
        final raw = _regGetString(entry.$1, entry.$2, '');
        final path = raw == null ? null : _unquote(raw);
        if (path != null && path.isNotEmpty && File(path).existsSync()) return path;
      }
    }

    // 2. Common install folders (covers K-Lite's bundled MPC-HC64).
    for (final candidate in _commonMpcHcPaths()) {
      if (File(candidate).existsSync()) return candidate;
    }
    return null;
  }

  static List<String> _commonMpcHcPaths() {
    final pf = Platform.environment['ProgramFiles'] ?? r'C:\Program Files';
    final pfx86 = Platform.environment['ProgramFiles(x86)'] ?? r'C:\Program Files (x86)';
    return [
      p.join(pf, 'MPC-HC', 'mpc-hc64.exe'),
      p.join(pf, 'MPC-HC', 'mpc-hc.exe'),
      p.join(pfx86, 'MPC-HC', 'mpc-hc.exe'),
      p.join(pfx86, 'MPC-HC', 'mpc-hc64.exe'),
      p.join(pfx86, 'K-Lite Codec Pack', 'MPC-HC64', 'mpc-hc64.exe'),
      p.join(pf, 'K-Lite Codec Pack', 'MPC-HC64', 'mpc-hc64.exe'),
      p.join(pfx86, 'K-Lite Codec Pack', 'MPC-HC', 'mpc-hc.exe'),
    ];
  }

  static String _unquote(String value) {
    final trimmed = value.trim();
    if (trimmed.length >= 2 && trimmed.startsWith('"') && trimmed.endsWith('"')) return trimmed.substring(1, trimmed.length - 1);
    return trimmed;
  }
}
