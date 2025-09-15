import 'dart:io';
import '../../models/players/player_configuration.dart';
import 'player.dart';
import 'players/vlc_player.dart';
import 'players/mpc_hc_player.dart';
import 'configurable_player.dart';

enum PlayerType {
  vlc,
  mpcHc,
  custom,
}

class PlayerFactory {
  static const String customPlayersPath = 'players';
  
  /// Create a player instance based on the type
  static MediaPlayer createPlayer(PlayerType type, {Map<String, dynamic>? config}) {
    switch (type) {
      case PlayerType.vlc:
        return VLCPlayer(
          host: config?['host'] ?? 'localhost',
          port: config?['port'] ?? 8080,
          password: config?['password'] ?? '',
        );
      
      case PlayerType.mpcHc:
        return MPCHCPlayer(
          host: config?['host'] ?? 'localhost',
          port: config?['port'] ?? 13579,
        );
      
      case PlayerType.custom:
        if (config == null || config['configuration'] == null) {
          throw ArgumentError('Custom player requires a PlayerConfiguration');
        }
        final playerConfig = config['configuration'] as PlayerConfiguration;
        return ConfigurablePlayer(playerConfig);
    }
  }

  /// Create a player from a configuration object
  static MediaPlayer createFromConfiguration(PlayerConfiguration config) {
    return ConfigurablePlayer(config);
  }

  /// Load all available custom player configurations from the players directory
  static Future<List<PlayerConfiguration>> loadCustomPlayerConfigurations() async {
    final configurations = <PlayerConfiguration>[];
    
    try {
      final playersDir = Directory(customPlayersPath);
      if (!await playersDir.exists()) {
        return configurations;
      }
      
      await for (final entity in playersDir.list()) {
        if (entity is File && (entity.path.endsWith('.json') || entity.path.endsWith('.player'))) {
          try {
            final content = await entity.readAsString();
            final config = PlayerConfiguration.fromJsonString(content);
            configurations.add(config);
          } catch (e) {
            // Skip invalid configuration files
            print('Failed to load player configuration from ${entity.path}: $e');
          }
        }
      }
    } catch (e) {
      print('Failed to load custom player configurations: $e');
    }
    
    return configurations;
  }

  /// Save a player configuration to the players directory
  static Future<void> savePlayerConfiguration(PlayerConfiguration config) async {
    try {
      final playersDir = Directory(customPlayersPath);
      if (!await playersDir.exists()) {
        await playersDir.create(recursive: true);
      }
      
      final fileName = '${config.name.toLowerCase().replaceAll(' ', '_')}.player';
      final file = File('${playersDir.path}/$fileName');
      await file.writeAsString(config.toJsonString());
    } catch (e) {
      throw Exception('Failed to save player configuration: $e');
    }
  }

  /// Get all available player types including custom ones
  static Future<List<PlayerInfo>> getAvailablePlayers() async {
    final players = <PlayerInfo>[
      PlayerInfo(
        name: 'VLC Media Player',
        type: PlayerType.vlc,
        description: 'VLC Media Player with Web Interface',
        isBuiltIn: true,
      ),
      PlayerInfo(
        name: 'MPC-HC',
        type: PlayerType.mpcHc,
        description: 'Media Player Classic - Home Cinema',
        isBuiltIn: true,
      ),
    ];
    
    // Add custom players
    final customConfigs = await loadCustomPlayerConfigurations();
    for (final config in customConfigs) {
      players.add(PlayerInfo(
        name: config.name,
        type: PlayerType.custom,
        description: 'Custom player configuration',
        isBuiltIn: false,
        configuration: config,
      ));
    }
    
    return players;
  }

  /// Create example configuration files for custom players
  static Future<void> createExampleConfigurations() async {
    try {
      final playersDir = Directory(customPlayersPath);
      if (!await playersDir.exists()) {
        await playersDir.create(recursive: true);
      }

      // Create VLC example
      final vlcExample = File('${playersDir.path}/vlc_example.player');
      await vlcExample.writeAsString(PlayerConfiguration.vlcConfig.toJsonString());

      // Create MPC-HC example
      final mpcExample = File('${playersDir.path}/mpc_hc_example.player');
      await mpcExample.writeAsString(PlayerConfiguration.mpcHcConfig.toJsonString());

      // Create a custom example
      final customExample = PlayerConfiguration(
        name: 'Custom Player Example',
        type: 'http',
        host: 'localhost',
        port: 8000,
        password: 'optional_password',
        endpoints: {
          'status': '/api/status',
          'command': '/api/command',
        },
        commands: {
          'play': {'action': 'play'},
          'pause': {'action': 'pause'},
          'togglePlayPause': {'action': 'toggle'},
          'volumeUp': {'action': 'volume', 'direction': 'up'},
          'volumeDown': {'action': 'volume', 'direction': 'down'},
          'mute': {'action': 'mute'},
        },
        fieldMappings: {
          'filePath': 'current_file',
          'currentPosition': 'position_ms',
          'totalDuration': 'duration_ms',
          'isPlaying': 'is_playing',
          'volumeLevel': 'volume',
          'isMuted': 'is_muted',
        },
      );
      
      final customFile = File('${playersDir.path}/custom_example.player');
      await customFile.writeAsString(customExample.toJsonString());
      
    } catch (e) {
      throw Exception('Failed to create example configurations: $e');
    }
  }
}

class PlayerInfo {
  final String name;
  final PlayerType type;
  final String description;
  final bool isBuiltIn;
  final PlayerConfiguration? configuration;

  PlayerInfo({
    required this.name,
    required this.type,
    required this.description,
    required this.isBuiltIn,
    this.configuration,
  });
}