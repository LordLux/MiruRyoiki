import 'package:flutter/widgets.dart';
import '../../models/players/mediastatus.dart';

abstract class MediaPlayer {
  // Status information
  Stream<MediaStatus> get statusStream;
  
  // Controls
  Future<void> play();
  Future<void> pause();
  Future<void> togglePlayPause();
  Future<void> setVolume(int level);
  Future<void> mute();
  Future<void> unmute();
  
  // Navigation controls
  Future<void> nextVideo();
  Future<void> previousVideo();
  Future<void> seek(int seconds);
  
  // Connection management
  Future<bool> connect();
  void disconnect();
  void dispose();
  
  // Force immediate status update
  Future<void> pollStatus();

  /// Widget for displaying the player's icon
  Widget get iconWidget;
}

