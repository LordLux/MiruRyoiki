import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/main.dart';
import 'package:provider/provider.dart';
import '../models/series.dart';
import '../models/anilist/anime.dart';
import '../services/anilist/linking.dart';
import '../services/anilist/provider.dart';
import '../services/navigation/dialogs.dart';

class AnilistLinkDialog extends ManagedDialog {
  final Series series;
  final SeriesLinkService linkService;
  final Function(int, String) onLink;

  AnilistLinkDialog({
    super.key,
    required this.series,
    required this.linkService,
    required this.onLink,
    super.title = const Text('Link Local entry to Anilist entry'),
    super.constraints,
    required super.popContext,
  }) : super(
          contentBuilder: (context, constraints) => AnilistSearchPanel(
            series: series,
            linkService: linkService,
            onLink: onLink,
            constraints: constraints,
            skipAutoClose: true,
          ),
          actions: (_) => [
            ManagedDialogButton(
              popContext: popContext,
              text: 'anilist link'
            )
          ],
        );

  @override
  State<AnilistLinkDialog> createState() => _AnilistLinkDialogState();
}

class _AnilistLinkDialogState extends State<AnilistLinkDialog> {
  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: widget.title,
      content: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: widget.constraints.maxWidth,
        height: widget.constraints.maxHeight,
        child: AnilistSearchPanel(
          series: widget.series,
          linkService: widget.linkService,
          onLink: widget.onLink,
          constraints: widget.constraints,
        ),
      ),
      actions: widget.actions!(widget.popContext), // this context does not matter
    );
  }
}

class AnilistSearchPanel extends StatefulWidget {
  /// The series to link to Anilist.
  final Series series;

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
  });

  @override
  State<AnilistSearchPanel> createState() => _AnilistSearchPanelState();
}

class _AnilistSearchPanelState extends State<AnilistSearchPanel> {
  bool _isLoading = true;
  String? _error;
  List<AnilistAnime> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialSearch ?? widget.series.name;
    _searchSeries();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
                return ListTile(
                  leading: series.bannerImage != null
                      ? Image.network(
                          series.bannerImage!,
                          width: 60,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => const Icon(FluentIcons.video),
                        )
                      : const Icon(FluentIcons.video),
                  title: Text(series.title.english ?? series.title.romaji ?? 'Unknown'),
                  subtitle: Text(
                    '${series.format ?? ''} ${series.seasonYear ?? ''} | ${series.episodes ?? '?'} eps',
                  ),
                  onPressed: () async {
                    await widget.onLink(series.id, series.title.userPreferred ?? series.title.english ?? series.title.romaji ?? 'Unknown');

                    // if the dialog should not close automatically
                    if (!widget.skipAutoClose) {
                      closeDialog(context);
                    }

                    homeKey.currentState?.setState(() {});
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
