import 'dart:math' show min;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors, IconButton;
import 'package:flutter/material.dart' hide TextBox, Slider, BackButton;
import 'package:glossy/glossy.dart';
import 'package:miruryoiki/utils/text.dart';
import 'package:miruryoiki/widgets/frosted_noise.dart';
import 'package:provider/provider.dart';
import 'package:marquee/marquee.dart';

import '../services/anilist/queries/anilist_service.dart';
import '../models/anilist/anime.dart';
import '../models/anilist/page_info.dart';
import '../services/library/library_provider.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../services/navigation/navigation.dart';
import '../settings.dart';
import '../manager.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import '../widgets/buttons/back_button.dart';
import '../widgets/buttons/button.dart';
import '../widgets/cards/sarch_series_card.dart';
import '../widgets/fading_edge_scrollview.dart';
import '../widgets/page/search_template.dart';

final GlobalKey<_BrowseScreenState> browseScreenKey = GlobalKey<_BrowseScreenState>();

class BrowseScreen extends StatefulWidget {
  final ScrollController scrollController;

  const BrowseScreen({super.key, required this.scrollController});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  @override
  Widget build(BuildContext context) {
    return SearchScreen(
      scrollController: widget.scrollController,
    );
  }
}

class SearchScreen extends StatefulWidget {
  final ScrollController scrollController;

  const SearchScreen({
    super.key,
    required this.scrollController,
  });

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  FocusNode? _searchFocusNode;
  final TextStyle _searchTextStyle = Manager.smallSubtitleStyle.copyWith(fontWeight: FontWeight.w400);

  DeferredPointerHandlerLink? deferredPointerLink;

  bool _isSearchFocused = false;
  double _textSearchWidth = 0.0;

  // Data Futures
  late Future<AnilistSearchPage<AnilistAnime>?> _trendingFuture;
  late Future<AnilistSearchPage<AnilistAnime>?> _popularFuture;
  late Future<AnilistSearchPage<AnilistAnime>?> _upcomingFuture;
  late Future<AnilistSearchPage<AnilistAnime>?> _top100Future;
  Future<List<String>>? _imagesFuture;

  // Results State
  bool _isShowingResults = false;
  String _resultsQueryType = '';
  String _resultsTitle = '';
  String? _resultsQuery;
  Map<String, dynamic>? _resultsFilters;

