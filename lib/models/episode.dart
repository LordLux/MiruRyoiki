import 'dart:io';


import '../services/thumbnail_manager.dart';

class Episode {
  final String path; /// TODO use PathString
  final String name;
  String? thumbnailPath;
  bool watched;
  double watchedPercentage;
  bool thumbnailUnavailable;

  static final Map<String, int> _failedAttempts = {};
  static const int _maxAttempts = 3;

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
      'path': path,
      'name': name,
      'thumbnailPath': thumbnailPath,
      'watched': watched,
      'watchedPercentage': watchedPercentage,
      'thumbnailUnavailable': thumbnailUnavailable,
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
      thumbnailUnavailable: json['thumbnailUnavailable'] ?? false,
    );
  }

  Future<String?> getThumbnail() async {
    if (thumbnailUnavailable) return null;

    // Check if cached thumbnail already exists
    if (thumbnailPath != null) {
      final file = File(thumbnailPath!);
      if (await file.exists()) return thumbnailPath;
    }

    // Use the thumbnail manager to get or generate thumbnail
    final thumbnailManager = ThumbnailManager();
    final String? newThumbnailPath = await thumbnailManager.getThumbnail(path);

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
