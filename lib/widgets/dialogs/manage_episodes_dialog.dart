// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:path/path.dart' as p;
import 'package:sticky_headers/sticky_headers.dart';

import '../../manager.dart';
import '../../models/episode.dart';
import '../../models/series.dart';
import '../../models/sonarr/sonarr_episode.dart';
import '../../models/sonarr/sonarr_episode_file.dart';
import '../../services/downloads/torrent_manager.dart';
import '../../services/isolates/thumbnail_manager.dart';
import '../../services/navigation/dialogs2.dart';
import '../../services/navigation/navigation.dart';
import '../../services/navigation/show_info.dart';
import '../buttons/button.dart';
import 'show_dialog.dart';
import '../../utils/logging.dart';
import '../../utils/path.dart';
import '../file_explorer.dart';
import '../tooltip_wrapper.dart';

/// Dialog for managing Sonarr episode ↔ file links
///
/// Fetches fresh data from Sonarr every time it opens, displays Sonarr's own file data, and only tracks user overrides for syncing back
class ManageEpisodesDialog extends StatefulWidget {
  final List<SonarrEpisode> sonarrEpisodes;
  final Series? localSeries;
  final String seriesTitle;
  final int? sonarrSeriesId;

  const ManageEpisodesDialog({
    super.key,
    required this.sonarrEpisodes,
    required this.localSeries,
    required this.seriesTitle,
    this.sonarrSeriesId,
  });

  @override
  State<ManageEpisodesDialog> createState() => _ManageEpisodesDialogState();
}

class _ManageEpisodesDialogState extends State<ManageEpisodesDialog> {
  late List<SonarrEpisode> _sonarrEpisodes;
  bool _isLoading = true;
  bool _isSyncing = false;

  /// Sonarr's own file data per episode (from getEpisodeFiles API)
  final Map<int, SonarrEpisodeFile> _sonarrFiles = {};

  /// User overrides: sonarrEpId → local file path (only set when user clicks Change)
  final Map<int, String> _userOverrides = {};

  // Cached thumbnail paths: local file path → thumbnail path
  final Map<String, String?> _thumbnails = {};
  // Local episodes indexed by path for quick lookup
  final Map<String, Episode> _localByPath = {};

  @override
  void initState() {
    super.initState();
    _sonarrEpisodes = widget.sonarrEpisodes;
    _indexLocalEpisodes();
    _loadThumbnails();
    _fetchFreshData();
  }

