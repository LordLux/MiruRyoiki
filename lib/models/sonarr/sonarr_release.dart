class SonarrRelease {
  final String guid; // The unique ID needed to "grab" the file
  final String title;
  final int size;
  final int indexerId;
  final String indexer;
  final bool rejected; // Is it blocked by profile settings?
  final List<String> rejections;
  final int seeders;
  final int leechers;
  final String quality; // e.g. "1080p Web-DL"

  SonarrRelease({
    required this.guid,
    required this.title,
    required this.size,
    required this.indexerId,
    required this.indexer,
    required this.rejected,
    required this.rejections,
    required this.seeders,
    required this.leechers,
    required this.quality,
  });

  bool get isLikelyBatch {
    final lowerTitle = title.toLowerCase();
    // Common keywords indicating a multi-episode pack
    return lowerTitle.contains('batch') ||
        lowerTitle.contains('complete') ||
        // Regex looking for "S01" or "Season 1" without a specific "E01" following closely
        RegExp(r'(s\d+|season \d+)(?!.*e\d+)').hasMatch(lowerTitle);
  }

  factory SonarrRelease.fromJson(Map<String, dynamic> json) {
    return SonarrRelease(
      guid: json['guid'] ?? '',
      title: json['title'] ?? 'Unknown',
      size: json['size'] ?? 0,
      indexerId: json['indexerId'] ?? 0,
      indexer: json['indexer'] ?? 'Unknown',
      rejected: json['rejected'] ?? false,
      rejections: (json['rejections'] as List?)?.map((e) => e.toString()).toList() ?? [],
      seeders: json['seeders'] ?? 0,
      leechers: json['leechers'] ?? 0,
      quality: json['quality']?['quality']?['name'] ?? 'Unknown',
    );
  }
}
