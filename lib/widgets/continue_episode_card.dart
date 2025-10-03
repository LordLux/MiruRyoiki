import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show InkWell, Material;
import 'package:miruryoiki/widgets/frosted_noise.dart';
import 'package:transparent_image/transparent_image.dart';
import '../enums.dart';
import '../manager.dart';

import '../models/episode.dart';
import '../models/series.dart';
import '../services/navigation/statusbar.dart';
import '../utils/color.dart';
import '../utils/logging.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import 'context_menu/series.dart';
import 'hidden.dart';

class ContinueEpisodeCard extends StatefulWidget {
  final Series series;
  final Episode episode;
  final Alignment posterAlignment;
  final VoidCallback? onTap;
  final double? progress;

  const ContinueEpisodeCard({
    super.key,
    required this.series,
    required this.episode,
    this.onTap,
    this.progress,
    this.posterAlignment = Alignment.center,
  });

  @override
  State<ContinueEpisodeCard> createState() => _ContinueEpisodeCardState();
}

class _ContinueEpisodeCardState extends State<ContinueEpisodeCard> {
  bool _isHovering = false;
  bool _loading = true;
  bool _hasError = false;
  ImageProvider? _posterImageProvider;
  ImageSource? _lastKnownDefaultSource;
  final GlobalKey<SeriesContextMenuState> _contextMenuKey = GlobalKey<SeriesContextMenuState>();

