import 'dart:convert';
import '../../utils/icons.dart';

class PlayerConfiguration {
  final String name;
  final String type; // 'http', 'websocket', etc.
  final String host;
  final int port;
  final String? password;
  final String? iconPath; // Path to icon file (.png/.svg/.ico)
  final List<String> executableNames; // List of possible executable names
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
    this.executableNames = const [],
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
      executableNames: json['executableNames'] != null ? List<String>.from(json['executableNames']) : [],
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
      'executableNames': executableNames,
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

  PlayerConfiguration copyWith({
    String? name,
    String? type,
    String? host,
    int? port,
    String? password,
    String? iconPath,
    List<String>? executableNames,
    Map<String, dynamic>? endpoints,
    Map<String, dynamic>? commands,
    Map<String, String>? fieldMappings,
  }) {
    return PlayerConfiguration(
      name: name ?? this.name,
      type: type ?? this.type,
      host: host ?? this.host,
      port: port ?? this.port,
      password: password ?? this.password,
      iconPath: iconPath ?? this.iconPath,
      executableNames: executableNames ?? this.executableNames,
      endpoints: endpoints ?? this.endpoints,
      commands: commands ?? this.commands,
      fieldMappings: fieldMappings ?? this.fieldMappings,
    );
  }

  // Example configurations for built-in players
  static PlayerConfiguration get vlcConfig => PlayerConfiguration(
    name: 'VLC Media Player',
    type: 'http',
    host: 'localhost',
    port: 8080,
    password: '',
    iconPath: vlc,
    executableNames: ['vlc.exe', 'VLC media player'],
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
    executableNames: ['mpc-hc.exe', 'mpc-hc64.exe', 'MPC-HC', 'Media Player Classic'],
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
