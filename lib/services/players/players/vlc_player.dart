import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../../../models/players/mediastatus.dart';
import '../../../utils/logging.dart';
import '../../../widgets/svg.dart' as icon show vlc;
import '../player.dart';

class VLCPlayer extends MediaPlayer {
  @override
  Widget get iconWidget => icon.vlc;
  final String host;
  final int port;
  final String password;

  Timer? _statusTimer;
  final StreamController<MediaStatus> _statusController = StreamController<MediaStatus>.broadcast();

  int prevVolume = 50;

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
    // If already connected (polling timer is active), return true
    if (_statusTimer?.isActive == true) return true;
    
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/requests/status.json'),
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
          volumeLevel: ((data['volume'] ?? 0) / 2.56).round(), // VLC uses 0-256, convert to 0-100
          isMuted: data['volume'] == 0,
        );

        _statusController.add(status);
      }
    } catch (e) {
      if (e is ClientException || e is TimeoutException) return;
      logErr('VLCPlayer fetchStatus error', e);
    }
  }

  @override
  Future<void> play() async => await _sendCommand('pl_play');

  @override
  Future<void> pause() async => await _sendCommand('pl_pause');

  @override
  Future<void> togglePlayPause() async => await _sendCommand('pl_pause');

  @override
  Future<void> setVolume(int level) async {
    // VLC uses 0-256 volume range
    final vlcVolume = (level * 2.56).round();
    await _sendCommand('volume', {'val': vlcVolume.toString()});
  }

  @override
  Future<void> mute() async {
    prevVolume = ((await statusStream.first).volumeLevel);
    await _sendCommand('volume', {'val': '0'});
  }

  @override
  Future<void> unmute() async => await _sendCommand('volume', {'val': '${(prevVolume * 2.56).round()}'});

  @override
  Future<void> nextVideo() async => await _sendCommand('pl_next');

  @override
  Future<void> previousVideo() async => await _sendCommand('pl_previous');

  @override
  Future<void> seek(int seconds) async {
    await _sendCommand('seek', {'val': seconds.toString()});
  }

  @override
  Future<void> pollStatus() async {
    await _fetchStatus();
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
    } catch (e, st) {
      if (e is ClientException || e is TimeoutException) return;
      logErr('VLCPlayer sendCommand error', e, st);
    }
  }

  @override
  void dispose() {
    disconnect();
    _statusController.close();
  }
}
