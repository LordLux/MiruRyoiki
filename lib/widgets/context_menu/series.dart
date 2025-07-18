// ignore_for_file: sort_child_properties_last

import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_desktop_context_menu/flutter_desktop_context_menu.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../manager.dart';
import '../../models/series.dart';
import '../../services/library/library_provider.dart';
import '../../services/navigation/dialogs.dart';
import '../../services/navigation/show_info.dart';
import '../../screens/series.dart';
import '../../utils/shell_utils.dart';
import '../dialogs/poster_select.dart';
import '../../utils/logging.dart';
import 'icons.dart' as icons;

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
  void openMenu() {
    popUpContextMenu(
      seriesMenu(
        context: widget.context,
        series: widget.series,
      ),
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
          icon: icons.openFolder,
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
          icon: icons.anilist,
          shortcutModifiers: ShortcutModifiers(control: Platform.isWindows, meta: Platform.isMacOS),
          onClick: (_) => _updateFromAnilist(context),
        ),
        if (!series.isLinked)
          MenuItem(
            label: series.isHidden ? 'Stop Hiding Series' : 'Hide Series',
            icon: series.isHidden ? icons.unhide : icons.hide,
            onClick: (_) => _toggleHiddenStatus(context),
          ),
        MenuItem.separator(),
        MenuItem(
          label: widget.series.watchedPercentage == 1.0 ? 'Mark All as Unwatched' : 'Mark All as Watched',
          toolTip: widget.series.watchedPercentage == 1.0 ? 'Unmark as watched' : 'Mark as watched',
          icon: widget.series.watchedPercentage == 1.0 ? icons.unwatch : icons.watch,
          onClick: (_) => widget.series.watchedPercentage == 1.0 ? _markAllAsUnwatched(context) : _markAllAsWatched(context),
        ),
      ],
    );
  }

  void _openFolderLocation(BuildContext context) async {
    try {
      ShellUtils.openFileExplorerAndSelect(widget.series.path);
    } catch (e, stackTrace) {
      snackBar(
        'Could not open folder: $e',
        severity: InfoBarSeverity.error,
        exception: e,
        stackTrace: stackTrace,
      );
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

  void _toggleHiddenStatus(BuildContext context) {
    final library = Provider.of<Library>(context, listen: false);
    final series = widget.series;

    // Toggle hidden status
    series.isHidden = !series.isHidden;

    // Update the series in the library
    library.updateSeries(series, invalidateCache: true);

    if (libraryScreenKey.currentState != null) {
      libraryScreenKey.currentState!.removeHiddenSeriesWithoutInvalidatingCache(series);
      libraryScreenKey.currentState!.setState(() {});
    }

    // Show confirmation
    snackBar(
      series.isHidden ? 'Series is now hidden' : 'Series is now visible',
      severity: InfoBarSeverity.success,
    );

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
  //TODO ask confirmation dialog before marking all as watched/unwatched

  void _markAllAsUnwatched(BuildContext context) {
    final library = Provider.of<Library>(context, listen: false);
    library.markSeriesWatched(widget.series, watched: false);
    snackBar('Marked all episodes as unwatched', severity: InfoBarSeverity.success);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
