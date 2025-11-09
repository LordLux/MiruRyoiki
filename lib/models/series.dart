// ignore_for_file: library_prefixes, unnecessary_this

import 'dart:io';

import 'package:flutter/widgets.dart' hide Image;
import 'package:miruryoiki/models/metadata.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';

import '../manager.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../services/anilist/queries/anilist_service.dart';
import '../services/file_system/cache.dart';
import '../utils/color.dart' as colorUtils;
import '../utils/logging.dart';
import '../utils/path.dart';
import '../utils/text.dart';
import 'anilist/anime.dart';
import 'anilist/mapping.dart';
import 'anilist/user_list.dart';
import 'episode.dart';
import '../enums.dart';
import 'season.dart';
import 'mapping_target.dart';

class Series {
  /// Database ID
  final int? id;

  /// Name of the series from the File System
  final String name;

  /// Path for the series from the File System
  final PathString path;

  /// List of seasons for the series from the File System
  final List<Season> seasons;

  /// List of related media (ONA/OVA) for the series from the File System
  final List<Episode> relatedMedia;

  /// Anilist IDs for the series
  List<AnilistMapping> anilistMappings;

  /// The currently selected Anilist ID for display purposes
  int? _primaryAnilistId;

  /// Cached dominant color from poster image
  Color? _localPosterDominantColor;

  /// Cached dominant color from banner image
  Color? _localBannerDominantColor;

  /// Preferred source for the Poster
  ImageSource? preferredPosterSource;

  /// Preferred source for the Banner
  ImageSource? preferredBannerSource;

  /// Cached URL for Anilist Poster
  String? _anilistPosterUrl;

  /// Cached URL for Anilist Banner
  String? _anilistBannerUrl;

  /// Poster path for the series from the File System
  PathString? localPosterPath;

