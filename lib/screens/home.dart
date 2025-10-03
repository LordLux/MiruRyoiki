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
import '../utils/color.dart';
import '../utils/logging.dart';
import '../utils/path.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import '../widgets/continue_episode_card.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/page.dart';
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
  Future<Map<int, AiringEpisode?>>? _cachedUpcomingEpisodesFuture;
  List<int>? _lastRequestedAnimeIds;

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

  bool _listsEqual<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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

    return MiruRyoikiTemplatePage(
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
    return Consumer<AnilistProvider>(
      builder: (context, anilistProvider, _) {
        // Get the base watching series data
        final watchingSeries = _getWatchingSeries(anilistProvider, library);

        if (watchingSeries == null) {
          // No watching list found - show error state
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                title: 'Continue Watching',
                child: _buildEmptyState('No watching list found', 'Unable to find your watching list from Anilist'),
              ),
            ],
          );
        }

        if (watchingSeries.isEmpty) {
          // No series in watching list - show empty state
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                title: 'Continue Watching',
                child: _buildEmptyState('No series in your watching list', 'Link your series with Anilist and add them to your watching list'),
              ),
            ],
          );
        }

        // Get series for each section
        final (continueWatchingSeries, nextUpSeries) = _getSeriesForSection(watchingSeries, anilistProvider); // $1: started, $2: not started
        final releasedSeries = List<Series>.from(watchingSeries); // series with aired but not downloaded episodes

        // TODO filter hidden if 'show hidden' setting is not enabled

        // Apply visibility rules
        final showContinueWatching = continueWatchingSeries.isNotEmpty;
        final showNextUp = nextUpSeries.isNotEmpty /* && !showContinueWatching*/;
        final showEmptyState = !showContinueWatching && nextUpSeries.isEmpty;

        final releasedEpisodes = _getReleasedEpisodes();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Continue Watching section
            if (showContinueWatching)
              _buildSection(
                title: 'Continue Watching',
                child: _buildContinueWatchingList(continueWatchingSeries, anilistProvider, onlyStarted: true),
              ),

            // Next Up section
            if (showNextUp)
              _buildSection(
                title: 'Next Up',
                child: _buildContinueWatchingList(nextUpSeries, anilistProvider, onlyStarted: false),
              ),

            // Empty state when both sections are empty
            if (showEmptyState)
              _buildSection(
                title: 'Continue Watching',
                child: _buildEmptyState('No series to continue', 'Start watching some series from your library'),
              ),

            if (releasedEpisodes.isNotEmpty) ...[
              VDiv(8), // Reduced spacing between sections
              _buildSection(
                title: 'Release Episodes to Download',
                child: _buildReleasedEpisodesSection(releasedEpisodes),
              ),
            ],

            VDiv(8), // Reduced spacing between sections
            _buildSection(
              title: 'Upcoming Episodes',
              child: _buildUpcomingEpisodesSection(),
            ),
          ],
        );
      },
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

  /// Gets the base watching series from Anilist and library
  List<Series>? _getWatchingSeries(AnilistProvider anilistProvider, Library library) {
    // Get the "Watching" list from Anilist user lists
    final watchingList = anilistProvider.userLists[AnilistListApiStatus.CURRENT.name_];

    if (watchingList == null) return null;

    // Filter to get only series that are in "Watching" list and in library
    final watchingSeries = library.series.where((series) {
      // Only consider linked series
      if (!series.isLinked) return false;

      // Check if any of the series' Anilist mappings are in the watching list
      return series.anilistMappings.any((mapping) {
        return watchingList.entries.any((entry) => entry.media.id == mapping.anilistId);
      });
    }).toList();

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

    return watchingSeries;
  }

  /// Filters series for a specific section based on episode progress
  ///
  /// $1 contains only series whose first non-finished has progress > 0
  /// $2 contains only series whose first non-finished has progress == 0
  (List<Series>, List<Series>) _getSeriesForSection(List<Series> watchingSeries, AnilistProvider anilistProvider) {
    final startedSeries = <Series>[];
    final notStartedSeries = <Series>[];

    for (final s in watchingSeries) {
      // Use the new progress manager to check if series has next episode
      final nextEpisode = Manager.anilistProgress.getNextEpisodeToWatchEpisode(s, anilistProvider);
      if (nextEpisode == null) continue; // Skip series with no next episode

      // Filter based on onlyStarted parameter
      if (nextEpisode.progress > 0 && nextEpisode.progress < Library.progressThreshold && !nextEpisode.watched) {
        // Show only episodes that have been started (progress > 0)
        startedSeries.add(s);
      } else {
        notStartedSeries.add(s);
      }
    }

    return (startedSeries, notStartedSeries);
  }

  Widget _buildContinueWatchingList(List<Series> series, AnilistProvider anilistProvider, {required bool onlyStarted}) {
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
              onPressed: () => _selectRandomEntry(series),
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
                    itemCount: series.length,
                    itemBuilder: (context, index) {
                      final currentSeries = series[index];
                      final bool isLast = index == series.length - 1;
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
  }

  List<Episode> _getReleasedEpisodes() {
    return [];
  }

  Widget _buildReleasedEpisodesSection(List<Episode> releasedEpisodes) {
    // show a list of episodes that have been already aired but not that we still don't have in our library
    if (releasedEpisodes.isEmpty) {
      return _buildEmptyState('No released episodes found', 'All released episodes are already in your library');
    }

    return ListView.builder(
      itemCount: releasedEpisodes.length,
      itemBuilder: (context, index) {
        final episode = releasedEpisodes[index];
        return ListTile(
          title: Text(episode.displayTitle ?? 'Episode ${episode.episodeNumber}'),
          subtitle: Text('Released on: '),
          trailing: IconButton(
            icon: Icon(FluentIcons.add),
            onPressed: () {
              // TODO in the future, bring user to torrent pane
              log('TODO in the future, bring user to torrent pane');
            },
          ),
        );
      },
    );
  }

  Widget _buildUpcomingEpisodesSection() {
    final anilistProvider = Provider.of<AnilistProvider>(context);
    final library = Provider.of<Library>(context);

    // Get the "Watching" + "Planning" lists from Anilist user lists
    final AnilistUserList? watchingList = anilistProvider.userLists[AnilistListApiStatus.CURRENT.name_];
    final AnilistUserList? planningList = anilistProvider.userLists[AnilistListApiStatus.PLANNING.name_];

    final list = [...watchingList?.entries ?? [], ...planningList?.entries ?? []];

    if (list.isEmpty) return _buildEmptyState('No watching list found', 'Unable to find your watching/planning lists from Anilist');

    // Filter to get only series that are in "Watching" list, linked, and in library
    final watchingSeries = library.series.where((series) {
      // Only consider linked series
      if (!series.isLinked) return false;

      // Check if any of the series' Anilist mappings are in the watching/planning list
      return series.anilistMappings.any((mapping) {
        return list.any((entry) => entry.media.id == mapping.anilistId);
      });
    }).toList();

    if (watchingSeries.isEmpty) return _buildEmptyState('No series in your watching list', 'Link your series with Anilist and add them to your watching list');

    // Use StreamBuilder approach with cached data for immediate display
    return _buildUpcomingEpisodesWithCache(watchingSeries, anilistProvider);
  }

  Widget _buildUpcomingEpisodesWithCache(List<Series> watchingSeries, AnilistProvider anilistProvider) {
    // Collect all unique anime IDs from the series
    final Set<int> animeIds = {};
    for (final series_ in watchingSeries) {
      for (final mapping in series_.anilistMappings) {
        if (mapping.anilistData?.status == 'RELEASING') animeIds.add(mapping.anilistId); // only display RELEASING series that the user is watching
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
      // Check if we need to create or reuse the cached future
      final currentAnimeIds = animeIds.toList();
      if (_cachedUpcomingEpisodesFuture == null || _lastRequestedAnimeIds == null || !_listsEqual(_lastRequestedAnimeIds!, currentAnimeIds)) {
        _lastRequestedAnimeIds = currentAnimeIds;
        _cachedUpcomingEpisodesFuture = anilistProvider.getUpcomingEpisodes(currentAnimeIds);
      }

      // If no cached data, try to fetch fresh data
      return FutureBuilder<Map<int, AiringEpisode?>>(
        future: _cachedUpcomingEpisodesFuture,
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
