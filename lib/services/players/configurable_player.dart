import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Icons, Icon;
import 'package:http/http.dart' as http;
import '../../models/players/mediastatus.dart';
import '../../models/players/player_configuration.dart';
import '../../utils/logging.dart';
import '../../widgets/svg.dart';
import 'player.dart';

class ConfigurablePlayer extends MediaPlayer {
  @override
  Widget get iconWidget {
    final path = config.iconPath;
    try {
      if (path != null && path.isNotEmpty) {
        if (path.startsWith('assets/')) {
          if (path.endsWith('.svg')) return Svg(path, width: 20, height: 20);
          if (path.endsWith('.png') || path.endsWith('.jpg') || path.endsWith('.jpeg')) return Image.asset(path, width: 20, height: 20);
          return Image.asset(path, width: 20, height: 20);
        }
        final file = File(path);
        if (file.existsSync()) return Image.file(file, width: 20, height: 20);
      }
    } catch (e) {
      logErr('Error loading the player icon from $path', e);
    }
    // Fallback icon
    return Icon(Icons.play_arrow, size: 20);
  }

  final PlayerConfiguration config;

  Timer? _statusTimer;
  final StreamController<MediaStatus> _statusController = StreamController<MediaStatus>.broadcast();

  ConfigurablePlayer(this.config);

  @override
  Stream<MediaStatus> get statusStream => _statusController.stream;

  String get _baseUrl => 'http://${config.host}:${config.port}';

  Map<String, String> get _headers {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (config.password != null && config.password!.isNotEmpty) //
      headers['Authorization'] = 'Basic ${base64Encode(utf8.encode(':${config.password}'))}';

    return headers;
  }

  @override
  Future<bool> connect() async {
    // If already connected (polling timer is active), return true
    if (_statusTimer?.isActive == true) return true;
    
    try {
      final statusEndpoint = config.endpoints['status'] as String;
      final response = await http
          .get(
            Uri.parse('$_baseUrl$statusEndpoint'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        _startStatusPolling();
        return true;
      }
      return false;
    } catch (e) {
      // Ensure we're properly disconnected on failed connection attempt
      disconnect();
      return false;
    }
  }

  @override
  void disconnect() {
    _statusTimer?.cancel();
    _statusTimer = null;
  }

  void _startStatusPolling() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (_) => _fetchStatus());
  }

  Future<void> _fetchStatus() async {
    try {
      final statusEndpoint = config.endpoints['status'] as String;
      final response = await http.get(
        Uri.parse('$_baseUrl$statusEndpoint'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = _parseResponse(response.body, statusEndpoint);

        final status = MediaStatus(
          filePath: _extractValue(data, config.fieldMappings['filePath']!) ?? '',
          currentPosition: _extractDuration(data, config.fieldMappings['currentPosition']!),
          totalDuration: _extractDuration(data, config.fieldMappings['totalDuration']!),
          isPlaying: _extractBool(data, config.fieldMappings['isPlaying']!),
          volumeLevel: _extractInt(data, config.fieldMappings['volumeLevel']!),
          isMuted: _extractBool(data, config.fieldMappings['isMuted']!),
        );

        _statusController.add(status);
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  dynamic _parseResponse(String body, String endpoint) {
    if (endpoint.endsWith('.json')) {
      return json.decode(body);
    } else if (endpoint.endsWith('.html')) {
      // Parse HTML variables format (MPC-HC style)
      final variables = <String, String>{};
      final regex = RegExp(r'<p id="([^"]+)">([^<]*)</p>');
      final matches = regex.allMatches(body);

      for (final match in matches) {
        final key = match.group(1);
        final value = match.group(2);
        if (key != null && value != null) variables[key] = value;
      }
      return variables;
    }
    return {};
  }

  dynamic _extractValue(dynamic data, String path) {
    final parts = path.split('.');
    dynamic current = data;

    for (final part in parts) {
      if (current is Map)
        current = current[part];
      else
        return null;
    }

    return current;
  }

  Duration _extractDuration(dynamic data, String path) {
    final value = _extractValue(data, path);
    if (value is int) return Duration(seconds: value);
    if (value is String) return Duration(milliseconds: int.tryParse(value) ?? 0);
    return Duration.zero;
  }

  bool _extractBool(dynamic data, String path) {
    final value = _extractValue(data, path);
    if (value is bool) return value;
    if (value is String) return value == 'playing' || value == '2' || value == '1' || value == 'true';
    if (value is int) return value != 0;
    return false;
  }

  int _extractInt(dynamic data, String path) {
    final value = _extractValue(data, path);
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.round();
    return 0;
  }

  @override
  Future<void> play() async => await _sendCommand('play');

  @override
  Future<void> pause() async => await _sendCommand('pause');

  @override
  Future<void> togglePlayPause() async => await _sendCommand('togglePlayPause');

  @override
  Future<void> setVolume(int level) async {
    // This is a simplified implementation
    // In practice, you might need more sophisticated volume control
    final currentVolume = _extractInt(await _getCurrentData(), config.fieldMappings['volumeLevel']!);
    final difference = level - currentVolume;

    if (difference > 0) {
      for (int i = 0; i < difference; i++) {
        await _sendCommand('volumeUp');
      }
    } else if (difference < 0) {
      for (int i = 0; i < difference.abs(); i++) {
        await _sendCommand('volumeDown');
      }
    }
  }

  @override
  Future<void> mute() async => await _sendCommand('mute');

  @override
  Future<void> unmute() async => await _sendCommand('mute');

  @override
  Future<void> nextVideo() async => await _sendCommand('next');

  @override
  Future<void> previousVideo() async => await _sendCommand('previous');

  @override
  Future<void> seek(int seconds) async {
    try {
      final commandConfig = config.commands['goto'] as Map<String, dynamic>?;
      if (commandConfig == null) return;

      final commandEndpoint = config.endpoints['command'] as String;
      // Create a copy of the command config and replace any placeholder values
      final queryParams = <String, String>{};
      for (final entry in commandConfig.entries) {
        String value = entry.value.toString();
        // Replace {seconds} placeholder with actual seconds value
        if (value.contains('{seconds}')) {
          value = value.replaceAll('{seconds}', seconds.toString());
        }
        queryParams[entry.key] = value;
      }

      final uri = Uri.parse('$_baseUrl$commandEndpoint').replace(
        queryParameters: queryParams,
      );

      await http.get(uri, headers: _headers);
    } catch (e, st) {
      logErr('Error seeking to $seconds seconds', e, st);
    }
  }

  @override
  Future<void> pollStatus() async {
    await _fetchStatus();
  }

  Future<dynamic> _getCurrentData() async {
    try {
      final statusEndpoint = config.endpoints['status'] as String;
      final response = await http.get(
        Uri.parse('$_baseUrl$statusEndpoint'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return _parseResponse(response.body, statusEndpoint);
      }
    } catch (e, st) {
      logErr('Error fetching current data', e, st);
    }
    return {};
  }

  Future<void> _sendCommand(String commandName) async {
    try {
      final commandConfig = config.commands[commandName] as Map<String, dynamic>?;
      if (commandConfig == null) return;

      final commandEndpoint = config.endpoints['command'] as String;
      final uri = Uri.parse('$_baseUrl$commandEndpoint').replace(
        queryParameters: commandConfig.map((key, value) => MapEntry(key, value.toString())),
      );

      await http.get(uri, headers: _headers);
    } catch (e, st) {
      logErr('Error sending command $commandName', e, st);
    }
  }

  @override
  void dispose() {
    disconnect();
    _statusController.close();
  }
}
