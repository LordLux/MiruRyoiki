import 'package:defer_pointer/defer_pointer.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import '../main.dart';
import '../manager.dart';
import '../services/anilist/queries/anilist_service.dart';
import '../models/anilist/anime.dart';
import '../models/anilist/page_info.dart';
import '../services/navigation/shortcuts.dart';
import '../utils/logging.dart';
import '../utils/screen.dart';
import '../widgets/cards/search_series_card.dart';
import '../widgets/context_menu/context_menu.dart';
import '../widgets/page/page_template.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/buttons/button.dart';

class SearchResultsScreen extends StatefulWidget {
  final String queryType; // 'trending', 'popular', 'upcoming', 'top100', 'search'
  final String title;
  final String? searchQuery;
  final Map<String, dynamic>? filters;
  final VoidCallback onBack;
  final void Function(AnilistAnime anime) onSeriesOpen;

  const SearchResultsScreen({
    super.key,
    required this.queryType,
    required this.title,
    this.searchQuery,
    this.filters,
    required this.onBack,
    required this.onSeriesOpen,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final List<AnilistAnime> _animeList = [];
  bool _isLoading = false;
  bool _hasNextPage = true;
  int _currentPage = 1;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();
  late final DesktopContextMenuController _menuController;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _scrollController.addListener(_onScroll);
    _menuController = DesktopContextMenuController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _menuController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoading && _hasNextPage) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = AnilistService();

      AnilistSearchPage<AnilistAnime>? result = await switch (widget.queryType) {
        'trending' => service.getTrendingNow(page: _currentPage, perPage: 20),
        'popular' => service.getPopularThisSeason(page: _currentPage, perPage: 20),
        'upcoming' => service.getUpcomingNextSeason(page: _currentPage, perPage: 20),
        'top100' => service.getTop100Anime(page: _currentPage, perPage: 20),
        'search' => service.searchAnime(
            page: _currentPage,
            perPage: 20,
            search: widget.searchQuery,
            genres: widget.filters?['genres'],
            seasonYear: widget.filters?['year'],
            season: widget.filters?['season'],
            format: widget.filters?['format'],
            countryOfOrigin: widget.filters?['countryOfOrigin'],
            durationGreater: widget.filters?['durationGreater'],
            durationLesser: widget.filters?['durationLesser'],
            episodeGreater: widget.filters?['episodeGreater'],
            episodeLesser: widget.filters?['episodeLesser'],
            excludedGenres: widget.filters?['excludedGenres'],
            excludedTags: widget.filters?['excludedTags'],
            isAdult: widget.filters?['isAdult'],
            isLicensed: widget.filters?['isLicensed'],
            sort: widget.filters?['sort'] ?? const ['POPULARITY_DESC'],
            licensedBy: widget.filters?['licensedBy'],
            minimumTagRank: widget.filters?['minimumTagRank'],
            onList: widget.filters?['onList'],
            source: widget.filters?['source'],
            status: widget.filters?['status'],
            tags: widget.filters?['tags'],
            yearGreater: widget.filters?['yearGreater'],
            yearLesser: widget.filters?['yearLesser'],
          ),
        _ => null,
      };

      if (result == null) {
        final bool isValidQuery = ['trending', 'popular', 'upcoming', 'top100', 'search'].contains(widget.queryType);

        if (mounted) {
          setState(() {
            _isLoading = false;
            if (isValidQuery) {
              _errorMessage = 'Failed to load data. Please check your connection.';
            } else {
              _errorMessage = 'Invalid query type: ${widget.queryType}';
            }
          });
        }
        return;
      }

      final pageInfo = result.pageInfo;
      final media = result.results;

      if (mounted) {
        setState(() {
          _animeList.addAll(media);
          _hasNextPage = pageInfo.hasNextPage;
          _currentPage++;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An error occurred: $e';
        });
      }
      logErr('Error fetching search results', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MiruRyoikiTemplatePage(
      hideInfoBar: true,
      headerWidget: HeaderWidget(
        title: (style, constraints) => Row(
          children: [
            StandardButton.icon(
              icon: const Icon(mat.Icons.arrow_back),
              onPressed: widget.onBack,
            ),
            const SizedBox(width: 16),
            Text(widget.title, style: style),
          ],
        ),
      ),
      scrollableContent: false,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null && _animeList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: mat.Colors.red)),
            const SizedBox(height: 16),
            Button(
              onPressed: _fetchData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_animeList.isEmpty && _isLoading) return const Center(child: ProgressRing());

    if (_animeList.isEmpty) return const Center(child: Text('No results found.'));

    return LayoutBuilder(builder: (context, constraints) {
      return DynMouseScroll(
        controller: _scrollController,
        stopScroll: KeyboardState.ctrlPressedNotifier,
        scrollSpeed: 1.0,
        enableSmoothScroll: Manager.animationsEnabled,
        durationMS: 350,
        animationCurve: Curves.easeOutQuint,
        builder: (context, controller, physics) {
          return ValueListenableBuilder(
            valueListenable: KeyboardState.ctrlPressedNotifier,
            builder: (context, isCtrlPressed, _) {
              return ValueListenableBuilder(
                valueListenable: previousGridColumnCount,
                builder: (context, columns, __) {
                  return GridView.builder(
                    controller: controller,
                    physics: physics,
                    padding: const EdgeInsets.only(bottom: 8),
                    addAutomaticKeepAlives: true,
                    addRepaintBoundaries: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns ?? ScreenUtils.crossAxisCount(constraints.maxWidth),
                      childAspectRatio: ScreenUtils.kDefaultAspectRatio,
                      crossAxisSpacing: ScreenUtils.cardPadding,
                      mainAxisSpacing: ScreenUtils.cardPadding,
                    ),
                    itemCount: _animeList.length + (_hasNextPage ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _animeList.length) {
                        // Loading indicator or error message
                        if (_errorMessage != null) {
                          return Center(
                            child: Button(
                              onPressed: _fetchData,
                              child: const Text('Retry'),
                            ),
                          );
                        }
                        return const Center(child: ProgressRing());
                      }
                  
                      final anime = _animeList[index];
                      return AspectRatio(
                        aspectRatio: ScreenUtils.kDefaultAspectRatio,
                        child: SearchSeriesCard(
                          series: anime,
                          number: null, // not showing top100 number
                          onTap: () => widget.onSeriesOpen(anime),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
    });
  }
}
