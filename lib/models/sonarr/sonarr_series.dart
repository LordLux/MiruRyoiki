/// Typed model for a Sonarr v3 series object.
///
/// See: https://sonarr.tv/docs/api/#/Series/get_api_v3_series
class SonarrSeries {
  final int id;
  final String title;
  final int tvdbId;
  final int seasonCount;
  final int episodeCount;
  final int episodeFileCount;
  final String status; // "continuing", "ended", "upcoming", "deleted"
  final bool monitored;
  final int qualityProfileId;

  const SonarrSeries({
    required this.id,
    required this.title,
    required this.tvdbId,
    required this.seasonCount,
    required this.episodeCount,
    required this.episodeFileCount,
    required this.status,
    required this.monitored,
    required this.qualityProfileId,
  });

  factory SonarrSeries.fromJson(Map<String, dynamic> json) {
    final statistics = json['statistics'] as Map<String, dynamic>? ?? {};
    return SonarrSeries(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Unknown',
      tvdbId: json['tvdbId'] as int? ?? 0,
      seasonCount: statistics['seasonCount'] as int? ?? json['seasonCount'] as int? ?? 0,
      episodeCount: statistics['episodeCount'] as int? ?? 0,
      episodeFileCount: statistics['episodeFileCount'] as int? ?? 0,
      status: json['status'] as String? ?? 'unknown',
      monitored: json['monitored'] as bool? ?? false,
      qualityProfileId: json['qualityProfileId'] as int? ?? 0,
    );
  }

  /// Whether all episodes have files downloaded.
  bool get isComplete => episodeCount > 0 && episodeFileCount >= episodeCount;

  @override
  String toString() => 'SonarrSeries($id: "$title" [$status])';
}
