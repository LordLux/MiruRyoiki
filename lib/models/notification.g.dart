// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiringNotification _$AiringNotificationFromJson(Map<String, dynamic> json) =>
    AiringNotification(
      id: (json['id'] as num).toInt(),
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      createdAt: (json['createdAt'] as num).toInt(),
      isRead: json['isRead'] as bool? ?? false,
      animeId: (json['animeId'] as num).toInt(),
      episode: (json['episode'] as num).toInt(),
      contexts:
          (json['contexts'] as List<dynamic>).map((e) => e as String).toList(),
      media: json['media'] == null
          ? null
          : MediaInfo.fromJson(json['media'] as Map<String, dynamic>),
      format: json['format'] as String?,
    );

Map<String, dynamic> _$AiringNotificationToJson(AiringNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'createdAt': instance.createdAt,
      'isRead': instance.isRead,
      'animeId': instance.animeId,
      'episode': instance.episode,
      'contexts': instance.contexts,
      'media': instance.media,
      'format': instance.format,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.AIRING: 'AIRING',
  NotificationType.RELATED_MEDIA_ADDITION: 'RELATED_MEDIA_ADDITION',
  NotificationType.MEDIA_DATA_CHANGE: 'MEDIA_DATA_CHANGE',
  NotificationType.MEDIA_MERGE: 'MEDIA_MERGE',
  NotificationType.MEDIA_DELETION: 'MEDIA_DELETION',
};

RelatedMediaAdditionNotification _$RelatedMediaAdditionNotificationFromJson(
        Map<String, dynamic> json) =>
    RelatedMediaAdditionNotification(
      id: (json['id'] as num).toInt(),
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      createdAt: (json['createdAt'] as num).toInt(),
      isRead: json['isRead'] as bool? ?? false,
      mediaId: (json['mediaId'] as num).toInt(),
      context: json['context'] as String?,
      media: json['media'] == null
          ? null
          : MediaInfo.fromJson(json['media'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RelatedMediaAdditionNotificationToJson(
        RelatedMediaAdditionNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'createdAt': instance.createdAt,
      'isRead': instance.isRead,
      'mediaId': instance.mediaId,
      'context': instance.context,
      'media': instance.media,
    };

MediaDataChangeNotification _$MediaDataChangeNotificationFromJson(
        Map<String, dynamic> json) =>
    MediaDataChangeNotification(
      id: (json['id'] as num).toInt(),
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      createdAt: (json['createdAt'] as num).toInt(),
      isRead: json['isRead'] as bool? ?? false,
      mediaId: (json['mediaId'] as num).toInt(),
      context: json['context'] as String?,
      reason: json['reason'] as String?,
      media: json['media'] == null
          ? null
          : MediaInfo.fromJson(json['media'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MediaDataChangeNotificationToJson(
        MediaDataChangeNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'createdAt': instance.createdAt,
      'isRead': instance.isRead,
      'mediaId': instance.mediaId,
      'context': instance.context,
      'reason': instance.reason,
      'media': instance.media,
    };

MediaMergeNotification _$MediaMergeNotificationFromJson(
        Map<String, dynamic> json) =>
    MediaMergeNotification(
      id: (json['id'] as num).toInt(),
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      createdAt: (json['createdAt'] as num).toInt(),
      isRead: json['isRead'] as bool? ?? false,
      mediaId: (json['mediaId'] as num).toInt(),
      deletedMediaTitles: (json['deletedMediaTitles'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      context: json['context'] as String?,
      reason: json['reason'] as String?,
      media: json['media'] == null
          ? null
          : MediaInfo.fromJson(json['media'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MediaMergeNotificationToJson(
        MediaMergeNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'createdAt': instance.createdAt,
      'isRead': instance.isRead,
      'mediaId': instance.mediaId,
      'deletedMediaTitles': instance.deletedMediaTitles,
      'context': instance.context,
      'reason': instance.reason,
      'media': instance.media,
    };

MediaDeletionNotification _$MediaDeletionNotificationFromJson(
        Map<String, dynamic> json) =>
    MediaDeletionNotification(
      id: (json['id'] as num).toInt(),
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      createdAt: (json['createdAt'] as num).toInt(),
      isRead: json['isRead'] as bool? ?? false,
      deletedMediaTitle: json['deletedMediaTitle'] as String?,
      context: json['context'] as String?,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$MediaDeletionNotificationToJson(
        MediaDeletionNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'createdAt': instance.createdAt,
      'isRead': instance.isRead,
      'deletedMediaTitle': instance.deletedMediaTitle,
      'context': instance.context,
      'reason': instance.reason,
    };

MediaInfo _$MediaInfoFromJson(Map<String, dynamic> json) => MediaInfo(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String?,
      coverImage: json['coverImage'] as String?,
      type: json['type'] as String?,
      format: json['format'] as String?,
      episodes: (json['episodes'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MediaInfoToJson(MediaInfo instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'coverImage': instance.coverImage,
      'type': instance.type,
      'format': instance.format,
      'episodes': instance.episodes,
    };
