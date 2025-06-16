import 'dart:async';
import 'dart:math' as math;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:provider/provider.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:defer_pointer/defer_pointer.dart';

import '../main.dart';
import '../services/library/library_provider.dart';
import '../services/navigation/show_info.dart';
import '../services/navigation/statusbar.dart';
import '../utils/path_utils.dart';
import '../widgets/buttons/button.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../widgets/buttons/wrapper.dart';
import '../widgets/dialogs/link_anilist_multi.dart';
import '../widgets/dialogs/poster_select.dart';
import '../enums.dart';
import '../manager.dart';
import '../models/anilist/mapping.dart';
import '../models/series.dart';
import '../models/episode.dart';
import '../services/anilist/linking.dart';
import '../services/navigation/dialogs.dart';
import '../services/navigation/shortcuts.dart';
import '../utils/image_utils.dart';
import '../utils/logging.dart';
import '../utils/screen_utils.dart';
import '../utils/time_utils.dart';
import '../widgets/episode_grid.dart';
import '../widgets/gradient_mask.dart';
import '../widgets/shift_clickable_hover.dart';
import '../widgets/transparency_shadow_image.dart';
import 'anilist_settings.dart';

class SeriesScreen extends StatefulWidget {
  final PathString seriesPath;
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
  // final ScrollController _scrollController = ScrollController();
  late double _headerHeight;
  bool posterChangeDisabled = false;
  bool bannerChangeDisabled = false;

  final Map<int, GlobalKey<ExpanderState>> _seasonExpanderKeys = {};

  bool _isPosterHovering = false;
  DeferredPointerHandlerLink deferredPointerLink = DeferredPointerHandlerLink();
  bool _isBannerHovering = false;

  Series? get series {
    final library = Provider.of<Library>(context, listen: false);
    return library.getSeriesByPath(widget.seriesPath);
  }

  Color get dominantColor =>
      series?.dominantColor ?? //
      FluentTheme.of(context).accentColor.defaultBrushFor(FluentTheme.of(context).brightness);

  //

  @override
  void initState() {
    super.initState();
    _headerHeight = ScreenUtils.kMaxHeaderHeight;
    nextFrame(() {
      _loadAnilistDataForCurrentSeries();
    });
  }

  ColorFilter get colorFilter => ColorFilter.matrix([
        // Scale down RGB channels (darken)
        0.7, 0, 0, 0, 0,
        0, 0.7, 0, 0, 0,
        0, 0, 0.7, 0, 0,
        0, 0, 0, 1, 0,
      ]);

