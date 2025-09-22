import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../../../models/players/mediastatus.dart';
import '../../../utils/logging.dart';
import '../../../widgets/svg.dart' as icon show mpcHc;
import '../player.dart';

class MPCHCPlayer extends MediaPlayer {
  @override
  Widget get iconWidget => icon.mpcHc;
  final String host;
  final int port;

  Timer? _statusTimer;
  final StreamController<MediaStatus> _statusController = StreamController<MediaStatus>.broadcast();
  MediaStatus? _lastStatus;

  MPCHCPlayer({
    this.host = 'localhost',
    this.port = 13579,
  });

  @override
  Stream<MediaStatus> get statusStream => _statusController.stream;

  String get _baseUrl => 'http://$host:$port';

  @override
  Future<bool> connect() async {
    // If already connected (polling timer is active), return true
    if (_statusTimer?.isActive == true) return true;

    try {
      final response = await http //
          .get(Uri.parse('$_baseUrl/variables.html'))
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
        Uri.parse('$_baseUrl/variables.html'),
      );

      if (response.statusCode == 200) {
        final variables = _parseVariables(response.body);

        // Try to get the full file path - MPC-HC provides 'filepath' variable with complete path
        String fullFilePath = variables['filepath'] ?? '';

        // Fallback to constructing path from directory and filename if filepath not available
        if (fullFilePath.isEmpty) {
          final fileDir = variables['filedir'] ?? '';
          final fileName = variables['file'] ?? '';

          if (fileDir.isNotEmpty && fileName.isNotEmpty) {
            fullFilePath = fileDir.endsWith('\\') || fileDir.endsWith('/') ? '$fileDir$fileName' : '$fileDir\\$fileName';
          } else if (fileName.isNotEmpty) {
            fullFilePath = fileName;
            logTrace('MPC-HC: Using filename only: "$fullFilePath"');
          } else {
            fullFilePath = ''; // No valid path info available
            logWarn('MPC-HC: No valid file path information available from variables for current file.');
          }
        }

        final status = MediaStatus(
          filePath: fullFilePath,
          currentPosition: Duration(milliseconds: int.tryParse(variables['position'] ?? '0') ?? 0),
          totalDuration: Duration(milliseconds: int.tryParse(variables['duration'] ?? '0') ?? 0),
          isPlaying: variables['state'] == '2', // 2 = playing in MPC-HC
          volumeLevel: int.tryParse(variables['volumelevel'] ?? '0') ?? 0,
          isMuted: variables['muted'] == '1',
        );

        _lastStatus = status;
        _statusController.add(status);
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  Map<String, String> _parseVariables(String html) {
    final variables = <String, String>{};

    // MPC-HC variables.html contains lines like:
    // <p id="file">filename.mkv</p>
    // <p id="filedir">C:\Path\To\Directory</p>
    final regex = RegExp(r'<p id="([^"]+)">([^<]*)</p>');
    final matches = regex.allMatches(html);

    for (final match in matches) {
      final key = match.group(1);
      final value = match.group(2);
      if (key != null && value != null) variables[key] = value;
    }

    return variables;
  }

  @override
  Future<void> play() async => await _sendCommand(887);

  @override
  Future<void> pause() async => await _sendCommand(888);

  @override
  Future<void> togglePlayPause() async => await _sendCommand(889);

  @override
  Future<void> setVolume(int level) async {
    final currentVolume = await _getCurrentVolume();
    final difference = level - currentVolume;

    if (difference > 0) {
      final steps = (difference / 5).ceil();
      for (int i = 0; i < steps; i++) await _sendCommand(907); // Volume up by 5
    } else if (difference < 0) {
      final steps = (difference.abs() / 5).ceil();
      for (int i = 0; i < steps; i++) await _sendCommand(908); // Volume down by 5
    }
  }

  @override
  Future<void> mute() async => await _sendCommand(909);

  @override
  Future<void> unmute() async => await _sendCommand(909);

  @override
  Future<void> previousVideo() async => await _sendCommand(919); // Previous file/chapter

  @override
  Future<void> nextVideo() async => await _sendCommand(920); // Next file/chapter

  @override
  Future<void> seek(int seconds) async {
    try {
      // Use last known status to calculate percentage
      if (_lastStatus != null && _lastStatus!.totalDuration.inSeconds > 0) {
        // Calculate percentage (0-100) of total duration
        final percent = (seconds / _lastStatus!.totalDuration.inSeconds * 100).clamp(0.0, 100.0);

        // MPC-HC seek using command -1 with percentage
        await http.get(
          Uri.parse('$_baseUrl/command.html').replace(
            queryParameters: {
              'wm_command': '-1',
              'percent': percent.toString(),
            },
          ),
        );
      }
    } catch (e, st) {
      logErr('Error seeking to $seconds seconds', e, st);
    }
  }

  @override
  Future<void> pollStatus() async {
    await _fetchStatus();
  }

  Future<int> _getCurrentVolume() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/variables.html'));
      if (response.statusCode == 200) {
        final variables = _parseVariables(response.body);
        return int.tryParse(variables['volume'] ?? '0') ?? 0;
      }
    } catch (e, st) {
      logErr('Error fetching current volume', e, st);
    }
    return 0;
  }

  Future<void> _sendCommand(int commandId) async {
    try {
      await http.get(
        Uri.parse('$_baseUrl/command.html').replace(
          queryParameters: {'wm_command': commandId.toString()},
        ),
      );
    } catch (e, st) {
      logErr('Error sending command $commandId', e, st);
    }
  }

  @override
  void dispose() {
    disconnect();
    _statusController.close();
  }
}
