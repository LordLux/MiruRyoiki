import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show InkWell, Material;
import 'package:transparent_image/transparent_image.dart';
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

    // Check if local poster exists
    if (widget.series.folderImagePath != null) {
      _posterImageProvider = FileImage(File(widget.series.folderImagePath!));
    } else
    // Check if anilist poster exists (cache/network)
    if (widget.series.posterImage != null) {
      final imageCache = ImageCacheService();
      final cachedFile = await imageCache.getCachedImageFile(widget.series.posterImage!);

      if (cachedFile != null)
        _posterImageProvider = FileImage(cachedFile);
      else {
        // If not in cache, use NetworkImage
        _posterImageProvider = NetworkImage(widget.series.posterImage!);
        // and start caching in background for future use
        imageCache.cacheImage(widget.series.posterImage!);
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
        fit: BoxFit.contain,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.transparent,
          boxShadow: _isHovering
              ? [
                  BoxShadow(
                    color: (widget.series.dominantColor ?? Colors.blue).withOpacity(0.05),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Stack(
          children: [
            Card(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Poster image
                    Expanded(
                      child: Container(width: double.infinity, color: Colors.white.withOpacity(.03), child: _getSeriesImage()),
                    ),

                    // Series info
                    Padding(
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
                              activeColor: widget.series.dominantColor,
                              backgroundColor: Color.lerp(Colors.grey.withOpacity(0.5), widget.series.dominantColor, 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Hover overlay
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  splashColor: (widget.series.dominantColor ?? Colors.blue).withOpacity(0.1),
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
    );
  }
}
