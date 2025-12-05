import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart' hide Card, Divider, Tooltip, ListTile, showDialog;
import 'package:miruryoiki/services/navigation/show_info.dart';
import '../models/sonarr/sonarr_release.dart';
import '../services/sonarr/sonarr_service.dart'; // Needed for grab
import '../models/anilist/anime.dart';
import '../services/anilist/linking.dart';
import '../utils/logging.dart';
import '../utils/screen.dart';
import '../utils/units.dart';
import '../widgets/buttons/button.dart';
import '../widgets/dialogs/episode_search.dart';
import '../services/downloads/download_controller.dart';

class DownloadsScreen extends StatefulWidget {
  final DownloadController controller;
  final SonarrRepository sonarrRepo;
  final ScrollController scrollController;

  const DownloadsScreen({
    super.key,
    required this.controller,
    required this.sonarrRepo,
    required this.scrollController,
  });

  @override
  State<DownloadsScreen> createState() => DownloadsScreenState();
}

class DownloadsScreenState extends State<DownloadsScreen> {
  Future<List<SonarrRelease>>? _releasesFuture;
  final TextEditingController _searchController = TextEditingController();
  AnilistAnime? anime;

  List<dynamic> _episodesMetadata = []; // Store raw episode data
  int? _sonarrSeriesId;
  bool _isLoading = false;

  void _fetchMockAnime() async {
    final animeId = int.tryParse(_searchController.text.trim());
    if (animeId == null) {
      snackBar("Please enter a valid AniList Anime ID.", severity: InfoBarSeverity.warning);
      return;
    }

    logTrace("Fetching anime details for AniList ID: $animeId");
    anime = await SeriesLinkService().fetchAnimeDetails(animeId);
    if (anime != null) {
      logDebug("Fetched anime details for Anilist ID: $animeId - ${anime?.title.romaji}");
      _fetchData();
    } else {
      logWarn('Failed to fetch anime details for AniList ID: $animeId');
      snackBar("Failed to fetch anime details for AniList ID: $animeId", severity: InfoBarSeverity.warning);
    }
  }

  void _fetchData() async {
    setState(() => _isLoading = true);
    try {
      logTrace("Syncing and fetching episodes for: ${anime?.title.romaji}");

      // 1. Sync Series & Get Episode List
      final result = await widget.controller.syncAndFetchEpisodes(anime!);

      if (mounted) {
        setState(() {
          _sonarrSeriesId = result.$1;
          _episodesMetadata = result.$2;
          // Sort episodes by season then episode number (descending usually better for new animes)
          _episodesMetadata.sort((a, b) {
            int sComp = (b['seasonNumber'] as int).compareTo(a['seasonNumber'] as int);
            if (sComp != 0) return sComp;
            return (b['episodeNumber'] as int).compareTo(a['episodeNumber'] as int);
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

  // New method to search for Season Packs (Batches)
  void _searchSeasonPack() {
    if (_sonarrSeriesId == null) return;

    // We assume Season 1 for simplicity, or you could add a selector
    showDialog(
      context: context,
      builder: (context) => EpisodeSearchDialog(
          // We pass a flag or special ID to indicate season search,
          // strictly speaking SonarrRepository.searchReleases needs to change slightly to support this cleanly,
          // but for now let's keep it to the Episode Dialog which is what you asked for.
          // This is just to show how you WOULD use the ID.
          isSeasonSearch: true,
          seriesId: _sonarrSeriesId!,
          sonarrRepo: widget.sonarrRepo,),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: anime == null ? const Text("Downloads") : Text("Downloads: ${anime?.title.romaji}"),
        actions: [
          // Show Batch Search button only if we have a valid series ID
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
                onPressed: _fetchData,
                icon: const Icon(Icons.refresh),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
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
                        placeholder: "Enter AniList Anime ID",
                        onSubmitted: (_) => _fetchMockAnime(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StandardButton.iconLabel(
                    onPressed: _fetchMockAnime,
                    label: const Text("Fetch Downloads"),
                    icon: const Icon(Icons.search),
                  )
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : _episodesMetadata.isEmpty 
                ? const Center(child: Text("No episodes found. Try entering an ID and fetching."))
                : ListView.builder(
                    controller: widget.scrollController,
                    itemCount: _episodesMetadata.length,
                    itemBuilder: (context, index) {
                      final ep = _episodesMetadata[index];
                      final title = ep['title'] ?? "Unknown Title";
                      final s = ep['seasonNumber'] ?? 0;
                      final e = ep['episodeNumber'] ?? 0;
                      final hasFile = ep['hasFile'] as bool? ?? false;
                      final episodeId = ep['id'];

                      return ListTile(
                        leading: const Icon(Icons.movie),
                        title: Text("S${s.toString().padLeft(2, '0')}E${e.toString().padLeft(2, '0')} - $title"),
                        trailing: hasFile
                            ? const Tooltip(
                                message: "File exists in library",
                                child: Icon(Icons.check_circle, color: Colors.green),
                              )
                            : StandardButton.icon(
                                icon: const Icon(Icons.download_for_offline),
                                onPressed: () => _showSearchDialog(episodeId),
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
    showDialog(
      context: context,
      builder: (context) => EpisodeSearchDialog(
        episodeId: episodeId, 
        sonarrRepo: widget.sonarrRepo
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
                    icon: _isGrabbing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.download),
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
