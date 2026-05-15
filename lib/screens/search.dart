import 'dart:math' show min;
import 'dart:ui';

import 'package:defer_pointer/defer_pointer.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors, IconButton;
import 'package:flutter/material.dart' hide TextBox, Slider, BackButton;
import 'package:glossy/glossy.dart';
import 'package:miruryoiki/utils/text.dart';
import 'package:miruryoiki/widgets/frosted_noise.dart';
import 'package:provider/provider.dart';

import '../../manager.dart';
import '../../models/anilist/page_info.dart';
import '../../services/anilist/anilist_availability.dart';
import '../../services/connectivity/connectivity_service.dart';
import '../../services/navigation/navigation.dart';
import '../../settings.dart';
import '../../utils/screen.dart';
import '../../utils/time.dart';
import '../../widgets/buttons/back_button.dart';
import '../../widgets/buttons/button.dart';
import '../../widgets/service_unavailable_banner.dart';
import '../models/anilist/anime_card.dart';
import '../widgets/cards/search_series_card.dart';
import '../../widgets/fading_edge_scrollview.dart';
import '../../widgets/page/search_template.dart';
import '../../widgets/search_bg_library_shelf_cards.dart';
import '../../widgets/search_filters.dart';
import '../../widgets/top100_list.dart';
import '../../widgets/section_grid_view.dart';
import '../services/anilist/queries/anilist_service.dart';
import '../services/library/library_provider.dart';
import '../utils/logging.dart';
import '../utils/anilist_utils.dart';
import '../widgets/animated_hider.dart';
import 'searched_series.dart';

class SectionDataManager extends ChangeNotifier {
  final int id;
  final String type; // 'trending', 'popular', 'upcoming', 'top100'

  List<AnimeCard> items = [];
  bool isLoading = false;
  bool hasMore = true;
  int currentPage = 1;
  int perPage;
  String? errorMessage;

  bool isFetching = false;

  SectionDataManager({required this.id, required this.type, this.perPage = 6});

  Future<void> fetch({bool reset = false, int? overridePerPage, bool preserveCurrentItems = false}) async {
    if (isFetching) return;
    if (!hasMore && !reset) return;

    isFetching = true;

    // Only fresh start
    if (items.isEmpty || (reset && !preserveCurrentItems)) {
      isLoading = true;
      notifyListeners();
    }

    try {
      int reqPage = reset ? 1 : currentPage;
      int reqPerPage = overridePerPage ?? perPage;

      final service = AnilistService();
      AnilistSearchPage<AnimeCard>? result;

      switch (type) {
        case 'trending':
          result = await service.getTrendingNow(page: reqPage, perPage: reqPerPage);
          break;
        case 'popular':
          result = await service.getPopularThisSeason(page: reqPage, perPage: reqPerPage);
          break;
        case 'upcoming':
          result = await service.getUpcomingNextSeason(page: reqPage, perPage: reqPerPage);
          break;
        case 'top100':
          result = await service.getTop100Anime(page: reqPage, perPage: reqPerPage);
          break;
      }

      if (result != null && result.results.isNotEmpty) {
        if (reset) {
          if (!preserveCurrentItems) items.clear();

          currentPage = 1;
          if (overridePerPage != null) perPage = overridePerPage;
        }

        // Keep older + append
        final newItems = result.results.where((newAnim) => !items.any((existing) => existing.id == newAnim.id));
        items.addAll(newItems);

        hasMore = result.pageInfo.hasNextPage;
        currentPage++;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      isFetching = false;
      notifyListeners();
    }
  }
}

final GlobalKey<SearchScreenState> browseScreenKey = GlobalKey<SearchScreenState>();

class BrowseScreen extends StatefulWidget {
  final ScrollController scrollController;
  const BrowseScreen({super.key, required this.scrollController});
  @override
  State<BrowseScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<BrowseScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  FocusNode? _searchFocusNode;
  final TextStyle _searchTextStyle = Manager.smallSubtitleStyle.copyWith(fontWeight: FontWeight.w400);
  double _lastScrollPosition = 0.0;
  DeferredPointerHandlerLink? deferredPointerLink;

