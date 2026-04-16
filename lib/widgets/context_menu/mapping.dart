// ignore_for_file: sort_child_properties_last

import 'dart:io';
import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/models/mapping_target.dart';
import 'package:provider/provider.dart';
import 'package:flutter_desktop_context_menu/flutter_desktop_context_menu.dart';

import '../../manager.dart';
import '../../models/anilist/user_list.dart';
import '../../models/series.dart';
import '../../services/anilist/provider/anilist_provider.dart';
import '../../services/library/library_provider.dart';
import '../../services/library/scanner/scanner_service.dart';
import '../../services/lock_manager.dart';
import '../../services/navigation/show_info.dart';
import '../../utils/shell.dart';
import '../../utils/icons.dart' as icons;
import '../dialogs/entry_editor.dart';
import 'controller.dart';

class MappingContextMenu extends StatefulWidget {
  final MappingTarget target;
  final Series series;
  final Widget child;
  final BuildContext context;
  final DesktopContextMenuController controller;
  final VoidCallback? onChanged;

  const MappingContextMenu({
    super.key,
    required this.context,
    required this.target,
    required this.series,
    required this.child,
    required this.controller,
    this.onChanged,
  });

  @override
  State<MappingContextMenu> createState() => MappingContextMenuState();
}

class MappingContextMenuState extends State<MappingContextMenu> {
  @override
  void initState() {
    super.initState();
    widget.controller.attach(_openMenu, _openMenuAt, this);
  }

  @override
  void didUpdateWidget(MappingContextMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.detach(this);
      widget.controller.attach(_openMenu, _openMenuAt, this);
    }
  }

  @override
  void dispose() {
    widget.controller.detach(this);
    super.dispose();
  }

  void _openMenu() => _openMenuAt(null, Placement.bottomRight);

  void _openMenuAt(Offset? position, Placement placement) {
    popUpContextMenu(
      episodeMenu(
        context: widget.context,
        target: widget.target,
      ),
      position: position,
      placement: placement,
    );
  }

  Menu episodeMenu({
    required final BuildContext context,
    required final MappingTarget target,
  }) {
    final scannerService = Provider.of<LibraryScannerService>(context, listen: false);
    final shouldDisable = scannerService.isIndexing;

    return Menu(
      items: [
        MenuItem(
          label: 'Open Anilist Dialog',
          shortcutKey: 'a',
          icon: icons.anilist,
          onClick: (_) => _openAnilistDialog(context),
          disabled: shouldDisable,
        ),
        MenuItem(
          label: 'Remove mapping',
          shortcutKey: 'r',
          onClick: (_) => _removeMapping(context),
          icon: icons.remove_link,
          disabled: shouldDisable,
          shortcutModifiers: ShortcutModifiers(control: Platform.isWindows, meta: Platform.isMacOS),
        ),
        MenuItem(
          label: target.watchedPercentage == 1 //
              ? 'Unmark as Watched'
              : 'Mark as Watched',
          shortcutKey: 'w',
          icon: target.watchedPercentage == 1 ? icons.unwatch : icons.check,
          disabled: shouldDisable,
          onClick: (_) => _toggleWatched(context),
        ),
        MenuItem.separator(),
        MenuItem(
          label: target.watchedPercentage == 0 //
              ? 'Play first Episode'
              : 'Play next Episode',
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
    widget.onChanged?.call();
    Manager.setState();
  }

  void _removeMapping(BuildContext context) {
    final library = Provider.of<Library>(context, listen: false);

    final mappingToRestore = widget.series.anilistMappings.firstWhereOrNull((m) => m.localPath == widget.target.path);

    library.removeMapping(widget.series, widget.target);

    snackBar(
      'Mapping removed',
      severity: InfoBarSeverity.success,
      action: mappingToRestore != null
          ? Button(
              child: Text('Undo', style: Manager.bodyStyle.copyWith(decoration: TextDecoration.underline)),
              onPressed: () {
                widget.series.anilistMappings.add(mappingToRestore);
                library.updateSeries(widget.series);
                widget.onChanged?.call();
                Manager.setState();
                snackBar('Mapping restored', severity: InfoBarSeverity.success);
              },
            )
          : null,
    );
    widget.onChanged?.call();
    Manager.setState();
  }

  void _openAnilistDialog(BuildContext context) {
    // Find the AnilistMapping whose localPath matches the target path, or fall back to the primary
    final mapping = widget.series.anilistMappings.firstWhereOrNull((m) => m.localPath == widget.target.path) //
        ??
        widget.series.anilistMappings.firstOrNull;

    if (mapping == null) {
      snackBar('No AniList mapping found for this item', severity: InfoBarSeverity.warning);
      return;
    }

    final anime = mapping.anilistData;
    if (anime == null) {
      snackBar('No AniList data available for this mapping', severity: InfoBarSeverity.warning);
      return;
    }

    final displayTitle = mapping.preferredTitle ?? anime.title.userPreferred ?? anime.title.romaji ?? anime.title.english ?? 'Unknown';

    // Look up existing entry in user's lists
    final anilist = Provider.of<AnilistProvider>(context, listen: false);
    AnilistMediaListEntry? existing;
    for (final list in anilist.userLists.values) {
      for (final entry in list.entries) {
        if (entry.mediaId == mapping.anilistId) {
          existing = entry;
          break;
        }
      }
      if (existing != null) break;
    }

    showEntryEditorDialog(
      context,
      mediaId: mapping.anilistId,
      title: displayTitle,
      totalEpisodes: anime.episodes,
      bannerImage: anime.bannerImage,
      coverImage: anime.posterImage,
      isFavourite: anime.isFavourite ?? false,
      entry: existing,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
