class PlexMapping {
  final int anilistId;
  final int tvdbId;
  final int? tmdbShowId;
  final List<int> tvdbSeasons; // The seasons this AniList entry covers (e.g., [1])

  PlexMapping({
    required this.anilistId,
    required this.tvdbId,
    this.tmdbShowId,
    required this.tvdbSeasons,
  });

  factory PlexMapping.fromJson(String anilistIdKey, Map<String, dynamic> json) {
    // 1. Extract TVDB ID
    final tvdbId = json['tvdb_id'] as int? ?? 0;
    
    // 2. Extract TMDB ID (Optional, for future Radarr support)
    final tmdbShowId = json['tmdb_show_id'] as int?;

    // 3. Parse "tvdb_mappings" to find which seasons apply
    // Structure is like: { "s1": "e1-e12", "s2": "e13-" }
    final seasonKeys = (json['tvdb_mappings'] as Map<String, dynamic>? ?? {}).keys;
    
    final seasons = seasonKeys
        .where((key) => key.startsWith('s')) // Filter "s1", "s2"
        .map((key) => int.tryParse(key.substring(1))) // "s1" -> 1
        .whereType<int>() // Remove nulls
        .toList();

    return PlexMapping(
      anilistId: int.parse(anilistIdKey),
      tvdbId: tvdbId,
      tmdbShowId: tmdbShowId,
      tvdbSeasons: seasons.isNotEmpty ? seasons : [1], // Default to S1 if undefined
    );
  }
}