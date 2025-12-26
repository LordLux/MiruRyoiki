import 'dart:async';
import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:miruryoiki/widgets/acrylic_header.dart';
import 'package:provider/provider.dart';
import 'package:defer_pointer/defer_pointer.dart';

import '../main.dart';
import '../models/anilist/anime.dart';
import '../services/connectivity/connectivity_service.dart';
import '../services/library/library_provider.dart';
import '../services/lock_manager.dart';
import '../services/navigation/show_info.dart';
import '../services/navigation/statusbar.dart';
import '../utils/color.dart';
import '../utils/path.dart';
import '../utils/shell.dart';
import '../utils/text.dart';
import '../widgets/animated_color_wrapper.dart';
import '../widgets/buttons/back_button.dart';
import '../widgets/buttons/button.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../widgets/dialogs/link_anilist.dart';
import '../widgets/dialogs/image_select.dart';
import '../enums.dart';
import '../manager.dart';
import '../models/anilist/mapping.dart';
import '../models/series.dart';
import '../services/anilist/linking.dart';
import '../services/navigation/dialogs.dart';
import '../services/navigation/shortcuts.dart';
import '../utils/logging.dart';
import '../utils/error_handling.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/infobar.dart';
import '../widgets/page/page_template.dart';
import '../widgets/cards/mapping_card.dart';
import '../widgets/shift_clickable_hover.dart';
import '../widgets/shrinker.dart';
import '../widgets/simple_html_parser.dart';
import '../widgets/transparency_shadow_image.dart';
import '../models/mapping_target.dart';
import '../services/navigation/navigation.dart';
import 'package:recase/recase.dart';
import 'dart:io';
import '../services/file_system/cache.dart';
import '../widgets/viewtype_switcher.dart';
import 'anilist_settings.dart';
import '../models/episode.dart';
import '../widgets/episode_grid.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Duration for which AniList data is considered fresh and doesn't need refetching
const Duration kAnilistCacheDuration = Duration(days: 1);

/// Wrapper that manages navigation between SeriesScreen (grid of mappings) and InnerSeriesScreen (single mapping)
class SeriesScreenContainer extends StatefulWidget {
  final PathString? seriesPath;
  final VoidCallback onBack;

  const SeriesScreenContainer({
    super.key,
    required this.seriesPath,
    required this.onBack,
  });

  @override
  SeriesScreenContainerState createState() => SeriesScreenContainerState();
}

class SeriesScreenContainerState extends State<SeriesScreenContainer> {
  AnilistMapping? _selectedMapping;
  MappingTarget? _selectedTarget;

  final GlobalKey<SeriesScreenState> _seriesScreenKey = GlobalKey<SeriesScreenState>();

  /// Get the isReloadingSeries property from the currently active screen
  bool get isReloadingSeries => _seriesScreenKey.currentState?.isReloadingSeries ?? false;

  GlobalKey<SeriesScreenState>? get seriesScreenKey => _seriesScreenKey;

  /// Check if we're currently showing the inner series screen
  bool get isShowingInnerScreen => _selectedMapping != null && _selectedTarget != null;

  void navigateToMapping(AnilistMapping mapping, MappingTarget target) {
    if (!mounted) return;

    final navManager = Provider.of<NavigationManager>(context, listen: false);
    final mappingName = target.displayName;

    // Push the inner mapping page to navigation stack
    navManager.pushPage(
      'mapping:${mapping.localPath}',
      mappingName,
      data: mapping.localPath,
    );

    setState(() {
      _selectedMapping = mapping;
      _selectedTarget = target;
      // Save the series color if not already saved, then set the mapping color as current
      Manager.seriesDominantColor ??= Manager.currentDominantColor ?? Manager.accentColor;
      Manager.currentDominantColor = mapping.effectivePrimaryColorSync() ?? Manager.seriesDominantColor ?? Manager.accentColor;
    });
  }

  void exitMapping() {
    if (!mounted) return;

    final navManager = Provider.of<NavigationManager>(context, listen: false);

    // Pop the mapping page from navigation stack
    if (navManager.currentView?.level == NavigationLevel.page && navManager.currentView?.id.startsWith('mapping:') == true) {
      navManager.goBack();
    }

    setState(() {
      _selectedMapping = null;
      _selectedTarget = null;
      // Restore the series color from seriesDominantColor
      Manager.currentDominantColor = Manager.seriesDominantColor ?? Manager.accentColor;
    });

    Manager.setState();
  }

  @override
  Widget build(BuildContext context) {
    return SeriesScreen(
      key: _seriesScreenKey,
      seriesPath: widget.seriesPath,
      onBack: isShowingInnerScreen ? exitMapping : widget.onBack,
      onNavigateToMapping: navigateToMapping,
      target: _selectedTarget,
      mapping: _selectedMapping,
    );
  }
}

class SeriesScreen extends StatefulWidget {
  final PathString? seriesPath;
  final VoidCallback onBack;
  final Function(AnilistMapping mapping, MappingTarget target)? onNavigateToMapping;
  final MappingTarget? target;
  final AnilistMapping? mapping;

