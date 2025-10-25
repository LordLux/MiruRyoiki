import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:provider/provider.dart';

import '../manager.dart';
import '../models/episode.dart';
import '../models/series.dart';
import '../services/library/library_provider.dart';
import '../services/players/player_manager.dart';
import '../utils/path.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import 'buttons/button.dart';
import 'video_duration_bar.dart';

class Player extends StatefulWidget {
  const Player({super.key});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> with TickerProviderStateMixin {
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _statusSubscription;
  Timer? _updateTimer;
  bool _isPlayerConnected = false;
  bool _expanded = false;

  PlayerManager? get _playerManager => Provider.of<Library>(context, listen: false).playerManager;

  bool get _hasCurrentMedia {
    final status = _playerManager?.lastStatus;
    return status != null && status.filePath.isNotEmpty && status.totalDuration.inSeconds > 0;
  }

  Series? _series;
  Episode? get _currentEpisode {
    if (!_hasCurrentMedia) return null;
    _series = Provider.of<Library>(context, listen: false).getSeriesByPath(PathString(_playerManager?.lastStatus?.filePath ?? ''));
    return _series?.getEpisodeByPath(PathString(_playerManager?.lastStatus?.filePath ?? ''));
  }

  static const Color _whiteColor = Color.fromARGB(255, 208, 208, 208);
  static const Color _grayColor = Color(0xFF8a8a8a);

  @override
  void initState() {
    super.initState();
    _subscribeToConnection();
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _statusSubscription?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }

  void _subscribeToConnection() {
    final library = Provider.of<Library>(context, listen: false);
    _connectionSubscription?.cancel();
    _connectionSubscription = library.playerManager?.connectionStream.listen((status) {
      final connected = status.state == PlayerConnectionState.connected && library.currentConnectedPlayer != null;
      if (connected != _isPlayerConnected) {
        setState(() {
          _isPlayerConnected = connected;
        });
        if (connected) {
          _startPeriodicUpdate();
          _subscribeToStatus();
          _updateExpandedState(); // Update expansion state when connected
        } else {
          _updateTimer?.cancel();
          _statusSubscription?.cancel();
          _expanded = false; // Collapse when disconnected
        }
      }
    });
    // Initial state - use Library's connection state
    _isPlayerConnected = library.playerManager?.isConnected == true && library.currentConnectedPlayer != null;
    if (_isPlayerConnected) {
      _startPeriodicUpdate();
      _subscribeToStatus();
      _updateExpandedState(); // Set initial expansion state
    }
  }

  void _startPeriodicUpdate() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _hasCurrentMedia) {
        _updateExpandedState();
        setState(() {});
      }
    });
  }

  void _subscribeToStatus() {
    final library = Provider.of<Library>(context, listen: false);
    _statusSubscription?.cancel();
    _statusSubscription = library.playerManager?.statusStream.listen((status) {
      if (mounted) {
        _updateExpandedState();
        setState(() {});
      }
    });
  }

  void _updateExpandedState() {
    // Only expand if there's actually current media loaded, not old cached data
    if (_expanded != _hasCurrentMedia) _expanded = _hasCurrentMedia;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 110,
      left: 0,
      child: Builder(builder: (context) {
        if (Manager.settings.enableMediaPlayerIntegration != true) return SizedBox.shrink();

        final library = Provider.of<Library>(context);
        if (library.playerManager?.isConnected != true || library.currentConnectedPlayer == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Opacity(
                opacity: 0.2,
                child: AnimatedAcrylic(
                  duration: gradientChangeDuration,
                  tint: Manager.accentColor,
                  blurAmount: 30,
                  elevation: 4,
                  shadowColor: Colors.black,
                  tintAlpha: 0.1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: AnimatedContainer(
                    duration: mediumDuration,
                    height: _expanded ? 100 : 40,
                    width: ScreenUtils.kNavigationBarWidth + 4,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                bottom: 0,
                child: LayoutBuilder(builder: (context, constraints) {
                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Video duration bar with seek functionality
                      Positioned(
                        bottom: 0,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 40, minWidth: constraints.maxWidth),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 7.0, left: 7.0, right: 7.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Player icon
                                _buildControlButton(_playerManager?.currentPlayer?.iconWidget ?? Icon(Icons.video_library, size: 18, color: _whiteColor), () {}),

                                // Previous button
                                Row(
                                  children: [
                                    _buildControlButton(
                                      Icons.skip_previous,
                                      _hasCurrentMedia
                                          ? () {
                                              final lib = Provider.of<Library>(context, listen: false);
                                              lib.previousCurrentVideo().then((_) {
                                                if (mounted) setState(() {});
                                              });
                                            }
                                          : () {}, // Empty callback when no media
                                    ),
                                    const SizedBox(width: 8),
                                    // Play/Pause button
                                    _buildControlButton(
                                      _hasCurrentMedia && _playerManager?.lastStatus?.isPlaying == true ? Icons.pause : Icons.play_arrow,
                                      _hasCurrentMedia
                                          ? () {
                                              final lib = Provider.of<Library>(context, listen: false);
                                              lib.togglePlayPauseCurrentPlayback().then((_) {
                                                if (mounted) setState(() {});
                                              });
                                            }
                                          : () {}, // Empty callback when no media
                                    ),
                                    const SizedBox(width: 8),
                                    // Next button
                                    _buildControlButton(
                                      Icons.skip_next,
                                      _hasCurrentMedia
                                          ? () {
                                              final lib = Provider.of<Library>(context, listen: false);
                                              lib.nextCurrentVideo().then((_) {
                                                if (mounted) setState(() {});
                                              });
                                            }
                                          : () {}, // Empty callback when no media
                                    ),
                                  ],
                                ),
                                // Mute button
                                _buildControlButton(
                                  _hasCurrentMedia && library.playerManager?.lastStatus?.isMuted == true ? Icons.volume_off : Icons.volume_up,
                                  _hasCurrentMedia
                                      ? () {
                                          final lib = Provider.of<Library>(context, listen: false);
                                          lib.toggleMuteCurrentPlayback().then((_) {
                                            if (mounted) setState(() {});
                                          });
                                        }
                                      : () {}, // Empty callback when no media
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: shortDuration,
                        top: _expanded ? 0 : -15,
                        child: AnimatedOpacity(
                          duration: shortDuration,
                          opacity: _expanded ? 1 : 0,
                          child: Container(
                            width: 300,
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Episode title or file path
                                  Text(
                                    _hasCurrentMedia ? (_currentEpisode?.name ?? _playerManager?.lastStatus?.filePath ?? '') : '',
                                    style: const TextStyle(fontSize: 13, color: _whiteColor),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // Series title if available
                                  if (_hasCurrentMedia && _series?.displayTitle != null)
                                    Text(
                                      _series!.displayTitle,
                                      style: const TextStyle(fontSize: 9, color: _grayColor),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  else
                                    SizedBox(height: 5),

                                  // Video duration bar with seek functionality
                                  VideoDurationBar(
                                    status: _hasCurrentMedia ? library.playerManager?.lastStatus : null,
                                    onSeek: (seconds) async {
                                      final lib = Provider.of<Library>(context, listen: false);
                                      await lib.gotoCurrentVideo(seconds);
                                      setState(() {});
                                    },
                                    onSeekDown: () async {
                                      final lib = Provider.of<Library>(context, listen: false);
                                      await lib.pauseCurrentPlayback();
                                    },
                                    onSeekUp: () async {
                                      final lib = Provider.of<Library>(context, listen: false);
                                      await lib.resumeCurrentPlayback();
                                    },
                                    progressColor: Manager.accentColor.lightest,
                                    thumbColor: Manager.accentColor.light,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildControlButton(dynamic iconOrWidget, VoidCallback onPressed) {
    Widget iconWidget;
    if (iconOrWidget is IconData)
      iconWidget = Icon(iconOrWidget, size: 18, color: _whiteColor);
    else if (iconOrWidget is Widget)
      iconWidget = Padding(padding: const EdgeInsets.all(4.0), child: iconOrWidget);
    else
      iconWidget = Icon(Icons.play_arrow, size: 18, color: _whiteColor);

    return SizedBox.square(
      dimension: 25,
      child: StandardButton(
        isSmall: true,
        padding: EdgeInsets.zero,
        label: iconWidget,
        onPressed: onPressed,
      ),
    );
  }
}
