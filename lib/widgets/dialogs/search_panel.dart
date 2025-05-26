import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/main.dart';
import 'package:miruryoiki/widgets/series_image.dart';
import 'package:provider/provider.dart';
import '../../models/series.dart';
import '../../models/anilist/anime.dart';
import '../../services/anilist/linking.dart';
import '../../services/anilist/provider.dart';
import '../../services/cache.dart';
import '../../services/navigation/dialogs.dart';
import '../../utils/time_utils.dart';
import 'link_anilist_multi.dart';

class AnilistSearchPanel extends StatefulWidget {
  /// The series to link to Anilist.
  final Series series;

  /// If true, the textbox is enabled, otherwise it is disabled.
  final bool enabled;

  /// The service to use for linking series to Anilist.
  final SeriesLinkService linkService;

  /// The function to call when a series is linked.
  final Function(int, String) onLink;

  /// The constraints for the dialog, used to resize it.
  final BoxConstraints constraints;

  /// The initial search term to use when the dialog is opened.
  final String? initialSearch;

  /// If true, the dialog will not close automatically after linking, it needs to be closed inside `onLink`.
  final bool skipAutoClose;

  const AnilistSearchPanel({
    super.key,
    required this.series,
    required this.linkService,
    required this.onLink,
    required this.constraints,
    this.initialSearch,
    this.skipAutoClose = false,
    this.enabled = true,
  });

  @override
  State<AnilistSearchPanel> createState() => _AnilistSearchPanelState();
}

class _AnilistSearchPanelState extends State<AnilistSearchPanel> {
  bool _isLoading = true;
  String? _error;
  List<AnilistAnime> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();

  AnilistAnime? _selectedSeries;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialSearch ?? widget.series.name;
    _searchSeries();
    nextFrame(() {
      context.resizeManagedDialog(
        width: widget.constraints.maxWidth,
        height: widget.constraints.maxHeight,
      );
    });
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

  Future<void> search() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final anilistProvider = context.read<AnilistProvider>();

      if (await anilistProvider.ensureInitialized()) {
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
      } else
        throw Exception('Anilist user not initialized');
    } catch (e) {
      setState(() {
        _error = 'Error searching Anilist: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextBox(
          controller: _searchController,
          placeholder: 'Search anime title',
          suffix: IconButton(
            icon: const Icon(FluentIcons.search),
            onPressed: search,
          ),
          decoration: WidgetStatePropertyAll(
            BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.transparent),
            ),
          ),
          enabled: widget.enabled,
          onChanged: (_) {
            // TODO add race condition timer to avoid too many requests
            search();
          },
          onSubmitted: (_) => search(),
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
                final series = _searchResults[index];
                final isSelected = _selectedSeries?.id == series.id;

                return SelectableTile(
                  title: Text(series.title.userPreferred ?? series.title.english ?? series.title.romaji ?? 'Unknown'),
                  subtitle: Text('${series.format ?? ''} ${series.seasonYear ?? ''} | ${series.episodes ?? '?'} eps'),
                  icon: series.posterImage != null
                      ? SeriesImageBuilder(
                          imageProviderFuture: ImageCacheService().getImageProvider(series.posterImage!),
                          width: 60,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                      : const Icon(FluentIcons.video),
                  isSelected: isSelected,
                  onTap: () async {
                    await widget.onLink(series.id, series.title.userPreferred ?? series.title.english ?? series.title.romaji ?? 'Unknown');
                    setState(() => _selectedSeries = isSelected ? null : series);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
