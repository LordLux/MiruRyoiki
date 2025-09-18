import 'dart:convert';

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

  // For easier debugging and logging
  String toJsonString() => jsonEncode(toJson());

  static AnilistMapping fromJsonString(String jsonString) {
    return AnilistMapping.fromJson(jsonDecode(jsonString));
  }
}
