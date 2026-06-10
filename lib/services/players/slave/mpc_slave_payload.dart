/// Pure-Dart definitions and parsing for the MPC-HC external ("slave") API.
///
/// MPC-HC is launched with `mpc-hc.exe /slave <hostHwnd> "<file>"`. It then
/// pushes notifications to our window via `WM_COPYDATA`, where:
///   * `COPYDATASTRUCT.dwData` = one of [MpcCommand] (the command code),
///   * `COPYDATASTRUCT.lpData` = a null-terminated UTF-16 string payload,
///   * `COPYDATASTRUCT.cbData` = payload byte length (including the terminator).
///
/// Multi-value payloads are pipe-delimited; a literal pipe inside a value is
/// escaped as `\|`. See [splitMpcFields].
///
/// This file is deliberately free of FFI and Flutter imports so it can be
/// unit-tested without a running player. Numeric values are verified against
/// `MpcApi.h` (clsid2/mpc-hc, develop branch).
library;

/// MPC-HC API command codes carried in `COPYDATASTRUCT.dwData`.
///
/// `0x5xxxxxxx` codes are notifications MPC-HC sends to us; `0xAxxxxxxx` codes
/// are commands we send to MPC-HC.
abstract final class MpcCommand {
  // --- Notifications: MPC-HC -> host (pushed automatically) ---

  /// Handshake. Payload = MPC-HC's main window handle as a decimal string.
  static const int connect = 0x50000000;

  /// Load-state change. Payload = an [MpcLoadState] index.
  static const int state = 0x50000001;

  /// Play-state change. Payload = an [MpcPlayState] index.
  static const int playMode = 0x50000002;

  /// New file loaded. Payload = `title|author|description|file|duration`.
  static const int nowPlaying = 0x50000003;

  /// Current position, in seconds (float string).
  static const int currentPosition = 0x50000007;

  /// Position changed by a seek. Payload = new position in seconds.
  static const int notifySeek = 0x50000008;

  /// Playback reached the end of the stream. No payload.
  static const int notifyEndOfStream = 0x50000009;

  /// The instance is closing. No payload.
  static const int disconnect = 0x5000000B;

  // --- Commands: host -> MPC-HC ---

  /// Load a file into an existing instance. Payload = file path.
  static const int openFile = 0xA0000000;
  static const int stop = 0xA0000001;
  static const int playPause = 0xA0000003;
  static const int play = 0xA0000004;
  static const int pause = 0xA0000005;

  /// Seek to an absolute position. Payload = seconds.
  static const int setPosition = 0xA0002000;

  /// Ask MPC-HC to reply with [currentPosition].
  static const int getCurrentPosition = 0xA0003004;

  /// Ask MPC-HC to reply with [nowPlaying].
  static const int getNowPlaying = 0xA0003002;

  /// Seek relative to the current position. Payload = seconds (may be negative).
  static const int jumpOfNSeconds = 0xA0003005;

  /// Bump the volume up/down by MPC-HC's configured step.
  ///
  /// The slave API has **no** absolute set-volume, no mute, and no volume
  /// notification — see [MpcWmCommand] for the `WM_COMMAND` fallback.
  static const int increaseVolume = 0xA0004003;
  static const int decreaseVolume = 0xA0004004;
}

/// MPC-HC internal command IDs usable by sending `WM_COMMAND` (0x111) straight
/// to the player window via `PostMessage`/`SendMessage`.
///
/// Used for actions the slave API lacks (mute) and as a fallback for
/// volume/next/previous. These are the same IDs the web `command.html` path
/// forwards (e.g. `command.html?wm_command=909`). Confirmed reactive via a live
/// check before being relied upon.
abstract final class MpcWmCommand {
  /// `WM_COMMAND`.
  static const int message = 0x0111;

  static const int play = 887;
  static const int pause = 888;
  static const int playPause = 889;
  static const int stop = 890;
  static const int volumeUp = 907;
  static const int volumeDown = 908;
  static const int mute = 909;
  static const int previous = 919;
  static const int next = 920;
}

/// `MPC_LOADSTATE` (MpcApi.h). Index order matches the native enum.
enum MpcLoadState {
  closed, // MLS_CLOSED  = 0
  loading, // MLS_LOADING = 1
  loaded, // MLS_LOADED  = 2
  closing, // MLS_CLOSING = 3
  failing; // MLS_FAILING = 4

  static MpcLoadState? fromCode(int code) => //
      (code >= 0 && code < MpcLoadState.values.length) ? MpcLoadState.values[code] : null;
}

/// `MPC_PLAYSTATE` (MpcApi.h). Index order matches the native enum.
enum MpcPlayState {
  play, // PS_PLAY   = 0
  pause, // PS_PAUSE  = 1
  stop, // PS_STOP   = 2
  unused; // PS_UNUSED = 3

  static MpcPlayState? fromCode(int code) => //
      (code >= 0 && code < MpcPlayState.values.length) ? MpcPlayState.values[code] : null;

  /// MPC-HC is actively playing only in [MpcPlayState.play].
  bool get isPlaying => this == MpcPlayState.play;
}

/// Parsed `CMD_NOWPLAYING` payload (`title|author|description|file|duration`).
///
/// Note: [file] is MPC-HC's 4th field. In practice MPC-HC reports the full path
/// here, but the slave manager treats the path it launched the instance with as
/// the source of truth and only falls back to [file] when it looks absolute.
class MpcNowPlaying {
  final String title;
  final String author;
  final String description;
  final String file;
  final Duration duration;

  const MpcNowPlaying({
    required this.title,
    required this.author,
    required this.description,
    required this.file,
    required this.duration,
  });

  factory MpcNowPlaying.parse(String payload) {
    final parts = splitMpcFields(payload);
    String at(int i) => i < parts.length ? parts[i] : '';
    return MpcNowPlaying(
      title: at(0),
      author: at(1),
      description: at(2),
      file: at(3),
      duration: parseMpcSeconds(at(4)),
    );
  }

  @override
  String toString() => 'MpcNowPlaying(file: $file, duration: $duration, title: $title)';
}

/// Splits an MPC-HC pipe-delimited payload into its fields, honoring the
/// escaping rules: `\|` is a literal pipe and `\\` is a literal backslash.
///
/// Always returns at least one element (an empty payload yields `['']`).
List<String> splitMpcFields(String payload) {
  final fields = <String>[];
  final buffer = StringBuffer();

  for (int i = 0; i < payload.length; i++) {
    final char = payload[i];

    if (char == r'\' && i + 1 < payload.length) {
      final next = payload[i + 1];
      if (next == '|' || next == r'\') {
        buffer.write(next);
        i++; // consume the escaped character
        continue;
      }
    }

    if (char == '|') {
      fields.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(char);
    }
  }

  fields.add(buffer.toString());
  return fields;
}

/// Parses an MPC-HC seconds value (e.g. `"12"`, `"12.345"`) into a [Duration].
///
/// Returns [Duration.zero] for empty, malformed, or negative input.
Duration parseMpcSeconds(String raw) {
  final value = double.tryParse(raw.trim());
  if (value == null || value.isNaN || value.isInfinite || value < 0) return Duration.zero;
  return Duration(milliseconds: (value * 1000).round());
}
