import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show InkWell, Material;
import 'package:transparent_image/transparent_image.dart';
import '../enums.dart';
import '../manager.dart';
import '../services/cache.dart';
import 'dart:io';

import '../models/series.dart';
import '../utils/time_utils.dart';
import 'series_image.dart';

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
                        color: (widget.series.dominantColor ?? Manager.genericGray).withOpacity(0.05),
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
                  child: RepaintBoundary(
                    child: SeriesImageBuilder.poster(
                      widget.series,
                      key: ValueKey('${widget.series.path}:${widget.series.effectivePosterPath}'),
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topCenter,
                      fadeInDuration: const Duration(milliseconds: 250),
                      fadeInCurve: Curves.easeIn,
                      skipLoadingIndicator: true,
                    ),
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
                        final Color? temp = widget.series.dominantColor;
                        final double value = widget.series.isAnilistPoster ? .66 : .9;
                        final Color nicerColor = temp?.lerpWith(Colors.grey, value) ?? Manager.genericGray.withOpacity(.2);

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
