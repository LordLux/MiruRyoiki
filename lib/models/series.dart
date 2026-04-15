// ignore_for_file: library_prefixes, unnecessary_this

import 'package:flutter/widgets.dart' hide Image;
import 'package:miruryoiki/models/metadata.dart';
import 'package:collection/collection.dart';
import 'package:recase/recase.dart';

import '../services/anilist/queries/anilist_service.dart';
import '../utils/logging.dart';
import '../utils/path.dart';
import '../utils/text.dart';
import 'anilist/anime.dart';
import 'anilist/mapping.dart';
import 'episode.dart';
import '../enums.dart';
import 'season.dart';
import 'series_presenter.dart';
import 'mapping_target.dart';

class Series {
  /// Database ID
  final int? id;

  /// Name of the series from the File System
  final String name;

  /// Path for the series from the File System
  final PathString path;

  /// List of episode collections (seasons and folders) for the series from the File System
  final List<EpisodeCollection> collections;

  /// Anilist IDs for the series
  List<AnilistMapping> anilistMappings;

  /// The currently selected Anilist ID for display purposes
  int? _primaryAnilistId;

  /// Handles all image resolution, color computation, and display logic
  late final SeriesPresenter presenter;

  /// Whether the series is hidden from the library (only when not linked to Anilist)
  bool isForcedHidden;

  /// Custom list name for unlinked series (null -> default to 'Unlinked')
  /// ignored if linked
  String? customListName;

  /// User's custom ordering of episode grids.
  /// If null, use default order (seasons 1->N, then uncategorized).
  /// Each string is a grid identifier like 'season_1', 'special_uncategorized', etc.
  List<String>? customGridOrder;

  /// Get the effective list name for this unlinked series, with validation and fallback
  String getEffectiveListName(List<String> availableListNames) {
    // For linked series, this method shouldn't be used as AniList API is source of truth
    if (isLinked) return AnilistService.statusListNameUnlinked; // fallback, but this shouldn't be called for linked series

    // If no custom list name is set, use default
    if (customListName == null || customListName!.isEmpty) return AnilistService.statusListNameUnlinked;

    // Check if the list name or custom list name exists in available lists
    final customApiName = customListName!.startsWith(AnilistService.statusListPrefixCustom) ? customListName! : '${AnilistService.statusListPrefixCustom}$customListName';
    if (availableListNames.contains(customApiName) || availableListNames.contains(customListName!)) //
      return customListName!;

    // Fallback to default if custom list doesn't exist
    return AnilistService.statusListNameUnlinked;
  }

  /// Metadata for the series
  Metadata? _metadata;

  /// Constructor for Series
  Series({
    this.id,
    required this.name,
    required this.path,
    PathString? localPosterPath,
    PathString? localBannerPath,
    required this.collections,
    this.anilistMappings = const [],
    AnilistAnime? anilistData,
    Color? posterColor,
    Color? bannerColor,
    ImageSource? preferredPosterSource,
    ImageSource? preferredBannerSource,
    String? anilistPoster,
    String? anilistBanner,
    int? primaryAnilistId,
    bool isHidden = false,
    this.customListName,
    this.customGridOrder,
    Metadata? metadata,
  })  : isForcedHidden = isHidden,
        _primaryAnilistId = primaryAnilistId ?? anilistMappings.firstOrNull?.anilistId,
        _metadata = metadata {
    presenter = SeriesPresenter(
      this,
      posterColor: posterColor,
      bannerColor: bannerColor,
      preferredPosterSource: preferredPosterSource,
      preferredBannerSource: preferredBannerSource,
      anilistPosterUrl: anilistPoster,
      anilistBannerUrl: anilistBanner,
      localPosterPath: localPosterPath,
      localBannerPath: localBannerPath,
    );
  }

