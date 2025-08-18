import 'package:fluent_ui/fluent_ui.dart';
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
        VDiv(16),
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
    final cachedUpcomingEpisodes = anilistProvider.getCachedUpcomingEpisodes(
      animeIds.toList(), 
      refreshInBackground: true
    );

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
          aNextAiring = aNextAiring == null ? episode!.airingAt! : 
              (episode!.airingAt! < aNextAiring ? episode.airingAt! : aNextAiring);
        }
      }

      // Get the earliest upcoming episode for series B
      for (final mapping in b.anilistMappings) {
        final episode = upcomingEpisodesMap[mapping.anilistId];
        if (episode?.airingAt != null) {
          bNextAiring = bNextAiring == null ? episode!.airingAt! : 
              (episode!.airingAt! < bNextAiring ? episode.airingAt! : bNextAiring);
        }
      }

      // Compare airing times (earlier first)
      return (aNextAiring ?? 0).compareTo(bNextAiring ?? 0);
    });

    return _buildUpcomingEpisodesSeriesList(series, upcomingEpisodesMap);
  }

  Widget _buildUpcomingEpisodesSeriesList(List<Series> series, Map<int, AiringEpisode?> upcomingEpisodesMap) {
    return SizedBox(
      height: 280, // Increased height to accommodate natural series card size + episode info
      child: ValueListenableBuilder(
          valueListenable: KeyboardState.ctrlPressedNotifier,
          builder: (context, isCtrlPressed, _) {
            return ListView.builder(
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
                    nextEpisode = nextEpisode == null ? episode : 
                        (episode!.airingAt! < nextEpisode.airingAt! ? episode : nextEpisode);
                  }
                }
                
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 150,
                    child: _buildUpcomingEpisodeCard(currentSeries, nextEpisode),
                  ),
                );
              },
            );
          }),
    );
  }

  Widget _buildUpcomingEpisodeCard(Series series, AiringEpisode? upcomingEpisode) {
    return Stack(
      children: [
        // Series card with its natural aspect ratio
        SizedBox(
          width: 150,
          height: 230, // Natural height for series card (aspect ratio roughly 150x220)
          child: SeriesCard(
            series: series,
            onTap: () => widget.onSeriesSelected(series.path),
          ),
        ),
        
        // Upcoming episode info positioned below the series card
        if (upcomingEpisode != null && upcomingEpisode.airingAt != null)
          Positioned(
            bottom: 0, // Position below the series card
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: FluentTheme.of(context).resources.cardBackgroundFillColorDefault,
                borderRadius: BorderRadius.circular(4),
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
    return SizedBox(
      height: 220,
      child: ValueListenableBuilder(
          valueListenable: KeyboardState.ctrlPressedNotifier,
          builder: (context, isCtrlPressed, _) {
            return ListView.builder(
              physics: isCtrlPressed ? const NeverScrollableScrollPhysics() : null,
              scrollDirection: Axis.horizontal,
              itemCount: series.length,
              itemBuilder: (context, index) {
                final currentSeries = series[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 120, // Made narrower (less wide)
                    child: SeriesCard(
                      series: currentSeries,
                      onTap: () => widget.onSeriesSelected(currentSeries.path),
                    ),
                  ),
                );
              },
            );
          }),
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
