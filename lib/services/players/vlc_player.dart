import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/players/mediastatus.dart';
import '../players/player.dart';

class VLCPlayer extends MediaPlayer {
  final String host;
  final int port;
  final String password;
  
  Timer? _statusTimer;
  final StreamController<MediaStatus> _statusController = StreamController<MediaStatus>.broadcast();
  
  VLCPlayer({
    this.host = 'localhost',
    this.port = 8080,
    this.password = '',
  });

  @override
  Stream<MediaStatus> get statusStream => _statusController.stream;

  String get _baseUrl => 'http://$host:$port';
  
  Map<String, String> get _headers => {
    'Authorization': 'Basic ${base64Encode(utf8.encode(':$password'))}',
    'Content-Type': 'application/json',
  };

  @override
  Future<bool> connect() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/requests/status.json'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        _startStatusPolling();
        return true;
      }
      return false;
    } catch (e) {
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
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _fetchStatus();
    });
  }

  Future<void> _fetchStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/requests/status.json'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        final status = MediaStatus(
          filePath: data['information']?['category']?['meta']?['filename'] ?? '',
          currentPosition: Duration(seconds: (data['time'] ?? 0).toInt()),
          totalDuration: Duration(seconds: (data['length'] ?? 0).toInt()),
          isPlaying: data['state'] == 'playing',
          volumeLevel: ((data['volume'] ?? 0) * 100 / 256).round(), // VLC uses 0-256, convert to 0-100
          isMuted: (data['volume'] ?? 0) == 0,
        );
        
        _statusController.add(status);
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  @override
  Future<void> play() async {
    await _sendCommand('pl_play');
  }

  @override
  Future<void> pause() async {
    await _sendCommand('pl_pause');
  }

  @override
  Future<void> togglePlayPause() async {
    await _sendCommand('pl_pause');
  }

  @override
  Future<void> setVolume(int level) async {
    // Clamp volume to valid range
    final clampedLevel = level.clamp(0, 100);
    // VLC uses 0-256 volume range, but let's be more precise
    final vlcVolume = (clampedLevel * 256 / 100).round();
    await _sendCommand('volume', {'val': vlcVolume.toString()});
  }

  @override
  Future<void> mute() async {
    await _sendCommand('volume', {'val': '0'});
  }

  @override
  Future<void> unmute() async {
    // Instead of hardcoded 128, let's use a reasonable default
    await _sendCommand('volume', {'val': '128'}); // 50% volume when unmuting
  }

  Future<void> _sendCommand(String command, [Map<String, String>? params]) async {
    try {
      final uri = Uri.parse('$_baseUrl/requests/status.json').replace(
        queryParameters: {
          'command': command,
          ...?params,
        },
      );
      
      await http.get(uri, headers: _headers);
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    disconnect();
    _statusController.close();
  }
}