  const SeriesScreen({
    super.key,
    required this.seriesPath,
    required this.onBack,
    this.onNavigateToMapping,
    this.target,
    this.mapping,
  });

  @override
  SeriesScreenState createState() => SeriesScreenState();
}

class SeriesScreenState extends State<SeriesScreen> {
  late final SimpleHtmlParser parser;

  final ShrinkerController _descriptionController = ShrinkerController();

  bool posterChangeDisabled = false;
  bool bannerChangeDisabled = false;

  bool isReloadingSeries = false;

  bool _isPosterHovering = false;
  bool _isBannerHovering = false;
  DeferredPointerHandlerLink? deferredPointerLink;

  /// Cached reference to the current series, updated via Selector in build()
  Series? _cachedSeries;
  AnilistMapping? _cachedMapping;

  ViewType _currentViewType = ViewType.grid;

  late Color _textColor;
  late Color _selectedTextColor;

  bool get isMappingMode => widget.target != null;

  // Color? dominantColor;

  // Widget: whether to allocate a full row or divide it in 2 columns [true = full row, false = 2 columns]
  Map<InfoLabel, bool> infos(Series series) {
    if (isMappingMode && widget.target != null) {
      return {
        if (widget.target!.isSeason)
          InfoLabel(
            label: 'Episodes',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('${widget.target!.episodes.length}'),
          ): false,
        if (_cachedMapping?.anilistData?.status != null)
          InfoLabel(
            label: 'Status',
            labelStyle: Manager.bodyStrongStyle,
            child: Text(_cachedMapping!.anilistData!.status!.toAnimeStatus()?.name_ ?? _cachedMapping!.anilistData!.status!),
          ): false,
        if (_cachedMapping?.anilistData?.format != null)
          InfoLabel(
            label: 'Format',
            labelStyle: Manager.bodyStrongStyle,
            child: Text(_cachedMapping!.anilistData!.format!),
          ): false,
        if (_cachedMapping?.anilistData?.seasonYear != null)
          InfoLabel(
            label: 'Year',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('${_cachedMapping!.anilistData!.seasonYear}'),
          ): false,
        if (_cachedMapping?.anilistData?.season != null)
          InfoLabel(
            label: 'Season',
            labelStyle: Manager.bodyStrongStyle,
            child: Text(_cachedMapping!.anilistData!.season!.toLowerCase().titleCase),
          ): false,
        if (_cachedMapping?.anilistData?.averageScore != null)
          InfoLabel(
            label: 'Rating',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('${_cachedMapping!.anilistData!.averageScore! / 10}/10'),
          ): false,
        if (_cachedMapping?.anilistData?.meanScore != null)
          InfoLabel(
            label: 'Mean Score',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('${_cachedMapping!.anilistData!.meanScore! / 10}/10'),
          ): false,
        if (_cachedMapping?.anilistData?.popularity != null)
          InfoLabel(
            label: 'Popularity',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('#${_cachedMapping!.anilistData!.popularity}'),
          ): false,
        if (_cachedMapping?.anilistData?.favourites != null)
          InfoLabel(
            label: 'Favourites',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('${_cachedMapping!.anilistData!.favourites}'),
          ): false,
        if (widget.target!.metadata?.duration != null && widget.target!.metadata!.duration.inSeconds > 0)
          InfoLabel(
            label: 'Duration',
            labelStyle: Manager.bodyStrongStyle,
            child: Text(widget.target!.metadata!.durationFormatted),
          ): true,
      };
    }

    return {
      InfoLabel(
        label: 'Seasons',
        labelStyle: Manager.bodyStrongStyle,
        child: Text('${series.numberOfSeasons}'),
      ): false,
      InfoLabel(
        label: 'Episodes',
        labelStyle: Manager.bodyStrongStyle,
        child: Text('${series.totalEpisodes}'),
      ): false,
      if (series.relatedMedia.isNotEmpty)
        InfoLabel(
          label: 'Related Media',
          labelStyle: Manager.bodyStrongStyle,
          child: Text('${series.relatedMedia.length}'),
        ): false,
      if (series.effectiveStatus != null)
        InfoLabel(
          label: 'Status',
          labelStyle: Manager.bodyStrongStyle,
          child: Text(series.effectiveStatus!),
        ): false,
      if (series.formats != null)
        InfoLabel(
          label: 'Formats',
          labelStyle: Manager.bodyStrongStyle,
          child: Text(series.formats!),
        ): true,
      if (series.seasonAndSeasonYearRange != null)
        InfoLabel(
          label: 'Years',
          labelStyle: Manager.bodyStrongStyle,
          child: Text('${series.seasonAndSeasonYearRange}'),
        ): true,
      if (series.highestUserScore != null && series.highestUserScore! > 0)
        InfoLabel(
          label: 'User Score',
          labelStyle: Manager.bodyStrongStyle,
          child: Text('${series.highestUserScore!.toStringAsFixed(1)}/10'),
        ): false,
      if (series.metadata?.duration != null && series.metadata!.duration.inSeconds > 0)
        InfoLabel(
          label: 'Duration',
          labelStyle: Manager.bodyStrongStyle,
          child: Text(series.metadata!.durationFormatted),
        ): true,
    };
  }

