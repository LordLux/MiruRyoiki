// ignore_for_file: sort_child_properties_last

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_desktop_context_menu/flutter_desktop_context_menu.dart';

import '../../manager.dart';
import '../../models/folder_node.dart';
import '../../models/series.dart';
import '../../services/library/library_provider.dart';
import '../../services/navigation/show_info.dart';
import '../../utils/shell.dart';
import '../../utils/icons.dart' as icons;
import '../../utils/time.dart';
import '../dialogs/link_anilist.dart';
import '../file_explorer.dart';
import 'controller.dart';

/// Right-click menu for an **unlinked** folder node card, so an unmapped folder
/// is never a dead end. Mapped folder nodes use [MappingContextMenu] instead.
class FolderNodeContextMenu extends StatefulWidget {
  final FolderNode node;
  final Series series;
  final Widget child;
  final BuildContext context;
  final DesktopContextMenuController controller;
  final VoidCallback? onChanged;

  const FolderNodeContextMenu({
    super.key,
    required this.context,
    required this.node,
    required this.series,
    required this.child,
    required this.controller,
    this.onChanged,
  });

  @override
  State<FolderNodeContextMenu> createState() => FolderNodeContextMenuState();
}

class FolderNodeContextMenuState extends State<FolderNodeContextMenu> {
  @override
  void initState() {
    super.initState();
    widget.controller.attach(_openMenu, _openMenuAt, this);
  }

  @override
  void didUpdateWidget(FolderNodeContextMenu oldWidget) {
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
    popUpContextMenu(_buildMenu(widget.context), position: position, placement: placement);
  }

  Menu _buildMenu(BuildContext context) {
    final fullyWatched = widget.node.watchedPercentage == 1 && widget.node.totalCount > 0;
    return Menu(
      items: [
        MenuItem(
          label: 'Open Folder',
          icon: icons.folder_open,
          onClick: (_) => _openFolder(),
        ),
        MenuItem(
          label: fullyWatched ? 'Mark folder unwatched' : 'Mark folder watched',
          icon: fullyWatched ? icons.unwatch : icons.check,
          onClick: (_) => _toggleWatched(context, !fullyWatched),
        ),
        MenuItem.separator(),
        MenuItem(
          label: 'Link to AniList…',
          icon: icons.anilist,
          onClick: (_) => _linkToAnilist(context),
        ),
      ],
    );
  }

  void _openFolder() {
    try {
      ShellUtils.openFolder(widget.node.path.path);
    } catch (e, st) {
      snackBar('Could not open folder: $e', severity: InfoBarSeverity.error, exception: e, stackTrace: st);
    }
  }

  void _toggleWatched(BuildContext context, bool watched) {
    final library = Provider.of<Library>(context, listen: false);
    // Recursive: a folder represents everything inside it.
    library.markEpisodesWatched(widget.node.subtreeEpisodes, watched: watched, overrideProgress: true);
    snackBar(watched ? 'Marked folder as watched' : 'Marked folder as unwatched', severity: InfoBarSeverity.success);
    widget.onChanged?.call();
    nextFrame(() => Manager.setState());
  }

  void _linkToAnilist(BuildContext context) {
    linkWithAnilist(
      context,
      widget.series,
      (_) async {},
      (_) {},
      initialLocalPath: widget.node.path,
      lockLocal: true,
      startInAddMode: true,
      explorerOptions: FileExplorerOptions(
        allowCreateFolder: true,
        allowRename: true,
        allowCurrentFolder: true,
        allowDelete: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
