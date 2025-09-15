// ignore_for_file: avoid_print

import 'dart:async';
import '../lib/services/players/player_manager.dart';
import '../lib/config/player_config.dart';

/// Automated command testing - runs through all commands automatically
/// Run with: dart run lib/auto_test_commands.dart
void main() async {
  print('🤖 Automated Media Player Command Test');
  print('======================================');
  
  // Load configuration
  await PlayerConfig.load();
  PlayerConfig.printConfig();
  
  final playerManager = PlayerManager();
  
  // Set up listeners
  playerManager.statusStream.listen((status) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    print('[$timestamp] 📺 STATUS: ${status.isPlaying ? '▶️  PLAYING' : '⏸️  PAUSED'} | Volume: ${status.volumeLevel}% ${status.isMuted ? '🔇' : '🔊'}');
  });
  
  playerManager.connectionStream.listen((connectionStatus) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    
    switch (connectionStatus.state) {
      case PlayerConnectionState.connected:
        print('[$timestamp] ✅ CONNECTED!');
        break;
      case PlayerConnectionState.error:
        print('[$timestamp] ❌ ERROR: ${connectionStatus.message}');
        break;
      default:
        break;
    }
  });
  
  print('\n🔍 Connecting to media player...');
  
  // Try to connect
  final connected = await playerManager.autoConnect();
  
  if (!connected) {
    print('❌ No media players found!');
    print('💡 Please start VLC or MPC-HC with web interface enabled and load a video');
    playerManager.dispose();
    return;
  }
  
  print('\n🎮 Starting automated command test...');
  print('💡 Make sure you have a video loaded in your media player!\n');
  
  await _runCommandTests(playerManager);
  
  print('\n✅ All command tests completed!');
  playerManager.dispose();
}

Future<void> _runCommandTests(PlayerManager playerManager) async {
  final tests = [
    () => _testCommand('PAUSE', () => playerManager.pause()),
    () => _testWait(2),
    () => _testCommand('PLAY', () => playerManager.play()),
    () => _testWait(2),
    () => _testCommand('TOGGLE PLAY/PAUSE', () => playerManager.togglePlayPause()),
    () => _testWait(2),
    () => _testCommand('TOGGLE PLAY/PAUSE', () => playerManager.togglePlayPause()),
    () => _testWait(2),
    () => _testCommand('SET VOLUME 30%', () => playerManager.setVolume(30)),
    () => _testWait(2),
    () => _testCommand('SET VOLUME 70%', () => playerManager.setVolume(70)),
    () => _testWait(2),
    () => _testCommand('MUTE', () => playerManager.mute()),
    () => _testWait(2),
    () => _testCommand('UNMUTE', () => playerManager.unmute()),
    () => _testWait(2),
    () => _testCommand('SET VOLUME 50%', () => playerManager.setVolume(50)),
    () => _testWait(1),
  ];
  
  for (final test in tests) {
    await test();
  }
}

Future<void> _testCommand(String commandName, Future<void> Function() command) async {
  final timestamp = DateTime.now().toString().substring(11, 19);
  print('[$timestamp] 🧪 Testing: $commandName');
  
  try {
    await command();
    print('[$timestamp] ✅ Command sent successfully');
  } catch (e) {
    print('[$timestamp] ❌ Command failed: $e');
  }
}

Future<void> _testWait(int seconds) async {
  print('   ⏱️  Waiting ${seconds}s for status update...');
  await Future.delayed(Duration(seconds: seconds));
}
