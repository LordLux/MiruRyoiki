import 'dart:io';
import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show InkWell, Material;
import 'package:miruryoiki/services/navigation/statusbar.dart';
import 'package:miruryoiki/services/player_trackers/mpchc.dart';

import '../manager.dart';
import '../models/episode.dart';
import '../models/series.dart';
import '../utils/logging.dart';
import '../utils/path_utils.dart';
import '../utils/screen_utils.dart';
import '../utils/time_utils.dart';
import 'context_menu/episode.dart';
import 'watched_badge.dart';

class HoverableEpisodeTile extends StatefulWidget {
  final Episode episode;
  final VoidCallback onTap;
  final Series series;

  const HoverableEpisodeTile({
    super.key,
    required this.episode,
    required this.onTap,
    required this.series,
  });

  @override
  State<HoverableEpisodeTile> createState() => _HoverableEpisodeTileState();
}

class _HoverableEpisodeTileState extends State<HoverableEpisodeTile> {
  bool _isHovering = false;
  final GlobalKey<EpisodeContextMenuState> _contextMenuKey = GlobalKey<EpisodeContextMenuState>();

  @override
  Widget build(BuildContext context) {
    return EpisodeContextMenu(
      key: _contextMenuKey,
      series: widget.series,
      episode: widget.episode,
      context: context,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) {
          StatusBarManager().hide();
          setState(() => _isHovering = false);
        },
        onHover: (_) => StatusBarManager().showDelayed(widget.episode.name),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: getDuration(const Duration(milliseconds: 150)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
            boxShadow: _isHovering
                ? [
                    BoxShadow(
                      color: widget.series.dominantColor?.withOpacity(0.05) ?? Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
            child: Stack(
              children: [
                // Episode card content
                Card(
                  padding: EdgeInsets.zero,
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      // Thumbnail or icon
                      ClipRRect(
                        borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
                        child: _buildEpisodeThumbnail(widget.episode),
                      ),

                      // Bottom text overlay
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.85),
                                  Colors.black.withOpacity(0.7),
                                  Colors.black.withOpacity(0),
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                widget.episode.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Watched indicator
                      Positioned(
                        top: 8,
                        right: 8,
                        child: WatchedBadge(isWatched: widget.episode.watched),
                      ),

                      // Progress indicator
                      if (widget.episode.watchedPercentage > 0)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: LayoutBuilder(builder: (context, constraints) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(ScreenUtils.kEpisodeCardBorderRadius), bottomRight: Radius.circular(ScreenUtils.kEpisodeCardBorderRadius)),
                              ),
                              height: 3.5,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(ScreenUtils.kEpisodeCardBorderRadius), bottomRight: Radius.circular(ScreenUtils.kEpisodeCardBorderRadius)),
                                    color: widget.series.dominantColor,
                                  ),
                                  height: 3.5,
                                  width: (widget.episode.watchedPercentage > MPCHCTracker.watchedThreshold ? 1 : widget.episode.watchedPercentage) * constraints.maxWidth,
                                ),
                              ),
                            );
                          }),
                        ),
                    ],
                  ),
                ),
                // Hover and splash overlay
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onSecondaryTapDown: (_) => _contextMenuKey.currentState?.openMenu(),
                      child: InkWell(
                        onTap: widget.onTap,
                        splashColor: widget.series.dominantColor?.withOpacity(0.3),
                        highlightColor: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
                        child: AnimatedContainer(
                          duration: getDuration(const Duration(milliseconds: 150)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
                            color: _isHovering ? Colors.white.withOpacity(0.03) : Colors.transparent,
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
      ),
    );
  }

  bool thumbnailExists(PathString? thumbnailPath) => //
      thumbnailPath != null && thumbnailPath.pathMaybe != null && File(thumbnailPath.path).existsSync();

  Widget _buildEpisodeThumbnail(Episode episode, {Widget? child}) {
    // Prefer cached thumbnail if available
    if (thumbnailExists(episode.thumbnailPath)) {
      final thumbnailWidget = Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(File(episode.thumbnailPath!.path)),
            fit: BoxFit.cover,
          ),
        ),
        child: child,
      );
      // Always blur when thumbnail exists
      return ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: widget.episode.watched ? 0 : 15,
          sigmaY: widget.episode.watched ? 0 : 15,
          tileMode: TileMode.mirror,
        ),
        child: thumbnailWidget,
      );
    }
    // Otherwise, try to load asynchronously
    return _buildThumbnailWithFuture(episode, child);
  }

  Widget _buildThumbnailWithFuture(Episode episode, [Widget? child]) {
    return FutureBuilder<PathString?>(
      future: episode.getThumbnail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Loading: show spinner, no blur
          return Center(
            child: ProgressRing(
              strokeWidth: 2,
              activeColor: Manager.accentColor,
            ),
          );
        }

        final PathString? thumbnailPath = snapshot.data;

        if (thumbnailPath == null || thumbnailPath.pathMaybe == null || !File(thumbnailPath.path).existsSync()) {
          // No thumbnail: show fallback icon, no blur
          return Icon(
            FluentIcons.video,
            size: 32,
            color: FluentTheme.of(context).resources.textFillColorSecondary,
          );
        }

        try {
          // Thumbnail loaded: always blur
          final thumbnailWidget = Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(thumbnailPath.path)),
                fit: BoxFit.cover,
              ),
            ),
            child: child,
          );
          return ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: widget.episode.watched ? 0 : 15,
              sigmaY: widget.episode.watched ? 0 : 15,
              tileMode: TileMode.mirror,
            ),
            child: thumbnailWidget,
          );
        } catch (e, stackTrace) {
          logErr('Error displaying episode thumbnail', e, stackTrace);
          return Icon(
            FluentIcons.error,
            size: 32,
            color: FluentTheme.of(context).resources.textFillColorSecondary,
          );
        }
      },
    );
  }
}
