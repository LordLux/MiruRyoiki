import 'package:fluent_ui/fluent_ui.dart';
import '../../models/anilist/anime.dart';
import '../../models/sonarr/sonarr_series.dart';
import '../../services/downloads/torrent_manager.dart';

class SonarrManualLinkDialog extends StatefulWidget {
  final int animeId;
  final AnilistTitle animeTitle;

  const SonarrManualLinkDialog({
    super.key,
    required this.animeId,
    required this.animeTitle,
  });

  @override
  State<SonarrManualLinkDialog> createState() => _SonarrManualLinkDialogState();
}

class _SonarrManualLinkDialogState extends State<SonarrManualLinkDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<SonarrSeries> _results = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.animeTitle.romaji ?? widget.animeTitle.english ?? '';
    _performSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final controller = TorrentManager.downloadController;
      if (controller != null) {
        final res = await controller.sonarr.lookupSeries(query);
        if (mounted) {
          setState(() {
            _results = res.take(3).toList();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        // Just ignore or show small info
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _linkSeries(SonarrSeries series) async {
    final controller = TorrentManager.downloadController;
    if (controller != null) {
      await controller.customMappings.saveCustomTvdbId(widget.animeId, series.tvdbId);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("Link to Sonarr Series"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("We couldn't automatically find a match for this anime. You can search manually below:"),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextBox(
                  controller: _searchController,
                  placeholder: "Search Sonarr...",
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
              const SizedBox(width: 8),
              Button(
                onPressed: _isSearching ? null : _performSearch,
                child: const Text("Search"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isSearching)
            const Center(child: ProgressRing())
          else if (_results.isEmpty)
            const Text("No results found.")
          else ...[
            const Text("Top Results:"),
            const SizedBox(height: 8),
            ..._results.map((series) => Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(series.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("TVDB: ${series.tvdbId}"),
                      ],
                    ),
                  ),
                  Button(
                    onPressed: () => _linkSeries(series),
                    child: const Text("Link"),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
      actions: [
        Button(
          child: const Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}
