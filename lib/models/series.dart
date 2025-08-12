import 'dart:io';
import 'dart:math' show min;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart' hide Image;
import 'package:miruryoiki/models/metadata.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';

import '../manager.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../services/file_system/cache.dart';
import '../utils/logging.dart';
import '../utils/path_utils.dart';
import 'anilist/anime.dart';
import 'anilist/mapping.dart';
import 'anilist/user_list.dart';
import 'episode.dart';
import '../enums.dart';

class Season {
  final String name;
  final PathString path;
  final List<Episode> episodes;

  Season({
    required this.name,
    required this.path,
    required this.episodes,
    Metadata? metadata,
  }) : _metadata = metadata;

  @override
  String toString() {
    return '''
      Season(
        name: $name, path: $path,
        episodes: $episodes
      )
    ''';
  }

  int get watchedCount => episodes.where((e) => e.watched).length;
  int get totalCount => episodes.length;
  double get watchedPercentage => totalCount > 0 ? watchedCount / totalCount : 0.0;

  Metadata? _metadata;

  Metadata? get metadata => _metadata ?? _getMetadata();

  Metadata? _getMetadata() {
    if (_metadata != null) return _metadata;

    // Get total duration
    int totSize = 0;
    Duration totDuration = Duration.zero;
    DateTime? creationDate; // earliest creation date among all episodes
    DateTime? lastModifiedDate; // latest modification date among all episodes
    DateTime? lastAccessedDate; // latest access date among all episodes

    // Populate variables
    for (final episode in episodes) {
      final metadata = episode.metadata;
      if (metadata != null) {
        totSize += metadata.size;
        totDuration += metadata.duration;
        creationDate ??= _minDate(creationDate, metadata.creationTime);
        lastModifiedDate ??= _maxDate(lastModifiedDate, metadata.lastModified);
        lastAccessedDate ??= _maxDate(lastAccessedDate, metadata.lastAccessed);
      }
    }

    _metadata = Metadata(
      size: totSize,
      duration: totDuration,
      creationTime: creationDate,
      lastModified: lastModifiedDate,
      lastAccessed: lastAccessedDate,
    );

    return _metadata;
  }

  // For JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path.path, // not nullable
      'episodes': episodes.map((e) => e.toJson()).toList(),
      'metadata': _metadata?.toJson(),
    };
  }

  // For JSON deserialization
  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      name: json['name'],
      path: PathString.fromJson(json['path'])!,
      episodes: (json['episodes'] as List).map((e) => Episode.fromJson(e)).toList(),
      metadata: json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null,
    );
  }
}

class Series {
  /// Name of the series from the File System
  final String name;

  /// Path for the series from the File System
  final PathString path;

  /// Poster path for the series from the File System
  PathString? folderPosterPath;

  /// Poster path for the series from the File System
  PathString? folderBannerPath;

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

