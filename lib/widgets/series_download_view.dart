import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart' hide Card, Divider, Tooltip, ListTile, IconButton, showDialog, FilledButton;
import 'package:miruryoiki/widgets/tooltip_wrapper.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:provider/provider.dart';
import '../manager.dart';
import '../models/episode.dart';
import '../models/series.dart';
import '../models/ui_episode.dart';
import '../services/library/library_provider.dart';
import 'episode_grid.dart';
import 'file_explorer.dart';
import 'package:miruryoiki/services/navigation/show_info.dart';
import '../models/anilist/anime.dart';
import '../models/sonarr/sonarr_episode.dart';
import '../models/sonarr/sonarr_episode_file.dart';
import '../models/sonarr/sonarr_quality_profile.dart';
import '../settings.dart';
import 'package:path/path.dart' as p;
import '../utils/path.dart';
import '../services/isolates/thumbnail_manager.dart';
import '../services/navigation/dialogs2.dart';
import '../services/navigation/navigation.dart';
import '../utils/logging.dart';
import '../utils/screen.dart';
import 'buttons/button.dart';
import 'dialogs/knaben_search.dart';
import 'dialogs/show_dialog.dart';
import 'dialogs/sonarr_manual_link_dialog.dart';
import '../services/downloads/torrent_manager.dart';

/// Watch tab for Searched Series with Sonarr integration
class SeriesDownloadView extends StatefulWidget {
  final int animeId;
  final AnilistTitle animeTitle;

  const SeriesDownloadView({
    super.key,
    required this.animeId,
    required this.animeTitle,
  });

  @override
  State<SeriesDownloadView> createState() => _SeriesDownloadViewState();
}

class _SeriesDownloadViewState extends State<SeriesDownloadView> {
  bool _isLoading = false;
  List<SonarrEpisode> _episodesMetadata = [];
  int? _sonarrSeriesId;
  String? _sonarrSeriesTitle;
  String? _sonarrSeriesPath;

  List<SonarrQualityProfile> _qualityProfiles = [];
  bool _isLoadingProfiles = false;
  int _selectedQualityProfileId = 0;

  @override
  void initState() {
    super.initState();
    _loadQualityProfiles().then((_) {
      _fetchData();
    });
  }

