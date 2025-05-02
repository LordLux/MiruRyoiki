import 'package:fluent_ui/fluent_ui.dart';
import 'dart:io';
import '../models/episode.dart';
import 'watched_badge.dart';

class EpisodeGrid extends StatelessWidget {
  final List<Episode> episodes;
  final String? title;
  final Function(Episode) onTap;

  const EpisodeGrid({
    super.key,
    required this.episodes,
    this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (episodes.isEmpty) {
      return Center(
        child: Text(
          'No episodes found',
          style: FluentTheme.of(context).typography.body,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
            child: Text(
              title!,
              style: FluentTheme.of(context).typography.subtitle,
            ),
          ),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            childAspectRatio: 16 / 12,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: episodes.length,
          itemBuilder: (context, index) {
            final episode = episodes[index];
            return _buildEpisodeTile(context, episode);
          },
        ),
      ],
    );
  }

  Widget _buildEpisodeTile(BuildContext context, Episode episode) {
    return GestureDetector(
      onTap: () => onTap(episode),
      child: Card(
        padding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Episode preview or placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: episode.thumbnailPath != null
                  ? Image.file(
                      File(episode.thumbnailPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.withOpacity(0.3),
                        child: const Center(child: Icon(FluentIcons.video, size: 40)),
                      ),
                    )
                  : Container(
                      color: Colors.grey.withOpacity(0.3),
                      child: const Center(child: Icon(FluentIcons.video, size: 40)),
                    ),
            ),

            // Episode name at the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Text(
                  episode.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Watched badge in the top-right corner
            if (episode.watched)
              const Positioned(
                top: 8,
                right: 8,
                child: WatchedBadge(isWatched: true),
              ),

            // Progress indicator if partially watched
            if (episode.watchedPercentage > 0 && episode.watchedPercentage < 0.85)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ProgressBar(
                  value: (episode.watchedPercentage > 0.9 ? 1 : episode.watchedPercentage) * 100,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  activeColor: Colors.blue,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
