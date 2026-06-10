import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../models/players/mediastatus.dart';
import '../../../utils/logging.dart';
import '../../../utils/path.dart';
import '../../../utils/time.dart';
import 'mpc_slave_bridge.dart';
import 'mpc_slave_payload.dart';

/// One MPC-HC window the app launched and controls over slave mode.
class MpcSlaveInstance {
  /// MPC-HC's main window handle (the target for commands).
  final int hwnd;

  /// Currently loaded file (seeded from the launch path, refined by NOWPLAYING).
  String filePath;

  Duration position;
  Duration duration;
  bool isPlaying;

  /// Volume / mute are only known for the web-interface-owning instance; for
  /// every other instance these stay at their defaults (the UI hides the
  /// slider for non-owners).
  int volumeLevel;
  bool isMuted;

  MpcLoadState loadState;
  DateTime lastActivityAt;

  MpcSlaveInstance({required this.hwnd, required this.filePath})
      : position = Duration.zero,
        duration = Duration.zero,
        isPlaying = false,
        volumeLevel = 0,
        isMuted = false,
        loadState = MpcLoadState.loading,
        lastActivityAt = now;

  MediaStatus toStatus() => MediaStatus(
        filePath: filePath,
        currentPosition: position,
        totalDuration: duration,
        isPlaying: isPlaying,
        volumeLevel: volumeLevel,
        isMuted: isMuted,
      );
}

/// Tracks every app-launched MPC-HC slave instance, routes the push
/// notifications that arrive through [MpcSlaveBridge], and surfaces the
/// **last-active** instance to the rest of the app via [statusStream].
///
/// Multi-instance is handled internally; the UI shows a single (last-active)
/// player. Only the first-connected, still-running instance owns MPC-HC's web
/// interface, so only it can report a real volume/mute level — see
/// [activeInstanceHasVolumeReadback].
class MpcSlaveManager {
  MpcSlaveManager({this.webInterfacePort = 13579});

  /// Port MPC-HC's web interface listens on (used only for owner volume read).
  final int webInterfacePort;

  final MpcSlaveBridge _bridge = MpcSlaveBridge.instance;
  StreamSubscription<MpcIncomingMessage>? _bridgeSub;

  final Map<int, MpcSlaveInstance> _instances = {};
  final List<int> _connectOrder = []; // hwnds in connection order (owner = first alive)
  final List<String> _pendingFiles = []; // launched files awaiting CMD_CONNECT (FIFO)
  int _lastActiveHwnd = 0;

  final StreamController<MediaStatus> _statusController = StreamController<MediaStatus>.broadcast();
  final StreamController<void> _changeController = StreamController<void>.broadcast();
  Timer? _ownerVolumeTimer;
  Timer? _positionTimer;

  /// Status of the last-active instance; updated on every relevant push.
  Stream<MediaStatus> get statusStream => _statusController.stream;

  /// Fires when the set of instances, the active instance, or the owner changes
  /// (so listeners can refresh connection/volume-affordance state).
  Stream<void> get changes => _changeController.stream;

  bool get hasInstances => _instances.isNotEmpty;
  int get instanceCount => _instances.length;
  MpcSlaveInstance? get activeInstance => _instances[_lastActiveHwnd];
  MediaStatus? get lastStatus => activeInstance?.toStatus();

  /// The web-interface-owning instance = the first-connected one still alive.
  int get _ownerHwnd => _connectOrder.firstWhere(_instances.containsKey, orElse: () => 0);

  /// True only when the active instance is the owner, i.e. when a real volume
  /// level/mute is available for the volume slider.
  bool get activeInstanceHasVolumeReadback => _lastActiveHwnd != 0 && _lastActiveHwnd == _ownerHwnd;

  /// Ensures the receive bridge is running. Returns false if it can't start.
  Future<bool> ensureStarted() async {
    final hwnd = await _bridge.start();
    if (hwnd == null) return false;
    _bridgeSub ??= _bridge.incoming.listen(_onMessage);
    return true;
  }

  /// Launches `exePath /slave <hostHwnd> "<file>"` and begins tracking it.
  /// Returns false if the bridge or process could not be started.
  Future<bool> launch(String exePath, PathString file) async {
    if (!await ensureStarted()) return false;
    try {
      await Process.start(
        exePath,
        ['/slave', _bridge.hostHwnd.toString(), file.path],
        mode: ProcessStartMode.detached,
      );
      _pendingFiles.add(file.path);
      logTrace('Launched MPC-HC slave for "${file.path}" (host hwnd: ${_bridge.hostHwnd})');
      return true;
    } catch (e, st) {
      logErr('Failed to launch MPC-HC in slave mode', e, st);
      return false;
    }
  }

  // --- Incoming notification routing -------------------------------------

