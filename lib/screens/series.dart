import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

import '../dialogs/confirm_watch_all.dart';
import '../dialogs/link_anilist.dart';
import '../models/library.dart';
import '../models/series.dart';
import '../models/episode.dart';
import '../services/anilist/linking.dart';
import '../widgets/episode_grid.dart';
import 'anilist_settings.dart';

class SeriesScreen extends StatelessWidget {
  final String seriesPath;
  final VoidCallback onBack;

  const SeriesScreen({
    super.key,
    required this.seriesPath,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final library = context.watch<Library>();
    final series = library.getSeriesByPath(seriesPath);

    if (series == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Series not found'),
            const SizedBox(height: 16),
            Button(
              onPressed: onBack,
              child: const Text('Back to Library'),
            ),
          ],
        ),
      );
    }

    return _buildSeriesContent(context, series);
  }

  Widget _buildSeriesContent(BuildContext context, Series series) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          // Header with poster as background
          _buildSeriesHeader(context, series),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Expanded(
            child: SizedBox(
              width: 1400,
              child: Row(
                children: [
                  Container(
                    height: double.infinity,
                    color: Colors.white.withOpacity(0.1),
                    width: 300,
                    child: SingleChildScrollView(
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
                            activeColor: Colors.red, // TODO get primary color from series
                            backgroundColor: Colors.white.withOpacity(.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Episodes by season
                          _buildEpisodesList(context, series),
                        ],
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

  Widget _buildSeriesHeader(BuildContext context, Series series) {
    final library = context.watch<Library>();
    return Stack(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(8.0),
            color: Colors.grey.withOpacity(0.2),
            image: (series.bannerImage != null)
                ? DecorationImage(
                    image: NetworkImage(series.bannerImage!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.6),
                      BlendMode.darken,
                    ),
                  )
                : (series.posterPath != null)
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
          padding: const EdgeInsets.all(32.0),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                series.displayTitle,
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
              onBack,
              const Icon(FluentIcons.back),
              'Back to Library',
            ),
            _buildButton(
              () => library.scanLibrary(),
              const Icon(FluentIcons.refresh),
              'Refresh',
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
              () => _linkWithAnilist(context, series),
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

  Widget _buildButton(void Function()? onTap, Widget child, String label) {
    return Tooltip(
      message: label,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: IconButton(
          style: ButtonStyle(
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

  Widget _buildEpisodesList(BuildContext context, Series series) {
    if (series.seasons.isNotEmpty) {
      // Multiple seasons - display by season
      final List<Widget> seasonWidgets = [];

      // Add a section for each season
      for (int i = 1; i <= series.seasons.length; i++) {
        final seasonEpisodes = series.getEpisodesForSeason(i);
        if (seasonEpisodes.isNotEmpty) {
          seasonWidgets.add(
            EpisodeGrid(
              title: 'Season $i',
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

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(children: seasonWidgets),
      );
    } else {
      // Single season - show simple grid
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: EpisodeGrid(
          episodes: series.getEpisodesForSeason(1),
          onTap: (episode) => _playEpisode(episode),
        ),
      );
    }
  }

  void _playEpisode(Episode episode) async {
    // Launch MPC-HC with the episode file
    await OpenAppFile.open(episode.path);
  }

  void _linkWithAnilist(BuildContext context, Series series) async {
    final library = Provider.of<Library>(context, listen: false);
    final linkService = SeriesLinkService();

    showDialog(
      context: context,
      builder: (context) => AnilistLinkDialog(
        series: series,
        linkService: linkService,
        onLink: (anilistId) async {
          await library.linkSeriesWithAnilist(series, anilistId);
        },
      ),
    );
  }
}
