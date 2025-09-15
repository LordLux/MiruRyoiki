// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

import 'package:miruryoiki/services/players/player_manager.dart';
import 'package:miruryoiki/models/players/mediastatus.dart';

/// Integration tests that require actual media players to be running
/// Run these tests manually when you have VLC or MPC-HC running with a video loaded
void main() {
  group('Player Command Integration Tests', () {
    late PlayerManager playerManager;

    setUp(() {
      playerManager = PlayerManager();
    });

    tearDown(() {
      playerManager.dispose();
    });

    group('Real Player Tests (requires running media player)', () {
      test('should connect and execute commands successfully', () async {
        print('🔍 Attempting to connect to media player...');
        
        final connected = await playerManager.autoConnect();
        
        if (!connected) {
          print('⚠️  Skipping integration test - no media player available');
          print('💡 To run this test:');
          print('   1. Start VLC or MPC-HC');
          print('   2. Enable web interface');
          print('   3. Load a video file');
          print('   4. Run the test again');
          return;
        }

        print('✅ Connected to media player!');
        
        // Wait for initial status
        final initialStatusCompleter = Completer<MediaStatus>();
        late StreamSubscription statusSubscription;
        
        statusSubscription = playerManager.statusStream.listen((status) {
          if (!initialStatusCompleter.isCompleted) {
            initialStatusCompleter.complete(status);
          }
        });

        try {
          final initialStatus = await initialStatusCompleter.future.timeout(Duration(seconds: 5));
          print('📊 Initial status: ${initialStatus.isPlaying ? 'PLAYING' : 'PAUSED'} | Volume: ${initialStatus.volumeLevel}%');

          // Test commands and verify responses
          await _testCommandSequence(playerManager);

        } catch (e) {
          print('❌ Error during command testing: $e');
          fail('Command testing failed: $e');
        } finally {
          // Cancel subscription first to stop receiving updates
          await statusSubscription.cancel();
          
          // Add a small delay to ensure all pending events are processed
          await Future.delayed(Duration(milliseconds: 100));
          
          // Then disconnect the player manager
          await playerManager.disconnect();
        }
      }, timeout: Timeout(Duration(seconds: 30)));
    });
  });
}

Future<void> _testCommandSequence(PlayerManager playerManager) async {
  print('\n🧪 Testing command sequence...');
  
  final testResults = <String, bool>{};
  
  // Test pause command
  await _testCommand(
    'PAUSE',
    () => playerManager.pause(),
    (status) => !status.isPlaying,
    playerManager,
    testResults,
  );

  await Future.delayed(Duration(seconds: 2));

  // Test play command
  await _testCommand(
    'PLAY',
    () => playerManager.play(),
    (status) => status.isPlaying,
    playerManager,
    testResults,
  );

  await Future.delayed(Duration(seconds: 2));

  // Test volume commands
  await _testVolumeCommand(
    'SET VOLUME 30%',
    () => playerManager.setVolume(30),
    30,
    playerManager,
    testResults,
  );

  await Future.delayed(Duration(seconds: 2));

  await _testVolumeCommand(
    'SET VOLUME 70%',
    () => playerManager.setVolume(70),
    70,
    playerManager,
    testResults,
  );

  await Future.delayed(Duration(seconds: 2));

  // Test mute/unmute
  await _testCommand(
    'MUTE',
    () => playerManager.mute(),
    (status) => status.isMuted || status.volumeLevel == 0,
    playerManager,
    testResults,
  );

  await Future.delayed(Duration(seconds: 2));

  await _testCommand(
    'UNMUTE',
    () => playerManager.unmute(),
    (status) => !status.isMuted && status.volumeLevel > 0,
    playerManager,
    testResults,
  );

  // Print test results
  print('\n📋 Test Results Summary:');
  testResults.forEach((command, success) {
    print('   ${success ? '✅' : '❌'} $command');
  });

  final successCount = testResults.values.where((success) => success).length;
  final totalTests = testResults.length;
  
  print('\n🎯 Success Rate: $successCount/$totalTests (${(successCount/totalTests*100).toStringAsFixed(1)}%)');

  // Overall test should pass if most commands work
  expect(successCount, greaterThan(totalTests ~/ 2), 
      reason: 'More than half of the commands should work');
}

Future<void> _testCommand(
  String commandName,
  Future<void> Function() command,
  bool Function(MediaStatus) validator,
  PlayerManager playerManager,
  Map<String, bool> testResults,
) async {
  print('   🧪 Testing: $commandName');
  
  try {
    // Execute command
    await command();
    
    // Wait for status update and validate
    final statusCompleter = Completer<MediaStatus>();
    late StreamSubscription subscription;
    
    subscription = playerManager.statusStream.listen((status) {
      if (!statusCompleter.isCompleted) {
        statusCompleter.complete(status);
      }
    });

    try {
      final status = await statusCompleter.future.timeout(Duration(seconds: 3));
      final success = validator(status);
      
      testResults[commandName] = success;
      
      if (success) {
        print('      ✅ Command successful');
      } else {
        print('      ❌ Command validation failed');
      }
      
    } finally {
      await subscription.cancel();
      // Small delay to ensure stream cleanup
      await Future.delayed(Duration(milliseconds: 50));
    }
    
  } catch (e) {
    print('      ❌ Command failed: $e');
    testResults[commandName] = false;
  }
}

Future<void> _testVolumeCommand(
  String commandName,
  Future<void> Function() command,
  int expectedVolume,
  PlayerManager playerManager,
  Map<String, bool> testResults,
) async {
  await _testCommand(
    commandName,
    command,
    (status) {
      // Allow some tolerance for volume (±5%)
      final tolerance = 5;
      final actualVolume = status.volumeLevel;
      final withinTolerance = (actualVolume - expectedVolume).abs() <= tolerance;
      
      if (!withinTolerance) {
        print('      📊 Expected: ~$expectedVolume%, Got: $actualVolume%');
      }
      
      return withinTolerance;
    },
    playerManager,
    testResults,
  );
}
