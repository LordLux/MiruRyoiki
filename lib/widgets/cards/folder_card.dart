import 'package:fluent_ui/fluent_ui.dart';

import '../../models/folder_node.dart';
import '../../models/mapping_target.dart';
import '../../models/series.dart';
import '../context_menu/folder.dart';
import '../context_menu/mapping.dart';
import 'poster_card.dart';

/// Card for a [FolderNode] on the node screen. A thin wrapper over the shared
/// [PosterCard] shell: linked folders show their AniList poster + the rich
/// [MappingContextMenu]; unlinked folders show a placeholder + the lightweight
/// [FolderNodeContextMenu]. Progress is recursive over the whole subtree.
class FolderCard extends StatelessWidget {
  final FolderNode node;
  final Series series;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const FolderCard({
    super.key,
    required this.node,
    required this.series,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
  });

  @override
  Widget build(BuildContext context) {
    final mapping = node.mapping;

    return PosterCard(
      posterUrl: mapping?.anilistData?.posterImage,
      loadDominantColor: () async => mapping == null ? null : await mapping.effectivePrimaryColor(),
      dominantColorSync: () => mapping?.effectivePrimaryColorSync(),
      title: node.displayName,
      watchedCount: node.watchedCount,
      totalCount: node.totalCount,
      watchedPercentage: node.watchedPercentage,
      placeholderIcon: node.hasChildren ? FluentIcons.fabric_folder : FluentIcons.file_image,
      onTap: onTap,
      borderRadius: borderRadius,
      identityKey: node.path,
      menuBuilder: (ctx, child, controller, refresh) {
        // Linked folder → reuse the rich mapping menu (Edit AniList Entry, etc.).
        if (node.isLinked && node.collection != null) {
          return MappingContextMenu(
            controller: controller,
            series: series,
            target: MappingTarget.collection(node.collection!),
            context: ctx,
            onChanged: refresh,
            child: child,
          );
        }
        // Unlinked folder → lightweight menu (Open Folder / Mark watched / Link).
        return FolderNodeContextMenu(
          controller: controller,
          series: series,
          node: node,
          context: ctx,
          onChanged: refresh,
          child: child,
        );
      },
    );
  }
}
