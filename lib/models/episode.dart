import 'dart:io';

import '../services/isolates/thumbnail_manager.dart';
import '../utils/path_utils.dart';
import 'metadata.dart';
import 'mkv_metadata.dart';

class Episode {
  final PathString path;
  final String name;
  PathString? thumbnailPath;
  bool watched;
  double watchedPercentage;
  bool thumbnailUnavailable;
  Metadata? metadata;
  MkvMetadata? mkvMetadata;

  Episode({
    required this.path,
    required this.name,
    this.thumbnailPath,
    this.watched = false,
    this.watchedPercentage = 0.0,
    this.thumbnailUnavailable = false,
    this.metadata,
    this.mkvMetadata,
  });

  @override
  String toString() {
    return """
    Episode(
      name: $name,
      metadata: $metadata,
      mkvMetadata: $mkvMetadata
    )
    """;
  }

  // For JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path.path, // not nullable
      'thumbnailPath': thumbnailPath?.pathMaybe, // nullable
      'watched': watched,
      'watchedPercentage': watchedPercentage,
      'thumbnailUnavailable': thumbnailUnavailable,
      'metadata': metadata?.toJson(),
      'mkvMetadata': mkvMetadata?.toJson(),
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
      metadata: json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null,
      mkvMetadata: json['mkvMetadata'] != null ? MkvMetadata.fromJson(json['mkvMetadata']) : null,
    );
  }

  Future<PathString?> getThumbnail() async {
    if (thumbnailUnavailable) return null;

    // Check if cached thumbnail already exists
    if (thumbnailPath != null && thumbnailPath!.pathMaybe != null) {
      final file = File(thumbnailPath!.path);
      if (await file.exists()) return thumbnailPath;
    }

    // Use the thumbnail manager to get or generate thumbnail
    final thumbnailManager = ThumbnailManager();
    final PathString? newThumbnailPath = await thumbnailManager.getThumbnail(path);

    if (newThumbnailPath != null && newThumbnailPath.pathMaybe != null) {
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

  Episode copyWith({
    PathString? path,
    String? name,
    PathString? thumbnailPath,
    bool? watched,
    double? watchedPercentage,
    bool? thumbnailUnavailable,
    Metadata? metadata,
    MkvMetadata? mkvMetadata,
  }) {
    return Episode(
      path: path ?? this.path,
      name: name ?? this.name,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      watched: watched ?? this.watched,
      watchedPercentage: watchedPercentage ?? this.watchedPercentage,
      thumbnailUnavailable: thumbnailUnavailable ?? this.thumbnailUnavailable,
      metadata: metadata ?? this.metadata,
      mkvMetadata: mkvMetadata ?? this.mkvMetadata,
    );
  }

  String? get seriesName {
    if (path.path.isEmpty) return null;
    return path.getRelativeToMiruRyoikiSaveDirectory?.split(ps).first;
  }
}
