import 'package:fluent_ui/fluent_ui.dart';
import 'dart:async';
import 'package:miruryoiki/models/anilist/user_list.dart';
import 'package:miruryoiki/widgets/buttons/button.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';

import '../models/episode.dart';
import '../services/library/library_provider.dart';
import '../models/series.dart';
import '../models/anilist/anime.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../services/navigation/shortcuts.dart';
import '../settings.dart';
import '../utils/color_utils.dart';
import '../utils/path_utils.dart';
import '../utils/screen_utils.dart';
import '../utils/time_utils.dart';
import '../widgets/continue_episode_card.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/page.dart';
import '../widgets/series_card.dart';
import '../manager.dart';
import '../widgets/upcoming_episode_card.dart';

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

  void _selectRandomEntry(List<Series> series) {
    if (series.isEmpty) return;

    // Select a random series from the list
    final randomSeries = series[now.millisecondsSinceEpoch % series.length];

    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
    final nextEpisode = Manager.anilistProgress.getNextEpisodeToWatchEpisode(randomSeries, anilistProvider);

    // Trigger the onSeriesSelected callback with the selected series path
    _openEpisode(randomSeries, nextEpisode!);
  }

  void _openEpisode(Series currentSeries, Episode nextEpisode) async {
    widget.onSeriesSelected(currentSeries.path);
    final library = Provider.of<Library>(context, listen: false);

    await Future.delayed(const Duration(milliseconds: 100));
    library.playEpisode(nextEpisode);
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
          child: _buildContinueWatchingSection(true),
        ),
        _buildSection(
          title: 'Next Up',
          child: _buildContinueWatchingSection(false),
        ),
        VDiv(8), // Reduced spacing between sections
        _buildSection(
          title: 'Upcoming Episodes',
          child: _buildUpcomingEpisodesSection(),
        ),
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

  Widget _buildContinueWatchingSection(bool isNextUp) {
    final anilistProvider = Provider.of<AnilistProvider>(context);
    final library = Provider.of<Library>(context);

    // Get the "Watching" list from Anilist user lists
    final watchingList = anilistProvider.userLists[AnilistListApiStatus.CURRENT.name_];

    if (watchingList == null) return _buildEmptyState('No watching list found', 'Unable to find your watching list from Anilist');

    // Filter to get only series that are in "Watching" list and in library
    final watchingSeries = library.series.where((series) {
      // Only consider linked series
      if (!series.isLinked) return false;

      // Check if any of the series' Anilist mappings are in the watching list
      return series.anilistMappings.any((mapping) {
        return watchingList.entries.any((entry) => entry.media.id == mapping.anilistId);
      });
    }).toList();

    if (watchingSeries.isEmpty) return _buildEmptyState('No series in your watching list', 'Link your series with Anilist and add them to your watching list');

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

    return _buildContinueWatchingList(watchingSeries, onlyStarted: isNextUp);
  }

  Widget _buildUpcomingEpisodesSection() {
    final anilistProvider = Provider.of<AnilistProvider>(context);
    final library = Provider.of<Library>(context);

    // Get the "Watching" list from Anilist user lists
    final watchingList = anilistProvider.userLists[AnilistListApiStatus.CURRENT.name_];

    if (watchingList == null) return _buildEmptyState('No watching list found', 'Unable to find your watching list from Anilist');

    // Filter to get only series that are in "Watching" list, linked, and in library
    final watchingSeries = library.series.where((series) {
      // Only consider linked series
      if (!series.isLinked) return false;

      // Check if any of the series' Anilist mappings are in the watching list
      return series.anilistMappings.any((mapping) {
        return watchingList.entries.any((entry) => entry.media.id == mapping.anilistId);
      });
    }).toList();

    if (watchingSeries.isEmpty) return _buildEmptyState('No series in your watching list', 'Link your series with Anilist and add them to your watching list');

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

          if (snapshot.hasError) return _buildEmptyState('Error loading upcoming episodes', 'Failed to fetch airing information from Anilist');

          final freshUpcomingEpisodes = snapshot.data ?? <int, AiringEpisode?>{};

          final freshSeriesWithUpcomingEpisodes = watchingSeries.where((series) {
            return series.anilistMappings.any((mapping) {
              final upcomingEpisode = freshUpcomingEpisodes[mapping.anilistId];
              return upcomingEpisode != null && upcomingEpisode.airingAt != null;
            });
          }).toList();

          if (freshSeriesWithUpcomingEpisodes.isEmpty) return _buildEmptyState('No upcoming episodes', 'None of your watched series have upcoming episodes scheduled');

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
    final onlyUpcomingEpisodes = series.where((s) {
      return s.anilistMappings.any((mapping) => upcomingEpisodesMap[mapping.anilistId]?.airingAt != null);
    }).toList();
    return HoverVisibleScrollbar(
      height: 170,
      builder: (context, scrollController) {
        return ValueListenableBuilder(
          valueListenable: KeyboardState.ctrlPressedNotifier,
          builder: (context, isCtrlPressed, _) {
            return ListView.builder(
              controller: scrollController,
              physics: isCtrlPressed ? const NeverScrollableScrollPhysics() : null,
              scrollDirection: Axis.horizontal,
              itemCount: onlyUpcomingEpisodes.length,
              itemBuilder: (context, index) {
                final currentSeries = onlyUpcomingEpisodes[index];

                // Get the upcoming episode info for this series
                AiringEpisode? nextEpisode;
                for (final mapping in currentSeries.anilistMappings) {
                  final episode = upcomingEpisodesMap[mapping.anilistId];
                  if (episode?.airingAt != null) {
                    nextEpisode = nextEpisode == null ? episode : (episode!.airingAt! < nextEpisode.airingAt! ? episode : nextEpisode);
                  }
                }

                return Padding(
                  padding: index != onlyUpcomingEpisodes.length - 1 ? const EdgeInsets.only(right: 12) : EdgeInsets.zero,
                  child: SizedBox(
                    width: 260,
                    height: 170,
                    child: UpcomingEpisodeCard(series: currentSeries, airingEpisode: nextEpisode!),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildContinueWatchingList(List<Series> series, {bool onlyStarted = false}) {
    return Consumer<AnilistProvider>(
      builder: (context, anilistProvider, _) {
        final onlySeriesWithNextEpisodes = series.where((s) {
          // Use the new progress manager to check if series has next episode
          final nextEpisode = Manager.anilistProgress.getNextEpisodeToWatchEpisode(s, anilistProvider);
          if (nextEpisode == null) return false;

          // Filter based on onlyStarted parameter
          if (onlyStarted) {
            // Show only episodes that have been started (progress > 0)
            return nextEpisode.progress > 0;
          }
          // Show only episodes that haven't been started (progress == 0)
          return nextEpisode.progress == 0;
        }).toList();

        // If this is the "Continue Watching" section (onlyStarted = true) and it's empty, don't show anything
        if (onlyStarted && onlySeriesWithNextEpisodes.isEmpty) return const SizedBox.shrink();

        // If this is the "Next Up" section (onlyStarted = false) and it's empty
        if (!onlyStarted && onlySeriesWithNextEpisodes.isEmpty) {
          // Check if "Continue Watching" has content
          final startedSeries = series.where((s) {
            final nextEpisode = Manager.anilistProgress.getNextEpisodeToWatchEpisode(s, anilistProvider);
            return nextEpisode != null && nextEpisode.progress > 0;
          }).toList();

          // If "Continue Watching" is not empty, don't show "Next Up" section at all
          if (startedSeries.isNotEmpty) return const SizedBox.shrink();

          // If both sections would be empty, show empty state
          return _buildEmptyState('No series to continue', 'Start watching some series from your library');
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 50,
              height: 280,
              child: RotatedBox(
                quarterTurns: -1,
                child: StandardButton(
                  label: const Text('Random Entry'),
                  onPressed: () => _selectRandomEntry(onlySeriesWithNextEpisodes),
                ),
              ),
            ),
            HDiv(12),
            Expanded(
              child: HoverVisibleScrollbar(
                height: 280,
                builder: (context, scrollController) {
                  return ValueListenableBuilder(
                    valueListenable: KeyboardState.ctrlPressedNotifier,
                    builder: (context, isCtrlPressed, _) {
                      return ListView.builder(
                        controller: scrollController,
                        physics: isCtrlPressed ? const NeverScrollableScrollPhysics() : null,
                        scrollDirection: Axis.horizontal,
                        itemCount: onlySeriesWithNextEpisodes.length,
                        itemBuilder: (context, index) {
                          final currentSeries = onlySeriesWithNextEpisodes[index];
                          final bool isLast = index == onlySeriesWithNextEpisodes.length - 1;
                          // Use the new progress manager to get next episode
                          final nextEpisode = Manager.anilistProgress.getNextEpisodeToWatchEpisode(currentSeries, anilistProvider);
                          if (nextEpisode == null) return const SizedBox.shrink();

                          return Padding(
                            padding: isLast ? EdgeInsets.zero : const EdgeInsets.only(right: 12),
                            child: SizedBox(
                              width: 200,
                              child: ContinueEpisodeCard(
                                series: currentSeries,
                                episode: nextEpisode,
                                onTap: () => _openEpisode(currentSeries, nextEpisode),
                                progress: onlyStarted ? nextEpisode.progress : null, // Show progress only if this is "Continue Watching"
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
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
        height: widget.height + 20, // Extra height for scrollbar padding
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
            padding: const EdgeInsets.only(bottom: 20), // Space for scrollbar
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
