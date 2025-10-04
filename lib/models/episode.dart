import 'dart:io';
import 'package:flutter_anitomy/flutter_anitomy.dart';

import '../manager.dart';
import '../services/isolates/thumbnail_manager.dart';
import '../utils/path.dart';
import 'metadata.dart';
import 'mkv_metadata.dart';

class Episode {
  final int? id;
  final PathString path;
  final String name;
  int? _episodeNumber;
  PathString? thumbnailPath;
  bool watched;
  double _progress;
  bool thumbnailUnavailable;
  Metadata? metadata;
  MkvMetadata? mkvMetadata;
  String? _anilistTitle;
  late final ParsedAnime _parsedAnime;

  Episode({
    this.id,
    required this.path,
    required this.name,
    int? episodeNumber,
    this.thumbnailPath,
    this.watched = false,
    double progress = 0.0,
    this.thumbnailUnavailable = false,
    this.metadata,
    this.mkvMetadata,
    String? anilistTitle,
  })  : _episodeNumber = episodeNumber,
        _progress = progress {
    _parsedAnime = FlutterAnitomy().parse(path.name!);
    _episodeNumber ??= int.tryParse(_parsedAnime.episode ?? '');
    this.anilistTitle = anilistTitle;
  }

  String? get anilistTitle => _trimEpNumber(_anilistTitle);
  set anilistTitle(String? value) => _anilistTitle = _trimEpNumber(value);
  String? _trimEpNumber(String? title) {
    if (title == null) return null;
    final trimmed = title.trim();
    final prefixReg = RegExp(r'^(?:Episode|Ep|E)\s*\d{1,3}', caseSensitive: false);
    final prefixMatch = prefixReg.firstMatch(trimmed);
    if (prefixMatch == null) return trimmed;

    final remainder = trimmed.substring(prefixMatch.end).trim();
    if (remainder.isEmpty) {
      // No separator/title after the episode number -> keep the episode string
      return prefixMatch.group(0)!.trim();
    }

    // If there's a separator and a non-empty title, remove the "Episode N - " prefix and return the title.
    final sepStripped = remainder.replaceFirst(RegExp(r'^[-–:]\s*'), '').trim();
    return sepStripped.isEmpty ? prefixMatch.group(0)!.trim() : sepStripped;
  }

  /// Returns progress as a value between 0.0 and 1.0
  double get progress => double.parse(_progress.toStringAsFixed(2));
  set progress(double value) {
    if (value < 0.0 || value > 1.0) throw ArgumentError('Progress must be between 0.0 and 1.0');
    _progress = value;
  }

  /// Returns progress as a percentage string like "75%"
  String get progressPercentage => '${(progress * 100).toStringAsFixed(0)}%';

  /// Returns the episode number, either from metadata or parsed from the name
  int? get episodeNumber => _episodeNumber ?? int.tryParse(_parsedAnime.episode ?? '');
  set episodeNumber(int? value) => _episodeNumber = value;

  /// Returns the display title, prioritizing AniList title over filename
  String? get displayTitle => (Manager.enableAnilistEpisodeTitles ? anilistTitle : null) ?? _parsedAnime.episodeTitle;

  @override
  String toString() {
    return """
    Episode(
      name: $name,
      number: $episodeNumber,
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
      'episodeNumber': _episodeNumber, // nullable
      'thumbnailPath': thumbnailPath?.pathMaybe, // nullable
      'watched': watched,
      'watchedPercentage': progress,
      'thumbnailUnavailable': thumbnailUnavailable,
      'metadata': metadata?.toJson(),
      'mkvMetadata': mkvMetadata?.toJson(),
      'anilistTitle': anilistTitle, // nullable
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
      progress: json['watchedPercentage'] ?? 0.0,
      thumbnailUnavailable: json['thumbnailUnavailable'] ?? false,
      metadata: json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null,
      mkvMetadata: json['mkvMetadata'] != null ? MkvMetadata.fromJson(json['mkvMetadata']) : null,
      anilistTitle: json['anilistTitle'],
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
    double? progress,
    bool? thumbnailUnavailable,
    Metadata? metadata,
    MkvMetadata? mkvMetadata,
    String? anilistTitle,
  }) {
    return Episode(
      id: id ?? this.id,
      path: path ?? this.path,
      name: name ?? this.name,
      episodeNumber: episodeNumber ?? _episodeNumber,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      watched: watched ?? this.watched,
      progress: progress ?? this.progress,
      thumbnailUnavailable: thumbnailUnavailable ?? this.thumbnailUnavailable,
      metadata: metadata ?? this.metadata,
      mkvMetadata: mkvMetadata ?? this.mkvMetadata,
      anilistTitle: anilistTitle ?? this.anilistTitle,
    );
  }

  String? get seriesName {
    if (path.path.isEmpty) return null;
    return path.getRelativeToMiruRyoikiSaveDirectory?.split(ps).first;
  }

  /// Whether the display title is in a simple format (e.g., "Episode 1")
  bool get isDisplayTitleSimple => RegExp(r'^(Episode|Ep|E) \d{1,3}$', caseSensitive: false).hasMatch(displayTitle ?? '');

  /// Whether the title was successfully parsed from the filename
  bool get isTitleParsable => _parsedAnime.episodeTitle != null;
}
