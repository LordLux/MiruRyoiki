import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show InkWell, Material;
import 'package:transparent_image/transparent_image.dart';
import '../enums.dart';
import '../manager.dart';

import '../models/series.dart';
import '../utils/logging.dart';
import '../utils/time_utils.dart';

class SeriesCard extends StatefulWidget {
  final Series series;
  final VoidCallback onTap;

  const SeriesCard({
    super.key,
    required this.series,
    required this.onTap,
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
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        cursor: SystemMouseCursors.click,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: AnimatedContainer(
            duration: getDuration(const Duration(milliseconds: 150)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
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
                  borderRadius: BorderRadius.circular(8.0),
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
                                style: FluentTheme.of(context).typography.bodyStrong,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${widget.series.totalEpisodes} episodes',
                                    style: FluentTheme.of(context).typography.caption,
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${(widget.series.watchedPercentage * 100).round()}%',
                                    style: FluentTheme.of(context).typography.caption,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 200,
                                child: ProgressBar(
                                  value: widget.series.watchedPercentage * 100,
                                  activeColor: widget.series.watchedPercentage == 0 ? Colors.transparent : widget.series.dominantColor,
                                  backgroundColor: Color.lerp(Colors.black.withOpacity(0.2), widget.series.dominantColor, 0),
                                ),
                              ),
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
                                child: child,
                              ),
                            ),
                          );
                        }
                        return Container(color: nicerColor, child: child);
                      }),
                    ],
                  ),
                ),
                // Hover overlay
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onTap,
                      splashColor: mainColor.withOpacity(0.1),
                      highlightColor: mainColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8.0),
                      child: AnimatedContainer(
                        duration: getDuration(const Duration(milliseconds: 150)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: _isHovering ? mainColor.withOpacity(0.1) : Colors.transparent,
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
}
