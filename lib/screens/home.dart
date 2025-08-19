import 'package:fluent_ui/fluent_ui.dart';
import 'dart:async';
import 'package:miruryoiki/models/anilist/user_list.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';

import '../services/library/library_provider.dart';
import '../models/series.dart';
import '../models/anilist/anime.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../services/navigation/shortcuts.dart';
import '../settings.dart';
import '../utils/color_utils.dart';
import '../utils/path_utils.dart';
import '../utils/screen_utils.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/page.dart';
import '../widgets/series_card.dart';
import '../manager.dart';

class HomeScreen extends StatefulWidget {
  final Function(PathString) onSeriesSelected;
  final ScrollController scrollController;

  const HomeScreen({
    super.key,
    required this.onSeriesSelected,
    required this.scrollController,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Color get lessGradientColor => shiftHue(Manager.accentColor.lighter, -60);
Color get moreGradientColor => shiftHue(Manager.accentColor.lighter, 10);

class _HomeScreenState extends State<HomeScreen> {
  Timer? _minuteRefreshTimer; // refresh relative times every minute

  @override
  void initState() {
    super.initState();
    _minuteRefreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {}); // triggers rebuild to update relative timestamps
    });
  }

  @override
  void dispose() {
    _minuteRefreshTimer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final library = Provider.of<Library>(context);
    final settings = Provider.of<SettingsManager>(context);

    return MiruRyoikiHeaderInfoBarPage(
      headerWidget: HeaderWidget(
        title: (_, __) => PageHeader(title: WelcomeWidget()),
        titleLeftAligned: true,
        fixed: 100,
        children: [
          VDiv(0),
        ],
      ),
      headerMaxHeight: 100,
      headerMinHeight: 100,
      content: _buildContent(library, settings),
      hideInfoBar: true,
      noHeaderBanner: true,
    );
  }

