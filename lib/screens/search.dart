import 'dart:math' show min;
import 'dart:ui';

import 'package:defer_pointer/defer_pointer.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart' hide TextBox;
import 'package:miruryoiki/utils/text.dart';
import 'package:provider/provider.dart';

import '../services/library/library_provider.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../settings.dart';
import '../manager.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import '../widgets/buttons/button.dart';
import '../widgets/page/search_template.dart';

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
        return AnimeContentDashboard();
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
  const AnimeContentDashboard({super.key});

  @override
  State<AnimeContentDashboard> createState() => _AnimeContentDashboardState();
}

class _AnimeContentDashboardState extends State<AnimeContentDashboard> {
  // Mock Data
  final List<Map<String, dynamic>> _trendingAnime = [
    {'title': 'My Gift Lvl 9999', 'color': Colors.blueAccent},
    {'title': 'May I Ask for One Final Thing?', 'color': Colors.redAccent},
    {'title': 'SANDA', 'color': Colors.teal},
    {'title': 'TOUGEN ANKI', 'color': Colors.orangeAccent},
    {'title': 'Gachiakuta', 'color': Colors.purpleAccent},
    {'title': 'ONE PIECE', 'color': Colors.amber},
  ];

  final List<Map<String, dynamic>> _popularAnime = [
    {'title': 'One-Punch Man', 'color': Colors.yellow},
    {'title': 'SPY x FAMILY', 'color': Colors.pinkAccent},
    {'title': 'My Hero Academia', 'color': Colors.greenAccent},
    {'title': 'Assassin Status', 'color': Colors.indigoAccent},
    {'title': 'To Your Eternity', 'color': Colors.brown},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("TRENDING NOW"),
            _buildHorizontalList(_trendingAnime),

            const SizedBox(height: 30),

            _buildSectionHeader("POPULAR THIS SEASON"),
            _buildHorizontalList(_popularAnime),

            const SizedBox(height: 30),

            _buildSectionHeader("UPCOMING NEXT SEASON"),
            _buildHorizontalList(_trendingAnime.reversed.toList()), // Reusing list for mock

            const SizedBox(height: 30),

            _buildSectionHeader("FEDE MEGA GAY"),
            _buildHorizontalList(_popularAnime.reversed.toList()), // Reusing list for mock

            const SizedBox(height: 50), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
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
          const Text(
            "View All",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<Map<String, dynamic>> data) {
    return SizedBox(
      height: 240, // Height for Image + Text
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = data[index];
          return _buildAnimeCard(item['title'], item['color']);
        },
      ),
    );
  }

  Widget _buildAnimeCard(String title, Color mockColor) {
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
                // Using a gradient to mock an image
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [mockColor.withOpacity(0.6), mockColor],
                ),
              ),
              child: Stack(
                children: [
                  // Mock content inside image
                  Center(
                    child: Icon(Icons.image, color: Colors.white.withOpacity(0.5), size: 40),
                  ),
                  // Mock "Tag" (like the blue dot in the screenshot)
                  if (title.length % 2 == 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.lightBlueAccent,
                          shape: BoxShape.circle,
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
