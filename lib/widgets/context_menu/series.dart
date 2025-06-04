// ignore_for_file: sort_child_properties_last

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../../manager.dart';
import '../../models/series.dart';
import '../../services/library/library_provider.dart';
import '../../services/navigation/dialogs.dart';
import '../../services/navigation/show_info.dart';
import '../../screens/series.dart';
import '../dialogs/poster_select.dart';
import 'context_menu.dart';
import '../../utils/logging.dart';

class SeriesContextMenu extends StatelessWidget {
  final Series series;
  final Widget child;
  final VoidCallback? onTap;

  const SeriesContextMenu({
    super.key,
    required this.series,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ContextMenuOverlay(
      onTap: onTap,
      child: child,
      items: [
        ContextMenuItemData(
          label: 'Open in File Explorer',
          icon: FluentIcons.folder_open,
          onPressed: () => _openInExplorer(context),
        ),
        ContextMenuItemData(
          label: 'Change Poster Image',
          icon: FluentIcons.picture_fill,
          onPressed: () => _changePosterImage(context),
        ),
        ContextMenuItemData(
          label: 'Change Banner Image',
          icon: FluentIcons.photo2,
          onPressed: () => _changeBannerImage(context),
        ),
        ContextMenuItemData.divider(),
        ContextMenuItemData(
          label: 'Update from Anilist',
          icon: FluentIcons.refresh,
          onPressed: () => _updateFromAnilist(context),
        ),
        ContextMenuItemData.divider(),
        ContextMenuItemData(
          label: series.watchedPercentage == 1.0 ? 'Already Watched All' : 'Mark All as Watched',
          icon: FluentIcons.check_mark,
          onPressed: series.watchedPercentage == 1.0 ? null : () => _markAllAsWatched(context),
        ),
        ContextMenuItemData(
          label: series.watchedPercentage == 0.0 ? 'Already Unwatched' : 'Mark All as Unwatched',
          icon: FluentIcons.clear,
          onPressed: series.watchedPercentage == 0.0 ? null : () => _markAllAsUnwatched(context),
        ),
      ],
    );
  }

  void _openInExplorer(BuildContext context) async {
    try {
      final library = Provider.of<Library>(context, listen: false);
      library.openFolder(series.path);
    } catch (e) {
      logErr('Error opening folder', e);
      snackBar('Could not open folder: $e', severity: InfoBarSeverity.error);
    }
  }

  void _changePosterImage(BuildContext context) {
    // Get the current SeriesScreenState if available
    final seriesScreenState = context.findAncestorStateOfType<SeriesScreenState>();

    if (seriesScreenState != null) {
      // Use the existing method if we're on the series screen
      seriesScreenState.selectImage(context, false);
    } else {
      // Otherwise show a standalone dialog
      showManagedDialog(
        context: context,
        id: 'posterSelection:${series.path}',
        title: 'Select Poster',
        dialogDoPopCheck: () => true,
        builder: (context) => ImageSelectionDialog(
          series: series,
          popContext: context,
          isBanner: false,
        ),
      );
    }
    Manager.setState();
  }

  void _changeBannerImage(BuildContext context) {
    // Similar to poster but with isBanner = true
    final seriesScreenState = context.findAncestorStateOfType<SeriesScreenState>();

    if (seriesScreenState != null) {
      seriesScreenState.selectImage(context, true);
    } else {
      showManagedDialog(
        context: context,
        id: 'bannerSelection:${series.path}',
        title: 'Select Banner',
        dialogDoPopCheck: () => true,
        builder: (context) => ImageSelectionDialog(
          series: series,
          popContext: context,
          isBanner: true,
        ),
      );
    }
    Manager.setState();
  }

  void _updateFromAnilist(BuildContext context) {
    // TODO: Implement Anilist update
    snackBar('Anilist update not yet implemented', severity: InfoBarSeverity.warning);
  }

  void _markAllAsWatched(BuildContext context) {
    final library = Provider.of<Library>(context, listen: false);
    library.markSeriesWatched(series, watched: true);
    snackBar('Marked all episodes as watched', severity: InfoBarSeverity.success);
  }

  void _markAllAsUnwatched(BuildContext context) {
    final library = Provider.of<Library>(context, listen: false);
    library.markSeriesWatched(series, watched: false);
    snackBar('Marked all episodes as unwatched', severity: InfoBarSeverity.success);
  }
}
