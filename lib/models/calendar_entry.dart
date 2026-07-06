import '../utils/time.dart';
import 'anilist/anime.dart';
import 'notification.dart';
import 'series.dart';

/// Airing info for one upcoming/aired episode of a locally-mapped series.
class ReleaseEpisodeInfo {
  final Series series;
  final AnilistAnime? animeData; // nullable — full anime data not needed for calendar rows
  final AiringEpisode airingEpisode;
  final DateTime airingDate;
  final bool isWatched;
  final bool isAvailable;

  ReleaseEpisodeInfo({
    required this.series,
    required this.animeData,
    required this.airingEpisode,
    required this.airingDate,
    required this.isWatched,
    required this.isAvailable,
  });
}

/// Unified data structure for calendar entries (episodes and notifications).
abstract class CalendarEntry {
  final DateTime date;
  final Series? series; // nullable because notifications might not have series

  CalendarEntry({
    required this.date,
    this.series,
  });

  bool get isPastEntry => date.isBefore(now);
  bool get isFutureEntry => date.isAfter(now);
}

class EpisodeCalendarEntry extends CalendarEntry {
  final ReleaseEpisodeInfo episodeInfo;

  EpisodeCalendarEntry({
    required this.episodeInfo,
  }) : super(
          date: episodeInfo.airingDate,
          series: episodeInfo.series,
        );
}

class NotificationCalendarEntry extends CalendarEntry {
  final AnilistNotification notification;

  NotificationCalendarEntry({
    required this.notification,
    super.series,
  }) : super(
          date: notification.createdAt != 0 ? DateTime.fromMillisecondsSinceEpoch(notification.createdAt * 1000) : now,
        );
}
