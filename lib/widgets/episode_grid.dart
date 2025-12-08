import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:sticky_headers/sticky_headers.dart';
import '../manager.dart';
import '../models/anilist/mapping.dart';
import '../models/episode.dart';
import '../models/series.dart';
import '../utils/time.dart';
import 'acrylic_header.dart';
import 'cards/episode_card.dart';

class EpisodeGrid extends StatelessWidget {
  final List<Episode> episodes;
  final Series series;
  final String? title;
  final Function(Episode) onTap;
  final AnilistMapping? mapping;
  final bool collapsable;
  final bool initiallyExpanded;
  final bool isReloadingSeries;

  const EpisodeGrid({
    super.key,
    required this.episodes,
    required this.series,
    required this.mapping,
    this.title,
    this.collapsable = true,
    this.initiallyExpanded = true,
    required this.onTap,
    this.isReloadingSeries = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GridView.builder(
        shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: (constraints.maxWidth ~/ 200).clamp(1, 10),
          childAspectRatio: 1.78, // 16:9 aspect ratio
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: episodes.length,
        itemBuilder: (context, index) {
          final episode = episodes[index];
          return _buildEpisodeTile(context, episode, series, mapping);
        },
      );
    });
  }

  Widget _buildEpisodeTile(BuildContext context, Episode episode, Series series, AnilistMapping? mapping) {
    return HoverableEpisodeTile(
      episode: episode,
      onTap: () => onTap(episode),
      series: series,
      isReloadingSeries: isReloadingSeries,
      mapping: mapping,
    );
  }
}
