import 'package:fluent_ui/fluent_ui.dart';
import 'dart:async';
import 'package:miruryoiki/widgets/buttons/button.dart';
import 'package:provider/provider.dart';

import '../models/episode.dart';
import '../models/series.dart';
import '../models/anilist/anime.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../services/library/library_provider.dart';
import '../settings.dart';
import '../utils/color.dart';
import '../utils/logging.dart';
import '../utils/path.dart';
import '../utils/screen.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/cards/continue_episode_card.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/page_template.dart';
import '../manager.dart';
import '../widgets/cards/upcoming_episode_card.dart';

/// Home screen.
///
/// Section data (Continue Watching / Next Up / Upcoming) and the Sonarr title cache live in [HomeViewModel] (registered app-wide in `main.dart`).
/// This widget only renders and owns view concerns: the minute ticker for relative times, scrollbars, and navigation callbacks.
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

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  Timer? _minuteRefreshTimer; // refresh relative times every minute

  @override
  bool get wantKeepAlive => true;

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

  void _selectRandomEntry(HomeViewModel vm, List<Series> series) {
    final pick = vm.pickRandomEntry(series);
    if (pick == null) return;

    _openEpisode(pick.$1, pick.$2);
  }

  void _openEpisode(Series currentSeries, Episode nextEpisode) async {
    widget.onSeriesSelected(currentSeries.path);
    final vm = context.read<HomeViewModel>();

    await Future.delayed(const Duration(milliseconds: 100));
    vm.playEpisode(nextEpisode);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // for AutomaticKeepAliveClientMixin

    final vm = context.watch<HomeViewModel>();

    return MiruRyoikiTemplatePage(
      scrollRestorationId: 'home',
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
      content: _buildContent(vm),
      hideInfoBar: true,
      noHeaderBanner: true,
    );
  }

  Widget _buildContent(HomeViewModel vm) {
    // Rebuild when Library, AnilistProvider, or settings notify
    context.watch<Library>();
    context.watch<AnilistProvider>();
    context.watch<SettingsManager>();

    final watchingSeries = vm.watchingSeries;

    if (watchingSeries == null) {
      // No watching list found
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
      // No series in watching list
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

    // Start async Sonarr title fetch if needed
    vm.ensureSonarrTitles(watchingSeries);

    // Get series for each section
    final (continueWatchingSeries, nextUpSeries) = vm.sectionsFor(watchingSeries);

    // Apply visibility rules
    final showContinueWatching = continueWatchingSeries.isNotEmpty;
    final showNextUp = nextUpSeries.isNotEmpty /* && !showContinueWatching*/;
    final showEmptyState = !showContinueWatching && nextUpSeries.isEmpty;

    final releasedEpisodes = _getReleasedEpisodes();

    return Padding(
      padding: EdgeInsets.only(right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Continue Watching section
          if (showContinueWatching)
            _buildSection(
              title: 'Continue Watching',
              child: _buildContinueWatchingList(vm, continueWatchingSeries, onlyStarted: true),
            ),

          // Next Up section
          if (showNextUp)
            _buildSection(
              title: 'Next Up',
              child: _buildContinueWatchingList(vm, nextUpSeries, onlyStarted: false),
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
            child: _buildUpcomingEpisodesSection(vm),
          ),
        ],
      ),
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

  Widget _buildContinueWatchingList(HomeViewModel vm, List<Series> series, {required bool onlyStarted}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 280 * Manager.fontSizeMultiplier,
          child: AspectRatio(
            aspectRatio: 0.21,
            child: RotatedBox(
              quarterTurns: -1,
              child: StandardButton.iconLabel(
                label: const Text('Random Entry'),
                icon: const Icon(FluentIcons.switch_widget),
                onPressed: () => _selectRandomEntry(vm, series),
              ),
            ),
          ),
        ),
        HDiv(12),
        Expanded(
          child: HoverVisibleScrollbar(
            height: 280 * Manager.fontSizeMultiplier,
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(ScreenUtils.kStatCardBorderRadius)),
                child: ListView.builder(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: series.length,
                      itemBuilder: (context, index) {
                        final currentSeries = series[index];
                        final bool isLast = index == series.length - 1;
                        final nextEpisode = vm.nextEpisodeFor(currentSeries);
                        if (nextEpisode == null) return const SizedBox.shrink();

                        return Padding(
                          padding: isLast ? EdgeInsets.zero : const EdgeInsets.only(right: 12),
                          child: AspectRatio(
                            aspectRatio: 1 / ScreenUtils.kDefaultUpcomingEpisodeCardAspectRatio,
                            child: ContinueEpisodeCard(
                              series: currentSeries,
                              episode: nextEpisode,
                              sonarrTitle: vm.sonarrTitleFor(currentSeries, nextEpisode),
                              onTap: () => _openEpisode(currentSeries, nextEpisode),
                              progress: onlyStarted ? nextEpisode.progress : null, // Show progress only if this is "Continue Watching"
                            ),
                          ),
                        );
                      },
                    ),
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

  Widget _buildUpcomingEpisodesSection(HomeViewModel vm) {
    final watchPlanSeries = vm.watchPlanLinkedSeries;

    if (watchPlanSeries == null) return _buildEmptyState('No watching list found', 'Unable to find your watching/planning lists from Anilist');
    if (watchPlanSeries.isEmpty) return _buildEmptyState('No series in your watching list', 'Link your series with Anilist and add them to your watching list');

    final animeIds = vm.releasingAnimeIds(watchPlanSeries);

    // Get cached data immediately
    final cachedUpcomingEpisodes = vm.cachedUpcomingEpisodes(animeIds);

    // Filter to only series with cached upcoming episodes data
    final seriesWithUpcomingEpisodes = watchPlanSeries.where((series) {
      return HomeViewModel.earliestAiring(series, cachedUpcomingEpisodes) != null;
    }).toList();

    if (seriesWithUpcomingEpisodes.isNotEmpty) return _buildSortedUpcomingEpisodesList(seriesWithUpcomingEpisodes, cachedUpcomingEpisodes);

    // If no cached data, try to fetch fresh data (memoized future)
    return FutureBuilder<Map<int, AiringEpisode?>>(
      future: vm.freshUpcomingEpisodes(animeIds),
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

        final freshSeriesWithUpcomingEpisodes = watchPlanSeries.where((series) {
          return HomeViewModel.earliestAiring(series, freshUpcomingEpisodes) != null;
        }).toList();

        if (freshSeriesWithUpcomingEpisodes.isEmpty) return _buildEmptyState('No upcoming episodes', 'None of your watched series have upcoming episodes scheduled');

        return _buildSortedUpcomingEpisodesList(freshSeriesWithUpcomingEpisodes, freshUpcomingEpisodes);
      },
    );
  }

  Widget _buildSortedUpcomingEpisodesList(List<Series> series, Map<int, AiringEpisode?> upcomingEpisodesMap) {
    HomeViewModel.sortByNearestAiring(series, upcomingEpisodesMap);

    return HoverVisibleScrollbar(
      height: 280 * Manager.fontSizeMultiplier,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(ScreenUtils.kStatCardBorderRadius)),
          child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: series.length,
                itemBuilder: (context, index) {
                  final currentSeries = series[index];

                  // Earliest upcoming episode for this series and the mapping it belongs to
                  final airing = HomeViewModel.earliestAiring(currentSeries, upcomingEpisodesMap);
                  if (airing == null) return const SizedBox.shrink();

                  return Padding(
                    padding: index != series.length - 1 ? const EdgeInsets.only(right: 12) : EdgeInsets.zero,
                    child: AspectRatio(
                      aspectRatio: 1 / ScreenUtils.kDefaultUpcomingEpisodeCardAspectRatio,
                      child: UpcomingEpisodeCard(
                        series: currentSeries,
                        airingEpisode: airing.$1,
                        anilistId: airing.$2,
                      ),
                    ),
                  );
                },
              ),
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
        offset: const Offset(-28, -5),
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
                  userName,
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
