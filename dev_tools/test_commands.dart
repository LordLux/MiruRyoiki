// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import '../lib/services/players/player_manager.dart';
import '../lib/config/player_config.dart';

/// Interactive command testing tool for media players
/// Run with: dart run lib/test_commands.dart
void main() async {
  print('🎮 Media Player Command Testing Tool');
  print('===================================');
  
  // Load configuration
  await PlayerConfig.load();
  PlayerConfig.printConfig();
  
  final playerManager = PlayerManager();
  
  // Set up listeners
  final statusSubscription = playerManager.statusStream.listen((status) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    print('\n[$timestamp] 📺 STATUS UPDATE:');
    print('   File: ${status.filePath.isNotEmpty ? status.filePath : 'No file loaded'}');
    print('   State: ${status.isPlaying ? '▶️  PLAYING' : '⏸️  PAUSED'}');
    print('   Volume: ${status.volumeLevel}% ${status.isMuted ? '🔇 (MUTED)' : '🔊'}');
    if (status.totalDuration.inSeconds > 0) {
      final progress = (status.progress * 100).toStringAsFixed(1);
      print('   Progress: $progress% (${_formatDuration(status.currentPosition)} / ${_formatDuration(status.totalDuration)})');
    }
    print('');
    _showPrompt();
  });
  
  final connectionSubscription = playerManager.connectionStream.listen((connectionStatus) {
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
  
  print('\n🔍 Connecting to media player...');
  
  // Try to connect
  final connected = await playerManager.autoConnect();
  
  if (!connected) {
    print('❌ No media players found!');
    print('💡 Please start VLC or MPC-HC with web interface enabled');
    await _cleanup(statusSubscription, connectionSubscription, playerManager);
    return;
  }
  
  print('\n🎮 Ready to test commands!');
  print('📝 Load a video file in your media player first, then try these commands:\n');
  _showHelp();
  
  // Command loop
  await _commandLoop(playerManager);
  
  await _cleanup(statusSubscription, connectionSubscription, playerManager);
}

void _showHelp() {
  print('Available commands:');
  print('  play      - Start playback');
  print('  pause     - Pause playback');
  print('  toggle    - Toggle play/pause');
  print('  vol <0-100> - Set volume (e.g., "vol 50")');
  print('  vol+      - Volume up');
  print('  vol-      - Volume down');
  print('  mute      - Mute audio');
  print('  unmute    - Unmute audio');
  print('  status    - Show current status');
  print('  help      - Show this help');
  print('  quit      - Exit program');
  print('');
}

void _showPrompt() {
  stdout.write('🎮 Command > ');
}

Future<void> _commandLoop(PlayerManager playerManager) async {
  _showPrompt();
  
  await for (final line in stdin.transform(utf8.decoder).transform(LineSplitter())) {
    final command = line.trim().toLowerCase();
    final parts = command.split(' ');
    final cmd = parts[0];
    
    final timestamp = DateTime.now().toString().substring(11, 19);
    
    try {
      switch (cmd) {
        case 'play':
          print('[$timestamp] 🎵 Sending PLAY command...');
          await playerManager.play();
          break;
          
        case 'pause':
          print('[$timestamp] ⏸️  Sending PAUSE command...');
          await playerManager.pause();
          break;
          
        case 'toggle':
          print('[$timestamp] ⏯️  Sending TOGGLE PLAY/PAUSE command...');
          await playerManager.togglePlayPause();
          break;
          
        case 'vol':
          if (parts.length > 1) {
            final volume = int.tryParse(parts[1]);
            if (volume != null && volume >= 0 && volume <= 100) {
              print('[$timestamp] 🔊 Setting volume to $volume%...');
              await playerManager.setVolume(volume);
            } else {
              print('❌ Invalid volume. Use a number between 0-100');
            }
          } else {
            print('❌ Please specify volume level (e.g., "vol 50")');
          }
          break;
          
        case 'vol+':
          print('[$timestamp] 🔊 Volume up...');
          await playerManager.volumeUp();
          break;
          
        case 'vol-':
          print('[$timestamp] 🔉 Volume down...');
          await playerManager.volumeDown();
          break;
          
        case 'mute':
          print('[$timestamp] 🔇 Sending MUTE command...');
          await playerManager.mute();
          break;
          
        case 'unmute':
          print('[$timestamp] 🔊 Sending UNMUTE command...');
          await playerManager.unmute();
          break;
          
        case 'status':
          print('[$timestamp] 📊 Requesting current status...');
          // Status will be shown automatically via the listener
          break;
          
        case 'help':
          _showHelp();
          break;
          
        case 'quit':
        case 'exit':
        case 'q':
          print('👋 Exiting...');
          return;
          
        case '':
          // Empty command, just show prompt again
          break;
          
        default:
          print('❓ Unknown command: "$cmd"');
          print('💡 Type "help" to see available commands');
      }
    } catch (e) {
      print('❌ Error executing command: $e');
    }
    
    if (cmd.isNotEmpty) {
      print('');
    }
    _showPrompt();
  }
}

Future<void> _cleanup(StreamSubscription statusSub, StreamSubscription connectionSub, PlayerManager playerManager) async {
  await statusSub.cancel();
  await connectionSub.cancel();
  playerManager.dispose();
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
