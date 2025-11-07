import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:miruryoiki/widgets/frosted_noise.dart';
import 'package:provider/provider.dart';
import 'package:defer_pointer/defer_pointer.dart';

import '../main.dart';
import '../models/anilist/anime.dart';
import '../services/connectivity/connectivity_service.dart';
import '../services/library/library_provider.dart';
import '../services/lock_manager.dart';
import '../services/navigation/show_info.dart';
import '../services/navigation/statusbar.dart';
import '../utils/path.dart';
import '../utils/shell.dart';
import '../utils/text.dart';
import '../widgets/animated_color_wrapper.dart';
import '../widgets/buttons/button.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../widgets/buttons/wrapper.dart';
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
import '../utils/retry.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/infobar.dart';
import '../widgets/page/page.dart';
import '../widgets/mapping_card.dart';
import '../widgets/shift_clickable_hover.dart';
import '../widgets/shrinker.dart';
import '../widgets/simple_html_parser.dart';
import '../widgets/tooltip_wrapper.dart';
import '../widgets/transparency_shadow_image.dart';
import '../models/mapping_target.dart';
import '../services/navigation/navigation.dart';
import 'anilist_settings.dart';
import 'inner_series.dart';

/// Duration for which AniList data is considered fresh and doesn't need refetching
const Duration kAnilistCacheDuration = Duration(minutes: 30);

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
  static Color? mainDominantColor;

  final GlobalKey<SeriesScreenState> _seriesScreenKey = GlobalKey<SeriesScreenState>();
  final GlobalKey<InnerSeriesScreenState> _innerSeriesScreenKey = GlobalKey<InnerSeriesScreenState>();

  bool _navigateToMappingFinish = false;
  bool _mainSeriesScreenOpacityHideStart = false;

  /// Get the isReloadingSeries property from the currently active screen
  bool get isReloadingSeries {
    if (_selectedMapping != null && _selectedTarget != null) {
      // Inner series screen is active
      return _innerSeriesScreenKey.currentState?.isReloadingSeries ?? false;
    } else {
      // Main series screen is active
      return _seriesScreenKey.currentState?.isReloadingSeries ?? false;
    }
  }

  GlobalKey<SeriesScreenState>? get seriesScreenKey {
    if (isShowingInnerScreen) return null;
    return _seriesScreenKey;
  }

  GlobalKey<InnerSeriesScreenState>? get innerSeriesScreenKey {
    if (isShowingMainScreen) return null;
    return _innerSeriesScreenKey;
  }

  /// Check if we're currently showing the inner series screen
  bool get isShowingInnerScreen => _selectedMapping != null && _selectedTarget != null;

  /// Check if we're currently showing the main series screen
  bool get isShowingMainScreen => !isShowingInnerScreen;

  bool get showInnerScreen => _selectedMapping != null && _selectedTarget != null;

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
      SeriesScreenContainerState.mainDominantColor = mainDominantColor ?? Manager.accentColor;
    });

    nextFrame(delay: 15, () {
      setState(() => _mainSeriesScreenOpacityHideStart = true);
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
      _mainSeriesScreenOpacityHideStart = false;
      _selectedTarget = null;
      SeriesScreenContainerState.mainDominantColor = mainDominantColor ?? Manager.accentColor;
      Manager.currentDominantColor = mainDominantColor;
    });
  }

  void onNavigateToMappingFinish() {
    if (!mounted) return;
    setState(() => _navigateToMappingFinish = showInnerScreen);
  }

  @override
  Widget build(BuildContext context) {
    // Use IndexedStack to keep both screens alive and preserve state
    return Stack(
      children: [
        // Main series screen (grid of mappings)
        Offstage(
          offstage: showInnerScreen && _navigateToMappingFinish,
          child: AnimatedOpacity(
            duration: getDuration(const Duration(milliseconds: 300)),
            opacity: showInnerScreen && _mainSeriesScreenOpacityHideStart ? 0.0 : 1.0,
            child: IgnorePointer(
              ignoring: showInnerScreen,
              child: AbsorbPointer(
                absorbing: showInnerScreen,
                child: SeriesScreen(
                  key: _seriesScreenKey,
                  seriesPath: widget.seriesPath,
                  onBack: widget.onBack,
                  onNavigateToMapping: navigateToMapping,
                ),
              ),
            ),
          ),
        ),

        // Inner series screen (single mapping detail)
        AbsorbPointer(
          absorbing: !showInnerScreen,
          child: IgnorePointer(
            ignoring: !showInnerScreen,
            child: AnimatedOpacity(
              duration: getDuration(const Duration(milliseconds: 300)),
              opacity: showInnerScreen ? 1.0 : 0.0,
              onEnd: () => onNavigateToMappingFinish(),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: showInnerScreen
                    ? InnerSeriesScreen(
                        key: _innerSeriesScreenKey,
                        seriesPath: widget.seriesPath!,
                        target: _selectedTarget!,
                        mapping: _selectedMapping!,
                        onBack: exitMapping,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SeriesScreen extends StatefulWidget {
  final PathString? seriesPath;
  final VoidCallback onBack;
  final Function(AnilistMapping mapping, MappingTarget target)? onNavigateToMapping;

  const SeriesScreen({
    super.key,
    required this.seriesPath,
    required this.onBack,
    this.onNavigateToMapping,
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

  // Color? dominantColor;

  // Widget: whether to allocate a full row or divide it in 2 columns [true = full row, false = 2 columns]
  Map<InfoLabel, bool> infos(Series series) => {
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
            child: Text('${series.highestUserScore! / 10}/10'),
          ): false,
        if (series.metadata?.duration != null && series.metadata!.duration.inSeconds > 0)
          InfoLabel(
            label: 'Duration',
            labelStyle: Manager.bodyStrongStyle,
            child: Text(series.metadata!.durationFormatted),
          ): true,
      };

  //

  @override
  void initState() {
    super.initState();
    if (widget.seriesPath != null) {
      deferredPointerLink = DeferredPointerHandlerLink();
      nextFrame(() => _loadAnilistDataForCurrentSeries());
    }
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
      SeriesScreenContainerState.mainDominantColor = mapping.effectivePrimaryColorSync();
      Manager.currentDominantColor = SeriesScreenContainerState.mainDominantColor;
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

    // Filter out IDs that were recently synced (within cache duration)
    final currentTime = now;
    final List<int> idsToFetch = [];

    // Store the original dominant color to check if it changes after calculating the new one
    final Color? originalDominantColor = series.effectivePrimaryColorSync();
    if (originalDominantColor != null) {
      SeriesScreenContainerState.mainDominantColor = originalDominantColor;
    }

    for (final id in anilistIDs) {
      final mapping = series.anilistMappings.firstWhere(
        (m) => m.anilistId == id,
        orElse: () => series.anilistMappings.first, // fallback, shouldn't happen
      );

      // Check if this mapping needs to be refreshed
      if (force || mapping.lastSynced == null || currentTime.difference(mapping.lastSynced!) > kAnilistCacheDuration || mapping.anilistData?.posterImage == null || mapping.anilistData?.bannerImage == null) {
        idsToFetch.add(id);
      } else {
        logTrace('Skipping AniList fetch for ID $id - synced ${currentTime.difference(mapping.lastSynced!).inMinutes} minutes ago');
      }
    }

    // If no IDs need fetching, return early
    if (idsToFetch.isEmpty) {
      logTrace('All AniList data is up to date, skipping fetch');
      return;
    }

    logTrace('Fetching AniList data for ${idsToFetch.length} IDs: ${idsToFetch.join(', ')}');

    try {
      final Map<int, AnilistAnime?> anime = await SeriesLinkService().fetchMultipleAnimeDetails(idsToFetch);

      bool anyUpdatesOccurred = false;
      bool dominantColorChanged = false;

      if (mounted) {
        setState(() {
          // Process each anime in the map
          for (final entry in anime.entries) {
            final anilistId = entry.key;
            final anilistAnime = entry.value;

            if (anilistAnime != null) {
              // Find the mapping with this ID
              for (var i = 0; i < series.anilistMappings.length; i++) {
                if (series.anilistMappings[i].anilistId == anilistId) {
                  final oldMapping = series.anilistMappings[i];
                  series.anilistMappings[i] = series.anilistMappings[i].copyWith(
                    anilistId: anilistId,
                    lastSynced: now,
                    anilistData: anilistAnime,
                  );

                  // Also update the series.anilistData if this is the primary
                  if (series.primaryAnilistId == anilistId || series.primaryAnilistId == null) {
                    series.anilistData = anilistAnime;
                  }

                  anyUpdatesOccurred = oldMapping.anilistData != anilistAnime;
                  break; // Break after updating the mapping
                }
              }
            } else if (ConnectivityService().isOffline) {
              logWarn('Failed to fetch AniList details for ID: $anilistId - device is offline');
            } else {
              logErr('Failed to load Anilist data for ID: $anilistId');
            }
          }
        });
      }

      // Update dominant color if any updates occurred
      if (anyUpdatesOccurred) {
        final dominantColor = await series.effectivePrimaryColor(forceRecalculate: true);
        if (dominantColor != null) SeriesScreenContainerState.mainDominantColor = dominantColor;

        if (!mounted || _cachedSeries == null) {
          // in case series was disposed during the async operation
          logTrace('Series disposed before updating dominant color');
          return;
        }

        Manager.setState(() => Manager.currentDominantColor = dominantColor);

        // Check if dominant color changed
        dominantColorChanged = originalDominantColor?.value != series.effectivePrimaryColorSync()?.value;

        Manager.setState();
      }

      // Save if any updates occurred (mappings or dominant color changed)
      if (anyUpdatesOccurred || dominantColorChanged) {
        // Save the updated series to the library
        final BuildContext? ctx;
        if (mounted)
          ctx = context;
        else
          ctx = rootNavigatorKey.currentContext;

        if (ctx != null && ctx.mounted) {
          try {
            final library = Provider.of<Library>(ctx, listen: false);

            // Update the series mappings with the new AnilistData
            await library.updateSeriesMappings(series, series.anilistMappings);

            // Also update the series
            await library.updateSeries(series, invalidateCache: false);

            if (libraryScreenKey.currentState != null) libraryScreenKey.currentState!.updateSeriesInSortCache(series);

            logTrace('Updated ${anyUpdatesOccurred ? 'mappings' : ''}${anyUpdatesOccurred && dominantColorChanged ? ' and ' : ''}${dominantColorChanged ? 'dominant color' : ''}, saved to library');
          } catch (e) {
            logErr('Error updating series: $e');
          }
        }
      }
    } catch (e) {
      // Check if it's an expected offline error
      if (!RetryUtils.isExpectedOfflineError(e)) {
        logErr('Failed to load Anilist data for multiple IDs: ${anilistIDs.join(', ')}', e);
      } else {
        logDebug('Skipping Anilist data fetch - device is offline');
      }
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
            NormalButton(
              onPressed: widget.onBack,
              tooltip: 'Go back to the library',
              label: 'Back to Library',
            ),
          ],
        ),
      );

    return Selector<Library, Series?>(
      selector: (_, library) => library.getSeriesByPath(widget.seriesPath!),
      shouldRebuild: (prev, next) => prev != next,
      builder: (context, series, child) {
        // Update the cached series reference
        _cachedSeries = series;

        if (series == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Series not found', style: Manager.subtitleStyle),
                VDiv(16),
                NormalButton(
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
            backgroundColor: SeriesScreenContainerState.mainDominantColor,
            onHeaderCollapse: () => _descriptionController.collapse(),
            scrollableContent: false,
          ),
        );
      },
    );
  }

  HeaderWidget _buildHeader(BuildContext context, Series series) {
    return HeaderWidget(
      image_widget: FutureBuilder(
        future: series.getBannerImage(),
        builder: (context, snapshot) {
          return Stack(
            children: [
              // Banner
              ShiftClickableHover(
                color: SeriesScreenContainerState.mainDominantColor,
                enabled: _isBannerHovering && !bannerChangeDisabled,
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
                                (SeriesScreenContainerState.mainDominantColor ?? Manager.accentColor).withOpacity(0.27),
                                Colors.transparent,
                              ],
                            ),
                            color: enabled ? (SeriesScreenContainerState.mainDominantColor ?? Manager.accentColor).withOpacity(0.75) : Colors.transparent,
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
                  _buildButton(
                    widget.onBack,
                    const Icon(FluentIcons.back),
                    'Back to Library',
                  ),
                  // _buildButton(
                  //   () {
                  //     logInfo(series);
                  //     showSimpleManagedDialog(
                  //       context: context,
                  //       id: 'showSeries:${series.hashCode}',
                  //       title: 'Series Info',
                  //       constraints: const BoxConstraints(
                  //         maxWidth: 800,
                  //         maxHeight: 500,
                  //       ),
                  //       body: series.toString(),
                  //     );
                  //   },
                  //   const Icon(FluentIcons.info),
                  //   'Print Series',
                  // ),
                  // Builder(
                  //   builder: (context) {
                  //     final library = context.watch<Library>();
                  //     final isIndexing = library.isIndexing;
                  //     final isWatched = series.watchedPercentage == 1;

                  //     return _buildButton(
                  //       (isWatched || isIndexing)
                  //           ? null
                  //           : () {
                  //               // Check if the action should be disabled during indexing
                  //               if (library.lockManager.shouldDisableAction(UserAction.markSeriesWatched)) {
                  //                 snackBar(
                  //                   library.lockManager.getDisabledReason(UserAction.markSeriesWatched),
                  //                   severity: InfoBarSeverity.warning,
                  //                 );
                  //                 return;
                  //               }

                  //               showSimpleManagedDialog(
                  //                 context: context,
                  //                 id: 'confirmWatchAll',
                  //                 title: 'Confirm Watch All',
                  //                 body: 'Are you sure you want to mark all episodes of "${series.displayTitle}" as watched?',
                  //                 positiveButtonText: 'Confirm',
                  //                 onPositive: () => library.markSeriesWatched(series),
                  //               );
                  //             },
                  //       const Icon(FluentIcons.check_mark),
                  //       isIndexing ? 'Cannot mark while library is indexing, please wait.' : (isWatched ? 'You have already watched all episodes' : 'Mark All as Watched'),
                  //     );
                  //   },
                  // ),
                  // if (context.watch<AnilistProvider>().isLoggedIn)
                  //   _buildButton(
                  //     series.seasons.isNotEmpty
                  //         ? () => linkWithAnilist(
                  //               context,
                  //               series,
                  //               _loadAnilistData,
                  //               setState,
                  //             )
                  //         : null,
                  //     Icon(
                  //       series.primaryAnilistId != null ? FluentIcons.link : FluentIcons.add_link,
                  //       color: Colors.white,
                  //     ),
                  //     series.primaryAnilistId != null ? 'Update Anilist Link' : 'Link with Anilist',
                  //   ),
                ],
              )
            ],
          );
        },
      ),
      colorFilter: null,
      titleLeftAligned: false,
      title: (style, constraints) => Text(series.displayTitle, style: style),
      children: [
        // Add description if available
        if (series.description != null) ...[
          VDiv(8),
          Shrinker(
            maxHeight: 150,
            minHeight: 45,
            controller: _descriptionController,
            child: parser.parse(series.description!, selectable: true, selectionColor: SeriesScreenContainerState.mainDominantColor),
          ),
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
    return MiruRyoikiInfobar(
      getPosterImage: series.getPosterImage(),
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
          onPressed: () => ShellUtils.openFolder(series.path.path),
        ),
        SizedBox(height: 6.0),
        _buildManageLinksButton(anilistProvider, series),
      ],
      poster: ({required imageProvider, required width, required height, required squareness, required offset}) {
        return DeferPointer(
          link: deferredPointerLink,
          paintOnTop: true,
          child: SizedBox(
            height: height - offset,
            width: width,
            child: ShiftClickableHover(
              color: SeriesScreenContainerState.mainDominantColor,
              enabled: _isPosterHovering && !posterChangeDisabled,
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
                                (SeriesScreenContainerState.mainDominantColor ?? Manager.accentColor).withOpacity(.2),
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
          if (series.genres.isNotEmpty) ...[
            VDiv(16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: series.genres.map((genre) => Chip(text: (color) => Text(genre, style: Manager.bodyStyle.copyWith(color: color)))).toList(),
            ),
          ],

          // Progress bar
          VDiv(16),
          SizedBox(
            width: 300,
            child: AnimatedColor(
                color: SeriesScreenContainerState.mainDominantColor,
                duration: gradientChangeDuration,
                builder: (color) {
                  return ProgressBar(
                    value: series.watchedPercentage * 100,
                    activeColor: color,
                    backgroundColor: Colors.white.withOpacity(.3),
                  );
                }),
          ),

          if (series.metadata != null) ...[
            VDiv(16),
            Wrap(alignment: WrapAlignment.spaceBetween, spacing: 8, runSpacing: 8, children: [
              InfoLabel(
                label: 'Path',
                child: Text(
                  series.path.path,
                  style: Manager.captionStyle,
                ),
              ),
              InfoLabel(
                label: 'Size',
                child: Text(series.metadata!.fileSize(), style: Manager.captionStyle),
              ),
              InfoLabel(
                label: 'First Downloaded',
                child: Text(series.metadata!.creationTime.pretty(), style: Manager.captionStyle),
              ),
              InfoLabel(
                label: 'Last Modified',
                child: Text(series.metadata!.lastModified.pretty(), style: Manager.captionStyle),
              ),
            ]),
            VDiv(16),
          ],
        ],
      );
    });
  }

  Widget _buildButton(void Function()? onTap, Widget child, String label) {
    return MouseButtonWrapper(
      child: (_) => TooltipWrapper(
        tooltip: label,
        child: (_) => Padding(
          padding: const EdgeInsets.all(2.0),
          child: IconButton(
            style: ButtonStyle(
              backgroundColor: ButtonState.resolveWith((states) {
                if (onTap == null) return Colors.transparent;
                if (states.contains(mat.MaterialState.pressed)) return Colors.white.withOpacity(0.125);
                if (states.contains(mat.MaterialState.hovered)) return Colors.white.withOpacity(0.075);
                return Colors.transparent;
              }),
              foregroundColor: ButtonState.all(Colors.white.withOpacity(onTap != null ? 1 : 0)),
              elevation: ButtonState.all(0),
              shape: ButtonState.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))),
            ),
            icon: Padding(
              padding: const EdgeInsets.all(6.0),
              child: child,
            ),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }

  Widget _buildContentGrid(BuildContext context, Series series) {
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

        // Load Anilist data
        if (anilistIdsToLoad.isNotEmpty) await loadData(anilistIdsToLoad);

        // Update the series with the new mappings
        Manager.currentDominantColor = await series.effectivePrimaryColor();
        Manager.setState();
      },
    ),
  );
}
