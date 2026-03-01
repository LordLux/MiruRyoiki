/// Typed model for a Sonarr v3 episode object.
///
/// See: https://sonarr.tv/docs/api/#/Episode/get_api_v3_episode
class SonarrEpisode {
  final int id;
  final int episodeNumber;
  final int seasonNumber;
  final String title;
  final bool hasFile;
  final bool monitored;
  final String? airDateUtc;
  final String? overview;

  const SonarrEpisode({
    required this.id,
    required this.episodeNumber,
    required this.seasonNumber,
    required this.title,
    required this.hasFile,
    required this.monitored,
    this.airDateUtc,
    this.overview,
  });

  factory SonarrEpisode.fromJson(Map<String, dynamic> json) {
    return SonarrEpisode(
      id: json['id'] as int,
      episodeNumber: json['episodeNumber'] as int? ?? 0,
      seasonNumber: json['seasonNumber'] as int? ?? 0,
      title: json['title'] as String? ?? 'Unknown',
      hasFile: json['hasFile'] as bool? ?? false,
      monitored: json['monitored'] as bool? ?? true,
      airDateUtc: json['airDateUtc'] as String?,
      overview: json['overview'] as String?,
    );
  }

  @override
  String toString() => 'SonarrEpisode(S${seasonNumber.toString().padLeft(2, '0')}'
      'E${episodeNumber.toString().padLeft(2, '0')} "$title")';
}
