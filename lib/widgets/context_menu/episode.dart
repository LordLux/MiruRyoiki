// ignore_for_file: sort_child_properties_last

import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:miruryoiki/functions.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import '../../models/episode.dart';
import '../../models/series.dart';
import '../../services/library/library_provider.dart';
import '../../services/navigation/show_info.dart';
import '../../utils/logging.dart';
import '../../utils/shell_utils.dart';
import 'context_menu.dart';
import 'package:open_dir/open_dir.dart';

class EpisodeContextMenu extends StatelessWidget {
  final Episode episode;
  final Series series;
  final Widget child;
  final VoidCallback? onTap;

  const EpisodeContextMenu({
    super.key,
    required this.episode,
    required this.series,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ContextMenuOverlay(
      onTap: onTap,
      child: child,
      items: [
        ContextMenuItemData(
          label: 'Play',
          icon: FluentIcons.play,
          onPressed: () => _playEpisode(context),
        ),
        ContextMenuItemData(
          label: 'Open With...',
          icon: FluentIcons.open_with,
          onPressed: () => _openWith(context),
        ),
        ContextMenuItemData.divider(),
        ContextMenuItemData(
          label: 'Open Folder Location',
          icon: FluentIcons.folder_open,
          onPressed: () => _openFolderLocation(context),
        ),
        ContextMenuItemData(
          label: 'Copy Filename',
          icon: FluentIcons.copy,
          onPressed: () => _copyFilename(context),
        ),
        ContextMenuItemData.divider(),
        ContextMenuItemData(
          label: episode.watched ? 'Mark as Unwatched' : 'Mark as Watched',
          icon: episode.watched ? FluentIcons.clear : FluentIcons.check_mark,
          onPressed: () => _toggleWatched(context),
        ),
        ContextMenuItemData(
          label: 'Blur Thumbnail (Not Implemented)',
          icon: FluentIcons.blur,
          onPressed: () => _blurThumbnail(context),
        ),
      ],
    );
  }

  void _playEpisode(BuildContext context) {
    final library = Provider.of<Library>(context, listen: false);
    library.playEpisode(episode);
  }

  void _openWith(BuildContext context) {
    try {
      ShellUtils.openWithDialog(episode.path);
    } catch (e) {
      logErr('Error opening with dialog', e);
      snackBar('Could not open with dialog: $e', severity: InfoBarSeverity.error);
    }
  }

  void _openFolderLocation(BuildContext context) async {
    try {
      ShellUtils.openFileExplorerAndSelect(episode.path);
    } catch (e) {
      logErr('Error opening folder location', e);
      snackBar('Could not open folder: $e', severity: InfoBarSeverity.error);
    }
  }

  void _copyFilename(BuildContext context) {
    final filename = p.basename(episode.path);
    copyToClipboard(filename);
    snackBar('Filename copied to clipboard', severity: InfoBarSeverity.success);
  }

  void _toggleWatched(BuildContext context) {
    final library = Provider.of<Library>(context, listen: false);
    final newState = !episode.watched;

    library.markEpisodeWatched(episode, watched: newState);

    snackBar(newState ? 'Marked as watched' : 'Marked as unwatched', severity: InfoBarSeverity.success);
  }

  void _blurThumbnail(BuildContext context) {
    // TODO: Implement thumbnail blurring with ffmpeg
    snackBar('Thumbnail blurring not yet implemented', severity: InfoBarSeverity.warning);
  }
}
