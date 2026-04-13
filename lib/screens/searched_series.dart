import 'dart:async';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:miruryoiki/models/anilist/anime_overview.dart';
import 'package:miruryoiki/models/anilist/page_info.dart';
import 'package:miruryoiki/widgets/acrylic_header.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../models/anilist/anime.dart';
import '../models/anilist/user_list.dart';
import '../services/connectivity/connectivity_service.dart';
import '../services/navigation/shortcuts.dart';
import '../utils/text.dart';
import '../widgets/buttons/back_button.dart';
import '../widgets/buttons/button.dart';
import '../enums.dart';
import '../manager.dart';
import '../services/anilist/linking.dart';
import '../utils/logging.dart';
import '../utils/error_handling.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import '../widgets/buttons/highlighted_button.dart';
import '../widgets/info_label_text.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/infobar.dart';
import '../widgets/page/page_template.dart';
import '../widgets/pill.dart';
import '../widgets/shrinker.dart';
import '../widgets/simple_html_parser.dart';
import '../widgets/transparency_shadow_image.dart';
import 'package:recase/recase.dart';
import '../widgets/series_download_view.dart';
import '../services/file_system/cache.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../utils/anilist_utils.dart';
import '../widgets/cards/dual_info_card.dart';
import '../widgets/dialogs/entry_editor.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../widgets/score_widget.dart';
import 'package:provider/provider.dart';
import 'settings.dart';

/// Duration for which AniList data is considered fresh and doesn't need refetching
const Duration kAnilistCacheDuration = Duration(days: 1);

Widget _kIdentityWrapper({required Widget child}) => child;

class SearchedSeriesScreen extends StatefulWidget {
  final String anilistUrl;
  final VoidCallback onBack;

  const SearchedSeriesScreen({
    super.key,
    required this.anilistUrl,
    required this.onBack,
  });

  @override
  SearchedSeriesScreenState createState() => SearchedSeriesScreenState();
}

class SearchedSeriesScreenState extends State<SearchedSeriesScreen> {
  int currentTabIndex = 0;
  late final SimpleHtmlParser parser;

  final ShrinkerController _descriptionController = ShrinkerController();

  bool isReloadingSeries = false;
  DeferredPointerHandlerLink? deferredPointerLink;
  final List<String> _tabNames = [];
  final List<Map<int, String>?> _pages = [];

  /// Cached reference to the current series, updated via Selector in build()
  AnimeOverview? _cachedSeries;

  // Per-tab data state
  final List<CharacterEdge> _allCharacters = [];
  AnilistPageInfo? _characterPageInfo;
  bool _loadingMoreCharacters = false;
  bool _charactersLoaded = false;

  final List<StaffEdge> _allStaff = [];
  AnilistPageInfo? _staffPageInfo;
  bool _loadingMoreStaff = false;
  bool _staffLoaded = false;

  final List<MediaListSocial> _allSocial = [];
  AnilistPageInfo? _socialPageInfo;
  bool _loadingMoreSocial = false;
  bool _socialLoaded = false;

  AnimeStatsFull? _statsData;
  bool _loadingStats = false;
  bool _statsLoaded = false;

  // Tab history state
  final Map<String, ScrollController> _tabScrollControllers = {};
  bool _restoringFromHistory = false;
  Map<String, dynamic>? _pendingViewState;

  ScrollController _getOrCreateController(String tabName) {
    return _tabScrollControllers.putIfAbsent(tabName, () => ScrollController());
  }

  // Widget: whether to allocate a full row or divide it in 2 columns [true = full row, false = 2 columns]
  Map<InfoLabel, bool> getInfos(AnimeOverview? series) {
    return {
      if (series?.format != null)
        InfoLabelText(
          label: 'Format',
          text: series!.format!,
        ): false,
      if (series?.episodes != null)
        InfoLabelText(
          label: 'Episodes',
          text: '${_cachedSeries!.episodes}',
        ): false,
      if (series?.duration != null)
        InfoLabelText(
          label: '${formatEpisodic.contains(series?.format) ? "Episode " : ""}Duration',
          text: '${_cachedSeries!.duration} mins',
        ): false,
      if (series?.status != null)
        InfoLabelText(
          label: 'Status',
          text: series!.status!.toAnimeStatus()?.name_ ?? series.status!,
        ): false,
      if (series?.startDate != null)
        InfoLabelText(
          label: 'Start Date',
          text: '${series!.startDate!.year}-${series.startDate!.month}-${series.startDate!.day}',
        ): false,
      if (series?.endDate != null)
        InfoLabelText(
          label: 'End Date',
          text: '${series!.endDate!.year}-${series.endDate!.month}-${series.endDate!.day}',
        ): false,
      if (series?.season != null)
        InfoLabelText(
          label: 'Season',
          text: '${series!.season!.toLowerCase().titleCase} ${series.seasonYear ?? ""}',
        ): false,
      if (series?.source != null)
        InfoLabelText(
          label: 'Source',
          text: series!.source!.replaceAll('_', ' ').titleCase,
        ): false,
      if (series?.averageScore != null)
        InfoLabelText(
          label: 'Average Score',
          text: '${series!.averageScore}%',
        ): false,
      if (series?.meanScore != null)
        InfoLabelText(
          label: 'Mean Score',
          text: '${series!.meanScore}%',
        ): false,
      if (series?.popularity != null)
        InfoLabelText(
          label: 'Popularity',
          text: '${series!.popularity}',
        ): false,
      if (series?.favourites != null)
        InfoLabelText(
          label: 'Favourites',
          text: '${series!.favourites}',
        ): false,
      if (series?.studios.isNotEmpty == true)
        InfoLabelText(
          label: 'Studios',
          text: series!.studios.where((s) => s.isMain).map((s) => s.name).join('\n'),
        ): true,
      if (series?.studios.isNotEmpty == true)
        InfoLabelText(
          label: 'Producers',
          text: series!.studios.where((s) => !s.isMain).map((s) => s.name).join('\n'),
        ): true,
      if (series?.hashtag != null)
        InfoLabelText(
          label: 'Hashtag',
          text: series!.hashtag!,
        ): false,
      // if (series?.genres != null && series!.genres.isNotEmpty)
      //   InfoLabel(
      //     label: 'Genres',
      //     labelStyle: Manager.bodyStrongStyle,
      //     child: Text(series.genres.join(', ')),
      //   ): true,
      if (series?.title.romaji != null)
        InfoLabelText(
          label: 'Romaji',
          text: series!.title.romaji!,
        ): true,
      if (series?.title.english != null)
        InfoLabelText(
          label: 'English',
          text: series!.title.english!,
        ): true,
      if (series?.title.native != null)
        InfoLabelText(
          label: 'Native',
          text: series!.title.native!,
        ): true,
      if (series?.synonyms.isNotEmpty == true)
        InfoLabelText(
          label: 'Synonyms',
          text: series!.synonyms.join('\n'),
        ): true,
    };
  }