  /// Create a copy of the series with modified fields
  Series copyWith({
    int? id,
    String? name,
    PathString? path,
    PathString? folderPosterPath,
    PathString? folderBannerPath,
    List<EpisodeCollection>? collections,
    List<AnilistMapping>? anilistMappings,
    AnilistAnime? anilistData,
    Color? posterColor,
    Color? bannerColor,
    ImageSource? preferredPosterSource,
    ImageSource? preferredBannerSource,
    int? primaryAnilistId,
    String? anilistPoster,
    String? anilistBanner,
    bool? isHidden,
    String? customListName,
    List<String>? customGridOrder,
    Metadata? metadata,
  }) {
    return Series(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      localPosterPath: folderPosterPath ?? presenter.localPosterPath,
      localBannerPath: folderBannerPath ?? presenter.localBannerPath,
      collections: collections ?? this.collections,
      anilistMappings: anilistMappings ?? this.anilistMappings,
      anilistData: anilistData ?? anilistData,
      posterColor: posterColor ?? presenter.rawPosterColor,
      bannerColor: bannerColor ?? presenter.rawBannerColor,
      preferredPosterSource: preferredPosterSource ?? presenter.preferredPosterSource,
      preferredBannerSource: preferredBannerSource ?? presenter.preferredBannerSource,
      primaryAnilistId: primaryAnilistId ?? _primaryAnilistId,
      anilistPoster: anilistPoster ?? presenter.rawAnilistPosterUrl,
      anilistBanner: anilistBanner ?? presenter.rawAnilistBannerUrl,
      isHidden: isHidden ?? this.isForcedHidden,
      customListName: customListName ?? this.customListName,
      customGridOrder: customGridOrder ?? this.customGridOrder,
      metadata: metadata ?? _metadata,
    );
  }