  /// Whether the series is hidden from the library (only when not linked to Anilist)
  bool isHidden = false;

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
    this.isHidden = false,
    Metadata? metadata,
  })  : _anilistData = anilistData,
        _dominantColor = dominantColor,
        _anilistPosterUrl = anilistPoster,
        _anilistBannerUrl = anilistBanner,
        _primaryAnilistId = primaryAnilistId ?? anilistMappings.firstOrNull?.anilistId,
        _metadata = metadata;

  Series copyWith({
    String? name,
    PathString? path,
    PathString? folderPosterPath,
    PathString? folderBannerPath,
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
    bool? isHidden,
    Metadata? metadata,
  }) {
    return Series(
      name: name ?? this.name,
      path: path ?? this.path,
      folderPosterPath: folderPosterPath ?? this.folderPosterPath,
      folderBannerPath: folderBannerPath ?? this.folderBannerPath,
      seasons: seasons ?? this.seasons,
      relatedMedia: relatedMedia ?? this.relatedMedia,
      anilistMappings: anilistMappings ?? this.anilistMappings,
      anilistData: anilistData ?? _anilistData,
      dominantColor: dominantColor ?? _dominantColor,
      preferredPosterSource: preferredPosterSource ?? this.preferredPosterSource,
      preferredBannerSource: preferredBannerSource ?? this.preferredBannerSource,
      primaryAnilistId: primaryAnilistId ?? _primaryAnilistId,
      anilistPoster: anilistPoster ?? _anilistPosterUrl,
      anilistBanner: anilistBanner ?? _anilistBannerUrl,
      isHidden: isHidden ?? this.isHidden,
      metadata: metadata ?? _metadata,
    );
  }

  /// JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path.path, //not nullable
      'posterPath': folderPosterPath?.pathMaybe, // nullable
      'bannerPath': folderBannerPath?.pathMaybe, // nullable
      'seasons': seasons.map((s) => s.toJson()).toList(),
      'relatedMedia': relatedMedia.map((e) => e.toJson()).toList(),
      'anilistMappings': anilistMappings.map((m) => m.toJson()).toList(),
      'dominantColor': _dominantColor?.value, // nullable
      'dataVersion': _dataVersion,
      'primaryAnilistId': _primaryAnilistId,
      'anilistPosterUrl': _anilistPosterUrl ?? _anilistData?.posterImage, // nullable
      'anilistBannerUrl': _anilistBannerUrl ?? _anilistData?.bannerImage, // nullable
      'preferredPosterSource': preferredPosterSource?.name_, // nullable
      'preferredBannerSource': preferredBannerSource?.name_, // nullable
      'isHidden': isHidden,
      'metadata': _metadata?.toJson(), // nullable
    };
  }

  /// JSON deserialization
  factory Series.fromJson(Map<String, dynamic> json) {
    Color? extractDominantColor(Map<String, dynamic> json) {
      if (json.containsKey('dominantColor') && json['dominantColor'] != null) {
        try {
          // log('Parsing dominant color from JSON: ${json['dominantColor']}: ${Color(json['dominantColor'] as int).toHex()}');
          return Color(json['dominantColor'] as int);
        } catch (e, st) {
          logErr('Error parsing dominant color', e, st);
        }
      }
      return null;
    }

    List<AnilistMapping> extractAnilistMapping(Map<String, dynamic> json, PathString path) {
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
                } catch (e, st) {
                  logErr('Error parsing individual Anilist mapping', e, st);
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
      } catch (e, st) {
        logErr('Error processing Anilist mappings', e, st);
      }
      return mappings;
    }

    List<Season> extractSeasons(Map<String, dynamic> json, PathString path) {
      List<Season> seasons = [];
      try {
        if (json.containsKey('seasons') && json['seasons'] != null) {
          final seasonsJson = json['seasons'] as List?;
          if (seasonsJson != null) {
            for (final season in seasonsJson) {
              if (season is Map<String, dynamic>) {
                try {
                  seasons.add(Season.fromJson(season));
                } catch (e, st) {
                  logErr('Error parsing season', e, st);
                }
              }
            }
          }
        }
      } catch (e, st) {
        logErr('Error processing seasons', e, st);
        // Create empty season if none parsed successfully (required field)
        if (seasons.isEmpty) //
          seasons = [Season(name: 'Season 1', path: path, episodes: [])];
      }
      return seasons;
    }

    List<Episode> extractRelatedMedia(Map<String, dynamic> json, PathString path) {
      List<Episode> relatedMedia = [];
      try {
        if (json.containsKey('relatedMedia') && json['relatedMedia'] != null) {
          final mediaJson = json['relatedMedia'] as List?;
          if (mediaJson != null) {
            for (final episode in mediaJson) {
              if (episode is Map<String, dynamic>) {
                try {
                  relatedMedia.add(Episode.fromJson(episode));
                } catch (e, st) {
                  logErr('Error parsing related media episode', e, st);
                }
              }
            }
          }
        }
      } catch (e, st) {
        logErr('Error processing related media', e, st);
      }
      return relatedMedia;
    }

    try {
      // Validate required fields
      final name = json['name'] as String? ?? '';
      final path = PathString(json['path'] as String? ?? '');

      if (name.isEmpty || path.path.isEmpty) //
        logWarn('Series JSON missing required name or path: $json');

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
        folderPosterPath: PathString.fromJson(json['posterPath']),
        folderBannerPath: PathString.fromJson(json['bannerPath']),
        seasons: seasons,
        relatedMedia: relatedMedia,
        anilistMappings: mappings,
        dominantColor: dominantColor,
        anilistPoster: json['anilistPosterUrl'] as String?,
        anilistBanner: json['anilistBannerUrl'] as String?,
        metadata: json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null,
        // anilistData is not serialized directly, but retrieved on demand
        // preferredPosterSource and preferredBannerSource
        // are null by default to be set by the settings
      );
      series.isHidden = (json['isHidden'] as bool? ?? false) == true;

      // Set primary Anilist ID if available
      try {
        if (json.containsKey('primaryAnilistId') && json['primaryAnilistId'] != null) {
          series._primaryAnilistId = json['primaryAnilistId'] as int?;
          // Validate that the primary ID exists in mappings
          if (series._primaryAnilistId != null && !mappings.any((m) => m.anilistId == series._primaryAnilistId)) {
            logWarn('primaryAnilistId ${series._primaryAnilistId} not found in mappings');
          }
        }
      } catch (e, st) {
        logErr('Error setting primaryAnilistId', e, st);
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
      } catch (e, st) {
        logErr('Error setting preferredPosterSource', e, st);
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
      } catch (e, st) {
        logErr('Error setting preferredBannerSource', e, st);
      }

      return series;
    } catch (e, st) {
      // If anything fails critically, create a minimal valid series
      logErr('Critical error parsing Series.fromJson', e, st);
      return Series(
        name: json['name'] as String? ?? 'Unknown Series',
        path: PathString.fromJson(json['path'])!,
        seasons: [],
      );
    }
  }

  factory Series.fromValues({
    required String name,
    required PathString path,
    PathString? folderPosterPath,
    PathString? folderBannerPath,
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
    bool isHidden = false,
    Metadata? metadata,
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
      isHidden: isHidden,
      metadata: metadata,
    );

    return series;
  }

  @override
  String toString() {
    return '''\nSeries(
  Name:                       $name,
  Path:                         '$path',
  Last List Update:      ${DateTime.fromMillisecondsSinceEpoch((latestUpdatedAt ?? 0) * 1000).pretty()},
  Added to List:           ${DateTime.fromMillisecondsSinceEpoch((earliestCreatedAt ?? 0) * 1000).pretty()},
  Started Watching:     ${earliestStartedAt.pretty()},
  Finished Watching:   ${latestCompletionDate.pretty()},
  Release Date:            ${earliestReleaseDate.pretty()},
  End Date:                  ${latestEndDate.pretty()},
  Highest User Score:   $highestUserScore,
  Highest Popularity:    $highestPopularity,
  Dominant Color:        ${dominantColor?.toHex()},
  Hidden:                   $isHidden,
)''';
  }

  String toStringMini() => '''Series(${name.substring(0, min(30, name.length))}...)''';

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
  int? get anilistId => isLinked ? anilistMappings.firstOrNull?.anilistId : null;

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
  AnilistMapping? getMappingForPath(PathString path) {
    // Exact match
    for (var mapping in anilistMappings) {
      if (mapping.localPath == path) {
        return mapping;
      }
    }

    // Parent folder match (for nested files)
    for (var mapping in anilistMappings) {
      if (path.path.startsWith(mapping.localPath.path)) {
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
      logTrace('   No need to extract color, using cached dominant color for ${substringSafe(name, 0, 20, '"')}: ${_dominantColor!.toHex()}!');
      return _dominantColor;
    }

    // Skip if binding not initialized or no poster path
    if (!WidgetsBinding.instance.isRootWidgetAttached) {
      logDebug('   WidgetsBinding not initialized, initializing...');
      WidgetsFlutterBinding.ensureInitialized();
    }

    logTrace('  Calculating dominant color for $name...');
    // Get source type
    final DominantColorSource sourceType = Manager.dominantColorSource;
    String? imagePath;

    // Use the existing logic from effectivePosterPath/effectiveBannerPath
    if (sourceType == DominantColorSource.poster) {
      // For poster source, use the effectivePosterPath
      imagePath = effectivePosterPath;
      if (imagePath != null) {
        logTrace(isAnilistPoster ? '   Using Anilist poster for dominant color calculation' : '   Using local poster for dominant color calculation: "$imagePath"');
      }
    } else {
      // For banner source, use the effectiveBannerPath
      imagePath = effectiveBannerPath;
      if (imagePath != null) {
        logTrace(isAnilistBanner ? '   Using Anilist banner for dominant color calculation' : '   Using local banner for dominant color calculation: "$imagePath"');
      }
    }

    // If no image path found, return null
    if (imagePath == null) {
      logTrace('   No image available for dominant color extraction');
      return null;
    }

    // For Anilist images, we need to get the cached path
    if ((sourceType == DominantColorSource.poster && isAnilistPoster) || (sourceType == DominantColorSource.banner && isAnilistBanner)) {
      imagePath = await _getAnilistCachedImagePath();
      if (imagePath == null) {
        logTrace('   Failed to get cached Anilist image');
        return null;
      }
    }

    return await extractColorFromPath(imagePath) ?? _dominantColor;
  }

  Future<Color?> extractColorFromPath(String imagePath) async {
    // Calculate color using compute to avoid UI blocking
    try {
      // Use compute to process on a background thread
      final imageFile = File(imagePath);
      if (await imageFile.exists()) {
        final Uint8List imageBytes = await imageFile.readAsBytes();
        final Image image = (await decodeImageFromList(imageBytes));
        final ByteData byteData = (await image.toByteData())!;

        // Force UI update by using a separate isolate
        final Color? newColor = await compute(_isolateExtractColor, (byteData, image.width, image.height));
        logMulti([
          ['   Dominant color calculated: '],
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
    return null;
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

  Map<int, AnilistMediaListEntry?>? _mediaListEntries;

  // Cached info for quick access
  (AnilistMediaListEntry?, int?, int?, DateTime?, DateTime?, int?, DateTime?, DateTime?, int?)? _cachedSeriesInfo;

  Map<int, AnilistMediaListEntry?> get mediaListEntries => _mediaListEntries ?? getMediaListEntries(Provider.of<AnilistProvider>(Manager.context, listen: false));

  Map<int, AnilistMediaListEntry?> getMediaListEntries(AnilistProvider anilistProvider) {
    if (!isLinked) return {};

    // initialize if null
    _mediaListEntries = {};

    for (final mapping in anilistMappings) {
      bool found = false;
      for (final list in anilistProvider.userLists.values) {
        for (final listEntry in list.entries) {
          if (listEntry.mediaId == mapping.anilistId) {
            // If the mapping is found in the list, add it to the map
            _mediaListEntries![mapping.anilistId] = listEntry;
            found = true;
            break;
          }
        }
        if (found) break;
      }

      // If not found in any list, add null
      if (!found) _mediaListEntries![mapping.anilistId] = null;
    }

    // Clear the cached info so it will be recalculated next time
    _cachedSeriesInfo = null;

    return _mediaListEntries!;
  }

  // Get the best entry values from all user's list entries for this series
  (AnilistMediaListEntry?, int?, int?, DateTime?, DateTime?, int?, DateTime?, DateTime?, int?)? getSeriesInfoFromMediaListEntry(AnilistProvider anilistProvider) {
    if (!isLinked) return null;

    // Use cached info if available
    if (_cachedSeriesInfo != null) return _cachedSeriesInfo;

    // Make sure media list entries are populated
    final entries = getMediaListEntries(anilistProvider);
    if (entries.isEmpty) return null;

    // Values to collect from all mappings
    AnilistMediaListEntry? bestEntry;

    int? latestUpdatedAt; //            updatedAt    - list updated timestamp
    int? earliestCreatedAt; //          createdAt    - added to list timestamp
    DateTime? earliestStartedAt; //     startedAt    - user started entry timestamp
    DateTime? latestCompletionDate; //  completedAt  - user completion date
    int? highestUserScore; //           averageScore - user score
    DateTime? earliestReleaseDate; //   startDate    - official release date
    DateTime? latestEndDate; //         endDate      - official end date
    int? highestPopularity; //          popularity   - popularity

    // Process each mapping's media list entry
    for (final anilistId in entries.keys) {
      final entry = entries[anilistId];

      if (entry != null) {
        // List updated timestamp - take the most recent
        if (entry.updatedAt != null && (latestUpdatedAt == null || entry.updatedAt! > latestUpdatedAt)) {
          latestUpdatedAt = entry.updatedAt;
        }

        // Added to list timestamp - take the earliest
        if (entry.createdAt != null && (earliestCreatedAt == null || entry.createdAt! < earliestCreatedAt)) {
          earliestCreatedAt = entry.createdAt;
        }

        // User started entry timestamp - take the earliest
        final startedDate = entry.startedAt?.toDateTime();
        if (startedDate != null && (earliestStartedAt == null || startedDate.isBefore(earliestStartedAt))) {
          earliestStartedAt = startedDate;
        }

        // User completion date - take the latest
        final completedDate = entry.completedAt?.toDateTime();
        if (completedDate != null && (latestCompletionDate == null || completedDate.isAfter(latestCompletionDate))) {
          latestCompletionDate = completedDate;
          // Track the entry with the latest completion date as the "best" entry
          bestEntry = entry;
        }

        // User score - take the highest
        if (entry.score != null && (highestUserScore == null || entry.score! > highestUserScore)) {
          highestUserScore = entry.score;
        }
      }

      // Get release date from the anime data for this mapping
      final mapping = anilistMappings.firstWhereOrNull((m) => m.anilistId == anilistId);
      final animeData = mapping?.anilistData;
      if (animeData != null) {
        // Release date - take the earliest
        final releaseDate = animeData.startDate?.toDateTime();
        if (releaseDate != null && (earliestReleaseDate == null || releaseDate.isBefore(earliestReleaseDate))) {
          earliestReleaseDate = releaseDate;
        }

        final endDate = animeData.endDate?.toDateTime();
        if (endDate != null && (latestEndDate == null || endDate.isAfter(latestEndDate))) {
          latestEndDate = endDate;
        }

        // Popularity - take the highest
        if (animeData.popularity != null && (highestPopularity == null || animeData.popularity! > highestPopularity)) {
          highestPopularity = animeData.popularity;
        }
      }
    }

    // Cache the results
    _cachedSeriesInfo = (
      bestEntry, //$1
      latestUpdatedAt, //$2
      earliestCreatedAt, //$3
      earliestStartedAt, //$4
      latestCompletionDate, //$5
      highestUserScore, //$6
      earliestReleaseDate, //$7
      latestEndDate, //$8
      highestPopularity, //$9
    );

    return _cachedSeriesInfo;
  }

  /// When the user last updated this series in their list
  int? get latestUpdatedAt {
    final anilistProvider = Provider.of<AnilistProvider>(Manager.context, listen: false);
    return getSeriesInfoFromMediaListEntry(anilistProvider)?.$2;
  }

  /// When the user added this series to their list
  int? get earliestCreatedAt {
    final anilistProvider = Provider.of<AnilistProvider>(Manager.context, listen: false);
    return getSeriesInfoFromMediaListEntry(anilistProvider)?.$3;
  }

  /// When the user started watching this series
  DateTime? get earliestStartedAt {
    final anilistProvider = Provider.of<AnilistProvider>(Manager.context, listen: false);
    return getSeriesInfoFromMediaListEntry(anilistProvider)?.$4;
  }

  /// When the user completed watching this series
  DateTime? get latestCompletionDate {
    final anilistProvider = Provider.of<AnilistProvider>(Manager.context, listen: false);
    return getSeriesInfoFromMediaListEntry(anilistProvider)?.$5;
  }

  /// The highest user score for this series
  int? get highestUserScore {
    final anilistProvider = Provider.of<AnilistProvider>(Manager.context, listen: false);
    return getSeriesInfoFromMediaListEntry(anilistProvider)?.$6;
  }

  /// The earliest release date for this series
  DateTime? get earliestReleaseDate {
    final anilistProvider = Provider.of<AnilistProvider>(Manager.context, listen: false);
    return getSeriesInfoFromMediaListEntry(anilistProvider)?.$7;
  }

  /// The latest end date for this series
  DateTime? get latestEndDate {
    final anilistProvider = Provider.of<AnilistProvider>(Manager.context, listen: false);
    return getSeriesInfoFromMediaListEntry(anilistProvider)?.$8;
  }

  /// The highest popularity for this series
  int? get highestPopularity {
    final anilistProvider = Provider.of<AnilistProvider>(Manager.context, listen: false);
    return getSeriesInfoFromMediaListEntry(anilistProvider)?.$9;
  }

  // Helper method to get specific media list entry for a given path
  AnilistMediaListEntry? _getMediaListEntry(AnilistProvider anilistProvider) {
    if (!isLinked) return null;

    // Make sure entries are populated
    final entries = getMediaListEntries(anilistProvider);

    // Use the primary mapping's entry if available
    if (primaryAnilistId != null && entries.containsKey(primaryAnilistId)) {
      return entries[primaryAnilistId];
    }

    // Otherwise return the first non-null entry
    for (final entry in entries.values) {
      if (entry != null) return entry;
    }

    return null;
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
  String get displayTitle {
    // Helper: Remove season indicators in various languages/scripts
    String removeSeasonIndicators(String input) {
      // Patterns for season indicators in English, Japanese, Romaji, etc.
      final patterns = [
        RegExp(r'(?:Season|S|Seasons?|Part|Cour|Vol(?:ume)?|Chapter|Ch)\s*\d+', caseSensitive: false),
        RegExp(r'(?:第\s*\d+\s*(?:期|シーズン|部|章|クール|巻))'), // Japanese: 第1期, 第2部, etc.
        RegExp(r'(?:シーズン|クール|パート|章|巻)\s*\d+'), // Japanese: シーズン2, クール1, etc.
        RegExp(r'(?:kikaku|ki|bu|shou|kuru|kan)\s*\d+', caseSensitive: false), // Romaji
        RegExp(r'(?:\d+\s*(?:期|シーズン|部|章|クール|巻))'), // Japanese: 2期, 3部, etc.
        RegExp(r'[\(\[]\s*(?:Season|S|Seasons?|Part|Cour|Vol(?:ume)?|Chapter|Ch|第\d+期|シーズン\d+|クール\d+|パート\d+|章\d+|巻\d+)\s*[\)\]]', caseSensitive: false),
      ];

      String result = input;
      for (final pattern in patterns) {
        result = result.replaceAll(pattern, '');
      }
      // Remove extra whitespace and trailing punctuation
      result = result.replaceAll(RegExp(r'\s+'), ' ').trim();
      result = result.replaceAll(RegExp(r'[\-–—:：,;]+$'), '').trim();
      return result;
    }

    final title = (currentAnilistData?.title.userPreferred ??
        currentAnilistData?.title.english ??
        currentAnilistData?.title.romaji ??
        name);

    return removeSeasonIndicators(title);
  }

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

  /// The season year from Anilist
  int? get seasonYear => currentAnilistData?.seasonYear;

  /// Checks if any Anilist mapping has the "hide from status lists" flag set
  bool get shouldBeHidden {
    if (isLinked && anilistMappings.isNotEmpty) {
      return mediaListEntries.values.any((entry) => entry?.hiddenFromStatusLists == true);
    }

    return isHidden; // if not linked, use the local isHidden flag
  }

  /// Getter to check if the poster is from Anilist
  String? get effectivePosterPath {
    final ImageSource effectiveSource = preferredPosterSource ?? Manager.defaultPosterSource;

    // Determine available options
    final bool hasLocalPoster = folderPosterPath != null;
    final bool hasAnilistPoster = anilistPosterUrl != null;

    // Apply fallback logic based on source preference
    switch (effectiveSource) {
      case ImageSource.autoLocal:
      case ImageSource.local:
        return hasLocalPoster ? folderPosterPath?.pathMaybe : (hasAnilistPoster ? anilistPosterUrl : null);

      case ImageSource.autoAnilist:
      case ImageSource.anilist:
        return hasAnilistPoster ? anilistPosterUrl : (hasLocalPoster ? folderPosterPath?.pathMaybe : null);
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
    return effectivePosterPath == folderPosterPath?.pathMaybe;
  }

  /// Get the effective poster image as an ImageProvider
  Future<ImageProvider?> getPosterImage() async {
    final path = effectivePosterPath;
    if (path == null) return null;

    if (isLocalPoster) {
      return FileImage(File(path));
    } else if (isAnilistPoster) {
      return await ImageCacheService().getImageProvider(path);
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
      case ImageSource.autoLocal:
      case ImageSource.local:
        return hasLocalBanner ? folderBannerPath?.pathMaybe : (hasAnilistBanner ? anilistBannerUrl : null);

      case ImageSource.autoAnilist:
      case ImageSource.anilist:
        return hasAnilistBanner ? anilistBannerUrl : (hasLocalBanner ? folderBannerPath?.pathMaybe : null);
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
    return effectiveBannerPath == folderBannerPath?.pathMaybe;
  }

  /// Get the effective banner image as an ImageProvider
  Future<ImageProvider?> getBannerImage() async {
    final path = effectiveBannerPath;
    if (path == null) return null;

    if (isLocalBanner) {
      return FileImage(File(path));
    } else if (isAnilistBanner) {
      return await ImageCacheService().getImageProvider(path);
    }
    return null;
  }

  Metadata? _metadata;

  Metadata? get metadata => _metadata ?? _getMetadata();

  set metadata(Metadata? metadata) {
    if (metadata == null) logWarn('Setting metadata for series $name to null');
    _metadata = metadata;
    _dataVersion++;
  }

  void setMetadataFromValues({
    int? size,
    Duration? duration,
    DateTime? creationTime,
    DateTime? lastModified,
    DateTime? lastAccessed,
  }) {
    _metadata = _metadata?.copyWith(
          size: size,
          duration: duration,
          creationTime: creationTime,
          lastModified: lastModified,
          lastAccessed: lastAccessed,
        ) ??
        Metadata(
          size: size,
          duration: duration,
          creationTime: creationTime,
          lastModified: lastModified,
          lastAccessed: lastAccessed,
        );
    _dataVersion++;
  }

  Metadata? _getMetadata() {
    if (_metadata != null) return _metadata;

    // Get total duration
    int totSize = 0;
    Duration totDuration = Duration.zero;
    DateTime? creationDate; // earliest creation date among all seasons
    DateTime? lastModifiedDate; // latest modification date among all seasons
    DateTime? lastAccessedDate; // latest access date among all seasons

    // Populate the variables
    for (final season in seasons) {
      totSize += season.metadata?.size ?? 0;
      totDuration += season.metadata?.duration ?? Duration.zero;

      creationDate = _minDate(creationDate, season.metadata?.creationTime);
      lastModifiedDate = _maxDate(lastModifiedDate, season.metadata?.lastModified);
      lastAccessedDate = _maxDate(lastAccessedDate, season.metadata?.lastAccessed);
    }

    _metadata = Metadata(
      size: totSize,
      duration: totDuration,
      creationTime: creationDate,
      lastModified: lastModifiedDate,
      lastAccessed: lastAccessedDate,
    );

    return _metadata;
  }
}

DateTime? _minDate(DateTime? date1, DateTime? date2) {
  if (date1 == null) return date2;
  if (date2 == null) return date1;
  return date1.isBefore(date2) ? date1 : date2;
}

DateTime? _maxDate(DateTime? date1, DateTime? date2) {
  if (date1 == null) return date2;
  if (date2 == null) return date1;
  return date1.isAfter(date2) ? date1 : date2;
}
