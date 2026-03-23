import 'package:fluent_ui/fluent_ui.dart';
import '../manager.dart';
import '../utils/logging.dart';
import '../utils/time.dart';
import 'episode.dart';
import 'sonarr/sonarr_episode.dart';

/// Represents the different states an episode can have
enum EpisodeState {
  /// Episode exists locally and can be played
  downloaded,

  /// Episode was released but not downloaded yet (available for download)
  released,

  /// Episode exists in AniList but hasn't been released yet
  future,

  /// Episode is missing/not found in AniList data
  unknown,
}

/// A unified representation of episodes that can be downloaded, available, or future
class UIEpisode {
  /// The local episode file (null for future episodes)
  final Episode? localEpisode;

  /// The remote episode metadata from Sonarr (null if not found or if Sonarr series is not linked)
  final SonarrEpisode? sonarrEpisode;

  /// Episode number
  final int episodeNumber;

  /// Episode title from AniList (unavailable for future episodes)
  final String? anilistTitle;

  /// Current state of this episode
  final EpisodeState state;

  /// Air date for future episodes (only 'next' episode is known)
  final DateTime? airDate;

  /// Whether this episode has been watched (only relevant for downloaded episodes)
  final bool watched;

  /// Watch progress (0.0 - 1.0, only relevant for downloaded episodes)
  final double progress;

  const UIEpisode({
    required this.episodeNumber,
    this.localEpisode,
    this.sonarrEpisode,
    this.anilistTitle,
    required this.state,
    this.airDate,
    this.watched = false,
    this.progress = 0.0,
  });

  /// Create a UIEpisode from a local episode file
  factory UIEpisode.fromLocalEpisode(Episode episode, {SonarrEpisode? sonarrEpisode}) {
    return UIEpisode(
      localEpisode: episode,
      sonarrEpisode: sonarrEpisode,
      episodeNumber: episode.episodeNumber ?? 0,
      anilistTitle: episode.anilistTitle,
      state: EpisodeState.downloaded,
      watched: episode.watched,
      progress: episode.progress,
    );
  }

  /// Create a UIEpisode for an available but not downloaded episode
  factory UIEpisode.released({
    /// Episode number from AniList
    required int episodeNumber,

    /// Sonarr episode
    SonarrEpisode? sonarrEpisode,

    /// Episode title from AniList
    String? anilistTitle,

    /// Air date, if known
    DateTime? airDate,
  }) {
    return UIEpisode(
      episodeNumber: episodeNumber,
      sonarrEpisode: sonarrEpisode,
      anilistTitle: anilistTitle,
      state: EpisodeState.released,
      airDate: airDate,
    );
  }

  /// Create a UIEpisode for a future (not yet aired) episode
  factory UIEpisode.future({
    /// Episode number from AniList
    required int episodeNumber,

    /// Sonarr episode
    SonarrEpisode? sonarrEpisode,

    /// Episode title from AniList
    String? anilistTitle,

    /// Air date, if known
    DateTime? airDate,
  }) {
    return UIEpisode(
      episodeNumber: episodeNumber,
      sonarrEpisode: sonarrEpisode,
      anilistTitle: anilistTitle,
      state: EpisodeState.future,
      airDate: airDate,
    );
  }

  /// Display title for the episode
  String get displayTitle {
    if (Manager.enableAnilistEpisodeTitles && anilistTitle != null && anilistTitle!.isNotEmpty) {
      // Parse episode name from AniList format "Episode DD - EpisodeName"
      final match = RegExp(r'^Episode\s+\d+\s*-\s*(.+)$').firstMatch(anilistTitle!);
      if (match != null && match.group(1) != null) return match.group(1)!.trim();
      return anilistTitle!;
    }

    if (localEpisode != null && localEpisode!.displayTitle != null) return localEpisode!.displayTitle!;
    if (sonarrEpisode != null && sonarrEpisode!.title.isNotEmpty && sonarrEpisode!.title != "Unknown") return sonarrEpisode!.title;

    // If no episode number is known, show the cleaned filename instead of "Episode 0"
    if (episodeNumber <= 0 && localEpisode != null) return localEpisode!.cleanedName;

    return 'Episode $episodeNumber';
  }

  /// The episode number to display — uses absoluteEpisodeNumber for specials (season 0),
  /// regular episodeNumber for normal seasons
  int get displayEpisodeNumber =>
      isSpecial ? (sonarrEpisode?.absoluteEpisodeNumber ?? episodeNumber) : episodeNumber;

  /// Whether this episode is a special (season 0)
  bool get isSpecial => sonarrEpisode?.seasonNumber == 0;

  /// Label for the top-left badge on the episode card.
  /// Shows OVA/ONA/Movie when detected, otherwise the episode number (or cleaned name if unknown).
  String get badgeLabel {
    final type = localEpisode?.typeLabel;
    if (type != null) return type;
    final num = displayEpisodeNumber;
    if (num > 0) return num.toString();
    if (localEpisode != null) return localEpisode!.cleanedName;
    return num.toString();
  }

