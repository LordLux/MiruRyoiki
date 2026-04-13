// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'anime.dart';
import 'user_data.dart';

/// Encode the `customLists` value from the API into a JSON string.
///
/// The AniList GraphQL API returns `customLists` as a JSON object
/// (`Map<String, dynamic>`), but when the value has been through
/// `toJson()` → `fromJson()` cycles it may already be a String.
/// Using `toString()` on a Map produces Dart's default representation
/// (e.g. `{key: true}`) which is NOT valid JSON, so we explicitly
/// `jsonEncode` Maps to keep the round-trip safe.
String? _encodeCustomLists(dynamic value) {
  if (value == null) return null;
  if (value is String) return value; // already serialised
  if (value is Map) return jsonEncode(value);
  return value.toString(); // fallback
}

enum AnilistListApiStatus {
  CURRENT,
  PLANNING,
  COMPLETED,
  DROPPED,
  PAUSED,
  REPEATING,
  CUSTOM,
}

const String CurrentString = "CURRENT";
const String PlanningString = "PLANNING";
const String CompletedString = "COMPLETED";
const String DroppedString = "DROPPED";
const String PausedString = "PAUSED";
const String RepeatingString = "REPEATING";
const String CustomString = "CUSTOM";

extension AnilistListStatusX on AnilistListApiStatus {
  
  String get name_ {
    return switch (this) {
      AnilistListApiStatus.CURRENT => CurrentString,
      AnilistListApiStatus.PLANNING => PlanningString,
      AnilistListApiStatus.COMPLETED => CompletedString,
      AnilistListApiStatus.DROPPED => DroppedString,
      AnilistListApiStatus.PAUSED => PausedString,
      AnilistListApiStatus.REPEATING => RepeatingString,
      AnilistListApiStatus.CUSTOM => CustomString,
    };
  }
}

extension AnilistListStatusExtension on String {
  AnilistListApiStatus? toListStatus() {
    return switch (this) {
      CurrentString => AnilistListApiStatus.CURRENT,
      PlanningString => AnilistListApiStatus.PLANNING,
      CompletedString => AnilistListApiStatus.COMPLETED,
      DroppedString => AnilistListApiStatus.DROPPED,
      PausedString => AnilistListApiStatus.PAUSED,
      RepeatingString => AnilistListApiStatus.REPEATING,
      CustomString => AnilistListApiStatus.CUSTOM,
      _ => null,
    };
  }
}

class AnilistMediaListEntry {
  final int id;
  final int mediaId;
  final AnilistAnime media;
  final AnilistListApiStatus status;
  final int? progress;
  final int? score; // format POINT_100 (0-100, format-independent)
  final int? repeat;
  final String? notes;
  final bool private;
  final String? customLists;
  final bool hiddenFromStatusLists;
  final int? priority;
  final DateValue? startedAt;
  final DateValue? completedAt;
  final int? createdAt;
  final int? updatedAt;

