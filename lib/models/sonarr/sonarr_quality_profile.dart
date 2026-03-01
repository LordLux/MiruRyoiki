/// Typed model for a Sonarr v3 quality profile.
///
/// See: https://sonarr.tv/docs/api/#/QualityProfile/get_api_v3_qualityprofile
class SonarrQualityProfile {
  final int id;
  final String name;

  const SonarrQualityProfile({
    required this.id,
    required this.name,
  });

  factory SonarrQualityProfile.fromJson(Map<String, dynamic> json) {
    return SonarrQualityProfile(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
    );
  }

  @override
  String toString() => 'SonarrQualityProfile($id: "$name")';
}
