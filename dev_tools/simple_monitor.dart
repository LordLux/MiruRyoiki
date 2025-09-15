// ignore_for_file: avoid_print

import 'dart:async';
import '../lib/services/players/player_manager.dart';
import '../lib/services/players/factory.dart';
import '../lib/config/player_config.dart';

/// Simple monitoring application that just prints status updates
/// Run this with: dart run lib/simple_monitor.dart
void main() async {
  print('🎵 Simple Media Player Monitor');
  print('==============================');
  
  // Load configuration
  await PlayerConfig.load();
  PlayerConfig.printConfig();
  print('');
  
  final playerManager = PlayerManager();
  
  // Set up listeners with simple print statements
  playerManager.statusStream.listen((status) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    print('[$timestamp] 📺 ${status.isPlaying ? 'PLAYING' : 'PAUSED'}: ${status.filePath}');
    
    if (status.totalDuration.inSeconds > 0) {
      final progress = (status.progress * 100).toStringAsFixed(1);
      print('[$timestamp] ⏱️  Progress: $progress% | Volume: ${status.volumeLevel}%');
    }
  });
  
  playerManager.connectionStream.listen((connectionStatus) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    
    switch (connectionStatus.state) {
      case PlayerConnectionState.disconnected:
        print('[$timestamp] 🔌 DISCONNECTED');
        break;
      case PlayerConnectionState.connecting:
        print('[$timestamp] 🔄 CONNECTING...');
        break;
      case PlayerConnectionState.connected:
        print('[$timestamp] ✅ CONNECTED!');
        break;
      case PlayerConnectionState.error:
        print('[$timestamp] ❌ ERROR: ${connectionStatus.message}');
        break;
    }
  });
  
  print('\n🔍 Searching for media players...');
  
  // Try to connect
  final connected = await playerManager.autoConnect();
  
  if (!connected) {
    print('❌ No players found. Trying specific players...');
    
    // Try VLC with configured password
    final vlcConfig = PlayerConfig.vlc;
    print('🎯 Trying VLC with password...');
    if (await playerManager.connectToPlayer(PlayerType.vlc, config: vlcConfig)) {
      print('✅ Connected to VLC with password!');
    } else {
      print('❌ VLC with password not available');
      
      // Try VLC without password
      print('🎯 Trying VLC without password...');
      if (await playerManager.connectToPlayer(PlayerType.vlc, config: {
        'host': vlcConfig['host'],
        'port': vlcConfig['port'],
        'password': '',
      })) {
        print('✅ Connected to VLC without password!');
      } else {
        print('❌ VLC not available');
        
        // Try MPC-HC
        print('🎯 Trying MPC-HC...');
        if (await playerManager.connectToPlayer(PlayerType.mpcHc, config: PlayerConfig.mpcHc)) {
          print('✅ Connected to MPC-HC!');
        } else {
          print('❌ MPC-HC not available');
        }
      }
    }
  }
  
  if (playerManager.isConnected) {
    print('\n📡 Monitoring started! Status updates will appear below...');
    print('🎮 Now play/pause/change volume in your media player to see updates');
    print('⏹️  Press Ctrl+C to stop monitoring\n');
    
    // Keep the program running to monitor
    await Future.delayed(Duration(days: 1)); // Run indefinitely
  } else {
    print('\n💡 Setup Instructions:');
    print('1. Open VLC Media Player:');
    print('   - Go to Tools → Preferences → Show All Settings');
    print('   - Navigate to Interface → Main interfaces');
    print('   - Check "Web" checkbox and restart VLC');
    print('   - Default port: 8080');
    print('');
    print('2. OR open MPC-HC:');
    print('   - Go to View → Options → Player → Web Interface');
    print('   - Check "Listen on port" and restart MPC-HC');
    print('   - Default port: 13579');
    print('');
    print('Then run this program again!');
  }
  
  // Cleanup
  playerManager.dispose();
}
