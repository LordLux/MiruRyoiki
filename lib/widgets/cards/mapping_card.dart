import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/models/anilist/mapping.dart';

import '../../models/mapping_target.dart';
import '../../models/series.dart';
import '../context_menu/mapping.dart';
import 'poster_card.dart';

/// Card for a single AniList [mapping] / [target]. A thin wrapper over the
/// shared [PosterCard] shell — only the data source and the menu differ.
class MappingCard extends StatelessWidget {
  final MappingTarget target;
  final AnilistMapping mapping;
  final Series series;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const MappingCard({
    super.key,
    required this.target,
    required this.mapping,
    required this.onTap,
    required this.series,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
  });

  String get _displayTitle =>
      mapping.preferredTitle ??
      target.when(
        episode: (ep) => ep.displayTitle ?? ep.name,
        collection: (collection) => collection.prettyName,
      );

  @override
  Widget build(BuildContext context) {
    return PosterCard(
      posterUrl: mapping.anilistData?.posterImage,
      loadDominantColor: () => mapping.effectivePrimaryColor(),
      dominantColorSync: () => mapping.effectivePrimaryColorSync(),
      title: _displayTitle,
      watchedCount: target.watchedCount,
      totalCount: target.totalCount,
      watchedPercentage: target.watchedPercentage,
      placeholderIcon: FluentIcons.file_image,
      onTap: onTap,
      borderRadius: borderRadius,
      identityKey: mapping.localPath,
      menuBuilder: (ctx, child, controller, refresh) => MappingContextMenu(
        controller: controller,
        series: series,
        target: target,
        context: ctx,
        onChanged: refresh,
        child: child,
      ),
    );
  }
}
