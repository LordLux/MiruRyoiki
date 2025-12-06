import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:miruryoiki/models/mapping_target.dart';
import 'package:provider/provider.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:recase/recase.dart';

import '../main.dart';
import '../models/anilist/anime.dart';
import '../services/connectivity/connectivity_service.dart';
import '../services/file_system/cache.dart';
import '../services/library/library_provider.dart';
import '../services/lock_manager.dart';
import '../services/navigation/show_info.dart';
import '../utils/path.dart';
import '../utils/shell.dart';
import '../utils/text.dart';
import '../widgets/animated_color_wrapper.dart';
import '../widgets/buttons/button.dart';
import '../widgets/buttons/wrapper.dart';
import '../widgets/dialogs/link_anilist.dart';
import '../enums.dart';
import '../manager.dart';
import '../models/anilist/mapping.dart';
import '../models/series.dart';
import '../models/episode.dart';
import '../services/anilist/linking.dart';
import '../services/navigation/dialogs.dart';
import '../utils/logging.dart';
import '../utils/retry.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import '../widgets/episode_grid.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/infobar.dart';
import '../widgets/page/page_template.dart';
import '../widgets/shift_clickable_hover.dart';
import '../widgets/shrinker.dart';
import '../widgets/simple_html_parser.dart';
import '../widgets/tooltip_wrapper.dart';
import '../widgets/transparency_shadow_image.dart';
import 'anilist_settings.dart';

class InnerSeriesScreen extends StatefulWidget {
  final VoidCallback onBack; // Callback to go back to the series screen
  final PathString seriesPath; // Parent Series
  final MappingTarget target; // Target episode or season
  final AnilistMapping? mapping; // The AnilistMapping for this target

  const InnerSeriesScreen({
    super.key,
    required this.onBack,
    required this.seriesPath,
    required this.target,
    required this.mapping,
  });

  @override
  InnerSeriesScreenState createState() => InnerSeriesScreenState();
}

class InnerSeriesScreenState extends State<InnerSeriesScreen> {
  late final SimpleHtmlParser parser;
  final ShrinkerController _descriptionController = ShrinkerController();

  bool isReloadingSeries = false;

  DeferredPointerHandlerLink? deferredPointerLink;

  AnilistMapping? _cachedMapping;
  late Series _cachedSeries;

  Color? dominantColor;

  List<Widget> infos() => [
        if (widget.target.isSeason)
          InfoLabel(
            label: 'Episodes',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('${widget.target.episodes.length}'),
          ),
        if (_cachedMapping?.anilistData?.status != null)
          InfoLabel(
            label: 'Status',
            labelStyle: Manager.bodyStrongStyle,
            child: Text(_cachedMapping!.anilistData!.status!.replaceAll('_', ' ').titleCase),
          ),
        if (_cachedMapping?.anilistData?.format != null)
          InfoLabel(
            label: 'Format',
            labelStyle: Manager.bodyStrongStyle,
            child: Text(_cachedMapping!.anilistData!.format!),
          ),
        if (_cachedMapping?.anilistData?.seasonYear != null)
          InfoLabel(
            label: 'Year',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('${_cachedMapping!.anilistData!.seasonYear}'),
          ),
        if (_cachedMapping?.anilistData?.season != null)
          InfoLabel(
            label: 'Season',
            labelStyle: Manager.bodyStrongStyle,
            child: Text(_cachedMapping!.anilistData!.season!.toLowerCase().titleCase),
          ),
        if (_cachedMapping?.anilistData?.averageScore != null)
          InfoLabel(
            label: 'Rating',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('${_cachedMapping!.anilistData!.averageScore! / 10}/10'),
          ),
        if (_cachedMapping?.anilistData?.meanScore != null)
          InfoLabel(
            label: 'Mean Score',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('${_cachedMapping!.anilistData!.meanScore! / 10}/10'),
          ),
        if (_cachedMapping?.anilistData?.popularity != null)
          InfoLabel(
            label: 'Popularity',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('#${_cachedMapping!.anilistData!.popularity}'),
          ),
        if (_cachedMapping?.anilistData?.favourites != null)
          InfoLabel(
            label: 'Favourites',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('${_cachedMapping!.anilistData!.favourites}'),
          ),
        if (widget.target.metadata?.duration != null && widget.target.metadata!.duration.inSeconds > 0)
          InfoLabel(
            label: 'Duration',
            labelStyle: Manager.bodyStrongStyle,
            child: Text(widget.target.metadata!.durationFormatted),
          ),
      ];

