// Video Player Process Monitor using process_monitor plugin
import 'package:process_monitor/process_monitor.dart';

class VideoPlayerProcessMonitor {
  static VideoPlayerProcessMonitor? _instance;
  static VideoPlayerProcessMonitor get instance => _instance ??= VideoPlayerProcessMonitor._();

  VideoPlayerProcessMonitor._();

  ProcessMonitor? _monitor;
  bool _isMonitoring = false;
  final Set<int> _runningProcesses = <int>{};

  Function(String, int)? onPlayerStarted;
  Function(String, int)? onPlayerStopped;

  static void _onPlayerStart(ProcessEvent event) {
    final instance = VideoPlayerProcessMonitor.instance;
    instance._runningProcesses.add(event.processId);
    // print('Video player started: ${event.processName} (PID: ${event.processId})');
    instance.onPlayerStarted?.call(event.processName, event.processId);
  }

  static void _onPlayerStop(ProcessEvent event) {
    final instance = VideoPlayerProcessMonitor.instance;
    instance._runningProcesses.remove(event.processId);
    // print('Video player stopped: ${event.processName} (PID: ${event.processId})');
    instance.onPlayerStopped?.call(event.processName, event.processId);
  }

  /// Map process name to player type for integration
  static String getPlayerTypeFromProcessName(String processName) {
    final name = processName.toLowerCase();
    if (name.startsWith('vlc')) return 'vlc';
    if (name.startsWith('mpc-hc')) return 'mpc-hc';
    return 'unknown';
  }

  static final List<ProcessConfig> _configs = [
    // VLC Media Player
    ProcessConfig(
      processName: 'vlc.exe',
      onStart: _onPlayerStart,
      onStop: _onPlayerStop,
      allowMultipleStartCallbacks: false,
      allowMultipleStopCallbacks: false,
    ),
    // Media Player Classic - Home Cinema
    ProcessConfig(
      processName: 'mpc-hc.exe', //x86
      onStart: _onPlayerStart,
      onStop: _onPlayerStop,
      allowMultipleStartCallbacks: false,
      allowMultipleStopCallbacks: false,
    ),
    ProcessConfig(
      processName: 'mpc-hc64.exe', //x64
      onStart: _onPlayerStart,
      onStop: _onPlayerStop,
      allowMultipleStartCallbacks: false,
      allowMultipleStopCallbacks: false,
    ),
  ];

  Future<bool> startMonitoring() async {
    if (_isMonitoring) return true;
    try {
      _monitor = ProcessMonitor();
      final started = await _monitor!.startMonitoringProcesses(_configs);
      if (started) _isMonitoring = true;
      return started;
    } catch (e) {
      return false;
    }
  }

  Future<void> stopMonitoring() async {
    if (!_isMonitoring) return;
    try {
      await _monitor?.stopMonitoring();
      _isMonitoring = false;
      _runningProcesses.clear();
    } catch (e) {
      // Ignore errors on stopping
    }
  }

  bool get isMonitoring => _isMonitoring;
  bool get hasRunningPlayers => _runningProcesses.isNotEmpty;
  Set<int> get runningProcesses => Set.unmodifiable(_runningProcesses);
}

class VideoPlayerProcessIntegration {
  static VideoPlayerProcessMonitor? _monitor;

  static Future<bool> initialize({
    required Function() onPlayerDetected,
    required Function() onPlayerStopped,
    Function(String processName, String playerType)? onSpecificPlayerStarted,
    Function(String processName, String playerType)? onSpecificPlayerStopped,
  }) async {
    _monitor = VideoPlayerProcessMonitor.instance;
    _monitor!.onPlayerStarted = (processName, processId) {
      onPlayerDetected();
      final playerType = VideoPlayerProcessMonitor.getPlayerTypeFromProcessName(processName);
      onSpecificPlayerStarted?.call(processName, playerType);
    };
    _monitor!.onPlayerStopped = (processName, processId) {
      onPlayerStopped();
      final playerType = VideoPlayerProcessMonitor.getPlayerTypeFromProcessName(processName);
      onSpecificPlayerStopped?.call(processName, playerType);
    };
    return await _monitor!.startMonitoring();
  }

  static Future<void> stop() async {
    await _monitor?.stopMonitoring();
    _monitor = null;
  }

  static bool get isMonitoring => _monitor?.isMonitoring ?? false;
  static bool get hasRunningPlayers => _monitor?.hasRunningPlayers ?? false;
}
