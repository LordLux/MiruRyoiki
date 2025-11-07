import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart' show PointerScrollEvent;
import 'package:flutter/material.dart' show Icons;
import 'package:glossy/glossy.dart';
import 'package:miruryoiki/widgets/tooltip_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:squiggly_slider/slider.dart';

import '../main.dart';
import '../manager.dart';
import '../models/episode.dart';
import '../models/players/mediastatus.dart';
import '../models/series.dart';
import '../services/library/library_provider.dart';
import '../services/players/player_manager.dart';
import '../utils/path.dart';
import '../utils/screen.dart';
import '../utils/shell.dart';
import '../utils/time.dart';
import 'buttons/button.dart';
import 'frosted_noise.dart';
import 'video_duration_bar.dart';

class Player extends StatefulWidget {
  const Player({super.key});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> with TickerProviderStateMixin {
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _statusSubscription;
  bool _isPlayerConnected = false;
  bool _verticallyExpanded = false;
  bool _horizontallyExpanded = false;
  bool _isHoveringVolume = false;
  int _currentVolume = 50;
  String? _lastPath;
  ImageProvider? posterImage;

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
    super.dispose();
  }

  void _subscribeToConnection() {
    final library = Provider.of<Library>(context, listen: false);
    _connectionSubscription?.cancel();
    _connectionSubscription = library.playerManager?.connectionStream.listen((status) {
      final connected = status.state == PlayerConnectionState.connected && library.currentConnectedPlayer != null;
      if (connected != _isPlayerConnected) {
        setState(() => _isPlayerConnected = connected);

        if (connected) {
          // _startPeriodicUpdate();
          _subscribeToStatus();
          _updateExpandedState(); // Update expansion state when connected
        } else {
          // _updateTimer?.cancel();
          _statusSubscription?.cancel();
          _verticallyExpanded = false; // Collapse when disconnected
        }
      }
    });
    // Initial state - use Library's connection state
    _isPlayerConnected = library.playerManager?.isConnected == true && library.currentConnectedPlayer != null;
    if (_isPlayerConnected) {
      _subscribeToStatus();
      _updateExpandedState(); // Set initial expansion state
    }
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
    if (_verticallyExpanded != _hasCurrentMedia) _verticallyExpanded = _hasCurrentMedia && _horizontallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    _horizontallyExpanded = !(homeKey.currentState?.isCompactView ?? false);
    if (!_horizontallyExpanded) _verticallyExpanded = false;
    return AnimatedPositioned(
      duration: shortDuration,
      curve: Curves.easeInOutBack,
      bottom: _horizontallyExpanded ? 110 : 100,
      left: 0,
      child: Builder(builder: (context) {
        if (Manager.settings.enableMediaPlayerIntegration != true) return SizedBox.shrink();

        return Selector<Library, ({bool isConnected, String? playerName, MediaStatus? status})>(
            selector: (_, library) => (
                  isConnected: library.playerManager?.isConnected ?? false,
                  playerName: library.currentConnectedPlayer,
                  status: library.playerManager?.lastStatus,
                ),
            builder: (context, data, _) {
              if (!data.isConnected || data.playerName == null) return const SizedBox.shrink();

              return TooltipWrapper(
                tooltip: (_hasCurrentMedia) ? null : 'Player is open with no media.\nPlay a video to enable playback controls.',
                child: (_) => GestureDetector(
                  onTap: () {
                    // Bring the player window to foreground
                    final status = data.status;
                    if (status != null && status.filePath.isNotEmpty && _hasCurrentMedia) ShellUtils.focusPlayerWindowByFilePath(status.filePath);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: 0.2,
                          child: FrostedNoise(
                            child: AnimatedContainer(
                              duration: dimDuration,
                              curve: Cubic(0.48, 0.1, 0.2, 0.95),
                              height: _verticallyExpanded
                                  ? 110
                                  : _hasCurrentMedia
                                      ? 50
                                      : 40,
                              width: _horizontallyExpanded ? ScreenUtils.kNavigationBarWidth + 8 : 37,
                              decoration: BoxDecoration(
                                color: (Manager.currentDominantColor ?? Manager.accentColor).lerpWith(Colors.black.withOpacity(.4), 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          bottom: 0,
                          child: LayoutBuilder(builder: (context, constraints) {
                            return AnimatedOpacity(
                              duration: shortDuration,
                              opacity: _horizontallyExpanded ? 1.0 : 0.0,
                              child: Stack(
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
                                            SizedBox.square(dimension: 25),
                                            
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
                                            // Volume control with slider
                                            SizedBox.square(dimension: 25),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  AnimatedPositioned(
                                    duration: shortDuration,
                                    top: _verticallyExpanded ? 0 : -15,
                                    child: Container(
                                      width: constraints.maxWidth - 14,
                                      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 0.0),
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Episode title or file path
                                            Row(
                                              children: [
                                                _playerSeriesPosterPreviewImage(status: data.status, placeholder: true),
                                                const SizedBox(width: 2),
                                                Expanded(
                                                  child: AnimatedOpacity(
                                                    duration: shortDuration,
                                                    opacity: _verticallyExpanded ? 1 : 0,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(left: 8, top: 2),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            _hasCurrentMedia ? (_currentEpisode?.name ?? _playerManager?.lastStatus?.filePath ?? '') : '',
                                                            style: const TextStyle(fontSize: 13, color: _whiteColor),
                                                            overflow: TextOverflow.ellipsis,
                                                            softWrap: false,
                                                            maxLines: 1,
                                                          ), // Series title if available
                                                          if (_hasCurrentMedia && _series?.displayTitle != null) ...[
                                                            SizedBox(height: 2),
                                                            Text(
                                                              _series!.displayTitle,
                                                              style: const TextStyle(fontSize: 9, color: _grayColor),
                                                              overflow: TextOverflow.ellipsis,
                                                              softWrap: false,
                                                              maxLines: 1,
                                                            )
                                                          ],
                                                          SizedBox(height: 5),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // Video duration bar with seek functionality
                                            AnimatedOpacity(
                                              duration: shortDuration,
                                              opacity: _verticallyExpanded ? 1 : 0,
                                              child: Padding(
                                                padding: EdgeInsets.only(left: 2, top: 3),
                                                child: VideoDurationBar(
                                                  status: _hasCurrentMedia ? data.status : null,
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
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                        Positioned(
                          bottom: 7,
                          left: 7,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: ((_series == null || _currentEpisode == null) && !_horizontallyExpanded) || _horizontallyExpanded ? 1.0 : 0.0,
                            child: _buildControlButton(_playerManager?.currentPlayer?.iconWidget ?? Icon(Icons.video_library, size: 18, color: _whiteColor), () {})),
                        ),
                        Positioned(
                          top: 7,
                          left: 7,
                          child: Padding(
                            padding: EdgeInsets.only(right: 7, bottom: 7),
                            child: _playerSeriesPosterPreviewImage(status: data.status, placeholder: false),
                          ),
                        ),
                        Positioned(
                          bottom: 7,
                          right: 7,
                          child: IgnorePointer(
                            ignoring: !_horizontallyExpanded,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: _horizontallyExpanded ? 1.0 : 0.0,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: _isHoveringVolume ? 100 : 25,
                                child: MouseRegion(
                                  onEnter: (_) => !_hasCurrentMedia ? null : setState(() => _isHoveringVolume = true),
                                  onExit: (_) => !_hasCurrentMedia ? null : setState(() => _isHoveringVolume = false),
                                  child: Listener(
                                    onPointerSignal: (data.status?.filePath.isEmpty ?? false)
                                        ? null
                                        : (event) {
                                            if (event is PointerScrollEvent && _hasCurrentMedia) {
                                              final delta = event.scrollDelta.dy;
                                              final newVolume = (_currentVolume + (delta > 0 ? -5 : 5)).clamp(0, 100);
                                              final lib = Provider.of<Library>(context, listen: false);
                                              lib.setPlaybackVolume(newVolume.toInt()).then((_) {
                                                if (mounted) setState(() {});
                                              });
                                            }
                                          },
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        // Volume slider
                                        AnimatedPositioned(
                                          duration: const Duration(milliseconds: 200),
                                          curve: Curves.easeOutCubic,
                                          bottom: !_hasCurrentMedia || _isHoveringVolume ? 28 : 15,
                                          right: 0,
                                          child: IgnorePointer(
                                            ignoring: !_hasCurrentMedia || !_isHoveringVolume,
                                            child: AnimatedOpacity(
                                              duration: const Duration(milliseconds: 200),
                                              opacity: !_hasCurrentMedia || !_isHoveringVolume ? 0.0 : 1.0,
                                              child: SizedBox(
                                                width: 25,
                                                height: 70,
                                                child: LayoutBuilder(builder: (context, constraints) {
                                                  return GlossyContainer(
                                                    width: constraints.maxWidth,
                                                    height: constraints.maxHeight,
                                                    opacity: 0.1,
                                                    strengthX: 20,
                                                    strengthY: 20,
                                                    border: Border.all(
                                                      color: Colors.white.withOpacity(.25),
                                                      width: 0.75,
                                                    ),
                                                    blendMode: BlendMode.src,
                                                    borderRadius: BorderRadius.circular(4),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
                                                      child: RotatedBox(
                                                        quarterTurns: 3,
                                                        child: SquigglySlider(
                                                          value: _currentVolume.toDouble(),
                                                          min: 0,
                                                          max: 100,
                                                          padding: EdgeInsets.zero,
                                                          activeColor: Manager.currentDominantColor ?? Manager.accentColor,
                                                          inactiveColor: const Color(0xFF595959).lerpWith(Manager.currentDominantColor ?? Manager.accentColor, 0.5).withOpacity(0.5),
                                                          squiggleAmplitude: 0,
                                                          thumbsSize: Size(10, 0),
                                                          onChanged: _hasCurrentMedia
                                                              ? (value) {
                                                                  final lib = Provider.of<Library>(context, listen: false);
                                                                  lib.setPlaybackVolume(value.toInt()).then((_) {
                                                                    if (mounted) setState(() {});
                                                                  });
                                                                }
                                                              : null,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Actual volume button
                                        Builder(builder: (context) {
                                          _currentVolume = _playerManager?.lastStatus?.volumeLevel ?? 50;
                                          final isMuted = _playerManager?.lastStatus?.isMuted ?? false;
                                          return SizedBox(
                                            width: 25,
                                            height: 25,
                                            child: StandardButton(
                                              isButtonDisabled: !_hasCurrentMedia,
                                              cursor: _hasCurrentMedia ? null : SystemMouseCursors.basic,
                                              isSmall: true,
                                              padding: EdgeInsets.zero,
                                              label: Icon(isMuted ? Icons.volume_off : Icons.volume_up, size: 18, color: _whiteColor),
                                              onPressed: _hasCurrentMedia
                                                  ? () {
                                                      final lib = Provider.of<Library>(context, listen: false);
                                                      lib.toggleMuteCurrentPlayback().then((_) {
                                                        if (mounted) setState(() {});
                                                      });
                                                    }
                                                  : null,
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
      }),
    );
  }

  Widget _playerSeriesPosterPreviewImage({MediaStatus? status, bool placeholder = false}) {
    final episode = _currentEpisode;
    final series = _series;

    // If no episode or series is linked, return a shrinked SizedBox
    if (episode == null || series == null || !_hasCurrentMedia) return const SizedBox.shrink();

    // Check if the path has changed and rebuild if necessary
    final currentPath = status?.filePath ?? '';
    if (_lastPath != currentPath) _lastPath = currentPath;
    final w = _horizontallyExpanded ? 30.0 : 23.5;
    final h = _horizontallyExpanded ? 43.0 : 36.0;

    if (placeholder) return SizedBox(width: w, height: h);

    return FutureBuilder(
      key: ValueKey(currentPath), // Rebuild when path changes
      future: series.getPosterImage(),
      initialData: posterImage,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && posterImage == null) {
          // Show a loading placeholder
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: ProgressRing(strokeWidth: 2),
              ),
            ),
          );
        }
        final oldImage = posterImage;
        posterImage = snapshot.data;

        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: posterImage != null
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: w,
                  height: h,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: posterImage!,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
              : oldImage != null
                  ? AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: w,
                      height: h,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: oldImage,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                  : AnimatedContainer(
                      width: w,
                      height: h,
                      color: Colors.grey,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white.withOpacity(0.5),
                        size: 24,
                      ),
                    ),
        );
      },
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
        isButtonDisabled: !_hasCurrentMedia,
        cursor: _hasCurrentMedia ? null : SystemMouseCursors.basic,
        padding: EdgeInsets.zero,
        label: iconWidget,
        onPressed: onPressed,
      ),
    );
  }
}
