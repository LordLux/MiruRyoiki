// ignore_for_file: sort_child_properties_last

import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/functions.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_desktop_context_menu/flutter_desktop_context_menu.dart';

import '../../manager.dart';
import '../../models/episode.dart';
import '../../models/series.dart';
import '../../services/episode_navigation/episode_navigator.dart';
import '../../services/library/library_provider.dart';
import '../../services/lock_manager.dart';
import '../../services/navigation/show_info.dart';
import '../../utils/shell.dart';
import '../../utils/icons.dart' as icons;

class EpisodeContextMenu extends StatefulWidget {
  final Episode episode;
  final Series series;
  final Widget child;
  final BuildContext context;

  const EpisodeContextMenu({
    super.key,
    required this.context,
    required this.episode,
    required this.series,
    required this.child,
  });

  @override
  State<EpisodeContextMenu> createState() => EpisodeContextMenuState();
}

class EpisodeContextMenuState extends State<EpisodeContextMenu> {
  void openMenu() {
    popUpContextMenu(
      episodeMenu(
        context: widget.context,
        episode: widget.episode,
      ),
      placement: Placement.bottomRight,
    );
  }

  Menu episodeMenu({
    required final BuildContext context,
    required final Episode episode,
  }) {
    final library = Provider.of<Library>(context, listen: false);
    final shouldDisable = library.isIndexing;
    final arePreviousWatched = EpisodeNavigator.instance.arePreviousEpisodesWatched(widget.episode, widget.series);

    return Menu(
      items: [
        MenuItem(
          label: 'Play',
          icon: icons.play,
          shortcutKey: 'p',
          shortcutModifiers: ShortcutModifiers(control: Platform.isWindows, meta: Platform.isMacOS),
          onClick: (_) => _playEpisode(context),
        ),
        MenuItem(
          label: 'Open With...',
          shortcutKey: 'o',
          shortcutModifiers: ShortcutModifiers(control: Platform.isWindows, meta: Platform.isMacOS),
          onClick: (_) => _openWith(context),
        ),
        MenuItem(
          label: 'Open Folder Location',
          shortcutKey: 'f',
          icon: icons.folder_open,
          shortcutModifiers: ShortcutModifiers(control: Platform.isWindows, meta: Platform.isMacOS),
          onClick: (_) => _openFolderLocation(context),
        ),
        MenuItem(
          label: 'Copy Filename',
          shortcutKey: 'c',
          icon: icons.copy,
          shortcutModifiers: ShortcutModifiers(control: Platform.isWindows, meta: Platform.isMacOS),
          onClick: (_) => _copyFilename(context),
        ),
        MenuItem.separator(),
        if (arePreviousWatched == false)
          MenuItem(
            label: 'Mark Previous Episodes as Watched',
            icon: icons.checkPrevious,
            disabled: shouldDisable,
            onClick: (_) => _watchAllPreviousSeasonEpisodes(context),
          ),
        MenuItem(
          label: episode.watched ? 'Unmark as Watched' : 'Mark as Watched',
          shortcutKey: 'w',
          icon: episode.watched ? icons.unwatch : icons.check,
          disabled: shouldDisable,
          onClick: (_) => _toggleWatched(context),
        ),
      ],
    );
  }

  void _playEpisode(BuildContext context) {
    final library = Provider.of<Library>(context, listen: false);
    library.playEpisode(widget.episode);
  }

  void _openWith(BuildContext context) {
    try {
      ShellUtils.openWithDialog(widget.episode.path);
    } catch (e, stackTrace) {
      snackBar(
        'Could not open with dialog: $e',
        severity: InfoBarSeverity.error,
        exception: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _openFolderLocation(BuildContext context) async {
    try {
      ShellUtils.openFileExplorerAndSelect(widget.episode.path);
    } catch (e, stackTrace) {
      snackBar(
        'Could not open folder: $e',
        severity: InfoBarSeverity.error,
        exception: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _copyFilename(BuildContext context) {
    final filename = p.basename(widget.episode.path.path);
    copyToClipboard(filename);
    snackBar('Filename copied to clipboard', severity: InfoBarSeverity.success);
  }

  void _toggleWatched(BuildContext context) {
    final library = Provider.of<Library>(context, listen: false);
    final newState = !widget.episode.watched;

    // Check if the action should be disabled
    if (library.lockManager.shouldDisableAction(UserAction.markEpisodeWatched)) {
      snackBar(
        library.lockManager.getDisabledReason(UserAction.markEpisodeWatched),
        severity: InfoBarSeverity.warning,
      );
      return;
    }

    library.markEpisodeWatched(widget.episode, watched: newState, overrideProgress: true);

    snackBar(newState ? 'Marked as watched' : 'Marked as unwatched', severity: InfoBarSeverity.success);
    Manager.setState();
  }

  void _watchAllPreviousSeasonEpisodes(BuildContext context) {
    List<Episode> previousEpisodes = [];
    final season = EpisodeNavigator.instance.findSeasonForEpisode(widget.episode, widget.series);
    if (season == null) {
      snackBar('Could not find the season for this episode', severity: InfoBarSeverity.error);
      return;
    }

    final currentEpisodeNumber = widget.episode.episodeNumber;
    for (final ep in season.episodes) {
      if (ep.episodeNumber != null && currentEpisodeNumber != null && ep.episodeNumber! < currentEpisodeNumber && !ep.watched) {
        previousEpisodes.add(ep);
      }
    }
    
    if (previousEpisodes.isEmpty) {
      snackBar('No previous episodes to mark as watched', severity: InfoBarSeverity.info);
      return;
    }
    
    final library = Provider.of<Library>(context, listen: false);
    library.markEpisodesWatched(previousEpisodes, watched: true, overrideProgress: true);

    Manager.setState();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
