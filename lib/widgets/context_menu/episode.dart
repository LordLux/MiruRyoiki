// ignore_for_file: sort_child_properties_last

import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/functions.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import '../../manager.dart';
import '../../models/episode.dart';
import '../../models/series.dart';
import '../../services/library/library_provider.dart';
import '../../services/navigation/show_info.dart';
import '../../utils/logging.dart';
import '../../utils/path_utils.dart';
import '../../utils/shell_utils.dart';
import '../../utils/time_utils.dart';
import 'package:flutter_desktop_context_menu/flutter_desktop_context_menu.dart';

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
  late final Menu menu;

  @override
  void initState() {
    super.initState();
    menu = episodeMenu(
      context: widget.context,
      episode: widget.episode,
    );
  }

  void openMenu() {
    popUpContextMenu(
      menu,
      placement: Placement.bottomRight,
    );
  }

  Menu episodeMenu({
    required final BuildContext context,
    required final Episode episode,
  }) {
    return Menu(
      items: [
        MenuItem(
          label: 'Play',
          // icon: r"C:\Users\LordLux\Pictures\Icons\Win11VideoScriptss.ico".replaceAll("\\", ps),
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
          shortcutModifiers: ShortcutModifiers(control: Platform.isWindows, meta: Platform.isMacOS),
          onClick: (_) => _openFolderLocation(context),
        ),
        MenuItem(
          label: 'Copy Filename',
          shortcutKey: 'c',
          shortcutModifiers: ShortcutModifiers(control: Platform.isWindows, meta: Platform.isMacOS),
          onClick: (_) => _copyFilename(context),
        ),
        MenuItem.separator(),
        MenuItem.checkbox(
          key: 'watched',
          label: episode.watched ? 'Unmark as Watched' : 'Mark as Watched',
          toolTip: episode.watched ? 'Unmark as watched' : 'Mark as watched',
          checked: widget.episode.watched,
          onClick: (menuItem) {
            _toggleWatched(context);
            nextFrame(() => menuItem.checked = !(menuItem.checked == true));
          },
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
    } catch (e) {
      logErr('Error opening with dialog', e);
      snackBar('Could not open with dialog: $e', severity: InfoBarSeverity.error);
    }
  }

  void _openFolderLocation(BuildContext context) async {
    try {
      ShellUtils.openFileExplorerAndSelect(widget.episode.path);
    } catch (e) {
      logErr('Error opening folder location', e);
      snackBar('Could not open folder: $e', severity: InfoBarSeverity.error);
    }
  }

  void _copyFilename(BuildContext context) {
    final filename = p.basename(widget.episode.path);
    copyToClipboard(filename);
    snackBar('Filename copied to clipboard', severity: InfoBarSeverity.success);
  }

  void _toggleWatched(BuildContext context) {
    final library = Provider.of<Library>(context, listen: false);
    final newState = !widget.episode.watched;

    library.markEpisodeWatched(widget.episode, watched: newState);

    snackBar(newState ? 'Marked as watched' : 'Marked as unwatched', severity: InfoBarSeverity.success);
    Manager.setState();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
