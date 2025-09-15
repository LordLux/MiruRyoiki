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
  
  // Connection management
  Future<bool> connect();
  void disconnect();
  void dispose();
}

