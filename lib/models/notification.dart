// ignore_for_file: constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

enum NotificationType {
  AIRING,
  RELATED_MEDIA_ADDITION,
  MEDIA_DATA_CHANGE,
  MEDIA_MERGE,
  MEDIA_DELETION,
}

abstract class AnilistNotification {
  final int id;
  final NotificationType type;
  final int createdAt;
  final bool isRead;

  const AnilistNotification({
    required this.id,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toJson();

  AnilistNotification copyWith({
    int? id,
    NotificationType? type,
    int? createdAt,
    bool? isRead,
  }) {
    return switch (this) {
      AiringNotification n => n.copyWith(id: id, type: type, createdAt: createdAt, isRead: isRead),
      RelatedMediaAdditionNotification n => n.copyWith(id: id, type: type, createdAt: createdAt, isRead: isRead),
      MediaDataChangeNotification n => n.copyWith(id: id, type: type, createdAt: createdAt, isRead: isRead),
      MediaMergeNotification n => n.copyWith(id: id, type: type, createdAt: createdAt, isRead: isRead),
      MediaDeletionNotification n => n.copyWith(id: id, type: type, createdAt: createdAt, isRead: isRead),
      _ => throw UnimplementedError('copyWith not implemented for $runtimeType'),
    };
  }
}

@JsonSerializable()
class AiringNotification extends AnilistNotification {
  final int animeId;
  final int episode;
  final List<String> contexts;
  final MediaInfo? media;
  final String? format; // Format of the anime (TV, MOVIE, OVA, ONA, etc.)

  const AiringNotification({
    required super.id,
    required super.type,
    required super.createdAt,
    super.isRead,
    required this.animeId,
    required this.episode,
    required this.contexts,
    this.media,
    this.format,
  });

  factory AiringNotification.fromJson(Map<String, dynamic> json) => _$AiringNotificationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AiringNotificationToJson(this);

  /// Returns true if this notification is for a movie (based on format)
  bool get isMovie => format?.toUpperCase() == 'MOVIE';

  /// Returns a formatted title for display based on the anime format
  /// - For movies: "Movie - {title}"
  /// - For TV/OVA/ONA/etc: "Episode {episode} - {title}"
  String getFormattedTitle(String? fallbackTitle) {
    final title = media?.title ?? fallbackTitle ?? 'Unknown anime';
    if (isMovie) return 'Movie - $title';
    return 'Episode $episode - $title';
  }

  @override
  AiringNotification copyWith({
    int? id,
    NotificationType? type,
    int? createdAt,
    bool? isRead,
    int? animeId,
    int? episode,
    List<String>? contexts,
    MediaInfo? media,
    String? format,
  }) {
    return AiringNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      animeId: animeId ?? this.animeId,
      episode: episode ?? this.episode,
      contexts: contexts ?? this.contexts,
      media: media ?? this.media,
      format: format ?? this.format,
    );
  }
}

@JsonSerializable()
class RelatedMediaAdditionNotification extends AnilistNotification {
  final int mediaId;
  final String? context;
  final MediaInfo? media;

  const RelatedMediaAdditionNotification({
    required super.id,
    required super.type,
    required super.createdAt,
    super.isRead,
    required this.mediaId,
    this.context,
    this.media,
  });

  factory RelatedMediaAdditionNotification.fromJson(Map<String, dynamic> json) => _$RelatedMediaAdditionNotificationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RelatedMediaAdditionNotificationToJson(this);

  @override
  RelatedMediaAdditionNotification copyWith({
    int? id,
    NotificationType? type,
    int? createdAt,
    bool? isRead,
    int? mediaId,
    String? context,
    MediaInfo? media,
  }) {
    return RelatedMediaAdditionNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      mediaId: mediaId ?? this.mediaId,
      context: context ?? this.context,
      media: media ?? this.media,
    );
  }
}

@JsonSerializable()
class MediaDataChangeNotification extends AnilistNotification {
  final int mediaId;
  final String? context;
  final String? reason;
  final MediaInfo? media;

  const MediaDataChangeNotification({
    required super.id,
    required super.type,
    required super.createdAt,
    super.isRead,
    required this.mediaId,
    this.context,
    this.reason,
    this.media,
  });

  factory MediaDataChangeNotification.fromJson(Map<String, dynamic> json) => _$MediaDataChangeNotificationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MediaDataChangeNotificationToJson(this);

  @override
  MediaDataChangeNotification copyWith({
    int? id,
    NotificationType? type,
    int? createdAt,
    bool? isRead,
    int? mediaId,
    String? context,
    String? reason,
    MediaInfo? media,
  }) {
    return MediaDataChangeNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      mediaId: mediaId ?? this.mediaId,
      context: context ?? this.context,
      reason: reason ?? this.reason,
      media: media ?? this.media,
    );
  }
}

@JsonSerializable()
class MediaMergeNotification extends AnilistNotification {
  final int mediaId;
  final List<String> deletedMediaTitles;
  final String? context;
  final String? reason;
  final MediaInfo? media;

  const MediaMergeNotification({
    required super.id,
    required super.type,
    required super.createdAt,
    super.isRead,
    required this.mediaId,
    required this.deletedMediaTitles,
    this.context,
    this.reason,
    this.media,
  });

  factory MediaMergeNotification.fromJson(Map<String, dynamic> json) => _$MediaMergeNotificationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MediaMergeNotificationToJson(this);

  @override
  MediaMergeNotification copyWith({
    int? id,
    NotificationType? type,
    int? createdAt,
    bool? isRead,
    int? mediaId,
    List<String>? deletedMediaTitles,
    String? context,
    String? reason,
    MediaInfo? media,
  }) {
    return MediaMergeNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      mediaId: mediaId ?? this.mediaId,
      deletedMediaTitles: deletedMediaTitles ?? this.deletedMediaTitles,
      context: context ?? this.context,
      reason: reason ?? this.reason,
      media: media ?? this.media,
    );
  }
}

@JsonSerializable()
class MediaDeletionNotification extends AnilistNotification {
  final String? deletedMediaTitle;
  final String? context;
  final String? reason;

  const MediaDeletionNotification({
    required super.id,
    required super.type,
    required super.createdAt,
    super.isRead,
    this.deletedMediaTitle,
    this.context,
    this.reason,
  });

  factory MediaDeletionNotification.fromJson(Map<String, dynamic> json) => _$MediaDeletionNotificationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MediaDeletionNotificationToJson(this);

  @override
  MediaDeletionNotification copyWith({
    int? id,
    NotificationType? type,
    int? createdAt,
    bool? isRead,
    String? deletedMediaTitle,
    String? context,
    String? reason,
  }) {
    return MediaDeletionNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      deletedMediaTitle: deletedMediaTitle ?? this.deletedMediaTitle,
      context: context ?? this.context,
      reason: reason ?? this.reason,
    );
  }
}

@JsonSerializable()
class MediaInfo {
  final int id;
  final String? title;
  final String? coverImage;
  final String? type;
  final String? format;
  final int? episodes;

  const MediaInfo({
    required this.id,
    this.title,
    this.coverImage,
    this.type,
    this.format,
    this.episodes,
  });

  factory MediaInfo.fromJson(Map<String, dynamic> json) => _$MediaInfoFromJson(json);

  Map<String, dynamic> toJson() => _$MediaInfoToJson(this);
}