  @override
  void initState() {
    super.initState();
    _loadImage();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.series.effectivePosterPath != null && //
          widget.series.preferredPosterSource == ImageSource.autoAnilist &&
          widget.series.anilistPosterUrl != null) {
        _loadImage(); // Re-evaluate after initial build
      }
    });
  }

  @override
  void didUpdateWidget(ContinueEpisodeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.series != widget.series) _loadImage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if the default poster source changed (from settings)
    final currentDefaultSource = Manager.defaultPosterSource;
    if (_lastKnownDefaultSource != currentDefaultSource) {
      _lastKnownDefaultSource = currentDefaultSource;
      if (widget.series.preferredPosterSource == null) {
        // If using default source and it changed, reload the image
        _loadImage();
      }
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      _posterImageProvider = await widget.series.getPosterImage();
    } catch (e, stackTrace) {
      logErr('Failed to load series poster image', e, stackTrace);
      _posterImageProvider = null;
      _hasError = true;
    }

    if (mounted) setState(() => _loading = false);
  }

  Widget _getSeriesImage() {
    Widget loadingWidget = const Center(child: ProgressRing(strokeWidth: 3));

    Widget noImageWidget = LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: widget.posterAlignment,
        child: SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxWidth * 1.05,
          child: Icon(FluentIcons.file_image, size: constraints.maxWidth * 0.25),
        ),
      ),
    );

    // If loading and we have an image provider already, keep showing the image
    // This prevents flickering when the app regains focus
    if (_loading && _posterImageProvider != null) {
      return FadeInImage(
        placeholder: MemoryImage(kTransparentImage),
        image: _posterImageProvider!,
        fit: BoxFit.fitWidth,
        alignment: widget.posterAlignment,
        fadeInDuration: getDuration(const Duration(milliseconds: 250)),
        fadeInCurve: Curves.easeIn,
        imageErrorBuilder: (context, error, stackTrace) => noImageWidget,
      );
    }

    if (_loading) return loadingWidget;

    if (_hasError || _posterImageProvider == null) return noImageWidget;

    return FadeInImage(
      placeholder: MemoryImage(kTransparentImage),
      image: _posterImageProvider!,
      fit: BoxFit.fitWidth,
      alignment: widget.posterAlignment,
      fadeInDuration: getDuration(const Duration(milliseconds: 250)),
      fadeInCurve: Curves.easeIn,
      imageErrorBuilder: (context, error, stackTrace) => noImageWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor;
    switch (Manager.settings.libColView) {
      case LibraryColorView.alwaysDominant:
        mainColor = widget.series.dominantColor ?? Manager.genericGray;
        break;
      case LibraryColorView.hoverDominant:
        mainColor = _isHovering ? (widget.series.dominantColor ?? Manager.genericGray) : Manager.genericGray;
        break;
      case LibraryColorView.alwaysAccent:
        mainColor = Manager.accentColor;
        break;
      case LibraryColorView.hoverAccent:
        mainColor = _isHovering ? Manager.accentColor : Manager.genericGray;
        break;
      case LibraryColorView.none:
        mainColor = Manager.genericGray;
        break;
    }
    return KeyedSubtree(
      key: ValueKey('${widget.series.path}-${widget.series.dominantColor?.value ?? 0}'),
      child: SeriesContextMenu(
        key: _contextMenuKey,
        series: widget.series,
        context: context,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) {
            StatusBarManager().hide();
            setState(() => _isHovering = false);
          },
          onHover: (_) {
            // print('isDisplayTitleSimple: ${widget.episode.isDisplayTitleSimple}, isTitleParsable: ${widget.episode.isTitleParsable}, displayTitle: "${widget.episode.displayTitle}"');
            StatusBarManager().showDelayed("Episode ${widget.episode.episodeNumber ?? '?'}${!widget.episode.isDisplayTitleSimple && widget.episode.isTitleParsable && widget.episode.displayTitle != null ? ' - ${widget.episode.displayTitle}' : ''}");
          },
          cursor: SystemMouseCursors.click,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8.02)),
            child: AnimatedContainer(
              duration: getDuration(const Duration(milliseconds: 150)),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8.02)),
                color: Colors.transparent,
                boxShadow: _isHovering
                    ? [
                        BoxShadow(
                          color: mainColor.withOpacity(0.05),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  // Poster image
                  Positioned.fill(
                    child: Container(
                      child: _getSeriesImage(),
                    ),
                  ),
                  // to fix visual glitch
                  // Positioned(
                  //   bottom: 0,
                  //   child: Container(
                  //     color: Colors.black,
                  //     height: 1,
                  //     width: 1000,
                  //   ),
                  // ),
                  Card(
                    padding: EdgeInsets.zero,
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Poster image
                        Expanded(child: SizedBox.shrink()),

                        // Series info
                        Builder(builder: (context) {
                          final double value = widget.series.isAnilistPoster ? .76 : .9;
                          final Color nicerColor = mainColor.lerpWith(Colors.grey, value);

                          Widget child = Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.series.name,
                                  maxLines: 2,
                                  style: Manager.bodyStrongStyle.copyWith(fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Show episode title only if it's not a generic "Episode X" title
                                if (!widget.episode.isDisplayTitleSimple && widget.episode.isTitleParsable && widget.episode.displayTitle != null) ...[
                                  SizedBox(height: 4),
                                  Opacity(
                                    opacity: 0.8,
                                    child: Text(
                                      widget.episode.displayTitle!,
                                      maxLines: 3,
                                      style: Manager.miniBodyStyle.copyWith(
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.italic,
                                        fontSize: Manager.miniBodyStyle.fontSize! * 1.15,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    const SizedBox.shrink(),
                                    const Spacer(),
                                    Text(
                                      'Episode ${widget.episode.episodeNumber ?? '?'}',
                                      style: Manager.captionStyle.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: lighten(widget.series.dominantColor ?? FluentTheme.of(context).resources.textFillColorSecondary, .4),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                if (widget.progress != null && widget.progress != 0.0) ...[
                                  VDiv(8),
                                  SizedBox(
                                    width: 200,
                                    child: ProgressBar(
                                      strokeWidth: 3.5,
                                      value: widget.series.watchedPercentage * 100,
                                      activeColor: widget.series.watchedPercentage == 0 ? Colors.transparent : widget.series.dominantColor,
                                      backgroundColor: Color.lerp(Colors.black.withOpacity(0.2), widget.series.dominantColor, 0),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          );
                          if (widget.series.isAnilistPoster) {
                            return Transform.scale(
                              scale: 1.02,
                              child: Transform.translate(
                                offset: Offset(0, 1),
                                child: Acrylic(
                                  blurAmount: 5,
                                  tint: nicerColor,
                                  elevation: 0.5,
                                  tintAlpha: 0.5,
                                  luminosityAlpha: 0.8,
                                  child: FrostedNoise(child: child),
                                ),
                              ),
                            );
                          }
                          return Container(color: nicerColor, child: child);
                        }),
                      ],
                    ),
                  ),

                  // Anilist hidden indicator
                  if (widget.series.isAnilistHidden) const AnilistHidden(),
                  // LOCAL hidden indicator
                  if (widget.series.isForcedHidden) const LocalHidden(),

                  // Hover overlay
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: GestureDetector(
                        onSecondaryTapDown: (_) => _contextMenuKey.currentState?.openMenu(),
                        child: InkWell(
                          onTap: () => widget.onTap?.call(),
                          splashColor: mainColor.withOpacity(0.1),
                          highlightColor: mainColor.withOpacity(0.05),
                          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                          child: AnimatedContainer(
                            duration: getDuration(const Duration(milliseconds: 150)),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                              color: _isHovering ? mainColor.withOpacity(0.1) : Colors.transparent,
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
      ),
    );
  }
}
