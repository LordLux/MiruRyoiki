// ignore_for_file: sort_child_properties_last

import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_desktop_context_menu/flutter_desktop_context_menu.dart';
import '../../models/anilist/anime_card.dart';
import '../../utils/anilist_utils.dart';
import '../../utils/icons.dart' as icons;
import '../dialogs/entry_editor.dart';
import 'controller.dart';

class SearchedSeriesContextMenu extends StatefulWidget {
  final AnimeCard series;
  final Widget child;
  final BuildContext context;
  final DesktopContextMenuController controller;

  const SearchedSeriesContextMenu({
    super.key,
    required this.series,
    required this.child,
    required this.context,
    required this.controller,
  });

  @override
  State<SearchedSeriesContextMenu> createState() => SearchedSeriesContextMenuState();
}

class SearchedSeriesContextMenuState extends State<SearchedSeriesContextMenu> {
  @override
  void initState() {
    super.initState();
    widget.controller.attach(_openMenu, _openMenuAt, this);
  }

  @override
  void didUpdateWidget(SearchedSeriesContextMenu oldWidget) {
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
      seriesMenu(
        context: widget.context,
        series: widget.series,
      ),
      position: position,
      placement: placement,
    );
  }

  Menu seriesMenu({
    required final BuildContext context,
    required final AnimeCard series,
  }) {
    return Menu(
      items: [
        MenuItem(
          label: 'Add to Library',
          icon: icons.list,
          onClick: (_) => _openEntryEditor(context),
        ),
        MenuItem.separator(),
        MenuItem(
          label: 'Open in Anilist',
          shortcutKey: 'a',
          icon: icons.anilist,
          shortcutModifiers: ShortcutModifiers(control: Platform.isWindows, meta: Platform.isMacOS),
          onClick: (_) => _openInAnilist(context),
        ),
      ],
    );
  }

  void _openInAnilist(BuildContext context) => openAnilistAnime(widget.series.id);

  void _openEntryEditor(BuildContext context) {
    final s = widget.series;
    final displayTitle = s.title.userPreferred ?? s.title.romaji ?? s.title.english ?? 'Unknown';
    showEntryEditorDialog(
      context,
      mediaId: s.id,
      title: displayTitle,
      totalEpisodes: s.episodes,
      coverImage: s.coverImage,
      isFavourite: s.isFavourite,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
