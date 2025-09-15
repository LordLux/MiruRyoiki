// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Debug tool specifically for testing VLC volume commands
/// Run with: dart run lib/debug_vlc_volume.dart
void main() async {
  print('🔊 VLC Volume Debug Tool');
  print('========================');
  
  const host = 'localhost';
  const port = 8080;
  const password = 'miruryoiki';
  const baseUrl = 'http://$host:$port';
  
  final headers = {
    'Authorization': 'Basic ${base64Encode(utf8.encode(':$password'))}',
    'Content-Type': 'application/json',
  };
  
  print('Testing VLC volume commands and responses...\n');
  
  // Test 1: Get current status
  await _testGetStatus(baseUrl, headers);
  
  // Test 2: Test different volume values
  final volumeTests = [256, 128, 77, 51, 0]; // VLC volume range is 0-256
  for (final volume in volumeTests) {
    await _testSetVolume(baseUrl, headers, volume);
    await Future.delayed(Duration(milliseconds: 500));
  }
  
  // Test 3: Test volume commands without val parameter
  await _testVolumeCommands(baseUrl, headers);
  
  print('\n🏁 Volume debug test completed!');
}

Future<void> _testGetStatus(String baseUrl, Map<String, String> headers) async {
  print('📊 Getting current VLC status...');
  
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/requests/status.json'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Current volume: ${data['volume']} (VLC range: 0-256)');
      print('   Converted to %: ${((data['volume'] ?? 0) / 2.56).round()}%');
      print('   State: ${data['state']}');
      print('   Time: ${data['time']}s / ${data['length']}s');
    } else {
      print('❌ Failed to get status: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error getting status: $e');
  }
  print('');
}

Future<void> _testSetVolume(String baseUrl, Map<String, String> headers, int vlcVolume) async {
  final percentage = (vlcVolume / 2.56).round();
  print('🔊 Setting volume to $vlcVolume ($percentage%)...');
  
  try {
    final uri = Uri.parse('$baseUrl/requests/status.json').replace(
      queryParameters: {
        'command': 'volume',
        'val': vlcVolume.toString(),
      },
    );
    
    final response = await http.get(uri, headers: headers);
    print('   Command response: ${response.statusCode}');
    
    // Get status after setting volume
    await Future.delayed(Duration(milliseconds: 200));
    final statusResponse = await http.get(
      Uri.parse('$baseUrl/requests/status.json'),
      headers: headers,
    );
    
    if (statusResponse.statusCode == 200) {
      final data = json.decode(statusResponse.body);
      final actualVolume = data['volume'] ?? 0;
      final actualPercentage = (actualVolume / 2.56).round();
      print('   Actual volume: $actualVolume ($actualPercentage%)');
      
      if (actualVolume == vlcVolume) {
        print('   ✅ Volume set correctly');
      } else {
        print('   ❌ Volume mismatch! Expected: $vlcVolume, Got: $actualVolume');
      }
    }
  } catch (e) {
    print('   ❌ Error setting volume: $e');
  }
  print('');
}

Future<void> _testVolumeCommands(String baseUrl, Map<String, String> headers) async {
  print('🧪 Testing other volume commands...');
  
  final commands = [
    {'command': 'volup', 'description': 'Volume Up'},
    {'command': 'voldown', 'description': 'Volume Down'},
    {'command': 'volup', 'val': '10', 'description': 'Volume Up by 10'},
    {'command': 'voldown', 'val': '10', 'description': 'Volume Down by 10'},
  ];
  
  for (final cmd in commands) {
    print('   Testing: ${cmd['description']}');
    
    try {
      final queryParams = <String, String>{'command': cmd['command']!};
      if (cmd.containsKey('val')) {
        queryParams['val'] = cmd['val']!;
      }
      
      final uri = Uri.parse('$baseUrl/requests/status.json').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(uri, headers: headers);
      print('     Response: ${response.statusCode}');
      
      // Get status after command
      await Future.delayed(Duration(milliseconds: 200));
      final statusResponse = await http.get(
        Uri.parse('$baseUrl/requests/status.json'),
        headers: headers,
      );
      
      if (statusResponse.statusCode == 200) {
        final data = json.decode(statusResponse.body);
        final volume = data['volume'] ?? 0;
        final percentage = (volume / 2.56).round();
        print('     New volume: $volume ($percentage%)');
      }
      
      await Future.delayed(Duration(milliseconds: 300));
      
    } catch (e) {
      print('     ❌ Error: $e');
    }
  }
}
