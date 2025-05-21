import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart' hide Image;
import 'package:palette_generator/palette_generator.dart';
import 'package:collection/collection.dart';

import '../manager.dart';
import '../services/cache.dart';
import '../utils/logging.dart';
import '../utils/path_utils.dart';
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

  @override
  String toString() {
    return '''
Season(
  name: $name, path: $path,
  episodes: $episodes
    )''';
  }

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
  String? folderPosterPath;

  /// Poster path for the series from the File System
  String? folderBannerPath;

  /// List of seasons for the series from the File System
  final List<Season> seasons;

  /// List of related media (ONA/OVA) for the series from the File System
  final List<Episode> relatedMedia;

  /// Anilist IDs for the series
  List<AnilistMapping> anilistMappings;

  /// Anilist data for the series
  AnilistAnime? _anilistData;

  /// Cached dominant color from poster image
  Color? _dominantColor;

  // The currently selected Anilist ID for display purposes
  int? _primaryAnilistId;

  /// Preferred source for the Poster
  ImageSource? preferredPosterSource;

  /// Preferred source for the Banner
  ImageSource? preferredBannerSource;

  /// Cached URL for Anilist Poster
  String? _anilistPosterUrl;

  /// Cached URL for Anilist Banner
  String? _anilistBannerUrl;
  
  // TODO add file info object to store info about the series folder (creation date, last modification date, size, etc)

  Series({
    required this.name,
    required this.path,
    this.folderPosterPath,
    this.folderBannerPath,
    required this.seasons,
    this.relatedMedia = const [],
    this.anilistMappings = const [],
    AnilistAnime? anilistData,
    Color? dominantColor,
    this.preferredPosterSource,
    this.preferredBannerSource,
    String? anilistPoster,
    String? anilistBanner,
    int? primaryAnilistId,
  })  : _anilistData = anilistData,
        _dominantColor = dominantColor,
        _anilistPosterUrl = anilistPoster,
        _anilistBannerUrl = anilistBanner,
        _primaryAnilistId = primaryAnilistId ?? anilistMappings.firstOrNull?.anilistId;

  Series copyWith({
    String? name,
    String? path,
    String? folderPosterPath,
    String? folderBannerPath,
    List<Season>? seasons,
    List<Episode>? relatedMedia,
    List<AnilistMapping>? anilistMappings,
    AnilistAnime? anilistData,
    Color? dominantColor,
    ImageSource? preferredPosterSource,
    ImageSource? preferredBannerSource,
    int? primaryAnilistId,
    String? anilistPoster,
    String? anilistBanner,
  }) {
    return Series(
      name: name ?? this.name,
      path: path ?? this.path,
      folderPosterPath: folderPosterPath ?? this.folderPosterPath,
      folderBannerPath: folderBannerPath ?? this.folderBannerPath,
      seasons: seasons ?? this.seasons,
      relatedMedia: relatedMedia ?? this.relatedMedia,
      anilistMappings: anilistMappings ?? this.anilistMappings,
      anilistData: anilistData ?? this._anilistData,
      dominantColor: dominantColor ?? this._dominantColor,
      preferredPosterSource: preferredPosterSource ?? this.preferredPosterSource,
      preferredBannerSource: preferredBannerSource ?? this.preferredBannerSource,
      primaryAnilistId: primaryAnilistId ?? this._primaryAnilistId,
      anilistPoster: anilistPoster ?? this._anilistPosterUrl,
      anilistBanner: anilistBanner ?? this._anilistBannerUrl,
    );
  }

  @override
  String toString() {
    return '''
Series(
  name: $name,
  path: '$path', 
  dominantColor: ${_dominantColor?.toHex() ?? 'None'},
  anilistData: ${_anilistData ?? 'None'},
  anilistPosterUrl: ${_anilistPosterUrl ?? 'None'},
  anilistBannerUrl: ${_anilistBannerUrl ?? 'None'},
)''';
  }

