import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';

import '../services/library/library_provider.dart';
import '../models/series.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../services/navigation/shortcuts.dart';
import '../utils/path_utils.dart';
import '../utils/screen_utils.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  Color _shiftHue(Color color, double shift) {
    final hsvColor = HSVColor.fromColor(color);
    final newHue = (hsvColor.hue + shift) % 360;
    return hsvColor.withHue(newHue).toColor();
  }

  Color get lessGradientColor => _shiftHue(Manager.accentColor.lighter, -60);
  Color get moreGradientColor => _shiftHue(Manager.accentColor.lighter, 10);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: KeyboardState.ctrlPressedNotifier,
        builder: (context, isCtrlPressed, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            controller: widget.scrollController,
            physics: isCtrlPressed ? const NeverScrollableScrollPhysics() : null,
            children: [
              Consumer<AnilistProvider>(builder: (context, anilistProvider, _) {
                final userName = anilistProvider.currentUser?.name;
                return Row(
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
                );
              }),
              VDiv(24),

              // Currently Watching Section
              _buildSection(
                title: 'Continue Watching',
                child: _buildContinueWatchingSection(),
              ),

              VDiv(24),

              // Upcoming Episodes
              _buildSection(
                title: 'Upcoming Episodes',
                child: _buildUpcomingEpisodesSection(),
              ),

              VDiv(24),

              // Recently Added
              _buildSection(
                title: 'Recently Added to Library',
                child: _buildRecentlyAddedSection(),
              ),
            ],
          );
        });
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: FluentTheme.of(context).typography.subtitle,
        ),
        VDiv(8),
        child,
      ],
    );
  }

  Widget _buildContinueWatchingSection() {
    // ignore: unused_local_variable
    final anilistProvider = Provider.of<AnilistProvider>(context);
    final library = Provider.of<Library>(context);

    // Filter to get only series that are in "Watching" list and in library
    final watchingSeries = library.series
        // TODO .where((s) => s.isLinked &&
        //             s.anilistMappings.any((m) =>
        //               m.status == 'CURRENT' || m.status == 'Watching'))
        .toList();

    if (watchingSeries.isEmpty) {
      return _buildEmptyState('No series in your watching list', 'Link your series with Anilist and add them to your watching list');
    }

    return _buildHorizontalSeriesList(watchingSeries);
  }

  Widget _buildUpcomingEpisodesSection() {
    // ignore: unused_local_variable
    final anilistProvider = Provider.of<AnilistProvider>(context);
    final library = Provider.of<Library>(context);

    // Get series with upcoming episodes
    // This is a placeholder - you'd need to implement API calls to get actual airing info
    final upcomingSeries = library.series
        // TODO.where((s) => s.isLinked && s.anilistMappings.any((m) =>
        //         m.nextAiringEpisode != null))
        .toList();

    // Sort by nearest airing date
    // TODO upcomingSeries.sort((a, b) {
    //   final aNext = a.anilistMappings.firstWhere(
    //     (m) => m.nextAiringEpisode != null,
    //     orElse: () => a.anilistMappings.first,
    //   ).nextAiringEpisode?.airingAt ?? 0;

    //   final bNext = b.anilistMappings.firstWhere(
    //     (m) => m.nextAiringEpisode != null,
    //     orElse: () => b.anilistMappings.first,
    //   ).nextAiringEpisode?.airingAt ?? 0;

    //   return aNext.compareTo(bNext);
    // });

    if (upcomingSeries.isEmpty) {
      return _buildEmptyState('No upcoming episodes', 'None of your watched series have upcoming episodes scheduled');
    }

    return _buildHorizontalSeriesList(upcomingSeries);
  }

  Widget _buildRecentlyAddedSection() {
    final library = Provider.of<Library>(context);

    // Get recently added series - sort by dateAdded
    final recentSeries = library.series.toList();
    // TODO ..sort((a, b) => (b.dateAdded ?? now)
    //     .compareTo(a.dateAdded ?? now));

    final topRecent = recentSeries.take(10).toList();

    if (topRecent.isEmpty) //
      return _buildEmptyState('No series in your library', 'Add series to your library to see them here');

    return _buildHorizontalSeriesList(topRecent);
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
                    width: 150,
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
