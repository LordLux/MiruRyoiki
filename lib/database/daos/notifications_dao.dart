// notifications_dao.dart
import 'dart:convert';
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';
import '../../models/notification.dart';

part 'notifications_dao.g.dart';

@DriftAccessor(tables: [NotificationsTable])
class NotificationsDao extends DatabaseAccessor<AppDatabase> with _$NotificationsDaoMixin {
  NotificationsDao(AppDatabase db) : super(db);

  // Get all notifications, ordered by creation time (newest first)
  Future<List<NotificationsTableData>> getAllNotifications() {
    return (select(notificationsTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  // Get recent notifications (last N notifications)
  Future<List<NotificationsTableData>> getRecentNotifications({int limit = 5}) {
    return (select(notificationsTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .get();
  }

  // Get unread notifications count
  Future<int> getUnreadCount() async {
    final countQuery = selectOnly(notificationsTable)
      ..addColumns([notificationsTable.id.count()])
      ..where(notificationsTable.isRead.equals(false));
    
    final result = await countQuery.getSingle();
    return result.read(notificationsTable.id.count()) ?? 0;
  }

  // Get notifications by type
  Future<List<NotificationsTableData>> getNotificationsByType(NotificationType type) {
    return (select(notificationsTable)
          ..where((t) => t.type.equals(type.index))
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  // Mark notification as read
  Future<int> markAsRead(int notificationId) {
    return (update(notificationsTable)
          ..where((t) => t.id.equals(notificationId)))
        .write(NotificationsTableCompanion(
      isRead: const Value(true),
      localUpdatedAt: Value(DateTime.now()),
    ));
  }

  // Mark all notifications as read
  Future<int> markAllAsRead() {
    return (update(notificationsTable)..where((t) => t.isRead.equals(false)))
        .write(NotificationsTableCompanion(
      isRead: const Value(true),
      localUpdatedAt: Value(DateTime.now()),
    ));
  }

  // Insert or update notification (upsert based on Anilist notification ID)
  Future<void> upsertNotification(AnilistNotification notification) async {
    final companion = _notificationToCompanion(notification);
    
    await into(notificationsTable).insertOnConflictUpdate(companion);
  }

  // Batch insert/update notifications (preserves local read status)
  Future<void> upsertNotifications(List<AnilistNotification> notifications) async {
    // Use custom SQL to preserve read status
    await transaction(() async {
      for (final notification in notifications) {
        await customStatement(
          'INSERT OR REPLACE INTO notifications (id, type, created_at, is_read, anime_id, episode, contexts, media_id, context, reason, deleted_media_titles, deleted_media_title, media_info, local_created_at, local_updated_at) '
          'VALUES (?, ?, ?, COALESCE((SELECT is_read FROM notifications WHERE id = ?), ?), ?, ?, ?, ?, ?, ?, ?, ?, ?, datetime("now"), datetime("now"))',
          [
            Variable(notification.id),
            Variable(notification.type.index), 
            Variable(notification.createdAt),
            Variable(notification.id), // For the COALESCE subquery
            Variable(notification.isRead), // Default value if not exists
            Variable(_getAnimeId(notification)),
            Variable(_getEpisode(notification)),
            Variable(_getContexts(notification)),
            Variable(_getMediaId(notification)),
            Variable(_getContext(notification)),
            Variable(_getReason(notification)),
            Variable(_getDeletedMediaTitles(notification)),
            Variable(_getDeletedMediaTitle(notification)),
            Variable(_getMediaInfo(notification)),
          ],
        );
      }
    });
  }

  // Helper methods to extract fields from notifications
  int? _getAnimeId(AnilistNotification notification) {
    return notification is AiringNotification ? notification.animeId : null;
  }

  int? _getEpisode(AnilistNotification notification) {
    return notification is AiringNotification ? notification.episode : null;
  }

  String? _getContexts(AnilistNotification notification) {
    if (notification is AiringNotification) {
      return notification.contexts.isEmpty ? null : jsonEncode(notification.contexts);
    }
    return null;
  }

  int? _getMediaId(AnilistNotification notification) {
    switch (notification) {
      case MediaDataChangeNotification dataChange:
        return dataChange.mediaId;
      case MediaMergeNotification merge:
        return merge.mediaId;
      default:
        return null;
    }
  }

  String? _getContext(AnilistNotification notification) {
    switch (notification) {
      case MediaDataChangeNotification dataChange:
        return dataChange.context;
      case MediaMergeNotification merge:
        return merge.context;
      case MediaDeletionNotification deletion:
        return deletion.context;
      default:
        return null;
    }
  }

  String? _getReason(AnilistNotification notification) {
    switch (notification) {
      case MediaDataChangeNotification dataChange:
        return dataChange.reason;
      case MediaMergeNotification merge:
        return merge.reason;
      case MediaDeletionNotification deletion:
        return deletion.reason;
      default:
        return null;
    }
  }

  String? _getDeletedMediaTitles(AnilistNotification notification) {
    if (notification is MediaMergeNotification) {
      return notification.deletedMediaTitles.isEmpty ? null : jsonEncode(notification.deletedMediaTitles);
    }
    return null;
  }

  String? _getDeletedMediaTitle(AnilistNotification notification) {
    return notification is MediaDeletionNotification ? notification.deletedMediaTitle : null;
  }

  String? _getMediaInfo(AnilistNotification notification) {
    final media = switch (notification) {
      AiringNotification airing => airing.media,
      MediaDataChangeNotification dataChange => dataChange.media,
      MediaMergeNotification merge => merge.media,
      MediaDeletionNotification _ => null,
      _ => null,
    };
    return media != null ? jsonEncode(media.toJson()) : null;
  }

  // Delete old notifications (keep only recent N notifications)
  Future<int> deleteOldNotifications({int keepCount = 100}) async {
    final oldNotifications = await (select(notificationsTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ])
          ..limit(-1, offset: keepCount))
        .get();

    if (oldNotifications.isEmpty) return 0;

    final idsToDelete = oldNotifications.map((n) => n.id).toList();
    return (delete(notificationsTable)..where((t) => t.id.isIn(idsToDelete))).go();
  }

  // Convert AnilistNotification to database companion
  NotificationsTableCompanion _notificationToCompanion(AnilistNotification notification) {
    switch (notification) {
      case AiringNotification airing:
        return NotificationsTableCompanion.insert(
          id: Value(airing.id),
          type: airing.type,
          createdAt: airing.createdAt,
          isRead: Value(airing.isRead),
          animeId: Value(airing.animeId),
          episode: Value(airing.episode),
          contexts: Value(airing.contexts),
          mediaInfo: Value(airing.media),
        );
      case MediaDataChangeNotification dataChange:
        return NotificationsTableCompanion.insert(
          id: Value(dataChange.id),
          type: dataChange.type,
          createdAt: dataChange.createdAt,
          isRead: Value(dataChange.isRead),
          mediaId: Value(dataChange.mediaId),
          context: Value(dataChange.context),
          reason: Value(dataChange.reason),
          mediaInfo: Value(dataChange.media),
        );
      case MediaMergeNotification merge:
        return NotificationsTableCompanion.insert(
          id: Value(merge.id),
          type: merge.type,
          createdAt: merge.createdAt,
          isRead: Value(merge.isRead),
          mediaId: Value(merge.mediaId),
          context: Value(merge.context),
          reason: Value(merge.reason),
          deletedMediaTitles: Value(merge.deletedMediaTitles),
          mediaInfo: Value(merge.media),
        );
      case MediaDeletionNotification deletion:
        return NotificationsTableCompanion.insert(
          id: Value(deletion.id),
          type: deletion.type,
          createdAt: deletion.createdAt,
          isRead: Value(deletion.isRead),
          deletedMediaTitle: Value(deletion.deletedMediaTitle),
          context: Value(deletion.context),
          reason: Value(deletion.reason),
        );
      default:
        throw UnimplementedError('Unknown notification type: ${notification.runtimeType}');
    }
  }

  // Convert database row to AnilistNotification
  static AnilistNotification? dataToNotification(NotificationsTableData data) {
    switch (data.type) {
      case NotificationType.AIRING:
        return AiringNotification(
          id: data.id,
          type: data.type,
          createdAt: data.createdAt,
          isRead: data.isRead,
          animeId: data.animeId ?? 0,
          episode: data.episode ?? 0,
          contexts: data.contexts ?? [],
          media: data.mediaInfo,
        );
      case NotificationType.MEDIA_DATA_CHANGE:
        return MediaDataChangeNotification(
          id: data.id,
          type: data.type,
          createdAt: data.createdAt,
          isRead: data.isRead,
          mediaId: data.mediaId ?? 0,
          context: data.context,
          reason: data.reason,
          media: data.mediaInfo,
        );
      case NotificationType.MEDIA_MERGE:
        return MediaMergeNotification(
          id: data.id,
          type: data.type,
          createdAt: data.createdAt,
          isRead: data.isRead,
          mediaId: data.mediaId ?? 0,
          deletedMediaTitles: data.deletedMediaTitles ?? [],
          context: data.context,
          reason: data.reason,
          media: data.mediaInfo,
        );
      case NotificationType.MEDIA_DELETION:
        return MediaDeletionNotification(
          id: data.id,
          type: data.type,
          createdAt: data.createdAt,
          isRead: data.isRead,
          deletedMediaTitle: data.deletedMediaTitle,
          context: data.context,
          reason: data.reason,
        );
    }
  }
}
