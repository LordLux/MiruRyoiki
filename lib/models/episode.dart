import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../services/media_info.dart';

class Episode {
  final String path;
  final String name;
  String? thumbnailPath;
  bool watched;
  double watchedPercentage;

  Episode({
    required this.path,
    required this.name,
    this.thumbnailPath,
    this.watched = false,
    this.watchedPercentage = 0.0,
  });

  // For JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'name': name,
      'thumbnailPath': thumbnailPath,
      'watched': watched,
      'watchedPercentage': watchedPercentage,
    };
  }

  // For JSON deserialization
  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      path: json['path'],
      name: json['name'],
      thumbnailPath: json['thumbnailPath'],
      watched: json['watched'] ?? false,
      watchedPercentage: json['watchedPercentage'] ?? 0.0,
    );
  }

  Future<String?> getThumbnail() async {
    if (thumbnailPath != null) {
      // Check if the file exists
      final file = File(thumbnailPath!);
      if (await file.exists()) return thumbnailPath;
    }

    // Check if we already have a cached thumbnail
    final String cachePath = await _getCachedThumbnailPath();

    // If thumbnail exists, return it
    if (await File(cachePath).exists()) {
      thumbnailPath = cachePath;
      return cachePath;
    }

    final newThumbnailPath = await MediaInfo.extractThumbnail(path, outputPath: cachePath);
    if (newThumbnailPath != null) thumbnailPath = newThumbnailPath;

    return newThumbnailPath;
  }

  Future<String> _getCachedThumbnailPath() async {
    final tempDir = await getTemporaryDirectory();
    final String filename = basenameWithoutExtension(path);
    final String seriesName = basename(dirname(path));
    final String thumbnailPath = join(tempDir.path, 'miruryoiki_thumbnails', seriesName, '$filename.png');

    // Ensure directory exists
    final directory = Directory(dirname(thumbnailPath));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return thumbnailPath;
  }
}