  //

  @override
  void initState() {
    super.initState();
    deferredPointerLink = DeferredPointerHandlerLink();
    nextFrame(() => _loadAnilistData());
    parser = SimpleHtmlParser(context);

    // Listen for intra-page back/forward restores
    Manager.navigation.restoreNotifier.addListener(_onRestoreFromHistory);

    // Store pending viewState for deferred resolution after _initTabs
    final viewState = Manager.navigation.currentView?.viewState;
    if (viewState != null) _pendingViewState = viewState;
  }

  void _initTabs() {
    // Tabs
    final List<String> tabNames = [
      "Overview",
      if (_cachedSeries?.characters.isNotEmpty == true) "Characters",
      "Watch", // TODO: radarr/sonarr integration
      if (_cachedSeries?.staff.isNotEmpty == true) "Staff",
      if (_cachedSeries?.stats?.scoreDistribution.isNotEmpty == true && _cachedSeries?.stats?.statusDistribution.isNotEmpty == true) "Statistics",
      if (_cachedSeries?.following.isNotEmpty == true) "Social",
    ];

    // Pages
    List<Map<int, String>?> pages = [];
    for (int i = 0; i < tabNames.length; i++) {
      pages.add({i: tabNames[i]});
      if (i < tabNames.length - 1) pages.add(null);
    }

    _tabNames.addAll(tabNames);
    _pages.addAll(pages);

    // Set initial viewState on the navigation item so the original entry is restorable
    final currentView = Manager.navigation.currentView;
    if (currentView != null && currentView.viewState == null) {
      currentView.viewState = {
        'tabIndex': 0,
        'tabName': _tabNames.isNotEmpty ? _tabNames[0] : 'Overview',
        'mementos': <String, double>{},
      };
    }

    // Restore tab from pending viewState (re-entry after full page exit)
    if (_pendingViewState != null) {
      _restoringFromHistory = true;
      final tabName = _pendingViewState!['tabName'] as String?;
      final tabIndex = _pendingViewState!['tabIndex'] as int?;
      int targetIndex = 0;
      if (tabName != null && _tabNames.contains(tabName)) {
        targetIndex = _tabNames.indexOf(tabName);
      } else if (tabIndex != null) {
        targetIndex = tabIndex.clamp(0, _tabNames.length - 1);
      }
      if (targetIndex != 0) _onTabChanged(targetIndex);
      _restoringFromHistory = false;
      _pendingViewState = null;
    }
  }

  /// Called whenever the user selects a tab. Triggers lazy data loading
  void _onTabChanged(int index) {
    if (!mounted) return;
    if (index == currentTabIndex) return;

    // Push tab history unless we're restoring from back/forward
    if (!_restoringFromHistory) {
      _captureCurrentScrollOffset();
      final currentMementos = Map<String, double>.from(
        (Manager.navigation.currentView?.viewState?['mementos'] as Map?)?.cast<String, double>() ?? {},
      );
      Manager.navigation.pushTabState({
        'tabIndex': index,
        'tabName': _tabNames[index],
        'mementos': currentMementos,
      });
    }

    setState(() => currentTabIndex = index);
    if (index >= _tabNames.length) return;
    switch (_tabNames[index]) {
      case 'Characters':
        if (!_charactersLoaded && !_loadingMoreCharacters) _loadCharactersTab();
      case 'Staff':
        if (!_staffLoaded && !_loadingMoreStaff) _loadStaffTab();
      case 'Social':
        if (!_socialLoaded && !_loadingMoreSocial) _loadSocialTab();
      case 'Statistics':
        if (!_statsLoaded && !_loadingStats) _loadStatsTab();
    }
  }

  /// Saves the current tab's scroll offset into the current NavigationItem's viewState mementos
  void _captureCurrentScrollOffset() {
    if (currentTabIndex >= _tabNames.length) return;
    final tabName = _tabNames[currentTabIndex];
    final controller = _tabScrollControllers[tabName];
    if (controller != null && controller.hasClients) {
      final viewState = Manager.navigation.currentView?.viewState;
      if (viewState != null) {
        final mementos = (viewState['mementos'] as Map?)?.cast<String, double>() ?? <String, double>{};
        mementos[tabName] = controller.offset;
        viewState['mementos'] = mementos;
      }
    }
  }

  /// Handles intra-page back/forward restore events
  void _onRestoreFromHistory() {
    // Guard: only act if this screen is the current view
    final currentView = Manager.navigation.currentView;
    if (currentView == null || !currentView.id.startsWith('/searched_series:')) return;

    final viewState = currentView.viewState;
    if (viewState == null) return;

    // Capture current tab's scroll before switching
    _captureCurrentScrollOffset();

    final tabName = viewState['tabName'] as String?;
    final tabIndex = viewState['tabIndex'] as int?;

    // Resolve target index: prefer by name, fall back to clamped index
    int targetIndex;
    if (tabName != null && _tabNames.contains(tabName)) {
      targetIndex = _tabNames.indexOf(tabName);
    } else if (tabIndex != null) {
      targetIndex = tabIndex.clamp(0, _tabNames.length - 1);
    } else {
      return;
    }

    _restoringFromHistory = true;
    _onTabChanged(targetIndex);
    _restoringFromHistory = false;

    // Restore scroll offset for the target tab
    final mementos = (viewState['mementos'] as Map?)?.cast<String, double>();
    final targetTabName = tabName ?? (targetIndex < _tabNames.length ? _tabNames[targetIndex] : null);
    if (mementos != null && targetTabName != null) {
      final savedOffset = mementos[targetTabName];
      if (savedOffset != null && savedOffset > 0) {
        final controller = _getOrCreateController(targetTabName);
        nextFrame(() {
          if (mounted && controller.hasClients) {
            final max = controller.position.maxScrollExtent;
            controller.jumpTo(savedOffset.clamp(0.0, max));
          }
        });
      }
    }
  }