  void _onMessage(MpcIncomingMessage msg) {
    switch (msg.command) {
      case MpcCommand.connect:
        _onConnect(msg.senderHwnd);
      case MpcCommand.nowPlaying:
        _onNowPlaying(msg.senderHwnd, msg.payload);
      case MpcCommand.playMode:
        _onPlayMode(msg.senderHwnd, msg.payload);
      case MpcCommand.state:
        _onState(msg.senderHwnd, msg.payload);
      case MpcCommand.currentPosition:
      case MpcCommand.notifySeek:
        _onPosition(msg.senderHwnd, msg.payload);
      case MpcCommand.notifyEndOfStream:
        _onEndOfStream(msg.senderHwnd);
      case MpcCommand.disconnect:
        _onDisconnect(msg.senderHwnd);
    }
  }

  void _onConnect(int hwnd) {
    if (hwnd == 0 || _instances.containsKey(hwnd)) return;

    final file = _pendingFiles.isNotEmpty ? _pendingFiles.removeAt(0) : '';
    _instances[hwnd] = MpcSlaveInstance(hwnd: hwnd, filePath: file);
    _connectOrder.add(hwnd);
    logTrace('MPC-HC slave connected: hwnd=$hwnd file="$file" (instances: ${_instances.length})');

    _setActive(hwnd);
    // Pull the initial file/duration/position rather than wait for the next push.
    _bridge.send(hwnd, MpcCommand.getNowPlaying);
    _bridge.send(hwnd, MpcCommand.getCurrentPosition);
    _changeController.add(null);
    _emitActiveStatus();
  }

  void _onNowPlaying(int hwnd, String payload) {
    final inst = _instances[hwnd];
    if (inst == null) return;
    final np = MpcNowPlaying.parse(payload);
    if (_looksAbsolute(np.file)) inst.filePath = np.file;
    if (np.duration > Duration.zero) inst.duration = np.duration;
    _touch(hwnd);
  }

  void _onPlayMode(int hwnd, String payload) {
    final inst = _instances[hwnd];
    if (inst == null) return;
    final state = MpcPlayState.fromCode(int.tryParse(payload.trim()) ?? -1);
    if (state != null) inst.isPlaying = state.isPlaying;
    _touch(hwnd);
    _updatePositionPolling();
  }

  void _onState(int hwnd, String payload) {
    final inst = _instances[hwnd];
    if (inst == null) return;
    final state = MpcLoadState.fromCode(int.tryParse(payload.trim()) ?? -1);
    if (state != null) inst.loadState = state;
    // Don't promote the active instance for a bare load-state change.
  }

  void _onPosition(int hwnd, String payload) {
    final inst = _instances[hwnd];
    if (inst == null) return;
    inst.position = parseMpcSeconds(payload);
    _touch(hwnd);
  }

  void _onEndOfStream(int hwnd) {
    final inst = _instances[hwnd];
    if (inst == null) return;
    // Snap to the end so progress crosses the watched threshold.
    if (inst.duration > Duration.zero) inst.position = inst.duration;
    inst.isPlaying = false;
    _touch(hwnd);
    _updatePositionPolling();
  }

  void _onDisconnect(int hwnd) {
    if (!_instances.containsKey(hwnd)) return;
    _instances.remove(hwnd);
    _connectOrder.remove(hwnd);
    logTrace('MPC-HC slave disconnected: hwnd=$hwnd (instances: ${_instances.length})');

    if (_lastActiveHwnd == hwnd) _setActive(_mostRecentlyActiveHwnd());
    _updateOwnerVolumePolling();
    _changeController.add(null);
    _emitActiveStatus();
  }

  /// Drops instances whose window is gone (e.g. MPC-HC crashed without sending
  /// CMD_DISCONNECT). Call when the process monitor reports an MPC-HC exit.
  void pruneDeadInstances() {
    final dead = _instances.keys.where((h) => !_bridge.isInstanceAlive(h)).toList();
    for (final hwnd in dead) {
      _onDisconnect(hwnd);
    }
  }

  // --- Active / owner bookkeeping ----------------------------------------

  void _touch(int hwnd) {
    _instances[hwnd]?.lastActivityAt = now;
    _setActive(hwnd);
    if (hwnd == _lastActiveHwnd) _emitActiveStatus();
  }

  void _setActive(int hwnd) {
    if (_lastActiveHwnd == hwnd) return;
    _lastActiveHwnd = hwnd;
    _updateOwnerVolumePolling();
    _updatePositionPolling();
    _changeController.add(null);
  }

  int _mostRecentlyActiveHwnd() {
    MpcSlaveInstance? best;
    for (final inst in _instances.values) {
      if (best == null || inst.lastActivityAt.isAfter(best.lastActivityAt)) best = inst;
    }
    return best?.hwnd ?? 0;
  }

  void _emitActiveStatus() {
    final status = lastStatus;
    if (status != null && !_statusController.isClosed) _statusController.add(status);
  }

  // --- Owner volume readback (the only remaining, scoped HTTP use) --------