  //

  @override
  void initState() {
    super.initState();
    // Initialize the cached mapping from the widget
    _cachedMapping = widget.mapping;

    deferredPointerLink = DeferredPointerHandlerLink();
    parser = SimpleHtmlParser(context);
    // Use the current mapping's color
    dominantColor = Manager.currentDominantColor;

    // Initialize dominant color and fetch episode titles
    nextFrame(() => _initializeMappingData());
  }

  @override
  didUpdateWidget(covariant InnerSeriesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.target != oldWidget.target || widget.mapping != oldWidget.mapping) {
      // Mapping or target changed, update cached mapping and reload data
      _cachedMapping = widget.mapping;
      nextFrame(() => _initializeMappingData());
    }
  }

  @override
  void dispose() {
    deferredPointerLink?.dispose();
    super.dispose();
  }

  ColorFilter get colorFilter => ColorFilter.matrix([
        // Scale down RGB channels (darken)
        0.7, 0, 0, 0, 0,
        0, 0.7, 0, 0, 0,
        0, 0, 0.7, 0, 0,
        0, 0, 0, 1, 0,
      ]);

  /// Initialize mapping data: calculate dominant color and fetch episode titles
  Future<void> _initializeMappingData() async {
    if (!mounted || _cachedMapping == null) return;

    final mapping = _cachedMapping!;

    // Calculate dominant color from the mapping's anilistData (already fetched by SeriesScreen)
    dominantColor = await mapping.effectivePrimaryColor(forceRecalculate: false);
    if (!mounted) return;

    Manager.setState(() => Manager.currentDominantColor = dominantColor);

    // Fetch episode titles from AniList (this is mapping-specific and not done by SeriesScreen)
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

  /// Force reload AniList data for this mapping (called from link dialog)
  Future<void> loadAnilistData([int? anilistId]) async {
    final mapping = _cachedMapping;
    if (mapping == null) return;

    try {
      final AnilistAnime? anime = await SeriesLinkService().fetchAnimeDetails(anilistId ?? mapping.anilistId);

      if (anime != null) {
        // Update the cached mapping with fresh data
        if (mounted) setState(() => _cachedMapping = _cachedMapping?.copyWith(lastSynced: now, anilistData: anime));

        // Recalculate dominant color
        dominantColor = await mapping.effectivePrimaryColor(forceRecalculate: true);
        if (!mounted) return;

        Manager.setState(() => Manager.currentDominantColor = dominantColor);

        // Fetch episode titles
        try {
          final (newSeries, episodeTitlesUpdated) = await Manager.episodeTitleService.fetchAndUpdateEpisodeTitlesFromMapping(mapping);
          if (episodeTitlesUpdated && mounted) {
            setState(() {});
          }

          if (newSeries != null && libraryScreenKey.currentState != null) {
            libraryScreenKey.currentState!.updateSeriesInSortCache(newSeries);
          }
        } catch (e) {
          logErr('Error fetching episode titles', e);
        }

        if (mounted) setState(() {});
      } else if (ConnectivityService().isOffline) {
        logWarn('Failed to fetch AniList details for ID: ${anilistId ?? mapping.anilistId} - device is offline');
      } else {
        logErr('Failed to load Anilist data for ID: ${anilistId ?? mapping.anilistId}');
      }
    } catch (e) {
      if (!RetryUtils.isExpectedOfflineError(e)) {
        logErr('Failed to load Anilist data for ID: ${anilistId ?? mapping.anilistId}', e);
      } else {
        logDebug('Skipping Anilist data fetch - device is offline');
      }
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
    imageCache.cacheImage(imageUrl);
    return CachedNetworkImageProvider(imageUrl, errorListener: (error) => logWarn('Failed to load image from network: $error'));
  }

  @override
  Widget build(BuildContext context) {
    return Selector<Library, Series?>(
      selector: (_, library) => library.getSeriesByPath(widget.seriesPath),
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

        // Update the cached series reference
        _cachedSeries = series;

        return DeferredPointerHandler(
          key: ValueKey(series.path),
          link: deferredPointerLink,
          child: MiruRyoikiTemplatePage(
            headerWidget: _buildHeader(context),
            infobar: (_) => _buildInfoBar(context),
            content: _buildEpisodesList(context),
            backgroundColor: dominantColor,
            onHeaderCollapse: () => _descriptionController.collapse(),
          ),
        );
      },
    );
  }

  HeaderWidget _buildHeader(BuildContext context) {
    return HeaderWidget(
      image_widget: FutureBuilder<ImageProvider?>(
        future: _getMappingImage(banner: true),
        builder: (context, snapshot) {
          return Stack(
            children: [
              // Banner
              ShiftClickableHover(
                color: dominantColor,
                enabled: false,
                onTap: null,
                onEnter: () {},
                onExit: () {},
                onHover: null,
                finalChild: (BuildContext context, bool enabled) {
                  return AnimatedOpacity(
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
                            dominantColor?.withOpacity(0.27) ?? Colors.transparent,
                            Colors.transparent,
                          ],
                        ),
                        color: enabled ? (dominantColor ?? Manager.accentColor).withOpacity(0.75) : Colors.transparent,
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
                  // Builder(
                  //   builder: (context) {
                  //     final library = context.watch<Library>();
                  //     final isIndexing = library.isIndexing;
                  //     final isWatched = widget.target.watchedPercentage == 1;

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
                  //                 body: 'Are you sure you want to mark all episodes of "${widget.target.displayName}" as watched?',
                  //                 positiveButtonText: 'Confirm',
                  //                 onPositive: () => library.markTargetWatched(widget.target),
                  //               );
                  //             },
                  //       const Icon(FluentIcons.check_mark),
                  //       isIndexing ? 'Cannot mark while library is indexing, please wait.' : (isWatched ? 'You have already watched all episodes' : 'Mark All as Watched'),
                  //     );
                  //   },
                  // ),
                ],
              )
            ],
          );
        },
      ),
      colorFilter: null,
      titleLeftAligned: false,
      title: (style, constraints) => Text(widget.target.displayName, style: style),
      children: [
        // Add description if available
        if (_cachedMapping?.anilistData?.description != null) ...[
          VDiv(8),
          Shrinker(
            maxHeight: 150,
            minHeight: 45,
            controller: _descriptionController,
            child: parser.parse(_cachedMapping!.anilistData!.description!, selectable: true, selectionColor: dominantColor),
          ),
          VDiv(8),
        ],
      ],
    );
  }

  // Get the decoration image based on the banner image
  DecorationImage? _getBannerDecoration(ImageProvider? imageProvider) {
    if (imageProvider == null) return null;

    return DecorationImage(
      alignment: Alignment.topCenter,
      image: imageProvider,
      fit: BoxFit.cover,
      isAntiAlias: true,
      colorFilter: colorFilter,
    );
  }

  MiruRyoikiInfobar _buildInfoBar(BuildContext context) {
    // final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
    return MiruRyoikiInfobar(
      getPosterImage: _getMappingImage(banner: false),
      isProfilePicture: false,
      contentPadding: (posterExtraVertical) => EdgeInsets.only(left: 24.0, right: 24.0, bottom: 16.0, top: 16.0 + posterExtraVertical),
      setStateCallback: () {
        if (mounted) setState(() {});
      },
      content: _buildInfoBarContent(),
      footerPadding: EdgeInsets.all(8.0),
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
          onPressed: () => ShellUtils.openFolder(widget.mapping?.localPath.path ?? widget.seriesPath.path),
        ),
      ],
      // footer: [
      //   Builder(
      //     builder: (context) {
      //       final library = context.watch<Library>();
      //       final isIndexing = library.isIndexing;

      //       // Compute tooltip with switch-case outside of the widget
      //       String tooltipKey;
      //       if (!anilistProvider.isLoggedIn)
      //         tooltipKey = 'notLoggedIn';
      //       else if (isIndexing)
      //         tooltipKey = 'indexing';
      //       else if (!(_cachedMapping?.isLinked ?? false))
      //         tooltipKey = 'notLinked';
      //       else
      //         tooltipKey = 'linked';

      //       String tooltipText = switch (tooltipKey) {
      //         'indexing' => 'Cannot link while library is indexing, please wait.',
      //         'notLinked' => 'Link with Anilist',
      //         'linked' => 'Manage Anilist Links',
      //         'notLoggedIn' => 'You must be logged in to Anilist to link series.',
      //         _ => '',
      //       };

      //       return StandardButton(
      //         expand: true,
      //         tooltip: tooltipText,
      //         label: Row(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             Icon(_cachedMapping?.isLinked ?? false ? FluentIcons.link : FluentIcons.add_link),
      //             HDiv(4),
      //             Text(
      //               _cachedMapping?.isLinked ?? false ? 'Manage Anilist Links' : 'Link with Anilist',
      //               style: getStyleBasedOnAccent(false),
      //             ),
      //           ],
      //         ),
      //         onPressed: () {
      //           // Check if the action should be disabled during indexing
      //           if (library.lockManager.shouldDisableAction(UserAction.anilistOperations)) {
      //             snackBar(
      //               library.lockManager.getDisabledReason(UserAction.anilistOperations),
      //               severity: InfoBarSeverity.warning,
      //             );
      //             return;
      //           }

      //           linkWithAnilist(context, _cachedSeries, loadAnilistData, setState, _cachedMapping?.anilistId);
      //         },
      //         isButtonDisabled: anilistProvider.isOffline || isIndexing,
      //       );
      //     },
      //   ),
      // ],
      poster: ({required imageProvider, required width, required height, required squareness, required offset}) {
        return DeferPointer(
          link: deferredPointerLink,
          paintOnTop: true,
          child: SizedBox(
            height: height - offset,
            width: width,
            child: ShiftClickableHover(
              color: dominantColor,
              enabled: false,
              onTap: null,
              onEnter: () {},
              onExit: () {},
              onHover: null,
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
                              colorFilter: _cachedSeries.posterImage != null ? ColorFilter.mode(Colors.black.withOpacity(0), BlendMode.darken) : null,
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
                                dominantColor?.withOpacity(.2) ?? Colors.transparent,
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

  Widget _buildInfoBarContent() {
    final infos_ = infos();

    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          if (_cachedMapping?.anilistData?.genres.isNotEmpty ?? false) ...[
            VDiv(16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _cachedMapping!.anilistData!.genres.map((genre) => Chip(text: (color) => Text(genre, style: Manager.bodyStyle.copyWith(color: color)))).toList(),
            ),
          ],

          // Progress bar
          VDiv(16),
          SizedBox(
            width: 300,
            child: AnimatedColor(
                color: dominantColor,
                duration: gradientChangeDuration,
                builder: (color) {
                  return ProgressBar(
                    value: widget.target.watchedPercentage,
                    activeColor: color,
                    backgroundColor: Colors.white.withOpacity(.3),
                  );
                }),
          ),

          if (widget.target.metadata != null) ...[
            VDiv(16),
            Wrap(alignment: WrapAlignment.spaceBetween, spacing: 8, runSpacing: 8, children: [
              InfoLabel(
                label: 'Path',
                child: Text(widget.target.path.path, style: Manager.captionStyle),
              ),
              InfoLabel(
                label: 'Size',
                child: Text(widget.target.metadata!.fileSize(), style: Manager.captionStyle),
              ),
              InfoLabel(
                label: 'First Downloaded',
                child: Text(widget.target.metadata!.creationTime.pretty(), style: Manager.captionStyle),
              ),
              InfoLabel(
                label: 'Last Modified',
                child: Text(widget.target.metadata!.lastModified.pretty(), style: Manager.captionStyle),
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
        tooltip: Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
        preferBelow: true,
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
    return EpisodeGrid(
      collapsable: false,
      episodes: widget.target.episodes,
      onTap: (episode) => _playEpisode(episode),
      series: _cachedSeries,
      mapping: widget.mapping,
    );
  }

  void _playEpisode(Episode episode) {
    final library = Provider.of<Library>(context, listen: false);
    library.playEpisode(episode);
  }
}

void linkWithAnilist(BuildContext context, Series? series, Future<void> Function(int) loadData, void Function(VoidCallback) setState, [int? currentAnilistId]) async {
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

        // Load Anilist data for the current mapping, if we're in the screen of an already linked series / primary mapping
        if (mappings.isNotEmpty) await loadData(currentAnilistId ?? series.primaryAnilistId ?? mappings.first.anilistId);

        // Update the series with the new mappings
        Manager.currentDominantColor = await series.effectivePrimaryColor();
        Manager.setState();
      },
    ),
  );
}
