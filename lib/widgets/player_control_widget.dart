import 'dart:async';
import 'package:flutter/material.dart';
import '../services/players/player_manager.dart';
import '../services/players/factory.dart';
import '../models/players/mediastatus.dart';

/// Example widget demonstrating how to use the Player Manager system
class PlayerControlWidget extends StatefulWidget {
  const PlayerControlWidget({super.key});

  @override
  State<PlayerControlWidget> createState() => _PlayerControlWidgetState();
}

class _PlayerControlWidgetState extends State<PlayerControlWidget> {
  late final PlayerManager _playerManager;
  MediaStatus? _currentStatus;
  PlayerConnectionStatus? _connectionStatus;
  List<PlayerInfo> _availablePlayers = [];
  
  StreamSubscription? _statusSubscription;
  StreamSubscription? _connectionSubscription;

  @override
  void initState() {
    super.initState();
    _playerManager = PlayerManager();
    _setupListeners();
    _loadAvailablePlayers();
  }

  void _setupListeners() {
    _statusSubscription = _playerManager.statusStream.listen((status) {
      setState(() {
        _currentStatus = status;
      });
    });

    _connectionSubscription = _playerManager.connectionStream.listen((status) {
      setState(() {
        _connectionStatus = status;
      });
    });
  }

  Future<void> _loadAvailablePlayers() async {
    final players = await _playerManager.getAvailablePlayers();
    setState(() {
      _availablePlayers = players;
    });
  }

  Future<void> _connectToPlayer(PlayerInfo playerInfo) async {
    bool connected = false;
    
    if (playerInfo.type == PlayerType.custom && playerInfo.configuration != null) {
      connected = await _playerManager.connectToPlayerWithConfiguration(playerInfo.configuration!);
    } else {
      connected = await _playerManager.connectToPlayer(playerInfo.type);
    }

    if (connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to ${playerInfo.name}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect to ${playerInfo.name}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _autoConnect() async {
    final connected = await _playerManager.autoConnect();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(connected ? 'Auto-connected successfully' : 'No players found'),
        backgroundColor: connected ? Colors.green : Colors.orange,
      ),
    );
  }

  Future<void> _createExampleConfigs() async {
    try {
      await _playerManager.createExampleConfigurations();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Example configurations created in players/ folder')),
      );
      _loadAvailablePlayers(); // Reload to show new configs
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create examples: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Player Control'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Connection Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_getConnectionStatusText()),
                    if (_connectionStatus?.hasError == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        _connectionStatus!.message ?? 'Unknown error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Media Status
            if (_currentStatus != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Media Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('File: ${_currentStatus!.filePath}'),
                      Text('Duration: ${_formatDuration(_currentStatus!.totalDuration)}'),
                      Text('Position: ${_formatDuration(_currentStatus!.currentPosition)}'),
                      Text('Progress: ${(_currentStatus!.progress * 100).toStringAsFixed(1)}%'),
                      Text('Playing: ${_currentStatus!.isPlaying ? 'Yes' : 'No'}'),
                      Text('Volume: ${_currentStatus!.volumeLevel}%'),
                      Text('Muted: ${_currentStatus!.isMuted ? 'Yes' : 'No'}'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
            
            // Controls
            if (_playerManager.isConnected) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Controls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ElevatedButton(
                            onPressed: () => _playerManager.play(),
                            child: const Text('Play'),
                          ),
                          ElevatedButton(
                            onPressed: () => _playerManager.pause(),
                            child: const Text('Pause'),
                          ),
                          ElevatedButton(
                            onPressed: () => _playerManager.togglePlayPause(),
                            child: const Text('Toggle'),
                          ),
                          ElevatedButton(
                            onPressed: () => _playerManager.mute(),
                            child: const Text('Mute'),
                          ),
                          ElevatedButton(
                            onPressed: () => _playerManager.unmute(),
                            child: const Text('Unmute'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
            
            // Available Players
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Available Players', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: _autoConnect,
                            child: const Text('Auto Connect'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _createExampleConfigs,
                            child: const Text('Create Examples'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _playerManager.disconnect(),
                            child: const Text('Disconnect'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _availablePlayers.length,
                          itemBuilder: (context, index) {
                            final player = _availablePlayers[index];
                            return ListTile(
                              title: Text(player.name),
                              subtitle: Text(player.description),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!player.isBuiltIn)
                                    const Icon(Icons.extension, size: 16),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => _connectToPlayer(player),
                                    child: const Text('Connect'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getConnectionStatusText() {
    if (_connectionStatus == null) return 'Unknown';
    
    switch (_connectionStatus!.state) {
      case PlayerConnectionState.disconnected:
        return 'Disconnected';
      case PlayerConnectionState.connecting:
        return 'Connecting...';
      case PlayerConnectionState.connected:
        return 'Connected';
      case PlayerConnectionState.error:
        return 'Error';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _connectionSubscription?.cancel();
    _playerManager.dispose();
    super.dispose();
  }
}
