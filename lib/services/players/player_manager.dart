import 'dart:async';
import '../../models/players/mediastatus.dart';
import '../../models/players/player_configuration.dart';
import '../../config/player_config.dart';
import 'player.dart';
import 'factory.dart';

class PlayerManager {
  MediaPlayer? _currentPlayer;
  PlayerType? _currentPlayerType;
  PlayerConfiguration? _currentPlayerConfig;
  final StreamController<MediaStatus> _statusController = StreamController<MediaStatus>.broadcast();
  final StreamController<PlayerConnectionStatus> _connectionController = StreamController<PlayerConnectionStatus>.broadcast();

  StreamSubscription? _playerStatusSubscription;
  Timer? _connectionCheckTimer;
  bool _configLoaded = false; // Track if config is already loaded

  MediaStatus? _lastStatus;

  /// Stream of media status updates from the currently active player
  Stream<MediaStatus> get statusStream => _statusController.stream;

  /// Stream of player connection status updates
  Stream<PlayerConnectionStatus> get connectionStream => _connectionController.stream;

  /// Currently active player
  MediaPlayer? get currentPlayer => _currentPlayer;

  /// Whether a player is currently connected
  bool get isConnected => _currentPlayer != null;

  /// Get the current player type
  PlayerType? get currentPlayerType => _currentPlayerType;

  /// Get the current player configuration
  PlayerConfiguration? get currentPlayerConfig => _currentPlayerConfig;

  /// Get the last known status
  MediaStatus? get lastStatus => _lastStatus;

  /// Connect to a specific player type with optional configuration
  Future<bool> connectToPlayer(PlayerType type, {Map<String, dynamic>? config}) async {
    await disconnect();

    try {
      _currentPlayer = PlayerFactory.createPlayer(type, config: config);
      _currentPlayerType = type;
      _currentPlayerConfig = null; // Built-in players don't use PlayerConfiguration
      return await _establishConnection();
    } catch (e) {
      _connectionController.add(PlayerConnectionStatus.error('Failed to create player: $e'));
      return false;
    }
  }

  /// Connect to a player using a configuration object
  Future<bool> connectToPlayerWithConfiguration(PlayerConfiguration config) async {
    await disconnect();

    try {
      _currentPlayer = PlayerFactory.createFromConfiguration(config);
      _currentPlayerType = PlayerType.custom;
      _currentPlayerConfig = config;
      return await _establishConnection();
    } catch (e) {
      _connectionController.add(PlayerConnectionStatus.error('Failed to create player: $e'));
      return false;
    }
  }

  /// Auto-discover and connect to available players
  Future<bool> autoConnect() async {
    // Load player configuration only once
    if (!_configLoaded) {
      await PlayerConfig.load();
      _configLoaded = true;
    }

    final players = [
      () => connectToPlayer(PlayerType.vlc, config: PlayerConfig.vlc),
      () => connectToPlayer(PlayerType.mpc, config: PlayerConfig.mpcHc),
    ];

    for (final playerConnector in players) {
      if (await playerConnector()) {
        return true;
      }
    }

    // Try custom players
    final customConfigs = await PlayerFactory.loadCustomPlayerConfigurations();
    for (final config in customConfigs) {
      if (await connectToPlayerWithConfiguration(config)) {
        return true;
      }
    }

    return false;
  }

  /// Disconnect from the current player
  Future<void> disconnect() async {
    _connectionCheckTimer?.cancel();
    _playerStatusSubscription?.cancel();

    if (_currentPlayer != null) {
      _currentPlayer!.disconnect();
      _currentPlayer!.dispose();
      _currentPlayer = null;
    }

    _currentPlayerType = null;
    _currentPlayerConfig = null;

    _connectionController.add(PlayerConnectionStatus.disconnected());
  }

  /// Establish connection to the current player
  Future<bool> _establishConnection() async {
    if (_currentPlayer == null) return false;

    _connectionController.add(PlayerConnectionStatus.connecting());

    final connected = await _currentPlayer!.connect();

    if (connected) {
      _connectionController.add(PlayerConnectionStatus.connected());
      _setupPlayerListeners();
      _startConnectionCheck();
      return true;
    } else {
      _connectionController.add(PlayerConnectionStatus.error('Failed to connect to player'));
      _currentPlayer?.dispose();
      _currentPlayer = null;
      return false;
    }
  }

  /// Setup listeners for the current player
  void _setupPlayerListeners() {
    if (_currentPlayer == null) return;

    _playerStatusSubscription = _currentPlayer!.statusStream.listen(
      (status) {
        _lastStatus = status; // Store the last status
        _statusController.add(status);
      },
      onError: (error) => _connectionController.add(PlayerConnectionStatus.error('Player error: $error')),
    );
  }