  bool _isSearchFocused = false;
  double _textSearchWidth = 0.0;
  bool _showFilters = false;

  bool _isShowingSearchQuery = false;
  int? _expandedSectionId;
  late Map<int, SectionDataManager> _sectionManagers;
  Future<List<String>>? _imagesFuture;

  String? _resultsQuery;
  Map<String, dynamic>? _resultsFilters;
  final List<AnimeCard> _resultsList = [];
  bool _resultsIsLoading = false;
  bool _resultsIsLoadingUI = false;
  bool _resultsHasNextPage = true;
  int _resultsCurrentPage = 1;
  String? _resultsErrorMessage;
  double _filterButtonSize = 40;
  SearchBarStatus _overrideSearchBarStatus = SearchBarStatus.automatic;

  final GlobalKey<SearchedSeriesScreenState> searchedSeriesScreenKey = GlobalKey<SearchedSeriesScreenState>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
    widget.scrollController.addListener(_onScroll);
    NavigationManager.registerActiveScrollController('search', widget.scrollController);
    NavigationManager.restoreScrollOffset('search', widget.scrollController);

    _sectionManagers = {
      1: SectionDataManager(id: 1, type: 'trending'),
      2: SectionDataManager(id: 2, type: 'popular'),
      3: SectionDataManager(id: 3, type: 'upcoming'),
      4: SectionDataManager(id: 4, type: 'top100', perPage: 10),
    };

    _fetchInitialData();
  }

  void _fetchInitialData() {
    for (var manager in _sectionManagers.values) manager.fetch(reset: true, overridePerPage: manager.perPage);
    _imagesFuture = _aggregateImages();
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;

    final settings = Provider.of<SettingsManager>(context, listen: false);
    if (!settings.useInfiniteScroll) return;

    final maxScroll = widget.scrollController.position.maxScrollExtent;
    final currentScroll = widget.scrollController.position.pixels;
    final delta = 200.0; // Trigger distance

    if (currentScroll >= maxScroll - delta) {
      // Infinite Scroll for Text Search
      if (_isShowingSearchQuery && !_resultsIsLoading && _resultsHasNextPage)
        _fetchTextSearchResults();

      // Infinite Scroll for Expanded Section
      else if (_expandedSectionId != null) {
        final activeManager = _sectionManagers[_expandedSectionId];
        if (activeManager != null && !activeManager.isLoading && activeManager.hasMore) {
          // Fetch next page
          activeManager.fetch();
        }
      }
    }
  }

  void _expandSection(int sectionId) {
    if (widget.scrollController.hasClients) _lastScrollPosition = widget.scrollController.offset;

    setState(() {
      _expandedSectionId = sectionId;
      _isShowingSearchQuery = false;
    });

    // Scroll to top
    if (widget.scrollController.hasClients)
      widget.scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

    final manager = _sectionManagers[sectionId];
    if (manager != null) manager.fetch(reset: true, overridePerPage: 42, preserveCurrentItems: true);
  }

  void _performTextSearch(String query, {Map<String, dynamic>? filters}) {
    setState(() {
      _isShowingSearchQuery = true;
      _expandedSectionId = null;
      _resultsQuery = query;
      _resultsFilters = filters;
      _resultsList.clear();
      _resultsCurrentPage = 1;
      _resultsHasNextPage = true;
      _resultsIsLoading = false;
      _resultsErrorMessage = null;
    });

    // Scroll to top
    if (widget.scrollController.hasClients) //
      widget.scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

    _fetchTextSearchResults();
  }