  Future<void> _loadQualityProfiles() async {
    final controller = TorrentManager.downloadController;
    if (controller == null || !mounted) return;

    setState(() {
      _isLoadingProfiles = true;
    });

    try {
      final profiles = await controller.getQualityProfiles();
      if (mounted) {
        setState(() {
          _qualityProfiles = profiles;
          final sId = SettingsManager().sonarrQualityProfileId;
          if (profiles.any((p) => p.id == sId)) {
            _selectedQualityProfileId = sId;
          } else if (profiles.isNotEmpty) {
            _selectedQualityProfileId = profiles.first.id;
          }
        });
      }
    } catch (e) {
      logErr("Failed to fetch quality profiles", e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfiles = false;
        });
      }
    }
  }

  void _onQualityProfileChanged(int newId) {
    setState(() => _selectedQualityProfileId = newId);
    SettingsManager().sonarrQualityProfileId = newId;
  }

  Future<void> _fetchData() async {
    if (!mounted || TorrentManager.downloadController == null) return;
    setState(() {
      _isLoading = true;
      _episodesMetadata.clear();
      _sonarrSeriesId = null;
    });

    try {
      final (id, eps) = await TorrentManager.downloadController!.syncAndFetchEpisodes(animeId: widget.animeId, altTitle: widget.animeTitle.romaji ?? "Unknown");
      if (!mounted) return;

      // Resolve the Sonarr series filesystem path for local library fallback
      String? seriesPath;
      try {
        final sonarr = TorrentManager.sonarrRepository;
        if (sonarr != null) {
          final seriesData = await sonarr.getSeriesById(id);
          seriesPath = seriesData['path'] as String?;
        }
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _sonarrSeriesId = id;
        _sonarrSeriesTitle = widget.animeTitle.romaji ?? "Unknown";
        _sonarrSeriesPath = seriesPath;
        _episodesMetadata = eps;
        // Sort descending
        _episodesMetadata.sort((a, b) {
          int cmp = b.seasonNumber.compareTo(a.seasonNumber);
          if (cmp != 0) return cmp;
          return b.episodeNumber.compareTo(a.episodeNumber);
        });
      });
    } catch (e) {
      if (mounted) {
        if (e.toString().contains("Mapping not found")) {
          showPaddedDialog(
            context,
            navigationItem: DialogNavigationItem(id: 'sonarr:manual-link', title: 'Link to Sonarr Series'),
            builder: (context, item, options) {
              return PaddedDialog.custom(
                navigationItem: item,
                barrierOptions: options,
                constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
                contentBuilder: (_, __) => SonarrManualLinkDialog(
                  animeId: widget.animeId,
                  animeTitle: widget.animeTitle,
                  onLinked: () => _fetchData(),
                ),
              );
            },
          );
        } else {
          snackBar("Failed to fetch Sonarr episodes: $e", severity: InfoBarSeverity.error);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _changeLink() {
    showPaddedDialog(
      context,
      navigationItem: DialogNavigationItem(id: 'sonarr:change-link', title: 'Link to Sonarr Series'),
      builder: (context, item, options) {
        return PaddedDialog.custom(
          navigationItem: item,
          barrierOptions: options,
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
          contentBuilder: (_, __) => SonarrManualLinkDialog(
            animeId: widget.animeId,
            animeTitle: widget.animeTitle,
            onLinked: () => _fetchData(),
          ),
        );
      },
    );
  }

  void _searchSeasonPack() {
    final controller = TorrentManager.downloadController;
    if (controller == null) return;
    final titles = <String>{
      if (widget.animeTitle.userPreferred != null) widget.animeTitle.userPreferred!,
      if (widget.animeTitle.romaji != null) widget.animeTitle.romaji!,
      if (widget.animeTitle.english != null) widget.animeTitle.english!,
      if (_sonarrSeriesTitle != null) _sonarrSeriesTitle!,
    }.where((t) => t.trim().isNotEmpty).toList();

    if (titles.isEmpty) {
      snackBar("Anime title not found. Cannot search.", severity: InfoBarSeverity.error);
      return;
    }

    final firstEp = _episodesMetadata.isNotEmpty ? _episodesMetadata.first : null;
    final season = firstEp?.seasonNumber ?? 1;

    showPaddedDialog(
      context,
      navigationItem: DialogNavigationItem(id: 'knaben:season-search', title: 'Season Search'),
      builder: (context, item, options) {
        return PaddedDialog.custom(
          navigationItem: item,
          barrierOptions: options,
          constraints: const BoxConstraints(maxWidth: 850, maxHeight: 650),
          contentBuilder: (_, __) => KnabenSearchDialog(
            controller: controller,
            seriesTitles: titles,
            season: season,
            isSeasonSearch: true,
            sonarrSeriesId: _sonarrSeriesId,
          ),
        );
      },
    );
  }

  void _showKnabenSearchDialog(SonarrEpisode ep) {
    final controller = TorrentManager.downloadController;
    if (controller == null) return;
    final titles = <String>{
      if (widget.animeTitle.userPreferred != null) widget.animeTitle.userPreferred!,
      if (widget.animeTitle.romaji != null) widget.animeTitle.romaji!,
      if (widget.animeTitle.english != null) widget.animeTitle.english!,
      if (_sonarrSeriesTitle != null) _sonarrSeriesTitle!,
    }.where((t) => t.trim().isNotEmpty).toList();

    if (titles.isEmpty) {
      snackBar("Anime title not found. Cannot search.", severity: InfoBarSeverity.error);
      return;
    }

    showPaddedDialog(
      context,
      navigationItem: DialogNavigationItem(id: 'knaben:episode-search', title: 'Episode Search'),
      builder: (context, item, options) {
        return PaddedDialog.custom(
          navigationItem: item,
          barrierOptions: options,
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 900),
          contentBuilder: (_, __) => KnabenSearchDialog(
            controller: controller,
            seriesTitles: titles,
            season: ep.seasonNumber,
            episode: ep.episodeNumber,
            sonarrEpisodeId: ep.id,
            sonarrSeriesId: _sonarrSeriesId,
          ),
        );
      },
    );
  }

  Widget _buildQualityProfileSelector() {
    if (_isLoadingProfiles) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 16, height: 16, child: RepaintBoundary(child: CircularProgressIndicator(strokeWidth: 2))),
            SizedBox(width: 8),
            Text("Loading quality profiles..."),
          ],
        ),
      );
    }
    if (_qualityProfiles.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text("Quality Profile: ", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          ComboBox<int>(
            value: _selectedQualityProfileId != 0 ? _selectedQualityProfileId : null,
            items: _qualityProfiles.map((p) => ComboBoxItem<int>(value: p.id, child: Text(p.name))).toList(),
            onChanged: (val) {
              if (val != null) _onQualityProfileChanged(val);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!TorrentManager.isEnabled) return const Center(child: Text("Configure Sonarr & qBittorrent in Settings to enable downloads."));

    return Card(
      borderRadius: BorderRadius.circular(8.0),
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_sonarrSeriesId != null && !_isLoading)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: _changeLink,
                    icon: const Icon(Icons.link),
                    label: const Text("Edit Link"),
                  ),
                  TextButton.icon(
                    onPressed: _searchSeasonPack,
                    icon: const Icon(Icons.inventory_2),
                    label: const Text("Search Batches"),
                  ),
                  SizedBox(
                    width: ScreenUtils.kDefaultButtonSize,
                    height: ScreenUtils.kDefaultButtonSize,
                    child: StandardButton.icon(
                      onPressed: _fetchData,
                      icon: const Icon(Icons.refresh),
                    ),
                  ),
                ],
              ),
            ),
          if (!_isLoading) _buildQualityProfileSelector(),
          if (_qualityProfiles.isNotEmpty && !_isLoading) const Divider(),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: RepaintBoundary(child: CircularProgressIndicator()),
                ),
              ),
            )
          else if (_episodesMetadata.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Center(child: Text("No episodes found.")),
            )
          else
            ..._buildSeasonSections(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Find the local Series that corresponds to this Sonarr series.
  /// Tries AniList ID first, then falls back to matching the Sonarr series path.
  Series? _findLocalSeries() {
    final library = Provider.of<Library>(context, listen: false);

    // Primary: match by AniList ID
    final byAnilist = library.getSeriesByAnilistId(widget.animeId);
    if (byAnilist != null) return byAnilist;

    // Fallback: match by Sonarr series filesystem path
    // (e.g. Frieren S3's AniList ID isn't in the library, but S1/S2 are,
    // and they all share the same Sonarr series root folder)
    if (_sonarrSeriesPath != null) {
      final localPath = _sonarrPathToLocal(_sonarrSeriesPath!, library);
      if (localPath != null) {
        return library.getSeriesByPath(PathString(localPath));
      }
    }
    return null;
  }

  /// Converts a Sonarr/Docker path back to a local Windows path using the
  /// known sonarrRoot ↔ libraryPath mapping.
  ///
  /// e.g. "/data/Videos/Series/Frieren/" → "M:\Videos\Series\Frieren\"
  String? _sonarrPathToLocal(String sonarrPath, Library library) {
    final localLibraryPath = library.libraryPath;
    if (localLibraryPath == null) return null;

    final settings = SettingsManager();
    final sonarrRoot = settings.sonarrRootFolderPath.isNotEmpty
        ? settings.sonarrRootFolderPath
        : library.libraryDockerPath;
    if (sonarrRoot == null) return null;

    final normalizedSonarr = sonarrPath.replaceAll('\\', '/');
    final normalizedRoot = sonarrRoot.endsWith('/')
        ? sonarrRoot.substring(0, sonarrRoot.length - 1)
        : sonarrRoot;

    if (normalizedSonarr.toLowerCase().startsWith(normalizedRoot.toLowerCase())) {
      final relativePath = normalizedSonarr.substring(normalizedRoot.length);
      final localBase = localLibraryPath.replaceAll('/', '\\');
      final result = '$localBase${relativePath.replaceAll('/', '\\')}';
      logTrace('[SeriesDownloadView] Sonarr path "$sonarrPath" → local "$result"');
      return result;
    }

    logTrace('[SeriesDownloadView] Could not translate Sonarr path "$sonarrPath" (root=$sonarrRoot, library=$localLibraryPath)');
    return null;
  }

  List<Widget> _buildSeasonSections() {
    // Group episodes by season
    final grouped = groupBy(_episodesMetadata, (SonarrEpisode e) => e.seasonNumber);
    // Sort seasons descending, specials (season 0) last
    final sortedSeasons = grouped.keys.toList()
      ..sort((a, b) {
        if (a == 0) return 1;
        if (b == 0) return -1;
        return b.compareTo(a);
      });

    // Look up the local series once for passing to EpisodeGrid
    final localSeries = _findLocalSeries();

    return [
      for (final season in sortedSeasons) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            season == 0 ? 'Specials' : 'Season $season',
            style: Manager.bodyStrongStyle,
          ),
        ),
        EpisodeGrid(
          collapsable: false,
          episodes: UIEpisode.merge(
            localSeries?.seasons.firstWhereOrNull((s) => s.seasonNumber == season)?.episodes,
            grouped[season]!,
          ),
          series: localSeries,
          mapping: null,
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          onTap: (uiEpisode) {
            // If the episode can be played locally, play it
            if (uiEpisode.canPlay) {
              final lib = Provider.of<Library>(context, listen: false);
              lib.playEpisode(uiEpisode.localEpisode!);
              return;
            }
            // Otherwise open search dialog for released/future episodes
            if (uiEpisode.sonarrEpisode != null) {
              _showKnabenSearchDialog(uiEpisode.sonarrEpisode!);
            }
          },
        ),
      ],
    ];
  }
}

