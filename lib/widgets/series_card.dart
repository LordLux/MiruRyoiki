import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show InkWell, Material;
import 'package:transparent_image/transparent_image.dart';
import '../manager.dart';
import '../services/cache.dart';
import 'dart:io';

import '../models/series.dart';

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

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(SeriesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.series != widget.series) _loadImage();
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

    if (_posterImageProvider != null) {
      return FadeInImage(
        placeholder: MemoryImage(kTransparentImage),
        image: _posterImageProvider!,
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
        fadeInDuration: const Duration(milliseconds: 300),
        fadeInCurve: Curves.easeIn,
        imageErrorBuilder: (context, error, stackTrace) => const Center(child: Icon(FluentIcons.file_image, size: 40)),
      );
    }

    return const Center(child: Icon(FluentIcons.file_image, size: 40));
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
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
                      duration: const Duration(milliseconds: 150),
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
    );
  }
}
