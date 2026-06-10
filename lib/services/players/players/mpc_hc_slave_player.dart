import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../models/players/mediastatus.dart';
import '../../../widgets/svg.dart' as icon show mpcHc;
import '../player.dart';
import '../slave/mpc_slave_manager.dart';

/// A [MediaPlayer] facade over [MpcSlaveManager] that represents the currently
/// active MPC-HC slave instance.
///
/// This lets the existing `PlayerManager` → `MediaPlayerMonitorService` → UI
/// pipeline drive slave mode without changes: status is the manager's
/// last-active stream and commands target the last-active instance. It is
/// push-based, so `PlayerManager` skips its polling connection-check.
class MpcSlavePlayer extends MediaPlayer {
  MpcSlavePlayer(this._manager);

  final MpcSlaveManager _manager;

  @override
  bool get isPushBased => true;

  @override
  Widget get iconWidget => icon.mpcHc;

  @override
  Stream<MediaStatus> get statusStream => _manager.statusStream;

  @override
  Future<bool> connect() => _manager.ensureStarted();

  @override
  void disconnect() {}

  @override
  void dispose() {}

  /// Liveness for the manager's connection checks: true while any instance is
  /// tracked. Never throws.
  @override
  Future<bool> pollStatus() async => _manager.hasInstances;

  @override
  Future<void> play() async => _manager.play();

  @override
  Future<void> pause() async => _manager.pause();

  @override
  Future<void> togglePlayPause() async => _manager.togglePlayPause();

  @override
  Future<void> setVolume(int level) async => _manager.setVolume(level);

  // MPC-HC's mute (WM_COMMAND 909) is a toggle, so mute/unmute send the same
  @override
  Future<void> mute() async => _manager.mute();

  @override
  Future<void> unmute() async => _manager.mute();

  @override
  Future<void> nextVideo() async => _manager.next();

  @override
  Future<void> previousVideo() async => _manager.previous();

  @override
  Future<void> seek(int seconds) async => _manager.seek(seconds);
}
