import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show InkWell, Material;
import 'package:transparent_image/transparent_image.dart';
import '../enums.dart';
import '../manager.dart';
import '../services/cache.dart';
import 'dart:io';

import '../models/series.dart';
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
  ImageProvider? _posterImageProvider;
  ImageSource? _lastKnownDefaultSource;

  @override
  void initState() {
    super.initState();
    _loadImage();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.series.effectivePosterPath != null && //
          widget.series.preferredPosterSource == ImageSource.autoAnilist &&
          widget.series.anilistData?.posterImage != null) {
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

    setState(() => _loading = true);

    // Get effective poster path based on user preference
    final effectivePath = widget.series.effectivePosterPath;

    if (effectivePath == null) {
      setState(() => _loading = false);
      return;
    }

    // Check if local poster exists
    if (widget.series.isLocalPoster) {
      _posterImageProvider = FileImage(File(effectivePath));
    } else
    // Check if anilist poster exists (cache/network)
    if (widget.series.isAnilistPoster) {
      final imageCache = ImageCacheService();
      final cachedFile = await imageCache.getCachedImageFile(effectivePath);

      if (cachedFile != null)
        _posterImageProvider = FileImage(cachedFile);
      else {
        // If not in cache, use NetworkImage
        _posterImageProvider = NetworkImage(effectivePath);
        // and start caching in background for future use
        imageCache.cacheImage(effectivePath);
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Widget _getSeriesImage() {
    if (_loading) return const Center(child: ProgressRing(strokeWidth: 3));

    Widget noImg = LayoutBuilder(builder: (context, constraints) {
      return Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxWidth * 1.05,
          child: Icon(FluentIcons.file_image, size: constraints.maxWidth * 0.25),
        ),
      );
    });

    if (_posterImageProvider != null) {
      return FadeInImage(
        placeholder: MemoryImage(kTransparentImage),
        image: _posterImageProvider!,
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
        fadeInDuration: getDuration(const Duration(milliseconds: 250)),
        fadeInCurve: Curves.easeIn,
        imageErrorBuilder: (context, error, stackTrace) => noImg,
      );
    }

    return noImg;
  }

  @override
  Widget build(BuildContext context) {
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
                        color: (widget.series.dominantColor ?? Manager.accentColor).withOpacity(0.05),
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
                Positioned(
                  bottom: 0,
                  child: Container(
                    color: Colors.grey,
                    height: 1,
                    width: 1000,
                  ),
                ),
                Card(
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster image
                      Expanded(
                        child: Container(),
                      ),

                      // Series info
                      Builder(builder: (context) {
                        Color nicerColor = (widget.series.dominantColor ?? Manager.accentColor).lerpWith(Colors.grey, widget.series.isAnilistPoster ? .66 : .9);

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
                            scale: 1.01,
                            child: Transform.translate(
                              offset: Offset(0, 1),
                              child: Acrylic(
                                blurAmount: 5,
                                tint: nicerColor,
                                elevation: 0.5,
                                tintAlpha: 0.5,
                                luminosityAlpha: 0.4,
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
                      splashColor: (widget.series.dominantColor ?? Manager.accentColor).withOpacity(0.1),
                      highlightColor: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8.0),
                      child: AnimatedContainer(
                        duration: getDuration(const Duration(milliseconds: 150)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: _isHovering ? Colors.white.withOpacity(0.03) : Colors.transparent,
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
