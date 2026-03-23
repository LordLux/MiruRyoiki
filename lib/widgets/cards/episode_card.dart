import 'dart:io';
import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show InkWell, Material;
import 'package:flutter_desktop_context_menu/flutter_desktop_context_menu.dart';
import 'package:miruryoiki/services/anilist/provider/anilist_provider.dart';
import 'package:miruryoiki/services/navigation/show_info.dart';
import 'package:miruryoiki/services/navigation/statusbar.dart';
import 'package:miruryoiki/utils/color.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../manager.dart';
import '../../models/anilist/mapping.dart';
import '../../models/ui_episode.dart';
import '../../models/episode.dart';
import '../../models/series.dart';
import '../../services/library/library_provider.dart';
import '../../utils/logging.dart';
import '../../utils/path.dart';
import '../../utils/screen.dart';
import '../../utils/time.dart';
import '../context_menu/episode.dart';
import '../context_menu/controller.dart';
import '../play_button.dart';

class HoverableEpisodeTile extends StatefulWidget {
  final UIEpisode uiEpisode;
  final VoidCallback onTap;
  final Series? series;
  final bool isReloadingSeries;
  final AnilistMapping? mapping;

  /// Called when the user wants to change the Sonarr episode link via context menu
  final void Function(UIEpisode)? onChangeSonarrLink;

  /// Called when the user wants to link a released episode to a local file
  final void Function(UIEpisode)? onLinkLocalFile;

  const HoverableEpisodeTile({
    super.key,
    required this.uiEpisode,
    required this.onTap,
    required this.series,
    required this.mapping,
    this.isReloadingSeries = false,
    this.onChangeSonarrLink,
    this.onLinkLocalFile,
  });

  @override
  State<HoverableEpisodeTile> createState() => _HoverableEpisodeTileState();
}

class _HoverableEpisodeTileState extends State<HoverableEpisodeTile> {
  bool _isHovering = false;
  late final DesktopContextMenuController _menuController;