// Getter and setter for primaryAnilistId
  int? get primaryAnilistId => _primaryAnilistId ?? anilistId; // Fall back to the first mapping

  set primaryAnilistId(int? value) {
    if (value != null && anilistMappings.any((m) => m.anilistId == value)) {
      _primaryAnilistId = value;
    }
  }

  AnilistAnime? get anilistData => _anilistData;

  set anilistData(AnilistAnime? value) {
    _anilistData = value;
    _anilistPosterUrl = value?.posterImage;
    _anilistBannerUrl = value?.bannerImage;

    _dataVersion++;
  }

  // Backwards compatibility for older versions
  int? get anilistId => isLinked ? anilistMappings.first.anilistId : null;

  set anilistId(int? value) {
    if (value == null) {
      anilistMappings.clear();
    } else if (!isLinked) {
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

  int _dataVersion = 0;

// Include in the key for SeriesCard
  int get dataVersion => _dataVersion;

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
    // Always prioritize locally calculated color which respects DominantColorSource
    if (_dominantColor != null) {
      return _dominantColor;
    }

    // Fall back to Anilist color if locally calculated color is not available
    if (_anilistData?.dominantColor != null) {
      try {
        return _anilistData!.dominantColor!.fromHex();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Add getters
  String? get anilistPosterUrl => _anilistPosterUrl ?? _anilistData?.posterImage;
  String? get anilistBannerUrl => _anilistBannerUrl ?? _anilistData?.bannerImage;

  /// Calculate and cache the dominant color from the image
  Future<Color?> calculateDominantColor({bool forceRecalculate = false}) async {
    // If color already calculated and not forced, return cached color
    if (_dominantColor != null && !forceRecalculate) {
      logTrace('Using cached dominant color for $name: ${_dominantColor!.toHex()}');
      return _dominantColor;
    }

    // Skip if binding not initialized or no poster path
    if (!WidgetsBinding.instance.isRootWidgetAttached) {
      logDebug('WidgetsBinding not initialized, initializing...');
      WidgetsFlutterBinding.ensureInitialized();
    }
    if (folderPosterPath == null) {
      logTrace('No poster path available');
      return null;
    }
    logTrace('Calculating dominant color for $name...');
    // Get source type
    final DominantColorSource sourceType = Manager.dominantColorSource;
    String? imagePath;

    // Use the existing logic from effectivePosterPath/effectiveBannerPath
    if (sourceType == DominantColorSource.poster) {
      // For poster source, use the effectivePosterPath
      imagePath = effectivePosterPath;
      if (imagePath != null) {
        logTrace(isAnilistPoster ? 'Using Anilist poster for dominant color calculation' : 'Using local poster for dominant color calculation: "$imagePath"');
      }
    } else {
      // For banner source, use the effectiveBannerPath
      imagePath = effectiveBannerPath;
      if (imagePath != null) {
        logTrace(isAnilistBanner ? 'Using Anilist banner for dominant color calculation' : 'Using local banner for dominant color calculation: "$imagePath"');
      }
    }

    // If no image path found, return null
    if (imagePath == null) {
      logTrace('No image available for dominant color extraction');
      return null;
    }

    // For Anilist images, we need to get the cached path
    if ((sourceType == DominantColorSource.poster && isAnilistPoster) || (sourceType == DominantColorSource.banner && isAnilistBanner)) {
      imagePath = await _getAnilistCachedImagePath();
      if (imagePath == null) {
        logTrace('Failed to get cached Anilist image');
        return null;
      }
    }

    // Calculate color using compute to avoid UI blocking
    try {
      // Use compute to process on a background thread
      final imageFile = File(imagePath!);
      if (await imageFile.exists()) {
        final Uint8List imageBytes = await imageFile.readAsBytes();
        final Image image = (await decodeImageFromList(imageBytes));
        final ByteData byteData = (await image.toByteData())!;

        // Force UI update by using a separate isolate
        final Color? newColor = await compute(_isolateExtractColor, (byteData, image.width, image.height));
        logMulti([
          ['Dominant color calculated: '],
          [newColor?.toHex() ?? 'None', newColor ?? Colors.yellow, newColor == null ? Colors.red : Colors.transparent],
        ]);

        // Only update if the color actually changed
        if (newColor != null && (_dominantColor?.value != newColor.value)) {
          _dominantColor = newColor;
          _dataVersion++;
        }
        return _dominantColor;
      }
    } catch (e) {
      logErr('Error extracting dominant color', e);
    }
    return _dominantColor;
  }

  // Helper method to get cached Anilist images
  Future<String?> _getAnilistCachedImagePath() async {
    if (anilistData == null) return null;

    final imageCache = ImageCacheService();
    await imageCache.init();

    // Try poster first
    if (anilistData?.posterImage != null) {
      final path = await imageCache.getCachedImagePath(anilistData!.posterImage!);
      if (path != null) return path;
    }

    // Try banner next
    if (anilistData?.bannerImage != null) {
      return await imageCache.getCachedImagePath(anilistData!.bannerImage!);
    }

    return null;
  }

  // Static method to run in isolate
  static Future<Color?> _isolateExtractColor((ByteData, int, int) data) async {
    try {
      final byteData = data.$1;
      final width = data.$2;
      final height = data.$3;
      final EncodedImage encoded_image = EncodedImage(byteData, height: height, width: width);

      final paletteGenerator = await PaletteGenerator.fromByteData(encoded_image);

      // Try vibrant color first, fall back to dominant
      return paletteGenerator.vibrantColor?.color ?? paletteGenerator.dominantColor?.color;
    } catch (e) {
      logErr('Error extracting color from image', e);
      return null;
    }
  }

  /// JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'posterPath': folderPosterPath,
      'bannerPath': folderBannerPath,
      'seasons': seasons.map((s) => s.toJson()).toList(),
      'relatedMedia': relatedMedia.map((e) => e.toJson()).toList(),
      'anilistMappings': anilistMappings.map((m) => m.toJson()).toList(),
      'dominantColor': _dominantColor?.value,
      'dataVersion': _dataVersion,
      'primaryAnilistId': _primaryAnilistId,
      'anilistPosterUrl': _anilistPosterUrl ?? _anilistData?.posterImage,
      'anilistBannerUrl': _anilistBannerUrl ?? _anilistData?.bannerImage,
      if (preferredPosterSource != null) 'preferredPosterSource': preferredPosterSource!.name_,
      if (preferredBannerSource != null) 'preferredBannerSource': preferredBannerSource!.name_,
    };
  }

  /// JSON deserialization
  factory Series.fromJson(Map<String, dynamic> json) {
    Color? extractDominantColor(Map<String, dynamic> json) {
      if (json.containsKey('dominantColor') && json['dominantColor'] != null) {
        try {
          return Color(json['dominantColor'] as int);
        } catch (e) {
          logDebug('Error parsing dominant color: $e');
        }
      }
      return null;
    }

    List<AnilistMapping> extractAnilistMapping(Map<String, dynamic> json, String path) {
      final List<AnilistMapping> mappings = [];
      try {
        if (json.containsKey('anilistMappings') && json['anilistMappings'] != null) {
          // Handle newer format with anilistMappings array
          final mappingsJson = json['anilistMappings'] as List?;
          if (mappingsJson != null) {
            for (final mapping in mappingsJson) {
              if (mapping is Map<String, dynamic>) {
                try {
                  mappings.add(AnilistMapping.fromJson(mapping));
                } catch (e) {
                  logDebug('Error parsing individual Anilist mapping: $e');
                }
              }
            }
          }
        }
        // // Support legacy format with single anilistId
        // else if (json.containsKey('anilistId') && json['anilistId'] != null) {
        //   mappings.add(AnilistMapping(
        //     localPath: path,
        //     anilistId: json['anilistId'] as int,
        //   ));
        // }
      } catch (e) {
        logDebug('Error processing Anilist mappings: $e');
      }
      return mappings;
    }

    List<Season> extractSeasons(Map<String, dynamic> json, String path) {
      List<Season> seasons = [];
      try {
        if (json.containsKey('seasons') && json['seasons'] != null) {
          final seasonsJson = json['seasons'] as List?;
          if (seasonsJson != null) {
            for (final season in seasonsJson) {
              if (season is Map<String, dynamic>) {
                try {
                  seasons.add(Season.fromJson(season));
                } catch (e) {
                  logDebug('Error parsing season: $e');
                }
              }
            }
          }
        }
      } catch (e) {
        logDebug('Error processing seasons: $e');
        // Create empty season if none parsed successfully (required field)
        if (seasons.isEmpty) //
          seasons = [Season(name: 'Season 1', path: path, episodes: [])];
      }
      return seasons;
    }

    List<Episode> extractRelatedMedia(Map<String, dynamic> json, String path) {
      List<Episode> relatedMedia = [];
      try {
        if (json.containsKey('relatedMedia') && json['relatedMedia'] != null) {
          final mediaJson = json['relatedMedia'] as List?;
          if (mediaJson != null) {
            for (final episode in mediaJson) {
              if (episode is Map<String, dynamic>) {
                try {
                  relatedMedia.add(Episode.fromJson(episode));
                } catch (e) {
                  logDebug('Error parsing related media episode: $e');
                }
              }
            }
          }
        }
      } catch (e) {
        logDebug('Error processing related media: $e');
      }
      return relatedMedia;
    }

    try {
      // Validate required fields
      final name = json['name'] as String? ?? '';
      final path = json['path'] as String? ?? '';

      if (name.isEmpty || path.isEmpty) //
        logDebug('Warning: Series JSON missing required name or path: $json');

      // Process dominant color with safe parsing
      Color? dominantColor = extractDominantColor(json);

      // Process anilist mappings with validation
      List<AnilistMapping> mappings = extractAnilistMapping(json, path);

      // Process seasons with validation
      List<Season> seasons = extractSeasons(json, path);

      // Process related media with validation
      List<Episode> relatedMedia = extractRelatedMedia(json, path);

      // Create the Series instance
      final series = Series(
        name: name,
        path: path,
        folderPosterPath: json['posterPath'] as String?,
        folderBannerPath: json['bannerPath'] as String?,
        seasons: seasons,
        relatedMedia: relatedMedia,
        anilistMappings: mappings,
        dominantColor: dominantColor,
        anilistPoster: json['anilistPosterUrl'] as String?,
        anilistBanner: json['anilistBannerUrl'] as String?,
        // anilistData is not serialized directly, but retrieved on demand
        // preferredPosterSource and preferredBannerSource
        // are null by default to be set by the settings
      );

      // Set primary Anilist ID if available
      try {
        if (json.containsKey('primaryAnilistId') && json['primaryAnilistId'] != null) {
          series._primaryAnilistId = json['primaryAnilistId'] as int?;
          // Validate that the primary ID exists in mappings
          if (series._primaryAnilistId != null && !mappings.any((m) => m.anilistId == series._primaryAnilistId)) {
            logDebug('Warning: primaryAnilistId ${series._primaryAnilistId} not found in mappings');
          }
        }
      } catch (e) {
        logDebug('Error setting primaryAnilistId: $e');
      }

      // Set preferred poster source if available
      try {
        if (json['preferredPosterSource'] != null) {
          final sourceStr = json['preferredPosterSource'] as String?;
          if (sourceStr == 'local')
            series.preferredPosterSource = ImageSource.local;
          else if (sourceStr == 'anilist') //
            series.preferredPosterSource = ImageSource.anilist;
          // if the preferred source is not set, it will be decided by the setting
        }
      } catch (e) {
        logDebug('Error setting preferredPosterSource: $e');
      }

      // Set preferred banner source if available
      try {
        if (json['preferredBannerSource'] != null) {
          final sourceStr = json['preferredBannerSource'] as String?;
          if (sourceStr == 'local')
            series.preferredBannerSource = ImageSource.local;
          else if (sourceStr == 'anilist') //
            series.preferredBannerSource = ImageSource.anilist;
          // if the preferred source is not set, it will be decided by the setting
        }
      } catch (e) {
        logDebug('Error setting preferredBannerSource: $e');
      }

      return series;
    } catch (e) {
      // If anything fails critically, create a minimal valid series
      logDebug('Critical error parsing Series.fromJson: $e');
      return Series(
        name: json['name'] as String? ?? 'Unknown Series',
        path: json['path'] as String? ?? '',
        seasons: [],
      );
    }
  }

  factory Series.fromValues({
    required String name,
    required String path,
    String? folderPosterPath,
    String? folderBannerPath,
    required List<Season> seasons,
    List<Episode> relatedMedia = const [],
    List<AnilistMapping> anilistMappings = const [],
    int? primaryAnilistId,
    AnilistAnime? anilistData,
    ImageSource? preferredPosterSource,
    ImageSource? preferredBannerSource,
    Color? dominantColor,
    String? anilistPoster,
    String? anilistBanner,
  }) {
    final series = Series(
      name: name,
      path: path,
      folderPosterPath: folderPosterPath,
      folderBannerPath: folderBannerPath,
      seasons: seasons,
      relatedMedia: relatedMedia,
      anilistMappings: anilistMappings,
      dominantColor: dominantColor,
      preferredPosterSource: preferredPosterSource,
      preferredBannerSource: preferredBannerSource,
      anilistData: anilistData,
      primaryAnilistId: primaryAnilistId,
      anilistBanner: anilistBanner,
      anilistPoster: anilistPoster,
    );

    return series;
  }

  /// Getters for seasons and episodes
  List<Episode> getEpisodesForSeason([int i = 1]) {
    // TODO check if series has global episodes numbering or not
    if (i < 1 || i > seasons.length) //
      return <Episode>[];

    return seasons[i - 1].episodes;
  }

  /// Get ONA/OVA
  List<Episode> getUncategorizedEpisodes() {
    final categorizedEpisodes = seasons.expand((s) => s.episodes).toSet();
    return relatedMedia.where((e) => !categorizedEpisodes.contains(e)).toList();
  }

  /// Get the current Anilist data based on the primary Anilist ID
  AnilistAnime? get currentAnilistData {
    if (_primaryAnilistId == null) return _anilistData;

    // Find mapping with the primary ID
    final mapping = anilistMappings.firstWhereOrNull((m) => m.anilistId == _primaryAnilistId);

    // If found and has data, return it
    if (mapping != null && mapping.anilistData != null) {
      return mapping.anilistData;
    }

    // Fall back to the first mapping's data
    return _anilistData;
  }

  // Anilist Getters
  bool get isLinked => anilistMappings.isNotEmpty;

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
  
  /// Mean score from Anilist
  int? get meanScore => currentAnilistData?.meanScore;

  /// Popularity from Anilist
  int? get popularity => currentAnilistData?.popularity;

  /// Format from Anilist (TV, Movie, etc)
  String? get format => currentAnilistData?.format;

  /// Genres from Anilist
  List<String> get genres => currentAnilistData?.genres ?? [];

  /// Getter to check if the poster is from Anilist
  String? get effectivePosterPath {
    final ImageSource effectiveSource = preferredPosterSource ?? Manager.defaultPosterSource;

    // Determine available options
    final bool hasLocalPoster = folderPosterPath != null;
    final bool hasAnilistPoster = anilistPosterUrl != null;

    // Apply fallback logic based on source preference
    switch (effectiveSource) {
      case ImageSource.local:
        return hasLocalPoster ? folderPosterPath : (hasAnilistPoster ? anilistPosterUrl : null);

      case ImageSource.anilist:
        return hasAnilistPoster ? anilistPosterUrl : (hasLocalPoster ? folderPosterPath : null);

      case ImageSource.autoLocal:
        return hasLocalPoster ? folderPosterPath : (hasAnilistPoster ? anilistPosterUrl : null);

      case ImageSource.autoAnilist:
        return hasAnilistPoster ? anilistPosterUrl : (hasLocalPoster ? folderPosterPath : null);
    }
  }

  /// Getter to check if the poster actually being used is from Anilist
  bool get isAnilistPoster {
    if (effectivePosterPath == null) return false;
    return effectivePosterPath == anilistPosterUrl;
  }

  /// Getter to check if the poster actually being used is from a local file
  bool get isLocalPoster {
    if (effectivePosterPath == null) return false;
    return effectivePosterPath == folderPosterPath;
  }

  /// Get the effective poster image as an ImageProvider
  Future<ImageProvider?> getPosterImage() async {
    final path = effectivePosterPath;
    if (path == null) return null;

    if (isLocalPoster) {
      return FileImage(File(path));
    } else if (isAnilistPoster) {
      final imageCache = ImageCacheService();
      final cachedFile = await imageCache.getCachedImageFile(path);

      if (cachedFile != null) {
        return FileImage(cachedFile);
      } else {
        // Also start caching for future use
        imageCache.cacheImage(path);
        return NetworkImage(path);
      }
    }
    return null;
  }

  //
  //
  /// Getter to check if the banner is from Anilist or local file
  String? get effectiveBannerPath {
    final ImageSource effectiveSource = preferredBannerSource ?? Manager.defaultBannerSource;

    // Determine available options
    final bool hasLocalBanner = folderBannerPath != null;
    final bool hasAnilistBanner = anilistBannerUrl != null;

    // Apply fallback logic based on source preference
    switch (effectiveSource) {
      case ImageSource.local:
        return hasLocalBanner ? folderBannerPath : (hasAnilistBanner ? anilistBannerUrl : null);

      case ImageSource.anilist:
        return hasAnilistBanner ? anilistBannerUrl : (hasLocalBanner ? folderBannerPath : null);

      case ImageSource.autoLocal:
        return hasLocalBanner ? folderBannerPath : (hasAnilistBanner ? anilistBannerUrl : null);

      case ImageSource.autoAnilist:
        return hasAnilistBanner ? anilistBannerUrl : (hasLocalBanner ? folderBannerPath : null);
    }
  }

  /// Getter to check if the banner actually being used is from Anilist
  bool get isAnilistBanner {
    if (effectiveBannerPath == null) return false;
    return effectiveBannerPath == anilistBannerUrl;
  }

  /// Getter to check if the banner actually being used is from a local file
  bool get isLocalBanner {
    if (effectiveBannerPath == null) return false;
    return effectiveBannerPath == folderBannerPath;
  }

  /// Get the effective banner image as an ImageProvider
  Future<ImageProvider?> getBannerImage() async {
    final path = effectiveBannerPath;
    if (path == null) return null;

    if (isLocalBanner) {
      return FileImage(File(path));
    } else if (isAnilistBanner) {
      final imageCache = ImageCacheService();
      final cachedFile = await imageCache.getCachedImageFile(path);

      if (cachedFile != null) {
        return FileImage(cachedFile);
      } else {
        // Also start caching for future use
        imageCache.cacheImage(path);
        return NetworkImage(path);
      }
    }
    return null;
  }
}