  /// Fetch fresh episode + episode file data from Sonarr
  ///
  /// Links are derived from Sonarr's own hasFile/episodeFileId
  Future<void> _fetchFreshData() async {
    final sonarr = TorrentManager.sonarrRepository;
    final seriesId = widget.sonarrSeriesId;
    if (sonarr == null || seriesId == null) {
      logTrace('[ManageEpisodes] No Sonarr repo or seriesId — skipping fetch');
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      logTrace('[ManageEpisodes] Fetching fresh episodes + files for seriesId=$seriesId');
      final freshEpisodes = await sonarr.getEpisodes(seriesId);
      final episodeFiles = await sonarr.getEpisodeFiles(seriesId);
      logTrace('[ManageEpisodes] Fetched ${freshEpisodes.length} episodes, ${episodeFiles.length} files');

      final fileById = {for (final f in episodeFiles) f.id: f};

      if (!mounted) return;
      setState(() {
        _sonarrEpisodes = freshEpisodes;
        _sonarrFiles.clear();

        for (final ep in freshEpisodes) {
          if (ep.hasFile && ep.episodeFileId != null && ep.episodeFileId! > 0) {
            final file = fileById[ep.episodeFileId!];
            if (file != null) {
              _sonarrFiles[ep.id] = file;
              logTrace('[ManageEpisodes] S${ep.seasonNumber}E${ep.episodeNumber}: file="${file.relativePath}"');
            }
          }
        }

        logTrace('[ManageEpisodes] ${_sonarrFiles.length}/${freshEpisodes.length} episodes have files in Sonarr');
        _isLoading = false;
      });
      _loadSonarrFileThumbnails();
    } catch (e) {
      logErr('[ManageEpisodes] Failed to fetch fresh data', e);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _indexLocalEpisodes() {
    if (widget.localSeries == null) return;
    widget.localSeries!.seasons //
        .expand((season) => season.episodes)
        .forEach((ep) => _localByPath[ep.path.path] = ep);
  }

  void _loadThumbnails() {
    final thumbManager = ThumbnailManager();
    for (final ep in _localByPath.values) {
      final key = ep.path.path;
      if (ep.thumbnailPath?.pathMaybe != null && File(ep.thumbnailPath!.path).existsSync()) {
        _thumbnails[key] = ep.thumbnailPath!.path;
        continue;
      }
      thumbManager.getThumbnail(ep.path).then((result) {
        if (result != null && mounted) {
          setState(() => _thumbnails[key] = result.path);
        }
      });
    }
  }

  /// Generate thumbnails for Sonarr-managed files by resolving their local paths
  void _loadSonarrFileThumbnails() {
    if (widget.localSeries == null) return;
    final thumbManager = ThumbnailManager();
    final seriesRoot = widget.localSeries!.path.path;

    for (final sonarrFile in _sonarrFiles.values) {
      final localPath = p.join(seriesRoot, sonarrFile.relativePath);
      if (_thumbnails.containsKey(localPath)) continue;
      final file = File(localPath);
      if (!file.existsSync()) continue;

      final ps = PathString(localPath);
      thumbManager.getThumbnail(ps).then((result) {
        if (result != null && mounted) {
          setState(() => _thumbnails[localPath] = result.path);
        }
      });
    }
  }

  /// Pick a local file to link to a Sonarr episode
  void _changeLinkForEpisode(SonarrEpisode sonarrEp) {
    if (widget.localSeries == null) return;
    if (!mounted) return;

    PathString? selectedPath;

    void onConfirm(PathString? path) {
      if (path == null || !mounted) return;
      logTrace('[ManageEpisodes] Override: ep ${sonarrEp.id} (S${sonarrEp.seasonNumber}E${sonarrEp.episodeNumber}) → "${path.path}"');
      setState(() => _userOverrides[sonarrEp.id] = path.path);
    }

    showPaddedDialog(
      context,
      navigationItem: DialogNavigationItem(
        id: 'manage-episodes:file-link',
        title: 'Select Episode File',
      ),
      builder: (context, item, options) => PaddedDialog.simple(
        navigationItem: item,
        barrierOptions: options,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
        title: Text(
          "Select file for S${sonarrEp.seasonNumber.toString().padLeft(2, '0')}"
          "E${sonarrEp.episodeNumber.toString().padLeft(2, '0')}"
          " — ${sonarrEp.title}",
        ),
        content: FileExplorer(
          rootPath: widget.localSeries!.path,
          options: const FileExplorerOptions(
            allowFiles: true,
            allowCurrentFolder: false,
          ),
          onSelectionChanged: (sel) => selectedPath = sel.firstOrNull,
          onFileDoubleTap: (path) {
            closeDialog();
            onConfirm(path);
          },
        ),
        actions: [
          Row(
            children: [
              Button(onPressed: closeDialog, child: const Text("Cancel")),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  closeDialog();
                  onConfirm(selectedPath);
                },
                child: const Text("Select"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Count of episodes that have a file (either from Sonarr or user override)
  int get _linkedCount {
    int count = 0;
    for (final ep in _sonarrEpisodes) {
      if (_userOverrides.containsKey(ep.id) || _sonarrFiles.containsKey(ep.id)) count++;
    }
    return count;
  }

  bool get _hasChanges => _userOverrides.isNotEmpty;

  /// Syncs user overrides to Sonarr via manual import
  Future<void> _syncToSonarr() async {
    final controller = TorrentManager.downloadController;
    final seriesId = widget.sonarrSeriesId;
    if (controller == null || seriesId == null) {
      snackBar('Sonarr is not configured.', severity: InfoBarSeverity.error);
      return;
    }

    if (_userOverrides.isEmpty) {
      if (mounted) closeDialog();
      return;
    }

    logTrace('[ManageEpisodes] Sync: ${_userOverrides.length} overrides to import');
    setState(() => _isSyncing = true);
    int successCount = 0;
    int failCount = 0;

    if (widget.localSeries != null) {
      try {
        await controller.ensureSonarrSeriesPath(seriesId, widget.localSeries!.path.path);
      } catch (e) {
        logErr('Failed to update Sonarr series path', e);
      }
    }

    final sonarrEpById = {for (final ep in _sonarrEpisodes) ep.id: ep};

    for (final entry in _userOverrides.entries) {
      final sonarrEp = sonarrEpById[entry.key];
      if (sonarrEp == null) continue;

      try {
        logTrace('[ManageEpisodes] Importing "${entry.value}" → S${sonarrEp.seasonNumber}E${sonarrEp.episodeNumber}');
        await controller.manualImportFile(
          localFilePath: entry.value,
          sonarrSeriesId: seriesId,
          sonarrEpisodeId: sonarrEp.id,
          seasonNumber: sonarrEp.seasonNumber,
        );
        successCount++;
      } catch (e) {
        failCount++;
        logErr('Failed to import ${entry.value}', e);
      }
    }

    if (mounted) {
      setState(() => _isSyncing = false);
      if (successCount > 0) {
        snackBar(
          'Updated $successCount episode${successCount > 1 ? 's' : ''} in Sonarr'
          '${failCount > 0 ? ' ($failCount failed)' : ''}',
          severity: failCount > 0 ? InfoBarSeverity.warning : InfoBarSeverity.success,
        );
        if (mounted) closeDialog();
      } else if (failCount > 0) {
        snackBar('Failed to update $failCount episode${failCount > 1 ? 's' : ''}. Check logs.', severity: InfoBarSeverity.error);
      }
    }
  }

  Widget _buildThumbnailForPath(String? filePath) {
    if (filePath == null) return _placeholderThumb();
    final thumbPath = _thumbnails[filePath];
    if (thumbPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.file(
          File(thumbPath),
          width: 64,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderThumb(),
        ),
      );
    }
    return _placeholderThumb();
  }

  Widget _placeholderThumb() {
    return Container(
      width: 64,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[160].withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(FluentIcons.video, size: 16, color: Colors.grey[120]),
    );
  }

  bool _isFutureEpisode(SonarrEpisode ep) {
    if (ep.airDateUtc == null) return true;
    final airDate = DateTime.tryParse(ep.airDateUtc!);
    return airDate == null || airDate.isAfter(DateTime.now());
  }

  Widget _buildRow(BuildContext context, SonarrEpisode sonarrEp) {
    final isFuture = _isFutureEpisode(sonarrEp);
    final override = _userOverrides[sonarrEp.id];
    final sonarrFile = _sonarrFiles[sonarrEp.id];
    final hasFile = override != null || sonarrFile != null;

    String? displayName;
    String? displayPath;
    String? thumbnailPath;

    if (override != null) {
      displayName = p.basename(override);
      displayPath = widget.localSeries != null ? p.relative(override, from: widget.localSeries!.path.path) : displayName;
      thumbnailPath = override;
    } else if (sonarrFile != null) {
      displayName = sonarrFile.fileName;
      displayPath = sonarrFile.relativePath;
      if (widget.localSeries != null) {
        final localPath = p.join(widget.localSeries!.path.path, sonarrFile.relativePath);
        if (_thumbnails.containsKey(localPath) || File(localPath).existsSync()) {
          thumbnailPath = localPath;
        }
      }
    }

    final dimColor = Colors.grey[120];
    final futureStyle = TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: dimColor);
    final isOverridden = override != null;

    return Opacity(
      opacity: isFuture ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: isOverridden ? Manager.currentDominantColor?.withOpacity(0.15) : null,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, left: 8.0, right: 16.0),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(
                'S${sonarrEp.seasonNumber.toString().padLeft(2, '0')}\n'
                'E${sonarrEp.episodeNumber.toString().padLeft(2, '0')}',
                style: isFuture ? futureStyle : TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: dimColor),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: TooltipWrapper(
                tooltip: sonarrEp.title,
                child: (text) => Text(
                  sonarrEp.title,
                  style: isFuture ? futureStyle : const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(FluentIcons.forward, size: 12, color: dimColor),
            const SizedBox(width: 8),
            _buildThumbnailForPath(thumbnailPath),
            const SizedBox(width: 10),
            Expanded(
              flex: 4,
              child: isFuture
                  ? Text('Not aired yet', style: futureStyle)
                  : hasFile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName!,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                            TooltipWrapper(
                              tooltip: displayPath!,
                              child: (text) => Text(
                                text,
                                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      : Text('No file linked', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: dimColor)),
            ),
            const SizedBox(width: 8),
            Button(
              onPressed: isFuture ? null : () => _changeLinkForEpisode(sonarrEp),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FluentIcons.edit, size: 12),
                  const SizedBox(width: 6),
                  Text(hasFile ? 'Change' : 'Link'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSync = widget.sonarrSeriesId != null && _linkedCount > 0 && _hasChanges;

    final grouped = groupBy(_sonarrEpisodes, (SonarrEpisode e) => e.seasonNumber);
    for (final eps in grouped.values) {
      eps.sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
    }
    final seasonNumbers = grouped.keys.where((s) => s > 0).toList()..sort((a, b) => b.compareTo(a));
    seasonNumbers.addAll(grouped.keys.where((s) => s == 0));

    return ContentDialog(
      title: Row(
        children: [
          Text("Manage Episodes — ${widget.seriesTitle}"),
          const Spacer(),
          TooltipWrapper(
            tooltip: "Attempt to automatically link Sonarr episodes to local files.",
            child: (tooltip) => StandardButton.iconLabel(
              icon: const Icon(Icons.question_mark, size: 16),
              label: const Text("Auto-link"),
              onPressed: () => _performAutoLinking(),
            ),
          ),
        ],
      ),
      constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
      content: _isLoading
          ? const Center(child: SizedBox(width: 32, height: 32, child: RepaintBoundary(child: ProgressRing())))
          : _sonarrEpisodes.isEmpty
              ? const Center(child: Text("No Sonarr episodes found"))
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          for (final sNum in seasonNumbers)
                            StickyHeader(
                              header: Transform.translate(
                                offset: const Offset(0, -1),
                                child: Container(
                                  color: FluentTheme.of(context).acrylicBackgroundColor,
                                  padding: const EdgeInsets.only(right: 8, bottom: 4, top: 16),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const SizedBox(width: 8),
                                          Text(
                                            sNum == 0 ? 'Specials' : 'Season $sNum',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          const Spacer(),
                                          Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: Text(
                                              '${grouped[sNum]!.where((e) => _userOverrides.containsKey(e.id) || _sonarrFiles.containsKey(e.id)).length}/${grouped[sNum]!.length}',
                                              style: TextStyle(fontSize: 12, color: Colors.grey[120]),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Transform.scale(scale: 1.02, child: const Divider()),
                                    ],
                                  ),
                                ),
                              ),
                              content: Column(
                                children: [
                                  for (final ep in grouped[sNum]!) _buildRow(context, ep),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
      actions: [
        if (_isSyncing)
          const Center(child: SizedBox(width: 24, height: 24, child: RepaintBoundary(child: ProgressRing())))
        else
          Row(
            children: [
              Button(child: const Text("Cancel"), onPressed: () => closeDialog()),
              const Spacer(),
              Text('$_linkedCount/${_sonarrEpisodes.length} linked', style: TextStyle(fontSize: 12, color: Colors.grey[120])),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: canSync ? _syncToSonarr : null,
                child: Text(_hasChanges ? "Save & Sync (${_userOverrides.length})" : "Save & Sync"),
              ),
            ],
          ),
      ],
    );
  }

  // TODO implement autolink if Sonarr doesn't have it already. This would attempt to match Sonarr episodes to local files based on filename similarity, and populate _userOverrides accordingly
  void _performAutoLinking() {
    snackBar('Auto-linking is not implemented yet.', severity: InfoBarSeverity.warning);
  }
}