  /// Resets all per-tab state when navigating to a new series
  void _resetTabState() {
    currentTabIndex = 0;
    _tabNames.clear();
    _pages.clear();
    for (final c in _tabScrollControllers.values) c.dispose();
    _tabScrollControllers.clear();
    _allCharacters.clear();
    _characterPageInfo = null;
    _loadingMoreCharacters = false;
    _charactersLoaded = false;
    _allStaff.clear();
    _staffPageInfo = null;
    _loadingMoreStaff = false;
    _staffLoaded = false;
    _allSocial.clear();
    _socialPageInfo = null;
    _loadingMoreSocial = false;
    _socialLoaded = false;
    _statsData = null;
    _loadingStats = false;
    _statsLoaded = false;
  }

  //Tab data loaders
  Future<void> _loadCharactersTab({int page = 1}) async {
    if (!mounted || _cachedSeries == null) return;
    setState(() => _loadingMoreCharacters = true);

    final result = await SeriesLinkService().fetchAnimeCharacters(_cachedSeries!.id, page: page);
    if (!mounted) return;

    setState(() {
      _loadingMoreCharacters = false;
      _charactersLoaded = true;
      if (result != null) {
        _allCharacters.addAll(result.characters);
        _characterPageInfo = result.pageInfo;
      }
    });
  }

  Future<void> _loadStaffTab({int page = 1}) async {
    if (!mounted || _cachedSeries == null) return;
    setState(() => _loadingMoreStaff = true);

    final result = await SeriesLinkService().fetchAnimeStaff(_cachedSeries!.id, page: page);
    if (!mounted) return;

    setState(() {
      _loadingMoreStaff = false;
      _staffLoaded = true;
      if (result != null) {
        _allStaff.addAll(result.staff);
        _staffPageInfo = result.pageInfo;
      }
    });
  }

  Future<void> _loadSocialTab({int page = 1}) async {
    if (!mounted || _cachedSeries == null) return;
    setState(() => _loadingMoreSocial = true);

    final result = await SeriesLinkService().fetchAnimeSocial(_cachedSeries!.id, page: page);
    if (!mounted) return;

    setState(() {
      _loadingMoreSocial = false;
      _socialLoaded = true;
      if (result != null) {
        _allSocial.addAll(result.social);
        _socialPageInfo = result.pageInfo;
      }
    });
  }

  Future<void> _loadStatsTab() async {
    if (!mounted || _cachedSeries == null) return;
    setState(() => _loadingStats = true);

    final result = await SeriesLinkService().fetchAnimeStats(_cachedSeries!.id);
    if (!mounted) return;

    setState(() {
      _loadingStats = false;
      _statsLoaded = true;
      _statsData = result;
    });
  }

