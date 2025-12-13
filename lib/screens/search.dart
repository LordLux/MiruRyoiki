import 'dart:math' show min;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart' hide TextBox;
import 'package:miruryoiki/utils/text.dart';
import 'package:miruryoiki/widgets/animated_translate.dart';
import 'package:miruryoiki/widgets/widget_alpha_mask.dart';
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
import '../widgets/buttons/button.dart';
import '../widgets/cards/sarch_series_card.dart';
import '../widgets/fading_edge_scrollview.dart';
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

  void _onSeriesOpen(AnilistAnime anime) {
    final navigator = Provider.of<NavigationManager>(context, listen: false);
    navigator.pushPage("search:series:${anime.id}", anime.title.userPreferred ?? 'Anime Details');
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
                onSeriesOpen: _onSeriesOpen,
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
                      onSeriesOpen: _onSeriesOpen,
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
  final Function(AnilistAnime anime) onSeriesOpen;

  const SearchScreen({
    super.key,
    required this.scrollController,
    required this.onShowSearchResults,
    required this.onSeriesOpen,
  });

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final TextStyle _searchTextStyle = Manager.smallSubtitleStyle.copyWith(fontWeight: FontWeight.w400);

  DeferredPointerHandlerLink? deferredPointerLink;

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
    deferredPointerLink?.dispose();
    super.dispose();
  }

  final List<String> _demoImages = [
    "https://cdn.akamai.steamstatic.com/steam/apps/400/header.jpg", // Portal
    "https://cdn.akamai.steamstatic.com/steam/apps/730/header.jpg", // CS:GO
    "https://cdn.akamai.steamstatic.com/steam/apps/570/header.jpg", // Dota 2
    "https://cdn.akamai.steamstatic.com/steam/apps/271590/header.jpg", // GTA V
    "https://cdn.akamai.steamstatic.com/steam/apps/1172470/header.jpg", // Apex
    "https://cdn.akamai.steamstatic.com/steam/apps/1091500/header.jpg", // Cyberpunk
    "https://cdn.akamai.steamstatic.com/steam/apps/1245620/header.jpg", // Elden Ring
    "https://cdn.akamai.steamstatic.com/steam/apps/440/header.jpg", // TF2
  ];

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
              // fadeEdges: const EdgeInsets.only(top: 300, bottom: 300),
              gradientStops: [0.0, 0.05, 0.15, 0.85, 0.95, 1.0],
              gradientColors: [
                Colors.black.withOpacity(0),
                Colors.black.withOpacity(0.75),
                Colors.black,
                Colors.black,
                Colors.black.withOpacity(0.75),
                Colors.black.withOpacity(0),
              ],
              child: FadingEdgeScrollView(
                // fadeEdges: const EdgeInsets.only(top: 100, bottom: 300),
                gradientStops: [0.0, 0.1, 0.13, 0.7, 0.75, 1.0],
                gradientColors: [
                  Colors.black.withOpacity(0),
                  Colors.black.withOpacity(0.25),
                  Colors.black,
                  Colors.black,
                  Colors.black.withOpacity(0.25),
                  Colors.black.withOpacity(0),
                ],
                child: Opacity(
                  opacity: (1.0 - _animationValue).clamp(0.0, 0.5),
                  child: SearchLibraryShelfDisplay(
                    imageUrls: _demoImages, // Using dummy images
                    verticalOffset: -50 * _animationValue,
                  ),
                ),
              ),
            ),
          ),
          SearchTemplatePage(
            header: Text('Browse', style: Manager.titleStyle),
            behindSearchBar: (animationValue) {
              if (_animationValue != animationValue) nextFrame(() => setState(() => _animationValue = animationValue));
              return SizedBox.shrink();
            },
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
                          color: Colors.white.withOpacity(0.25),
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
        ],
      ),
    );
  }

  Widget _buildContent(Library library, SettingsManager settings) {
    return Consumer<AnilistProvider>(
      builder: (context, anilistProvider, _) {
        return AnimeContentDashboard(onShowSearchResults: widget.onShowSearchResults, onSeriesOpen: widget.onSeriesOpen);
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
  final Function(AnilistAnime anime) onSeriesOpen;

  const AnimeContentDashboard({
    super.key,
    required this.onShowSearchResults,
    required this.onSeriesOpen,
  });

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
        LayoutBuilder(builder: (context, constraints) {
          final int count = ScreenUtils.crossAxisCount(constraints.maxWidth);
          final double cardHeight = ScreenUtils.maxCardHeight;
          final double sectionHeight = cardHeight + 60;

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
                          onPressed: () => setState(() => _fetchData()),
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
            rows: rows, // How many rows of images to show
            speed: reverseAnimation ? -15.0 : 20.0, // Different speeds/directions
            angle: -0.2, // The slant angle
            verticalOffset: verticalOffset,
          ),
        ),
      );
    });
  }
}

class Slanted3DGrid extends StatelessWidget {
  final List<String> images;
  final int rows;
  final double speed;
  final double angle;
  final double verticalOffset;

  const Slanted3DGrid({
    super.key,
    required this.images,
    this.rows = 4,
    this.speed = 20.0, // Pixels per second
    this.angle = -0.1, // Rotation Z
    this.verticalOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
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
            ..translate(0.0, verticalOffset, 0.0)
            ..rotateX(-0.4)
            ..rotateY(0.1)
            ..rotateZ(angle)
            ..scale(1.6)
            ..translate(0.0, -200.0, 0.0),
          child: SizedBox(
            width: width,
            height: height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(rows, (rowIndex) {
                // Alternate speeds for parallax effect
                final double rowSpeed = (rowIndex % 2 == 0) ? speed : speed * 0.5;
                final bool isReverse = rowIndex % 2 != 0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: gap / 2),
                  child: SizedBox(
                    height: imageHeight,
                    child: Marquee(
                      startPadding: rowIndex * (imageWidth + gap) / 2,
                      velocity: rowSpeed,
                      containerExtent: (imageWidth + gap) * images.length,
                      blankSpace: 0,
                      child: Row(
                        children: images.map((imgUrl) {
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
