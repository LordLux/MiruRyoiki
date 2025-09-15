// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Debug tool to test VLC connection directly
/// Run with: dart run lib/debug_vlc.dart
void main() async {
  print('🔍 VLC Connection Debug Tool');
  print('============================');
  
  const host = 'localhost';
  const port = 8080;
  const password = 'miruryoiki';
  
  print('Testing VLC connection:');
  print('  Host: $host');
  print('  Port: $port');
  print('  Password: $password');
  print('');
  
  // Test 1: Check if VLC web interface is accessible
  print('📡 Test 1: Checking if VLC web interface is accessible...');
  final baseUrl = 'http://$host:$port';
  
  try {
    final response = await http.get(Uri.parse(baseUrl)).timeout(Duration(seconds: 5));
    print('✅ VLC web interface is accessible (Status: ${response.statusCode})');
  } catch (e) {
    print('❌ Cannot reach VLC web interface: $e');
    print('💡 Make sure VLC is running with web interface enabled');
    return;
  }
  
  // Test 2: Test without authentication
  print('\n📡 Test 2: Testing status endpoint without password...');
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/requests/status.json'),
    ).timeout(Duration(seconds: 5));
    
    print('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('✅ VLC allows access without password');
      print('📄 Response: ${response.body.substring(0, 200)}...');
    } else if (response.statusCode == 401) {
      print('🔐 VLC requires authentication (this is expected)');
    } else {
      print('❓ Unexpected response: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error accessing status endpoint: $e');
  }
  
  // Test 3: Test with authentication
  print('\n📡 Test 3: Testing status endpoint with password "$password"...');
  try {
    final headers = {
      'Authorization': 'Basic ${base64Encode(utf8.encode(':$password'))}',
      'Content-Type': 'application/json',
    };
    
    final response = await http.get(
      Uri.parse('$baseUrl/requests/status.json'),
      headers: headers,
    ).timeout(Duration(seconds: 5));
    
    print('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('✅ VLC accepts the password!');
      print('📄 Full response:');
      
      try {
        final data = json.decode(response.body);
        final prettyJson = JsonEncoder.withIndent('  ').convert(data);
        print(prettyJson);
        
        // Extract key information
        print('\n📊 Key Information:');
        print('   State: ${data['state']}');
        print('   Time: ${data['time']} seconds');
        print('   Length: ${data['length']} seconds');
        print('   Volume: ${data['volume']}');
        print('   Filename: ${data['information']?['category']?['meta']?['filename'] ?? 'No file loaded'}');
        
      } catch (e) {
        print('Raw response: ${response.body}');
      }
    } else if (response.statusCode == 401) {
      print('❌ VLC rejected the password');
      print('💡 Check your VLC web interface password settings');
    } else {
      print('❓ Unexpected response: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('❌ Error with authentication: $e');
  }
  
  // Test 4: Test different authentication methods
  print('\n📡 Test 4: Testing alternative authentication...');
  try {
    // Some VLC versions might use different auth schemes
    final altHeaders = {
      'Authorization': 'Basic ${base64Encode(utf8.encode('$password:'))}',
    };
    
    final response = await http.get(
      Uri.parse('$baseUrl/requests/status.json'),
      headers: altHeaders,
    ).timeout(Duration(seconds: 5));
    
    if (response.statusCode == 200) {
      print('✅ Alternative authentication worked!');
    } else {
      print('❌ Alternative authentication failed (${response.statusCode})');
    }
  } catch (e) {
    print('❌ Alternative authentication error: $e');
  }
  
  print('\n🏁 Debug test completed!');
  print('💡 If tests fail, check:');
  print('   1. VLC is running');
  print('   2. Web interface is enabled: Tools → Preferences → Interface → Main interfaces → Web');
  print('   3. Password is set correctly in VLC preferences');
  print('   4. VLC was restarted after enabling web interface');
}