  void _updateOwnerVolumePolling() {
    final shouldPoll = activeInstanceHasVolumeReadback;
    if (shouldPoll && _ownerVolumeTimer == null) {
      _ownerVolumeTimer = Timer.periodic(const Duration(seconds: 1), (_) => _refreshOwnerVolume());
      _refreshOwnerVolume();
    } else if (!shouldPoll && _ownerVolumeTimer != null) {
      _ownerVolumeTimer!.cancel();
      _ownerVolumeTimer = null;
    }
  }

  Future<void> _refreshOwnerVolume() async {
    final hwnd = _ownerHwnd;
    final inst = _instances[hwnd];
    if (inst == null) return;
    try {
      final response = await http.get(Uri.parse('http://localhost:$webInterfacePort/variables.html')).timeout(const Duration(seconds: 1));
      if (response.statusCode != 200) return;
      final vars = <String, String>{};
      for (final match in RegExp(r'<p id="([^"]+)">([^<]*)</p>').allMatches(response.body)) {
        final key = match.group(1);
        final value = match.group(2);
        if (key != null && value != null) vars[key] = value;
      }
      final volume = int.tryParse(vars['volumelevel'] ?? '');
      if (volume != null) inst.volumeLevel = volume;
      inst.isMuted = vars['muted'] == '1';
      if (_lastActiveHwnd == hwnd) _emitActiveStatus();
    } catch (_) {
      // web interface disabled/unreachable: slider stays hidden
    }
  }

  // --- Position requests --------------------------------------------------
  //
  // MPC-HC does NOT push CMD_CURRENTPOSITION on its own (verified live), so
  // while the active instance is playing we request it on a light timer. This
  // is a tiny per-window WM_COPYDATA message — far cheaper than the old
  // whole-status HTTP poll — and stops when paused (position isn't changing).

  void _updatePositionPolling() {
    final inst = activeInstance;
    final shouldPoll = inst != null && inst.isPlaying;
    if (shouldPoll && _positionTimer == null) {
      _positionTimer = Timer.periodic(const Duration(seconds: 1), (_) => _requestPosition());
      _requestPosition();
    } else if (!shouldPoll && _positionTimer != null) {
      _positionTimer!.cancel();
      _positionTimer = null;
    }
  }

  void _requestPosition() {
    if (_lastActiveHwnd != 0) _bridge.send(_lastActiveHwnd, MpcCommand.getCurrentPosition);
  }

  // --- Commands (target the last-active instance) ------------------------

  void play() => _send(MpcCommand.play);
  void pause() => _send(MpcCommand.pause);
  void togglePlayPause() => _send(MpcCommand.playPause);
  void stop() => _send(MpcCommand.stop);
  void seek(int seconds) => _send(MpcCommand.setPosition, '$seconds');

  // No slave-API equivalent: fall back to WM_COMMAND on the instance window.
  void next() => _sendWm(MpcWmCommand.next);
  void previous() => _sendWm(MpcWmCommand.previous);
  void volumeUp() => _sendWm(MpcWmCommand.volumeUp);
  void volumeDown() => _sendWm(MpcWmCommand.volumeDown);
  void mute() => _sendWm(MpcWmCommand.mute);

  /// Absolute volume only works for the owner (we need its current level to
  /// know how many steps to send); no-op otherwise.
  void setVolume(int level) {
    final inst = activeInstance;
    if (inst == null || !activeInstanceHasVolumeReadback) return;
    final difference = level - inst.volumeLevel;
    final steps = (difference.abs() / 5).ceil(); // MPC-HC's default volume step
    for (var i = 0; i < steps; i++) {
      _sendWm(difference > 0 ? MpcWmCommand.volumeUp : MpcWmCommand.volumeDown);
    }
    // The owner-volume timer will reconcile the displayed level shortly.
  }

  void _send(int command, [String payload = '']) {
    if (_lastActiveHwnd == 0) return;
    _bridge.send(_lastActiveHwnd, command, payload);
  }

  void _sendWm(int commandId) {
    if (_lastActiveHwnd == 0) return;
    _bridge.sendWmCommand(_lastActiveHwnd, commandId);
  }

  // --- Helpers / teardown ------------------------------------------------

  bool _looksAbsolute(String path) => path.length > 2 && (path[1] == ':' || path.startsWith(r'\\'));

  Future<void> dispose() async {
    _ownerVolumeTimer?.cancel();
    _ownerVolumeTimer = null;
    _positionTimer?.cancel();
    _positionTimer = null;
    await _bridgeSub?.cancel();
    _bridgeSub = null;
    _instances.clear();
    _connectOrder.clear();
    _pendingFiles.clear();
    _lastActiveHwnd = 0;
    if (!_statusController.isClosed) await _statusController.close();
    if (!_changeController.isClosed) await _changeController.close();
    await _bridge.stop();
  }
}
