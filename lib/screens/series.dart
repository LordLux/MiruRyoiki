import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:provider/provider.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:recase/recase.dart';

import '../main.dart';
import '../services/connectivity/connectivity_service.dart';
import '../services/library/library_provider.dart';
import '../services/lock_manager.dart';
import '../services/navigation/show_info.dart';
import '../services/navigation/statusbar.dart';
import '../utils/path.dart';
import '../utils/text.dart';
import '../widgets/buttons/button.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../widgets/buttons/wrapper.dart';
import '../widgets/dialogs/link_anilist.dart';
import '../widgets/dialogs/image_select.dart';
import '../enums.dart';
import '../manager.dart';
import '../models/anilist/mapping.dart';
import '../models/series.dart';
import '../models/episode.dart';
import '../services/anilist/linking.dart';
import '../services/navigation/dialogs.dart';
import '../services/navigation/shortcuts.dart';
import '../utils/logging.dart';
import '../utils/retry.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import '../widgets/episode_grid.dart';
import '../widgets/page/header_widget.dart';
import 'package:sticky_headers/sticky_headers.dart';
import '../widgets/page/infobar.dart';
import '../widgets/page/page.dart';
import '../widgets/shift_clickable_hover.dart';
import '../widgets/shrinker.dart';
import '../widgets/simple_html_parser.dart';
import '../widgets/transparency_shadow_image.dart';
import 'anilist_settings.dart';

class SeriesScreen extends StatefulWidget {
  final PathString? seriesPath;
  final VoidCallback onBack;

