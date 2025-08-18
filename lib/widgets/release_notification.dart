import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import '../services/anilist/provider/anilist_provider.dart';
import '../services/library/library_provider.dart';
import '../models/anilist/anime.dart';
import '../manager.dart';

class ReleaseNotificationWidget extends StatefulWidget {
  final VoidCallback? onMorePressed;

  const ReleaseNotificationWidget({
    super.key,
    this.onMorePressed,
  });

  @override
  State<ReleaseNotificationWidget> createState() => _ReleaseNotificationWidgetState();
}

class _ReleaseNotificationWidgetState extends State<ReleaseNotificationWidget> {
  final FlyoutController _flyoutController = FlyoutController();

  @override
  void dispose() {
    _flyoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<Library, AnilistProvider>(
      builder: (context, library, anilistProvider, child) {
        final upcomingEpisodes = _getUpcomingEpisodes(library, anilistProvider);
        final hasNotifications = upcomingEpisodes.isNotEmpty;

        return FlyoutTarget(
          controller: _flyoutController,
          child: Tooltip(
            message: hasNotifications 
                ? '${upcomingEpisodes.length} upcoming episode${upcomingEpisodes.length > 1 ? 's' : ''}'
                : 'No upcoming episodes',
            child: IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    FluentIcons.ringer,
                    size: 16,
                    color: hasNotifications 
                        ? Manager.accentColor 
                        : Colors.grey.withOpacity(0.6),
                  ),
                  if (hasNotifications)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: FluentTheme.of(context).scaffoldBackgroundColor,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: hasNotifications ? _showNotificationDropdown : null,
            ),
          ),
        );
      },
    );
  }

  void _showNotificationDropdown() {
    final library = Provider.of<Library>(context, listen: false);
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
    final upcomingEpisodes = _getUpcomingEpisodes(library, anilistProvider);

    _flyoutController.showFlyout(
      barrierDismissible: true,
      dismissOnPointerMoveAway: false,
      dismissWithEsc: true,
      builder: (context) {
        return FlyoutContent(
          constraints: const BoxConstraints(
            maxWidth: 350,
            maxHeight: 400,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upcoming Episodes',
                      style: FluentTheme.of(context).typography.subtitle,
                    ),
                    if (widget.onMorePressed != null)
                      Button(
                        child: const Text('More'),
                        onPressed: () {
                          _flyoutController.close();
                          widget.onMorePressed?.call();
                        },
                      ),
                  ],
                ),
              ),

              const Divider(),

              // Episode list
              Flexible(
                child: upcomingEpisodes.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No upcoming episodes found.'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: upcomingEpisodes.length,
                        itemBuilder: (context, index) {
                          final episode = upcomingEpisodes[index];
                          return _buildEpisodeNotificationItem(episode);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEpisodeNotificationItem(EpisodeNotificationInfo episode) {
    final timeUntil = episode.airingDate.difference(DateTime.now());
    final isToday = timeUntil.inDays == 0;
    final isPast = timeUntil.isNegative;

    return ListTile(
      leading: SizedBox(
        width: 40,
        height: 30,
        child: episode.series.posterImage != null
            ? Image.network(
                episode.series.posterImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.withOpacity(0.3),
                  child: const Icon(FluentIcons.photo2, size: 16),
                ),
              )
            : Container(
                color: Colors.grey.withOpacity(0.3),
                child: const Icon(FluentIcons.photo2, size: 16),
              ),
      ),
      title: Text(
        episode.series.displayTitle,
        style: const TextStyle(fontSize: 13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        'Episode ${episode.airingEpisode.episode ?? '?'} • ${isPast ? 'Aired' : 'Airs'} ${_formatTimeUntil(timeUntil.abs())}',
        style: TextStyle(
          fontSize: 11,
          color: isToday ? Manager.accentColor : null,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onPressed: () {
        _flyoutController.close();
        // TODO: Navigate to series or episode
      },
    );
  }

  List<EpisodeNotificationInfo> _getUpcomingEpisodes(Library library, AnilistProvider anilistProvider) {
    final List<EpisodeNotificationInfo> episodes = [];
    
    // For now, we'll create a placeholder implementation
    // In a real implementation, you'd want to cache the upcoming episodes data
    // and update it periodically in the background
    
    // This is a simplified version that would need to be enhanced
    // to work with your actual data structure
    
    return episodes.take(10).toList(); // Limit to 10 items for the dropdown
  }

  String _formatTimeUntil(Duration duration) {
    if (duration.inDays > 0) {
      return 'in ${duration.inDays}d';
    } else if (duration.inHours > 0) {
      return 'in ${duration.inHours}h';
    } else if (duration.inMinutes > 0) {
      return 'in ${duration.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

class EpisodeNotificationInfo {
  final series; // Keep as dynamic for now
  final AnilistAnime? animeData; // Make nullable
  final AiringEpisode airingEpisode;
  final DateTime airingDate;

  EpisodeNotificationInfo({
    required this.series,
    required this.animeData,
    required this.airingEpisode,
    required this.airingDate,
  });
}
