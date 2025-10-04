import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:sticky_headers/sticky_headers.dart';
import '../manager.dart';
import '../models/episode.dart';
import '../models/series.dart';
import '../utils/time.dart';
import 'acrylic_header.dart';
import 'episode_card.dart';

class EpisodeGrid extends StatelessWidget {
  final List<Episode> episodes;
  final Series series;
  final String? title;
  final Function(Episode) onTap;
  final bool collapsable;
  final bool initiallyExpanded;
  final GlobalKey<ExpandingStickyHeaderBuilderState>? expanderKey;
  final bool isReloadingSeries;

  const EpisodeGrid({
    super.key,
    required this.episodes,
    required this.series,
    this.title,
    this.collapsable = true,
    this.initiallyExpanded = true,
    required this.onTap,
    this.expanderKey,
    this.isReloadingSeries = false,
  });

  @override
  Widget build(BuildContext context) {
    return ExpandingStickyHeaderBuilder(
      key: expanderKey,
      enabled: collapsable || title != null,
      initiallyExpanded: initiallyExpanded,
      contentBackgroundColor: Colors.transparent,
      contentShape: (open) => RoundedRectangleBorder(),
      useInkWell: false,
      builder: (BuildContext context, {double stuckAmount = 0.0, bool isHovering = false, bool isExpanded = false}) => AcrylicHeader(
        child: Builder(builder: (context) {
          if (episodes.isEmpty) {
            return title != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title!, style: Manager.subtitleStyle),
                      Text('No Episodes Found', style: Manager.bodyStyle),
                    ],
                  )
                : Text('No Episodes Found for this Season', style: Manager.subtitleStyle);
          }
          if (title != null) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title!, style: Manager.subtitleStyle),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.translate(offset: const Offset(0, -1.5), child: Text('${episodes.length} Episodes', style: Manager.captionStyle)),
                      const SizedBox(width: 8),
                      AnimatedRotation(turns: isExpanded ? 0 : .5, duration: shortDuration, child: const Icon(mat.Icons.expand_more)),
                    ],
                  )
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ),
      headerBackgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
        child: LayoutBuilder(builder: (context, constraints) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: (constraints.maxWidth ~/ 200).clamp(1, 10),
              childAspectRatio: 1.78, // 16:9 aspect ratio
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: episodes.length,
            itemBuilder: (context, index) {
              final episode = episodes[index];
              return _buildEpisodeTile(context, episode, series);
            },
          );
        }),
      ),
    );
  }

  Widget _buildEpisodeTile(BuildContext context, Episode episode, Series series) {
    return HoverableEpisodeTile(
      episode: episode,
      onTap: () => onTap(episode),
      series: series,
      isReloadingSeries: isReloadingSeries,
    );
  }
}
