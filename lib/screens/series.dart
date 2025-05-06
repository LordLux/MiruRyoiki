import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as mat;
import 'package:flutter/services.dart';
import 'package:miruryoiki/services/navigation/show_info.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:provider/provider.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../dialogs/confirm_watch_all.dart';
import '../dialogs/link_anilist.dart';
import '../models/library.dart';
import '../models/series.dart';
import '../models/episode.dart';
import '../services/anilist/linking.dart';
import '../services/anilist/provider.dart';
import '../services/navigation/dialogs.dart';
import '../services/navigation/navigation.dart';
import '../theme.dart';
import '../widgets/episode_grid.dart';
import '../widgets/transparency_shadow_image.dart';
import 'anilist_settings.dart';

class SeriesScreen extends StatefulWidget {
  final String seriesPath;
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
  static const double _maxHeaderHeight = 290.0;
  static const double _minHeaderHeight = 150.0;
  static const double _infoBarWidth = 300.0;
  static const double _maxContentWidth = 1400.0;

  final Map<int, GlobalKey<ExpanderState>> _seasonExpanderKeys = {};

  Series? get series {
    final library = Provider.of<Library>(context, listen: false);
    return library.getSeriesByPath(widget.seriesPath);
  }

  Color get dominantColor =>
      series?.dominantColor ?? //
      FluentTheme.of(context).accentColor.defaultBrushFor(FluentTheme.of(context).brightness);

  // TEMP

  // Debug state
  bool showDebugControls = true;
  double testWidth = 230.0;
  double testHeight = 326.0;
  bool useTestMode = false;

  //

  @override
  void initState() {
    super.initState();
    _headerHeight = _maxHeaderHeight;
  }

  ColorFilter get colorFilter => ColorFilter.matrix([
        // Scale down RGB channels (darken)
        0.7, 0, 0, 0, 0,
        0, 0.7, 0, 0, 0,
        0, 0, 0.7, 0, 0,
        0, 0, 0, 1, 0,
      ]);