  @override
  didUpdateWidget(covariant SearchedSeriesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.anilistUrl != oldWidget.anilistUrl) {
      // Series changed, load new data
      deferredPointerLink ??= DeferredPointerHandlerLink();
      nextFrame(() => _loadAnilistData());
    }
  }

  @override
  void dispose() {
    Manager.navigation.restoreNotifier.removeListener(_onRestoreFromHistory);
    for (final c in _tabScrollControllers.values) c.dispose();
    deferredPointerLink?.dispose();
    super.dispose();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    // If series changes while dependencies change, reload Anilist data
    if (_cachedSeries != null && _cachedSeries!.id.toString() != widget.anilistUrl.split('/').last) {
      nextFrame(() => _loadAnilistData());
    }
  }

  ColorFilter get colorFilter => ColorFilter.matrix([
        // Scale down RGB channels (darken)
        0.7, 0, 0, 0, 0,
        0, 0.7, 0, 0, 0,
        0, 0, 0.7, 0, 0,
        0, 0, 0, 1, 0,
      ]);

  Future<ImageProvider?> _getAnilistImage({required bool banner}) async {
    final series = _cachedSeries;
    if (series == null) return null;

    final imageUrl = banner ? series.bannerImage : series.coverImage;
    if (imageUrl == null || imageUrl.isEmpty) return null;

    return await ImageCacheService().getImageProvider(imageUrl);
  }

  Future<void> _loadAnilistData() async {
    try {
      final anilistId = int.parse(widget.anilistUrl.split('/').last);
      logTrace('Fetching AniList data for ID $anilistId');

      final AnimeOverview? anilistAnime = await SeriesLinkService().fetchDetailedAnimeDetails(anilistId);
      if (!mounted) return;

      if (anilistAnime == null) {
        if (ConnectivityService().isOffline)
          logWarn('Failed to fetch AniList details for ID $anilistId: device is offline');
        else
          logErr('Failed to load Anilist data for ID: $anilistId');
        return;
      }

      Manager.currentDominantColor = anilistAnime.dominantColor?.fromHex();

      _resetTabState();
      _cachedSeries = anilistAnime;

      // Finalize UI
      _initTabs();
      Manager.setState();
    } catch (e) {
      if (!isExpectedOfflineError(e)) logErr('Failed to load Anilist data', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MiruRyoikiTemplatePage(
      headerWidget: _buildHeader(context, _cachedSeries),
      infobar: (_) => _buildInfoBar(context, _cachedSeries),
      content: _buildContent(context, _cachedSeries),
      backgroundColor: Manager.currentDominantColor,
      onHeaderCollapse: () => _descriptionController.collapse(),
      stickyHeader: buildHeader(45.0, ScreenUtils.kStatCardBorderRadius),
    );
  }

  HeaderWidget _buildHeader(BuildContext context, AnimeOverview? series) {
    final title = series?.title.userPreferred ?? '';
    final description = series?.description;
    final imageFuture = _getAnilistImage(banner: true);

    return HeaderWidget(
      image_widget: FutureBuilder(
        future: imageFuture,
        builder: (context, snapshot) {
          return Stack(
            children: [
              // Banner
              Container(
                height: ScreenUtils.kMaxHeaderHeight,
                width: double.infinity,
                // Background image
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (Manager.currentDominantColor ?? Manager.accentColor).withOpacity(0.27),
                      Colors.transparent,
                    ],
                  ),
                  image: _getBannerDecoration(snapshot.data),
                ),
                padding: const EdgeInsets.only(bottom: 16.0),
                alignment: Alignment.bottomLeft,
              ),
              // Back button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackButton(
                    onTap: widget.onBack,
                    label: 'Back to Browse',
                    child: const Icon(FluentIcons.back),
                  ),
                ],
              )
            ],
          );
        },
      ),
      colorFilter: null,
      titleLeftAligned: false,
      title: (style, constraints) => Text(title, style: style),
      children: [
        // Add description if available
        if (description != null) ...[
          VDiv(8),
          Shrinker(
            maxHeight: 150,
            minHeight: 45,
            controller: _descriptionController,
            child: parser.parse(description, selectable: true),
          ),
          VDiv(8),
        ],
      ],
    );
  }

  // Get the decoration image based on the banner image
  DecorationImage? _getBannerDecoration(imageProvider) {
    if (imageProvider == null) return null;

    return DecorationImage(
      alignment: Alignment.topCenter,
      image: imageProvider,
      fit: BoxFit.cover,
      isAntiAlias: true,
      colorFilter: colorFilter,
    );
  }

  MiruRyoikiInfobar _buildInfoBar(BuildContext context, AnimeOverview? series) {
    final posterImage = _getAnilistImage(banner: false);

    return MiruRyoikiInfobar(
      getPosterImage: posterImage,
      isProfilePicture: false,
      contentPadding: (posterExtraVertical) => EdgeInsets.only(left: 24.0, right: 24.0, bottom: 16.0, top: 16.0 + posterExtraVertical),
      setStateCallback: () {
        if (mounted) setState(() {});
      },
      content: _buildInfoBarContent(series),
      footerPadding: EdgeInsets.all(6.0),
      footer: [
        // Add to Library Button
        Builder(builder: (context) {
          final animeId = series?.id;
          return StandardButton(
            label: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(mat.Icons.library_add_outlined),
                HDiv(4),
                Text(
                  'Add to Library',
                  style: getStyleBasedOnAccent(false),
                ),
              ],
            ),
            expand: true,
            tooltip: 'Add the series to your library',
            onPressed: animeId == null
                ? null
                : () {
                    logTrace('Opening Anilist List Editor Dialog');
                    final s = series!;
                    final displayTitle = s.title.userPreferred ?? s.title.romaji ?? s.title.english ?? 'Unknown';
                    final anilist = Provider.of<AnilistProvider>(context, listen: false);
                    AnilistMediaListEntry? existing;
                    for (final list in anilist.userLists.values) {
                      final match = list.entries.firstWhereOrNull((e) => e.mediaId == s.id);
                      if (match != null) {
                        existing = match;
                        break;
                      }
                    }
                    showEntryEditorDialog(
                      context,
                      mediaId: s.id,
                      title: displayTitle,
                      totalEpisodes: s.episodes,
                      bannerImage: s.bannerImage,
                      coverImage: s.coverImage,
                      isFavourite: s.isFavourite,
                      entry: existing,
                    );
                  },
          );
        }),
        SizedBox(height: 6.0),
        // Open in Anilist Button
        Builder(builder: (context) {
          final animeId = series?.id;
          return StandardButton(
            label: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(mat.Icons.open_in_new),
                HDiv(4),
                Text(
                  'Open in Anilist',
                  style: getStyleBasedOnAccent(false),
                ),
              ],
            ),
            expand: true,
            tooltip: 'Open the series in Anilist.co',
            onPressed: animeId == null
                ? null
                : () {
                    logTrace('Opening anime in browser: $kAnilistBaseUrl/anime/$animeId');
                    openAnilistAnime(animeId);
                  },
          );
        }),
      ],
      poster: ({required imageProvider, required width, required height, required squareness, required offset}) {
        return SizedBox(
          height: height - offset,
          width: width,
          child: AnimatedContainer(
            duration: shortStickyHeaderDuration,
            width: width,
            height: height,
            child: Builder(builder: (context) {
              if (imageProvider != null)
                // Image available -> show it
                return Center(
                  child: ShadowedImage(
                    imageProvider: imageProvider,
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0), BlendMode.darken),
                    blurSigma: 0,
                    shadowColorOpacity: 0,
                  ),
                );

              // No image -> image icon
              return Center(child: Icon(FluentIcons.picture, size: 48, color: Colors.white));
            }),
          ),
        );
      },
    );
  }

  Widget _buildInfoBarContent(AnimeOverview? series) {
    final infos_ = getInfos(series);
    final genres = series?.genres ?? [];

    return SizedBox(
      width: double.infinity, // template takes care of constraints
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...() {
            final List<Widget> columnChildren = [];
            final entries = infos_.entries.toList();

            for (int i = 0; i < entries.length; i++) {
              final currentEntry = entries[i];
              final InfoLabel currentInfo = currentEntry.key;
              final bool isFullRow = currentEntry.value;

              if (isFullRow) {
                // Full width widget
                columnChildren.add(Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: currentInfo,
                ));
              } else {
                // Check if next widget also wants to share space
                if (i + 1 < entries.length && !entries[i + 1].value) {
                  // Both current and next are false, put them in a row
                  final InfoLabel nextInfo = entries[i + 1].key;
                  columnChildren.add(Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(child: currentInfo),
                        const SizedBox(width: 16.0),
                        Expanded(child: nextInfo),
                      ],
                    ),
                  ));
                  i++; // Skip the next item since we've already processed it
                } else {
                  // Current is false but next is true or doesn't exist, show as full width
                  columnChildren.add(Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: currentInfo,
                  ));
                }
              }
            }

            return columnChildren;
          }(),

          // Genre tags
          if (genres.isNotEmpty) ...[
            VDiv(16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: genres.map((genre) => FluentPill(text: genre)).toList(),
            ),
            SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AnimeOverview? series) {
    if (_tabNames.isEmpty || currentTabIndex >= _tabNames.length) {
      return _buildOverviewContent(context, series);
    }
    return switch (_tabNames[currentTabIndex]) {
      'Watch' => _buildWatchTabContent(context, series),
      'Characters' => _buildCharactersTabContent(context),
      'Staff' => _buildStaffTabContent(context),
      'Statistics' => _buildStatsTabContent(context),
      'Social' => _buildSocialTabContent(context),
      _ => _buildOverviewContent(context, series),
    };
  }

  Widget _buildWatchTabContent(BuildContext context, AnimeOverview? series) {
    if (series == null) return const Center(child: RepaintBoundary(child: mat.CircularProgressIndicator()));

    return SeriesDownloadView(animeId: series.id, animeTitle: series.title);
  }

  /// Shared smooth-scroll wrapper used by every tab
  Widget _buildScrollWrapper(String tabName, List<Widget> children) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: true, platform: TargetPlatform.windows, scrollbars: false),
        child: DynMouseScroll(
          controller: _getOrCreateController(tabName),
          stopScroll: KeyboardState.ctrlPressedNotifier,
          scrollSpeed: 1.0,
          enableSmoothScroll: Manager.animationsEnabled,
          durationMS: 350,
          animationCurve: Curves.easeOutQuint,
          builder: (context, controller, physics) {
            return ValueListenableBuilder(
              valueListenable: KeyboardState.ctrlPressedNotifier,
              builder: (context, isCtrlPressed, _) {
                return SingleChildScrollView(
                  controller: controller,
                  physics: isCtrlPressed ? const NeverScrollableScrollPhysics() : physics,
                  child: Column(children: children),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverviewContent(BuildContext context, AnimeOverview? series) {
    int? getTabIndex(String name) {
      final index = _tabNames.indexOf(name);
      return index != -1 ? index : null;
    }

    // Overview Content
    List<List<Widget>> sections = [];
    // Relations
    if (series?.relations.isNotEmpty == true) sections.add(buildRelationsSection(-1, series!.relations));
    // Characters
    if (series?.characters.isNotEmpty == true) {
      final index = getTabIndex("Characters");
      if (index != null) sections.add(buildCharactersSection(index, series!.characters));
    }
    // Staff
    if (series?.staff.isNotEmpty == true) {
      final index = getTabIndex("Staff");
      if (index != null) sections.add(buildStaffSection(index, series!.staff));
    }
    // Stats
    if (series?.stats?.scoreDistribution.isNotEmpty == true && series?.stats?.statusDistribution.isNotEmpty == true) {
      final index = getTabIndex("Statistics");
      if (index != null) sections.add(buildStatsSection(index, series!.stats!));
    }
    // Social
    if (series?.following.isNotEmpty == true) {
      final index = getTabIndex("Social");
      if (index != null) sections.add(buildSocialSection(index, series!.following));
    }
    // Recommendations
    if (series?.recommendations.isNotEmpty == true) sections.add(buildRecommendationsSection(series!.recommendations));

    final List<Widget> contents = sections.map((sectionWidgets) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SettingsCard(
          children: sectionWidgets,
          padding: EdgeInsets.only(top: 24.0, left: 32.0, right: 32.0, bottom: 32.0),
        ),
      );
    }).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: true, platform: TargetPlatform.windows, scrollbars: false),
        child: DynMouseScroll(
          controller: _getOrCreateController('Overview'),
          stopScroll: KeyboardState.ctrlPressedNotifier,
          scrollSpeed: 1.0,
          enableSmoothScroll: Manager.animationsEnabled,
          durationMS: 350,
          animationCurve: Curves.easeOutQuint,
          builder: (context, controller, physics) {
            return ValueListenableBuilder(
              valueListenable: KeyboardState.ctrlPressedNotifier,
              builder: (context, isCtrlPressed, _) {
                return SingleChildScrollView(
                  controller: controller,
                  physics: isCtrlPressed ? const NeverScrollableScrollPhysics() : physics,
                  child: Column(children: contents),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Full tab content builders
  Widget _buildCharactersTabContent(BuildContext context) {
    return _buildScrollWrapper('Characters', [
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SettingsCard(
          padding: const EdgeInsets.only(top: 24.0, left: 32.0, right: 32.0, bottom: 32.0),
          children: [
            Text('Characters', style: Manager.subtitleStyle),
            VDiv(16),
            if (_allCharacters.isEmpty && _loadingMoreCharacters)
              const Center(child: ProgressRing())
            else if (_allCharacters.isEmpty)
              Text('No characters found.', style: Manager.bodyStyle)
            else
              LayoutBuilder(builder: (context, constraints) {
                final double itemWidth = 300;
                final int crossAxisCount = (constraints.maxWidth / itemWidth).floor().clamp(1, 3);
                final double spacing = 12;
                final double itemHeight = 80;
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    mainAxisExtent: itemHeight,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _allCharacters.length,
                  itemBuilder: (context, index) {
                    final edge = _allCharacters[index];
                    final character = edge.node;
                    final va = edge.voiceActors.isNotEmpty ? edge.voiceActors.first : null;
                    return DualInfoCard(
                      nameLeft: character?.name ?? 'Unknown',
                      descLeft: edge.role?.titleCase ?? '',
                      imageLeft: character?.image ?? '',
                      nameRight: va?.name,
                      descRight: va?.language,
                      imageRight: va?.image,
                      onTap: character != null ? () => openAnilistCharacter(character.id) : null,
                    );
                  },
                );
              }),
            if (_characterPageInfo?.hasNextPage == true) ...[
              VDiv(16),
              if (_loadingMoreCharacters)
                const Center(child: ProgressRing())
              else
                Center(
                  child: StandardButton(
                    label: Text('Load more', style: Manager.bodyStyle),
                    onPressed: () => _loadCharactersTab(page: (_characterPageInfo!.currentPage) + 1),
                  ),
                ),
            ]
          ],
        ),
      ),
    ]);
  }

  Widget _buildStaffTabContent(BuildContext context) {
    return _buildScrollWrapper('Staff', [
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SettingsCard(
          padding: const EdgeInsets.only(top: 24.0, left: 32.0, right: 32.0, bottom: 32.0),
          children: [
            Text('Staff', style: Manager.subtitleStyle),
            VDiv(16),
            if (_allStaff.isEmpty && _loadingMoreStaff)
              const Center(child: ProgressRing())
            else if (_allStaff.isEmpty)
              Text('No staff found.', style: Manager.bodyStyle)
            else
              LayoutBuilder(builder: (context, constraints) {
                final double itemWidth = 300;
                final int crossAxisCount = (constraints.maxWidth / itemWidth).floor().clamp(1, 3);
                final double spacing = 12;
                final double itemHeight = 80;
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    mainAxisExtent: itemHeight,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _allStaff.length,
                  itemBuilder: (context, index) {
                    final edge = _allStaff[index];
                    final member = edge.node;
                    return DualInfoCard(
                      nameLeft: member?.name ?? 'Unknown',
                      descLeft: edge.role?.titleCase ?? '',
                      imageLeft: member?.image ?? '',
                      onTap: member != null ? () => openAnilistStaff(member.id) : null,
                    );
                  },
                );
              }),
            if (_staffPageInfo?.hasNextPage == true) ...[
              VDiv(16),
              if (_loadingMoreStaff)
                const Center(child: ProgressRing())
              else
                Center(
                  child: StandardButton(
                    label: Text('Load more', style: Manager.bodyStyle),
                    onPressed: () => _loadStaffTab(page: (_staffPageInfo!.currentPage) + 1),
                  ),
                ),
            ],
          ],
        ),
      ),
    ]);
  }

  Widget _buildSocialTabContent(BuildContext context) {
    return _buildScrollWrapper('Social', [
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SettingsCard(
          padding: const EdgeInsets.only(top: 24.0, left: 32.0, right: 32.0, bottom: 32.0),
          children: [
            Text('Social', style: Manager.subtitleStyle),
            VDiv(16),
            if (_allSocial.isEmpty && _loadingMoreSocial)
              const Center(child: ProgressRing())
            else if (_allSocial.isEmpty)
              Text('No activity found.', style: Manager.bodyStyle)
            else
              LayoutBuilder(builder: (context, constraints) {
                final double itemWidth = 300;
                final int crossAxisCount = (constraints.maxWidth / itemWidth).floor().clamp(1, 3);
                final double spacing = 12;
                final double itemHeight = 72;
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    mainAxisExtent: itemHeight,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _allSocial.length,
                  itemBuilder: (context, index) {
                    final entry = _allSocial[index];
                    final user = entry.user;
                    return GestureDetector(
                      onTap: user != null ? () => openAnilistUser(user.name) : null,
                      child: MouseRegion(
                        cursor: user != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
                        child: Container(
                          height: itemHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              ClipOval(
                                child: user?.avatar != null && user!.avatar!.isNotEmpty
                                    ? CachedNetworkImage(
                                        key: ValueKey('social_avatar_${user.id}'),
                                        imageUrl: user.avatar!,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) => const SizedBox(width: 40, height: 40, child: Icon(FluentIcons.contact, size: 20)),
                                      )
                                    : const SizedBox(width: 40, height: 40, child: Icon(FluentIcons.contact, size: 20)),
                              ),
                              const SizedBox(width: 10),
                              // Name + status
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(user?.name ?? 'Unknown', style: Manager.bodyStrongStyle, overflow: TextOverflow.ellipsis),
                                    if (entry.status != null) Text(entry.status!.replaceAll('_', ' ').titleCase, style: Manager.captionStyle, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              // Score + time
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (entry.score != null && entry.score! > 0)
                                    ScoreWidget(
                                      score: entry.score!.toInt(),
                                      format: Provider.of<AnilistProvider>(context, listen: false).scoreFormat,
                                      textStyle: Manager.bodyStyle,
                                    ),
                                  if (entry.updatedAt != null) Text(formatRelativeTime(DateTime.fromMillisecondsSinceEpoch(entry.updatedAt! * 1000)), style: Manager.captionStyle),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            if (_socialPageInfo?.hasNextPage == true) ...[
              VDiv(16),
              if (_loadingMoreSocial)
                const Center(child: ProgressRing())
              else
                Center(
                  child: StandardButton(
                    label: Text('Load more', style: Manager.bodyStyle),
                    onPressed: () => _loadSocialTab(page: (_socialPageInfo!.currentPage) + 1),
                  ),
                ),
            ],
          ],
        ),
      ),
    ]);
  }

  Widget _buildStatsTabContent(BuildContext context) {
    // Show overview stats immediately because they're already loaded
    // trends come after the tab fetch
    final AnimeStats? displayStats = _statsData ?? _cachedSeries?.stats;
    return _buildScrollWrapper('Statistics', [
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SettingsCard(
          padding: const EdgeInsets.only(top: 24.0, left: 32.0, right: 32.0, bottom: 32.0),
          children: [
            Text('Statistics', style: Manager.subtitleStyle),
            if (displayStats == null && _loadingStats) ...[
              VDiv(16),
              const Center(child: ProgressRing())
            ] else if (displayStats != null) ...[
              VDiv(24),
              Text('Score Distribution', style: Manager.bodyStrongStyle),
              VDiv(12),
              _buildScoreBarChart(displayStats.scoreDistribution),
              VDiv(24),
              Text('Status Distribution', style: Manager.bodyStrongStyle),
              VDiv(12),
              _buildStatusDistribution(displayStats.statusDistribution),
              if (_statsData != null && _statsData!.trends.isNotEmpty) ...[
                VDiv(24),
                Text('Score Trend', style: Manager.bodyStrongStyle),
                VDiv(12),
                _buildTrendsTable(_statsData!.trends),
              ] else if (_loadingStats) ...[
                VDiv(24),
                const Center(child: ProgressRing()),
              ],
            ]
          ],
        ),
      ),
    ]);
  }

  // Stats visualisation helpers
  Widget _buildScoreBarChart(List<ScoreDistribution> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    final sorted = [...data]..sort((a, b) => a.score.compareTo(b.score));
    final maxAmount = sorted.map((e) => e.amount).reduce(max);
    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: sorted.map((point) {
          final barHeight = maxAmount > 0 ? (point.amount / maxAmount) * 120.0 : 0.0;
          final accent = (Manager.currentDominantAccentColor ?? Manager.accentColor).light;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  point.amount > 0 ? point.amount.toString() : '',
                  style: Manager.captionStyle,
                  textAlign: TextAlign.center,
                ),
                Container(
                  height: barHeight,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.4 + 0.6 * (maxAmount > 0 ? point.amount / maxAmount : 0)),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(point.score.toString(), style: Manager.captionStyle, textAlign: TextAlign.center),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusDistribution(List<StatusDistribution> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    final sorted = [...data]..sort((a, b) => b.amount.compareTo(a.amount));
    final total = sorted.fold(0, (sum, e) => sum + e.amount);
    if (total == 0) return const SizedBox.shrink();

    const statusColors = {
      CurrentString: Color(0xFF3DB4F2),
      CompletedString: Color(0xFF4CAF50),
      DroppedString: Color(0xFFE53935),
      PausedString: Color(0xFFF6A623),
      PlanningString: Color(0xFF9E9E9E),
      RepeatingString: Color(0xFFAB47BC),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 16,
            child: Row(
              children: sorted.map((item) {
                return Flexible(
                  flex: item.amount,
                  child: Container(color: statusColors[item.status] ?? Colors.grey),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: sorted.map((item) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColors[item.status] ?? Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '${item.status.replaceAll('_', ' ').titleCase}: ${item.amount}',
                  style: Manager.captionStyle,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTrendsTable(List<AnimeTrend> trends) {
    final sorted = [...trends]..sort((a, b) => a.date.compareTo(b.date));
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.07)),
          children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), child: Text('Date', style: Manager.bodyStrongStyle)),
            Text('Episode', style: Manager.bodyStrongStyle, textAlign: TextAlign.center),
            Text('Avg Score', style: Manager.bodyStrongStyle, textAlign: TextAlign.center),
            Text('Watching', style: Manager.bodyStrongStyle, textAlign: TextAlign.center),
          ],
        ),
        ...sorted.map((t) {
          final date = DateTime.fromMillisecondsSinceEpoch(t.date * 1000);
          final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          return TableRow(
            children: [
              Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), child: Text(dateStr, style: Manager.captionStyle)),
              Text(t.episode?.toString() ?? '–', style: Manager.captionStyle, textAlign: TextAlign.center),
              Text(t.averageScore != null ? '${t.averageScore}%' : '–', style: Manager.captionStyle, textAlign: TextAlign.center),
              Text(t.inProgress?.toString() ?? '–', style: Manager.captionStyle, textAlign: TextAlign.center),
            ],
          );
        }),
      ],
    );
  }

  List<Widget> buildRelationsSection(int _, List<RelationEdge> relations) {
    return [
      Text('Relations', style: Manager.subtitleStyle),
      VDiv(16),
      LayoutBuilder(
        builder: (context, constraints) {
          final double spacing = 12;
          final double minItemWidth = 100;

          final int crossAxisCount = ((constraints.maxWidth + spacing) / (minItemWidth + spacing)).floor().clamp(1, 20);
          final double itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

          final double totalHeight = itemWidth / ScreenUtils.kDefaultAspectRatio;
          final int rows = (relations.length / crossAxisCount).ceil();

          return SizedBox(
            height: rows * totalHeight + (rows > 0 ? (rows - 1) * spacing : 0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                childAspectRatio: ScreenUtils.kDefaultAspectRatio,
              ),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: relations.length,
              itemBuilder: (context, index) {
                final relation = relations[index];
                final node = relation.node;
                final bool isAnime = node != null && formatAnime.contains(node.format);
                final MediaFormat mediaFormat = MediaFormatX.fromString(node?.format); // TODO extract this into standalone widget + custom appearance based on media format -> manga volumes should have a book icon; anime should have a tv, movies shouldh ave a clapperboard

                return ClipRRect(
                  borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
                  child: MouseRegion(
                    cursor: node != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
                    child: Stack(
                      children: [
                        // Cover Image
                        mat.Ink(
                          color: Colors.transparent,
                          child: node?.coverImage != null && node!.coverImage!.isNotEmpty
                              ? CachedNetworkImage(
                                  key: ValueKey('relation_${node.id}'),
                                  imageUrl: node.coverImage!,
                                  width: itemWidth,
                                  height: totalHeight,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(
                                    width: itemWidth,
                                    height: totalHeight,
                                    color: Colors.grey[130],
                                    child: const Center(child: Icon(FluentIcons.photo2, size: 24)),
                                  ),
                                )
                              : Container(
                                  width: itemWidth,
                                  height: totalHeight,
                                  color: Colors.grey[130],
                                  child: const Center(child: Icon(FluentIcons.photo2, size: 24)),
                                ),
                        ),
                        // Relation type + format label
                        Positioned(
                          bottom: 0,
                          child: Container(
                            color: Colors.black.withOpacity(.5),
                            height: 35,
                            width: itemWidth,
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (mediaFormat.icon != null) ...[
                                    Icon(
                                      mediaFormat.icon,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    HDiv(4),
                                  ],
                                  Flexible(
                                    child: Text(
                                      relation.relationType.name_,
                                      style: Manager.bodyStyle,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: mat.Material(
                            color: Colors.transparent,
                            child: mat.InkWell(
                              onTap: node != null
                                  ? isAnime
                                      ? () => navigateToSeries(node)
                                      : () => openAnilistManga(node.id)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    ];
  }

  List<Widget> _buildGridSection<T>({
    required String title,
    required List<T> items,
    required Widget Function(BuildContext, T) itemBuilder,
    VoidCallback? onHeaderPressed,
  }) {
    return [
      HighlightedButton(
        title: Text(title, style: Manager.subtitleStyle),
        onPressed: onHeaderPressed,
      ),
      VDiv(16),
      LayoutBuilder(builder: (context, constraints) {
        final double itemWidth = 300;
        final int crossAxisCount = (constraints.maxWidth / itemWidth).floor().clamp(1, 3);
        final double spacing = 12;
        final double itemHeight = 80;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            mainAxisExtent: itemHeight,
          ),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) => itemBuilder(context, items[index]),
        );
      }),
    ];
  }

  List<Widget> buildCharactersSection(int index, List<CharacterEdge> characters) {
    return _buildGridSection(
      title: 'Characters',
      items: characters.take(6).toList(),
      onHeaderPressed: () => _onTabChanged(index),
      itemBuilder: (context, characterEdge) {
        final character = characterEdge.node;
        final voiceActor = characterEdge.voiceActors.isNotEmpty ? characterEdge.voiceActors.first : null;

        return DualInfoCard(
          nameLeft: character?.name ?? 'Unknown',
          descLeft: characterEdge.role?.titleCase ?? '',
          imageLeft: character?.image ?? '',
          nameRight: voiceActor?.name,
          descRight: voiceActor?.language,
          imageRight: voiceActor?.image,
          onTap: character != null ? () => openAnilistCharacter(character.id) : null,
        );
      },
    );
  }

  List<Widget> buildStaffSection(int index, List<StaffEdge> staff) {
    return _buildGridSection(
      title: 'Staff',
      items: staff.take(3).toList(),
      onHeaderPressed: () => _onTabChanged(index),
      itemBuilder: (context, staffEdge) {
        final staffMember = staffEdge.node;
        return DualInfoCard(
          nameLeft: staffMember?.name ?? 'Unknown',
          descLeft: staffEdge.role?.titleCase ?? '',
          imageLeft: staffMember?.image ?? '',
          onTap: staffMember != null ? () => openAnilistStaff(staffMember.id) : null,
        );
      },
    );
  }

  List<Widget> buildStatsSection(int index, AnimeStats stats) {
    return [
      HighlightedButton(
        title: Text('Statistics', style: Manager.subtitleStyle),
        onPressed: () => _onTabChanged(index),
      ),
      VDiv(16),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Score Distribution', style: Manager.bodyStrongStyle),
                VDiv(8),
                _buildScoreBarChart(stats.scoreDistribution),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status Distribution', style: Manager.bodyStrongStyle),
                VDiv(8),
                _buildStatusDistribution(stats.statusDistribution),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> buildSocialSection(int index, List<MediaListFollowing> following) {
    return _buildGridSection(
      title: 'Social',
      items: following.take(6).toList(),
      onHeaderPressed: () => _onTabChanged(index),
      itemBuilder: (context, user) {
        return DualInfoCard(
          nameLeft: user.user?.name ?? 'Unknown',
          descLeft: '',
          imageLeft: user.user?.avatar ?? '',
          onTap: user.user != null ? () => openAnilistUser(user.user!.name) : null,
        );
      },
    );
  }

  List<Widget> buildRecommendationsSection(List<RecommendationNode> recommendations) {
    return [
      Text('Recommendations', style: Manager.subtitleStyle),
      VDiv(16),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: recommendations.take(6).map((rec) {
          return GestureDetector(
            onTap: rec.mediaRecommendation != null ? () => navigateToSeries(rec.mediaRecommendation!) : null,
            child: MouseRegion(
              cursor: rec.mediaRecommendation != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
              child: SizedBox(
                width: 120,
                child: Column(
                  children: [
                    rec.mediaRecommendation?.coverImage != null && rec.mediaRecommendation!.coverImage!.isNotEmpty
                        ? CachedNetworkImage(
                            key: ValueKey('rec_${rec.mediaRecommendation!.id}'),
                            imageUrl: rec.mediaRecommendation!.coverImage!,
                            width: 100,
                            height: 150,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              width: 100,
                              height: 150,
                              color: Colors.grey[130],
                              child: const Center(child: Icon(FluentIcons.photo2, size: 24)),
                            ),
                          )
                        : Container(
                            width: 100,
                            height: 150,
                            color: Colors.grey[130],
                            child: const Center(child: Icon(FluentIcons.photo2, size: 24)),
                          ),
                    VDiv(8),
                    Text(
                      rec.mediaRecommendation?.title.userPreferred ?? '',
                      style: Manager.bodyStyle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ];
  }

  Widget buildHeader(double headerHeight, double borderRadius) {
    return Container(
      height: headerHeight,
      margin: EdgeInsets.all(.5),
      constraints: BoxConstraints(maxHeight: headerHeight),
      child: AcrylicHeader(
        borderRadius: BorderRadius.circular(borderRadius),
        useFrostedNoise: false,
        useAcrylic: false,
        padding: EdgeInsets.all(0.001),
        child: LayoutBuilder(builder: (context, constraints) {
          final pages = _pages.whereNot((p) => p == null).toList();
          final threshold = 500.0;
          final sepMargin = 4.0;

          return Stack(
            children: [
              Positioned.fill(
                child: Builder(builder: (context) {
                  Widget tab(bool isFirst, bool isLast, double extra, String page, Widget Function({required Widget child})? wrapper) {
                    wrapper ??= _kIdentityWrapper;
                    final width = ((threshold - 25) - (isFirst || isLast ? (extra * 2) : 0) - (sepMargin * (pages.length - 1))) / pages.length + extra;
                    return wrapper(
                      child: SizedBox(
                        width: width,
                        height: headerHeight,
                        child: mat.InkWell(
                          borderRadius: BorderRadius.circular(4),
                          onTap: () {
                            logTrace('Clicked on tab: $page');
                            final pageIndex = _tabNames.indexOf(page);
                            if (pageIndex != -1) _onTabChanged(pageIndex);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (!isFirst) SizedBox.shrink() else SizedBox(width: extra),
                              Text(page, style: Manager.captionStyle, textAlign: TextAlign.center),
                              if (!isLast) SizedBox.shrink() else SizedBox(width: extra),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  Widget builder(Widget Function({required Widget child})? wrapper) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _pages.map((page) {
                        final isFirst = _pages.indexOf(page) == 0;
                        final isSeparator = page == null;
                        final isLast = _pages.indexOf(page) == _pages.length - 1;
                        final extra = 0.0;

                        // Separator
                        if (isSeparator) return Container(width: 1, height: 24, margin: EdgeInsets.symmetric(horizontal: sepMargin), color: Colors.white.withOpacity(0.2));

                        // Normal tab
                        return tab(isFirst, isLast, extra, page.values.first, wrapper);
                      }).toList(),
                    );
                  }

                  // Decide layout based on available width
                  if (constraints.maxWidth >= threshold)
                    // Full row when enough width
                    return builder(({required Widget child}) => Expanded(child: child));
                  else
                    // Scrollable list when width is limited
                    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: builder(null));
                }),
              ),
              // Tab Indicator
              if (_cachedSeries != null)
                Positioned.fill(
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Builder(builder: (context) {
                      final tabWidth = (max(constraints.maxWidth, threshold)) / (pages.length);
                      // final tabIndicatorWidth = min(tabWidth - 32, measureTextWidth(pages[currentTabIndex]!.values.first, style: Manager.captionStyle) + 16);
                      var sidePadding = 32;
                      final tempWidth = tabWidth - (sidePadding * 2);
                      var tabIndicatorWidth = tempWidth;
                      if (tempWidth < 30) {
                        tabIndicatorWidth = 30;
                        sidePadding = max((tabWidth - tabIndicatorWidth) ~/ 2, 0);
                      }
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeInOut,
                        height: 3,
                        width: tabIndicatorWidth,
                        margin: EdgeInsets.only(
                          // left: currentTabIndex * tabWidth + (tabWidth / 2) - (tabIndicatorWidth / 2) - (((pages.length / 2) - currentTabIndex) * 2),
                          left: (currentTabIndex * tabWidth) + sidePadding,
                        ),
                        decoration: BoxDecoration(
                          color: (Manager.currentDominantAccentColor ?? Manager.accentColor).light.withOpacity(0.5),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
