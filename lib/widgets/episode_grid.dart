import 'package:fluent_ui/fluent_ui.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import '../manager.dart';
import '../models/anilist/mapping.dart';
import '../models/ui_episode.dart';
import '../models/series.dart';
import '../services/navigation/shortcuts.dart';
import 'cards/episode_card.dart';

class EpisodeGrid extends StatelessWidget {
  final List<UIEpisode> episodes;
  final Series? series;
  final String? title;
  final Function(UIEpisode) onTap;
  final AnilistMapping? mapping;
  final bool collapsable;
  final bool initiallyExpanded;
  final bool isReloadingSeries;
  final int? crossAxisCount;
  final EdgeInsets padding;
  final void Function(UIEpisode)? onChangeSonarrLink;
  final void Function(UIEpisode)? onLinkLocalFile;

  /// When true, disables own scrolling so the grid can be embedded in a parent scrollable
  final bool nested;

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
    this.onChangeSonarrLink,
    this.onLinkLocalFile,
    this.nested = false,
    EdgeInsets? padding,
  }) : padding = padding ?? const EdgeInsets.only(top: 66.0);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final delegate = SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: (crossAxisCount ?? (constraints.maxWidth ~/ 200)).clamp(1, 10),
          childAspectRatio: 1.78, // 16:9 aspect ratio
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        );

        if (nested) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: padding,
            gridDelegate: delegate,
            itemCount: episodes.length,
            itemBuilder: (context, index) => _buildEpisodeTile(context, episodes[index], series, mapping),
          );
        }

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
                  gridDelegate: delegate,
                  itemCount: episodes.length,
                  itemBuilder: (context, index) => _buildEpisodeTile(context, episodes[index], series, mapping),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEpisodeTile(BuildContext context, UIEpisode episode, Series? series, AnilistMapping? mapping) {
    return HoverableEpisodeTile(
      uiEpisode: episode,
      onTap: () => onTap(episode),
      series: series,
      isReloadingSeries: isReloadingSeries,
      mapping: mapping,
      onChangeSonarrLink: onChangeSonarrLink,
      onLinkLocalFile: onLinkLocalFile,
    );
  }
}
