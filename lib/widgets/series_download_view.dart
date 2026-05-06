import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:provider/provider.dart';

import '../models/sonarr/sonarr_quality_profile.dart';
import '../models/series.dart';
import '../services/navigation/show_info.dart';
import '../services/navigation/dialogs2.dart';
import '../services/downloads/torrent_manager.dart';
import '../services/library/library_provider.dart';
import '../models/anilist/anime.dart';
import '../models/sonarr/sonarr_episode.dart';
import '../models/ui_episode.dart';
import '../utils/logging.dart';
import '../utils/screen.dart';
import '../settings.dart';
import '../manager.dart';
import 'dialogs/knaben_search.dart';
import 'dialogs/show_dialog.dart';
import 'dialogs/sonarr_manual_link_dialog.dart';
import 'buttons/button.dart';
import 'episode_grid.dart';

/// Watch tab for Searched Series with Sonarr integration
class SeriesDownloadView extends StatefulWidget {
  final int animeId;
  final AnilistTitle animeTitle;

  /// When provided, show an "Add to Library" prompt when no local series is found
  final VoidCallback? onAddToLibrary;

  const SeriesDownloadView({
    super.key,
    required this.animeId,
    required this.animeTitle,
    this.onAddToLibrary,
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

    setState(() => _isLoadingProfiles = true);

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
      if (mounted) setState(() => _isLoadingProfiles = false);
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

    if (widget.onAddToLibrary != null && _findLocalSeries() == null) {
      snackBar("Add this series to your library first.", severity: InfoBarSeverity.warning);
      return;
    }

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
      navigationItem: DialogNavigationItem(
        id: 'knaben:season-search',
        title: 'Season Search',
        dialogDoPopCheck: () => Manager.canPopDialog,
      ),
      builder: (context, item, options) {
        return PaddedDialog.custom(
          navigationItem: item,
          barrierOptions: options,
          constraints: const BoxConstraints(maxWidth: 850, maxHeight: 650),
          contentBuilder: (_, __) => KnabenSearchDialog(
            key: knabenSearchDialogKey,
            controller: controller,
            seriesTitles: titles,
            season: season,
            isSeasonSearch: true,
            sonarrSeriesId: _sonarrSeriesId,
            series: _findLocalSeries(),
          ),
        );
      },
    );
  }

  void _showKnabenSearchDialog(SonarrEpisode ep) {
    final controller = TorrentManager.downloadController;
    if (controller == null) return;

    if (widget.onAddToLibrary != null && _findLocalSeries() == null) {
      snackBar("Add this series to your library first.", severity: InfoBarSeverity.warning);
      return;
    }

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
      navigationItem: DialogNavigationItem(
        id: 'knaben:episode-search',
        title: 'Episode Search',
        dialogDoPopCheck: () => Manager.canPopDialog,
      ),
      builder: (context, item, options) {
        return PaddedDialog.custom(
          navigationItem: item,
          barrierOptions: options,
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 900),
          contentBuilder: (_, __) => KnabenSearchDialog(
            key: knabenSearchDialogKey,
            controller: controller,
            seriesTitles: titles,
            season: ep.seasonNumber,
            episode: ep.episodeNumber,
            sonarrEpisodeId: ep.id,
            sonarrSeriesId: _sonarrSeriesId,
            series: _findLocalSeries(),
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
            SizedBox(width: 16, height: 16, child: RepaintBoundary(child: ProgressRing(strokeWidth: 2))),
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

    if (widget.onAddToLibrary != null && _findLocalSeries() == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_off_outlined, size: 48),
            const SizedBox(height: 12),
            const Text('Add this series to your Library to enable downloads.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: widget.onAddToLibrary,
              child: const Text('Add to Library'),
            ),
          ],
        ),
      );
    }

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
                  StandardButton.iconLabel(
                    onPressed: _changeLink,
                    icon: const Icon(Icons.link),
                    label: const Text("Edit Link"),
                  ),
                  StandardButton.iconLabel(
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
                  child: RepaintBoundary(child: ProgressRing(strokeWidth: 2)),
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

  /// Find the local Series that corresponds to this Sonarr series
  ///
  /// Tries AniList ID first, then falls back to matching the Sonarr series path
  Series? _findLocalSeries() {
    final library = Provider.of<Library>(context, listen: false);

    final byAnilist = library.getSeriesByAnilistId(widget.animeId);
    if (byAnilist != null) return byAnilist;

    // Fallback: match by Sonarr series filesystem path
    // (e.g. Frieren S3's AniList ID isn't in the library, but S1/S2 are, and they share the same Sonarr root folder)
    if (_sonarrSeriesPath != null) {
      final localPath = TorrentManager.downloadController?.fromSonarrPath(_sonarrSeriesPath!);
      if (localPath != null) return library.getSeriesByPath(localPath);
    }
    return null;
  }

  List<Widget> _buildSeasonSections() {
    final grouped = groupBy(_episodesMetadata, (SonarrEpisode e) => e.seasonNumber);
    final sortedSeasons = grouped.keys.toList()
      ..sort((a, b) {
        if (a == 0) return 1;
        if (b == 0) return -1;
        return b.compareTo(a);
      });

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
            if (uiEpisode.canPlay) {
              final lib = Provider.of<Library>(context, listen: false);
              lib.playEpisode(uiEpisode.localEpisode!);
              return;
            }
            if (uiEpisode.sonarrEpisode != null) {
              _showKnabenSearchDialog(uiEpisode.sonarrEpisode!);
            }
          },
        ),
      ],
    ];
  }
}