  const SeriesScreen({
    super.key,
    required this.seriesPath,
    required this.onBack,
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

  final Map<int, GlobalKey<ExpandingStickyHeaderBuilderState>> _seasonExpanderKeys = {};

  bool _isPosterHovering = false;
  DeferredPointerHandlerLink? deferredPointerLink;
  bool _isBannerHovering = false;

  Series? get series => Provider.of<Library>(context, listen: false).getSeriesByPath(widget.seriesPath!);

  Color get dominantColor =>
      series?.dominantColor ?? //
      FluentTheme.of(context).accentColor.defaultBrushFor(FluentTheme.of(context).brightness);

  List<Widget> infos(Series series) => [
        InfoLabel(
          label: 'Seasons',
          labelStyle: Manager.bodyStrongStyle,
          child: Text('${series.numberOfSeasons}'),
        ),
        InfoLabel(
          label: 'Episodes',
          labelStyle: Manager.bodyStrongStyle,
          child: Text('${series.totalEpisodes}'),
        ),
        if (series.anilistData?.status != null)
          InfoLabel(
            label: 'Status',
            labelStyle: Manager.bodyStrongStyle,
            child: Text(series.anilistData!.status!.replaceAll('_', ' ').titleCase),
          ),
        if (series.format != null)
          InfoLabel(
            label: 'Format',
            labelStyle: Manager.bodyStrongStyle,
            child: Text(series.format!),
          ),
        if (series.seasonYear != null)
          InfoLabel(
            label: 'Year',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('${series.seasonYear}'),
          ),
        if (series.anilistData?.season != null)
          InfoLabel(
            label: 'Season',
            labelStyle: Manager.bodyStrongStyle,
            child: Text(series.anilistData!.season!.toLowerCase().titleCase),
          ),
        if (series.rating != null)
          InfoLabel(
            label: 'Rating',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('${series.rating! / 10}/10'),
          ),
        if (series.meanScore != null)
          InfoLabel(
            label: 'Mean Score',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('${series.meanScore! / 10}/10'),
          ),
        if (series.highestUserScore != null && series.highestUserScore! > 0)
          InfoLabel(
            label: 'User Score',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('${series.highestUserScore! / 10}/10'),
          ),
        if (series.popularity != null)
          InfoLabel(
            label: 'Popularity',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('#${series.popularity}'),
          ),
        if (series.anilistData?.favourites != null)
          InfoLabel(
            label: 'Favourites',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('${series.anilistData!.favourites}'),
          ),
        if (series.metadata?.duration != null && series.metadata!.duration.inSeconds > 0)
          InfoLabel(
            label: 'Duration',
            labelStyle: Manager.bodyStrongStyle,
            child: Text(series.metadata!.durationFormatted),
          ),
        if (series.relatedMedia.isNotEmpty)
          InfoLabel(
            label: 'Related Media',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('${series.relatedMedia.length}'),
          ),
      ];

  //

  @override
  void initState() {
    super.initState();
    if (widget.seriesPath != null) {
      deferredPointerLink = DeferredPointerHandlerLink();
      nextFrame(() {
        _loadAnilistDataForCurrentSeries();
      });
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
        nextFrame(() {
          _loadAnilistDataForCurrentSeries();
        });
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
    if (widget.seriesPath != null && series != null && !series!.isLinked) {
      nextFrame(() {
        _loadAnilistDataForCurrentSeries();
      });
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
      id: isBanner ? 'bannerSelection:${series!.path}' : 'posterSelection:${series!.path}',
      title: isBanner ? 'Select Banner' : 'Select Poster',
      dialogDoPopCheck: () => true,
      builder: (context) => ImageSelectionDialog(
        series: series!,
        popContext: context,
        isBanner: isBanner,
      ),
    ).then((source) {
      if (source != null && mounted) setState(() {});
    });
  }

  Future<void> _loadAnilistDataForCurrentSeries() async {
    // TODO cancel fetch if screen gets disposed
    final series = this.series; // get current series
    if (!mounted || widget.seriesPath == null || series == null) return;

    if (!series.isLinked) {
      // Clear any Anilist data references to ensure UI updates
      series.anilistData = null;
      if (homeKey.currentContext?.mounted ?? false) setState(() {});
      return;
    }

    // Load data for the primary mapping (or first mapping if no primary)
    final anilistId = series.primaryAnilistId ?? series.anilistMappings.first.anilistId;
    await _loadAnilistData(anilistId);
  }

  Future<void> loadAnilistData(int id) async => await _loadAnilistData(id);

  Future<void> _loadAnilistData(int anilistId) async {
    final series = this.series;
    if (series == null) return;

    try {
      final anime = await SeriesLinkService().fetchAnimeDetails(anilistId);

      if (anime != null) {
        // Store the original dominant color to check if it changes
        final Color? originalDominantColor = series.dominantColor;

        setState(() {
          // Find the mapping with this ID
          for (var i = 0; i < series.anilistMappings.length; i++) {
            if (series.anilistMappings[i].anilistId == anilistId) {
              series.anilistMappings[i] = AnilistMapping(
                localPath: series.anilistMappings[i].localPath,
                anilistId: anilistId,
                title: series.anilistMappings[i].title,
                lastSynced: now,
                anilistData: anime,
              );

              // Also update the series.anilistData if this is the primary
              if (series.primaryAnilistId == anilistId || series.primaryAnilistId == null) {
                series.anilistData = anime;
              }

              break; // Break after updating the mapping
            }
          }
        });

        // Calculate dominant color (this will update it if needed)
        await series.calculateDominantColor(forceRecalculate: true);

        if (!mounted || this.series == null) return; // in case series was disposed during the async operation
        Manager.setState(() => Manager.currentDominantColor = series.dominantColor);

        // Fetch episode titles from AniList
        try {
          final episodeTitlesUpdated = await Manager.episodeTitleService.fetchAndUpdateEpisodeTitles(series);
          if (episodeTitlesUpdated && mounted) {
            logTrace('Episode titles updated, refreshing UI');
            setState(() {}); // Refresh UI to show updated episode titles
          }
        } catch (e) {
          logErr('Error fetching episode titles', e);
        }

        // Only save if dominant color changed or was newly set
        if (originalDominantColor?.value != series.dominantColor?.value) {
          // Save the updated series to the library

          final BuildContext? ctx;
          if (mounted)
            ctx = context;
          else
            ctx = rootNavigatorKey.currentContext;

          if (ctx != null && ctx.mounted) {
            try {
              final library = Provider.of<Library>(ctx, listen: false);
              await library.updateSeries(series, invalidateCache: false);

              if (libraryScreenKey.currentState != null) {
                libraryScreenKey.currentState!.updateSeriesInSortCache(series);
              }
              logTrace('Dominant color changed, saving series');
            } catch (e) {
              logErr('Error updating series: $e');
            }
          }
        }
      } else if (ConnectivityService().isOffline) {
        logWarn('Failed to fetch AniList details for ID: $anilistId - device is offline');
      } else {
        logErr('Failed to load Anilist data for ID: $anilistId');
      }
    } catch (e) {
      // Check if it's an expected offline error
      if (!RetryUtils.isExpectedOfflineError(e)) {
        logErr('Failed to load Anilist data for ID: $anilistId', e);
      } else {
        logDebug('Skipping Anilist data fetch - device is offline');
      }
    }
  }

  void toggleSeasonExpander(int seasonNumber) {
    final expanderKey = _seasonExpanderKeys[seasonNumber];
    if (expanderKey?.currentState != null) {
      setState(() {
        expanderKey?.currentState!.toggle();
      });
    } else {
      logWarn('No expander key found for season $seasonNumber');
    }
  }

  void _ensureSeasonKeys(Series series) {
    // For numbered seasons
    for (int i = 1; i <= 10; i++) {
      // Support up to 10 seasons
      _seasonExpanderKeys.putIfAbsent(i, () => GlobalKey<ExpandingStickyHeaderBuilderState>());
    }

    // For "Other Episodes" (season 0)
    _seasonExpanderKeys.putIfAbsent(0, () => GlobalKey<ExpandingStickyHeaderBuilderState>());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.seriesPath == null) return Container(color: Colors.red);

    return Selector<Library, Series?>(
      selector: (_, library) => library.getSeriesByPath(widget.seriesPath!),
      shouldRebuild: (prev, next) => prev != next,
      builder: (context, series, child) {
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
            content: _buildEpisodesList(context),
            backgroundColor: dominantColor,
            onHeaderCollapse: () => _descriptionController.collapse(),
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
                series: series,
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
                                dominantColor.withOpacity(0.27),
                                Colors.transparent,
                              ],
                            ),
                            color: enabled ? (series.dominantColor ?? Manager.accentColor).withOpacity(0.75) : Colors.transparent,
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
                  Builder(
                    builder: (context) {
                      final library = context.watch<Library>();
                      final isIndexing = library.isIndexing;
                      final isWatched = series.watchedPercentage == 1;
                      
                      return _buildButton(
                        (isWatched || isIndexing)
                            ? null
                            : () {
                                // Check if the action should be disabled during indexing
                                if (library.lockManager.shouldDisableAction(UserAction.markSeriesWatched)) {
                                  snackBar(
                                    library.lockManager.getDisabledReason(UserAction.markSeriesWatched),
                                    severity: InfoBarSeverity.warning,
                                  );
                                  return;
                                }
                                
                                showSimpleManagedDialog(
                                  context: context,
                                  id: 'confirmWatchAll',
                                  title: 'Confirm Watch All',
                                  body: 'Are you sure you want to mark all episodes of "${series.displayTitle}" as watched?',
                                  positiveButtonText: 'Confirm',
                                  onPositive: () => library.markSeriesWatched(series),
                                );
                              },
                        const Icon(FluentIcons.check_mark),
                        isIndexing 
                            ? 'Cannot mark while library is indexing, please wait.' 
                            : (isWatched 
                                ? 'You have already watched all episodes' 
                                : 'Mark All as Watched'),
                      );
                    },
                  ),
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
            child: parser.parse(series.description!, selectable: true, selectionColor: series.dominantColor),
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
      setStateCallback: () => setState(() {}),
      content: _buildInfoBarContent(series),
      footerPadding: EdgeInsets.all(8.0),
      footer: [
        if (series.seasons.isNotEmpty && anilistProvider.isLoggedIn)
          Builder(
            builder: (context) {
              final library = context.watch<Library>();
              final isIndexing = library.isIndexing;
              
              return StandardButton(
                expand: true,
                tooltip: isIndexing 
                    ? 'Cannot link while library is indexing, please wait.'
                    : (!series.isLinked ? 'Link with Anilist' : 'Manage Anilist Links'),
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
                  // Check if the action should be disabled during indexing
                  if (library.lockManager.shouldDisableAction(UserAction.anilistOperations)) {
                    snackBar(
                      library.lockManager.getDisabledReason(UserAction.anilistOperations),
                      severity: InfoBarSeverity.warning,
                    );
                    return;
                  }
                  
                  linkWithAnilist(context, series, _loadAnilistData, setState);
                },
                isButtonDisabled: anilistProvider.isOffline || isIndexing,
              );
            },
          ),
      ],
      poster: ({required imageProvider, required width, required height, required squareness, required offset}) {
        return DeferPointer(
          link: deferredPointerLink,
          paintOnTop: true,
          child: SizedBox(
            height: height - offset,
            width: width,
            child: ShiftClickableHover(
              series: series,
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
                                dominantColor.withOpacity(.2),
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

  Widget _buildInfoBarContent(Series series) {
    final infos_ = infos(series);

    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Info', style: FluentTheme.of(context).typography.subtitle),
          VDiv(8),

          if (series.anilistMappings.length > 1) ...[
            InfoLabel(
              label: 'Anilist Source',
              child: ComboBox<int>(
                isExpanded: true,
                placeholder: const Text('Select Anilist source'),
                items: series.anilistMappings.map((mapping) {
                  final title = mapping.title ?? 'Anilist ID: ${mapping.anilistId}';
                  return ComboBoxItem<int>(
                    value: mapping.anilistId,
                    child: SizedBox(
                      width: ScreenUtils.kInfoBarWidth - 106,
                      child: Tooltip(
                        message: title,
                        child: Text(
                          title,
                          style: Manager.captionStyle.copyWith(fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                value: series.primaryAnilistId,
                onChanged: (value) async {
                  if (value != null) {
                    setState(() {
                      series.primaryAnilistId = value;
                    });

                    if (libraryScreenKey.currentState != null) libraryScreenKey.currentState!.updateSeriesInSortCache(series);
                    // Fetch and load Anilist data
                    setState(() {
                      _loadAnilistData(value);
                    });
                  }
                },
              ),
            ),
            VDiv(16),
          ],

          // Series metadata
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: constraints.maxWidth / 100,
            ),
            itemCount: infos_.length,
            itemBuilder: (context, index) {
              final info = infos_[index];
              return info;
            },
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
            child: ProgressBar(
              value: series.watchedPercentage * 100,
              activeColor: dominantColor,
              backgroundColor: Colors.white.withOpacity(.3),
            ),
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
      child: (_) => mat.Tooltip(
        richMessage: WidgetSpan(
          child: Text(
            label,
            style: TextStyle(color: Colors.white),
          ),
        ),
        decoration: BoxDecoration(
          color: Color.lerp(Color.lerp(Colors.black, Colors.white, 0.2)!, dominantColor, 0.4)!.withOpacity(0.8),
          borderRadius: BorderRadius.circular(5.0),
        ),
        preferBelow: true,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: IconButton(
            style: ButtonStyle(
              foregroundColor: ButtonState.all(Colors.white.withOpacity(onTap != null ? 1 : 0)),
              elevation: ButtonState.all(0),
              shape: ButtonState.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              )),
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

  Widget _buildEpisodesList(BuildContext context) {
    // Make sure we have the season keys initialized
    _ensureSeasonKeys(series!);

    if (series!.seasons.isNotEmpty) {
      // Multiple seasons - display by season
      final List<Widget> seasonWidgets = [];

      // Add a section for each season
      for (int i = 1; i <= series!.seasons.length; i++) {
        final seasonEpisodes = series!.getEpisodesForSeason(i);
        final seasonName = series!.seasons[i - 1].prettyName;
        // Display all seasons, even if they're empty
        seasonWidgets.add(
          EpisodeGrid(
            title: seasonName,
            episodes: seasonEpisodes,
            initiallyExpanded: true,
            expanderKey: _seasonExpanderKeys[i],
            onTap: (episode) => _playEpisode(episode),
            series: series!,
            isReloadingSeries: isReloadingSeries,
          ),
        );
      }

      // Add uncategorized episodes if any
      final uncategorizedEpisodes = series!.getUncategorizedEpisodes();
      if (uncategorizedEpisodes.isNotEmpty) {
        seasonWidgets.add(
          EpisodeGrid(
            title: 'Others',
            episodes: uncategorizedEpisodes,
            initiallyExpanded: true,
            expanderKey: _seasonExpanderKeys[0],
            onTap: (episode) => _playEpisode(episode),
            series: series!,
          ),
        );
      }

      return Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 12.0,
          children: seasonWidgets,
        ),
      );
    } else {
      // Single season - show simple grid
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: EpisodeGrid(
          collapsable: false,
          episodes: series!.getEpisodesForSeason(1),
          onTap: (episode) => _playEpisode(episode),
          series: series!,
        ),
      );
    }
  }

  void _playEpisode(Episode episode) {
    final library = Provider.of<Library>(context, listen: false);
    library.playEpisode(episode);
  }
}

void linkWithAnilist(BuildContext context, Series? series, Future<void> Function(int) loadData, void Function(VoidCallback) setState) async {
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
    barrierColor: series.dominantColor?.withOpacity(0.5),
    canUserPopDialog: true,
    closeExistingDialogs: true,
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
        int newMappingsCount = 0;

        for (final mapping in mappings) {
          bool isNew = !oldMappings.any((m) => m.anilistId == mapping.anilistId && m.localPath == mapping.localPath);
          if (isNew) newMappingsCount++;
        }

        // Update the series mappings
        series.anilistMappings = mappings;

        // Ensure the library gets saved
        await library.updateSeriesMappings(series, mappings);

        // If links were added
        if (newMappingsCount > 0) {
          snackBar(
            'Successfully linked $newMappingsCount ${newMappingsCount == 1 ? 'new item' : 'new items'} with Anilist',
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

        // Load Anilist data for the primary mapping
        if (mappings.isNotEmpty) {
          final primaryId = series.primaryAnilistId ?? mappings.first.anilistId;
          await loadData(primaryId);
        }

        // Update the series with the new mappings
        Manager.currentDominantColor = series.dominantColor;
        if (context.mounted) setState(() {});
      },
    ),
  );
}
