import 'dart:io';

import '../services/isolates/thumbnail_manager.dart';
import '../utils/path_utils.dart';
import 'metadata.dart';
import 'mkv_metadata.dart';

class Episode {
  final int? id;
  final PathString path;
  final String name;
  final int? episodeNumber;
  PathString? thumbnailPath;
  bool watched;
  double watchedPercentage;
  bool thumbnailUnavailable;
  Metadata? metadata;
  MkvMetadata? mkvMetadata;

  Episode({
    this.id,
    required this.path,
    required this.name,
    this.episodeNumber,
    this.thumbnailPath,
    this.watched = false,
    this.watchedPercentage = 0.0,
    this.thumbnailUnavailable = false,
    this.metadata,
    this.mkvMetadata,
  });

  int? get resolvedEpisodeNumber => episodeNumber ?? _parseEpisodeNumberFromName();

  int? _parseEpisodeNumberFromName() {
    if (name.isEmpty) return null;
    
    // Try multiple patterns to extract episode numbers, in order of preference
    final patterns = [
      // Pattern 1: "1 - Title" or "01 - Title" (number at start followed by dash)
      RegExp(r'^(\d{1,3})\s*-'),
      
      // Pattern 2: "S01E01" or "S1E1" format anywhere in name  
      RegExp(r'S\d{1,2}E(\d{1,3})', caseSensitive: false),
      
      // Pattern 3: "Episode 1" or "Ep 1" format
      RegExp(r'(?:episode|ep)\s*(\d{1,3})', caseSensitive: false),
      
      // Pattern 4: "[01]" or "(01)" - number in brackets at start or after space
      RegExp(r'(?:^|\s)[\[\(](\d{1,3})[\]\)]'),
      
      // Pattern 5: " 01 " - standalone number with spaces (but not years like 2024)
      RegExp(r'\s(\d{1,2})\s'),
      
      // Pattern 6: "_01_" or ".01." - number surrounded by separators (prefer 1-2 digits)
      RegExp(r'[_\.](\d{1,2})[_\.]'),
      
      // Pattern 7: Start of filename with number (common in downloads)
      RegExp(r'^(\d{1,3})(?:\s|_|\.|$)'),
      
      // Pattern 8: Last resort - first 1-2 digit number in the name (avoid years)
      RegExp(r'(\d{1,2})'),
    ];
    
    for (int i = 0; i < patterns.length; i++) {
      final pattern = patterns[i];
      final match = pattern.firstMatch(name);
      if (match != null) {
        final episodeStr = match.group(1);
        if (episodeStr != null) {
          final episodeNum = int.tryParse(episodeStr);
          // Validate reasonable episode numbers (1-999, but prefer 1-99 for most patterns)
          if (episodeNum != null && episodeNum > 0 && episodeNum <= 999) {
            return episodeNum;
          }
        }
      }
    }
    
    return null;
  }

  @override
  String toString() {
    return """
    Episode(
      name: $name,
      number: $resolvedEpisodeNumber,
      metadata: $metadata,
      mkvMetadata: $mkvMetadata
    )
    """;
  }

  // ID-based equality when available
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Episode &&
          runtimeType == other.runtimeType &&
          (id != null && other.id != null
              ? id == other.id //
              : path == other.path); // Fall back to path

  @override
  int get hashCode => id?.hashCode ?? path.hashCode;

  // For JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path.path, // not nullable
      'episodeNumber': episodeNumber, // nullable
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
      id: json['id'],
      name: json['name'],
      path: PathString.fromJson(json['path'])!,
      episodeNumber: json['episodeNumber'],
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

  static void resetAllFailedAttempts() => ThumbnailManager().resetAllFailedAttempts();

  Episode copyWith({
    int? id,
    PathString? path,
    String? name,
    int? episodeNumber,
    PathString? thumbnailPath,
    bool? watched,
    double? watchedPercentage,
    bool? thumbnailUnavailable,
    Metadata? metadata,
    MkvMetadata? mkvMetadata,
  }) {
    return Episode(
      id: id ?? this.id,
      path: path ?? this.path,
      name: name ?? this.name,
      episodeNumber: episodeNumber ?? this.episodeNumber,
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
