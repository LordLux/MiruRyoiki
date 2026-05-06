// ignore_for_file: sort_child_properties_last

import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_desktop_context_menu/flutter_desktop_context_menu.dart';
import 'package:provider/provider.dart';
import '../../models/anilist/anime_card.dart';
import '../../services/anilist/provider/anilist_provider.dart';
import '../../services/library/library_provider.dart';
import '../../utils/anilist_utils.dart';
import '../../utils/icons.dart' as icons;
import '../../utils/searched_series_actions.dart' as actions;
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
    final anilist = Provider.of<AnilistProvider>(context, listen: false);
    final library = Provider.of<Library>(context, listen: false);
    final isInAnilist = anilist.allUserAnilistIds.contains(series.id);
    final isInLibrary = isInAnilist && library.mappedAnilistIds.contains(series.id);

    final label = isInLibrary
        ? 'Go to Series'
        : isInAnilist
            ? 'Add to Library'
            : 'Add to Anilist';

    return Menu(
      items: [
        MenuItem(
          label: label,
          icon: icons.list,
          onClick: (_) {
            if (isInLibrary) {
              actions.goToLibrarySeries(context, series.id);
            } else if (isInAnilist) {
              actions.startAddToLibraryFlow(context, series);
            } else {
              actions.openEntryEditor(context, series);
            }
          },
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

  @override
  Widget build(BuildContext context) => widget.child;
}
