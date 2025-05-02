import 'package:fluent_ui/fluent_ui.dart';
import '../models/series.dart';
import '../models/anilist/anime.dart';
import '../services/anilist/linking.dart';

class AnilistLinkDialog extends StatefulWidget {
  final Series series;
  final SeriesLinkService linkService;
  final Function(int) onLink;
  
  const AnilistLinkDialog({
    super.key,
    required this.series,
    required this.linkService,
    required this.onLink,
  });

  @override
  State<AnilistLinkDialog> createState() => _AnilistLinkDialogState();
}

class _AnilistLinkDialogState extends State<AnilistLinkDialog> {
  bool _isLoading = true;
  String? _error;
  List<AnilistAnime> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _searchController.text = widget.series.name;
    _searchSeries();
  }
  
  Future<void> _searchSeries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final results = await widget.linkService.findMatchesByName(widget.series);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error searching Anilist: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _search() async {
    if (_searchController.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final results = await widget.linkService.findMatchesByName(
        Series(
          name: _searchController.text,
          path: widget.series.path,
          seasons: widget.series.seasons,
        ),
      );
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error searching Anilist: $e';
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Link to Anilist'),
      content: SizedBox(
        width: 600,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Find the correct anime entry for "${widget.series.name}"'),
            const SizedBox(height: 8),
            
            TextBox(
              controller: _searchController,
              placeholder: 'Search anime title',
              suffix: IconButton(
                icon: const Icon(FluentIcons.search),
                onPressed: _search,
              ),
              onSubmitted: (_) => _search(),
            ),
            
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: ProgressRing())
            else if (_error != null)
              InfoBar(
                title: const Text('Error'),
                content: Text(_error!),
                severity: InfoBarSeverity.error,
              )
            else if (_searchResults.isEmpty)
              const Center(child: Text('No results found'))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final anime = _searchResults[index];
                    return ListTile(
                      leading: anime.bannerImage != null
                          ? Image.network(
                              anime.bannerImage!,
                              width: 60,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) => const Icon(FluentIcons.video),
                            )
                          : const Icon(FluentIcons.video),
                      title: Text(anime.title.english ?? anime.title.romaji ?? 'Unknown'),
                      subtitle: Text(
                        '${anime.format ?? ''} ${anime.seasonYear ?? ''} | ${anime.episodes ?? '?'} eps',
                      ),
                      onPressed: () {
                        widget.onLink(anime.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        Button(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}