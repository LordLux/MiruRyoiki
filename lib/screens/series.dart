import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

import '../models/library.dart';
import '../models/series.dart';
import '../models/episode.dart';
import '../widgets/episode_grid.dart';

class SeriesScreen extends StatelessWidget {
  final String seriesPath;

  const SeriesScreen({
    super.key,
    required this.seriesPath,
  });

  @override
  Widget build(BuildContext context) {
    final library = context.watch<Library>();
    final series = library.getSeriesByPath(seriesPath);

    if (series == null) {
      return const ScaffoldPage(
        content: Center(
          child: Text('Series not found'),
        ),
      );
    }

    return ScaffoldPage(
      // header: PageHeader(
      //   leading: Tooltip(
      //     message: 'Back',
      //     child: Button(
      //       onPressed: () => Navigator.pop(context),
      //       child: const Icon(FluentIcons.back),
      //     ),
      //   ),
      //   commandBar: CommandBar(
      //     primaryItems: [
      //       CommandBarButton(
      //         icon: const Icon(FluentIcons.back),
      //         label: const Text('Back'),
      //         onPressed: () => Navigator.pop(context),
      //       ),
      //       CommandBarButton(
      //         icon: const Icon(FluentIcons.refresh),
      //         label: const Text('Refresh'),
      //         onPressed: () => library.scanLibrary(),
      //       ),
      //       CommandBarButton(
      //         icon: const Icon(FluentIcons.check_mark),
      //         label: const Text('Mark All as Watched'),
      //         onPressed: () => library.markSeriesWatched(series),
      //       ),
      //     ],
      //   ),
      // ),
      content: _buildSeriesContent(context, series),
    );
  }

  Widget _buildSeriesContent(BuildContext context, Series series) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with poster as background
          _buildSeriesHeader(context, series),

          const SizedBox(height: 24),

          // Series info
          _buildSeriesInfo(context, series),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Episodes by season
          _buildEpisodesList(context, series),
        ],
      ),
    );
  }

  Widget _buildSeriesHeader(BuildContext context, Series series) {
    final library = context.watch<Library>();
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.grey.withOpacity(0.2),
            image: series.posterPath != null
                ? DecorationImage(
                    image: FileImage(File(series.posterPath!)),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.6),
                      BlendMode.darken,
                    ),
                  )
                : null,
          ),
          padding: const EdgeInsets.all(24.0),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                series.name,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildButton(
              () => Navigator.pop(context),
              const Icon(FluentIcons.back),
              'Back',
            ),
            _buildButton(
              () => library.scanLibrary(),
              const Icon(FluentIcons.refresh),
              'Refresh',
            ),
            _buildButton(
              () => library.markSeriesWatched(series),
              const Icon(FluentIcons.check_mark),
              'Mark All as Watched',
            ),
          ],
        )
      ],
    );
  }

  Widget _buildButton(void Function()? onTap, Widget child, String label) {
    return Tooltip(
      message: label,
      child: Button(
        onPressed: onTap,
        child: child,
      ),
    );
  }

  Widget _buildSeriesInfo(BuildContext context, Series series) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            InfoLabel(
              label: 'Seasons',
              child: Text('${series.seasons.isNotEmpty ? series.seasons.length : 1}'),
            ),
            const SizedBox(width: 24),
            InfoLabel(
              label: 'Episodes',
              child: Text('${series.totalEpisodes}'),
            ),
            const SizedBox(width: 24),
            if (series.relatedMedia.isNotEmpty) ...[
              InfoLabel(
                label: 'Related Media',
                child: Text('${series.relatedMedia.length}'),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        ProgressBar(
          value: series.watchedPercentage * 100,
          backgroundColor: Colors.grey.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildEpisodesList(BuildContext context, Series series) {
    if (series.seasons.isNotEmpty) {
      // Multiple seasons - display by season
      final List<Widget> seasonWidgets = [];

      // Add a section for each season
      for (int i = 0; i < series.seasons.length; i++) {
        final seasonEpisodes = series.getEpisodesForSeason(i + 1);
        if (seasonEpisodes.isNotEmpty) {
          seasonWidgets.add(
            EpisodeGrid(
              title: 'Season ${i.toString().padLeft(2, '0')}',
              episodes: seasonEpisodes,
              onTap: (episode) => _playEpisode(episode),
            ),
          );
        }
      }

      // Add uncategorized episodes if any
      final uncategorizedEpisodes = series.getUncategorizedEpisodes();
      if (uncategorizedEpisodes.isNotEmpty) {
        seasonWidgets.add(
          EpisodeGrid(
            title: 'Other Episodes',
            episodes: uncategorizedEpisodes,
            onTap: (episode) => _playEpisode(episode),
          ),
        );
      }

      return Column(children: seasonWidgets);
    } else {
      // Single season - show simple grid
      return EpisodeGrid(
        episodes: series.getEpisodesForSeason(1),
        onTap: (episode) => _playEpisode(episode),
      );
    }
  }

  void _playEpisode(Episode episode) async {
    // Launch MPC-HC with the episode file
    await OpenAppFile.open(episode.path);
  }
}
