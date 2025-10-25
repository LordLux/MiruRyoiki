import 'package:miruryoiki/models/metadata.dart';
import 'package:miruryoiki/utils/path.dart';
import 'episode.dart';
import 'season.dart';

/// Represents either an Episode or a Season as a mapping target.
/// This allows uniform handling of both types in the UI without explicit type checks.
sealed class MappingTarget {
  /// Creates a MappingTarget from an Episode
  factory MappingTarget.episode(Episode episode) = EpisodeTarget;

  /// Creates a MappingTarget from a Season
  factory MappingTarget.season(Season season) = SeasonTarget;

  /// Creates a MappingTarget from either an Episode or Season
  factory MappingTarget.from({Episode? episode, Season? season}) {
    if (episode != null) return MappingTarget.episode(episode);
    if (season != null) return MappingTarget.season(season);
    throw ArgumentError('Either episode or season must be provided');
  }

  /// Pattern matching for handling different target types
  T when<T>({
    required T Function(Episode episode) episode,
    required T Function(Season season) season,
  });

  /// Pattern matching with optional default case
  T maybeWhen<T>({
    T Function(Episode episode)? episode,
    T Function(Season season)? season,
    required T Function() orElse,
  });

  /// Map this target to another type
  T map<T>({
    required T Function(EpisodeTarget episode) episode,
    required T Function(SeasonTarget season) season,
  });

  /// Check if this is an episode target
  bool get isEpisode;

  /// Check if this is a season target
  bool get isSeason;

  /// Get the display name for this target
  String get displayName;

  /// Get the path for this target
  PathString get path;

  /// Get metadata if available
  Metadata? get metadata;

  /// Get all episodes (single episode in a list for Episode, all episodes for Season)
  List<Episode> get episodes;

  /// Get the number of watched episodes
  int get watchedCount;

  /// Get the total number of episodes
  int get totalCount;

  /// Get the watch progress as a percentage (0.0 to 1.0)
  double get watchedPercentage;

  /// Try to get the underlying Episode, or null if this is a Season
  Episode? get asEpisode;

  /// Try to get the underlying Season, or null if this is an Episode
  Season? get asSeason;
}

/// MappingTarget representing a single Episode
final class EpisodeTarget implements MappingTarget {
  final Episode episode;

  EpisodeTarget(this.episode);

  @override
  T when<T>({
    required T Function(Episode episode) episode,
    required T Function(Season season) season,
  }) {
    return episode(this.episode);
  }

  @override
  T maybeWhen<T>({
    T Function(Episode episode)? episode,
    T Function(Season season)? season,
    required T Function() orElse,
  }) {
    if (episode != null) return episode(this.episode);
    return orElse();
  }

  @override
  T map<T>({
    required T Function(EpisodeTarget episode) episode,
    required T Function(SeasonTarget season) season,
  }) {
    return episode(this);
  }

  @override
  bool get isEpisode => true;

  @override
  bool get isSeason => false;

  @override
  String get displayName => episode.displayTitle ?? episode.name;

  @override
  PathString get path => episode.path;

  @override
  Metadata? get metadata => episode.metadata;

  @override
  List<Episode> get episodes => [episode];

  @override
  int get watchedCount => episode.watched ? 1 : 0;

  @override
  int get totalCount => 1;

  @override
  double get watchedPercentage => episode.progress;

  @override
  Episode? get asEpisode => episode;

  @override
  Season? get asSeason => null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || //
      other is EpisodeTarget && //
          runtimeType == other.runtimeType &&
          episode == other.episode;

  @override
  int get hashCode => episode.hashCode;

  @override
  String toString() => 'EpisodeTarget($displayName)';
}

/// MappingTarget representing a Season with multiple Episodes
final class SeasonTarget implements MappingTarget {
  final Season season;

  SeasonTarget(this.season);

  @override
  T when<T>({
    required T Function(Episode episode) episode,
    required T Function(Season season) season,
  }) {
    return season(this.season);
  }

  @override
  T maybeWhen<T>({
    T Function(Episode episode)? episode,
    T Function(Season season)? season,
    required T Function() orElse,
  }) {
    if (season != null) return season(this.season);
    return orElse();
  }

  @override
  T map<T>({
    required T Function(EpisodeTarget episode) episode,
    required T Function(SeasonTarget season) season,
  }) {
    return season(this);
  }

  @override
  bool get isEpisode => false;

  @override
  bool get isSeason => true;

  @override
  String get displayName => season.prettyName;

  @override
  PathString get path => season.path;

  @override
  Metadata? get metadata => season.metadata;

  @override
  List<Episode> get episodes => season.episodes;

  @override
  int get watchedCount => season.watchedCount;

  @override
  int get totalCount => season.totalCount;

  @override
  double get watchedPercentage => season.watchedPercentage;

  @override
  Episode? get asEpisode => null;

  @override
  Season? get asSeason => season;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || //
      other is SeasonTarget && //
          runtimeType == other.runtimeType &&
          season == other.season;

  @override
  int get hashCode => season.hashCode;

  @override
  String toString() => 'SeasonTarget($displayName)';
}
