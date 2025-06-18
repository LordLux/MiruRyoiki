import 'dart:io';


import '../services/thumbnail_manager.dart';
import '../utils/path_utils.dart';

class Episode {
  final PathString path;
  final String name;
  PathString? thumbnailPath;
  bool watched;
  double watchedPercentage;
  bool thumbnailUnavailable;

  Episode({
    required this.path,
    required this.name,
    this.thumbnailPath,
    this.watched = false,
    this.watchedPercentage = 0.0,
    this.thumbnailUnavailable = false,
  });

  // For JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path.path, // not nullable
      'thumbnailPath': thumbnailPath?.pathMaybe, // nullable
      'watched': watched,
      'watchedPercentage': watchedPercentage,
      'thumbnailUnavailable': thumbnailUnavailable,
    };
  }

  // For JSON deserialization
  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      name: json['name'],
      path: PathString.fromJson(json['path'])!,
      thumbnailPath: PathString.fromJson(json['thumbnailPath']),
      watched: json['watched'] ?? false,
      watchedPercentage: json['watchedPercentage'] ?? 0.0,
      thumbnailUnavailable: json['thumbnailUnavailable'] ?? false,
    );
  }

  Future<PathString?> getThumbnail() async {
    if (thumbnailUnavailable) return null;

    // Check if cached thumbnail already exists
    if (thumbnailPath != null) {
      final file = File(thumbnailPath!.path);
      if (await file.exists()) return thumbnailPath;
    }

    // Use the thumbnail manager to get or generate thumbnail
    final thumbnailManager = ThumbnailManager();
    final PathString? newThumbnailPath = await thumbnailManager.getThumbnail(path);

    if (newThumbnailPath != null) {
      thumbnailPath = newThumbnailPath;
      return newThumbnailPath;
    } else {
      thumbnailUnavailable = true;
      return null;
    }
  }

  void resetThumbnailStatus() {
    thumbnailUnavailable = false;
    ThumbnailManager().resetFailedAttemptsForPath(path);
  }

  static void resetAllFailedAttempts() => //
      ThumbnailManager().resetAllFailedAttempts();
}