  final List<AnilistAnime> _resultsList = [];
  bool _resultsIsLoading = false;
  bool _resultsHasNextPage = true;
  bool _showFilters = false;
  int _resultsCurrentPage = 1;
  String? _resultsErrorMessage;
  double _filterButtonSize = 40;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
    widget.scrollController.addListener(_onScroll);
    _fetchData();
  }

  /// Initial data fetch for dashboard sections.
  void _fetchData() {
    final service = AnilistService();
    _trendingFuture = service.getTrendingNow();
    _popularFuture = service.getPopularThisSeason();
    _upcomingFuture = service.getUpcomingNextSeason();
    _top100Future = service.getTop100Anime();

    _imagesFuture = _aggregateImages();
  }

  /// Handles infinite scrolling for search results.
  void _onScroll() {
    if (_isShowingResults && //
        widget.scrollController.hasClients &&
        widget.scrollController.position.pixels >= widget.scrollController.position.maxScrollExtent - 200 &&
        !_resultsIsLoading &&
        _resultsHasNextPage) {
      _fetchResults();
    }
  }

  /// Fetches search results based on the current query type, page, and filters.
  Future<void> _fetchResults() async {
    if (_resultsIsLoading) return;
    setState(() {
      _resultsIsLoading = true;
      _resultsErrorMessage = null;
    });

    try {
      final service = AnilistService();
      final perPage = 20;

      AnilistSearchPage<AnilistAnime>? result = await switch (_resultsQueryType) {
        'trending' => service.getTrendingNow(page: _resultsCurrentPage, perPage: perPage),
        'popular' => service.getPopularThisSeason(page: _resultsCurrentPage, perPage: perPage),
        'upcoming' => service.getUpcomingNextSeason(page: _resultsCurrentPage, perPage: perPage),
        'top100' => service.getTop100Anime(page: _resultsCurrentPage, perPage: perPage),
        'search' => service.searchAnime(
            page: _resultsCurrentPage,
            perPage: perPage,
            search: _resultsQuery,
            genres: _resultsFilters?['genres'],
            seasonYear: _resultsFilters?['year'],
            season: _resultsFilters?['season'],
            format: _resultsFilters?['format'],
            countryOfOrigin: _resultsFilters?['countryOfOrigin'],
            durationGreater: _resultsFilters?['durationGreater'],
            durationLesser: _resultsFilters?['durationLesser'],
            episodeGreater: _resultsFilters?['episodeGreater'],
            episodeLesser: _resultsFilters?['episodeLesser'],
            excludedGenres: _resultsFilters?['excludedGenres'],
            excludedTags: _resultsFilters?['excludedTags'],
            isAdult: _resultsFilters?['isAdult'],
            isLicensed: _resultsFilters?['isLicensed'],
            sort: _resultsFilters?['sort'] ?? const ['POPULARITY_DESC'],
            licensedBy: _resultsFilters?['licensedBy'],
            minimumTagRank: _resultsFilters?['minimumTagRank'],
            onList: _resultsFilters?['onList'],
            source: _resultsFilters?['source'],
            status: _resultsFilters?['status'],
            tags: _resultsFilters?['tags'],
            yearGreater: _resultsFilters?['yearGreater'],
            yearLesser: _resultsFilters?['yearLesser'],
          ),
        _ => null,
      };

      if (result == null) {
        if (mounted) {
          setState(() {
            _resultsIsLoading = false;
            _resultsErrorMessage = 'Failed to load data.';
          });
        }
        return;
      }

      final pageInfo = result.pageInfo;
      final media = result.results;

      if (mounted) {
        setState(() {
          _resultsList.addAll(media);
          _resultsHasNextPage = pageInfo.hasNextPage;
          _resultsCurrentPage++;
          _resultsIsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _resultsIsLoading = false;
          _resultsErrorMessage = 'An error occurred: $e';
        });
      }
    }
  }

  void _showSearchResults({
    required String queryType,
    required String title,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) {
    setState(() {
      _isShowingResults = true;
      _resultsQueryType = queryType;
      _resultsTitle = title;
      _resultsQuery = searchQuery;
      _resultsFilters = filters;
      _resultsList.clear();
      _resultsCurrentPage = 1;
      _resultsHasNextPage = true;
      _resultsIsLoading = false;
      _resultsErrorMessage = null;
    });

    _fetchResults();
  }

  void _hideSearchResults() {
    setState(() {
      _isShowingResults = false;
      _searchController.clear();
    });
    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        0,
        duration: mediumDuration,
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSeriesOpen(AnilistAnime anime) {
    final navigator = Provider.of<NavigationManager>(context, listen: false);
    navigator.pushPage("search:series:${anime.id}", anime.title.userPreferred ?? 'Anime Details');
  }

  Future<List<String>> _aggregateImages() async {
    final results = await Future.wait([
      _trendingFuture,
      _popularFuture,
      _upcomingFuture,
      _top100Future,
    ]);

    final Set<String> images = {};
    for (var page in results) {
      if (page?.results != null) {
        for (var anime in page!.results) {
          if (anime.posterImage != null) {
            images.add(anime.posterImage!);
          }
        }
      }
    }
    return images.toList()..shuffle();
  }

  void _onSearchFocusChange() => setState(() => _isSearchFocused = _searchFocusNode?.hasFocus ?? false);

  void _onSearchTextChanged() => setState(() => _textSearchWidth = measureTextWidth(_searchController.text, style: _searchTextStyle) + (20 - _animationValue * 8) + 10 + 16);

  void clearSearch() => _searchController.clear();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode?.dispose();
    deferredPointerLink?.dispose();
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  double _animationValue = 0.0;

  @override
  Widget build(BuildContext context) {
    super.build(context); // for AutomaticKeepAliveClientMixin

    final library = Provider.of<Library>(context);
    final settings = Provider.of<SettingsManager>(context);

    // detect when user scrolls upwards (print up) or downwards (print down)
    return DeferredPointerHandler(
      key: ValueKey('BrowseScreenDeferredPointerHandler'),
      link: deferredPointerLink,
      child: Stack(
        children: [
          IgnorePointer(
            ignoring: true,
            child: FadingEdgeScrollView(
              axis: Axis.horizontal,
              fadeEdges: const EdgeInsets.only(top: 300, bottom: 300), // horizontal fade
              child: FadingEdgeScrollView(
                fadeEdges: const EdgeInsets.only(top: 100, bottom: 300), // vertical fade
                child: FutureBuilder<List<String>>(
                  future: _imagesFuture,
                  builder: (context, snapshot) {
                    final images = snapshot.data ?? [];
                    final hasData = snapshot.hasData && images.isNotEmpty;
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      opacity: hasData && !_isShowingResults ? 1.0 : 0.0,
                      child: Opacity(
                        opacity: (1.0 - _animationValue).clamp(0.1, 0.5),
                        child: SearchLibraryShelfDisplay(
                          imageUrls: hasData ? images : [],
                          verticalOffset: -50 * _animationValue,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SearchTemplatePage(
            searchBarStatus: _isShowingResults ? SearchBarStatus.collapsed : SearchBarStatus.automatic,
            header: Text('Browse', style: Manager.titleStyle),
            behindSearchBar: (animationValue) {
              if (_animationValue != animationValue) nextFrame(() => setState(() => _animationValue = animationValue)); // setstate not needed here because the ui is building right now
              return SizedBox.shrink();
            },
            content: _buildBody(library, settings),
            searchBarCollapsedWidth: (maxConstrainedWidth) => min(maxConstrainedWidth, _textSearchWidth + 27 + _filterButtonSize),
            searchBarMaxCollapsedWidth: (maxConstrainedWidth) => min(maxConstrainedWidth, ScreenUtils.kMaxContentWidth - 150),
            searchBarMinCollapsedWidth: (_) => 350,
            searchBar: (width, height, animationValue, focusNode) {
              if (_searchFocusNode == null) {
                _searchFocusNode = focusNode;
                _searchFocusNode!.addListener(_onSearchFocusChange);
              }

              final bool isExpanded = animationValue < 0.2;
              final borderRadius = lerpDouble(8, 12, 1 - animationValue)!;
              final horizontalPadding = lerpDouble(12, 20, 1 - animationValue)!;
              final filterButtonSize = lerpDouble(43, ((height == null ? null : height + 3) ?? 40), 1 - animationValue)!;
              _filterButtonSize = filterButtonSize;

              Color color(double a) => _isSearchFocused ? (Manager.currentDominantAccentColor ?? Manager.accentColor) : Colors.white.withOpacity(a);
              Color filterColorBg = _showFilters ? (Manager.currentDominantAccentColor ?? Manager.accentColor) : Colors.transparent;
              final val = 6.0;

              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  Row(
                    children: [
                      GlossyContainer(
                        color: color(1).withOpacity(.015),
                        opacity: 0.1,
                        strengthX: 20,
                        strengthY: 20,
                        blendMode: BlendMode.src,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(borderRadius),
                          bottomLeft: Radius.circular(borderRadius),
                          topRight: Radius.circular(borderRadius / 3),
                          bottomRight: Radius.circular(borderRadius / 3),
                        ),
                        width: (width ?? ScreenUtils.kMaxContentWidth - 150) - (filterButtonSize + val),
                        height: (height == null ? null : height + 3) ?? 40,
                        child: FrostedNoise(
                          intensity: .5,
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              textSelectionTheme: TextSelectionThemeData(
                                selectionColor: color(1).withOpacity(0.3),
                                selectionHandleColor: color(1),
                              ),
                            ),
                            child: TextBox(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              cursorOpacityAnimates: true,
                              style: _searchTextStyle,
                              padding: EdgeInsetsDirectional.fromSTEB(horizontalPadding, 0, horizontalPadding, 0),
                              highlightColor: Colors.transparent,
                              unfocusedColor: Colors.transparent,
                              enableInteractiveSelection: true,
                              suffix: _searchController.text.isNotEmpty
                                  ? Padding(
                                      padding: EdgeInsets.only(right: 20.0 - _animationValue * 8),
                                      child: IconButton(
                                        icon: Icon(FluentIcons.chrome_close, color: color(.6), size: 16),
                                        onPressed: clearSearch,
                                      ),
                                    )
                                  : null,
                              prefix: Padding(padding: EdgeInsets.only(left: 20.0 - _animationValue * 8), child: Icon(Icons.search, color: color(.6), size: 23)),
                              decoration: ButtonState.all(
                                BoxDecoration(
                                  color: color(1).withOpacity(.015),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(borderRadius),
                                    bottomLeft: Radius.circular(borderRadius),
                                    topRight: Radius.circular(borderRadius / 3),
                                    bottomRight: Radius.circular(borderRadius / 3),
                                  ),
                                  border: Border.all(
                                    color: _isSearchFocused //
                                        ? (Manager.currentDominantAccentColor ?? Manager.accentColor).light
                                        : Colors.white.withOpacity(0.1),
                                    width: _searchController.text.isNotEmpty ? 1.5 : 1,
                                  ),
                                ),
                              ),
                              placeholder: 'Search...',
                              onSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  _showSearchResults(
                                    queryType: 'search',
                                    title: 'Search Results: $value',
                                    searchQuery: value,
                                  );
                                }
                              },
                              onChanged: (value) {
                                if (value.isEmpty && _isShowingResults) _hideSearchResults();
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: val),
                      GlossyContainer(
                        color: filterColorBg,
                        opacity: 0.1,
                        strengthX: 20,
                        strengthY: 20,
                        blendMode: BlendMode.src,
                        border: Border.all(
                          color: _showFilters ? (Manager.currentDominantAccentColor ?? Manager.accentColor) : Colors.white.withOpacity(0.1),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(borderRadius / 3),
                          bottomLeft: Radius.circular(borderRadius / 3),
                          topRight: Radius.circular(borderRadius),
                          bottomRight: Radius.circular(borderRadius),
                        ),
                        width: filterButtonSize,
                        height: filterButtonSize,
                        child: FrostedNoise(
                          intensity: .5,
                          color: filterColorBg,
                          child: StandardButton.icon(
                            expandY: true,
                            padding: EdgeInsets.zero,
                            expand: true,
                            icon: Icon(FluentIcons.filter, color: _showFilters ? Manager.accentColor : Colors.grey, size: 20),
                            onPressed: () => setState(() => _showFilters = !_showFilters),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Filters Header
                  AnimatedSwitcher(
                    duration: dimDuration / 2,
                    reverseDuration: dimDuration / 4,
                    transitionBuilder: (child, animation) => SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: const Offset(0, 1.25),
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    ),
                    child: _showFilters && isExpanded ? DeferPointer(child: const AnimeFilterHeader()) : const SizedBox.shrink(),
                  ),
                ],
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedSwitcher(
                duration: dimDuration,
                child: _isShowingResults
                    ? BackButton(
                        onTap: _hideSearchResults,
                        label: 'Back to Browse',
                        child: const Icon(FluentIcons.back),
                      )
                    : SizedBox.shrink(),
              ),
              // ... other buttons
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(Library library, SettingsManager settings) {
    return FadingEdgeScrollView(
      fadeEdges: const EdgeInsets.only(bottom: 40),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: AnimatedSwitcher(
          duration: mediumDuration,
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _isShowingResults
              ? KeyedSubtree(
                  key: const ValueKey('SearchResults'),
                  child: _buildResultsView(),
                )
              : KeyedSubtree(
                  key: const ValueKey('Dashboard'),
                  child: Consumer<AnilistProvider>(
                    builder: (context, anilistProvider, _) {
                      return AnimeContentDashboard(
                        onShowSearchResults: _showSearchResults,
                        onSeriesOpen: _onSeriesOpen,
                        onRetry: () => setState(() => _fetchData()),
                        trendingFuture: _trendingFuture,
                        popularFuture: _popularFuture,
                        upcomingFuture: _upcomingFuture,
                        top100Future: _top100Future,
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    if (_resultsErrorMessage != null && _resultsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_resultsErrorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            Button(
              onPressed: _fetchResults,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_resultsList.isEmpty && _resultsIsLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: ProgressRing()),
      );
    }

    if (_resultsList.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No results found.')),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      final int count = ScreenUtils.crossAxisCount(constraints.maxWidth);
      return Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: count,
              childAspectRatio: ScreenUtils.kDefaultAspectRatio,
              crossAxisSpacing: ScreenUtils.cardPadding,
              mainAxisSpacing: ScreenUtils.cardPadding,
            ),
            padding: EdgeInsets.only(top: 16),
            itemCount: _resultsList.length,
            itemBuilder: (context, index) {
              final item = _resultsList[index];
              return SearchSeriesCard(
                series: item,
                onTap: () => _onSeriesOpen(item),
              );
            },
          ),
          if (_resultsIsLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: ProgressRing()),
            ),
        ],
      );
    });
  }
}

class AnimeFilterHeader extends StatefulWidget {
  const AnimeFilterHeader({super.key});

  @override
  State<AnimeFilterHeader> createState() => _AnimeFilterHeaderState();
}

class _AnimeFilterHeaderState extends State<AnimeFilterHeader> {
  // Mock State Variables for dropdowns
  String _selectedGenre = 'Any';
  String _selectedYear = 'Any';
  String _selectedSeason = 'Any';
  String _selectedFormat = 'Any';
  String _selectedStatus = 'Any';

  bool _showAdvFilters = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: LayoutBuilder(builder: (context, constraints) {
        final sizePerFilter = (constraints.maxWidth - (16 * 4) - 24 - 40) / 5;
        Color filterColorBg = _showAdvFilters ? (Manager.currentDominantAccentColor ?? Manager.accentColor) : Colors.transparent;
        final borderRadius = 8.0;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 2. Dropdowns
            _buildDropdown("Genres", _selectedGenre, ['Any', 'Action', 'Drama'], (v) => setState(() => _selectedGenre = v!), sizePerFilter),
            const SizedBox(width: 16),
            _buildDropdown("Year", _selectedYear, ['Any', '2024', '2023'], (v) => setState(() => _selectedYear = v!), sizePerFilter),
            const SizedBox(width: 16),
            _buildDropdown("Season", _selectedSeason, ['Any', 'Winter', 'Spring'], (v) => setState(() => _selectedSeason = v!), sizePerFilter),
            const SizedBox(width: 16),
            _buildDropdown("Format", _selectedFormat, ['Any', 'TV Show', 'Movie'], (v) => setState(() => _selectedFormat = v!), sizePerFilter),
            const SizedBox(width: 16),
            _buildDropdown("Airing Status", _selectedStatus, ['Any', 'Airing', 'Finished'], (v) => setState(() => _selectedStatus = v!), sizePerFilter),

            const SizedBox(width: 16),

            // 3. Filter/List View Toggle Button (Far right in image)
            GlossyContainer(
              color: filterColorBg,
              opacity: 0.1,
              strengthX: 20,
              strengthY: 20,
              blendMode: BlendMode.src,
              border: Border.all(
                color: _showAdvFilters ? (Manager.currentDominantAccentColor ?? Manager.accentColor) : Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                bottomLeft: Radius.circular(borderRadius),
                topRight: Radius.circular(borderRadius),
                bottomRight: Radius.circular(borderRadius),
              ),
              width: 140,
              height: 40,
              child: FrostedNoise(
                intensity: .5,
                color: filterColorBg,
                child: StandardButton.iconLabel(
                  expandY: true,
                  padding: EdgeInsets.zero,
                  expand: true,
                  label: Transform.translate(
                    offset: const Offset(0, 1),
                    child: Text('Advanced', style: Manager.bodyStyle.copyWith(color: Colors.grey)),
                  ),
                  icon: Icon(Icons.tune, color: _showAdvFilters ? Manager.accentColor : Colors.grey, size: 20),
                  onPressed: () => setState(() => _showAdvFilters = !_showAdvFilters),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Helper to build stylized Dropdowns
  Widget _buildDropdown(String label, String currentValue, List<String> items, ValueChanged<String?> onChanged, double width) {
    return Expanded(
      child: GlossyContainer(
        opacity: 0.1,
        strengthX: 20,
        strengthY: 20,
        blendMode: BlendMode.src,
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
        width: width,
        height: 40,
        child: FrostedNoise(
          intensity: 0.4,
          child: Padding(
            padding: EdgeInsets.only(left: 24.0, right: 12.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentValue,
                hint: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                dropdownColor: const Color(0xFF1B222C),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                isExpanded: true,
                onChanged: onChanged,
                items: items.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimeContentDashboard extends StatefulWidget {
  final Function({
    required String queryType,
    required String title,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) onShowSearchResults;
  final Function(AnilistAnime anime) onSeriesOpen;
  final VoidCallback onRetry;

  final Future<AnilistSearchPage<AnilistAnime>?> trendingFuture;
  final Future<AnilistSearchPage<AnilistAnime>?> popularFuture;
  final Future<AnilistSearchPage<AnilistAnime>?> upcomingFuture;
  final Future<AnilistSearchPage<AnilistAnime>?> top100Future;

  const AnimeContentDashboard({
    super.key,
    required this.onShowSearchResults,
    required this.onSeriesOpen,
    required this.onRetry,
    required this.trendingFuture,
    required this.popularFuture,
    required this.upcomingFuture,
    required this.top100Future,
  });

  @override
  State<AnimeContentDashboard> createState() => _AnimeContentDashboardState();
}

class _AnimeContentDashboardState extends State<AnimeContentDashboard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection("TRENDING NOW", widget.trendingFuture, 'trending'),
            const SizedBox(height: 30),
            _buildSection("POPULAR THIS SEASON", widget.popularFuture, 'popular'),
            const SizedBox(height: 30),
            _buildSection("UPCOMING NEXT SEASON", widget.upcomingFuture, 'upcoming'),
            const SizedBox(height: 30),
            _buildSection("TOP 100 ANIME", widget.top100Future, 'top100'),
            const SizedBox(height: 50), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Future<AnilistSearchPage<AnilistAnime>?> future, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title, type),
        LayoutBuilder(builder: (context, constraints) {
          final int count = ScreenUtils.crossAxisCount(constraints.maxWidth);
          final double cardHeight = ScreenUtils.maxCardHeight;
          final double sectionHeight = cardHeight + 30;

          return SizedBox(
            height: sectionHeight,
            child: FutureBuilder<AnilistSearchPage<AnilistAnime>?>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: ProgressRing());

                String? error;
                if (snapshot.hasError) {
                  error = 'Error: ${snapshot.error}';
                } else if (snapshot.connectionState == ConnectionState.done && snapshot.data == null) {
                  error = 'Failed to load data';
                }

                if (error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(error, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 8),
                        Button(
                          onPressed: widget.onRetry,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final mediaList = snapshot.data?.results ?? [];
                if (mediaList.isEmpty) return const Center(child: Text('No anime found'));

                final displayList = mediaList.take(count).toList();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(
                    (displayList.length * 2) - 1,
                    (index) {
                      if (index % 2 == 1) return SizedBox(width: ScreenUtils.cardPadding);

                      final item = displayList[index ~/ 2];
                      return Expanded(
                        child: AspectRatio(
                          aspectRatio: ScreenUtils.kDefaultAspectRatio,
                          child: SearchSeriesCard(
                            series: item,
                            onTap: () => widget.onSeriesOpen(item),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          GestureDetector(
            onTap: () {
              widget.onShowSearchResults(
                queryType: type,
                title: title,
              );
            },
            child: const Text(
              "View All",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchLibraryShelfDisplay extends StatelessWidget {
  final List<String> imageUrls;
  final bool reverseAnimation;
  final double verticalOffset;
  final double sigma = 2.0;

  const SearchLibraryShelfDisplay({
    super.key,
    required this.imageUrls,
    this.reverseAnimation = false,
    this.verticalOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final rows = ((constraints.maxHeight + 480) / 195).ceil(); //~ 4 rows at 300 height and 8 rows at 1080 height
      return ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: SizedBox(
          height: constraints.maxHeight + 100,
          width: constraints.maxWidth,
          child: Slanted3DGrid(
            images: imageUrls,
            rows: rows,
            speed: reverseAnimation ? -20 : 20,
            angle: -0.2, // The slant angle
            verticalOffset: verticalOffset,
          ),
        ),
      );
    });
  }
}

class Slanted3DGrid extends StatefulWidget {
  final List<String> images;
  final int rows;
  final double speed;
  final double angle;
  final double verticalOffset;

  const Slanted3DGrid({
    super.key,
    required this.images,
    this.rows = 4,
    this.speed = 16.0, // Pixels per second
    this.angle = -0.1, // Rotation Z
    this.verticalOffset = 0.0,
  });

  @override
  State<Slanted3DGrid> createState() => _Slanted3DGridState();
}

class _Slanted3DGridState extends State<Slanted3DGrid> {
  late List<List<String>> _rowImages;

  @override
  void initState() {
    super.initState();
    _initializeRows();
  }

  void _initializeRows() {
    _rowImages = List.generate(
      widget.rows,
      (_) => List.of(widget.images)..shuffle(),
    );
  }

  @override
  void didUpdateWidget(Slanted3DGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.images != oldWidget.images) {
      _initializeRows();
    } else if (widget.rows != oldWidget.rows) {
      if (widget.rows > _rowImages.length) {
        final int newRowsCount = widget.rows - _rowImages.length;
        _rowImages.addAll(
          List.generate(
            newRowsCount,
            (_) => List.of(widget.images)..shuffle(),
          ),
        );
      } else {
        _rowImages.length = widget.rows;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    const double imageWidth = 80.0;
    const double imageHeight = imageWidth * 1.71;
    const double gap = 8.0;

    return LayoutBuilder(builder: (context, constraints) {
      final double width = constraints.maxWidth * 1.5;
      final double height = constraints.maxHeight * 1.5;

      return OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: Transform(
          alignment: Alignment.center,
          filterQuality: FilterQuality.medium,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..translate(0.0, widget.verticalOffset, 0.0)
            ..rotateX(-0.4)
            ..rotateY(0.1)
            ..rotateZ(widget.angle)
            ..scale(1.6)
            ..translate(0.0, -200.0, 0.0),
          child: SizedBox(
            width: width,
            height: height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.rows, (rowIndex) {
                // Calculate a unique speed multiplier for each row to ensure different speeds
                final double speedVariation = 0.8 + ((rowIndex * 3) % 5) * 0.2;

                // Alternate direction for each row
                final double direction = (rowIndex % 2 == 0) ? 1.0 : -1.0;

                final double rowSpeed = widget.speed * speedVariation * direction;

                final List<String> rowImageList = (rowIndex < _rowImages.length) ? _rowImages[rowIndex] : widget.images;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: gap / 2),
                  child: SizedBox(
                    height: imageHeight,
                    child: Marquee(
                      startPadding: rowIndex * (imageWidth + gap) / 2,
                      velocity: rowSpeed,
                      containerExtent: (imageWidth + gap) * rowImageList.length,
                      blankSpace: 0,
                      child: Row(
                        children: rowImageList.map((imgUrl) {
                          return Container(
                            width: imageWidth,
                            height: imageHeight,
                            margin: EdgeInsets.only(right: gap),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                  imgUrl,
                                  maxHeight: (imageHeight * ScreenUtils.pixelResolution * 5).toInt(),
                                  maxWidth: (imageWidth * ScreenUtils.pixelResolution * 5).toInt(),
                                ),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 4,
                                  offset: const Offset(2, 2),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );
    });
  }
}
