/// Represents a file that Sonarr has imported/tracked for a series
///
/// See: https://sonarr.tv/docs/api/#/EpisodeFile
class SonarrEpisodeFile {
  final int id;
  final int seriesId;
  final int seasonNumber;

  /// Path relative to the series root folder (e.g. "Season 01/file.mkv")
  final String relativePath;

  /// Absolute path on the Sonarr host filesystem
  final String path;

  final int size;
  final String? dateAdded;
  final String? qualityName;
  final String? releaseGroup;

  /// Episode IDs this file belongs to
  final List<int> episodeIds;

  const SonarrEpisodeFile({
    required this.id,
    required this.seriesId,
    required this.seasonNumber,
    required this.relativePath,
    required this.path,
    required this.size,
    this.dateAdded,
    this.qualityName,
    this.releaseGroup,
    this.episodeIds = const [],
  });

  factory SonarrEpisodeFile.fromJson(Map<String, dynamic> json) {
    String? qualityName;
    if (json['quality'] is Map) {
      final q = json['quality'] as Map;
      if (q['quality'] is Map) qualityName = (q['quality'] as Map)['name'] as String?;
    }

    return SonarrEpisodeFile(
      id: json['id'] as int,
      seriesId: json['seriesId'] as int? ?? 0,
      seasonNumber: json['seasonNumber'] as int? ?? 0,
      relativePath: json['relativePath'] as String? ?? '',
      path: json['path'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      dateAdded: json['dateAdded'] as String?,
      qualityName: qualityName,
      releaseGroup: json['releaseGroup'] as String?,
    );
  }

  /// Extracts just the filename from the relativePath
  String get fileName {
    final idx = relativePath.lastIndexOf('/');
    return idx >= 0 ? relativePath.substring(idx + 1) : relativePath;
  }

  @override
  String toString() => 'SonarrEpisodeFile(id: $id, S$seasonNumber, "$relativePath")';
}