  /// Start periodic connection checking
  void _startConnectionCheck() {
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkConnection();
    });
  }

  /// Check if the connection is still alive
  Future<void> _checkConnection() async {
    if (_currentPlayer == null) return;

    try {
      // Try to reconnect if connection is lost
      // This is a simple check - in practice you might want more sophisticated logic
      final reconnected = await _currentPlayer!.connect();
      if (!reconnected) {
        _connectionController.add(PlayerConnectionStatus.error('Connection lost'));
        await disconnect();
      }
    } catch (e) {
      _connectionController.add(PlayerConnectionStatus.error('Connection check failed: $e'));
      await disconnect();
    }
  }

  // Player control methods that delegate to the current player

  Future<void> play() async => await _currentPlayer?.play();

  Future<void> pause() async => await _currentPlayer?.pause();

  Future<void> togglePlayPause() async => await _currentPlayer?.togglePlayPause();

  Future<void> setVolume(int level) async => await _currentPlayer?.setVolume(level);

  Future<void> volumeUp([int step = 5]) async {
    // Get current volume and increase it
    final currentVolume = _lastStatus?.volumeLevel ?? 50;
    final newVolume = (currentVolume + step).clamp(0, 100);
    await setVolume(newVolume);
  }

  Future<void> volumeDown([int step = 5]) async {
    // Get current volume and decrease it
    final currentVolume = _lastStatus?.volumeLevel ?? 50;
    final newVolume = (currentVolume - step).clamp(0, 100);
    await setVolume(newVolume);
  }

  Future<void> mute() async => await _currentPlayer?.mute();

  Future<void> unmute() async => await _currentPlayer?.unmute();

  /// Navigation controls
  Future<void> nextVideo() async => await _currentPlayer?.nextVideo();

  Future<void> previousVideo() async => await _currentPlayer?.previousVideo();

  Future<void> seek(int seconds) async => await _currentPlayer?.seek(seconds);

  /// Force immediate status update after command
  Future<void> pollStatus() async => await _currentPlayer?.pollStatus();

  /// Enhanced command execution with immediate polling
  Future<void> _executeCommandWithPoll(Future<void> Function() command) async {
    await command();
    await Future.delayed(const Duration(milliseconds: 20));
    await pollStatus();
  }

  /// Enhanced playback controls that poll immediately after execution
  Future<void> playWithPoll() async => await _executeCommandWithPoll(() => play());
  Future<void> pauseWithPoll() async => await _executeCommandWithPoll(() => pause());
  Future<void> togglePlayPauseWithPoll() async => await _executeCommandWithPoll(() => togglePlayPause());
  Future<void> setVolumeWithPoll(int level) async => await _executeCommandWithPoll(() => setVolume(level));
  Future<void> muteWithPoll() async => await _executeCommandWithPoll(() => mute());
  Future<void> unmuteWithPoll() async => await _executeCommandWithPoll(() => unmute());
  Future<void> nextVideoWithPoll() async => await _executeCommandWithPoll(() => nextVideo());
  Future<void> previousVideoWithPoll() async => await _executeCommandWithPoll(() => previousVideo());
  Future<void> seekWithPoll(int seconds) async => await _executeCommandWithPoll(() => seek(seconds));

  /// Get information about available players
  Future<List<PlayerInfo>> getAvailablePlayers() async => await PlayerFactory.getAvailablePlayers();

  /// Create example configuration files
  Future<void> createExampleConfigurations() async => await PlayerFactory.createExampleConfigurations();

  /// Save a custom player configuration
  Future<void> savePlayerConfiguration(PlayerConfiguration config) async {
    await PlayerFactory.savePlayerConfiguration(config);
  }

  /// Dispose of the manager and clean up resources
  void dispose() {
    disconnect();
    _statusController.close();
    _connectionController.close();
  }
}

class PlayerConnectionStatus {
  final PlayerConnectionState state;
  final String? message;

  PlayerConnectionStatus._(this.state, this.message);

  factory PlayerConnectionStatus.disconnected() => PlayerConnectionStatus._(PlayerConnectionState.disconnected, null);
  factory PlayerConnectionStatus.connecting() => PlayerConnectionStatus._(PlayerConnectionState.connecting, null);
  factory PlayerConnectionStatus.connected() => PlayerConnectionStatus._(PlayerConnectionState.connected, null);
  factory PlayerConnectionStatus.error(String message) => PlayerConnectionStatus._(PlayerConnectionState.error, message);

  bool get isConnected => state == PlayerConnectionState.connected;
  bool get isConnecting => state == PlayerConnectionState.connecting;
  bool get isDisconnected => state == PlayerConnectionState.disconnected;
  bool get hasError => state == PlayerConnectionState.error;
}

enum PlayerConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}
