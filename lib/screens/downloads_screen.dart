import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart' hide Card, Divider, Tooltip, ListTile, IconButton, showDialog;
import 'package:miruryoiki/services/navigation/show_info.dart';
import '../models/sonarr/sonarr_episode.dart';
import '../models/sonarr/sonarr_quality_profile.dart';
import '../models/sonarr/sonarr_release.dart';
import '../models/sonarr/sonarr_series.dart';
import '../services/sonarr/sonarr_service.dart';
import '../models/anilist/anime.dart';
import '../services/anilist/linking.dart';
import '../services/downloads/download_controller.dart';
import '../services/navigation/navigation.dart';
import '../settings.dart';
import '../manager.dart';
import '../utils/logging.dart';
import '../utils/screen.dart';
import '../utils/units.dart';
import '../widgets/buttons/button.dart';
import '../widgets/dialogs/episode_search.dart';

class DownloadsScreen extends StatefulWidget {
  final DownloadController? controller;
  final SonarrRepository? sonarrRepo;
  final ScrollController scrollController;

  const DownloadsScreen({
    super.key,
    this.controller,
    this.sonarrRepo,
    required this.scrollController,
  });

  @override
  State<DownloadsScreen> createState() => DownloadsScreenState();
}

class DownloadsScreenState extends State<DownloadsScreen> {
  final TextEditingController _searchController = TextEditingController();
  AnilistAnime? anime;

  // Phase 1: Sonarr series list + AniList search results
  List<SonarrSeries> _sonarrSeriesList = [];
  List<SonarrSeries> _filteredSeriesList = [];
  bool _isLoadingSeriesList = false;
  List<AnilistAnime> _anilistSearchResults = [];
  bool _isSearchingAnilist = false;
  String _seriesFilterQuery = '';

  // Phase 2: Episode list for selected anime
  List<SonarrEpisode> _episodesMetadata = [];
  int? _sonarrSeriesId;
  bool _isLoading = false;

  // Quality profiles
  List<SonarrQualityProfile> _qualityProfiles = [];
  int? _selectedQualityProfileId;
  bool _isLoadingProfiles = false;

  @override
  void activate() {
    super.activate();
    // Reregister and restore on GlobalKey reparent
    NavigationManager.registerActiveScrollController('torrent', widget.scrollController);
    NavigationManager.restoreScrollOffset('torrent', widget.scrollController);
  }

  @override
  void initState() {
    super.initState();
    NavigationManager.registerActiveScrollController('torrent', widget.scrollController);
    NavigationManager.restoreScrollOffset('torrent', widget.scrollController);
    _selectedQualityProfileId = SettingsManager().sonarrQualityProfileId;
    if (_selectedQualityProfileId == 0) _selectedQualityProfileId = null;
    if (widget.sonarrRepo != null) {
      _loadSeriesList();
      _loadQualityProfiles();
    }
  }

  /// Public entry point — called from the Series screen via global key.
  void loadAnime(AnilistAnime target) {
    setState(() => anime = target);
    _fetchData();
  }

  // Quality Profiles

  /// Load quality profiles from Sonarr and cache them
  /// If a profile is already selected in settings, it will be pre-selected in the dropdown
  void _loadQualityProfiles() async {
    if (widget.sonarrRepo == null) return;
    setState(() => _isLoadingProfiles = true);
    try {
      final profiles = await widget.sonarrRepo!.getQualityProfiles();
      if (mounted) {
        setState(() {
          _qualityProfiles = profiles;
          _isLoadingProfiles = false;
          // If no profile selected yet but profiles exist, auto-select the first
          if (_selectedQualityProfileId == null && profiles.isNotEmpty) {
            _selectedQualityProfileId = profiles.first.id;
            SettingsManager().sonarrQualityProfileId = profiles.first.id;
          }
        });
      }
    } catch (e) {
      logErr("Failed to load quality profiles: $e");
      if (mounted) setState(() => _isLoadingProfiles = false);
    }
  }

  /// Called when user selects a quality profile from the dropdown
  /// Updates local state and saves selection to settings
  void _onQualityProfileChanged(int? profileId) {
    if (profileId == null) return;
    setState(() => _selectedQualityProfileId = profileId);
    SettingsManager().sonarrQualityProfileId = profileId;
  }

  void _loadSeriesList() async {
    if (widget.sonarrRepo == null) return;
    setState(() => _isLoadingSeriesList = true);
    try {
      final list = await widget.sonarrRepo!.getSeries();
      list.sort((a, b) => a.title.compareTo(b.title));
      if (mounted) setState(() {
        _sonarrSeriesList = list;
        _applySeriesFilter();
        _isLoadingSeriesList = false;
      });
    } catch (e) {
      logErr("Failed to load Sonarr series: $e");
      if (mounted) {
        snackBar("Failed to load Sonarr series: $e", severity: InfoBarSeverity.error);
        setState(() => _isLoadingSeriesList = false);
      }
    }
  }

