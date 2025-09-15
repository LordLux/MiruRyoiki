import 'dart:io';
import 'dart:async';
import 'services/players/player_manager.dart';
import 'services/players/factory.dart';
import 'models/players/mediastatus.dart';

/// Simple console application to test the media player integration
/// Run this with: dart run lib/player_test.dart
void main() async {
  print('🎵 Media Player Integration Test');
  print('================================');
  
  final playerManager = PlayerManager();
  
  // Set up listeners for status updates
  final statusSubscription = playerManager.statusStream.listen((status) {
    _printMediaStatus(status);
  });
  
  final connectionSubscription = playerManager.connectionStream.listen((connectionStatus) {
    _printConnectionStatus(connectionStatus);
  });
  
  print('\n📡 Starting auto-discovery...');
  
  // Try to auto-connect
  final connected = await playerManager.autoConnect();
  
  if (!connected) {
    print('❌ No media players found!');
    print('\n💡 Make sure you have VLC or MPC-HC running with web interface enabled:');
    print('   VLC: Tools → Preferences → Interface → Main interfaces → Check "Web"');
    print('   MPC-HC: View → Options → Player → Web Interface → Check "Listen on port"');
    print('   Then restart the player and try again.');
    
    // Try manual connections
    print('\n🔍 Trying manual connections...');
    await _tryManualConnections(playerManager);
  }
  
  if (playerManager.isConnected) {
    print('\n🎮 Player connected! Try these commands:');
    await _showInteractiveCommands(playerManager);
  }
  
  // Cleanup
  await statusSubscription.cancel();
  await connectionSubscription.cancel();
  playerManager.dispose();
  
  print('\n👋 Goodbye!');
}

void _printMediaStatus(MediaStatus status) {
  print('\n📺 MEDIA STATUS UPDATE:');
  print('   File: ${status.filePath.isNotEmpty ? status.filePath : 'No file loaded'}');
  
  if (status.totalDuration.inSeconds > 0) {
    final progress = (status.progress * 100).toStringAsFixed(1);
    final currentTime = _formatDuration(status.currentPosition);
    final totalTime = _formatDuration(status.totalDuration);
    
    print('   Duration: $currentTime / $totalTime ($progress%)');
    print('   Status: ${status.isPlaying ? '▶️  PLAYING' : '⏸️  PAUSED'}');
    print('   Volume: ${status.volumeLevel}% ${status.isMuted ? '🔇 (MUTED)' : '🔊'}');
  } else {
    print('   Status: ${status.isPlaying ? '▶️  PLAYING' : '⏸️  STOPPED/PAUSED'}');
    print('   Volume: ${status.volumeLevel}% ${status.isMuted ? '🔇 (MUTED)' : '🔊'}');
  }
}

void _printConnectionStatus(PlayerConnectionStatus connectionStatus) {
  switch (connectionStatus.state) {
    case PlayerConnectionState.disconnected:
      print('🔌 DISCONNECTED from player');
      break;
    case PlayerConnectionState.connecting:
      print('🔄 CONNECTING to player...');
      break;
    case PlayerConnectionState.connected:
      print('✅ CONNECTED to player successfully!');
      break;
    case PlayerConnectionState.error:
      print('❌ CONNECTION ERROR: ${connectionStatus.message}');
      break;
  }
}

Future<void> _tryManualConnections(PlayerManager playerManager) async {
  print('   Trying VLC with password (localhost:8080)...');
  bool vlcConnected = await playerManager.connectToPlayer(PlayerType.vlc, config: {'password': 'miruryoiki'});
  if (vlcConnected) return;
  
  print('   Trying VLC without password (localhost:8080)...');
  vlcConnected = await playerManager.connectToPlayer(PlayerType.vlc);
  if (vlcConnected) return;
  
  print('   Trying MPC-HC (localhost:13579)...');
  bool mpcConnected = await playerManager.connectToPlayer(PlayerType.mpcHc);
  if (mpcConnected) return;
  
  // Try VLC with different ports
  for (final port in [8080, 8081, 9090]) {
    print('   Trying VLC on port $port with password...');
    bool connected = await playerManager.connectToPlayer(
      PlayerType.vlc, 
      config: {'port': port, 'password': 'miruryoiki'}
    );
    if (connected) return;
    
    print('   Trying VLC on port $port without password...');
    connected = await playerManager.connectToPlayer(
      PlayerType.vlc, 
      config: {'port': port}
    );
    if (connected) return;
  }
  
  print('   ❌ Could not connect to any player');
}

Future<void> _showInteractiveCommands(PlayerManager playerManager) async {
  print('   Commands:');
  print('   - Press SPACE or P: Toggle Play/Pause');
  print('   - Press M: Toggle Mute');
  print('   - Press +: Volume Up');
  print('   - Press -: Volume Down');
  print('   - Press Q: Quit');
  print('   - Press H: Show this help');
  
  // Enable raw mode for immediate key input
  stdin.echoMode = false;
  stdin.lineMode = false;
  
  await for (final input in stdin) {
    final key = String.fromCharCode(input.first).toLowerCase();
    
    switch (key) {
      case ' ':
      case 'p':
        print('\n🎵 Toggling play/pause...');
        await playerManager.togglePlayPause();
        break;
        
      case 'm':
        print('\n🔇 Toggling mute...');
        await playerManager.mute();
        break;
        
      case '+':
      case '=':
        print('\n🔊 Volume up...');
        await playerManager.volumeUp();
        break;
        
      case '-':
        print('\n🔉 Volume down...');
        await playerManager.volumeDown();
        break;
        
      case 'h':
        print('\n🎮 Commands:');
        print('   - SPACE/P: Play/Pause  - M: Mute  - +/-: Volume  - Q: Quit');
        break;
        
      case 'q':
        print('\n👋 Quitting...');
        return;
        
      default:
        print('\n❓ Unknown command "$key" - Press H for help');
    }
  }
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  } else {
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
