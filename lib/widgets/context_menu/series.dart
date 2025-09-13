// ignore_for_file: sort_child_properties_last

import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_desktop_context_menu/flutter_desktop_context_menu.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../manager.dart';
import '../../models/anilist/user_data.dart';
import '../../models/anilist/user_list.dart';
import '../../models/series.dart';
import '../../services/anilist/provider/anilist_provider.dart';
import '../../services/anilist/queries/anilist_service.dart';
import '../../services/library/library_provider.dart';
import '../../services/lock_manager.dart';
import '../../services/navigation/dialogs.dart';
import '../../services/navigation/show_info.dart';
import '../../screens/series.dart';
import '../../utils/logging.dart';
import '../../utils/shell_utils.dart';
import '../dialogs/image_select.dart';
import 'icons.dart' as icons;

typedef LastListChange = ({Series series, String previousListName});

class SeriesContextMenu extends StatefulWidget {
  final Series series;
  final Widget child;
  final BuildContext context;

  static int? lastSeriesId_watched; //
  static LastListChange? lastSeriesList_changeLists;

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
    final library = Provider.of<Library>(context, listen: false);
    final shouldDisable = library.isIndexing;
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
          disabled: shouldDisable,
          shortcutModifiers: ShortcutModifiers(control: Platform.isWindows, meta: Platform.isMacOS),
          onClick: (_) => _changePosterImage(context),
        ),
        MenuItem(
          label: 'Change Banner Image',
          shortcutKey: 'b',
          disabled: shouldDisable,
          shortcutModifiers: ShortcutModifiers(control: Platform.isWindows, meta: Platform.isMacOS),
          onClick: (_) => _changeBannerImage(context),
        ),
        if (series.isLinked)
          MenuItem(
            label: 'Update from Anilist',
            shortcutKey: 'a',
            icon: icons.anilist,
            disabled: shouldDisable,
            shortcutModifiers: ShortcutModifiers(control: Platform.isWindows, meta: Platform.isMacOS),
            onClick: (_) => _updateFromAnilist(context),
          ),
        MenuItem(
          label: series.isForcedHidden ? 'Stop Hiding' : 'Hide',
          icon: series.isForcedHidden ? icons.unhide : icons.hide,
          disabled: shouldDisable,
          onClick: (_) => _toggleHiddenStatus(context, series),
        ),
        if (!series.isLinked)
          MenuItem.submenu(
            label: 'Change List',
            disabled: shouldDisable,
            sublabel: 'Change the custom list for this series',
            submenu: _buildMenuFromLists(),
          ),
        MenuItem.separator(),
        MenuItem(
          disabled: shouldDisable,
          label: widget.series.watchedPercentage == 1.0 ? 'Mark as Unwatched' : 'Mark as Watched',
          toolTip: widget.series.watchedPercentage == 1.0 ? 'Mark all Episodes from this Series as Unwatched' : 'Mark all Episodes from this Series as Watched',
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
      seriesScreenState.selectImage(context, isBanner: false);
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
      seriesScreenState.selectImage(context, isBanner: true);
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

  static void _undoToggleHiddenStatus(BuildContext context) {
    try {
      // Use the global navigator context to avoid deactivated widget issues
      final globalContext = rootNavigatorKey.currentContext!;
      final library = Provider.of<Library>(globalContext, listen: false);
      final series = library.getSeriesById(SeriesContextMenu.lastSeriesId_watched!)!;

      _toggleHiddenStatus(globalContext, series);
    } catch (e) {
      logErr('Error occurred while toggling hidden status', e);
    }
  }

  static void _toggleHiddenStatus(BuildContext context, Series series) {
    final library = Provider.of<Library>(context, listen: false);
    SeriesContextMenu.lastSeriesId_watched = series.id;

    // Toggle hidden status
    series.isForcedHidden = !series.isForcedHidden;

    // Update the series in the library
    library.updateSeries(series, invalidateCache: true);

    if (libraryScreenKey.currentState != null) {
      if (series.isForcedHidden)
        libraryScreenKey.currentState!.removeHiddenSeriesWithoutInvalidatingCache(series);
      else
        libraryScreenKey.currentState!.updateSeriesInSortCache(series);

      libraryScreenKey.currentState!.setState(() {});
    }

    // Show confirmation
    snackBar(
      series.isForcedHidden ? 'Series is now hidden' : 'Series is now visible',
      severity: InfoBarSeverity.success,
      action: series.isForcedHidden ? UndoButton(() => _undoToggleHiddenStatus(context)) : null,
    );

    Manager.setState();
  }

  void _updateFromAnilist(BuildContext context) {
    // TODO: Implement Anilist update
    snackBar('Anilist update not yet implemented', severity: InfoBarSeverity.warning);
  }

  void _markAllAsWatched(BuildContext context) {
    final library = Provider.of<Library>(context, listen: false);
    
    // Check if the action should be disabled
    if (library.lockManager.shouldDisableAction(UserAction.markSeriesWatched)) {
      snackBar(
        library.lockManager.getDisabledReason(UserAction.markSeriesWatched),
        severity: InfoBarSeverity.warning,
      );
      return;
    }
    
    library.markSeriesWatched(widget.series, watched: true);
    snackBar('Marked all episodes as watched', severity: InfoBarSeverity.success);
  }

  //TODO ask confirmation dialog before marking all as watched/unwatched

  void _markAllAsUnwatched(BuildContext context) {
    final library = Provider.of<Library>(context, listen: false);
    
    // Check if the action should be disabled
    if (library.lockManager.shouldDisableAction(UserAction.markSeriesWatched)) {
      snackBar(
        library.lockManager.getDisabledReason(UserAction.markSeriesWatched),
        severity: InfoBarSeverity.warning,
      );
      return;
    }
    
    library.markSeriesWatched(widget.series, watched: false);
    snackBar('Marked all episodes as unwatched', severity: InfoBarSeverity.success);
  }

  static void _undoChangeCustomList() {
    try {
      final globalContext = rootNavigatorKey.currentContext!;
      final library = Provider.of<Library>(globalContext, listen: false);
      final series = library.getSeriesById(SeriesContextMenu.lastSeriesList_changeLists!.series.id!)!;
      final previousApiName = SeriesContextMenu.lastSeriesList_changeLists!.previousListName;

      _changeCustomList(globalContext, series, previousApiName, undoing: true);
    } catch (e) {
      logErr('Error occurred while changing custom list', e);
      rethrow;
    }
  }

  static void _changeCustomList(BuildContext context, Series series, String apiName, {bool undoing = false}) {
    final library = Provider.of<Library>(context, listen: false);

    // Update the series with the new custom list name (use API name)
    final updatedSeries = series;

    // Only store the previous state if this is not an undo operation
    if (!undoing) //
      SeriesContextMenu.lastSeriesList_changeLists = (series: updatedSeries, previousListName: updatedSeries.customListName ?? AnilistService.statusListNameUnlinked);

    updatedSeries.customListName = apiName == AnilistService.statusListNameUnlinked ? null : apiName;

    library.updateSeries(updatedSeries, invalidateCache: true);

    if (libraryScreenKey.currentState != null) {
      libraryScreenKey.currentState!.updateSeriesInSortCache(updatedSeries);
      libraryScreenKey.currentState!.setState(() {});
    }

    final prettyName = StatusStatistic.statusNameToPretty(apiName);

    snackBar(
      !undoing ? 'Changed list for "${series.name}" to $prettyName' : 'Reverted list change for "${series.name}"',
      severity: InfoBarSeverity.success,
      action: !undoing ? UndoButton(() => _undoChangeCustomList()) : null,
    );
  }

  Menu _buildMenuFromLists() {
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
    final Map<String, AnilistUserList> allLists = anilistProvider.userLists;

    final availableLists = <String, String>{}; // API name -> Display name

    // Add default unlinked option
    availableLists[AnilistService.statusListNameUnlinked] = 'Unlinked';

    // Add standard AniList lists if logged in
    if (anilistProvider.isLoggedIn) {
      // Swap the map to get API names as keys and Pretty names as values
      final swappedMap = <String, String>{};
      AnilistService.statusListNamesPrettyToApiMap.forEach((prettyName, apiName) {
        swappedMap[apiName] = prettyName;
      });
      availableLists.addAll(swappedMap);

      // Add custom lists
      final customLists = allLists.entries.where((entry) => entry.key.startsWith(AnilistService.statusListPrefixCustom));
      for (final entry in customLists) {
        final apiName = entry.key; // e.g., "custom_MyList"
        final displayName = StatusStatistic.statusNameToPretty(apiName); // e.g., "MyList"
        availableLists[apiName] = displayName;
      }
    }

    return Menu(
      items: availableLists.entries
          .map((entry) => MenuItem.checkbox(
                checked: widget.series.customListName == entry.key || (widget.series.customListName == null && entry.key == AnilistService.statusListNameUnlinked),
                label: entry.value, // Display name
                onClick: (item) => _changeCustomList(context, widget.series, entry.key), // Pass API name
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;

  static Button UndoButton(VoidCallback onPressed) {
    return Button(
      child: Text('Undo', style: Manager.bodyStyle.copyWith(decoration: TextDecoration.underline)),
      onPressed: onPressed,
    );
  }
}
