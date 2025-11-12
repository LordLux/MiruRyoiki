import 'package:fluent_ui/fluent_ui.dart';
import '../manager.dart';
import '../utils/time.dart';
import 'episode.dart';

/// Represents the different states an episode can have
enum EpisodeState {
  /// Episode exists locally and can be played
  downloaded,

  /// Episode was released but not downloaded yet (available for download)
  available,

  /// Episode exists in AniList but hasn't been released yet
  future,

  /// Episode is missing/not found in AniList data
  unknown,
}

/// A unified representation of episodes that can be downloaded, available, or future
class UIEpisode {
  /// The local episode file (null for future episodes)
  final Episode? localEpisode;

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
    this.anilistTitle,
    required this.state,
    this.airDate,
    this.watched = false,
    this.progress = 0.0,
  });

  /// Create a UIEpisode from a local episode file
  factory UIEpisode.fromLocalEpisode(Episode episode) {
    return UIEpisode(
      localEpisode: episode,
      episodeNumber: episode.episodeNumber ?? 0,
      anilistTitle: episode.anilistTitle,
      state: EpisodeState.downloaded,
      watched: episode.watched,
      progress: episode.progress,
    );
  }

  /// Create a UIEpisode for an available but not downloaded episode
  factory UIEpisode.available({
    /// Episode numbert from AniList
    required int episodeNumber,

    /// Episode title from AniList
    String? anilistTitle,

    /// Air date, if known
    DateTime? airDate,
  }) {
    return UIEpisode(
      episodeNumber: episodeNumber,
      anilistTitle: anilistTitle,
      state: EpisodeState.available,
      airDate: airDate,
    );
  }

  /// Create a UIEpisode for a future (not yet aired) episode
  factory UIEpisode.future({
    /// Episode number from AniList
    required int episodeNumber,

    /// Episode title from AniList
    String? anilistTitle,

    /// Air date, if known
    DateTime? airDate,
  }) {
    return UIEpisode(
      episodeNumber: episodeNumber,
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

    return 'Episode $episodeNumber';
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
  bool get canDownload => state == EpisodeState.available;

  /// Whether this episode is a future episode
  bool get isFuture => state == EpisodeState.future;

  /// Whether this episode is downloaded
  bool get isDownloaded => state == EpisodeState.downloaded;

  /// Color indicator for episode state
  Color get stateColor {
    switch (state) {
      case EpisodeState.downloaded:
        return watched ? const Color(0xFF4CAF50) : const Color(0xFF2196F3); // Green if watched, blue if not
      case EpisodeState.available:
        return const Color(0xFFFF9800); // Orange for available
      case EpisodeState.future:
        return const Color(0xFF9E9E9E); // Gray for future
      case EpisodeState.unknown:
        return const Color(0xFFF44336); // Red for unknown/error
    }
  }

  /// Icon for episode state
  IconData get stateIcon {
    switch (state) {
      case EpisodeState.downloaded:
        return watched ? FluentIcons.check_mark : FluentIcons.play;
      case EpisodeState.available:
        return FluentIcons.download;
      case EpisodeState.future:
        return FluentIcons.clock;
      case EpisodeState.unknown:
        return FluentIcons.unknown;
    }
  }

  /// Human-readable state description
  String get stateDescription {
    switch (state) {
      case EpisodeState.downloaded:
        return watched ? 'Watched' : 'Downloaded';
      case EpisodeState.available:
        return 'Available for download';
      case EpisodeState.future:
        return airDate != null ? 'Airs ${_formatDate(airDate!)}' : 'Not yet aired';
      case EpisodeState.unknown:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    final difference = date.difference(now);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return 'in ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} minutes';
    } else if (difference.inSeconds > -60) {
      return 'now';
    } else {
      return 'aired';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UIEpisode && other.episodeNumber == episodeNumber && other.state == state && other.localEpisode == localEpisode;
  }

  @override
  int get hashCode => Object.hash(episodeNumber, state, localEpisode);

  @override
  String toString() {
    return 'UIEpisode(episodeNumber: $episodeNumber, state: $state, title: $displayTitle)';
  }
}