  /// Fetches search results based on the current query type, page, and filters
  Future<void> _fetchTextSearchResults() async {
    if (_resultsIsLoading) return;
    setState(() {
      _resultsIsLoading = true;
      _resultsErrorMessage = null;
    });

    try {
      final service = AnilistService();
      final perPage = 42;

      AnilistSearchPage<AnimeCard>? result = await service.searchAnime(
        page: _resultsCurrentPage,
        perPage: perPage,
        search: _resultsQuery,
        //TODO add all filters
        genres: _resultsFilters?['genres'],
        sort: _resultsFilters?['sort'] ?? const ['POPULARITY_DESC'],
      );

      if (result == null) {
        if (mounted)
          setState(() {
            _resultsIsLoading = false;
            _resultsErrorMessage = 'Failed to load data.';
          });
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
      if (mounted)
        setState(() {
          _resultsIsLoading = false;
          _resultsErrorMessage = 'Error: $e';
        });
    }
  }

  void _handleBack() {
    setState(() {
      if (_expandedSectionId != null) {
        _expandedSectionId = null;

        _forceExpandIfNecessary();
        nextFrame(delay: 150, () {
          // Scroll back to last position
          if (widget.scrollController.hasClients)
            widget.scrollController.animateTo(
              _lastScrollPosition,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
        });
      } else if (_isShowingSearchQuery) {
        _isShowingSearchQuery = false;
        _searchController.clear();

        if (widget.scrollController.hasClients)
          widget.scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );

        _forceExpandIfNecessary();
      }
    });

    if (widget.scrollController.hasClients) //
      widget.scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _forceExpandIfNecessary() {
    if (_lastScrollPosition <= 100) {
      setState(() => _overrideSearchBarStatus = SearchBarStatus.expanded);

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _overrideSearchBarStatus = SearchBarStatus.automatic);
      });
    }
  }

  void _onSeriesOpen(AnimeCard anime) => navigateToSeries(anime);

  Future<List<String>> _aggregateImages() async {
    final service = AnilistService();
    final results = await Future.wait([service.getTrendingNow(perPage: 6), service.getPopularThisSeason(perPage: 6), service.getUpcomingNextSeason(perPage: 6), service.getTop100Anime(perPage: 10)]);
    final Set<String> images = {};
    for (var page in results) {
      if (page?.results != null) {
        for (var anime in page!.results) {
          if (anime.coverImage != null) images.add(anime.coverImage!);
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

  bool get _isServiceUnavailable => ConnectivityService().isOffline || AnilistAvailabilityService().isUnavailable;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final library = Provider.of<Library>(context);
    final settings = Provider.of<SettingsManager>(context);
    final bool showBackButton = _isShowingSearchQuery || _expandedSectionId != null;

    return DeferredPointerHandler(
      key: ValueKey('BrowseScreenDeferredPointerHandler'),
      link: deferredPointerLink,
      child: Stack(
        children: [
          // Background Shelf Cards
          IgnorePointer(
            ignoring: true,
            child: FadingEdgeScrollView(
              axis: Axis.horizontal,
              fadeEdges: const EdgeInsets.only(top: 300, bottom: 300), //TODO horiz/vert factory
              child: FadingEdgeScrollView(
                fadeEdges: const EdgeInsets.only(top: 100, bottom: 300),
                child: FutureBuilder<List<String>>(
                  future: _imagesFuture,
                  builder: (context, snapshot) {
                    final images = snapshot.data ?? [];
                    final hasData = snapshot.hasData && images.isNotEmpty;
                    final shouldHide = _isShowingSearchQuery || _expandedSectionId != null;
        
                    return AnimatedHider(
                      duration: const Duration(milliseconds: 800),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      shouldShowChild: hasData && !shouldHide,
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
          // Main Content
          SearchTemplatePage(
            scrollController: widget.scrollController,
            searchBarStatus: (_isShowingSearchQuery || _expandedSectionId != null) ? SearchBarStatus.collapsed : _overrideSearchBarStatus,
            header: Builder(builder: (context) {
              if (_isShowingSearchQuery) return Text('Search Results for "${_resultsQuery ?? ''}"', style: Manager.titleStyle);
              if (_expandedSectionId != null) {
                final sectionTitles = {
                  1: 'Trending Now',
                  2: 'Popular This Season',
                  3: 'Upcoming Next Season',
                  4: 'Top 100 Anime',
                };
                final title = sectionTitles[_expandedSectionId!] ?? 'Browse';
                return Text(title, style: Manager.titleStyle);
              }
        
              return Text('Browse', style: Manager.titleStyle);
            }),
            behindSearchBar: (val) {
              // Capture animation value for other effects
              if (_animationValue != val) nextFrame(() => setState(() => _animationValue = val));
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
              final double borderRadius = lerpDouble(8, 12, 1 - animationValue)!;
              final double horizontalPadding = lerpDouble(12, 20, 1 - animationValue)!;
              final double filterButtonSize = lerpDouble(43, ((height == null ? null : height + 3) ?? 40), 1 - animationValue)!;
              _filterButtonSize = filterButtonSize;
              Color color(double whiteAlpha) => _isSearchFocused ? (Manager.currentDominantAccentColor ?? Manager.accentColor) : Colors.white.withOpacity(whiteAlpha);
              final Color filterColorBg = _showFilters ? (Manager.currentDominantAccentColor ?? Manager.accentColor) : Colors.transparent;
              final double filtersButtonLeftPadding = 6.0;
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  Row(
                    children: [
                      // Search Box
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
                        width: (width ?? ScreenUtils.kMaxContentWidth - 150) - (filterButtonSize + filtersButtonLeftPadding),
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
                              enabled: !_isServiceUnavailable,
                              placeholder: _isServiceUnavailable ? 'Search unavailable...' : 'Search...',
                              onSubmitted: (value) {
                                if (value.isNotEmpty && !_isServiceUnavailable) _performTextSearch(value);
                              },
                              onChanged: (value) {
                                if (value.isEmpty && _isShowingSearchQuery) _handleBack();
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: filtersButtonLeftPadding),
                      // Filters Button
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
          // Back Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedSwitcher(
                duration: dimDuration,
                child: showBackButton
                    ? BackButton(
                        onTap: _handleBack,
                        label: 'Back to Browse',
                        child: const Icon(FluentIcons.back),
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(Library library, SettingsManager settings) {
    return FadingEdgeScrollView(
      fadeEdges: const EdgeInsets.only(bottom: 40),
      child: AnimatedSwitcher(
        duration: mediumDuration,
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(animation), child: child)),
        // If searching text    -> Show Separate Results View
        // If expanding section -> Show Main Dashboard
        // If nothing           -> Show Main Dashboard
        child: _isShowingSearchQuery
            ? KeyedSubtree(
                key: const ValueKey('SearchResults'),
                child: _buildResultsView(),
              )
            : _expandedSectionId == 4
                ? KeyedSubtree(
                    key: const ValueKey('Top100Expanded'),
                    child: SectionGridView(
                      manager: _sectionManagers[4]!,
                      onSeriesOpen: _onSeriesOpen,
                    ),
                  )
                : KeyedSubtree(
                    key: const ValueKey('Dashboard'),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ServiceUnavailableBanner(onRetry: _fetchInitialData),
                        AnimeContentDashboard(
                          sectionManagers: _sectionManagers,
                          onExpandSection: _expandSection,
                          onSeriesOpen: _onSeriesOpen,
                          onRetry: _fetchInitialData,
                          expandedSectionId: _expandedSectionId,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildResultsView() {
    // Show service unavailability or offline banner when there's an error
    if (_resultsErrorMessage != null && _resultsList.isEmpty) {
      if (ConnectivityService().isOffline || AnilistAvailabilityService().isUnavailable) {
        return ServiceUnavailableBanner(onRetry: _fetchTextSearchResults);
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_resultsErrorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            Button(
              onPressed: _fetchTextSearchResults,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_resultsList.isEmpty && _resultsIsLoading) return const SizedBox(height: 200, child: Center(child: ProgressRing()));
    if (_resultsList.isEmpty) return const SizedBox(height: 200, child: Center(child: Text('No results found.')));

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
                number: null, // not showing top100 number
                onTap: () => _onSeriesOpen(item),
              );
            },
          ),
          if (_resultsIsLoading) const Padding(padding: EdgeInsets.all(16.0), child: Center(child: ProgressRing())),
          if (!_resultsIsLoading && _resultsHasNextPage && !Provider.of<SettingsManager>(context).useInfiniteScroll)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                // Search Load More Button
                child: StandardButton.label(
                  onPressed: () {
                    log('Loading more search results for query: $_resultsQuery, page: $_resultsCurrentPage');
                    setState(() => _resultsIsLoadingUI = true);
                    _fetchTextSearchResults().then((_) {
                      if (mounted) setState(() => _resultsIsLoadingUI = false);
                      log('Finished loading more search results.');
                    });
                  },
                  isLoading: _resultsIsLoadingUI,
                  label: 'Load More',
                ),
              ),
            ),
        ],
      );
    });
  }
}

class AnimeContentDashboard extends StatelessWidget {
  final Map<int, SectionDataManager> sectionManagers;
  final Function(int sectionId) onExpandSection;
  final Function(AnimeCard anime) onSeriesOpen;
  final VoidCallback onRetry;
  final int? expandedSectionId;

  const AnimeContentDashboard({
    super.key,
    required this.sectionManagers,
    required this.onExpandSection,
    required this.onSeriesOpen,
    required this.onRetry,
    required this.expandedSectionId,
  });

  @override
  Widget build(BuildContext context) {
    final sections = {
      1: 'TRENDING NOW',
      2: 'POPULAR THIS SEASON',
      3: 'UPCOMING NEXT SEASON',
      4: 'TOP 100 ANIME',
    };

    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 20),
          itemCount: sections.length,
          itemBuilder: (context, index) {
            final sectionEntry = sections.entries.elementAt(index);
            final sectionId = sectionEntry.key;
            final sectionTitle = sectionEntry.value;

            final bool isExpanded = expandedSectionId == sectionId;
            final bool isHidden = expandedSectionId != null && !isExpanded;

            if (sectionId == 4) {
              return AnimatedSectionWrapper(
                isHidden: isHidden,
                child: Top100List(
                  manager: sectionManagers[sectionId]!,
                  onSeriesOpen: onSeriesOpen,
                  onExpand: () => onExpandSection(sectionId),
                ),
              );
            }

            return AnimatedSectionWrapper(
              isHidden: isHidden,
              child: SectionWidget(
                title: sectionTitle,
                manager: sectionManagers[sectionId]!,
                isExpanded: isExpanded,
                onExpand: () => onExpandSection(sectionId),
                onSeriesOpen: onSeriesOpen,
              ),
            );
          },
        ),
      ),
    );
  }
}

class SectionWidget extends StatefulWidget {
  final String title;
  final SectionDataManager manager;
  final bool isExpanded;
  final VoidCallback onExpand;
  final Function(AnimeCard) onSeriesOpen;

  const SectionWidget({
    super.key,
    required this.title,
    required this.manager,
    required this.isExpanded,
    required this.onExpand,
    required this.onSeriesOpen,
  });

  @override
  State<SectionWidget> createState() => _SectionWidgetState();
}

class _SectionWidgetState extends State<SectionWidget> {
  bool _areExtrasLoaded = false;
  bool _isCollapsing = false;
  bool _isRestoring = false;
  bool _fetchingMore = false;
  bool _showLoadMoreAfterExpand = false;

  @override
  void initState() {
    super.initState();
    if (widget.isExpanded) {
      _areExtrasLoaded = true;
      _isRestoring = true;
      _showLoadMoreAfterExpand = false;

      nextFrame(() {
        if (mounted) setState(() => _isRestoring = false);
      });
    }
  }

  @override
  void didUpdateWidget(covariant SectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isExpanded && !oldWidget.isExpanded) {
      _showLoadMoreAfterExpand = false;
      // Start expand animation
      // Delay showing the extra result rows until after the animation
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && widget.isExpanded) {
          setState(() {
            _areExtrasLoaded = true;
            _isCollapsing = false;
          });

          // To prevent load more button from appearing during the wait for the first batch fetch, delay showing the Load More button
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted && widget.isExpanded) setState(() => _showLoadMoreAfterExpand = true);
          });
        }
      });
    } else if (!widget.isExpanded && oldWidget.isExpanded) {
      // Start collapse animation
      setState(() => _isCollapsing = true);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && !widget.isExpanded) {
          setState(() {
            _areExtrasLoaded = false;
            _isCollapsing = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.manager,
      builder: (context, child) {
        final fullList = widget.manager.items;

        if (fullList.isEmpty && widget.manager.isLoading) return const SizedBox(height: 200, child: Center(child: ProgressRing()));
        if (fullList.isEmpty) return const SizedBox.shrink();

        return LayoutBuilder(builder: (context, constraints) {
          final int crossAxisCount = ScreenUtils.crossAxisCount(constraints.maxWidth);
          final bool showFullGrid = (widget.isExpanded && _areExtrasLoaded) || _isCollapsing;
          final int visibleItemCount = showFullGrid ? fullList.length : (fullList.length < crossAxisCount ? fullList.length : crossAxisCount);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              _buildSectionHeader(widget.title, widget.isExpanded),

              // Series Grid
              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutQuart,
                alignment: Alignment.topCenter,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: ScreenUtils.kDefaultAspectRatio,
                    crossAxisSpacing: ScreenUtils.cardPadding,
                    mainAxisSpacing: ScreenUtils.cardPadding,
                  ),
                  itemCount: visibleItemCount,
                  itemBuilder: (context, index) {
                    final item = fullList[index];

                    // All result cards are shown
                    if (index >= crossAxisCount) {
                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _isCollapsing ? 0.0 : 1.0,
                        curve: Curves.easeOut,
                        child: FadeInEntry(
                          delay: _areExtrasLoaded ? 0 : (index - crossAxisCount) * 30,
                          duration: _isRestoring ? Duration.zero : const Duration(milliseconds: 600),
                          child: SearchSeriesCard(
                            series: item,
                            number: null, // not showing top100 number
                            onTap: () => widget.onSeriesOpen(item),
                          ),
                        ),
                      );
                    }

                    // Only Preview Cards are shown
                    return SearchSeriesCard(
                      series: item,
                      number: null, // not showing top100 number
                      onTap: () => widget.onSeriesOpen(item),
                    );
                  },
                ),
              ),

              // Loading indicator at bottom of expanded section
              if (widget.isExpanded && widget.manager.isLoading && fullList.length > 6) const Padding(padding: EdgeInsets.all(20), child: Center(child: ProgressRing())),

              // Section Load More Button shown only after expand animation is complete and first batch of extras are loaded
              if (widget.isExpanded && _showLoadMoreAfterExpand && !widget.manager.isLoading && widget.manager.hasMore && !Provider.of<SettingsManager>(context).useInfiniteScroll)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: StandardButton.label(
                      onPressed: () {
                        log('Loading more for section ${widget.title}');
                        setState(() => _fetchingMore = true);
                        widget.manager.fetch().then((_) {
                          if (mounted) setState(() => _fetchingMore = false);
                          log('Finished loading more for section ${widget.title}');
                        });
                      },
                      isLoading: _fetchingMore,
                      isFilled: !_fetchingMore,
                      label: 'Load More',
                    ),
                  ),
                ),

              SizedBox(height: widget.isExpanded ? 50 : 30),
            ],
          );
        });
      },
    );
  }

  Widget _buildSectionHeader(String title, bool isExpanded) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isExpanded ? 0.0 : 1.0,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isExpanded ? 0.0 : null,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              if (!isExpanded)
                GestureDetector(
                  onTap: widget.onExpand,
                  child: const Text("View All", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedSectionWrapper extends StatelessWidget {
  final bool isHidden;
  final Widget child;

  const AnimatedSectionWrapper({
    super.key,
    required this.isHidden,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: child,
      secondChild: const SizedBox(width: double.infinity, height: 0),
      crossFadeState: isHidden ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
      sizeCurve: Curves.easeInOutQuart,
    );
  }
}

class FadeInEntry extends StatefulWidget {
  final Widget child;
  final int delay;
  final Duration duration;

  const FadeInEntry({
    super.key,
    required this.child,
    this.delay = 0,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<FadeInEntry> createState() => _FadeInEntryState();
}

class _FadeInEntryState extends State<FadeInEntry> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(FadeInEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) _controller.duration = widget.duration;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(opacity: _opacity, child: widget.child);
}
