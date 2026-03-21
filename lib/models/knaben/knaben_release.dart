import '../../utils/units.dart';

/// A single torrent result returned by Knaben's `/v1` search API
class KnabenRelease {
  final String title;
  final String magnetUrl;
  final int bytes;
  final int seeders;
  final int peers;
  final String tracker;
  final double virusDetection;
  final String? category;
  final DateTime? dateAdded;

  const KnabenRelease({
    required this.title,
    required this.magnetUrl,
    required this.bytes,
    required this.seeders,
    required this.peers,
    required this.tracker,
    required this.virusDetection,
    this.category,
    this.dateAdded,
  });

  /// Whether the release is likely a multi-episode / season batch
  bool get isLikelyBatch {
    final lower = title.toLowerCase();
    return lower.contains('batch') ||
        lower.contains('complete') ||
        RegExp(r'(s\d+|season \d+)(?!.*e\d+)').hasMatch(lower);
  }

  /// Rough quality label derived from the title text.\
  String get quality {
    final lower = title.toLowerCase();
    if (lower.contains('2160p') || lower.contains('4k')) return '2160p';
    if (lower.contains('1080p')) return '1080p';
    if (lower.contains('720p')) return '720p';
    if (lower.contains('480p')) return '480p';
    return 'Unknown';
  }

  factory KnabenRelease.fromJson(Map<String, dynamic> json) {
    return KnabenRelease(
      title: json['title'] as String? ?? 'Unknown',
      magnetUrl: json['magnetUrl'] as String? ?? '',
      bytes: (json['bytes'] as num?)?.toInt() ?? 0,
      seeders: (json['seeders'] as num?)?.toInt() ?? 0,
      peers: (json['peers'] as num?)?.toInt() ?? 0,
      tracker: json['tracker'] as String? ?? 'Unknown',
      virusDetection: (json['virusDetection'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String?,
      dateAdded: json['date'] != null //
          ? DateTime.tryParse(json['date'] as String)
          : null,
    );
  }

  @override
  String toString() => 'KnabenRelease("$title", seeders: $seeders, ${fileSize(bytes)})';
}