  /// Poster path for the series from the File System
  PathString? localBannerPath;

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
    this.localPosterPath,
    this.localBannerPath,
    required this.seasons,
    this.relatedMedia = const [],
    this.anilistMappings = const [],
    AnilistAnime? anilistData,
    Color? posterColor,
    Color? bannerColor,
    this.preferredPosterSource,
    this.preferredBannerSource,
    String? anilistPoster,
    String? anilistBanner,
    int? primaryAnilistId,
    bool isHidden = false,
    this.customListName,
    this.customGridOrder,
    Metadata? metadata,
  })  : isForcedHidden = isHidden,
        _localPosterDominantColor = posterColor,
        _localBannerDominantColor = bannerColor,
        _anilistPosterUrl = anilistPoster,
        _anilistBannerUrl = anilistBanner,
        _primaryAnilistId = primaryAnilistId ?? anilistMappings.firstOrNull?.anilistId,
        _metadata = metadata;

  /// Create a copy of the series with modified fields
  Series copyWith({
    int? id,
    String? name,
    PathString? path,
    PathString? folderPosterPath,
    PathString? folderBannerPath,
    List<Season>? seasons,
    List<Episode>? relatedMedia,
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
      localPosterPath: folderPosterPath ?? this.localPosterPath,
      localBannerPath: folderBannerPath ?? this.localBannerPath,
      seasons: seasons ?? this.seasons,
      relatedMedia: relatedMedia ?? this.relatedMedia,
      anilistMappings: anilistMappings ?? this.anilistMappings,
      anilistData: anilistData ?? anilistData,
      posterColor: posterColor ?? _localPosterDominantColor,
      bannerColor: bannerColor ?? _localBannerDominantColor,
      preferredPosterSource: preferredPosterSource ?? this.preferredPosterSource,
      preferredBannerSource: preferredBannerSource ?? this.preferredBannerSource,
      primaryAnilistId: primaryAnilistId ?? _primaryAnilistId,
      anilistPoster: anilistPoster ?? _anilistPosterUrl,
      anilistBanner: anilistBanner ?? _anilistBannerUrl,
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
      'posterPath': localPosterPath?.pathMaybe, // nullable
      'bannerPath': localBannerPath?.pathMaybe, // nullable
      'seasons': seasons.map((s) => s.toJson()).toList(),
      'relatedMedia': relatedMedia.map((e) => e.toJson()).toList(),
      'anilistMappings': anilistMappings.map((m) => m.toJson()).toList(),
      'posterColor': _localPosterDominantColor?.value, // nullable
      'bannerColor': _localBannerDominantColor?.value, // nullable
      'primaryAnilistId': _primaryAnilistId,
      'anilistPosterUrl': _anilistPosterUrl ?? anilistData?.posterImage, // nullable
      'anilistBannerUrl': _anilistBannerUrl ?? anilistData?.bannerImage, // nullable
      'preferredPosterSource': preferredPosterSource?.name_, // nullable
      'preferredBannerSource': preferredBannerSource?.name_, // nullable
      'isHidden': isForcedHidden,
      'customListName': customListName, // nullable
      'customGridOrder': customGridOrder, // nullable
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
        id: json['id'] as int?,
        name: name,
        path: path,
        localPosterPath: PathString.fromJson(json['posterPath']),
        localBannerPath: PathString.fromJson(json['bannerPath']),
        seasons: seasons,
        relatedMedia: relatedMedia,
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
        seasons: [],
      );
    }
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
        listEquality(other.seasons, seasons) &&
        listEquality(other.relatedMedia, relatedMedia) &&
        listEquality(other.anilistMappings, anilistMappings) &&
        other._primaryAnilistId == _primaryAnilistId &&
        other._localPosterDominantColor == _localPosterDominantColor &&
        other._localBannerDominantColor == _localBannerDominantColor &&
        other.preferredPosterSource == preferredPosterSource &&
        other.preferredBannerSource == preferredBannerSource &&
        other._anilistPosterUrl == _anilistPosterUrl &&
        other._anilistBannerUrl == _anilistBannerUrl &&
        other.localPosterPath == localPosterPath &&
        other.localBannerPath == localBannerPath &&
        other.isForcedHidden == isForcedHidden &&
        other.customListName == customListName;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        path,
        Object.hashAll(seasons),
        Object.hashAll(relatedMedia),
        Object.hashAll(anilistMappings),
        _primaryAnilistId,
        _localPosterDominantColor,
        _localBannerDominantColor,
        preferredPosterSource,
        preferredBannerSource,
        _anilistPosterUrl,
        _anilistBannerUrl,
        localPosterPath,
        localBannerPath,
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

  /// Set the Anilist data for the series
  set anilistData(AnilistAnime? value) {
    final mapping = anilistMappings.firstWhereOrNull((m) => m.anilistId == _primaryAnilistId);
    if (mapping != null) mapping.anilistData = value;

    _anilistPosterUrl = value?.posterImage;
    _anilistBannerUrl = value?.bannerImage;
  }

  /// Get primary color from the series poster image
  Color? get localPosterColor {
    // Always prioritize locally calculated color which respects DominantColorSource
    if (_localPosterDominantColor != null) return _localPosterDominantColor;

    // Fall back to Anilist color if locally calculated color is not available
    return anilistData?.dominantColor?.fromHex();
  }

  /// Get primary color from the series poster image
  Color? get localBannerColor {
    // Always prioritize locally calculated color which respects DominantColorSource
    if (_localBannerDominantColor != null) return _localBannerDominantColor;

    // Fall back to Anilist color if locally calculated color is not available
    return anilistData?.dominantColor?.fromHex();
  }

  Future<void> calculateLocalPosterDominantColor({bool forceRecalculate = false}) async {
    final result = await colorUtils.calculateLocalDominantColors(this, forceRecalculate: forceRecalculate);
    if (result.$2 == true) _localPosterDominantColor = result.$1?.$1 ?? _localPosterDominantColor; // override if new, othewise keep old
  }

  Future<void> calculateLocalBannerDominantColor({bool forceRecalculate = false}) async {
    final result = await colorUtils.calculateLocalDominantColors(this, forceRecalculate: forceRecalculate);
    if (result.$2 == true) _localBannerDominantColor = result.$1?.$2 ?? _localBannerDominantColor; // override if new, othewise keep old
  }

  Future<void> calculateLocalDominantColors({bool forceRecalculate = false}) async {
    final result = await colorUtils.calculateLocalDominantColors(this, forceRecalculate: forceRecalculate);
    if (result.$2 == true) {
      _localPosterDominantColor = result.$1?.$1 ?? _localPosterDominantColor; // override if new, othewise keep old
      _localBannerDominantColor = result.$1?.$2 ?? _localBannerDominantColor; // override if new, othewise keep old
    }
  }

  Future<void> clearCachedDominantColors() async {
    _localPosterDominantColor = null;
    _localBannerDominantColor = null;
  }

  /// Get the Anilist poster URL
  String? get anilistPosterUrl => _anilistPosterUrl ?? anilistData?.posterImage;

  /// Get the Anilist banner URL
  String? get anilistBannerUrl => _anilistBannerUrl ?? anilistData?.bannerImage;

  /// Media list entries for the series
  Map<int, AnilistMediaListEntry?>? _mediaListEntries;

  /// Cached info for quick access
  (AnilistMediaListEntry?, int?, int?, DateTime?, DateTime?, int?, DateTime?, DateTime?, int?)? _cachedSeriesInfo;

  /// Get media list entries for the series
  Map<int, AnilistMediaListEntry?> get mediaListEntries => _mediaListEntries ?? getMediaListEntries(Provider.of<AnilistProvider>(Manager.context, listen: false));

  /// Get media list entries for the series
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

  /// Get the best entry values from all user's list entries for this series
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
    int? averageUserScore; //           averageScore - user score
    DateTime? earliestReleaseDate; //   startDate    - official release date
    DateTime? latestEndDate; //         endDate      - official end date
    int? averagePopularity; //          popularity   - popularity

    // Variables for calculating averages
    int totalUserScore = 0;
    int userScoreCount = 0;
    int totalPopularity = 0;
    int popularityCount = 0;

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

        // User score - collect for average calculation
        if (entry.score != null) {
          totalUserScore += entry.score!;
          userScoreCount++;
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

        // Popularity - collect for average calculation
        if (animeData.popularity != null) {
          totalPopularity += animeData.popularity!;
          popularityCount++;
        }
      }
    }

    // Calculate averages
    if (userScoreCount > 0) averageUserScore = int.parse((totalUserScore / userScoreCount).round().toString());

    if (popularityCount > 0) averagePopularity = int.parse((totalPopularity / popularityCount).round().toString());

    // Cache the results
    _cachedSeriesInfo = (
      bestEntry, //$1
      latestUpdatedAt, //$2
      earliestCreatedAt, //$3
      earliestStartedAt, //$4
      latestCompletionDate, //$5
      averageUserScore, //$6
      earliestReleaseDate, //$7
      latestEndDate, //$8
      averagePopularity, //$9
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
  AnilistMediaListEntry? getMediaListEntry(AnilistProvider anilistProvider) {
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

  // Getters for seasons and episodes

  /// Get episode by database ID (searches all seasons and related media)
  Episode? getEpisodeById(int episodeId) {
    // Search seasons
    for (final season in seasons) {
      final episode = season.getEpisodeById(episodeId);
      if (episode != null) return episode;
    }

    // Search related media
    return relatedMedia.firstWhereOrNull((episode) => episode.id == episodeId);
  }

  /// Get episode by number (searches all seasons and related media)
  Episode? getEpisodeByNumber(int episodeNumber, {int? seasonNumber}) {
    if (seasonNumber != null) {
      // Search specific season
      return seasons.elementAtOrNull(seasonNumber - 1)?.getEpisodeByNumber(episodeNumber);
    }

    // Search all seasons
    for (final season in seasons) {
      final episode = season.getEpisodeByNumber(episodeNumber);
      if (episode != null) return episode;
    }

    // Search related media
    return relatedMedia.firstWhereOrNull((e) => e.episodeNumber == episodeNumber);
  }

  Episode? getEpisodeByPath(PathString episodePath) {
    // Search seasons
    for (final season in seasons) {
      final episode = season.getEpisodeByPath(episodePath);
      if (episode != null) return episode;
    }

    // Search related media
    return relatedMedia.firstWhereOrNull((episode) => episode.path == episodePath);
  }

  List<Episode> getEpisodesForSeason([int i = 1]) {
    // TODO check if series has global episodes numbering or not
    if (i < 1 || i > seasons.length) //
      return <Episode>[];

    return seasons[i - 1].episodes;
  }

  Season? getSeasonFromPath(PathString seasonPath) => //
      seasons.firstWhereOrNull((season) => season.path == seasonPath);

  /// Get ONA/OVA
  List<Episode> getUncategorizedEpisodes() {
    final categorizedEpisodes = seasons.expand((s) => s.episodes).toSet();
    return relatedMedia.where((e) => !categorizedEpisodes.contains(e)).toList();
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
  static int? parseSeasonNumber(String gridId) {
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
    for (int i = 1; i <= seasons.length; i++) grids.add(getGridIdentifier(i));

    // Add uncategorized if it has episodes
    if (getUncategorizedEpisodes().isNotEmpty) grids.add(getGridIdentifier(0));

    return grids;
  }

  /// Set custom grid display order
  /// Pass null to reset to default order
  void setGridDisplayOrder(List<String>? order) => customGridOrder = order;

  /// Check if a grid identifier is valid for this series
  bool isValidGridId(String gridId) {
    final seasonNum = parseSeasonNumber(gridId);
    if (seasonNum == null) return false;

    if (seasonNum == 0) return getUncategorizedEpisodes().isNotEmpty;

    return seasonNum > 0 && seasonNum <= seasons.length;
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

    final title = (currentAnilistData?.title.userPreferred ?? currentAnilistData?.title.english ?? currentAnilistData?.title.romaji ?? name);

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

  /// Checks if any Anilist mapping has the "hide from status lists" flag set
  bool get isAnilistHidden => isLinked && mediaListEntries.values.any((entry) => entry?.hiddenFromStatusLists == true);

  /// Getter to check if the poster is from Anilist
  String? get effectivePosterPath {
    final ImageSource effectiveSource = preferredPosterSource ?? Manager.defaultPosterSource;

    // Determine available options
    final bool hasLocalPoster = localPosterPath != null;
    final bool hasAnilistPoster = anilistPosterUrl != null;

    // Apply fallback logic based on source preference
    switch (effectiveSource) {
      case ImageSource.autoLocal:
      case ImageSource.local:
        return hasLocalPoster ? localPosterPath?.pathMaybe : (hasAnilistPoster ? anilistPosterUrl : null);

      case ImageSource.autoAnilist:
      case ImageSource.anilist:
        return hasAnilistPoster ? anilistPosterUrl : (hasLocalPoster ? localPosterPath?.pathMaybe : null);
    }
  }

  /// Get the effective poster image as an ImageProvider
  Future<ImageProvider?> getPosterImage() async {
    final path = effectivePosterPath;
    if (path == null) return null;
    if (isLocalPosterBeingUsed) return FileImage(File(path));
    if (isAnilistPosterBeingUsed) return await ImageCacheService().getImageProvider(path);
    return null;
  }

  /// Get the effective poster path for a specific episode
  String? getEffectivePosterPathForEpisode(Episode episode) {
    final mapping = getMappingForEpisode(episode);
    if (mapping == null) {
      logWarn('No mapping found for episode ${episode.episodeNumber} in series $name');
      return effectivePosterPath;
    } // Fallback to primary mapping

    final ImageSource effectiveSource = preferredPosterSource ?? Manager.defaultPosterSource;
    final bool hasLocalPoster = localPosterPath != null;
    final bool hasAnilistPoster = mapping.anilistData?.posterImage != null;

    switch (effectiveSource) {
      case ImageSource.autoLocal:
      case ImageSource.local:
        return hasLocalPoster ? localPosterPath?.pathMaybe : (hasAnilistPoster ? mapping.anilistData!.posterImage : null);

      case ImageSource.autoAnilist:
      case ImageSource.anilist:
        return hasAnilistPoster ? mapping.anilistData!.posterImage : (hasLocalPoster ? localPosterPath?.pathMaybe : null);
    }
  }

  /// Get the effective poster image for a specific episode
  Future<ImageProvider?> getPosterImageForEpisode(Episode episode) async {
    final path = getEffectivePosterPathForEpisode(episode);
    if (path == null) return null;

    // Check if it's a local path or URL
    if (path.startsWith('http://') || path.startsWith('https://')) //
      return await ImageCacheService().getImageProvider(path);
    // Local file
    return FileImage(File(path));
  }

  /// Get the effective poster color for a specific episode
  /// Uses the episode's corresponding AniList mapping if available
  Color? getEffectivePosterColorForEpisode(Episode episode) {
    final mapping = getMappingForEpisode(episode);
    if (mapping == null) return localPosterColor; // Fallback to primary mapping

    final ImageSource effectiveSource = preferredPosterSource ?? Manager.defaultPosterSource;

    switch (effectiveSource) {
      case ImageSource.autoLocal:
      case ImageSource.local:
        return _localPosterDominantColor ?? mapping.posterColor ?? mapping.anilistData?.dominantColor?.fromHex();

      case ImageSource.autoAnilist:
      case ImageSource.anilist:
        return mapping.posterColor ?? mapping.anilistData?.dominantColor?.fromHex() ?? _localPosterDominantColor;
    }
  }

  /// Get the effective poster path for a specific AniList ID
  String? getEffectivePosterPathForAnilistId(int anilistId) {
    final mapping = anilistMappings.firstWhereOrNull((m) => m.anilistId == anilistId);
    if (mapping == null) return effectivePosterPath; // Fallback to primary mapping

    final ImageSource effectiveSource = preferredPosterSource ?? Manager.defaultPosterSource;
    final bool hasLocalPoster = localPosterPath != null;
    final bool hasAnilistPoster = mapping.anilistData?.posterImage != null;

    switch (effectiveSource) {
      case ImageSource.autoLocal:
      case ImageSource.local:
        return hasLocalPoster ? localPosterPath?.pathMaybe : (hasAnilistPoster ? mapping.anilistData!.posterImage : null);

      case ImageSource.autoAnilist:
      case ImageSource.anilist:
        return hasAnilistPoster ? mapping.anilistData!.posterImage : (hasLocalPoster ? localPosterPath?.pathMaybe : null);
    }
  }

  /// Get the effective poster image for a specific AniList ID
  Future<ImageProvider?> getPosterImageForAnilistId(int anilistId) async {
    final path = getEffectivePosterPathForAnilistId(anilistId);
    if (path == null) return null;

    // Check if it's a local path or URL
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return await ImageCacheService().getImageProvider(path);
    } else {
      return FileImage(File(path));
    }
  }

  /// Get the effective poster color for a specific AniList ID
  Color? getEffectivePosterColorForAnilistId(int anilistId) {
    final mapping = anilistMappings.firstWhereOrNull((m) => m.anilistId == anilistId);
    if (mapping == null) return localPosterColor; // Fallback to primary mapping

    final ImageSource effectiveSource = preferredPosterSource ?? Manager.defaultPosterSource;

    switch (effectiveSource) {
      case ImageSource.autoLocal:
      case ImageSource.local:
        return _localPosterDominantColor ?? mapping.posterColor ?? mapping.anilistData?.dominantColor?.fromHex();

      case ImageSource.autoAnilist:
      case ImageSource.anilist:
        return mapping.posterColor ?? mapping.anilistData?.dominantColor?.fromHex() ?? _localPosterDominantColor;
    }
  }

  //
  //
  /// Getter to check if the banner is from Anilist or local file
  String? get effectiveBannerPath {
    final ImageSource effectiveSource = preferredBannerSource ?? Manager.defaultBannerSource;

    // Determine available options
    final bool hasLocalBanner = localBannerPath != null;
    final bool hasAnilistBanner = anilistBannerUrl != null;

    // Apply fallback logic based on source preference
    switch (effectiveSource) {
      case ImageSource.autoLocal:
      case ImageSource.local:
        return hasLocalBanner ? localBannerPath?.pathMaybe : (hasAnilistBanner ? anilistBannerUrl : null);

      case ImageSource.autoAnilist:
      case ImageSource.anilist:
        return hasAnilistBanner ? anilistBannerUrl : (hasLocalBanner ? localBannerPath?.pathMaybe : null);
    }
  }

  /// Get the effective primary color based on settings and available images
  Future<Color?> effectivePrimaryColor({int? anilistId, bool forceRecalculate = false, bool? overrideIsPoster}) async {
    // Determine available options
    final bool hasLocalBanner = localBannerPath != null;
    final bool hasAnilistBanner = anilistBannerUrl != null;

    // Apply fallback logic based on source preference
    if (overrideIsPoster ?? (Manager.settings.dominantColorSource == DominantColorSource.poster)) {
      switch (preferredPosterSource ?? Manager.defaultPosterSource) {
        case ImageSource.autoLocal:
        case ImageSource.local:
          return hasLocalBanner ? _localPosterDominantColor : (hasAnilistBanner ? anilistData?.dominantColor?.fromHex() : null);

        case ImageSource.autoAnilist:
        case ImageSource.anilist:
          final res = anilistMappings.firstWhereOrNull((m) => m.anilistId == (anilistId ?? primaryAnilistId));
          if (forceRecalculate) return await res?.calculatePosterColor();
          return await res?.posterColorFuture;
      }
    } else {
      switch (preferredBannerSource ?? Manager.defaultBannerSource) {
        case ImageSource.autoLocal:
        case ImageSource.local:
          return hasLocalBanner ? _localBannerDominantColor : (hasAnilistBanner ? anilistData?.dominantColor?.fromHex() : null);
        case ImageSource.autoAnilist:
        case ImageSource.anilist:
          final a = anilistMappings.firstWhereOrNull((m) => m.anilistId == (anilistId ?? primaryAnilistId));
          if (forceRecalculate) return await a?.calculateBannerColor();
          return await a?.bannerColorFuture;
      }
    }
  }

  /// Get the effective primary color based on settings and available images
  Color? effectivePrimaryColorSync([int? anilistId]) {
    // Determine available options
    final bool hasLocalBanner = localBannerPath != null;
    final bool hasAnilistBanner = anilistBannerUrl != null;

    // Apply fallback logic based on source preference
    if (Manager.settings.dominantColorSource == DominantColorSource.poster) {
      switch (preferredPosterSource ?? Manager.defaultPosterSource) {
        case ImageSource.autoLocal:
        case ImageSource.local:
          return hasLocalBanner ? _localPosterDominantColor : (hasAnilistBanner ? anilistData?.dominantColor?.fromHex() : null);

        case ImageSource.autoAnilist:
        case ImageSource.anilist:
          return anilistMappings.firstWhereOrNull((m) => m.anilistId == anilistId)?.posterColor;
      }
    } else {
      switch (preferredBannerSource ?? Manager.defaultBannerSource) {
        case ImageSource.autoLocal:
        case ImageSource.local:
          return hasLocalBanner ? _localBannerDominantColor : (hasAnilistBanner ? anilistData?.dominantColor?.fromHex() : null);
        case ImageSource.autoAnilist:
        case ImageSource.anilist:
          return anilistMappings.firstWhereOrNull((m) => m.anilistId == anilistId)?.bannerColor;
      }
    }
  }

  /// Getter to check if the banner actually being used is from Anilist
  bool get isAnilistBannerBeingUsed {
    if (effectiveBannerPath == null) return false;
    return effectiveBannerPath == anilistBannerUrl;
  }

  /// Getter to check if the banner actually being used is from a local file
  bool get isLocalBannerBeingUsed {
    if (effectiveBannerPath == null) return false;
    return effectiveBannerPath == localBannerPath?.pathMaybe;
  }

  /// Getter to check if the poster actually being used is from Anilist
  bool get isAnilistPosterBeingUsed {
    if (effectivePosterPath == null) return false;
    return effectivePosterPath == anilistPosterUrl;
  }

  /// Getter to check if the poster actually being used is from a local file
  bool get isLocalPosterBeingUsed {
    if (effectivePosterPath == null) return false;
    return effectivePosterPath == localPosterPath?.pathMaybe;
  }

  /// Get the effective banner image as an ImageProvider
  Future<ImageProvider?> getBannerImage() async {
    final path = effectiveBannerPath;
    if (path == null) return null;
    if (isLocalBannerBeingUsed) return FileImage(File(path));
    if (isAnilistBannerBeingUsed) return await ImageCacheService().getImageProvider(path);
    return null;
  }

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
    for (final season in seasons) {
      totSize += season.metadata?.size ?? 0;
      totDuration += season.metadata?.duration ?? Duration.zero;

      creationDate = DateTimeX.isBeforeMaybe(creationDate, season.metadata?.creationTime);
      lastModifiedDate = DateTimeX.isAfterMaybe(lastModifiedDate, season.metadata?.lastModified);
      lastAccessedDate = DateTimeX.isAfterMaybe(lastAccessedDate, season.metadata?.lastAccessed);
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

  /// DEPRECATED: Use Manager.episodeNavigator.getEpisodeInSeries instead
  @Deprecated('Use Manager.episodeNavigator.getEpisodeInSeries')
  Episode? getEpisode(int episodeNumber, {int season = 1}) => getEpisodeByNumber(episodeNumber, seasonNumber: season);

  /// DEPRECATED: Use Manager.anilistProgress.getNextEpisodeToWatch instead
  @Deprecated('Use Manager.anilistProgress.getNextEpisodeToWatch')
  (int, int)? get getNextEpisodeNumber {
    final provider = Provider.of<AnilistProvider>(Manager.context, listen: false);
    final nextNumber = Manager.anilistProgress.getNextEpisodeToWatch(this, provider);
    if (nextNumber == null) return null;

    // Find which season this episode belongs to
    final episode = Manager.episodeNavigator.getEpisodeInSeries(this, nextNumber);
    if (episode == null) return null;

    final season = Manager.episodeNavigator.findSeasonForEpisode(episode, this);
    final seasonIndex = seasons.indexOf(season!);

    return (seasonIndex + 1, nextNumber);
  }

  /// DEPRECATED: Use Manager.anilistProgress.getLastWatchedEpisode instead
  @Deprecated('Use Manager.anilistProgress.getLastWatchedEpisode')
  Episode? get getLastWatchedEpisode {
    final provider = Provider.of<AnilistProvider>(Manager.context, listen: false);
    return Manager.anilistProgress.getLastWatchedEpisode(this, provider);
  }

  /// DEPRECATED: Use Manager.anilistProgress.getNextEpisodeToWatchEpisode instead
  @Deprecated('Use Manager.anilistProgress.getNextEpisodeToWatchEpisode')
  Episode? get getNextEpisode {
    final provider = Provider.of<AnilistProvider>(Manager.context, listen: false);
    return Manager.anilistProgress.getNextEpisodeToWatchEpisode(this, provider);
  }

  // Update existing progress getters to use Anilist data
  int get totalEpisodes {
    if (isLinked) {
      return Manager.anilistProgress.getTotalEpisodesFromAnilist(this);
    }
    // Fallback to local count
    return seasons.fold(0, (sum, season) => sum + season.episodes.length) + relatedMedia.length;
  }

  int get watchedEpisodes {
    if (isLinked) {
      try {
        final provider = Provider.of<AnilistProvider>(Manager.context, listen: false);
        return Manager.anilistProgress.getWatchedEpisodesFromAnilist(this, provider);
      } catch (e) {
        // Context not available in isolate
        return seasons.fold(0, (sum, season) => sum + season.watchedCount) + relatedMedia.where((e) => e.watched).length;
      }
    }
    // Fallback to local count
    return seasons.fold(0, (sum, season) => sum + season.watchedCount) + relatedMedia.where((e) => e.watched).length;
  }

  double get watchedPercentage {
    if (isLinked) {
      try {
        final provider = Provider.of<AnilistProvider>(Manager.context, listen: false);
        return Manager.anilistProgress.getSeriesProgress(this, provider);
      } catch (e) {
        // Context not available in isolate
        return totalEpisodes > 0 ? watchedEpisodes / totalEpisodes : 0.0;
      }
    }
    // Fallback to local calculation
    return totalEpisodes > 0 ? watchedEpisodes / totalEpisodes : 0.0;
  }

  int get numberOfSeasons {
    if (seasons.isEmpty) return 0;

    // Get all valid season numbers
    final seasonNumbers = seasons //
        .map((season) => season.seasonNumber)
        .where((number) => number != null)
        .cast<int>()
        .toList();

    // If we have actual seasons with numbers, return the highest number
    if (seasonNumbers.isNotEmpty) //
      return seasonNumbers.reduce((a, b) => a > b ? a : b);

    // Otherwise, return the total count of all seasons
    return seasons.length;
  }

  /// Get the effective status of the series based on Anilist mappings
  String? get effectiveStatus {
    if (!isLinked) return null;

    final priority = [
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

    // Replace episodes inside seasons
    for (final season in seasons) {
      for (int i = 0; i < season.episodes.length; i++) {
        final existing = season.episodes[i];
        final replacement = newByPath[existing.path.path];
        if (replacement != null && !identical(replacement, existing)) {
          season.episodes[i] = replacement;
          updated = true;
        }
      }
    }

    // Replace episodes inside relatedMedia
    for (int i = 0; i < relatedMedia.length; i++) {
      final existing = relatedMedia[i];
      final replacement = newByPath[existing.path.path];
      if (replacement != null && !identical(replacement, existing)) {
        relatedMedia[i] = replacement;
        updated = true;
      }
    }

    return updated;
  }

  /// Get MappingTarget for a given AnilistMapping
  /// Returns null if the mapping path doesn't correspond to any season or episode
  MappingTarget? getTargetForMapping(AnilistMapping mapping) {
    // Check if mapping points to a season folder
    for (final season in seasons) {
      if (season.path == mapping.localPath) return MappingTarget.season(season);
    }

    // Check if mapping points to a related media episode
    for (final episode in relatedMedia) {
      if (episode.path == mapping.localPath) return MappingTarget.episode(episode);
    }
    // Check if mapping points to an episode within a season
    for (final season in seasons) {
      for (final episode in season.episodes) {
        if (episode.path == mapping.localPath) return MappingTarget.episode(episode);
      }
    }
    logTrace('No target found for mapping with Anilist ID ${mapping.anilistId} and path ${mapping.localPath}');
    return null;
  }

  /// Get the AnilistMapping for a given Episode
  /// Returns null if no mapping is found for the episode
  AnilistMapping? getMappingForEpisode(Episode episode) {
    // First, check if the episode path directly matches a mapping
    for (final mapping in anilistMappings) {
      if (mapping.localPath == episode.path) return mapping;
    }

    // If not, check if the episode is within a season that has a mapping
    for (final season in seasons) {
      if (season.episodes.contains(episode)) {
        // Found the season containing this episode, check if season path matches a mapping
        for (final mapping in anilistMappings) {
          if (mapping.localPath == season.path) return mapping;
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
        // Invalidate cached media list entries
        _mediaListEntries = null;
        _cachedSeriesInfo = null;
        return true;
      }
    }
    return false;
  }
}
