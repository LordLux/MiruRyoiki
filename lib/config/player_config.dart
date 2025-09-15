// ignore_for_file: prefer_final_fields, avoid_print

import 'dart:io';
import 'dart:convert';

/// Configuration for media player connections
class PlayerConfig {
  static const String _configFile = 'player_config.json';
  
  // Default configuration
  static Map<String, dynamic> _defaultConfig = {
    'vlc': {
      'host': 'localhost',
      'port': 8080,
      'password': 'miruryoiki',
    },
    'mpc_hc': {
      'host': 'localhost',
      'port': 13579,
    },
    'auto_connect_order': ['vlc_with_password', 'vlc_without_password', 'mpc_hc'],
  };
  
  static Map<String, dynamic> _config = {};
  
  /// Load configuration from file or create default
  static Future<void> load() async {
    try {
      final file = File(_configFile);
      if (await file.exists()) {
        final content = await file.readAsString();
        _config = json.decode(content);
        print('📋 Loaded player configuration from $_configFile');
      } else {
        _config = Map.from(_defaultConfig);
        await save();
        print('📝 Created default player configuration file: $_configFile');
      }
    } catch (e) {
      print('⚠️  Failed to load config, using defaults: $e');
      _config = Map.from(_defaultConfig);
    }
  }
  
  /// Save current configuration to file
  static Future<void> save() async {
    try {
      final file = File(_configFile);
      await file.writeAsString(json.encode(_config));
    } catch (e) {
      print('⚠️  Failed to save config: $e');
    }
  }
  
  /// Get VLC configuration
  static Map<String, dynamic> get vlc => _config['vlc'] ?? _defaultConfig['vlc'];
  
  /// Get MPC-HC configuration
  static Map<String, dynamic> get mpcHc => _config['mpc_hc'] ?? _defaultConfig['mpc_hc'];
  
  /// Get auto-connect order
  static List<String> get autoConnectOrder => 
      List<String>.from(_config['auto_connect_order'] ?? _defaultConfig['auto_connect_order']);
  
  /// Update VLC password
  static void setVlcPassword(String password) {
    _config['vlc'] = {
      ...vlc,
      'password': password,
    };
  }
  
  /// Print current configuration
  static void printConfig() {
    print('🔧 Current Player Configuration:');
    print('   VLC: ${vlc['host']}:${vlc['port']} (password: ${vlc['password'].isEmpty ? 'none' : '***'})');
    print('   MPC-HC: ${mpcHc['host']}:${mpcHc['port']}');
    print('   Auto-connect order: ${autoConnectOrder.join(' → ')}');
  }
}
