import 'dart:async';
import '../lib/services/players/player_manager.dart';
import '../lib/config/player_config.dart';

/// Improved volume testing - tests specific volume issues
/// Run with: dart run lib/test_volume_fix.dart
void main() async {
  print('🔊 Volume Fix Testing Tool');
  print('==========================');
  
  // Load configuration
  await PlayerConfig.load();
  
  final playerManager = PlayerManager();
  
  // Set up listeners with detailed volume info
  playerManager.statusStream.listen((status) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    print('[$timestamp] 📊 Volume: ${status.volumeLevel}% | Muted: ${status.isMuted ? 'YES' : 'NO'} | Playing: ${status.isPlaying ? 'YES' : 'NO'}');
  });
  
  playerManager.connectionStream.listen((connectionStatus) {
    if (connectionStatus.isConnected) {
      print('✅ Connected to player!');
    } else if (connectionStatus.hasError) {
      print('❌ Error: ${connectionStatus.message}');
    }
  });
  
  print('🔍 Connecting to media player...');
  
  final connected = await playerManager.autoConnect();
  
  if (!connected) {
    print('❌ No media players found!');
    playerManager.dispose();
    return;
  }
  
  print('\n🧪 Testing volume fixes...\n');
  
  await _runVolumeTests(playerManager);
  
  print('\n✅ Volume testing completed!');
  playerManager.dispose();
}

Future<void> _runVolumeTests(PlayerManager playerManager) async {
  // Wait for initial status
  await Future.delayed(Duration(seconds: 2));
  
  final tests = [
    () => _testVolume(playerManager, 'SET VOLUME 25%', () => playerManager.setVolume(25)),
    () => _testWait(3),
    () => _testVolume(playerManager, 'SET VOLUME 50%', () => playerManager.setVolume(50)),
    () => _testWait(3),
    () => _testVolume(playerManager, 'SET VOLUME 75%', () => playerManager.setVolume(75)),
    () => _testWait(3),
    () => _testVolume(playerManager, 'VOLUME UP (+5)', () => playerManager.volumeUp(5)),
    () => _testWait(3),
    () => _testVolume(playerManager, 'VOLUME DOWN (-10)', () => playerManager.volumeDown(10)),
    () => _testWait(3),
    () => _testVolume(playerManager, 'MUTE', () => playerManager.mute()),
    () => _testWait(3),
    () => _testVolume(playerManager, 'UNMUTE', () => playerManager.unmute()),
    () => _testWait(3),
    () => _testVolume(playerManager, 'SET VOLUME 40%', () => playerManager.setVolume(40)),
    () => _testWait(2),
  ];
  
  for (final test in tests) {
    await test();
  }
}

Future<void> _testVolume(PlayerManager playerManager, String testName, Future<void> Function() command) async {
  final timestamp = DateTime.now().toString().substring(11, 19);
  
  // Get current volume before test
  final beforeVolume = playerManager.lastStatus?.volumeLevel ?? 0;
  final beforeMuted = playerManager.lastStatus?.isMuted ?? false;
  
  print('[$timestamp] 🧪 $testName');
  print('   Before: ${beforeVolume}% ${beforeMuted ? '🔇' : '🔊'}');
  
  try {
    await command();
    print('   ✅ Command sent');
  } catch (e) {
    print('   ❌ Command failed: $e');
  }
}

Future<void> _testWait(int seconds) async {
  print('   ⏱️  Waiting ${seconds}s for status update...');
  await Future.delayed(Duration(seconds: seconds));
}
