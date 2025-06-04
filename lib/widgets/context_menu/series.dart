// ignore_for_file: sort_child_properties_last

import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_desktop_context_menu/flutter_desktop_context_menu.dart';
import 'package:provider/provider.dart';
import '../../manager.dart';
import '../../models/series.dart';
import '../../services/library/library_provider.dart';
import '../../services/navigation/dialogs.dart';
import '../../services/navigation/show_info.dart';
import '../../screens/series.dart';
import '../../utils/shell_utils.dart';
import '../dialogs/poster_select.dart';
import '../../utils/logging.dart';

class SeriesContextMenu extends StatefulWidget {
  final Series series;
  final Widget child;
  final BuildContext context;

  const SeriesContextMenu({
    super.key,
    required this.series,
    required this.child,
    required this.context,
  });

  @override
  State<SeriesContextMenu> createState() => SeriesContextMenuState();
}

class SeriesContextMenuState extends State<SeriesContextMenu> {
  late final Menu menu;

  @override
  void initState() {
    super.initState();
    menu = seriesMenu(
      context: widget.context,
      series: widget.series,
    );
  }

  void openMenu() {
    popUpContextMenu(
      menu,
      placement: Placement.bottomRight,
    );
  }

  Menu seriesMenu({
    required final BuildContext context,
    required final Series series,
  }) {
    return Menu(
      items: [
        MenuItem(
          label: 'Open in File Explorer',
          shortcutKey: 'e',
          shortcutModifiers: ShortcutModifiers(control: Platform.isWindows, meta: Platform.isMacOS),
          onClick: (_) => _openFolderLocation(context),
        ),
        MenuItem(
          label: 'Change Poster Image',
          shortcutKey: 'p',
          shortcutModifiers: ShortcutModifiers(control: Platform.isWindows, meta: Platform.isMacOS),
          onClick: (_) => _changePosterImage(context),
        ),
        MenuItem(
          label: 'Change Banner Image',
          shortcutKey: 'b',
          shortcutModifiers: ShortcutModifiers(control: Platform.isWindows, meta: Platform.isMacOS),
          onClick: (_) => _changeBannerImage(context),
        ),
        MenuItem(
          label: 'Update from Anilist',
          shortcutKey: 'a',
          shortcutModifiers: ShortcutModifiers(control: Platform.isWindows, meta: Platform.isMacOS),
          onClick: (_) => _updateFromAnilist(context),
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'watched',
          label: widget.series.watchedPercentage == 1.0 ? 'Already Watched All' : 'Mark All as Watched',
          toolTip: widget.series.watchedPercentage == 1.0 ? 'Unmark as watched' : 'Mark as watched',
          disabled: widget.series.watchedPercentage == 1.0,
          onClick: (menuItem) => _markAllAsWatched(context),
        ),
      ],
    );
  }

  void _openFolderLocation(BuildContext context) async {
    try {
      ShellUtils.openFileExplorerAndSelect(widget.series.path);
    } catch (e) {
      logErr('Error opening folder location', e);
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
        id: 'posterSelection:${widget.series.path}',
        title: 'Select Poster',
        dialogDoPopCheck: () => true,
        builder: (context) => ImageSelectionDialog(
          series: widget.series,
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
        id: 'bannerSelection:${widget.series.path}',
        title: 'Select Banner',
        dialogDoPopCheck: () => true,
        builder: (context) => ImageSelectionDialog(
          series: widget.series,
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
    library.markSeriesWatched(widget.series, watched: true);
    snackBar('Marked all episodes as watched', severity: InfoBarSeverity.success);
  }

  void _markAllAsUnwatched(BuildContext context) {
    final library = Provider.of<Library>(context, listen: false);
    library.markSeriesWatched(widget.series, watched: false);
    snackBar('Marked all episodes as unwatched', severity: InfoBarSeverity.success);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
