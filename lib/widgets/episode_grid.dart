import 'package:fluent_ui/fluent_ui.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import '../manager.dart';
import '../models/anilist/mapping.dart';
import '../models/episode.dart';
import '../models/series.dart';
import '../services/navigation/shortcuts.dart';
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
  final int? crossAxisCount;
  final EdgeInsets padding;

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
    this.crossAxisCount,
    EdgeInsets? padding,
  }) : padding = padding ?? const EdgeInsets.only(top: 66.0);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DynMouseScroll(
          stopScroll: KeyboardState.ctrlPressedNotifier,
          scrollSpeed: 1.0,
          enableSmoothScroll: Manager.animationsEnabled,
          durationMS: 350,
          animationCurve: Curves.easeOutQuint,
          builder: (context, controller, physics) {
            return ValueListenableBuilder(
              valueListenable: KeyboardState.ctrlPressedNotifier,
              builder: (context, isCtrlPressed, _) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: physics,
                  padding: padding,
                  controller: controller,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: (crossAxisCount ?? (constraints.maxWidth ~/ 200)).clamp(1, 10),
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
              },
            );
          },
        );
      },
    );
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
