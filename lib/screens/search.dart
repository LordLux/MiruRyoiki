import 'dart:math' show min;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart' hide TextBox;
import 'package:miruryoiki/utils/text.dart';
import 'package:provider/provider.dart';

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
import '../widgets/buttons/button.dart';
import '../widgets/page/search_template.dart';
import 'search_results.dart';

final GlobalKey<_BrowseScreenState> browseScreenKey = GlobalKey<_BrowseScreenState>();

class BrowseScreen extends StatefulWidget {
  final ScrollController scrollController;

  const BrowseScreen({super.key, required this.scrollController});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  // Navigation state
  bool _isSearchResultsVisible = false;
  bool _isFinishedTransitioningToResults = false;
  bool _isFinishedTransitioningToBrowse = true;
  
  // Search Results state
  String _searchQueryType = '';
  String _searchTitle = '';
  String? _searchQuery;
  Map<String, dynamic>? _searchFilters;

  void _showSearchResults({
    required String queryType,
    required String title,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) {
    final navigator = Provider.of<NavigationManager>(context, listen: false);
    navigator.pushPage("search_results:$queryType", title);
    
    setState(() {
      _searchQueryType = queryType;
      _searchTitle = title;
      _searchQuery = searchQuery;
      _searchFilters = filters;
      _isSearchResultsVisible = true;
      _isFinishedTransitioningToBrowse = false;
    });
  }

  void _hideSearchResults() {
    final navigator = Provider.of<NavigationManager>(context, listen: false);
    navigator.goBack();
    
    setState(() {
      _isSearchResultsVisible = false;
      _isFinishedTransitioningToResults = false;
    });
  }

  void _onEndTransition() {
    setState(() {
      if (_isSearchResultsVisible) {
        _isFinishedTransitioningToResults = true;
      } else {
        _isFinishedTransitioningToBrowse = true;
        _isFinishedTransitioningToResults = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Dashboard
        Offstage(
          offstage: _isSearchResultsVisible && _isFinishedTransitioningToResults,
          child: AnimatedOpacity(
            duration: mediumDuration,
            opacity: _isSearchResultsVisible ? 0.0 : 1.0,
            curve: Curves.ease,
            child: AbsorbPointer(
              absorbing: _isSearchResultsVisible,
              child: SearchScreen(
                scrollController: widget.scrollController,
                onShowSearchResults: _showSearchResults,
              ),
            ),
          ),
        ),

        // Search Results
        IgnorePointer(
          ignoring: !_isSearchResultsVisible,
          child: AbsorbPointer(
            absorbing: !_isSearchResultsVisible,
            child: AnimatedOpacity(
              duration: mediumDuration,
              opacity: _isSearchResultsVisible ? 1.0 : 0.0,
              curve: Curves.ease,
              onEnd: _onEndTransition,
              child: _isFinishedTransitioningToBrowse
                  ? const SizedBox.shrink()
                  : SearchResultsScreen(
                      queryType: _searchQueryType,
                      title: _searchTitle,
                      searchQuery: _searchQuery,
                      filters: _searchFilters,
                      onBack: _hideSearchResults,
                      onSeriesOpen: (_) {}, //TODO
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class SearchScreen extends StatefulWidget {
  final ScrollController scrollController;
  final Function({
    required String queryType,
    required String title,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) onShowSearchResults;

  const SearchScreen({
    super.key,
    required this.scrollController,
    required this.onShowSearchResults,
  });

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final TextStyle _searchTextStyle = Manager.smallSubtitleStyle.copyWith(fontWeight: FontWeight.w400);

  bool _isSearchFocused = false;
  double _textSearchWidth = 0.0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChange);
    _searchController.addListener(_onSearchTextChanged);
  }

  void _onSearchFocusChange() => setState(() => _isSearchFocused = _searchFocusNode.hasFocus);

  void _onSearchTextChanged() => setState(() => _textSearchWidth = measureTextWidth(_searchController.text, style: _searchTextStyle));

  void clearSearch() => _searchController.clear();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // for AutomaticKeepAliveClientMixin

    final library = Provider.of<Library>(context);
    final settings = Provider.of<SettingsManager>(context);

    // detect when user scrolls upwards (print up) or downwards (print down)
    return DeferredPointerHandler(
      child: SearchTemplatePage(
        header: Text('Browse', style: Manager.titleStyle),
        content: _buildContent(library, settings),
        searchBarCollapsedWidth: _textSearchWidth + 27,
        searchBarMaxCollapsedWidth: (maxConstrainedWidth) => min(maxConstrainedWidth, ScreenUtils.kMaxContentWidth) - 150,
        searchBar: (width, height, animationValue) {
          final bool isExpanded = animationValue < 0.2;
          final borderRadius = lerpDouble(8, 12, 1 - animationValue)!;
          final horizontalPadding = lerpDouble(12, 20, 1 - animationValue)!;
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              SizedBox(
                width: width,
                height: height == null ? null : height + 3,
                child: TextBox(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  cursorOpacityAnimates: true,
                  cursorColor: Manager.pastelAccentColor,
                  style: _searchTextStyle,
                  padding: EdgeInsetsDirectional.fromSTEB(horizontalPadding, 0, horizontalPadding, 0),
                  highlightColor: Colors.transparent,
                  unfocusedColor: Colors.transparent,
                  enableInteractiveSelection: true,
                  decoration: ButtonState.all(
                    BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(borderRadius),
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
                      widget.onShowSearchResults(
                        queryType: 'search',
                        title: 'Search Results: $value',
                        searchQuery: value,
                      );
                    }
                  },
                  onChanged: (value) {
                    // Handle search input changes
                  },
                ),
              ),
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
                child: isExpanded ? DeferPointer(child: const AnimeFilterHeader()) : const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(Library library, SettingsManager settings) {
    return Consumer<AnilistProvider>(
      builder: (context, anilistProvider, _) {
        return AnimeContentDashboard(onShowSearchResults: widget.onShowSearchResults);
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Using Wrap or ScrollView to handle responsiveness if screen is narrow
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // 2. Dropdowns
              _buildDropdown("Genres", _selectedGenre, ['Any', 'Action', 'Drama'], (v) => setState(() => _selectedGenre = v!)),
              const SizedBox(width: 16),
              _buildDropdown("Year", _selectedYear, ['Any', '2024', '2023'], (v) => setState(() => _selectedYear = v!)),
              const SizedBox(width: 16),
              _buildDropdown("Season", _selectedSeason, ['Any', 'Winter', 'Spring'], (v) => setState(() => _selectedSeason = v!)),
              const SizedBox(width: 16),
              _buildDropdown("Format", _selectedFormat, ['Any', 'TV Show', 'Movie'], (v) => setState(() => _selectedFormat = v!)),
              const SizedBox(width: 16),
              _buildDropdown("Airing Status", _selectedStatus, ['Any', 'Airing', 'Finished'], (v) => setState(() => _selectedStatus = v!)),

              const SizedBox(width: 24),

              // 3. Filter/List View Toggle Button (Far right in image)
              Padding(
                padding: const EdgeInsets.only(top: 24.0), // Align with inputs
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B222C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: StandardButton.icon(
                    icon: const Icon(Icons.tune, color: Colors.grey, size: 20),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper to build the Label + Input column
  Widget _buildHeaderItem({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  // Helper to build stylized Dropdowns
  Widget _buildDropdown(String label, String currentValue, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      width: 140,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B222C),
        borderRadius: BorderRadius.circular(8),
      ),
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

  const AnimeContentDashboard({super.key, required this.onShowSearchResults});

  @override
  State<AnimeContentDashboard> createState() => _AnimeContentDashboardState();
}

class _AnimeContentDashboardState extends State<AnimeContentDashboard> {
  late Future<AnilistSearchPage<AnilistAnime>?> _trendingFuture;
  late Future<AnilistSearchPage<AnilistAnime>?> _popularFuture;
  late Future<AnilistSearchPage<AnilistAnime>?> _upcomingFuture;
  late Future<AnilistSearchPage<AnilistAnime>?> _top100Future;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    final service = AnilistService();
    _trendingFuture = service.getTrendingNow();
    _popularFuture = service.getPopularThisSeason();
    _upcomingFuture = service.getUpcomingNextSeason();
    _top100Future = service.getTop100Anime();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection("TRENDING NOW", _trendingFuture, 'trending'),
            const SizedBox(height: 30),
            _buildSection("POPULAR THIS SEASON", _popularFuture, 'popular'),
            const SizedBox(height: 30),
            _buildSection("UPCOMING NEXT SEASON", _upcomingFuture, 'upcoming'),
            const SizedBox(height: 30),
            _buildSection("TOP 100 ANIME", _top100Future, 'top100'),
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
        SizedBox(
          height: 240,
          child: FutureBuilder<AnilistSearchPage<AnilistAnime>?>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) 
                return const Center(child: ProgressRing());
              

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
                        onPressed: () => setState(() => _fetchData()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final mediaList = snapshot.data?.results ?? [];

              if (mediaList.isEmpty) {
                return const Center(child: Text('No anime found'));
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: mediaList.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final item = mediaList[index];
                  return _buildAnimeCard(item);
                },
              );
            },
          ),
        ),
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

  Widget _buildAnimeCard(AnilistAnime anime) {
    final title = anime.title.userPreferred ?? 'Unknown Title';
    final coverImage = anime.posterImage ?? '';
    final colorHex = anime.dominantColor;
    final color = colorHex != null ? (Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000)) : Colors.blue;

    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // POSTER IMAGE
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: const Color(0xFF1B222C),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (coverImage.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: coverImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: const Color(0xFF1B222C)),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  // "Tag" (like the blue dot in the screenshot) - maybe use status or something?
                  if (anime.status == 'RELEASING')
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // TITLE
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFE1E1E1),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
