import 'anime.dart';

enum AnilistListStatus {
  current,
  planning,
  completed,
  dropped,
  paused,
}

class AnilistMediaListEntry {
  final int id;
  final int mediaId;
  final AnilistAnime media;
  final String status;
  final int? progress;
  final int? score;
  final String? customLists;
  
  AnilistMediaListEntry({
    required this.id,
    required this.mediaId,
    required this.media,
    required this.status,
    this.progress,
    this.score,
    this.customLists,
  });
  
  factory AnilistMediaListEntry.fromJson(Map<String, dynamic> json) {
    return AnilistMediaListEntry(
      id: json['id'],
      mediaId: json['mediaId'],
      media: AnilistAnime.fromJson(json['media']),
      status: json['status'],
      progress: json['progress'],
      score: json['score'],
      customLists: json['customLists']?.toString(),
    );
  }
}

class AnilistUserList {
  final List<AnilistMediaListEntry> entries;
  final String name;
  final bool isCustomList;
  
  AnilistUserList({
    required this.entries,
    required this.name,
    this.isCustomList = false,
  });
  
  factory AnilistUserList.fromJson(Map<String, dynamic> json, String name, {bool isCustomList = false}) {
    final lists = json['lists'] as List<dynamic>?;
    final entries = <AnilistMediaListEntry>[];
    
    if (lists != null) {
      for (final list in lists) {
        final listEntries = list['entries'] as List<dynamic>?;
        if (listEntries != null) {
          entries.addAll(
            listEntries.map((e) => AnilistMediaListEntry.fromJson(e as Map<String, dynamic>))
          );
        }
      }
    }
    
    return AnilistUserList(
      entries: entries,
      name: name,
      isCustomList: isCustomList,
    );
  }
}

class AnilistUser {
  final int id;
  final String name;
  final String? avatar;
  
  AnilistUser({
    required this.id,
    required this.name,
    this.avatar,
  });
  
  factory AnilistUser.fromJson(Map<String, dynamic> json) {
    return AnilistUser(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar']?['large'],
    );
  }
}