import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show InkWell, Material;
import 'package:miruryoiki/widgets/frosted_noise.dart';
import 'package:transparent_image/transparent_image.dart';
import '../enums.dart';
import '../manager.dart';

import '../models/series.dart';
import '../services/navigation/statusbar.dart';
import '../utils/logging.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import 'context_menu/series.dart';
import 'series_card_indicators.dart';

class SeriesCard extends StatefulWidget {
  final Series series;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const SeriesCard({
    super.key,
    required this.series,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
  });

  @override
  State<SeriesCard> createState() => _SeriesCardState();
}

class _SeriesCardState extends State<SeriesCard> {
  bool _isHovering = false;
  bool _loading = true;
  bool _hasError = false;
  ImageProvider? _posterImageProvider;
  ImageSource? _lastKnownDefaultSource;
  final GlobalKey<SeriesContextMenuState> _contextMenuKey = GlobalKey<SeriesContextMenuState>();
  Color? _dominantColor;

  @override
  void initState() {
    super.initState();
    _loadImage();

    nextFrame(() {
      if (widget.series.effectivePosterPath != null && //
          widget.series.preferredPosterSource == ImageSource.autoAnilist &&
          widget.series.anilistPosterUrl != null) {
        _loadImage(); // Re-evaluate after initial build
      }
    });
  }

  @override
  void didUpdateWidget(SeriesCard oldWidget) {
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

  Future<void> _loadDominantColor() async {
    final color = await widget.series.effectivePrimaryColor();
    if (mounted) setState(() => _dominantColor = color);
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
    _loadDominantColor();
  }

  Widget _getSeriesImage() {
    Widget loadingWidget = const Center(child: ProgressRing(strokeWidth: 3));

    Widget noImageWidget = LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: Alignment.topCenter,
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
        alignment: Alignment.topCenter,
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
      alignment: Alignment.topCenter,
      fadeInDuration: getDuration(const Duration(milliseconds: 250)),
      fadeInCurve: Curves.easeIn,
      imageErrorBuilder: (context, error, stackTrace) => noImageWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color? cachedPrimaryColor = widget.series.effectivePrimaryColorSync();
    final Color mainColor;
    switch (Manager.settings.libColView) {
      case LibraryColorView.alwaysDominant:
        mainColor = _dominantColor ?? cachedPrimaryColor ?? Manager.genericGray;
        break;
      case LibraryColorView.hoverDominant:
        mainColor = _isHovering ? (_dominantColor ?? cachedPrimaryColor ?? Manager.genericGray) : Manager.genericGray;
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
      key: ValueKey('${widget.series.path}-${_dominantColor ?? cachedPrimaryColor?.value ?? 0}'),
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
          onHover: (_) => StatusBarManager().showDelayed(widget.series.name),
          cursor: SystemMouseCursors.click,
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            child: AnimatedContainer(
              duration: getDuration(const Duration(milliseconds: 150)),
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
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
                    top: 0,
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
                    borderRadius: widget.borderRadius,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Poster image
                        Expanded(child: SizedBox.shrink()),

                        LayoutBuilder(builder: (context, constraints) {
                          return Transform.scale(
                            scale: 1.01,
                            child: Transform.translate(
                              offset: Offset(0, .5),
                              child: AnimatedContainer(
                                duration: getDuration(const Duration(milliseconds: 400)),
                                width: constraints.maxWidth,
                                height: 4,
                                color: Color.lerp(Colors.black.withOpacity(0.2), _dominantColor ?? cachedPrimaryColor, .4),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: AnimatedContainer(
                                    duration: getDuration(const Duration(milliseconds: 400)),
                                    color: widget.series.watchedPercentage == 0 ? Colors.transparent : _dominantColor ?? cachedPrimaryColor,
                                    width: constraints.maxWidth * widget.series.watchedPercentage,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),

                        // Series info
                        Builder(builder: (context) {
                          final double value = widget.series.isAnilistPosterBeingUsed ? .76 : .9;
                          final Color nicerColor = mainColor.lerpWith(Colors.grey, value);

                          Widget child = AnimatedContainer(
                            duration: getDuration(const Duration(milliseconds: 400)),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(.3),
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.transparent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.0 * Manager.fontSizeMultiplier),
                              child: AnimatedContainer(
                                duration: getDuration(const Duration(milliseconds: 400)),
                                constraints: BoxConstraints(minHeight: 42 * min(Manager.fontSizeMultiplier, 1)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.series.name,
                                      style: Manager.bodyStrongStyle.copyWith(fontSize: 12 * Manager.fontSizeMultiplier),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    VDiv(4),
                                    Row(
                                      children: [
                                        Text(
                                          '${widget.series.watchedEpisodes} / ${widget.series.totalEpisodes} Episodes',
                                          style: Manager.miniBodyStyle.copyWith(color: Color.lerp(_dominantColor ?? cachedPrimaryColor, Colors.white, .7)),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${(widget.series.watchedPercentage * 100).round()}%',
                                          style: Manager.miniBodyStyle.copyWith(color: Color.lerp(_dominantColor ?? cachedPrimaryColor, Colors.white, .7)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                          if (widget.series.isAnilistPosterBeingUsed) {
                            return Transform.scale(
                              scale: 1.02,
                              child: Transform.translate(
                                offset: Offset(0, 1),
                                child: Acrylic(
                                  blurAmount: 2,
                                  tint: nicerColor.lerpWith(Colors.grey, 0.2),
                                  elevation: 0.5,
                                  tintAlpha: 0.5,
                                  luminosityAlpha: 0.8,
                                  child: FrostedNoise(
                                    child: child,
                                  ),
                                ),
                              ),
                            );
                          }
                          return AnimatedContainer(
                            duration: getDuration(const Duration(milliseconds: 400)),
                            color: nicerColor,
                            child: child,
                          );
                        }),
                      ],
                    ),
                  ),

                  // Hover overlay
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: GestureDetector(
                        onSecondaryTapDown: (_) => _contextMenuKey.currentState?.openMenu(),
                        child: InkWell(
                          onTap: widget.onTap,
                          splashColor: mainColor.withOpacity(0.1),
                          highlightColor: mainColor.withOpacity(0.05),
                          borderRadius: widget.borderRadius,
                          child: AnimatedContainer(
                            duration: getDuration(const Duration(milliseconds: 150)),
                            decoration: BoxDecoration(
                              borderRadius: widget.borderRadius,
                              color: _isHovering ? mainColor.withOpacity(0.1) : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  CardIndicators(series: widget.series),

                  AiringIndicator(series: widget.series, isHovered: _isHovering),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
