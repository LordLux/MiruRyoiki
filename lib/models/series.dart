import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart' show ColorScheme, Colors;
import 'package:flutter/widgets.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:collection/collection.dart';

import 'anilist/anime.dart';
import 'anilist/mapping.dart';
import 'episode.dart';
import '../enums.dart';

class Season {
  final String name;
  final String path;
  final List<Episode> episodes;

  Season({
    required this.name,
    required this.path,
    required this.episodes,
  });

  int get watchedCount => episodes.where((e) => e.watched).length;
  int get totalCount => episodes.length;
  double get watchedPercentage => totalCount > 0 ? watchedCount / totalCount : 0.0;

  // For JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'episodes': episodes.map((e) => e.toJson()).toList(),
    };
  }

  // For JSON deserialization
  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      name: json['name'],
      path: json['path'],
      episodes: (json['episodes'] as List).map((e) => Episode.fromJson(e)).toList(),
    );
  }
}

class Series {
  /// Name of the series from the File System
  final String name;

  /// Path for the series from the File System
  final String path;

  /// Poster path for the series from the File System
  final String? folderImagePath;

  /// List of seasons for the series from the File System
  final List<Season> seasons;

  /// List of related media (ONA/OVA) for the series from the File System
  final List<Episode> relatedMedia;

  /// Anilist IDs for the series
  List<AnilistMapping> anilistMappings;

  /// Anilist data for the series
  AnilistAnime? anilistData;

  /// Cached dominant color from poster image
  Color? _dominantColor;

  // The currently selected Anilist ID for display purposes
  int? _primaryAnilistId;

  Series({
    required this.name,
    required this.path,
    this.folderImagePath,
    required this.seasons,
    this.relatedMedia = const [],
    this.anilistMappings = const [],
    this.anilistData,
    Color? dominantColor,
  }) : _dominantColor = dominantColor;

// Getter and setter for primaryAnilistId
  int? get primaryAnilistId => _primaryAnilistId ?? anilistId; // Fall back to the first mapping

  set primaryAnilistId(int? value) {
    if (value != null && anilistMappings.any((m) => m.anilistId == value)) {
      _primaryAnilistId = value;
    }
  }

  // Backwards compatibility for older versions
  int? get anilistId => anilistMappings.isNotEmpty ? anilistMappings.first.anilistId : null;
  set anilistId(int? value) {
    if (value == null) {
      anilistMappings.clear();
    } else if (anilistMappings.isEmpty) {
      anilistMappings.add(AnilistMapping(
        localPath: path,
        anilistId: value,
      ));
    } else {
      anilistMappings[0] = AnilistMapping(
        localPath: path,
        anilistId: value,
        title: anilistMappings[0].title,
        lastSynced: anilistMappings[0].lastSynced,
      );
    }
  }

  // Helper to find mapping for a path
  AnilistMapping? getMappingForPath(String path) {
    // Exact match
    for (var mapping in anilistMappings) {
      if (mapping.localPath == path) {
        return mapping;
      }
    }

    // Parent folder match (for nested files)
    for (var mapping in anilistMappings) {
      if (path.startsWith(mapping.localPath)) {
        return mapping;
      }
    }

    return null;
  }

  // Get Anilist ID for an episode
  int? getAnilistIdForEpisode(Episode episode) => getMappingForPath(episode.path)?.anilistId;

  /// Total number of episodes across all seasons and related media
  int get totalEpisodes => seasons.fold(0, (sum, season) => sum + season.episodes.length) + relatedMedia.length;

  /// Total watched episodes across all seasons and related media
  int get watchedEpisodes => seasons.fold(0, (sum, season) => sum + season.watchedCount) + relatedMedia.where((e) => e.watched).length;

  /// Percentage of watched episodes
  double get watchedPercentage => totalEpisodes > 0 ? watchedEpisodes / totalEpisodes : 0.0;

  /// Primary color from the series poster image
  Color? get dominantColor {
    // If Anilist provides a color, use that
    if (anilistData?.dominantColor != null) {
      try {
        return Color(int.parse(anilistData!.dominantColor!.replaceAll('#', '0xff')));
      } catch (e) {
        // Fall back to locally calculated color
        return _dominantColor;
      }
    }
    // Otherwise use locally calculated color
    return _dominantColor;
  }