  void selectImage(BuildContext context, bool isBanner) {
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
      if (source != null && mounted) Manager.setState();
    });
  }

  Future<void> _loadAnilistDataForCurrentSeries() async {
    if (series == null) return;

    if (!series!.isLinked) {
      // Clear any Anilist data references to ensure UI updates
      series!.anilistData = null;
      Manager.setState();
      return;
    }

    // Load data for the primary mapping (or first mapping if no primary)
    final anilistId = series!.primaryAnilistId ?? series!.anilistMappings.first.anilistId;
    await _loadAnilistData(anilistId);
  }

  Future<void> loadAnilistData(int id) async => await _loadAnilistData(id);

  Future<void> _loadAnilistData(int anilistId) async {
    if (series == null) return;

    final anime = await SeriesLinkService().fetchAnimeDetails(anilistId);

    if (anime != null) {
      // Store the original dominant color to check if it changes
      final Color? originalDominantColor = series!.dominantColor;

      setState(() {
        // Find the mapping with this ID
        for (var i = 0; i < series!.anilistMappings.length; i++) {
          if (series!.anilistMappings[i].anilistId == anilistId) {
            series!.anilistMappings[i] = AnilistMapping(
              localPath: series!.anilistMappings[i].localPath,
              anilistId: anilistId,
              title: series!.anilistMappings[i].title,
              lastSynced: now,
              anilistData: anime,
            );

            // Also update the series.anilistData if this is the primary
            if (series!.primaryAnilistId == anilistId || series!.primaryAnilistId == null) {
              series!.anilistData = anime;
            }

            break; // Break after updating the mapping
          }
        }
      });

      // Calculate dominant color (this will update it if needed)
      await series!.calculateDominantColor(forceRecalculate: true);

      // Only save if dominant color changed or was newly set
      if (originalDominantColor?.value != series!.dominantColor?.value) {
        // Save the updated series to the library

        final BuildContext ctx;
        if (mounted)
          ctx = context;
        else
          ctx = Manager.context;
          
        // ignore: use_build_context_synchronously
        final library = Provider.of<Library>(ctx, listen: false);
        await library.updateSeries(series!, invalidateCache: false);

        if (libraryScreenKey.currentState != null) {
          libraryScreenKey.currentState!.updateSeriesInSortCache(series!);
        }
        logTrace('Dominant color changed, saving series');
      }
    } else {
      logErr('Failed to load Anilist data for ID: $anilistId');
    }
  }

  void toggleSeasonExpander(int seasonNumber) {
    final expanderKey = _seasonExpanderKeys[seasonNumber];
    if (expanderKey?.currentState != null) {
      final isOpen = expanderKey!.currentState!.isExpanded;
      setState(() {
        expanderKey.currentState!.isExpanded = !isOpen;
      });
    } else {
      logWarn('No expander key found for season $seasonNumber');
    }
  }

  void _ensureSeasonKeys(Series series) {
    // For numbered seasons
    for (int i = 1; i <= 10; i++) {
      // Support up to 10 seasons
      _seasonExpanderKeys.putIfAbsent(i, () => GlobalKey<ExpanderState>());
    }

    // For "Other Episodes" (season 0)
    _seasonExpanderKeys.putIfAbsent(0, () => GlobalKey<ExpanderState>());
  }

  @override
  Widget build(BuildContext context) {
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
      key: ValueKey(series!.path),
      link: deferredPointerLink,
      child: AnimatedContainer(
        duration: gradientChangeDuration,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              dominantColor.withOpacity(series!.isLinked ? 0.5 : 0.15),
              Colors.transparent,
            ],
          ),
        ),
        child: _buildSeriesContent(context, series!),
      ),
    );
  }

  String _getDisplayPath(PathString path, PathString seriesPath) {
    if (path == seriesPath) return 'Main Series Folder';
    if (path.path.startsWith(seriesPath.path)) {
      return path.path.substring(seriesPath.path.length + 1);
    }
    return path.path;
  }

  Widget _buildSeriesHeader(BuildContext context, Series series) {
    return FutureBuilder(
        future: series.getBannerImage(),
        builder: (context, snapshot) {
          return Stack(
            children: [
              // Banner
              ShiftClickableHover(
                  series: series,
                  enabled: _isBannerHovering && !bannerChangeDisabled,
                  onTap: (context) => selectImage(context, true),
                  onEnter: bannerChangeDisabled ? () {} : () => setState(() => _isBannerHovering = true),
                  onExit: () {
                    StatusBarManager().hide();
                    setState(() => _isBannerHovering = false);
                  },
                  onHover: bannerChangeDisabled ? null : () => StatusBarManager().show(KeyboardState.shiftPressedNotifier.value ? 'Click to change Banner' : 'Shift-click to change Banner', autoHideDuration: Duration.zero),
                  finalChild: (BuildContext context, bool enabled) => LayoutBuilder(builder: (context, constraints) {
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
                            // Title and watched percentage
                            Positioned(
                              bottom: 0,
                              left: math.max(constraints.maxWidth / 2 - 380 + 10, ScreenUtils.kInfoBarWidth - (6 * 2) + 42),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Series title
                                  SizedBox(
                                    width: ScreenUtils.kMaxContentWidth - ScreenUtils.kInfoBarWidth - 32,
                                    child: Text(
                                      series.displayTitle,
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  VDiv(8),
                                  // Watched percentage
                                  Text(
                                    'Episodes: ${series.totalEpisodes} | Watched: ${series.watchedEpisodes} (${(series.watchedPercentage * 100).round()}%)',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  VDiv(12),
                                ],
                              ),
                            ),
                          ],
                        );
                      })),
              // temp buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildButton(
                    widget.onBack,
                    const Icon(FluentIcons.back),
                    'Back to Library',
                  ),
                  _buildButton(
                    () {
                      logInfo(series);
                      showSimpleManagedDialog(
                        context: context,
                        id: 'showSeries:${series.hashCode}',
                        title: 'Series Info',
                        constraints: const BoxConstraints(
                          maxWidth: 800,
                          maxHeight: 500,
                        ),
                        body: series.toString(),
                      );
                    },
                    const Icon(FluentIcons.info),
                    'Print Series',
                  ),
                  _buildButton(
                    series.watchedPercentage == 1
                        ? null
                        : () => showSimpleManagedDialog(
                              context: context,
                              id: 'confirmWatchAll',
                              title: 'Confirm Watch All',
                              body: 'Are you sure you want to mark all episodes of "${series.displayTitle}" as watched?',
                              positiveButtonText: 'Confirm',
                              onPositive: () {
                                final library = context.read<Library>();
                                library.markSeriesWatched(series);
                              },
                            ),
                    const Icon(FluentIcons.check_mark),
                    series.watchedPercentage == 1 ? 'You have already watched all episodes' : 'Mark All as Watched',
                  ),
                  if (context.watch<AnilistProvider>().isLoggedIn)
                    _buildButton(
                      series.seasons.isNotEmpty
                          ? () => linkWithAnilist(
                                context,
                                series,
                                _loadAnilistData,
                                setState,
                              )
                          : null,
                      Icon(
                        series.anilistId != null ? FluentIcons.link : FluentIcons.add_link,
                        color: Colors.white,
                      ),
                      series.anilistId != null ? 'Update Anilist Link' : 'Link with Anilist',
                    ),
                ],
              )
            ],
          );
        });
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

  Widget _infoBar(Series series) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Info', style: FluentTheme.of(context).typography.subtitle),
          VDiv(8),

          if (series.anilistMappings.length > 1) ...[
            InfoLabel(
              label: 'Anilist Source',
              child: ComboBox<int>(
                placeholder: const Text('Select Anilist source'),
                isExpanded: true,
                items: series.anilistMappings.map((mapping) {
                  final title = mapping.title ?? 'Anilist ID: ${mapping.anilistId}';
                  final path = _getDisplayPath(mapping.localPath, series.path);
                  return ComboBoxItem<int>(
                    value: mapping.anilistId,
                    child: Text('$title ($path)'),
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
                    await _loadAnilistData(value);
                  }
                },
              ),
            ),
            VDiv(16),
          ],

          // Add description if available
          if (series.description != null) ...[
            Text(
              series.description!,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            VDiv(16),
          ],

          // Series metadata
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              InfoLabel(
                label: 'Seasons',
                child: Text('${series.seasons.isNotEmpty ? series.seasons.length : 1}'),
              ),
              InfoLabel(
                label: 'Episodes',
                child: Text('${series.totalEpisodes}'),
              ),
              if (series.format != null)
                InfoLabel(
                  label: 'Format',
                  child: Text(series.format!),
                ),
              if (series.rating != null)
                InfoLabel(
                  label: 'Rating',
                  child: Text('${series.rating! / 10}/10'),
                ),
              if (series.popularity != null)
                InfoLabel(
                  label: 'Popularity',
                  child: Text('#${series.popularity}'),
                ),
              if (series.relatedMedia.isNotEmpty)
                InfoLabel(
                  label: 'Related Media',
                  child: Text('${series.relatedMedia.length}'),
                ),
            ],
          ),

          // Genre tags
          if (series.genres.isNotEmpty) ...[
            VDiv(16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: series.genres.map((genre) => Chip(text: Text(genre))).toList(),
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
          ...[
            for (int i = 0; i < 30; i++)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('test $i', style: FluentTheme.of(context).typography.body),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeriesContent(BuildContext context, Series series) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          // Sticky header
          AnimatedContainer(
            height: _headerHeight,
            width: double.infinity,
            duration: stickyHeaderDuration,
            curve: Curves.ease,
            alignment: Alignment.center,
            child: // Header with poster as background
                _buildSeriesHeader(context, series),
          ),
          Expanded(
            child: SizedBox(
              width: ScreenUtils.kMaxContentWidth,
              child: Row(
                children: [
                  // Info bar on the left
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 14.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      height: double.infinity,
                      width: ScreenUtils.kInfoBarWidth,
                      child: FutureBuilder(
                          future: series.getPosterImage(),
                          builder: (context, snapshot) {
                            ImageProvider? imageProvider = snapshot.data;

                            return FutureBuilder(
                              future: getImageDimensions(imageProvider),
                              builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
                                double posterWidth = 230.0; // Default width
                                double posterHeight = 230.0; // Default height 326.0
                                final double squareSize = 253.0;
                                double getInfoBarOffset = 0;

                                if (snapshot.hasData && snapshot.data != null) {
                                  final Size originalSize = snapshot.data!;

                                  // Avoid division by zero when image is empty
                                  if (originalSize.width > 0 && originalSize.height > 0) {
                                    final double aspectRatio = originalSize.height / originalSize.width;

                                    double maxWidth = 326.0;
                                    double maxHeight = 300.0;

                                    // Constrain aspect ratio between ScreenUtils.kDefaultAspectRatio and 1.41
                                    double effectiveAspectRatio = aspectRatio;
                                    if (aspectRatio < ScreenUtils.kDefaultAspectRatio) effectiveAspectRatio = ScreenUtils.kDefaultAspectRatio;
                                    if (aspectRatio > 1.41) effectiveAspectRatio = 1.41;

                                    // For square images (aspect ratio around 1), fit to the green box
                                    if (effectiveAspectRatio < 1) {
                                      // Wider than tall: linearly interpolate width based on distance from square
                                      // As AR approaches ScreenUtils.kDefaultAspectRatio, width approaches maxWidth (326)
                                      double ratioFactor = (1 - effectiveAspectRatio) / (1 - ScreenUtils.kDefaultAspectRatio); // 0 when AR=1, 1 when AR=ScreenUtils.kDefaultAspectRatio
                                      posterWidth = squareSize + (maxWidth - squareSize) * ratioFactor;
                                      posterHeight = posterWidth * effectiveAspectRatio;

                                      // Ensure we don't exceed height bound
                                      if (posterHeight > maxHeight) {
                                        posterHeight = maxHeight;
                                        posterWidth = posterHeight / effectiveAspectRatio;
                                      }
                                    } else {
                                      double ratioFactor = (effectiveAspectRatio - 1) / (1.41 - 1); // 0 when AR=1, 1 when AR=1.41
                                      posterHeight = squareSize + (maxHeight - squareSize) * ratioFactor;
                                      posterWidth = posterHeight / effectiveAspectRatio;

                                      // Ensure we don't exceed width bound
                                      if (posterWidth > maxWidth) {
                                        posterWidth = maxWidth;
                                        posterHeight = posterWidth * effectiveAspectRatio;
                                      }
                                    }
                                    getInfoBarOffset = math.max(posterHeight - squareSize - 16, 0);
                                  }
                                }

                                final double squareness = (getInfoBarOffset / 31);
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Info bar
                                    Positioned.fill(
                                      child: FadingEdgeScrollView(
                                        gradientStops: [
                                          (squareness * 0.025),
                                          (squareness * 0.04) + 0.025,
                                          (squareness * 0.075) + 0.05,
                                          0.9,
                                          0.95,
                                          0.98,
                                        ],
                                        // debug: true,
                                        child: ScrollConfiguration(
                                          behavior: ScrollConfiguration.of(context).copyWith(overscroll: true, platform: TargetPlatform.windows, scrollbars: false),
                                          child: DynMouseScroll(
                                            stopScroll: KeyboardState.ctrlPressedNotifier,
                                            scrollSpeed: 1.0,
                                            enableSmoothScroll: Manager.animationsEnabled,
                                            durationMS: 350,
                                            animationCurve: Curves.easeOutQuint,
                                            builder: (context, controller, physics) {
                                              return SingleChildScrollView(
                                                controller: controller,
                                                physics: physics,
                                                child: Padding(
                                                  padding: EdgeInsets.only(top: math.max(0, getInfoBarOffset)),
                                                  child: _infoBar(series),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Poster image that overflows the info bar from above to appear 'in' the header
                                    AnimatedPositioned(
                                      duration: stickyHeaderDuration,
                                      left: (ScreenUtils.kInfoBarWidth) / 2 - (posterWidth) / 2,
                                      top: -(ScreenUtils.kMaxHeaderHeight) + 32,
                                      child: DeferPointer(
                                        link: deferredPointerLink,
                                        paintOnTop: true,
                                        // Poster
                                        child: ShiftClickableHover(
                                            series: series,
                                            enabled: _isPosterHovering && !posterChangeDisabled,
                                            onTap: (context) => selectImage(context, false),
                                            onEnter: posterChangeDisabled ? () {} : () => setState(() => _isPosterHovering = true),
                                            onExit: () {
                                              setState(() => _isPosterHovering = false);
                                              StatusBarManager().hide();
                                            },
                                            onHover: posterChangeDisabled ? null : () => StatusBarManager().show(KeyboardState.shiftPressedNotifier.value ? 'Click to change Poster' : 'Shift-click to change Poster', autoHideDuration: Duration.zero),
                                            finalChild: (BuildContext context, bool enabled) => Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    AnimatedContainer(
                                                      duration: shortStickyHeaderDuration,
                                                      width: posterWidth,
                                                      height: posterHeight,
                                                      child: Builder(builder: (context) {
                                                        if (imageProvider != null)
                                                          // Image available -> show it
                                                          return ShadowedImage(
                                                            imageProvider: imageProvider,
                                                            fit: BoxFit.cover,
                                                            colorFilter: series.posterImage != null ? ColorFilter.mode(Colors.black.withOpacity(0), BlendMode.darken) : null,
                                                            blurSigma: 10,
                                                            shadowColorOpacity: .5,
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
                                                          width: posterWidth,
                                                          height: posterHeight,
                                                          duration: shortStickyHeaderDuration,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(8.0),
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
                                                        child: Center(
                                                          child: Icon(FluentIcons.edit, size: 35, color: Colors.white),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                )),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          }),
                    ),
                  ),
                  // Content area on the right
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: FadingEdgeScrollView(
                        fadeEdges: const EdgeInsets.symmetric(vertical: 16),
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(overscroll: true, platform: TargetPlatform.windows, scrollbars: false),
                          child: DynMouseScroll(
                            stopScroll: KeyboardState.ctrlPressedNotifier,
                            scrollSpeed: 1.8,
                            enableSmoothScroll: Manager.animationsEnabled,
                            durationMS: 350,
                            animationCurve: Curves.easeOut,
                            builder: (context, controller, physics) {
                              controller.addListener(() {
                                final offset = controller.offset;
                                final double newHeight = offset > 0 ? ScreenUtils.kMinHeaderHeight : ScreenUtils.kMaxHeaderHeight;

                                if (newHeight != _headerHeight && mounted) //
                                  setState(() => _headerHeight = newHeight);
                              });

                              // Then use the controller for your scrollable content
                              return CustomScrollView(
                                controller: controller,
                                physics: physics,
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: _buildEpisodesList(context),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
        if (seasonEpisodes.isNotEmpty) {
          seasonWidgets.add(
            EpisodeGrid(
              title: 'Season $i',
              episodes: seasonEpisodes,
              initiallyExpanded: true,
              expanderKey: _seasonExpanderKeys[i],
              onTap: (episode) => _playEpisode(episode),
              series: series!,
            ),
          );
        }
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 12.0,
              children: seasonWidgets,
            ),
          ),
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

        // Calculate the number of new mappings
        final oldMappings = series.anilistMappings;
        int newMappingsCount = 0;

        for (final mapping in mappings) {
          bool isNew = !oldMappings.any((m) => m.anilistId == mapping.anilistId && m.localPath == mapping.localPath);
          if (isNew) newMappingsCount++;
        }

        // Important: Update the series mappings
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
        setState(() {});
      },
    ),
  );
}
