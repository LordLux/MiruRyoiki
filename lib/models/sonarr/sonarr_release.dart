part of '../torrent_release.dart';

class SonarrRelease extends TorrentRelease {
  final String guid;
  @override
  final String title;
  final int size;
  final int indexerId;
  final String indexer;
  final bool rejected; // If it's blocked by user profile settings
  final List<String> rejections; // Reasons why it was rejected
  @override
  final int seeders;
  final int leechers;
  @override
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

  @override
  int get bytes => size;

  @override
  int get peers => leechers;

  @override
  String get tracker => indexer;

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