  /// Calculate and cache the dominant color from the poster image
  Future<Color?> calculateDominantColor() async {
    if (folderImagePath == null) return null;

    try {
      final File imageFile = File(folderImagePath!);
      if (!imageFile.existsSync()) return null;

      final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
        FileImage(imageFile),
        maximumColorCount: 10,
      );

      // Try to get a vibrant color first for better UI aesthetics
      _dominantColor = paletteGenerator.vibrantColor?.color ?? paletteGenerator.dominantColor?.color ?? Colors.blue; // Fallback color

      return _dominantColor;
    } catch (e) {
      debugPrint('Error extracting dominant color: $e');
      return null;
    }
  }

  // For JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'posterPath': folderImagePath,
      'seasons': seasons.map((s) => s.toJson()).toList(),
      'relatedMedia': relatedMedia.map((e) => e.toJson()).toList(),
      'anilistMappings': anilistMappings.map((m) => m.toJson()).toList(),
      'dominantColor': _dominantColor?.value,
      'primaryAnilistId': _primaryAnilistId,
    };
  }

  // For JSON deserialization
  factory Series.fromJson(Map<String, dynamic> json) {
    // Process dominant color
    Color? dominantColor;
    if (json['dominantColor'] != null) {
      dominantColor = Color(json['dominantColor'] as int);
    }

    // Process anilist mappings
    List<AnilistMapping> mappings = [];

    // Handle newer format with anilistMappings array
    if (json.containsKey('anilistMappings')) {
      mappings = (json['anilistMappings'] as List).map((m) => AnilistMapping.fromJson(m as Map<String, dynamic>)).toList();
    }
    // Support legacy format with single anilistId
    else if (json.containsKey('anilistId') && json['anilistId'] != null) {
      mappings.add(AnilistMapping(
        localPath: json['path'],
        anilistId: json['anilistId'] as int,
      ));
    }

    final series = Series(
      name: json['name'],
      path: json['path'],
      folderImagePath: json['posterPath'],
      seasons: (json['seasons'] as List).map((s) => Season.fromJson(s as Map<String, dynamic>)).toList(),
      relatedMedia: (json['relatedMedia'] as List?)?.map((e) => Episode.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      anilistMappings: mappings,
      dominantColor: dominantColor,
    );
    if (json['primaryAnilistId'] != null) //
      series._primaryAnilistId = json['primaryAnilistId'];

    return series;
  }

  List<Episode> getEpisodesForSeason([int i = 1]) {
    // TODO check if series has global episodes numbering or not
    if (i < 1 || i > seasons.length) //
      return <Episode>[];

    return seasons[i - 1].episodes;
  }

  // ONA/OVA
  List<Episode> getUncategorizedEpisodes() {
    final categorizedEpisodes = seasons.expand((s) => s.episodes).toSet();
    return relatedMedia.where((e) => !categorizedEpisodes.contains(e)).toList();
  }

  AnilistAnime? get currentAnilistData {
    if (_primaryAnilistId == null) return anilistData;

    // Find mapping with the primary ID
    final mapping = anilistMappings.firstWhereOrNull((m) => m.anilistId == _primaryAnilistId);

    // If found and has data, return it
    if (mapping != null && mapping.anilistData != null) {
      return mapping.anilistData;
    }

    // Fall back to the first mapping's data
    return anilistData;
  }

  // Anilist Getters
  /// Banner image from Anilist
  String? get bannerImage => currentAnilistData?.bannerImage;

  /// Poster image from Anilist
  String? get posterImage => currentAnilistData?.posterImage;

  /// Official title from Anilist
  String get displayTitle =>
      currentAnilistData?.title.userPreferred ?? //
      currentAnilistData?.title.english ??
      currentAnilistData?.title.romaji ??
      name;

  /// Description from Anilist
  String? get description => currentAnilistData?.description;

  /// Rating from Anilist
  int? get rating => currentAnilistData?.averageScore;

  /// Popularity from Anilist
  int? get popularity => currentAnilistData?.popularity;

  /// Format from Anilist (TV, Movie, etc)
  String? get format => currentAnilistData?.format;

  /// Genres from Anilist
  List<String> get genres => currentAnilistData?.genres ?? [];
}