  Widget _buildContent(Library library, SettingsManager settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          title: 'Continue Watching',
          child: _buildContinueWatchingSection(),
        ),
        VDiv(8), // Reduced spacing between sections
        _buildSection(
          title: 'Upcoming Episodes',
          child: _buildUpcomingEpisodesSection(),
        ),
        // VDiv(16),
        // _buildSection(
        //   title: 'Recently Added',
        //   child: _buildRecentlyAddedSection(),
        // ),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Manager.subtitleStyle),
        VDiv(8),
        child,
      ],
    );
  }

  Widget _buildContinueWatchingSection() {
    final anilistProvider = Provider.of<AnilistProvider>(context);
    final library = Provider.of<Library>(context);

    // Get the "Watching" list from Anilist user lists
    final watchingList = anilistProvider.userLists[AnilistListApiStatus.CURRENT.name_];

    if (watchingList == null) {
      return _buildEmptyState('No watching list found', 'Unable to find your watching list from Anilist');
    }

    // Filter to get only series that are in "Watching" list and in library
    final watchingSeries = library.series.where((series) {
      // Only consider linked series
      if (!series.isLinked) return false;

      // Check if any of the series' Anilist mappings are in the watching list
      return series.anilistMappings.any((mapping) {
        return watchingList.entries.any((entry) => entry.media.id == mapping.anilistId);
      });
    }).toList();

    if (watchingSeries.isEmpty) {
      return _buildEmptyState('No series in your watching list', 'Link your series with Anilist and add them to your watching list');
    }

    // Sort by most recently updated first, then by progress percentage (higher first)
    watchingSeries.sort((a, b) {
      // Primary sort: most recently updated first
      final aUpdated = a.latestUpdatedAt ?? 0;
      final bUpdated = b.latestUpdatedAt ?? 0;
      final updatedComparison = bUpdated.compareTo(aUpdated);

      if (updatedComparison != 0) {
        return updatedComparison;
      }

      // Secondary sort: higher progress percentage first (for series updated at same time)
      final aProgress = a.watchedPercentage;
      final bProgress = b.watchedPercentage;
      return bProgress.compareTo(aProgress);
    });

    return _buildHorizontalSeriesList(watchingSeries);
  }

  Widget _buildUpcomingEpisodesSection() {
    final anilistProvider = Provider.of<AnilistProvider>(context);
    final library = Provider.of<Library>(context);

    // Get the "Watching" list from Anilist user lists
    final watchingList = anilistProvider.userLists[AnilistListApiStatus.CURRENT.name_];

    if (watchingList == null) {
      return _buildEmptyState('No watching list found', 'Unable to find your watching list from Anilist');
    }

    // Filter to get only series that are in "Watching" list, linked, and in library
    final watchingSeries = library.series.where((series) {
      // Only consider linked series
      if (!series.isLinked) return false;

      // Check if any of the series' Anilist mappings are in the watching list
      return series.anilistMappings.any((mapping) {
        return watchingList.entries.any((entry) => entry.media.id == mapping.anilistId);
      });
    }).toList();

    if (watchingSeries.isEmpty) {
      return _buildEmptyState('No series in your watching list', 'Link your series with Anilist and add them to your watching list');
    }

    // Use StreamBuilder approach with cached data for immediate display
    return _buildUpcomingEpisodesWithCache(watchingSeries, anilistProvider);
  }

  Widget _buildUpcomingEpisodesWithCache(List<Series> watchingSeries, AnilistProvider anilistProvider) {
    // Collect all unique anime IDs from the series
    final Set<int> animeIds = {};
    for (final series in watchingSeries) {
      for (final mapping in series.anilistMappings) {
        animeIds.add(mapping.anilistId);
      }
    }

    // Get cached data immediately
    final cachedUpcomingEpisodes = anilistProvider.getCachedUpcomingEpisodes(animeIds.toList(), refreshInBackground: true);

    // Filter to only series with cached upcoming episodes data
    final seriesWithUpcomingEpisodes = watchingSeries.where((series) {
      return series.anilistMappings.any((mapping) {
        final upcomingEpisode = cachedUpcomingEpisodes[mapping.anilistId];
        return upcomingEpisode != null && upcomingEpisode.airingAt != null;
      });
    }).toList();

    if (seriesWithUpcomingEpisodes.isEmpty) {
      // If no cached data, try to fetch fresh data
      return FutureBuilder<Map<int, AiringEpisode?>>(
        future: anilistProvider.getUpcomingEpisodes(animeIds.toList()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 150,
              decoration: BoxDecoration(
                color: FluentTheme.of(context).resources.cardBackgroundFillColorSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: ProgressRing(),
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildEmptyState('Error loading upcoming episodes', 'Failed to fetch airing information from Anilist');
          }

          final freshUpcomingEpisodes = snapshot.data ?? <int, AiringEpisode?>{};

          final freshSeriesWithUpcomingEpisodes = watchingSeries.where((series) {
            return series.anilistMappings.any((mapping) {
              final upcomingEpisode = freshUpcomingEpisodes[mapping.anilistId];
              return upcomingEpisode != null && upcomingEpisode.airingAt != null;
            });
          }).toList();

          if (freshSeriesWithUpcomingEpisodes.isEmpty) {
            return _buildEmptyState('No upcoming episodes', 'None of your watched series have upcoming episodes scheduled');
          }

          return _buildSortedUpcomingEpisodesList(freshSeriesWithUpcomingEpisodes, freshUpcomingEpisodes);
        },
      );
    }

    // We have cached data, display it immediately
    return _buildSortedUpcomingEpisodesList(seriesWithUpcomingEpisodes, cachedUpcomingEpisodes);
  }

  Widget _buildSortedUpcomingEpisodesList(List<Series> series, Map<int, AiringEpisode?> upcomingEpisodesMap) {
    // Sort by nearest airing date
    series.sort((a, b) {
      int? aNextAiring;
      int? bNextAiring;

      // Get the earliest upcoming episode for series A
      for (final mapping in a.anilistMappings) {
        final episode = upcomingEpisodesMap[mapping.anilistId];
        if (episode?.airingAt != null) {
          aNextAiring = aNextAiring == null ? episode!.airingAt! : (episode!.airingAt! < aNextAiring ? episode.airingAt! : aNextAiring);
        }
      }

      // Get the earliest upcoming episode for series B
      for (final mapping in b.anilistMappings) {
        final episode = upcomingEpisodesMap[mapping.anilistId];
        if (episode?.airingAt != null) {
          bNextAiring = bNextAiring == null ? episode!.airingAt! : (episode!.airingAt! < bNextAiring ? episode.airingAt! : bNextAiring);
        }
      }

      // Compare airing times (earlier first)
      return (aNextAiring ?? 0).compareTo(bNextAiring ?? 0);
    });

    return _buildUpcomingEpisodesSeriesList(series, upcomingEpisodesMap);
  }

  Widget _buildUpcomingEpisodesSeriesList(List<Series> series, Map<int, AiringEpisode?> upcomingEpisodesMap) {
    return HoverVisibleScrollbar(
      height: 310, // Increased height to accommodate natural series card size + episode info
      builder: (context, scrollController) {
        return ValueListenableBuilder(
          valueListenable: KeyboardState.ctrlPressedNotifier,
          builder: (context, isCtrlPressed, _) {
            return ListView.builder(
              controller: scrollController,
              physics: isCtrlPressed ? const NeverScrollableScrollPhysics() : null,
              scrollDirection: Axis.horizontal,
              itemCount: series.length,
              itemBuilder: (context, index) {
                final currentSeries = series[index];

                // Get the upcoming episode info for this series
                AiringEpisode? nextEpisode;
                for (final mapping in currentSeries.anilistMappings) {
                  final episode = upcomingEpisodesMap[mapping.anilistId];
                  if (episode?.airingAt != null) {
                    nextEpisode = nextEpisode == null ? episode : (episode!.airingAt! < nextEpisode.airingAt! ? episode : nextEpisode);
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildUpcomingEpisodeCard(currentSeries, nextEpisode),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildUpcomingEpisodeCard(Series series, AiringEpisode? upcomingEpisode) {
    final double width = 180;
    final double cardHeight = 260; // Height for the series card
    return Stack(
      children: [
        // Series card with its natural aspect ratio
        SizedBox(
          width: width,
          height: cardHeight,
          child: SeriesCard(
            series: series,
            onTap: () => widget.onSeriesSelected(series.path),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ),
    
        // Upcoming episode info positioned below the series card
        if (upcomingEpisode != null && upcomingEpisode.airingAt != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Transform.translate(
              offset: Offset(-0.5, 0),
              child: Transform.scale(
                scale: 1.005,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: FluentTheme.of(context).resources.cardBackgroundFillColorDefault,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    border: Border.all(
                      color: FluentTheme.of(context).resources.cardStrokeColorDefault,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Episode ${upcomingEpisode.episode ?? '?'}',
                        style: FluentTheme.of(context).typography.caption?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatAiringTime(upcomingEpisode.airingAt!),
                        style: FluentTheme.of(context).typography.caption?.copyWith(
                              fontSize: 10,
                              color: FluentTheme.of(context).resources.textFillColorSecondary,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatAiringTime(int airingAt) {
    final airingDate = DateTime.fromMillisecondsSinceEpoch(airingAt * 1000);
    final now = DateTime.now();
    final difference = airingDate.difference(now);

    if (difference.isNegative) {
      return 'Aired';
    } else if (difference.inDays > 0) {
      return 'in ${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes}m';
    } else {
      return 'Soon';
    }
  }

  Widget _buildHorizontalSeriesList(List<Series> series) {
    return HoverVisibleScrollbar(
      height: 300,
      builder: (context, scrollController) {
        return ValueListenableBuilder(
          valueListenable: KeyboardState.ctrlPressedNotifier,
          builder: (context, isCtrlPressed, _) {
            return ListView.builder(
              controller: scrollController,
              physics: isCtrlPressed ? const NeverScrollableScrollPhysics() : null,
              scrollDirection: Axis.horizontal,
              itemCount: series.length,
              itemBuilder: (context, index) {
                final currentSeries = series[index];
                final bool isLast = index == series.length - 1;
                return Padding(
                  padding: isLast ? EdgeInsets.zero : const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 180, // Made narrower (less wide)
                    child: SeriesCard(
                      series: currentSeries,
                      onTap: () => widget.onSeriesSelected(currentSeries.path),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: FluentTheme.of(context).resources.cardBackgroundFillColorSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(FluentIcons.info, size: 32),
            VDiv(8),
            Text(title),
            VDiv(4),
            Text(
              subtitle,
              style: FluentTheme.of(context).typography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Custom widget for hover-visible horizontal scrollbars
class HoverVisibleScrollbar extends StatefulWidget {
  final double height;
  final Widget Function(BuildContext context, ScrollController scrollController) builder;

  const HoverVisibleScrollbar({
    super.key,
    required this.height,
    required this.builder,
  });

  @override
  State<HoverVisibleScrollbar> createState() => _HoverVisibleScrollbarState();
}

class _HoverVisibleScrollbarState extends State<HoverVisibleScrollbar> {
  bool _isHovering = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: SizedBox(
        height: widget.height + 20, // Add extra height for scrollbar padding
        child: Scrollbar(
          controller: _scrollController,
          style: ScrollbarThemeData(
            scrollbarColor: Colors.white.withOpacity(.25),
            thickness: 6.0,
            backgroundColor: Colors.transparent,
            contractDelay: Duration.zero,
            hoveringThickness: 6.0,
            radius: const Radius.circular(4.0),
          ),
          timeToFade: const Duration(milliseconds: 100),
          thumbVisibility: _isHovering,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20), // Reserve space for scrollbar
            child: SizedBox(
              height: widget.height,
              child: widget.builder(context, _scrollController),
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnilistProvider>(builder: (context, anilistProvider, _) {
      final userName = anilistProvider.currentUser?.name;
      return Transform.translate(
        offset: const Offset(-28, 0),
        child: Row(
          children: [
            Text(
              'Welcome Back${userName != null ? "," : ""} ',
              style: FluentTheme.of(context).typography.title,
            ),
            if (userName != null)
              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [
                      lessGradientColor,
                      moreGradientColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: Text(
                  userName.titleCase,
                  style: FluentTheme.of(context).typography.title,
                ),
              ),
            Text(
              '!',
              style: FluentTheme.of(context).typography.title,
            ),
          ],
        ),
      );
    });
  }
}