  /// JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path.path, //not nullable
      'collections': collections.map((c) => c.toJson()).toList(),
      'anilistMappings': anilistMappings.map((m) => m.toJson()).toList(),
      'primaryAnilistId': _primaryAnilistId,
      'isHidden': isForcedHidden,
      'customListName': customListName, // nullable
      'customGridOrder': customGridOrder, // nullable
      'metadata': _metadata?.toJson(), // nullable
      ...presenter.toJson(),
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
      } catch (e, st) {
        logErr('Error processing Anilist mappings', e, st);
      }
      return mappings;
    }

    List<EpisodeCollection> extractCollections(Map<String, dynamic> json, PathString path) {
      List<EpisodeCollection> collections = [];
      try {
        // Handle newer format with 'collections' key
        if (json.containsKey('collections') && json['collections'] != null) {
          final collectionsJson = json['collections'] as List?;
          if (collectionsJson != null) {
            for (final item in collectionsJson) {
              if (item is Map<String, dynamic>) {
                try {
                  collections.add(EpisodeCollection.fromJson(item));
                } catch (e, st) {
                  logErr('Error parsing collection', e, st);
                }
              }
            }
          }
        }
        // Handle legacy format with 'seasons' key
        else if (json.containsKey('seasons') && json['seasons'] != null) {
          final seasonsJson = json['seasons'] as List?;
          if (seasonsJson != null) {
            for (final item in seasonsJson) {
              if (item is Map<String, dynamic>) {
                try {
                  collections.add(EpisodeCollection.fromJson(item));
                } catch (e, st) {
                  logErr('Error parsing season', e, st);
                }
              }
            }
          }
        }
        // Handle legacy 'relatedMedia' by converting to Folder collections
        if (json.containsKey('relatedMedia') && json['relatedMedia'] != null) {
          final mediaJson = json['relatedMedia'] as List?;
          if (mediaJson != null && mediaJson.isNotEmpty) {
            final episodes = <Episode>[];
            for (final episode in mediaJson) {
              if (episode is Map<String, dynamic>) {
                try {
                  episodes.add(Episode.fromJson(episode));
                } catch (e, st) {
                  logErr('Error parsing related media episode', e, st);
                }
              }
            }
            if (episodes.isNotEmpty) {
              collections.add(Folder(
                name: Folder.uncategorizedName,
                path: path,
                episodes: episodes,
              ));
            }
          }
        }
      } catch (e, st) {
        logErr('Error processing collections', e, st);
        if (collections.isEmpty) //
          collections = [Season(name: 'Season 1', path: path, episodes: [], seasonNumber: 1)];
      }
      return collections;
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

      // Process collections (seasons + folders) with validation
      List<EpisodeCollection> collections = extractCollections(json, path);

      // Create the Series instance
      final series = Series(
        id: json['id'] as int?,
        name: name,
        path: path,
        localPosterPath: PathString.fromJson(json['posterPath']),
        localBannerPath: PathString.fromJson(json['bannerPath']),
        collections: collections,
        anilistMappings: mappings,
        posterColor: dominantColor,
        anilistPoster: json['anilistPosterUrl'] as String?,
        anilistBanner: json['anilistBannerUrl'] as String?,
        metadata: json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null,
        // anilistData is not serialized directly, but retrieved on demand
        // preferredPosterSource and preferredBannerSource
        // are null by default to be set by the settings
      );
      series.isForcedHidden = (json['isHidden'] as bool? ?? false) == true;

      // Set custom list name if available (only used for unlinked series)
      try {
        series.customListName = json['customListName'] as String?;
      } catch (e, st) {
        logErr('Error setting customListName', e, st);
      }

      // Set custom grid order if available
      try {
        if (json.containsKey('customGridOrder') && json['customGridOrder'] != null) {
          final orderJson = json['customGridOrder'];
          if (orderJson is List) series.customGridOrder = orderJson.cast<String>();
        }
      } catch (e, st) {
        logErr('Error setting customGridOrder', e, st);
      }

      // Set primary Anilist ID if available
      try {
        if (json.containsKey('primaryAnilistId') && json['primaryAnilistId'] != null) {
          series._primaryAnilistId = json['primaryAnilistId'] as int?;
          // Validate that the primary ID exists in mappings
          if (series._primaryAnilistId != null && !mappings.any((m) => m.anilistId == series._primaryAnilistId)) {
            logWarn('primaryAnilistId ${series._primaryAnilistId} not found in mappings for ${series.name}');
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
        id: json['id'] as int?,
        name: json['name'] as String? ?? 'Unknown Series',
        path: PathString.fromJson(json['path'])!,
        collections: [],
      );
    }
  }

  @override
  String toString() {
    return '''\nSeries(
  Name:                       $name,
  Path:                         '$path',
  Dominant Color:        ${localPosterColor?.toHex()},
  Hidden:                   $isForcedHidden,
)''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Series) return false;
    final listEquality = const DeepCollectionEquality().equals;
    return other.id == id &&
        other.name == name &&
        other.path == path &&
        listEquality(other.collections, collections) &&
        listEquality(other.anilistMappings, anilistMappings) &&
        other._primaryAnilistId == _primaryAnilistId &&
        other.presenter == presenter &&
        other.isForcedHidden == isForcedHidden &&
        other.customListName == customListName;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        path,
        Object.hashAll(collections),
        Object.hashAll(anilistMappings),
        _primaryAnilistId,
        presenter,
        isForcedHidden,
        customListName,
      );

  /// Getter and setter for primaryAnilistId
  int? get primaryAnilistId => _primaryAnilistId ?? (isLinked ? anilistMappings.firstOrNull?.anilistId : null); // Fall back to the first mapping
  /// Set the primary Anilist ID
  set primaryAnilistId(int? value) {
    if (value != null && anilistMappings.any((m) => m.anilistId == value)) {
      _primaryAnilistId = value;
    } else {
      logWarn('Invalid primaryAnilistId: $value');
    }
  }

  /// Anilist data for the series
  AnilistAnime? get anilistData {
    if (_primaryAnilistId == null && anilistMappings.isNotEmpty) _primaryAnilistId = anilistMappings.first.anilistId;
    return anilistMappings.firstWhereOrNull((m) => m.anilistId == (_primaryAnilistId))?.anilistData;
  }

  /// Set the primary Anilist id's data for the series
  set anilistData(AnilistAnime? value) {
    final mapping = anilistMappings.firstWhereOrNull((m) => m.anilistId == _primaryAnilistId);
    if (mapping != null) mapping.anilistData = value;

    presenter.updateAnilistUrls(poster: value?.posterImage, banner: value?.bannerImage);
  }

  // ==================== Forwarding to SeriesPresenter ====================

  // Data field accessors
  PathString? get localPosterPath => presenter.localPosterPath;
  set localPosterPath(PathString? value) => presenter.localPosterPath = value;

  PathString? get localBannerPath => presenter.localBannerPath;
  set localBannerPath(PathString? value) => presenter.localBannerPath = value;

  ImageSource? get preferredPosterSource => presenter.preferredPosterSource;
  set preferredPosterSource(ImageSource? value) => presenter.preferredPosterSource = value;

  ImageSource? get preferredBannerSource => presenter.preferredBannerSource;
  set preferredBannerSource(ImageSource? value) => presenter.preferredBannerSource = value;

  // Color
  Color? get localPosterColor => presenter.localPosterColor;
  Color? get localBannerColor => presenter.localBannerColor;
  Future<void> calculateLocalPosterDominantColor({bool forceRecalculate = false}) => presenter.calculateLocalPosterDominantColor(forceRecalculate: forceRecalculate);
  Future<void> calculateLocalBannerDominantColor({bool forceRecalculate = false}) => presenter.calculateLocalBannerDominantColor(forceRecalculate: forceRecalculate);
  Future<void> calculateLocalDominantColors({bool forceRecalculate = false}) => presenter.calculateLocalDominantColors(forceRecalculate: forceRecalculate);
  Future<void> clearCachedDominantColors() => presenter.clearCachedDominantColors();

  // Image URLs
  String? get anilistPosterUrl => presenter.anilistPosterUrl;
  String? get anilistBannerUrl => presenter.anilistBannerUrl;

  // Convenience getters

  /// Get only the Season collections
  List<Season> get seasons => collections.whereType<Season>().toList();

  /// Get only the Folder collections
  List<Folder> get folders => collections.whereType<Folder>().toList();

  // Getters for episodes

  /// Get episode by database ID (searches all collections)
  Episode? getEpisodeById(int episodeId) {
    for (final collection in collections) {
      final episode = collection.getEpisodeById(episodeId);
      if (episode != null) return episode;
    }
    return null;
  }

  /// Get episode by number (searches all collections)
  Episode? getEpisodeByNumber(int episodeNumber, {int? seasonNumber}) {
    if (seasonNumber != null) {
      final season = seasons.firstWhereOrNull((s) => s.seasonNumber == seasonNumber);
      return season?.getEpisodeByNumber(episodeNumber);
    }

    for (final collection in collections) {
      final episode = collection.getEpisodeByNumber(episodeNumber);
      if (episode != null) return episode;
    }
    return null;
  }

  Episode? getEpisodeByPath(PathString episodePath) {
    for (final collection in collections) {
      final episode = collection.getEpisodeByPath(episodePath);
      if (episode != null) return episode;
    }
    return null;
  }

  List<Episode> getEpisodesForSeason([int i = 1]) {
    final season = seasons.firstWhereOrNull((s) => s.seasonNumber == i);
    return season?.episodes ?? <Episode>[];
  }

  EpisodeCollection? getCollectionFromPath(PathString collectionPath) => //
      collections.firstWhereOrNull((c) => c.path == collectionPath);

  /// Get uncategorized episodes (from the synthetic Folder, if any)
  List<Episode> getUncategorizedEpisodes() {
    final uncategorized = collections.whereType<Folder>().where((f) => f.isUncategorized);
    return uncategorized.expand((f) => f.episodes).toList();
  }

  // Grid Ordering Methods

  /// Generate a grid identifier for a season number
  /// Format: 'season_N' for regular seasons, 'special_uncategorized' for uncategorized
  static String getGridIdentifier(int seasonNumber) {
    if (seasonNumber == 0) return 'special_uncategorized';
    return 'season_$seasonNumber';
  }

  /// Parse a season number from a grid identifier
  /// Returns null if not a valid season identifier
  static int? parseGridSeasonNumber(String gridId) {
    if (gridId == 'special_uncategorized') return 0;
    if (gridId.startsWith('season_')) return int.tryParse(gridId.substring(7));

    return null;
  }

  /// Get the display order of grids, either custom or default
  /// Returns a list of grid identifiers in display order
  List<String> getGridDisplayOrder() {
    // If custom order is set, validate and return it
    if (customGridOrder != null && customGridOrder!.isNotEmpty) {
      // Validate that all grids in custom order still exist
      final validatedOrder = <String>[];
      final availableGrids = _getAvailableGrids();

      for (final gridId in customGridOrder!) //
        if (availableGrids.contains(gridId)) validatedOrder.add(gridId);

      // Add any new grids that weren't in the custom order
      for (final gridId in availableGrids) //
        if (!validatedOrder.contains(gridId)) validatedOrder.add(gridId);

      return validatedOrder;
    }

    // Default order
    return _getAvailableGrids();
  }

  /// Get list of all available grids in default order
  List<String> _getAvailableGrids() {
    final grids = <String>[];

    // Add regular seasons
    for (final season in seasons) grids.add(getGridIdentifier(season.seasonNumber));

    // Add uncategorized if it has episodes
    if (getUncategorizedEpisodes().isNotEmpty) grids.add(getGridIdentifier(0));

    return grids;
  }

  /// Set custom grid display order
  /// Pass null to reset to default order
  void setGridDisplayOrder(List<String>? order) => customGridOrder = order;

  /// Check if a grid identifier is valid for this series
  bool isValidGridId(String gridId) {
    final seasonNum = parseGridSeasonNumber(gridId);
    if (seasonNum == null) return false;

    if (seasonNum == 0) return getUncategorizedEpisodes().isNotEmpty;

    return seasonNum > 0 && seasons.any((s) => s.seasonNumber == seasonNum);
  }

  /// Get the current Anilist data based on the primary Anilist ID
  AnilistAnime? get currentAnilistData {
    if (_primaryAnilistId == null) return anilistData;

    // Find mapping with the primary ID
    final mapping = anilistMappings.firstWhereOrNull((m) => m.anilistId == _primaryAnilistId);

    // If found and has data, return it
    if (mapping != null && mapping.anilistData != null) return mapping.anilistData;

    // Fall back to the first mapping's data
    return anilistData;
  }

  // ANILIST GETTERS
  /// Check if the series is linked to Anilist
  bool get isLinked => anilistMappings.isNotEmpty;

  // Display, image, and source detection forwarding
  String? get bannerImage => presenter.bannerImage;
  String? get posterImage => presenter.posterImage;
  String get displayTitle => presenter.displayTitle;

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

  /// List of all formats from all Anilist mappings
  String? get formats => anilistMappings.map((m) => parseFormat(m.anilistData?.format)).whereType<String>().toSet().join(', ');

  /// Genres from Anilist
  List<String> get genres => currentAnilistData?.genres ?? [];

  /// The season year from Anilist
  int? get seasonYear => currentAnilistData?.seasonYear;

  String? get seasonsYearRange {
    if (!isLinked) return null;
    final years = anilistMappings.map((m) => m.anilistData?.seasonYear).whereType<int>().toSet().toList()..sort();
    if (years.isEmpty) return null;
    if (years.length == 1) return years.first.toString();
    return '${years.first} - ${years.last}';
  }

  String? get seasonAndSeasonYearRange {
    if (!isLinked) return null;

    // Get all season-year combinations
    final seasonYearPairs = <(String, int)>[];
    for (final mapping in anilistMappings) {
      final season = mapping.anilistData?.season?.titleCase;
      final year = mapping.anilistData?.seasonYear;
      if (season != null && year != null) {
        seasonYearPairs.add((season, year));
      }
    }

    if (seasonYearPairs.isEmpty) return null;

    // Sort by year, then by season order (Winter, Spring, Summer, Fall)
    final seasonOrder = {'Winter': 0, 'Spring': 1, 'Summer': 2, 'Fall': 3};
    seasonYearPairs.sort((a, b) {
      final yearComparison = a.$2.compareTo(b.$2);
      if (yearComparison != 0) return yearComparison;
      return (seasonOrder[a.$1] ?? 0).compareTo(seasonOrder[b.$1] ?? 0);
    });

    if (seasonYearPairs.length == 1) {
      return '${seasonYearPairs.first.$1} ${seasonYearPairs.first.$2}';
    }

    final first = seasonYearPairs.first;
    final last = seasonYearPairs.last;
    return '${first.$1} ${first.$2} - ${last.$1} ${last.$2}';
  }

  // Image resolution forwarding
  String? get effectivePosterPath => presenter.effectivePosterPath;
  String? get effectiveBannerPath => presenter.effectiveBannerPath;
  Future<ImageProvider?> getPosterImage() => presenter.getPosterImage();
  Future<ImageProvider?> getBannerImage() => presenter.getBannerImage();
  String? getEffectivePosterPathForEpisode(Episode episode) => presenter.getEffectivePosterPathForEpisode(episode);
  Future<ImageProvider?> getPosterImageForEpisode(Episode episode) => presenter.getEffectivePosterImageForEpisode(episode);
  Color? getEffectivePosterColorForEpisode(Episode episode) => presenter.getEffectivePosterColorForEpisode(episode);
  String? getEffectivePosterPathForAnilistId(int anilistId) => presenter.getEffectivePosterPathForAnilistId(anilistId);
  Future<ImageProvider?> getPosterImageForAnilistId(int anilistId) => presenter.getEffectivePosterImageForAnilistId(anilistId);
  Color? getEffectivePosterColorForAnilistId(int anilistId) => presenter.getEffectivePosterColorForAnilistId(anilistId);
  Future<Color?> effectivePrimaryColor({int? anilistId, bool forceRecalculate = false, bool? overrideIsPoster}) => presenter.effectivePrimaryColor(anilistId: anilistId, forceRecalculate: forceRecalculate, overrideIsPoster: overrideIsPoster);
  Color? effectivePrimaryColorSync([int? anilistId]) => presenter.effectivePrimaryColorSync(anilistId);
  bool get isAnilistBannerBeingUsed => presenter.isAnilistBannerBeingUsed;
  bool get isLocalBannerBeingUsed => presenter.isLocalBannerBeingUsed;
  bool get isAnilistPosterBeingUsed => presenter.isAnilistPosterBeingUsed;
  bool get isLocalPosterBeingUsed => presenter.isLocalPosterBeingUsed;

  Metadata? get metadata => _metadata ?? _getMetadata();

  set metadata(Metadata? metadata) {
    if (metadata == null) logWarn('Setting metadata for series $name to null');
    _metadata = metadata;
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
    for (final collection in collections) {
      totSize += collection.metadata?.size ?? 0;
      totDuration += collection.metadata?.duration ?? Duration.zero;

      creationDate = DateTimeX.isBeforeMaybe(creationDate, collection.metadata?.creationTime);
      lastModifiedDate = DateTimeX.isAfterMaybe(lastModifiedDate, collection.metadata?.lastModified);
      lastAccessedDate = DateTimeX.isAfterMaybe(lastAccessedDate, collection.metadata?.lastAccessed);
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

  int get localTotalEpisodes => collections.fold(0, (sum, c) => sum + c.episodes.length);
  int get localWatchedEpisodes => collections.fold(0, (sum, c) => sum + c.watchedCount);
  double get localWatchedPercentage => localTotalEpisodes > 0 ? localWatchedEpisodes / localTotalEpisodes : 0.0;
  double get watchedPercentage => localWatchedPercentage; // Kept only for DB mapping

  int get numberOfSeasons {
    final seasonList = seasons;
    if (seasonList.isEmpty) return 0;

    // Get all season numbers
    final seasonNumbers = seasonList.map((s) => s.seasonNumber).toList();

    // Return the highest season number
    if (seasonNumbers.isNotEmpty) //
      return seasonNumbers.reduce((a, b) => a > b ? a : b);

    return seasonList.length;
  }

  /// Get the effective status of the series based on Anilist mappings
  String? get effectiveStatus {
    if (!isLinked) return null;

    final priority = [
      // TODO revisit the priority order if needed, currently based on what seems most useful for sorting and display purposes
      AnilistAnimeStatus.CANCELLED, // if any mapping is cancelled, take that
      AnilistAnimeStatus.HIATUS, // if there are no cancelled, and any mapping is on hiatus, take that
      AnilistAnimeStatus.RELEASING, // if there are no cancelled or on hiatus, and any mapping is releasing, take that
      AnilistAnimeStatus.NOT_YET_RELEASED, // if there are no releasing or cancelled or on hiatus, and any mapping is not yet released, take that
      AnilistAnimeStatus.FINISHED, // if all mappings are finished, take that
    ];

    // Get all statuses from anilist mappings
    final statuses = anilistMappings.map((mapping) => mapping.anilistData?.status?.toAnimeStatus()).whereType<AnilistAnimeStatus>().toSet();

    if (statuses.isEmpty) return null;

    // Return the highest priority status found
    for (final priorityStatus in priority) {
      if (statuses.contains(priorityStatus)) return priorityStatus.name_;
    }

    return null;
  }

  bool updateEpisodes(List<Episode> newEpisodes) {
    bool updated = false;

    // Map new episodes by their path string for quick lookup
    final Map<String, Episode> newByPath = {for (final e in newEpisodes) e.path.path: e};

    // Replace episodes inside collections
    for (final collection in collections) {
      for (int i = 0; i < collection.episodes.length; i++) {
        final existing = collection.episodes[i];
        final replacement = newByPath[existing.path.path];
        if (replacement != null && !identical(replacement, existing)) {
          collection.episodes[i] = replacement;
          updated = true;
        }
      }
    }

    return updated;
  }

  /// Get MappingTarget for a given AnilistMapping
  /// 
  /// Returns null if the mapping path doesn't correspond to any season or episode
  MappingTarget? getTargetForMapping(AnilistMapping mapping) {
    // Check if mapping points to a collection folder
    for (final collection in collections) {
      if (collection.path == mapping.localPath) return MappingTarget.collection(collection);
    }

    // Check if mapping points to an episode within a collection
    for (final collection in collections) {
      for (final episode in collection.episodes) {
        if (episode.path == mapping.localPath) return MappingTarget.episode(episode);
      }
    }
    // TODO logTrace('No target found for mapping with Anilist ID ${mapping.anilistId} and path ${mapping.localPath}');
    return null;
  }

  /// Get the AnilistMapping for a given Episode
  /// Returns null if no mapping is found for the episode
  AnilistMapping? getMappingForEpisode(Episode episode) {
    // First, check if the episode path directly matches a mapping
    for (final mapping in anilistMappings) {
      if (mapping.localPath == episode.path) return mapping;
    }

    // If not, check if the episode is within a collection that has a mapping
    for (final collection in collections) {
      if (collection.episodes.contains(episode)) {
        // Found the collection containing this episode, check if collection path matches a mapping
        for (final mapping in anilistMappings) {
          if (mapping.localPath == collection.path) return mapping;
        }
      }
    }

    // If still not found, return null (fallback to primary mapping)
    return null;
  }

  bool removeMapping(MappingTarget target) {
    for (final mapping in anilistMappings) {
      if (mapping.localPath == target.path) {
        anilistMappings.remove(mapping);
        return true;
      }
    }
    return false;
  }
}