  void toggleSeasonExpander(int seasonNumber) {
    final expanderKey = _seasonExpanderKeys[seasonNumber];
    if (expanderKey?.currentState != null) {
      final isOpen = expanderKey!.currentState!.isExpanded;
      setState(() {
        expanderKey.currentState!.isExpanded = !isOpen;
      });
    } else {
      debugPrint('No expander key found for season $seasonNumber');
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
            const Text('Series not found'),
            const SizedBox(height: 16),
            Button(
              onPressed: widget.onBack,
              child: const Text('Back to Library'),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            series!.dominantColor?.withOpacity(0.15) ?? Colors.transparent,
            Colors.transparent,
          ],
        ),
      ),
      child: _buildSeriesContent(context, series!),
    );
  }

  Widget _buildSeriesHeader(BuildContext context, Series series) {
    return Stack(
      children: [
        Container(
          height: _maxHeaderHeight,
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
            image: _getBannerImage(series),
          ),
          padding: const EdgeInsets.only(bottom: 16.0),
          alignment: Alignment.bottomLeft,
          child: LayoutBuilder(builder: (context, constraints) {
            return Stack(
              children: [
                // Title and watched percentage
                Positioned(
                  bottom: 0,
                  left: max(constraints.maxWidth / 2 - 380 + 10, _infoBarWidth - (6 * 2) + 42),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Series title
                      SizedBox(
                        width: _maxContentWidth - _infoBarWidth - 32,
                        child: Text(
                          series.displayTitle,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Watched percentage
                      Text(
                        'Episodes: ${series.totalEpisodes} | Watched: ${series.watchedEpisodes} (${(series.watchedPercentage * 100).round()}%)',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
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
            _buildButton(
              series.watchedPercentage == 1
                  ? null
                  : () => showDialog(
                        context: context,
                        builder: (context) => ConfirmWatchAllDialog(series: series),
                      ),
              const Icon(FluentIcons.check_mark),
              series.watchedPercentage == 1 ? 'You have already watched all episodes' : 'Mark All as Watched',
            ),
            _buildButton(
              context.watch<AnilistProvider>().isLoggedIn ? () => _linkWithAnilist(context) : null,
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
  }

  DecorationImage? _getBannerImage(Series series) {
    // Priority: Anilist banner -> local poster
    if (series.bannerImage != null) // Prefer Anilist banner if available
      return DecorationImage(
        alignment: Alignment.topCenter,
        image: NetworkImage(series.bannerImage!),
        fit: BoxFit.cover,
        isAntiAlias: true,
        colorFilter: colorFilter,
      );
    if (series.folderImagePath != null) // Use local image as fallback if available
      return DecorationImage(
        image: FileImage(File(series.folderImagePath!)),
        fit: BoxFit.cover,
        isAntiAlias: true,
        colorFilter: colorFilter,
      );
    return null;
  }

  DecorationImage? _getPosterImage(Series series) {
    // Priority: Anilist poster -> local poster
    if (series.posterImage != null) // Prefer Anilist poster if available
      return DecorationImage(
        alignment: Alignment.topCenter,
        image: NetworkImage(series.posterImage!),
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          Colors.black.withOpacity(0.3),
          BlendMode.darken,
        ),
      );
    if (series.folderImagePath != null) // Use local image as fallback if available
      return DecorationImage(
        image: FileImage(File(series.folderImagePath!)),
        fit: BoxFit.contain,
      );
    return null;
  }

  Widget _infoBar(Series series) {
    final appTheme = context.watch<AppTheme>();
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Info',
            style: FluentTheme.of(context).typography.subtitle,
          ),
          const SizedBox(height: 8),

          // Add description if available
          if (series.description != null) ...[
            Text(
              series.description!,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: series.genres.map((genre) => Chip(text: Text(genre))).toList(),
            ),
          ],

          // Progress bar
          const SizedBox(height: 16),
          ProgressBar(
            value: series.watchedPercentage * 100,
            activeColor: series.dominantColor,
            backgroundColor: Colors.white.withOpacity(.3),
          ),
        ],
      ),
    );
  }

  Duration get stickyHeaderDuration => const Duration(milliseconds: 430);

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
              width: _maxContentWidth,
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
                      width: _infoBarWidth,
                      child: Builder(builder: (context) {
                        double posterWidth = 230.0; // Default width
                        double posterHeight = 326.0; // Default height

                        // Get image provider based on available sources
                        ImageProvider? imageProvider;
                        if (series.posterImage != null)
                          imageProvider = NetworkImage(series.posterImage!);
                        else if (series.folderImagePath != null) //
                          imageProvider = FileImage(File(series.folderImagePath!));

                        // If no image is available, show a placeholder
                        if (imageProvider == null) {
                          return Container(
                            width: posterWidth,
                            height: posterHeight,
                            decoration: BoxDecoration(color: dominantColor.withOpacity(0.5), borderRadius: BorderRadius.circular(4)),
                            child: const Center(child: Icon(FluentIcons.picture, size: 48, color: Colors.white)),
                          );
                        }
                        return FutureBuilder(
                            future: _getImageDimensions(imageProvider),
                            builder: (context, AsyncSnapshot<Size> snapshot) {
                              double squareSize = 253.0;
                              if (snapshot.hasData && snapshot.data != null) {
                                final Size originalSize = snapshot.data!;
                                final double aspectRatio = originalSize.height / originalSize.width;

                                double maxWidth = 326.0;
                                double maxHeight = 300.0;

                                // Constrain aspect ratio between 0.71 and 1.41
                                double effectiveAspectRatio = aspectRatio;
                                if (aspectRatio < 0.71) effectiveAspectRatio = 0.71;
                                if (aspectRatio > 1.41) effectiveAspectRatio = 1.41;

                                // For square images (aspect ratio around 1), fit to the green box
                                if (effectiveAspectRatio < 1) {
                                  // Wider than tall: linearly interpolate width based on distance from square
                                  // As AR approaches 0.71, width approaches maxWidth (326)
                                  double ratioFactor = (1 - effectiveAspectRatio) / (1 - 0.71); // 0 when AR=1, 1 when AR=0.71
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
                              }

                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned.fill(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: max(posterHeight - squareSize - 16, 0)),
                                      child: SingleChildScrollView(
                                        child: _infoBar(series),
                                      ),
                                    ),
                                  ),
                                  // Poster image
                                  AnimatedPositioned(
                                    duration: stickyHeaderDuration,
                                    left: (_infoBarWidth) / 2 - (posterWidth) / 2,
                                    top: -(_maxHeaderHeight) + 32,
                                    child: SizedBox(
                                      width: posterWidth,
                                      height: posterHeight,
                                      child: SizedBox(
                                        width: posterWidth,
                                        height: posterHeight,
                                        child: ShadowedImage(
                                          imageProvider: imageProvider!,
                                          fit: BoxFit.cover,
                                          colorFilter: series.posterImage != null ? ColorFilter.mode(Colors.black.withOpacity(0), BlendMode.darken) : null,
                                          blurSigma: 10,
                                          shadowOffset: const Offset(0, 0),
                                          shadowOpacity: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            });
                      }),
                    ),
                  ),
                  // Content area on the right
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(overscroll: true, platform: TargetPlatform.windows, scrollbars: false),
                        child: DynMouseScroll(
                          scrollSpeed: 2.0,
                          durationMS: 350,
                          animationCurve: Curves.easeInOutQuint,
                          builder: (context, controller, physics) {
                            controller.addListener(() {
                              final offset = controller.offset;
                              final double newHeight = offset > 0 ? _minHeaderHeight : _maxHeaderHeight;

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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(void Function()? onTap, Widget child, String label) {
    return mat.Tooltip(
      richMessage: WidgetSpan(
        child: Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
      ),
      decoration: BoxDecoration(
        color: Color.lerp(Color.lerp(Colors.black, Colors.white, 0.2)!, series!.dominantColor, 0.4)!.withOpacity(0.8),
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

// Add this method to the SeriesScreenState class
  Future<Size> _getImageDimensions(ImageProvider imageProvider) async {
    final Completer<Size> completer = Completer<Size>();

    final ImageStream stream = imageProvider.resolve(const ImageConfiguration());
    final ImageStreamListener listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      },
      onError: (exception, stackTrace) {
        completer.complete(const Size(230, 326)); // Default size on error
      },
    );

    stream.addListener(listener);

    // Make sure to remove the listener when done
    return completer.future.then((size) {
      stream.removeListener(listener);
      return size;
    });
  }

  void _playEpisode(Episode episode) async {
    // Launch MPC-HC with the episode file
    await OpenAppFile.open(episode.path);
  }

  void _linkWithAnilist(BuildContext context) async {
    if (series == null) {
      snackBar('Series not found', severity: InfoBarSeverity.error);
      return;
    }

    // Show the dialog
    final result = await showManagedDialog<bool>(
      context: context,
      id: 'linkAnilist:${series!.path}',
      title: 'Link to Anilist',
      data: series!.path,
      builder: (context) => AnilistLinkDialog(
        content: null,
        series: series!,
        linkService: SeriesLinkService(),
        onLink: (anilistId) async {
          final library = Provider.of<Library>(context, listen: false);
          await library.linkSeriesWithAnilist(series!, anilistId);
        },
      ),
    );
  }
}
