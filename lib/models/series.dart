import 'episode.dart';

class Season {
  final String name;
  final String path;
  final List<Episode> episodes;

  Season({
    required this.name,
    required this.path,
    required this.episodes,
  });

  int get watchedCount => episodes.where((e) => e.watched).length;
  int get totalCount => episodes.length;
  double get watchedPercentage => totalCount > 0 ? watchedCount / totalCount : 0.0;

  // For JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'episodes': episodes.map((e) => e.toJson()).toList(),
    };
  }

  // For JSON deserialization
  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      name: json['name'],
      path: json['path'],
      episodes: (json['episodes'] as List).map((e) => Episode.fromJson(e)).toList(),
    );
  }
}

class Series {
  final String name;
  final String path;
  final String? posterPath;
  final List<Season> seasons;
  final List<Episode> relatedMedia;

  Series({
    required this.name,
    required this.path,
    this.posterPath,
    required this.seasons,
    this.relatedMedia = const [],
  });

  int get totalEpisodes => seasons.fold(0, (sum, season) => sum + season.episodes.length) + relatedMedia.length;

  int get watchedEpisodes => seasons.fold(0, (sum, season) => sum + season.watchedCount) + relatedMedia.where((e) => e.watched).length;

  double get watchedPercentage => totalEpisodes > 0 ? watchedEpisodes / totalEpisodes : 0.0;

  // For JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'posterPath': posterPath,
      'seasons': seasons.map((s) => s.toJson()).toList(),
      'relatedMedia': relatedMedia.map((e) => e.toJson()).toList(),
    };
  }

  // For JSON deserialization
  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      name: json['name'],
      path: json['path'],
      posterPath: json['posterPath'],
      seasons: (json['seasons'] as List).map((s) => Season.fromJson(s)).toList(),
      relatedMedia: (json['relatedMedia'] as List?)?.map((e) => Episode.fromJson(e)).toList() ?? [],
    );
  }

  List<Episode> getEpisodesForSeason([int i = 1]) {
    // TODO check if series has global episodes numbering or not
    if (i < 1 || i > seasons.length) //
      return <Episode>[];

    return seasons[i - 1].episodes;
  }

  // ONA/OVA
  List<Episode> getUncategorizedEpisodes() {
    final categorizedEpisodes = seasons.expand((s) => s.episodes).toSet();
    return relatedMedia.where((e) => !categorizedEpisodes.contains(e)).toList();
  }
}
