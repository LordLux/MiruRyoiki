import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show InkWell, Material;

import '../functions.dart';
import '../models/episode.dart';
import '../models/series.dart';
import '../utils/logging.dart';
import '../utils/time_utils.dart';
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

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: getDuration(const Duration(milliseconds: 150)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
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
        child: Stack(
          children: [
            // Episode card content
            Card(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Thumbnail or icon
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: _buildEpisodeThumbnail(widget.episode),
                    ),

                    // Bottom text overlay
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7.0),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
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

                    // Watched indicator
                    if (widget.episode.watched)
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: WatchedBadge(isWatched: true),
                      ),

                    // Progress indicator
                    if (widget.episode.watchedPercentage > 0 && widget.episode.watchedPercentage < 0.8)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          color: Colors.red.withOpacity(0.7),
                          child: ProgressBar(
                            value: (widget.episode.watchedPercentage > 0.8 ? 1 : widget.episode.watchedPercentage) * 100,
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            activeColor: widget.series.dominantColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Hover and splash overlay
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  splashColor: widget.series.dominantColor?.withOpacity(0.3),
                  highlightColor: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4.0),
                  child: AnimatedContainer(
                    duration: getDuration(const Duration(milliseconds: 150)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
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
  Widget _buildEpisodeThumbnail(Episode episode) {
  return FutureBuilder<String?>(
    future: episode.getThumbnail(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: ProgressRing(strokeWidth: 2));
      }
      
      final String? thumbnailPath = snapshot.data;
      
      if (thumbnailPath == null || !File(thumbnailPath).existsSync()) {
        // Fallback icon if no thumbnail
        return Icon(
          FluentIcons.video, 
          size: 32, 
          color: FluentTheme.of(context).resources.textFillColorSecondary
        );
      }
      
      // Display the thumbnail
      return Image.file(
        File(thumbnailPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          logErr('Error loading thumbnail', error, stackTrace);
          return Icon(
            FluentIcons.error, 
            size: 32, 
            color: FluentTheme.of(context).resources.textFillColorSecondary
          );
        },
      );
    },
  );
}
}
