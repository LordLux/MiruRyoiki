import 'dart:async';
import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:provider/provider.dart';

import '../manager.dart';
import '../models/episode.dart';
import '../models/players/player_configuration.dart';
import '../models/series.dart';
import '../services/library/library_provider.dart';
import '../services/players/player_manager.dart';
import '../utils/path_utils.dart';
import '../utils/screen_utils.dart';
import '../utils/time_utils.dart';
import 'buttons/button.dart';
import 'video_duration_bar.dart';

class Player extends StatefulWidget {
  final bool expanded;

  const Player({
    super.key,
    this.expanded = false,
  });

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> with TickerProviderStateMixin {
  StreamSubscription? _statusSubscription;

  PlayerManager? get _playerManager => Provider.of<Library>(context, listen: false).playerManager;

  Series? _series;
  Episode? get _currentEpisode {
    _series = Provider.of<Library>(context, listen: false).getSeriesByPath(PathString(_playerManager?.lastStatus?.filePath ?? ''));
    return _series?.getEpisodeByPath(PathString(_playerManager?.lastStatus?.filePath ?? ''));
  }

  static const Color _whiteColor = Color.fromARGB(255, 208, 208, 208);
  static const Color _grayColor = Color(0xFF8a8a8a);

  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _setupStatusSubscription();
    // Periodically update the UI to reflect playback progress
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _playerManager?.lastStatus != null) setState(() {}); // Update every second if playing something
    });
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }

  void _setupStatusSubscription() {
    final library = Provider.of<Library>(context, listen: false);

    // Listen to player status stream for background updates
    _statusSubscription?.cancel();
    _statusSubscription = library.playerManager?.statusStream.listen(
      (status) {
        // Update UI even when app is not focused
        if (mounted) {
          setState(() {
            // Force rebuild to update play/pause buttons and progress
          });
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reestablish subscription when dependencies change (e.g., new playerManager)
    _setupStatusSubscription();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 110,
      left: 0,
      child: Builder(builder: (context) {
        if (Manager.settings.enableMediaPlayerIntegration != true) return SizedBox.shrink();

        final library = Provider.of<Library>(context);
        if (library.playerManager?.isConnected != true) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Opacity(
                opacity: 0.2,
                child: Acrylic(
                  tint: Manager.accentColor,
                  blurAmount: 30,
                  elevation: 4,
                  shadowColor: Colors.black,
                  tintAlpha: 0.1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: AnimatedContainer(
                    duration: shortDuration,
                    height: widget.expanded ? 100 : 40,
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
                                      () async {
                                        final lib = Provider.of<Library>(context, listen: false);
                                        await lib.previousCurrentVideo();
                                        setState(() {});
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    // Play/Pause button
                                    _buildControlButton(
                                      _playerManager?.lastStatus?.isPlaying == true ? Icons.pause : Icons.play_arrow,
                                      () async {
                                        final lib = Provider.of<Library>(context, listen: false);
                                        await lib.togglePlayPauseCurrentPlayback();
                                        setState(() {});
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    // Next button
                                    _buildControlButton(
                                      Icons.skip_next,
                                      () async {
                                        final lib = Provider.of<Library>(context, listen: false);
                                        await lib.nextCurrentVideo();
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                                // Mute button
                                _buildControlButton(
                                  library.playerManager?.lastStatus?.isMuted == true ? Icons.volume_off : Icons.volume_up,
                                  () async {
                                    final lib = Provider.of<Library>(context, listen: false);
                                    await lib.toggleMuteCurrentPlayback();
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: shortDuration,
                        top: widget.expanded ? 0 : -15,
                        child: AnimatedOpacity(
                          duration: shortDuration,
                          opacity: widget.expanded ? 1 : 0,
                          child: Container(
                            width: 300,
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentEpisode?.name ?? _playerManager?.lastStatus?.filePath ?? '',
                                    style: const TextStyle(fontSize: 13, color: _whiteColor),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (_series?.displayTitle != null)
                                    Text(
                                      _series!.displayTitle,
                                      style: const TextStyle(fontSize: 9, color: _grayColor),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  else
                                    SizedBox(height: 5),
                                  VideoDurationBar(
                                    status: library.playerManager?.lastStatus,
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
                                    progressColor: Manager.accentColor,
                                    backgroundColor: _whiteColor,
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
    if (iconOrWidget is IconData) {
      iconWidget = Icon(iconOrWidget, size: 18, color: _whiteColor);
    } else if (iconOrWidget is Widget) {
      iconWidget = iconOrWidget;
    } else {
      iconWidget = Icon(Icons.play_arrow, size: 18, color: _whiteColor);
    }

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

  Widget _getCurrentPlayerIcon() {
    try {
      final playerManager = _playerManager;
      if (playerManager?.isConnected == true) {
        // Try to determine player type from the last status or connection info
        // For VLC, check if we're using the VLC default port or other VLC indicators
        // For MPC-HC, check if we're using MPC-HC default port
        // This is a heuristic approach since we don't have direct access to player type

        // Check if there's any way to determine from the PlayerManager
        // For now, return a generic connected player icon
        return SizedBox(
          width: 18,
          height: 18,
          child: Icon(Icons.play_circle, size: 18, color: _whiteColor),
        );
      }
    } catch (e) {
      // Fallback
    }

    return SizedBox(
      width: 18,
      height: 18,
      child: Icon(Icons.video_library, size: 18, color: _whiteColor),
    );
  }
}
