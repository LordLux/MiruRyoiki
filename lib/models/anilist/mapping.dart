import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/enums.dart';
import '../../utils/color.dart' as ColorUtils;

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
    _posterColor = (await ColorUtils.calculateLinkColors(this, calculatePoster: true, forceRecalculate: true)).$1.$1;
    return _posterColor;
  }
  Future<Color?> calculateBannerColor() async {
    _bannerColor = (await ColorUtils.calculateLinkColors(this, calculateBanner: true, forceRecalculate: true)).$1.$2;
    return _bannerColor;
  }
  
  Future<void> calculateDominantColors() async {
    final colors = await ColorUtils.calculateLinkColors(this, calculatePoster: true, calculateBanner: true, forceRecalculate: true);
    _posterColor = colors.$1.$1;
    _bannerColor = colors.$1.$2;
  }

  Map<String, dynamic> toJson() => {
        'localPath': localPath.path, // not nullable
        'anilistId': anilistId,
        'title': title,
        'lastSynced': lastSynced?.toIso8601String(),
        'posterColor': _posterColor?.toHex(),
        'bannerColor': _bannerColor?.toHex(),
        // We don't save anilistData in JSON, it will be fetched on demand
      };

  factory AnilistMapping.fromJson(Map<String, dynamic> json) => AnilistMapping(
        localPath: PathString.fromJson(json['localPath'])!,
        anilistId: json['anilistId'],
        title: json['title'],
        lastSynced: json['lastSynced'] != null ? DateTime.parse(json['lastSynced']) : null,
        posterColor: json['posterColor']?.fromHex(),
        bannerColor: json['bannerColor']?.fromHex(),
      );

  @override
  String toString() {
    return 'AnilistMapping(localPath: $localPath, anilistId: $anilistId, title: $title, lastSynced: $lastSynced)';
  }

  /// Get all episode file paths linked to this mapping
  /// If mapping points to a file: returns [that file]
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
}
