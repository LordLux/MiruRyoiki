import 'package:miruryoiki/models/metadata.dart';
import 'package:miruryoiki/utils/path.dart';
import 'episode.dart';
import 'season.dart';

/// Represents either an Episode or an EpisodeCollection as a mapping target
/// 
/// This allows uniform handling of both types in the UI without explicit type checks
sealed class MappingTarget {
  /// Creates a MappingTarget from an Episode
  factory MappingTarget.episode(Episode episode) = EpisodeTarget;

  /// Creates a MappingTarget from an EpisodeCollection (Season or Folder)
  factory MappingTarget.collection(EpisodeCollection collection) = CollectionTarget;

  /// Creates a MappingTarget from either an Episode or EpisodeCollection
  factory MappingTarget.from({Episode? episode, EpisodeCollection? collection}) {
    if (episode != null) return MappingTarget.episode(episode);
    if (collection != null) return MappingTarget.collection(collection);
    throw ArgumentError('Either episode or collection must be provided');
  }

  /// Pattern matching for handling different target types
  T when<T>({
    required T Function(Episode episode) episode,
    required T Function(EpisodeCollection collection) collection,
  });

  /// Pattern matching with optional default case
  T maybeWhen<T>({
    T Function(Episode episode)? episode,
    T Function(EpisodeCollection collection)? collection,
    required T Function() orElse,
  });

  /// Map this target to another type
  T map<T>({
    required T Function(EpisodeTarget episode) episode,
    required T Function(CollectionTarget collection) collection,
  });

  /// Check if this is an episode target
  bool get isEpisode;

  /// Check if this is a collection target
  bool get isCollection;

  /// Get the display name for this target
  String get displayName;

  /// Get the path for this target
  PathString get path;

  /// Get metadata if available
  Metadata? get metadata;

  /// Get all episodes (single episode in a list for Episode, all episodes for Collection)
  List<Episode> get episodes;

  /// Get the number of watched episodes
  int get watchedCount;

  /// Get the total number of episodes
  int get totalCount;

  /// Get the watch progress as a percentage (0.0 to 1.0)
  double get watchedPercentage;

  /// Try to get the underlying Episode, or null if this is a Collection
  Episode? get asEpisode;

  /// Try to get the underlying EpisodeCollection, or null if this is an Episode
  EpisodeCollection? get asCollection;
}

/// MappingTarget representing a single Episode
final class EpisodeTarget implements MappingTarget {
  final Episode episode;

  EpisodeTarget(this.episode);

  @override
  T when<T>({
    required T Function(Episode episode) episode,
    required T Function(EpisodeCollection collection) collection,
  }) {
    return episode(this.episode);
  }

  @override
  T maybeWhen<T>({
    T Function(Episode episode)? episode,
    T Function(EpisodeCollection collection)? collection,
    required T Function() orElse,
  }) {
    if (episode != null) return episode(this.episode);
    return orElse();
  }

  @override
  T map<T>({
    required T Function(EpisodeTarget episode) episode,
    required T Function(CollectionTarget collection) collection,
  }) {
    return episode(this);
  }

  @override
  bool get isEpisode => true;

  @override
  bool get isCollection => false;

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
  EpisodeCollection? get asCollection => null;

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

/// MappingTarget representing an EpisodeCollection (Season or Folder)
final class CollectionTarget implements MappingTarget {
  final EpisodeCollection collection;

  CollectionTarget(this.collection);

  @override
  T when<T>({
    required T Function(Episode episode) episode,
    required T Function(EpisodeCollection collection) collection,
  }) {
    return collection(this.collection);
  }

  @override
  T maybeWhen<T>({
    T Function(Episode episode)? episode,
    T Function(EpisodeCollection collection)? collection,
    required T Function() orElse,
  }) {
    if (collection != null) return collection(this.collection);
    return orElse();
  }

  @override
  T map<T>({
    required T Function(EpisodeTarget episode) episode,
    required T Function(CollectionTarget collection) collection,
  }) {
    return collection(this);
  }

  @override
  bool get isEpisode => false;

  @override
  bool get isCollection => true;

  @override
  String get displayName => collection.prettyName;

  @override
  PathString get path => collection.path;

  @override
  Metadata? get metadata => collection.metadata;

  @override
  List<Episode> get episodes => collection.episodes;

  @override
  int get watchedCount => collection.watchedCount;

  @override
  int get totalCount => collection.totalCount;

  @override
  double get watchedPercentage => collection.watchedPercentage;

  @override
  Episode? get asEpisode => null;

  @override
  EpisodeCollection? get asCollection => collection;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || //
      other is CollectionTarget && //
          runtimeType == other.runtimeType &&
          collection == other.collection;

  @override
  int get hashCode => collection.hashCode;

  @override
  String toString() => 'CollectionTarget($displayName)';
}