/// Dialog for managing Sonarr episode ↔ file links
/// Fetches fresh data from Sonarr every time it opens, displays Sonarr's own file data,
/// and only tracks user overrides for syncing back
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
  /// Links are derived purely from Sonarr's own hasFile/episodeFileId
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

      // Build map: fileId → SonarrEpisodeFile
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
    for (final season in widget.localSeries!.seasons) {
      for (final ep in season.episodes) {
        _localByPath[ep.path.path] = ep;
      }
    }
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
  void _changeLinkForEpisode(SonarrEpisode sonarrEp) async {
    if (widget.localSeries == null) return;

    if (!mounted) return;
    PathString? selectedPath;

    final result = await showDialog<PathString>(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Text("Select file for S${sonarrEp.seasonNumber.toString().padLeft(2, '0')}"
            "E${sonarrEp.episodeNumber.toString().padLeft(2, '0')}"
            " — ${sonarrEp.title}"),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
        content: FileExplorer(
          rootPath: widget.localSeries!.path,
          allowFiles: true,
          allowCurrentFolder: false,
          onSelectionChanged: (sel) => selectedPath = sel.firstOrNull,
          onFileDoubleTap: (path) => Navigator.of(ctx).pop(path),
        ),
        actions: [
          Row(
            children: [
              Button(child: const Text("Cancel"), onPressed: () => Navigator.of(ctx).pop()),
              const Spacer(),
              FilledButton(
                child: const Text("Select"),
                onPressed: () => Navigator.of(ctx).pop(selectedPath),
              ),
            ],
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      logTrace('[ManageEpisodes] Override: ep ${sonarrEp.id} (S${sonarrEp.seasonNumber}E${sonarrEp.episodeNumber}) → "${result.path}"');
      setState(() {
        _userOverrides[sonarrEp.id] = result.path;
      });
    }
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

    // Ensure Sonarr series path matches the real local folder
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
            severity: failCount > 0 ? InfoBarSeverity.warning : InfoBarSeverity.success);
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
        color: Colors.grey[160]?.withOpacity(0.15),
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

    // Group sonarr episodes by season, sorted by episode number within each
    final grouped = groupBy(_sonarrEpisodes, (SonarrEpisode e) => e.seasonNumber);
    for (final eps in grouped.values) {
      eps.sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
    }
    // Regular seasons descending, then specials (season 0) last
    final seasonNumbers = grouped.keys.where((s) => s > 0).toList()..sort((a, b) => b.compareTo(a));
    seasonNumbers.addAll(grouped.keys.where((s) => s == 0));

    return ContentDialog(
      title: Text("Manage Episodes — ${widget.seriesTitle}"),
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
}
