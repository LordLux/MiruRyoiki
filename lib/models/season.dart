// ignore_for_file: library_prefixes, unnecessary_this

import 'package:miruryoiki/models/metadata.dart';
import 'package:collection/collection.dart';

import '../enums.dart';
import '../utils/path.dart';
import 'episode.dart';

class Season {
  /// Database ID
  final int? id;

  /// Database ID for parent Series
  final int? seriesId;

  /// Name of the season
  final String name;

  /// Path for the season from the File System
  final PathString path;

  /// List of Episodes for the season
  final List<Episode> episodes;

  Season({
    this.id,
    this.seriesId,
    required this.name,
    required this.path,
    required this.episodes,
    Metadata? metadata,
  }) : _metadata = metadata;

  @override
  String toString() {
    return '''
      Season(
        name: $name, path: $path,
        episodes: $episodes
      )
    ''';
  }

  int get watchedCount => episodes.where((e) => e.watched).length;
  int get totalCount => episodes.length;
  double get watchedPercentage => totalCount > 0 ? watchedCount / totalCount : 0.0;

  String get prettyName {
    if (name.isEmpty) return 'Season';

    final seasonNum = seasonNumber; // Use the parsed season number if available
    if (seasonNum != null) return 'Season $seasonNum';

    // if no valid season number found, return the original name
    return name;
  }

  int? get seasonNumber {
    // Pattern to match "Season \d+" or "S\s?\d+"
    final seasonPattern = RegExp(r'^[Ss](?:eason)?\s*(\d+)$');
    final match = seasonPattern.firstMatch(name.trim());

    if (match != null) return int.parse(match.group(1)!); // Return as integer

    return null; // Return null if no valid season number found
  }

  Metadata? _metadata;

  Metadata? get metadata => _metadata ?? _getMetadata();

  Metadata? _getMetadata() {
    if (_metadata != null) return _metadata;

    // Get total duration
    int totSize = 0;
    Duration totDuration = Duration.zero;
    DateTime? creationDate; // earliest creation date among all episodes
    DateTime? lastModifiedDate; // latest modification date among all episodes
    DateTime? lastAccessedDate; // latest access date among all episodes

    // Populate variables
    for (final episode in episodes) {
      final metadata = episode.metadata;
      if (metadata != null) {
        totSize += metadata.size;
        totDuration += metadata.duration;
        creationDate ??= DateTimeX.isBeforeMaybe(creationDate, metadata.creationTime);
        lastModifiedDate ??= DateTimeX.isAfterMaybe(lastModifiedDate, metadata.lastModified);
        lastAccessedDate ??= DateTimeX.isAfterMaybe(lastAccessedDate, metadata.lastAccessed);
      }
    }

    _metadata = Metadata(
      size: totSize,
      duration: totDuration,
      creationTime: creationDate,
      lastModified: lastModifiedDate,
      lastAccessed: lastAccessedDate,
    );

    return _metadata;
  }

  // For JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Database ID
      'seriesId': seriesId, // Parent series ID
      'name': name,
      'path': path.path, // not nullable
      'episodes': episodes.map((e) => e.toJson()).toList(),
      'metadata': _metadata?.toJson(),
    };
  }

  // For JSON deserialization
  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'], // Database ID
      seriesId: json['seriesId'], // Parent series ID
      name: json['name'],
      path: PathString.fromJson(json['path'])!,
      episodes: (json['episodes'] as List).map((e) => Episode.fromJson(e)).toList(),
      metadata: json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null,
    );
  }

  Season copyWith({
    int? id,
    int? seriesId,
    String? name,
    PathString? path,
    List<Episode>? episodes,
    Metadata? metadata,
  }) {
    return Season(
      id: id ?? this.id,
      seriesId: seriesId ?? this.seriesId,
      name: name ?? this.name,
      path: path ?? this.path,
      episodes: episodes ?? this.episodes,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get episode by ID within this season
  Episode? getEpisodeById(int episodeId) => episodes.firstWhereOrNull((episode) => episode.id == episodeId);

  /// Get episode by number within this season
  Episode? getEpisodeByNumber(int episodeNumber) => episodes.firstWhereOrNull((episode) => episode.episodeNumber == episodeNumber);

  /// Get episode by path within this season
  Episode? getEpisodeByPath(PathString episodePath) => episodes.firstWhereOrNull((episode) => episode.path == episodePath);
}