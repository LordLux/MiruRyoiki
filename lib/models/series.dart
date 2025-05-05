import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart' show ColorScheme, Colors;
import 'package:flutter/widgets.dart';
import 'package:palette_generator/palette_generator.dart';

import 'anilist/anime.dart';
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

  /// Anilist ID for the series
  int? anilistId;

  /// Anilist data for the series
  AnilistAnime? anilistData;

  /// Cached dominant color from poster image
  Color? _dominantColor;

  Series({
    required this.name,
    required this.path,
    this.folderImagePath,
    required this.seasons,
    this.relatedMedia = const [],
    this.anilistId,
    this.anilistData,
    Color? dominantColor,
  }) : _dominantColor = dominantColor;

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
      'anilistId': anilistId,
      'dominantColor': _dominantColor?.value,
    };
  }

  // For JSON deserialization
  factory Series.fromJson(Map<String, dynamic> json) {
    Color? dominantColor;
    if (json['dominantColor'] != null) //
      dominantColor = Color(json['dominantColor'] as int);

    return Series(
      name: json['name'],
      path: json['path'],
      folderImagePath: json['posterPath'],
      seasons: (json['seasons'] as List).map((s) => Season.fromJson(s)).toList(),
      relatedMedia: (json['relatedMedia'] as List?)?.map((e) => Episode.fromJson(e)).toList() ?? [],
      anilistId: json['anilistId'],
      dominantColor: dominantColor,
    );
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

  // Anilist Getters
  /// Banner image from Anilist
  String? get bannerImage => anilistData?.bannerImage;

  /// Poster image from Anilist
  String? get posterImage => anilistData?.posterImage;

  /// Official title from Anilist
  String get displayTitle =>
      anilistData?.title.userPreferred ?? //
      anilistData?.title.english ??
      anilistData?.title.romaji ??
      name;

  /// Description from Anilist
  String? get description => anilistData?.description;

  /// Rating from Anilist
  int? get rating => anilistData?.averageScore;

  /// Popularity from Anilist
  int? get popularity => anilistData?.popularity;

  /// Format from Anilist (TV, Movie, etc)
  String? get format => anilistData?.format;

  /// Genres from Anilist
  List<String> get genres => anilistData?.genres ?? [];
}
