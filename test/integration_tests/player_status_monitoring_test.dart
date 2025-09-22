// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

import 'package:miruryoiki/services/players/player_manager.dart';
import 'package:miruryoiki/models/players/mediastatus.dart';

/// Integration test that monitors media player status
/// This can be used to verify status updates are working correctly
void main() {
  group('Player Status Monitoring Integration Tests', () {
    late PlayerManager playerManager;

    setUp(() {
      playerManager = PlayerManager();
    });

    tearDown(() {
      playerManager.dispose();
    });

    test('should monitor player status updates', () async {
      print('🔍 Attempting to connect to media player...');
      
      final connected = await playerManager.autoConnect();
      
      if (!connected) {
        print('⚠️  Skipping monitoring test - no media player available');
        print('💡 To run this test:');
        print('   1. Start VLC or MPC-HC');
        print('   2. Enable web interface');
        print('   3. Load a video file');
        print('   4. Run the test again');
        return;
      }

      print('✅ Connected to media player!');
      print('📊 Monitoring status for 10 seconds...\n');
      
      final statusUpdates = <MediaStatus>[];
      late StreamSubscription statusSubscription;
      
      statusSubscription = playerManager.statusStream.listen((status) {
        statusUpdates.add(status);
        _printStatusUpdate(status, statusUpdates.length);
      });

      try {
        // Monitor for 10 seconds
        await Future.delayed(Duration(seconds: 10));
        
        expect(statusUpdates.length, greaterThan(5), 
            reason: 'Should receive multiple status updates');
        
        print('\n📋 Monitoring Complete:');
        print('   Total Updates: ${statusUpdates.length}');
        print('   Average Updates/sec: ${(statusUpdates.length / 10).toStringAsFixed(1)}');
        
        // Verify we got meaningful data
        final hasValidFile = statusUpdates.any((s) => s.filePath.isNotEmpty);
        final hasValidDuration = statusUpdates.any((s) => s.totalDuration.inMilliseconds > 0);
        
        print('   Has File Info: ${hasValidFile ? '✅' : '❌'}');
        print('   Has Duration: ${hasValidDuration ? '✅' : '❌'}');
        
      } finally {
        // Cancel subscription first to stop receiving updates
        await statusSubscription.cancel();
        
        // Add a small delay to ensure all pending events are processed
        await Future.delayed(Duration(milliseconds: 100));
        
        // Then disconnect the player manager
        await playerManager.disconnect();
      }
    }, timeout: Timeout(Duration(seconds: 15)));
  });
}

void _printStatusUpdate(MediaStatus status, int updateNumber) {
  final timestamp = DateTime.now().toIso8601String().substring(11, 19);
  final filepath = status.filePath;
  final file = status.filePath.isEmpty ? 'No file' : status.filePath.split('\\').last;
  final progress = status.totalDuration.inMilliseconds > 0 ? 
      '${_formatTime(status.currentPosition.inMilliseconds)}/${_formatTime(status.totalDuration.inMilliseconds)}' : 'Unknown';
  final playStatus = status.isPlaying ? '▶️ PLAYING' : '⏸️ PAUSED';
  final volume = status.isMuted ? 'MUTED' : '${status.volumeLevel}%';
  
  print('[$timestamp] Update #$updateNumber:');
  print('   FilePath: $filepath');
  print('   File: $file');
  print('   Status: $playStatus | Volume: $volume');
  print('   Progress: $progress');
  print('');
}

String _formatTime(int milliseconds) {
  final totalSeconds = milliseconds ~/ 1000;
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}
