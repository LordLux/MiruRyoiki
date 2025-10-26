// ignore_for_file: sort_child_properties_last

import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/models/mapping_target.dart';
import 'package:provider/provider.dart';
import 'package:flutter_desktop_context_menu/flutter_desktop_context_menu.dart';

import '../../manager.dart';
import '../../models/series.dart';
import '../../services/library/library_provider.dart';
import '../../services/lock_manager.dart';
import '../../services/navigation/show_info.dart';
import '../../utils/shell.dart';
import '../../utils/icons.dart' as icons;

class MappingContextMenu extends StatefulWidget {
  final MappingTarget target;
  final Series series;
  final Widget child;
  final BuildContext context;

  const MappingContextMenu({
    super.key,
    required this.context,
    required this.target,
    required this.series,
    required this.child,
  });

  @override
  State<MappingContextMenu> createState() => MappingContextMenuState();
}

class MappingContextMenuState extends State<MappingContextMenu> {
  void openMenu() {
    popUpContextMenu(
      episodeMenu(
        context: widget.context,
        target: widget.target,
      ),
      placement: Placement.bottomRight,
    );
  }

  Menu episodeMenu({
    required final BuildContext context,
    required final MappingTarget target,
  }) {
    final library = Provider.of<Library>(context, listen: false);
    final shouldDisable = library.isIndexing;

    return Menu(
      items: [
        MenuItem(
          label: 'Play next episode',
          icon: icons.play,
          shortcutKey: 'p',
          shortcutModifiers: ShortcutModifiers(control: Platform.isWindows, meta: Platform.isMacOS),
          onClick: (_) => _playNextEpisode(context),
        ),
        MenuItem(
          label: 'Open Folder Location',
          shortcutKey: 'f',
          icon: icons.folder_open,
          shortcutModifiers: ShortcutModifiers(control: Platform.isWindows, meta: Platform.isMacOS),
          onClick: (_) => _openFolderLocation(context),
        ),
        MenuItem.separator(),
        MenuItem(
          label: 'Remove mapping',
          shortcutKey: 'r',
          onClick: (_) => _removeMapping(context),
          icon: icons.remove_link,
          disabled: shouldDisable,
          shortcutModifiers: ShortcutModifiers(control: Platform.isWindows, meta: Platform.isMacOS),
        ),
        MenuItem(
          label: target.watchedPercentage == 1 ? 'Unmark as Watched' : 'Mark as Watched',
          shortcutKey: 'w',
          icon: target.watchedPercentage == 1 ? icons.unwatch : icons.check,
          disabled: shouldDisable,
          onClick: (_) => _toggleWatched(context),
        ),
        MenuItem(
          label: 'Open Anilist Dialog',
          icon: icons.anilist,
          onClick: (_) => _openAnilistDialog(context),
          disabled: shouldDisable
        ),
      ],
    );
  }

  void _playNextEpisode(BuildContext context) {
    final library = Provider.of<Library>(context, listen: false);
    library.playNextEpisode(widget.target);
  }

  void _openFolderLocation(BuildContext context) async {
    try {
      ShellUtils.openFileExplorerAndSelect(widget.target.path);
    } catch (e, stackTrace) {
      snackBar(
        'Could not open folder: $e',
        severity: InfoBarSeverity.error,
        exception: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _toggleWatched(BuildContext context) {
    final library = Provider.of<Library>(context, listen: false);
    final newState = !(widget.target.watchedPercentage == 1);

    // Check if the action should be disabled
    if (library.lockManager.shouldDisableAction(UserAction.markEpisodeWatched)) {
      snackBar(
        library.lockManager.getDisabledReason(UserAction.markEpisodeWatched),
        severity: InfoBarSeverity.warning,
      );
      return;
    }

    library.markTargetWatched(widget.target, watched: newState);

    snackBar(newState ? 'Marked as watched' : 'Marked as unwatched', severity: InfoBarSeverity.success);
    Manager.setState();
  }
  
  void _removeMapping(BuildContext context) {
    final library = Provider.of<Library>(context, listen: false);

    // Check if the action should be disabled
    if (library.lockManager.shouldDisableAction(UserAction.updateSeriesInfo)) {
      snackBar(
        library.lockManager.getDisabledReason(UserAction.updateSeriesInfo),
        severity: InfoBarSeverity.warning,
      );
      return;
    }

    library.removeMapping(widget.series, widget.target);
    snackBar('Mapping removed', severity: InfoBarSeverity.success);
    Manager.setState();
  }
  
  void _openAnilistDialog(BuildContext context) {
    snackBar("Not yet implemented", severity: InfoBarSeverity.warning);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
