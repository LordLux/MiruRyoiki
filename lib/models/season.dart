// ignore_for_file: library_prefixes, unnecessary_this

import 'package:miruryoiki/models/metadata.dart';
import 'package:collection/collection.dart';

import '../enums.dart';
import '../utils/path.dart';
import 'episode.dart';

/// Regex pattern used to identify season-formatted directory names
/// 
/// Matches "Season 1", "season 12", "S1", "s1", "S 12", etc
final _seasonPattern = RegExp(r'^[Ss](?:eason)?\s*(\d+)$');

/// Returns the season number if [name] matches a season pattern, or null otherwise
int? parseSeasonNumber(String name) {
  final match = _seasonPattern.firstMatch(name.trim());
  if (match != null) return int.parse(match.group(1)!);
  return null;
}

/// Returns true if [name] matches a known season directory pattern
bool isSeasonName(String name) => parseSeasonNumber(name) != null;

/// Abstract base class for a named group of episodes rooted at a filesystem directory
///
/// Subclasses:
/// - [Season]: A numbered season folder (e.g., "Season 1", "S01")
/// - [Folder]: An arbitrary subfolder (e.g., "OVAs", "Specials", "Movies")
abstract class EpisodeCollection {
  /// Database ID
  final int? id;

  /// Database ID for parent Series
  final int? seriesId;

  /// Name of the collection (folder name or formatted season name)
  final String name;

  /// Path for the collection from the File System
  final PathString path;

  /// List of Episodes in this collection
  final List<Episode> episodes;

  Metadata? _metadata;

  EpisodeCollection({
    this.id,
    this.seriesId,
    required this.name,
    required this.path,
    required this.episodes,
    Metadata? metadata,
  }) : _metadata = metadata;

  /// Display-friendly name for this collection
  String get prettyName;

  int get watchedCount => episodes.where((e) => e.watched).length;
  int get totalCount => episodes.length;
  double get watchedPercentage => totalCount > 0 ? watchedCount / totalCount : 0.0;

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

  /// Get episode by ID within this collection
  Episode? getEpisodeById(int episodeId) => episodes.firstWhereOrNull((episode) => episode.id == episodeId);

  /// Get episode by number within this collection
  Episode? getEpisodeByNumber(int episodeNumber) => episodes.firstWhereOrNull((episode) => episode.episodeNumber == episodeNumber);

  /// Get episode by path within this collection
  Episode? getEpisodeByPath(PathString episodePath) => episodes.firstWhereOrNull((episode) => episode.path == episodePath);

  EpisodeCollection copyWith({
    int? id,
    int? seriesId,
    String? name,
    PathString? path,
    List<Episode>? episodes,
    Metadata? metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seriesId': seriesId,
      'type': this is Season ? 'season' : 'folder',
      'name': name,
      'path': path.path,
      'episodes': episodes.map((e) => e.toJson()).toList(),
      'metadata': _metadata?.toJson(),
    };
  }

  factory EpisodeCollection.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    final name = json['name'] as String;

    // Determine type from explicit field, or infer from name
    if (type == 'season' || (type == null && isSeasonName(name))) {
      return Season.fromJson(json);
    }
    return Folder.fromJson(json);
  }

  @override
  String toString() {
    return '''
      $runtimeType(
        name: $name, path: $path,
        episodes: $episodes
      )
    ''';
  }
}

/// A numbered season folder (e.g., "Season 1", "S01")
class Season extends EpisodeCollection {
  /// The parsed season number
  final int seasonNumber;

  Season({
    super.id,
    super.seriesId,
    required super.name,
    required super.path,
    required super.episodes,
    super.metadata,
    required this.seasonNumber,
  });

  /// Creates a Season by parsing the season number from [name]
  /// 
  /// Returns null if [name] doesn't match a season pattern
  static Season? tryParse({
    int? id,
    int? seriesId,
    required String name,
    required PathString path,
    required List<Episode> episodes,
    Metadata? metadata,
  }) {
    final num = parseSeasonNumber(name);
    if (num == null) return null;
    return Season(
      id: id,
      seriesId: seriesId,
      name: name,
      path: path,
      episodes: episodes,
      metadata: metadata,
      seasonNumber: num,
    );
  }

  @override
  String get prettyName {
    if (name.isEmpty) return 'Season';
    return 'Season $seasonNumber';
  }

  @override
  Season copyWith({
    int? id,
    int? seriesId,
    String? name,
    PathString? path,
    List<Episode>? episodes,
    Metadata? metadata,
    int? seasonNumber,
  }) {
    return Season(
      id: id ?? this.id,
      seriesId: seriesId ?? this.seriesId,
      name: name ?? this.name,
      path: path ?? this.path,
      episodes: episodes ?? this.episodes,
      metadata: metadata ?? this.metadata,
      seasonNumber: seasonNumber ?? this.seasonNumber,
    );
  }

  factory Season.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    return Season(
      id: json['id'],
      seriesId: json['seriesId'],
      name: name,
      path: PathString.fromJson(json['path'])!,
      episodes: (json['episodes'] as List).map((e) => Episode.fromJson(e)).toList(),
      metadata: json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null,
      seasonNumber: parseSeasonNumber(name) ?? 1,
    );
  }
}

/// An arbitrary subfolder that is not a numbered season (e.g., "OVAs", "Specials", "Movies")
class Folder extends EpisodeCollection {
  /// Sentinel name used for root-level loose files
  static const uncategorizedName = '__uncategorized__';

  Folder({
    super.id,
    super.seriesId,
    required super.name,
    required super.path,
    required super.episodes,
    super.metadata,
  });

  /// Whether this folder represents the synthetic "Uncategorized" group for root-level files.
  bool get isUncategorized => name == uncategorizedName;

  @override
  String get prettyName => isUncategorized ? 'Uncategorized' : name;

  @override
  Folder copyWith({
    int? id,
    int? seriesId,
    String? name,
    PathString? path,
    List<Episode>? episodes,
    Metadata? metadata,
  }) {
    return Folder(
      id: id ?? this.id,
      seriesId: seriesId ?? this.seriesId,
      name: name ?? this.name,
      path: path ?? this.path,
      episodes: episodes ?? this.episodes,
      metadata: metadata ?? this.metadata,
    );
  }

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'],
      seriesId: json['seriesId'],
      name: json['name'],
      path: PathString.fromJson(json['path'])!,
      episodes: (json['episodes'] as List).map((e) => Episode.fromJson(e)).toList(),
      metadata: json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null,
    );
  }
}