  AnilistMediaListEntry({
    required this.id,
    required this.mediaId,
    required this.media,
    required this.status,
    this.progress,
    this.score,
    this.repeat,
    this.notes,
    this.private = false,
    this.customLists,
    this.hiddenFromStatusLists = false,
    this.priority,
    this.startedAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory AnilistMediaListEntry.fromJson(Map<String, dynamic> json) {
    return AnilistMediaListEntry(
      id: json['id'],
      mediaId: json['mediaId'],
      media: AnilistAnime.fromJson(json['media']),
      status: json['status'].toString().toListStatus() ?? AnilistListApiStatus.CURRENT,
      progress: json['progress'],
      score: (json['score'] as num?)?.round(),
      repeat: json['repeat'],
      notes: json['notes'],
      private: json['private'] ?? false,
      customLists: _encodeCustomLists(json['customLists']),
      hiddenFromStatusLists: json['hiddenFromStatusLists'] ?? false,
      priority: json['priority'],
      startedAt: json['startedAt'] != null ? DateValue.fromJson(json['startedAt']) : null,
      completedAt: json['completedAt'] != null ? DateValue.fromJson(json['completedAt']) : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mediaId': mediaId,
      'media': media.toJson(),
      'status': status.name_,
      'progress': progress,
      'score': score,
      'repeat': repeat,
      'notes': notes,
      'private': private,
      'customLists': customLists,
      'hiddenFromStatusLists': hiddenFromStatusLists,
      'priority': priority,
      'startedAt': startedAt?.toJson(),
      'completedAt': completedAt?.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
  
  AnilistMediaListEntry copyWith({
    int? id,
    int? mediaId,
    AnilistAnime? media,
    AnilistListApiStatus? status,
    int? progress,
    int? score,
    int? repeat,
    String? notes,
    bool? private,
    String? customLists,
    bool? hiddenFromStatusLists,
    int? priority,
    DateValue? startedAt,
    DateValue? completedAt,
    int? createdAt,
    int? updatedAt,
  }) {
    return AnilistMediaListEntry(
      id: id ?? this.id,
      mediaId: mediaId ?? this.mediaId,
      media: media ?? this.media,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      score: score ?? this.score,
      repeat: repeat ?? this.repeat,
      notes: notes ?? this.notes,
      private: private ?? this.private,
      customLists: customLists ?? this.customLists,
      hiddenFromStatusLists: hiddenFromStatusLists ?? this.hiddenFromStatusLists,
      priority: priority ?? this.priority,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Hash code for UI-affecting properties only
  int get uiChangeHashCode {
    return Object.hash(
      mediaId,
      status,
      media.uiChangeHashCode,
      progress,
      score,
      updatedAt,
      completedAt,
    );
  }
}

class AnilistUserList {
  final List<AnilistMediaListEntry> entries;
  final String name;
  final AnilistListApiStatus? status;

  AnilistUserList({
    required this.entries,
    required this.name,
    this.status,
  });

  bool get isCustomList => status == null || status == AnilistListApiStatus.CUSTOM;

  factory AnilistUserList.fromJson(Map<String, dynamic> json, String name, {bool isCustomList = false}) {
    final lists = json['lists'] as List<dynamic>?;
    final entries = <AnilistMediaListEntry>[];

    if (lists != null) {
      for (final list in lists) {
        final listEntries = list['entries'] as List<dynamic>?;
        if (listEntries != null) {
          entries.addAll(listEntries.map((e) => AnilistMediaListEntry.fromJson(e as Map<String, dynamic>)));
        }
      }
    }

    return AnilistUserList(
      entries: entries,
      name: name,
      status: isCustomList ? AnilistListApiStatus.CUSTOM : json['status']?.toString().toListStatus(),
    );
  }
  
  @override
  String toString() => 'AUL($name)';

  /// Hash code for UI-affecting properties only
  int get uiChangeHashCode {
    // Hash all entry properties that affect UI
    int entriesHash = 0;
    for (final entry in entries) {
      entriesHash = Object.hash(entriesHash, entry.uiChangeHashCode);
    }
    return Object.hash(name, entriesHash);
  }
}

class AnilistUser {
  final int id;
  final String name;
  final String? avatar;
  final String? bannerImage;
  final AnilistUserData? userData;


  AnilistUser({
    required this.id,
    required this.name,
    this.avatar,
    this.bannerImage,
    this.userData,
  });
  
  AnilistUser copyWith({
    int? id,
    String? name,
    String? avatar,
    String? bannerImage,
    AnilistUserData? userData,
  }) {
    return AnilistUser(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      bannerImage: bannerImage ?? this.bannerImage,
      userData: userData ?? this.userData,
    );
  }

  /// Hash code for UI-affecting properties only
  int get uiChangeHashCode {
    return Object.hash(
      name,
      avatar,
      bannerImage,
      userData?.uiChangeHashCode,
    );
  }

  factory AnilistUser.fromJson(Map<String, dynamic> json) {
    return AnilistUser(
      id: json['id'],
      name: json['name'],
      avatar: parseProfilePicture(json['avatar']),
      bannerImage: json['bannerImage'],
      userData: json['userData'] != null ? AnilistUserData.fromJson(json['userData']) : null, //is null when called by getCurrentUser() but is then populated by getCurrentUser()
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'bannerImage': bannerImage,
      'userData': userData?.toJson(),
    };
  }
}

String? parseProfilePicture(dynamic avatar) {
  if (avatar == null) return null;
  if (avatar is String) return avatar;
  if (avatar is Map<String, dynamic>) {
    return avatar['large'] ?? avatar['medium'] ?? avatar['small'];
  }
  return null;
}
