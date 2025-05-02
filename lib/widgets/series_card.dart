// import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'dart:io';

import '../models/series.dart';

class SeriesCard extends StatelessWidget {
  final Series series;
  final VoidCallback onTap;
  
  const SeriesCard({
    super.key,
    required this.series,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster image
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.grey,
                  child: series.posterPath != null
                      ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.file(
                            File(series.posterPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                const Center(child: Icon(FluentIcons.file_image, size: 40)),
                          ),
                      )
                      : const Center(child: Icon(FluentIcons.file_image, size: 40)),
                ),
              ),
              
              // Series info
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      series.name,
                      style: FluentTheme.of(context).typography.bodyStrong,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${series.totalEpisodes} episodes',
                          style: FluentTheme.of(context).typography.caption,
                        ),
                        const Spacer(),
                        Text(
                          '${(series.watchedPercentage * 100).round()}%',
                          style: FluentTheme.of(context).typography.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ProgressBar(
                      value: series.watchedPercentage * 100,
                      activeColor: Colors.purple, //TODO get color from theme
                      backgroundColor: Colors.grey.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}