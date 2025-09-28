import 'dart:convert';
import 'dart:io';

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

  AnilistMapping({
    required this.localPath,
    required this.anilistId,
    this.title,
    this.lastSynced,
    this.anilistData,
  });

  Map<String, dynamic> toJson() => {
        'localPath': localPath.path, // not nullable
        'anilistId': anilistId,
        'title': title,
        'lastSynced': lastSynced?.toIso8601String(),
        // We don't save anilistData in JSON, it will be fetched on demand
      };

  factory AnilistMapping.fromJson(Map<String, dynamic> json) => AnilistMapping(
        localPath: PathString.fromJson(json['localPath'])!,
        anilistId: json['anilistId'],
        title: json['title'],
        lastSynced: json['lastSynced'] != null ? DateTime.parse(json['lastSynced']) : null,
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

      final entities = localDir.listSync(recursive: false);  // only direct children
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

  static AnilistMapping fromJsonString(String jsonString) {
    return AnilistMapping.fromJson(jsonDecode(jsonString));
  }
}
