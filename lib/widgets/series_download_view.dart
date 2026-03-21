import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart' hide Card, Divider, Tooltip, ListTile, IconButton, showDialog;
import '../manager.dart';
import '../models/ui_episode.dart';
import 'episode_grid.dart';
import 'package:miruryoiki/services/navigation/show_info.dart';
import '../models/anilist/anime.dart';
import '../models/sonarr/sonarr_episode.dart';
import '../models/sonarr/sonarr_quality_profile.dart';
import '../settings.dart';
import '../utils/logging.dart';
import '../utils/screen.dart';
import 'buttons/button.dart';
import 'dialogs/knaben_search.dart';
import 'dialogs/sonarr_manual_link_dialog.dart';
import '../services/downloads/torrent_manager.dart';

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
      setState(() {
        _sonarrSeriesId = id;
        _sonarrSeriesTitle = widget.animeTitle.romaji ?? "Unknown";
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
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => SonarrManualLinkDialog(
              animeId: widget.animeId,
              animeTitle: widget.animeTitle,
            ),
          );
          if (result == true) {
            // Re-fetch after user maps
            _fetchData();
          }
        } else {
          snackBar("Failed to fetch Sonarr episodes: $e", severity: InfoBarSeverity.error);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changeLink() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => SonarrManualLinkDialog(
        animeId: widget.animeId,
        animeTitle: widget.animeTitle,
      ),
    );
    if (result == true) _fetchData();
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

    showDialog(
      context: context,
      builder: (context) => KnabenSearchDialog(
        controller: controller,
        seriesTitles: titles,
        season: season,
        isSeasonSearch: true,
      ),
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

    showDialog(
      context: context,
      builder: (context) => KnabenSearchDialog(
        controller: controller,
        seriesTitles: titles,
        season: ep.seasonNumber,
        episode: ep.episodeNumber,
      ),
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

  List<Widget> _buildSeasonSections() {
    // Group episodes by season
    final grouped = groupBy(_episodesMetadata, (SonarrEpisode e) => e.seasonNumber);
    // Sort seasons ascending
    final sortedSeasons = grouped.keys.toList()..sort();

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
          episodes: UIEpisode.merge(null, grouped[season]!),
          series: null,
          mapping: null,
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          onTap: (uiEpisode) {
            if (uiEpisode.state == EpisodeState.released || uiEpisode.state == EpisodeState.future) {
              if (uiEpisode.sonarrEpisode != null) {
                _showKnabenSearchDialog(uiEpisode.sonarrEpisode!);
              }
            }
          },
        ),
      ],
    ];
  }
}
