import 'dart:convert';
import '../../utils/icons.dart';

class PlayerConfiguration {
  final String name;
  final String type; // 'http', 'websocket', etc.
  final String host;
  final int port;
  final String? password;
  final String? iconPath; // Path to icon file (.png/.svg/.ico)
  final Map<String, dynamic> endpoints;
  final Map<String, dynamic> commands;
  final Map<String, String> fieldMappings;

  PlayerConfiguration({
    required this.name,
    required this.type,
    required this.host,
    required this.port,
    this.password,
    this.iconPath,
    required this.endpoints,
    required this.commands,
    required this.fieldMappings,
  });

  factory PlayerConfiguration.fromJson(Map<String, dynamic> json) {
    return PlayerConfiguration(
      name: json['name'],
      type: json['type'],
      host: json['host'],
      port: json['port'],
      password: json['password'],
      iconPath: json['iconPath'],
      endpoints: json['endpoints'] ?? {},
      commands: json['commands'] ?? {},
      fieldMappings: Map<String, String>.from(json['fieldMappings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'host': host,
      'port': port,
      'password': password,
      'iconPath': iconPath,
      'endpoints': endpoints,
      'commands': commands,
      'fieldMappings': fieldMappings,
    };
  }

  factory PlayerConfiguration.fromJsonString(String jsonString) {
    return PlayerConfiguration.fromJson(json.decode(jsonString));
  }

  String toJsonString() {
    return json.encode(toJson());
  }

  // Example configurations for built-in players
  static PlayerConfiguration get vlcConfig => PlayerConfiguration(
    name: 'VLC Media Player',
    type: 'http',
    host: 'localhost',
    port: 8080,
    password: '',
    iconPath: vlc,
    endpoints: {
      'status': '/requests/status.json',
      'command': '/requests/status.json',
    },
    commands: {
      'play': {'command': 'pl_play'},
      'pause': {'command': 'pl_pause'},
      'togglePlayPause': {'command': 'pl_pause'},
      'volumeUp': {'command': 'volume', 'val': '+10'},
      'volumeDown': {'command': 'volume', 'val': '-10'},
      'mute': {'command': 'volume', 'val': '0'},
    },
    fieldMappings: {
      'filePath': 'information.category.meta.filename',
      'currentPosition': 'time',
      'totalDuration': 'length',
      'isPlaying': 'state',
      'volumeLevel': 'volume',
      'isMuted': 'volume',
    },
  );

  static PlayerConfiguration get mpcHcConfig => PlayerConfiguration(
    name: 'MPC-HC',
    type: 'http',
    host: 'localhost',
    port: 13579,
    iconPath: mpcHc,
    endpoints: {
      'status': '/variables.html',
      'command': '/command.html',
    },
    commands: {
      'play': {'wm_command': '887'},
      'pause': {'wm_command': '888'},
      'togglePlayPause': {'wm_command': '889'},
      'volumeUp': {'wm_command': '907'},
      'volumeDown': {'wm_command': '908'},
      'mute': {'wm_command': '909'},
    },
    fieldMappings: {
      'filePath': 'file',
      'currentPosition': 'position',
      'totalDuration': 'duration',
      'isPlaying': 'state',
      'volumeLevel': 'volume',
      'isMuted': 'muted',
    },
  );
}
