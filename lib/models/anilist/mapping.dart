import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/enums.dart';
import '../../manager.dart';
import '../../utils/color.dart' as color_utils;

import '../../utils/file.dart';
import '../../utils/logging.dart';
import '../../utils/path.dart';
import 'anime.dart';

class AnilistMapping {
  PathString localPath;
  int anilistId;
  String? title; // Optional: Store Anilist title for easier display
  DateTime? lastSynced;
  AnilistAnime? anilistData;
  Color? _posterColor;
  Color? _bannerColor;

  AnilistMapping({
    required this.localPath,
    required this.anilistId,
    this.title,
    this.lastSynced,
    this.anilistData,
    Color? posterColor,
    Color? bannerColor,
  })  : _posterColor = posterColor,
        _bannerColor = bannerColor;

  Future<Color?> get posterColorFuture => _posterColor != null ? Future.value(_posterColor) : calculatePosterColor();
  Future<Color?> get bannerColorFuture => _bannerColor != null ? Future.value(_bannerColor) : calculateBannerColor();

  Color? get posterColor => _posterColor;
  Color? get bannerColor => _bannerColor;

  Future<Color?> calculatePosterColor() async {
    _posterColor = (await color_utils.calculateLinkColors(this, calculatePoster: true, forceRecalculate: true)).$1.$1;
    return _posterColor;
  }

  Future<Color?> calculateBannerColor() async {
    _bannerColor = (await color_utils.calculateLinkColors(this, calculateBanner: true, forceRecalculate: true)).$1.$2;
    return _bannerColor;
  }

  Future<void> calculateDominantColors({bool forceRecalculate = true}) async {
    final colors = await color_utils.calculateLinkColors(this, calculatePoster: true, calculateBanner: true, forceRecalculate: forceRecalculate);
    _posterColor = colors.$1.$1;
    _bannerColor = colors.$1.$2;
  }

  Map<String, dynamic> toJson() => {
        'localPath': localPath.path, // not nullable
        'anilistId': anilistId,
        'title': title,
        'anilistData': anilistData?.toJson(),
        'lastSynced': lastSynced?.toIso8601String(),
        'posterColor': _posterColor?.toHex(),
        'bannerColor': _bannerColor?.toHex(),
        // We don't save anilistData in JSON, it will be fetched on demand
      };

  factory AnilistMapping.fromJson(Map<String, dynamic> json) => AnilistMapping(
        localPath: PathString.fromJson(json['localPath'])!,
        anilistId: json['anilistId'],
        title: json['title'],
        anilistData: json['anilistData'] != null ? AnilistAnime.fromJson(json['anilistData']) : null,
        lastSynced: json['lastSynced'] != null ? DateTime.parse(json['lastSynced']) : null,
        posterColor: json['posterColor'] != null ? (json['posterColor'] as String).fromHex() : null,
        bannerColor: json['bannerColor'] != null ? (json['bannerColor'] as String).fromHex() : null,
      );

  @override
  String toString() {
    return 'AnilistMapping(localPath: $localPath, anilistId: $anilistId, title: $title, lastSynced: $lastSynced)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnilistMapping && //
        other.localPath == localPath &&
        other.anilistId == anilistId &&
        other.title == title &&
        other.lastSynced == lastSynced &&
        other._posterColor == _posterColor &&
        other._bannerColor == _bannerColor;
  }

  @override
  int get hashCode =>
      localPath.hashCode ^ //
      anilistId.hashCode ^
      title.hashCode ^
      lastSynced.hashCode ^
      _posterColor.hashCode ^
      _bannerColor.hashCode;

  /// Get all episode file paths linked to this mapping
  /// 
  /// If mapping points to a file: returns [that file]
  /// 
  /// If mapping points to a directory: returns all video files directly in that directory
  List<PathString> get linkedEpisodePaths {
    final localFile = File(localPath.path); // File
    final localDir = Directory(localPath.path); // Directory

    // Case 1: Mapping points directly to a file (Movies/OVAs/ONAs)
    if (localFile.existsSync()) return [localPath];

    // Case 2: Mapping points to a directory (Season folders)
    if (localDir.existsSync()) {
      final videoFiles = <PathString>[];

      final entities = localDir.listSync(recursive: false); // only direct children
      for (final entity in entities) {
        if (entity is File && FileUtils.isVideoFile(entity.path)) {
          videoFiles.add(PathString(entity.path));
        }
      }

      return videoFiles;
    }

    // Case 3: Path doesn't exist (this shouldn't happen)
    logErr('Anilist mapping path does not exist: ${localPath.path}');
    return [];
  }

  bool get isLinked => anilistData != null;

  // For easier debugging and logging
  String toJsonString() => jsonEncode(toJson());

  static AnilistMapping fromJsonString(String jsonString) => AnilistMapping.fromJson(jsonDecode(jsonString));

  AnilistMapping copyWith({
    PathString? localPath,
    int? anilistId,
    String? title,
    DateTime? lastSynced,
    AnilistAnime? anilistData,
    Color? posterColor,
    Color? bannerColor,
  }) {
    return AnilistMapping(
      localPath: localPath ?? this.localPath,
      anilistId: anilistId ?? this.anilistId,
      title: title ?? this.title,
      lastSynced: lastSynced ?? this.lastSynced,
      anilistData: anilistData ?? this.anilistData,
      posterColor: posterColor ?? _posterColor,
      bannerColor: bannerColor ?? _bannerColor,
    );
  }

  /// Get the effective primary color based on settings and available images
  Future<Color?> effectivePrimaryColor({bool forceRecalculate = false}) async {
    // DominantColorSource.poster
    if (Manager.settings.dominantColorSource == DominantColorSource.poster) {
      if (forceRecalculate) return await calculatePosterColor();
      return await posterColorFuture;
    }
    // DominantColorSource.banner
    if (forceRecalculate) return await calculateBannerColor();
    return await bannerColorFuture;
  }

  /// Get the effective primary color based on settings and available images
  Color? effectivePrimaryColorSync() => //
      Manager.settings.dominantColorSource == DominantColorSource.poster ? posterColor : bannerColor;
}