  void _applySeriesFilter() {
    if (_seriesFilterQuery.isEmpty) {
      _filteredSeriesList = List.of(_sonarrSeriesList);
    } else {
      final q = _seriesFilterQuery.toLowerCase();
      _filteredSeriesList = _sonarrSeriesList
          .where((s) => s.title.toLowerCase().contains(q))
          .toList();
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _seriesFilterQuery = query;
      _applySeriesFilter();
    });

    // Also trigger AniList search if query is long enough
    if (query.trim().length >= 3) {
      _searchAnilist(query.trim());
    } else {
      setState(() {
        _anilistSearchResults = [];
        _isSearchingAnilist = false;
      });
    }
  }

  void _searchAnilist(String query) async {
    setState(() => _isSearchingAnilist = true);
    try {
      // First try as an AniList ID
      final asId = int.tryParse(query);
      if (asId != null) {
        final fetched = await SeriesLinkService().fetchAnimeDetails(asId);
        if (fetched != null && mounted) {
          setState(() {
            _anilistSearchResults = [fetched];
            _isSearchingAnilist = false;
          });
          return;
        }
      }

      // Otherwise search by name
      final results = await SeriesLinkService().searchByQuery(query);
      if (mounted) {
        setState(() {
          _anilistSearchResults = results;
          _isSearchingAnilist = false;
        });
      }
    } catch (e) {
      logErr("AniList search failed: $e");
      if (mounted) setState(() => _isSearchingAnilist = false);
    }
  }

  /// Called when user taps a series in the Phase-1 list.
  void _selectSonarrSeries(SonarrSeries series) async {
    setState(() { _isLoading = true; _sonarrSeriesId = series.id; });
    try {
      final episodes = await widget.sonarrRepo!.getEpisodes(series.id);
      episodes.sort((a, b) {
        int sComp = b.seasonNumber.compareTo(a.seasonNumber);
        if (sComp != 0) return sComp;
        return b.episodeNumber.compareTo(a.episodeNumber);
      });
      if (mounted) {
        setState(() {
          anime = null;
          _episodesMetadata = episodes;
          _isLoading = false;
        });
      }
    } catch (e) {
      logErr("Error fetching episodes: $e");
      if (mounted) {
        snackBar("Error: $e", severity: InfoBarSeverity.error);
        setState(() => _isLoading = false);
      }
    }
  }

  /// Called when user taps an AniList search result to add it via Sonarr
  void _selectAnilistResult(AnilistAnime result) {
    loadAnime(result);
  }

  // ---------------------------------------------------------------------------
  // Phase 2: Episode list (from AniList flow)
  // ---------------------------------------------------------------------------

  void _fetchData() async {
    if (widget.controller == null) {
      snackBar("Sonarr is not configured. Go to Settings > Sonarr.", severity: InfoBarSeverity.warning);
      return;
    }
    setState(() => _isLoading = true);
    try {
      logTrace("Syncing and fetching episodes for: ${anime?.title.romaji}");
      final result = await widget.controller!.syncAndFetchEpisodes(anime!);

      if (mounted) {
        setState(() {
          _sonarrSeriesId = result.$1;
          _episodesMetadata = result.$2;
          _episodesMetadata.sort((a, b) {
            int sComp = b.seasonNumber.compareTo(a.seasonNumber);
            if (sComp != 0) return sComp;
            return b.episodeNumber.compareTo(a.episodeNumber);
          });
          _isLoading = false;
        });
      }
    } catch (e) {
      logErr("Error fetching downloads: $e");
      if (mounted) {
        snackBar("Error: $e", severity: InfoBarSeverity.error);
        setState(() => _isLoading = false);
      }
    }
  }

  void _goBackToSeriesList() {
    setState(() {
      anime = null;
      _episodesMetadata = [];
      _sonarrSeriesId = null;
      _searchController.clear();
      _seriesFilterQuery = '';
      _anilistSearchResults = [];
    });
    _loadSeriesList();
  }

  void _searchSeasonPack() {
    if (_sonarrSeriesId == null || widget.sonarrRepo == null) return;
    showDialog(
      context: context,
      builder: (context) => EpisodeSearchDialog(
        isSeasonSearch: true,
        seriesId: _sonarrSeriesId!,
        sonarrRepo: widget.sonarrRepo!,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Guard: Sonarr not configured
    if (widget.sonarrRepo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Downloads")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.settings_ethernet, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("Sonarr is not configured.", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              const Text("Set your Sonarr URL and API key in Settings."),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Manager.navigation.pushPaneIndex(NavigationManager.SettingsIndex),
                icon: const Icon(Icons.settings),
                label: const Text("Go to Settings"),
              ),
            ],
          ),
        ),
      );
    }

    // Phase 2: Episode list is loaded (either from Sonarr series tap or AniList flow)
    if (_episodesMetadata.isNotEmpty || _isLoading) {
      return _buildEpisodeView();
    }

    // Phase 1: Show Sonarr series list
    return _buildSeriesListView();
  }

  Widget _buildSeriesListView() {
    final hasAnilistResults = _anilistSearchResults.isNotEmpty;
    final showAnilistSection = hasAnilistResults || _isSearchingAnilist;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Downloads"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SizedBox(
              width: ScreenUtils.kDefaultButtonSize,
              height: ScreenUtils.kDefaultButtonSize,
              child: StandardButton.icon(
                onPressed: _loadSeriesList,
                icon: const Icon(Icons.refresh),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Unified search bar: filters Sonarr list + searches AniList
          SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: TextBox(
                        controller: _searchController,
                        placeholder: "Search library or AniList anime...",
                        onChanged: _onSearchChanged,
                        suffix: _searchController.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 6.0),
                                  child: Icon(Icons.close, size: 16),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          // Content
          Expanded(
            child: _isLoadingSeriesList
                ? const Center(child: RepaintBoundary(child: CircularProgressIndicator()))
                : _buildSeriesListContent(showAnilistSection),
          ),
        ],
      ),
    );
  }

  Widget _buildSeriesListContent(bool showAnilistSection) {
    return ListView(
      controller: widget.scrollController,
      children: [
        // AniList search results section
        if (showAnilistSection) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Row(
              children: [
                const Icon(Icons.add_circle_outline, size: 18),
                const SizedBox(width: 6),
                Text("Add from AniList", style: Theme.of(context).textTheme.titleSmall),
                if (_isSearchingAnilist) ...[
                  const SizedBox(width: 8),
                  const SizedBox(width: 14, height: 14, child: RepaintBoundary(child: CircularProgressIndicator(strokeWidth: 2))),
                ],
              ],
            ),
          ),
          ..._anilistSearchResults.map((anime) {
            return ListTile(
              leading: const Icon(Icons.movie_filter, color: Colors.deepPurple),
              title: Text(anime.title.romaji ?? anime.title.english ?? 'Unknown'),
              subtitle: Text(
                [
                  if (anime.format != null) anime.format,
                  if (anime.episodes != null) '${anime.episodes} eps',
                  if (anime.seasonYear != null) '${anime.seasonYear}',
                  if (anime.status != null) anime.status,
                ].join(' • '),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onPressed: () => _selectAnilistResult(anime),
            );
          }),
          const Divider(),
        ],
        // Sonarr library section header
        if (_sonarrSeriesList.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Row(
              children: [
                const Icon(Icons.video_library, size: 18),
                const SizedBox(width: 6),
                Text("Sonarr Library", style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(width: 6),
                Text("(${_filteredSeriesList.length})", style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        if (_filteredSeriesList.isEmpty && _sonarrSeriesList.isNotEmpty && _seriesFilterQuery.isNotEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text("No matching series in Sonarr library.")),
          )
        else if (_sonarrSeriesList.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text("No series in Sonarr.\nSearch for an anime above to add one.")),
          )
        else
          ..._filteredSeriesList.map((s) {
            final progress = s.episodeCount > 0
                ? s.episodeFileCount / s.episodeCount
                : 0.0;
            return ListTile(
              leading: Icon(
                s.isComplete ? Icons.check_circle : Icons.tv,
                color: s.isComplete ? Colors.green : null,
              ),
              title: Text(s.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 3,
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(
                              s.isComplete ? Colors.green : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${s.episodeFileCount}/${s.episodeCount}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${s.status}${s.monitored ? '' : '  •  unmonitored'}",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              onPressed: () => _selectSonarrSeries(s),
            );
          }),
      ],
    );
  }

  Widget _buildQualityProfileSelector() {
    if (_qualityProfiles.isEmpty && !_isLoadingProfiles) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Row(
        children: [
          const Icon(Icons.high_quality, size: 18),
          const SizedBox(width: 8),
          Text("Quality Profile:", style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: 8),
          if (_isLoadingProfiles)
            const SizedBox(width: 16, height: 16, child: RepaintBoundary(child: CircularProgressIndicator(strokeWidth: 2)))
          else
            Expanded(
              child: ComboBox<int>(
                value: _selectedQualityProfileId,
                placeholder: const Text('Select a profile'),
                items: _qualityProfiles
                    .map((p) => ComboBoxItem<int>(value: p.id, child: Text(p.name)))
                    .toList(),
                onChanged: _onQualityProfileChanged,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEpisodeView() {
    final title = anime != null
        ? "Downloads: ${anime!.title.romaji}"
        : "Episodes";
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBackToSeriesList,
        ),
        title: Text(title),
        actions: [
          if (_sonarrSeriesId != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: _searchSeasonPack,
                icon: const Icon(Icons.inventory_2),
                label: const Text("Search Batches"),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SizedBox(
              width: ScreenUtils.kDefaultButtonSize,
              height: ScreenUtils.kDefaultButtonSize,
              child: StandardButton.icon(
                onPressed: anime != null ? _fetchData : null,
                icon: const Icon(Icons.refresh),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: RepaintBoundary(child: CircularProgressIndicator()))
          : _episodesMetadata.isEmpty
              ? const Center(child: Text("No episodes found."))
              : Column(
                  children: [
                    // Quality profile selector
                    _buildQualityProfileSelector(),
                    if (_qualityProfiles.isNotEmpty) const Divider(),
                    // Episode list
                    Expanded(
                      child: ListView.builder(
                        controller: widget.scrollController,
                        itemCount: _episodesMetadata.length,
                        itemBuilder: (context, index) {
                          final ep = _episodesMetadata[index];
                          return ListTile(
                            leading: const Icon(Icons.movie),
                            title: Text("S${ep.seasonNumber.toString().padLeft(2, '0')}E${ep.episodeNumber.toString().padLeft(2, '0')} - ${ep.title}"),
                            trailing: ep.hasFile
                                ? const Tooltip(
                                    message: "File exists in library",
                                    child: Icon(Icons.check_circle, color: Colors.green),
                                  )
                                : StandardButton.icon(
                                    icon: const Icon(Icons.download_for_offline),
                                    onPressed: () => _showSearchDialog(ep.id),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  void _showSearchDialog(int episodeId) {
    if (widget.sonarrRepo == null) return;
    showDialog(
      context: context,
      builder: (context) => EpisodeSearchDialog(
        episodeId: episodeId,
        sonarrRepo: widget.sonarrRepo!,
      ),
    );
  }
}

class ReleaseTile extends StatefulWidget {
  final SonarrRelease release;
  final SonarrRepository sonarrRepo;

  const ReleaseTile({super.key, required this.release, required this.sonarrRepo});

  @override
  State<ReleaseTile> createState() => _ReleaseTileState();
}

class _ReleaseTileState extends State<ReleaseTile> {
  bool _isGrabbing = false;

  Future<void> _handleGrab() async {
    setState(() => _isGrabbing = true);
    try {
      await widget.sonarrRepo.grabRelease(widget.release.guid, widget.release.indexerId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sent to download client: ${widget.release.title}")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to grab: $e"),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isGrabbing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.release;
    // Dim the tile if Sonarr rejected it (e.g. wrong quality profile)
    final opacity = r.rejected ? 0.5 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(r.title, style: Theme.of(context).textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              // Metadata Row
              Row(
                children: [
                  // Quality Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(r.quality, style: Theme.of(context).textTheme.bodySmall),
                  ),
                  const SizedBox(width: 8),
                  // Size
                  Text(fileSize(r.size), style: Theme.of(context).textTheme.bodySmall),
                  const Spacer(),
                  // Seeds/Peers
                  Icon(Icons.arrow_upward, size: 14, color: Colors.green[700]),
                  Text("${r.seeders}", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green[700])),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_downward, size: 14, color: Colors.red[700]),
                  Text("${r.leechers}", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red[700])),
                ],
              ),
              const Divider(),
              // Action Row
              Row(
                children: [
                  Expanded(
                    child: Text(r.indexer, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                  ),
                  if (r.rejected && r.rejections.isNotEmpty)
                    Tooltip(
                      message: r.rejections.join('\n'),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                      ),
                    ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        // Visual warning if trying to download a rejected release
                        backgroundColor: r.rejected ? Colors.orange.shade100 : null),
                    onPressed: _isGrabbing ? null : _handleGrab,
                    icon: _isGrabbing ? const SizedBox(width: 16, height: 16, child: RepaintBoundary(child: CircularProgressIndicator(strokeWidth: 2))) : const Icon(Icons.download),
                    label: Text(_isGrabbing ? "Sending..." : "Download"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