  //

  void _loadColors() {
    _textColor = Colors.white;
    _selectedTextColor = getTextColor(Manager.currentDominantColor ?? Manager.accentColor);
  }

  @override
  void initState() {
    super.initState();
    _loadColors();
    if (widget.seriesPath != null) {
      deferredPointerLink = DeferredPointerHandlerLink();
      nextFrame(() => _loadAnilistDataForCurrentSeries());
    }

    // Initialize the cached mapping from the widget
    _cachedMapping = widget.mapping;
    if (_cachedMapping?.viewType != null) _currentViewType = _cachedMapping!.viewType!;

    if (isMappingMode) nextFrame(() => _initializeMappingData());

    parser = SimpleHtmlParser(context);
  }

  @override
  didUpdateWidget(covariant SeriesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.seriesPath != oldWidget.seriesPath) {
      // Series changed, load new data
      if (widget.seriesPath != null) {
        deferredPointerLink ??= DeferredPointerHandlerLink();
        nextFrame(() => _loadAnilistDataForCurrentSeries());
      }
    }

    // Mapping or target changed
    if (widget.target != oldWidget.target || widget.mapping != oldWidget.mapping) {
      _cachedMapping = widget.mapping;
      if (_cachedMapping?.viewType != null) _currentViewType = _cachedMapping!.viewType!;

      if (isMappingMode) nextFrame(() => _initializeMappingData());
    }
  }

  void _onViewTypeChanged(ViewType newViewType) {
    setState(() => _currentViewType = newViewType);

    if (_cachedMapping != null) {
      final library = Provider.of<Library>(context, listen: false);
      library.updateMappingViewType(_cachedMapping!.anilistId, newViewType);
    }
  }

  @override
  void dispose() {
    deferredPointerLink?.dispose();
    super.dispose();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    // If series changes while dependencies change, reload Anilist data
    if (widget.seriesPath != null && _cachedSeries != null && !_cachedSeries!.isLinked) {
      nextFrame(() => _loadAnilistDataForCurrentSeries());
    }
  }

  ColorFilter get colorFilter => ColorFilter.matrix([
        // Scale down RGB channels (darken)
        0.7, 0, 0, 0, 0,
        0, 0.7, 0, 0, 0,
        0, 0, 0.7, 0, 0,
        0, 0, 0, 1, 0,
      ]);

  /// Initialize mapping data
  Future<void> _initializeMappingData() async {
    if (!mounted || _cachedMapping == null) return;

    final mapping = _cachedMapping!;

    // Calculate dominant color from the mapping's anilistData
    final dominantColor = await mapping.effectivePrimaryColor(forceRecalculate: false);
    if (!mounted) return;

    Manager.setState(() => Manager.currentDominantColor = dominantColor);

    // Fetch episode titles from AniList
    try {
      final (newSeries, episodeTitlesUpdated) = await Manager.episodeTitleService.fetchAndUpdateEpisodeTitlesFromMapping(mapping);
      if (episodeTitlesUpdated && mounted) {
        logTrace('Episode titles updated, refreshing UI');
        setState(() {}); // Refresh UI to show updated episode titles
      }

      if (newSeries != null && libraryScreenKey.currentState != null) {
        libraryScreenKey.currentState!.updateSeriesInSortCache(newSeries);
      }
    } catch (e) {
      logErr('Error fetching episode titles', e);
    }
  }

  Future<ImageProvider?> _getMappingImage({required bool banner}) async {
    final mapping = _cachedMapping;
    if (mapping == null) return null;

    final imageUrl = banner ? mapping.anilistData?.bannerImage : mapping.anilistData?.posterImage;
    if (imageUrl == null) return null;

    final imageCache = ImageCacheService();
    final File? cachedFile = await imageCache.getCachedImageFile(imageUrl);
    if (cachedFile != null) return FileImage(cachedFile);

    // Start caching in background but return network image for immediate display
    imageCache.cacheImage(imageUrl); // no await
    return CachedNetworkImageProvider(imageUrl, errorListener: (error) => logWarn('Failed to load image from network: $error'));
  }

  void _playEpisode(Episode episode) {
    final library = Provider.of<Library>(context, listen: false);
    library.playEpisode(episode);
  }

  void selectImage(BuildContext context, {required bool isBanner}) {
    final library = Provider.of<Library>(context, listen: false);
    if (_cachedSeries == null) return;

    // Check if the action should be disabled during indexing
    if (library.lockManager.shouldDisableAction(UserAction.seriesImageSelection)) {
      snackBar(
        library.lockManager.getDisabledReason(UserAction.seriesImageSelection),
        severity: InfoBarSeverity.warning,
      );
      return;
    }

    showManagedDialog<ImageSource?>(
      context: context,
      id: isBanner ? 'bannerSelection:${_cachedSeries!.path}' : 'posterSelection:${_cachedSeries!.path}',
      title: isBanner ? 'Select Banner' : 'Select Poster',
      dialogDoPopCheck: () => true,
      builder: (context) => ImageSelectionDialog(
        series: _cachedSeries!,
        popContext: context,
        isBanner: isBanner,
      ),
    ).then((source) {
      if (source != null && mounted) setState(() {});
    });
  }

  Future<void> _loadAnilistDataForCurrentSeries() async {
    final series = _cachedSeries; // get current series
    if (!mounted || widget.seriesPath == null || series == null) return;

    if (!series.isLinked) {
      // Clear any Anilist data references to ensure UI updates
      series.anilistData = null;
      if (homeKey.currentContext?.mounted ?? false) setState(() {});
      _loadColors();
      return;
    }

    // Load data for all mappings
    await _loadAnilistData(anilistIDs);
  }

  List<int> get anilistIDs => _cachedSeries?.anilistMappings.map((e) => e.anilistId).whereType<int>().toSet().toList() ?? [];

  Future<void> loadAnilistData(List<int> ids) async => await _loadAnilistData(ids, force: true); // force reload for single ID

  /// Change the primary AniList ID for the current series
  ///
  /// Assumes the anilistData of the mapping is already loaded
  Future<void> changePrimaryId(int id) async {
    final series = _cachedSeries;
    if (series == null) return;

    final mapping = series.anilistMappings.firstWhere(
      (m) => m.anilistId == id,
      orElse: () => series.anilistMappings.first, // fallback, shouldn't happen
    );

    setState(() {
      series.primaryAnilistId = mapping.anilistId;
      series.anilistData = mapping.anilistData;
      final newColor = mapping.effectivePrimaryColorSync();
      Manager.currentDominantColor = newColor;
      Manager.seriesDominantColor = newColor;
    });

    // Save the updated series to the library
    final BuildContext? ctx;
    if (mounted)
      ctx = context;
    else
      ctx = rootNavigatorKey.currentContext;

    if (ctx != null && ctx.mounted) {
      try {
        final library = Provider.of<Library>(ctx, listen: false);

        // Update the series mappings with the new primary ID
        await library.updateSeriesMappings(series, series.anilistMappings);

        // Also update the series
        await library.updateSeries(series, invalidateCache: false);

        if (libraryScreenKey.currentState != null) libraryScreenKey.currentState!.updateSeriesInSortCache(series);

        logTrace('Changed primary AniList ID to $id, saved to library');
      } catch (e) {
        logErr('Error updating series primary AniList ID: $e');
      }
    }
  }

  Future<void> _loadAnilistData(List<int> anilistIDs, {bool force = false}) async {
    final series = _cachedSeries;
    if (series == null) return;

    // Identify IDs that need fetching
    final currentTime = now;
    final idsToFetch = anilistIDs.where((id) {
      final mapping = series.anilistMappings.firstWhereOrNull((m) => m.anilistId == id);
      if (mapping == null) return false;

      return force || //
          mapping.lastSynced == null ||
          currentTime.difference(mapping.lastSynced!) > kAnilistCacheDuration ||
          mapping.anilistData?.posterImage == null ||
          mapping.anilistData?.bannerImage == null;
    }).toList();

    if (idsToFetch.isEmpty) return;

    logTrace('Fetching AniList data for ${idsToFetch.length} IDs: ${idsToFetch.join(', ')}');

    try {
      final Map<int, AnilistAnime?> fetchedData = await SeriesLinkService().fetchMultipleAnimeDetails(idsToFetch);
      if (!mounted) return;

      final library = Provider.of<Library>(context, listen: false);

      bool needsFullSave = false;
      bool dominantColorChanged = false;
      final List<Future<void> Function()> pendingPartialUpdates = [];

      for (final entry in fetchedData.entries) {
        final anilistId = entry.key;
        final anilistAnime = entry.value;

        if (anilistAnime == null) {
          if (ConnectivityService().isOffline) logWarn('Failed to fetch AniList details for ID $anilistId: device is offline');
          else logErr('Failed to load Anilist data for ID: $anilistId');
          
          continue;
        }

        final mapping = series.anilistMappings.firstWhereOrNull((m) => m.anilistId == anilistId);
        if (mapping == null) continue;

        final oldData = mapping.anilistData;
        final bool isPrimary = series.primaryAnilistId == anilistId || series.primaryAnilistId == null;

        // Update in memory
        mapping.anilistData = anilistAnime;
        mapping.lastSynced = currentTime;

        // Check for image changes | non primary mappings use updateMappingAnilistData whose update includes the new images
        if (isPrimary && (oldData?.posterImage != anilistAnime.posterImage || oldData?.bannerImage != anilistAnime.bannerImage)) //
          needsFullSave = true;

        // Check for dominant color changes
        if (isPrimary) {
          final oldColor = Manager.currentDominantColor;
          // Force recalculate because mapping data changed
          final newColor = await series.effectivePrimaryColor(forceRecalculate: true);

          if (oldColor?.value != newColor?.value) {
            dominantColorChanged = true;
            needsFullSave = true;

            if (!isMappingMode) {
              // In series mode, update both current and series dominant colors
              Manager.currentDominantColor = newColor;
              Manager.seriesDominantColor = newColor;
            } else {
              // In mapping mode, only update seriesDominantColor
              Manager.seriesDominantColor = newColor;
            }
          }
        }

        // Queue partial update if 
        if (!needsFullSave) {
          if (oldData != anilistAnime)
            pendingPartialUpdates.add(() => library.updateMappingAnilistData(series, anilistId, anilistAnime, currentTime));
          else
            pendingPartialUpdates.add(() => library.updateMappingLastSynced(series, anilistId, currentTime));
        }
      }

      if (needsFullSave) {
        Series seriesToSave = series;
        final primaryMapping = series.anilistMappings.firstWhereOrNull((m) => m.anilistId == series.primaryAnilistId);

        if (primaryMapping?.anilistData != null) {
          seriesToSave = series.copyWith(
            anilistPoster: primaryMapping!.anilistData!.posterImage,
            anilistBanner: primaryMapping.anilistData!.bannerImage,
          );
        }

        await library.updateSeriesMappings(seriesToSave, seriesToSave.anilistMappings);
        await library.updateSeries(seriesToSave, invalidateCache: false);
        logTrace('Performed full series update due to image/color changes.');
      } else {
        // Execute partial updates
        await Future.wait(pendingPartialUpdates.map((update) => update()));
        if (pendingPartialUpdates.isNotEmpty) logTrace('Performed ${pendingPartialUpdates.length} partial updates.');
      }

      // Finalize UI
      if (dominantColorChanged) {
        _loadColors();
        Manager.setState();
      }

      if (libraryScreenKey.currentState != null) libraryScreenKey.currentState!.updateSeriesInSortCache(series);
      

      if (mounted) setState(() {});
    } catch (e) {
      if (!isExpectedOfflineError(e)) logErr('Failed to load Anilist data', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.seriesPath == null)
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No series selected', style: Manager.subtitleStyle),
            VDiv(16),
            StandardButton.label(
              onPressed: widget.onBack,
              tooltip: 'Go back to the library',
              label: 'Back to Library',
            ),
          ],
        ),
      );

    // Use context.select to listen to changes in this specific series
    final series = context.select<Library, Series?>((library) => library.getSeriesByPath(widget.seriesPath!));

    // Update the cached series reference
    _cachedSeries = series;

    if (series == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Series not found', style: Manager.subtitleStyle),
            VDiv(16),
            StandardButton.label(
              onPressed: widget.onBack,
              tooltip: 'Go back to the library',
              label: 'Back to Library',
            ),
          ],
        ),
      );
    }

    return DeferredPointerHandler(
      key: ValueKey(series.path),
      link: deferredPointerLink,
      child: MiruRyoikiTemplatePage(
        headerWidget: _buildHeader(context, series),
        infobar: (_) => _buildInfoBar(context, series),
        content: _buildContentGrid(context, series),
        backgroundColor: Manager.currentDominantColor,
        onHeaderCollapse: () => _descriptionController.collapse(),
        scrollableContent: false,
      ),
    );
  }

  HeaderWidget _buildHeader(BuildContext context, Series series) {
    final isMapping = isMappingMode;
    final title = isMapping ? widget.target!.displayName : series.displayTitle;
    final description = isMapping ? _cachedMapping?.anilistData?.description : series.description;
    final imageFuture = isMapping ? _getMappingImage(banner: true) : series.getBannerImage();

    return HeaderWidget(
      image_widget: FutureBuilder(
        future: imageFuture,
        builder: (context, snapshot) {
          return Stack(
            children: [
              // Banner
              ShiftClickableHover(
                color: Manager.currentDominantColor,
                enabled: !isMapping && _isBannerHovering && !bannerChangeDisabled,
                onTap: (context) => selectImage(context, isBanner: true),
                onEnter: bannerChangeDisabled ? () {} : () => setState(() => _isBannerHovering = true),
                onExit: () {
                  StatusBarManager().hide();
                  setState(() => _isBannerHovering = false);
                },
                onHover: bannerChangeDisabled ? null : () => StatusBarManager().show(KeyboardState.shiftPressedNotifier.value ? 'Click to change Banner' : 'Shift-click to change Banner', autoHideDuration: Duration.zero),
                finalChild: (BuildContext context, bool enabled) {
                  return Stack(
                    children: [
                      AnimatedOpacity(
                        duration: shortStickyHeaderDuration,
                        opacity: enabled ? 0.75 : 1,
                        child: AnimatedContainer(
                          duration: shortStickyHeaderDuration,
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
                            color: enabled ? (Manager.currentDominantColor ?? Manager.accentColor).withOpacity(0.75) : Colors.transparent,
                            image: _getBannerDecoration(snapshot.data),
                          ),
                          padding: const EdgeInsets.only(bottom: 16.0),
                          alignment: Alignment.bottomLeft,
                          child: Builder(builder: (context) {
                            if (snapshot.data != null) return SizedBox.shrink();

                            return Center(
                              child: Stack(
                                children: [
                                  AnimatedOpacity(
                                    duration: shortStickyHeaderDuration,
                                    opacity: enabled ? 0 : 1,
                                    child: Icon(FluentIcons.picture, size: 48, color: Colors.white),
                                  ),
                                  AnimatedOpacity(
                                    duration: shortStickyHeaderDuration,
                                    opacity: enabled ? 1 : 0,
                                    child: Icon(FluentIcons.add, size: 48, color: Colors.white),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                      ...[
                        AnimatedOpacity(
                          duration: shortStickyHeaderDuration,
                          opacity: enabled && snapshot.data != null ? 1 : 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Colors.black.withOpacity(.95),
                                  Colors.black.withOpacity(0),
                                ],
                                radius: 0.5,
                                center: Alignment.center,
                                focal: Alignment.center,
                              ),
                            ),
                            child: Center(
                              child: Icon(FluentIcons.edit, size: 35, color: Colors.white),
                            ),
                          ),
                        ),
                        AnimatedOpacity(
                          duration: shortStickyHeaderDuration,
                          opacity: enabled && snapshot.data != null ? 1 : 0,
                          child: Center(
                            child: Icon(FluentIcons.edit, size: 35, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              // temp buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackButton(onTap: widget.onBack, label: 'Back to Library', child: const Icon(FluentIcons.back)),
                  // ... other buttons
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
            child: parser.parse(description, selectable: true, selectionColor: Manager.currentDominantColor),
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

  MiruRyoikiInfobar _buildInfoBar(BuildContext context, Series series) {
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
    final isMapping = isMappingMode;
    final posterImage = isMapping ? _getMappingImage(banner: false) : series.getPosterImage();

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
        StandardButton(
          label: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(mat.Icons.folder_open),
              HDiv(4),
              Text(
                'Open Series Folder',
                style: getStyleBasedOnAccent(false),
              ),
            ],
          ),
          expand: true,
          tooltip: 'Open the series folder in your file explorer',
          onPressed: () => ShellUtils.openFolder(isMapping ? (widget.mapping?.localPath.path ?? series.path.path) : series.path.path),
        ),
        if (!isMapping) ...[
          SizedBox(height: 6.0),
          _buildManageLinksButton(anilistProvider, series),
        ],
      ],
      poster: ({required imageProvider, required width, required height, required squareness, required offset}) {
        return DeferPointer(
          link: deferredPointerLink,
          paintOnTop: true,
          child: SizedBox(
            height: height - offset,
            width: width,
            child: ShiftClickableHover(
              color: Manager.currentDominantColor,
              enabled: !isMapping && _isPosterHovering && !posterChangeDisabled,
              onTap: (context) => selectImage(context, isBanner: false),
              onEnter: posterChangeDisabled ? () {} : () => setState(() => _isPosterHovering = true),
              onExit: () {
                setState(() => _isPosterHovering = false);
                StatusBarManager().hide();
              },
              onHover: posterChangeDisabled ? null : () => StatusBarManager().show(KeyboardState.shiftPressedNotifier.value ? 'Click to change Poster' : 'Shift-click to change Poster', autoHideDuration: Duration.zero),
              finalChild: (BuildContext context, bool enabled) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
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
                              colorFilter: series.posterImage != null ? ColorFilter.mode(Colors.black.withOpacity(0), BlendMode.darken) : null,
                              blurSigma: 0,
                              shadowColorOpacity: 0,
                            ),
                          );

                        // No image -> image + plus to add first
                        return Center(
                          child: Stack(
                            children: [
                              AnimatedOpacity(
                                duration: shortStickyHeaderDuration,
                                opacity: enabled ? 0 : 1,
                                child: Icon(FluentIcons.picture, size: 48, color: Colors.white),
                              ),
                              AnimatedOpacity(
                                duration: shortStickyHeaderDuration,
                                opacity: enabled ? 1 : 0,
                                child: Icon(FluentIcons.add, size: 48, color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    // Edit poster
                    ...[
                      AnimatedOpacity(
                        duration: shortStickyHeaderDuration,
                        opacity: enabled && imageProvider != null ? 1 : 0,
                        child: AnimatedContainer(
                          width: width,
                          height: height,
                          duration: shortStickyHeaderDuration,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
                            gradient: RadialGradient(
                              colors: [
                                Colors.black.withOpacity(.95),
                                (Manager.currentDominantColor ?? Manager.accentColor).withOpacity(.2),
                              ],
                              radius: 0.5,
                              center: Alignment.center,
                              focal: Alignment.center,
                            ),
                          ),
                          child: Center(
                            child: Icon(FluentIcons.edit, size: 35, color: Colors.white),
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                        duration: shortStickyHeaderDuration,
                        opacity: enabled && imageProvider != null ? 1 : 0,
                        child: Center(child: Icon(FluentIcons.edit, size: 35, color: Colors.white)),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Builder _buildManageLinksButton(AnilistProvider anilistProvider, Series series) {
    return Builder(
      builder: (context) {
        // Compute tooltip with switch-case outside of the widget
        String tooltipKey;
        if (!anilistProvider.isLoggedIn)
          tooltipKey = 'notLoggedIn';
        // else if (isIndexing)
        //   tooltipKey = 'indexing';
        else if (!series.isLinked)
          tooltipKey = 'notLinked';
        else
          tooltipKey = 'linked';

        String tooltipText = switch (tooltipKey) {
          // 'indexing' => 'Cannot link while library is indexing, please wait.',
          'notLinked' => 'Link with Anilist',
          'linked' => 'Manage Anilist Links',
          'notLoggedIn' => 'You must be logged in to Anilist to link series.',
          _ => '',
        };

        return StandardButton(
          expand: true,
          tooltip: tooltipText,
          label: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(series.isLinked ? FluentIcons.link : FluentIcons.add_link),
              HDiv(4),
              Text(
                !series.isLinked ? 'Link with Anilist' : 'Manage Anilist Links',
                style: getStyleBasedOnAccent(false),
              ),
            ],
          ),
          onPressed: () {
            // // Check if the action should be disabled during indexing
            // if (library.lockManager.shouldDisableAction(UserAction.anilistOperations)) {
            //   snackBar(
            //     library.lockManager.getDisabledReason(UserAction.anilistOperations),
            //     severity: InfoBarSeverity.warning,
            //   );
            //   return;
            // }

            linkWithAnilist(context, series, _loadAnilistData, setState);
          },
          isButtonDisabled: anilistProvider.isOffline,
        );
      },
    );
  }

  Widget _buildInfoBarContent(Series series) {
    final infos_ = infos(series);
    final isMapping = isMappingMode;
    final genres = isMapping ? (_cachedMapping?.anilistData?.genres ?? []) : series.genres;
    final watchedPercentage = isMapping ? (widget.target?.watchedPercentage ?? 0) : series.watchedPercentage;

    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Series metadata
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: () {
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
          ),

          // Genre tags
          if (genres.isNotEmpty) ...[
            VDiv(16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: genres.map((genre) => Chip(text: (color) => Text(genre, style: Manager.bodyStyle.copyWith(color: color)))).toList(),
            ),
          ],

          // Progress bar
          VDiv(16),
          SizedBox(
            width: 300,
            child: AnimatedColor(
                color: Manager.currentDominantColor,
                duration: gradientChangeDuration,
                builder: (color) {
                  return ProgressBar(
                    value: watchedPercentage * 100,
                    activeColor: color,
                    backgroundColor: Colors.white.withOpacity(.3),
                  );
                }),
          ),

          if (isMapping ? (widget.target?.metadata != null) : (series.metadata != null)) ...[
            VDiv(16),
            Wrap(alignment: WrapAlignment.spaceBetween, spacing: 8, runSpacing: 8, children: [
              InfoLabel(
                label: 'Path',
                child: Text(
                  isMapping ? widget.target!.path.path : series.path.path,
                  style: Manager.captionStyle,
                ),
              ),
              InfoLabel(
                label: 'Size',
                child: Text(isMapping ? widget.target!.metadata!.fileSize() : series.metadata!.fileSize(), style: Manager.captionStyle),
              ),
              InfoLabel(
                label: 'First Downloaded',
                child: Text(isMapping ? widget.target!.metadata!.creationTime.pretty() : series.metadata!.creationTime.pretty(), style: Manager.captionStyle),
              ),
              InfoLabel(
                label: 'Last Modified',
                child: Text(isMapping ? widget.target!.metadata!.lastModified.pretty() : series.metadata!.lastModified.pretty(), style: Manager.captionStyle),
              ),
            ]),
            VDiv(16),
          ],
        ],
      );
    });
  }

  Widget _buildContentGrid(BuildContext context, Series series) {
    if (isMappingMode && widget.target != null) {
      final headerHeight = 45.0;
      final borderRadius = ScreenUtils.kStatCardBorderRadius;

      final visibleHeader = Container(
        height: headerHeight,
        margin: EdgeInsets.all(.5),
        constraints: BoxConstraints(maxHeight: headerHeight),
        child: AcrylicHeader(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(borderRadius),
            topLeft: Radius.circular(borderRadius),
          ),
          useFrostedNoise: false,
          useAcrylic: false,
          padding: EdgeInsets.all(3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HDiv(6),
              ViewTypeSwitcher(
                useBorder: false,
                currentViewType: _currentViewType,
                textColor: _textColor,
                selectedTextColor: _selectedTextColor,
                onViewTypeChanged: _onViewTypeChanged,
              ),
              HDiv(3.5),
            ],
          ),
        ),
      );

      return Column(
        children: [
          visibleHeader,
          SizedBox(height: 4),
          Expanded(
            child: Card(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(borderRadius),
                bottomRight: Radius.circular(borderRadius),
              ),
              padding: EdgeInsets.only(top: 16, left: 16, bottom: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(borderRadius),
                  bottomRight: Radius.circular(borderRadius),
                ),
                child: Padding(
                  padding: EdgeInsets.only(right: 2),
                  child: EpisodeGrid(
                    collapsable: false,
                    episodes: widget.target!.episodes,
                    onTap: (episode) => _playEpisode(episode),
                    series: series,
                    mapping: widget.mapping,
                    padding: EdgeInsets.only(right: 14),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Create MappingTarget for each AnilistMapping using the helper method
    final List<(AnilistMapping, MappingTarget?)> mappingsWithTargets = series.anilistMappings.map((mapping) => (mapping, series.getTargetForMapping(mapping))).toList();

    // Filter out mappings without valid targets
    final validMappings = mappingsWithTargets.where((tuple) => tuple.$2 != null).toList();

    if (validMappings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(mat.Icons.add_link, size: 48, color: Manager.accentColor.lighter),
              VDiv(16),
              Text('No Links found', style: Manager.subtitleStyle),
              VDiv(8),
              Text(
                'Link the correct path with an AniList entry to see seasons and episodes', // TODO add counter that tracks how many times the mappings manager was opened while the valid mappings have been empty
                style: Manager.captionStyle,
                textAlign: TextAlign.center,
              ),
              VDiv(32),
              SizedBox(width: 420, child: _buildManageLinksButton(Provider.of<AnilistProvider>(context, listen: false), series)),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final List<Widget> children = validMappings.map((tuple) {
          final mapping = tuple.$1;
          final target = tuple.$2!;

          return MappingCard(
            key: ValueKey('${mapping.localPath}:${mapping.anilistId}'),
            target: target,
            series: series,
            mapping: mapping,
            onTap: () {
              if (widget.onNavigateToMapping != null)
                widget.onNavigateToMapping!(mapping, target);
              else
                logWarn('onNavigateToMapping callback is null');
            },
          );
        }).toList();

        return ScrollConfiguration(
          behavior: ScrollBehavior().copyWith(overscroll: false, scrollbars: false),
          child: GridView(
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ScreenUtils.crossAxisCount(constraints.maxWidth),
              childAspectRatio: ScreenUtils.kDefaultAspectRatio,
              crossAxisSpacing: ScreenUtils.cardPadding,
              mainAxisSpacing: ScreenUtils.cardPadding,
            ),
            children: children,
          ),
        );
      },
    );
  }
}

void linkWithAnilist(BuildContext context, Series? series, Future<void> Function(List<int>) loadData, void Function(VoidCallback) setState) async {
  if (series == null) {
    snackBar('Series not found', severity: InfoBarSeverity.error);
    return;
  }

  // Show the dialog
  await showManagedDialog(
    context: context,
    id: 'linkAnilist:${series.path}',
    title: 'Link to Anilist',
    data: series.path,
    barrierColor: Manager.currentDominantColor?.withOpacity(0.5),
    canUserPopDialog: true,
    closeExistingDialogs: true, // Close existing dialogs, important
    dialogDoPopCheck: () => Manager.canPopDialog, // Allow popping only when in view mode
    builder: (context) => AnilistLinkMultiDialog(
      constraints: const BoxConstraints(
        maxWidth: 1300,
        maxHeight: 600,
      ),
      series: series,
      popContext: context,
      linkService: SeriesLinkService(),
      onLink: (_, __) {},
      onDialogComplete: (success, mappings) async {
        // if the dialog was closed without a result, do nothing
        if (success == null)
          // logDebug('Dialog closed without result');
          return;

        // if the dialog was closed with a result, check if it was successful
        if (!success) {
          logErr('Linking failed');
          snackBar('Failed to link with Anilist', severity: InfoBarSeverity.error);
          return;
        }

        // if dialog was closed with a result, and it was successful, update the series mappings
        final library = Provider.of<Library>(context, listen: false);

        // Check if the action should be disabled during indexing
        if (library.lockManager.shouldDisableAction(UserAction.anilistOperations)) {
          snackBar(
            library.lockManager.getDisabledReason(UserAction.anilistOperations),
            severity: InfoBarSeverity.warning,
          );
          return;
        }

        // Calculate the number of new mappings
        final oldMappings = series.anilistMappings;
        List<int> anilistIdsToLoad = [];

        for (final mapping in mappings) {
          bool isNew = !oldMappings.any((m) => m.anilistId == mapping.anilistId && m.localPath == mapping.localPath);
          if (isNew) anilistIdsToLoad.add(mapping.anilistId);
        }

        // Ensure the library gets saved
        await library.updateSeriesMappings(series, mappings);

        // If links were added
        if (anilistIdsToLoad.isNotEmpty) {
          snackBar(
            'Successfully linked ${anilistIdsToLoad.length} ${anilistIdsToLoad.length == 1 ? 'new item' : 'new items'} with Anilist',
            severity: InfoBarSeverity.success,
          );
        } else if (mappings.length < oldMappings.length) {
          // If links were removed
          final removedCount = oldMappings.length - mappings.length;
          snackBar(
            'Removed $removedCount ${removedCount == 1 ? 'link' : 'links'} from Anilist',
            severity: InfoBarSeverity.success,
          );
        } else {
          // No changes in link count but mappings might have been updated
          snackBar(
            'Anilist links updated successfully',
            severity: InfoBarSeverity.success,
          );
        }

        closeDialog(context);

        // Load Anilist data
        if (anilistIdsToLoad.isNotEmpty) await loadData(anilistIdsToLoad);

        // Update the series with the new mappings
        final newColor = await series.effectivePrimaryColor();
        Manager.currentDominantColor = newColor;
        Manager.seriesDominantColor = newColor;
        Manager.setState();
      },
    ),
  );
}
