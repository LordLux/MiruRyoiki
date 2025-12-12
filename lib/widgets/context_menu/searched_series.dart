// ignore_for_file: sort_child_properties_last

import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_desktop_context_menu/flutter_desktop_context_menu.dart';
import 'package:miruryoiki/models/anilist/anime.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
import '../../utils/shell.dart';
import '../dialogs/image_select.dart';
import '../../utils/icons.dart' as icons;
import 'controller.dart';

class SearchedSeriesContextMenu extends StatefulWidget {
  final AnilistAnime series;
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
    required final AnilistAnime series,
  }) {
    return Menu(
      items: [
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

  void _openInAnilist(BuildContext context) => launchUrl(Uri.parse('https://anilist.co/anime/${widget.series.id}'));

  @override
  Widget build(BuildContext context) => widget.child;
}