  @override
  void initState() {
    super.initState();
    _menuController = DesktopContextMenuController();
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anilistProivder = Provider.of<AnilistProvider>(context, listen: false);

    final childWidget = MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) {
        StatusBarManager().hide();
        setState(() => _isHovering = false);
      },
      onHover: (_) {
        final String text;
        if (widget.isReloadingSeries) {
          text = "Reloading series, please wait...";
        } else if (widget.uiEpisode.localEpisode != null) {
          text = widget.uiEpisode.localEpisode!.path.fileName ?? widget.uiEpisode.localEpisode!.name;
        } else {
          text = widget.uiEpisode.displayTitle;
        }
        StatusBarManager().showDelayed(text);
      },
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: shortDuration,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
          boxShadow: _isHovering
              ? [
                  BoxShadow(
                    color: Manager.currentDominantColor?.withOpacity(0.05) ?? Colors.black.withOpacity(0.1),
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
                      child: _buildEpisodeThumbnail(widget.uiEpisode.localEpisode),
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
                            child: Builder(builder: (context) {
                              var text = widget.uiEpisode.displayTitle;
                              final epNum = widget.uiEpisode.displayEpisodeNumber;
                              final fallbackTitle = 'Episode $epNum';
                              final hasKnownTitle = text != fallbackTitle;

                              if (widget.isReloadingSeries) {
                                return Shimmer.fromColors(
                                  baseColor: Colors.white.withOpacity(0.3),
                                  highlightColor: Colors.white.withOpacity(0.7),
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 2),
                                    width: double.infinity,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }

                              // Styling based on episode state
                              final Color textColor;
                              final FontWeight fontWeight;
                              final FontStyle fontStyle;

                              if (!hasKnownTitle) {
                                textColor = Colors.white.withOpacity(0.7);
                                fontWeight = FontWeight.w400;
                                fontStyle = FontStyle.italic;
                              } else if (widget.uiEpisode.localEpisode != null) {
                                textColor = Colors.white;
                                fontWeight = FontWeight.w600;
                                fontStyle = FontStyle.normal;
                              } else if (widget.uiEpisode.isFuture) {
                                textColor = Colors.white.withOpacity(0.6);
                                fontWeight = FontWeight.w400;
                                fontStyle = FontStyle.italic;
                              } else {
                                // Released
                                textColor = Colors.white.withOpacity(0.85);
                                fontWeight = FontWeight.w500;
                                fontStyle = FontStyle.normal;
                              }

                              return Text(
                                text,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: fontWeight,
                                  fontStyle: fontStyle,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              );
                            }),
                          ),
                        ),
                      ),
                    ),

                    // Top-left badge
                    Builder(builder: (context) {
                      return Positioned(
                        left: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          constraints: const BoxConstraints(maxWidth: 120),
                          decoration: BoxDecoration(
                            color: Manager.currentDominantColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Transform.translate(
                            offset: const Offset(0, -1),
                            child: Text(
                              widget.uiEpisode.episodeNumber > 0 ? widget.uiEpisode.badgeLabel : widget.uiEpisode.shortTitle,
                              style: TextStyle(color: getTextColorBasedOnAccent(darkColor: const Color.fromARGB(255, 14, 14, 14)), fontSize: 12, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      );
                    }),

                    // Progress indicator
                    if (widget.uiEpisode.localEpisode != null)
                      ValueListenableBuilder<double>(
                        valueListenable: widget.uiEpisode.localEpisode!.progressNotifier,
                        builder: (context, progressValue, _) {
                          if (progressValue <= 0) return const SizedBox.shrink();
                          return Positioned(
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
                                  child: AnimatedContainer(
                                    duration: shortStickyHeaderDuration,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(ScreenUtils.kEpisodeCardBorderRadius), bottomRight: Radius.circular(ScreenUtils.kEpisodeCardBorderRadius)),
                                      color: Manager.currentDominantColor,
                                    ),
                                    height: 3.5,
                                    width: (progressValue > Library.progressThreshold ? 1 : progressValue) * constraints.maxWidth,
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                  ],
                ),
              ),
              // Hover and splash overlay
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onSecondaryTapDown: (details) {
                      if (widget.uiEpisode.localEpisode != null) {
                        _menuController.open();
                      } else if (widget.uiEpisode.isReleased) {
                        _showReleasedMenu();
                      } else if (widget.uiEpisode.isFuture) {
                        _showFutureMenu();
                      }
                    },
                    child: InkWell(
                      onTap: widget.uiEpisode.isFuture ? null : widget.onTap,
                      splashColor: widget.series?.localPosterColor?.withOpacity(0.3),
                      highlightColor: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
                      child: AnimatedContainer(
                        duration: shortDuration,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
                          color: _isHovering ? Colors.white.withOpacity(0.03) : Colors.transparent,
                        ),
                        child: Center(
                          child: widget.uiEpisode.localEpisode == null
                              ? AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: _isHovering ? 1.0 : 0.0,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      widget.uiEpisode.isFuture ? FluentIcons.ringer : FluentIcons.download,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Play button
              if (widget.uiEpisode.localEpisode != null)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: PlayButton(
                    key: ValueKey('play_${widget.uiEpisode.localEpisode!.path.path}'),
                    episode: widget.uiEpisode.localEpisode!,
                    forceExpand: _isHovering,
                    isNextEpisodeToPlay: widget.series != null && widget.uiEpisode.localEpisode == Manager.anilistProgress.getNextEpisodeToWatch(widget.series!, anilistProivder),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (widget.uiEpisode.localEpisode != null && widget.series != null) {
      return EpisodeContextMenu(
        controller: _menuController,
        series: widget.series!,
        episode: widget.uiEpisode.localEpisode!,
        uiEpisode: widget.uiEpisode,
        onChangeSonarrLink: widget.onChangeSonarrLink,
        context: context,
        onEpisodeChanged: () {
          if (mounted) setState(() {});
        },
        child: childWidget,
      );
    }
    return childWidget;
  }

  void _showReleasedMenu() {
    popUpContextMenu(Menu(items: [
      MenuItem(
        label: 'Search for Download',
        onClick: (_) => widget.onTap(),
      ),
      if (widget.onLinkLocalFile != null) ...[
        MenuItem.separator(),
        MenuItem(
          label: 'Link to Local File...',
          onClick: (_) => widget.onLinkLocalFile!(widget.uiEpisode),
        ),
      ],
    ]));
  }

  void _showFutureMenu() {
    final airDate = widget.uiEpisode.airDate;
    final label = airDate != null ? 'Set Reminder (${widget.uiEpisode.stateDescription})' : 'Set Reminder';
    popUpContextMenu(Menu(items: [
      MenuItem(
        label: label,
        onClick: (_) => snackBar('Reminders are not yet available.', severity: InfoBarSeverity.warning),
      ),
    ]));
  }

  bool thumbnailExists(PathString? thumbnailPath) => thumbnailPath != null && thumbnailPath.pathMaybe != null && File(thumbnailPath.path).existsSync();

  Widget _buildEpisodeThumbnail(Episode? episode, {Widget? child}) {
    if (episode == null) {
      return Container(
        color: Colors.black.withOpacity(0.2),
        child: Center(
          child: Icon(
            widget.uiEpisode.isFuture ? FluentIcons.clock : FluentIcons.calendar,
            size: 32,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      );
    }

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
          sigmaX: widget.uiEpisode.watched ? 0 : 15,
          sigmaY: widget.uiEpisode.watched ? 0 : 15,
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
        final PathString? thumbnailPath = snapshot.data;
        final bool isLoading = snapshot.connectionState == ConnectionState.waiting;
        final bool hasThumbnail = thumbnailPath != null && thumbnailPath.pathMaybe != null && File(thumbnailPath.path).existsSync();

        Widget builder(BuildContext context) {
          if (isLoading) {
            // Loading: show spinner, no blur
            return Center(
              child: ProgressRing(
                strokeWidth: 2,
                activeColor: widget.mapping?.effectivePrimaryColorSync() ?? Manager.accentColor,
              ),
            );
          }

          if (!hasThumbnail) {
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
                sigmaX: widget.uiEpisode.watched ? 0 : 15,
                sigmaY: widget.uiEpisode.watched ? 0 : 15,
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
        }

        try {
          final key = hasThumbnail
              ? 'thumbnail'
              : isLoading
                  ? 'loading'
                  : 'fallback';
          return AnimatedSwitcher(
            duration: mediumDuration,
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  ...previousChildren.where((element) => element.key != currentChild?.key),
                  if (currentChild != null) currentChild,
                ],
              );
            },
            child: Builder(
              key: ValueKey(key + episode.path.path),
              builder: builder,
            ),
          );
        } catch (_) {
          log('Error building episode thumbnail switcher, falling back to direct build');
          return builder(context);
        }
      },
    );
  }
}