  /// Short display title for UI constraints
  String get shortTitle {
    final title = displayTitle;
    if (title.length > 50) return '${title.substring(0, 47)}...';

    return title;
  }

  /// Whether this episode can be played
  bool get canPlay => state == EpisodeState.downloaded && localEpisode != null;

  /// Whether this episode can be downloaded
  bool get isReleased => state == EpisodeState.released;

  /// Whether this episode is a future episode
  bool get isFuture => state == EpisodeState.future;

  /// Whether this episode is downloaded
  bool get isDownloaded => state == EpisodeState.downloaded;

  /// Color indicator for episode state
  Color get stateColor {
    return switch (state) {
      EpisodeState.downloaded => watched ? const Color(0xFF4CAF50) : const Color(0xFF2196F3), // Green if watched, blue if not
      EpisodeState.released => const Color(0xFFFF9800), // Orange for available
      EpisodeState.future => const Color(0xFF9E9E9E), // Gray for future
      EpisodeState.unknown => const Color(0xFFF44336) // Red for unknown/error
    };
  }

  /// Icon for episode state
  IconData get stateIcon {
    return switch (state) {
      EpisodeState.downloaded => watched ? FluentIcons.check_mark : FluentIcons.play,
      EpisodeState.released => FluentIcons.download,
      EpisodeState.future => FluentIcons.clock,
      EpisodeState.unknown => FluentIcons.unknown
    };
  }

  /// Human-readable state description
  String get stateDescription {
    return switch (state) {
      EpisodeState.downloaded => watched ? 'Watched' : 'Downloaded',
      EpisodeState.released => 'Available for download',
      EpisodeState.future => airDate != null ? 'Airs ${_formatDate(airDate!)}' : 'Not yet aired',
      EpisodeState.unknown => 'Unknown'
    };
  }

  String _formatDate(DateTime date) {
    final difference = date.difference(now);

    if (difference.inDays > 7) return '${date.day}/${date.month}/${date.year}';
    if (difference.inDays > 0) return 'in ${difference.inDays} days';
    if (difference.inHours > 0) return 'in ${difference.inHours} hours';
    if (difference.inMinutes > 0) return 'in ${difference.inMinutes} minutes';
    if (difference.inSeconds > -60) return 'now';
    return 'aired';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UIEpisode && other.episodeNumber == episodeNumber && other.state == state && other.localEpisode == localEpisode;
  }

  @override
  int get hashCode => Object.hash(episodeNumber, state, localEpisode);

  @override
  String toString() => 'UIEpisode(episodeNumber: $episodeNumber, state: $state, title: $displayTitle)';

  static List<UIEpisode> merge(List<Episode>? localEpisodes, List<SonarrEpisode>? sonarrEpisodes) {
    logTrace('[UIEpisode.merge] local=${localEpisodes?.length ?? 0}, sonarr=${sonarrEpisodes?.length ?? 0}');
    final sonarrMap = {
      if (sonarrEpisodes != null)
        for (var e in sonarrEpisodes) e.episodeNumber: e
    };

    final result = <UIEpisode>[];
    final addedNumbers = <int>{};

    // First, add all local episodes
    if (localEpisodes != null) {
      for (final local in localEpisodes) {
        final num = local.episodeNumber ?? -1;

        result.add(UIEpisode.fromLocalEpisode(local, sonarrEpisode: sonarrMap[num]));
        if (num != -1) addedNumbers.add(num);
      }
    }

    // Next, add remaining sonarr episodes
    if (sonarrEpisodes != null) {
      for (final sonarr in sonarrEpisodes) {
        if (!addedNumbers.contains(sonarr.episodeNumber)) {
          final hasFile = sonarr.hasFile;
          final airDateStr = sonarr.airDateUtc;
          DateTime? airDate;

          if (airDateStr != null && airDateStr.isNotEmpty) //
            airDate = DateTime.tryParse(airDateStr);

          // If Sonarr has a file for this episode, treat it as downloaded
          // even without a local Episode match (e.g. after manual import)
          if (hasFile) {
            result.add(UIEpisode(
              episodeNumber: sonarr.episodeNumber,
              sonarrEpisode: sonarr,
              anilistTitle: sonarr.title,
              state: EpisodeState.downloaded,
              airDate: airDate,
            ));
          } else {
            bool isReleased = airDate != null ? airDate.isBefore(now) : false;

            if (isReleased) {
              result.add(UIEpisode.released(
                episodeNumber: sonarr.episodeNumber,
                sonarrEpisode: sonarr,
                anilistTitle: sonarr.title,
                airDate: airDate,
              ));
            } else {
              result.add(UIEpisode.future(
                episodeNumber: sonarr.episodeNumber,
                sonarrEpisode: sonarr,
                anilistTitle: sonarr.title,
                airDate: airDate,
              ));
            }
          }
        }
      }
    }

    // sort by episode number
    result.sort((a, b) {
      if (a.episodeNumber <= 0 && b.episodeNumber > 0) return 1;
      if (b.episodeNumber <= 0 && a.episodeNumber > 0) return -1;
      return a.episodeNumber.compareTo(b.episodeNumber);
    });
    return result;
  }
}
