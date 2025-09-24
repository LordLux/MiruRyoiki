// notifications_dao.dart
import 'dart:convert';
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';
import '../../models/notification.dart';

part 'notifications_dao.g.dart';

@DriftAccessor(tables: [NotificationsTable])
class NotificationsDao extends DatabaseAccessor<AppDatabase> with _$NotificationsDaoMixin {
  NotificationsDao(super.db);

  static bool _legacyTimestampRepairDone = false;

  Future<void> _repairLegacyCreatedAtIfNeeded() async {
    if (_legacyTimestampRepairDone) return;
    try {
      // First attempt a bulk in-sql conversion for rows stored as text.
      await customStatement(
        "UPDATE notifications SET created_at = CAST(strftime('%s', created_at) AS INTEGER) WHERE typeof(created_at)='text' AND created_at LIKE '____-__-__ __:__:__';",
      );

      // Double-check if any rows still remain as text (malformed / unexpected format) and fix them in Dart.
      final remaining = await customSelect(
        // ignore: unnecessary_string_escapes
        'SELECT id, created_at FROM notifications WHERE typeof(created_at) = \"text\"',
        readsFrom: {notificationsTable},
      ).get();

      for (final row in remaining) {
        final id = row.data['id'];
        final createdAtRaw = row.data['created_at'];
        if (createdAtRaw is String) {
          int? epoch;
          try {
            // Try common datetime parse.
            final dt = DateTime.tryParse(createdAtRaw);
            if (dt != null) {
              epoch = (dt.millisecondsSinceEpoch / 1000).floor();
            }
          } catch (_) {}
          if (epoch == null) {
            // As last resort attempt trimming / replacing 'T'
            final cleaned = createdAtRaw.replaceAll('T', ' ').split('.').first;
            final dt = DateTime.tryParse(cleaned);
            if (dt != null) epoch = (dt.millisecondsSinceEpoch / 1000).floor();
          }
          if (epoch != null) {
            await customStatement(
              'UPDATE notifications SET created_at = ? WHERE id = ?',
              [epoch, id],
            );
          }
        }
      }

  // --- Repair local_created_at / local_updated_at (DateTime columns expected as millis since epoch) ---
  // Convert text timestamps to millis
  await customStatement("UPDATE notifications SET local_created_at = (strftime('%s', local_created_at)*1000) WHERE typeof(local_created_at)='text' AND local_created_at LIKE '____-__-__ __:__:__';");
  await customStatement("UPDATE notifications SET local_updated_at = (strftime('%s', local_updated_at)*1000) WHERE typeof(local_updated_at)='text' AND local_updated_at LIKE '____-__-__ __:__:__';");
  // Convert seconds (too small) to millis
  await customStatement("UPDATE notifications SET local_created_at = local_created_at*1000 WHERE typeof(local_created_at)='integer' AND local_created_at > 0 AND local_created_at < 100000000000;\n");
  await customStatement("UPDATE notifications SET local_updated_at = local_updated_at*1000 WHERE typeof(local_updated_at)='integer' AND local_updated_at > 0 AND local_updated_at < 100000000000;\n");
    } catch (_) {
      // Ignore repair errors; continue.
    } finally {
      _legacyTimestampRepairDone = true; // prevent repeat work every call
    }
  }

  // Get all notifications, ordered by creation time (newest first)
  Future<List<NotificationsTableData>> getAllNotifications() async {
  await _repairLegacyCreatedAtIfNeeded();
  return (select(notificationsTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  // Get recent notifications (last N notifications)
  Future<List<NotificationsTableData>> getRecentNotifications({int limit = 5}) async {
  await _repairLegacyCreatedAtIfNeeded();
  return (select(notificationsTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .get();
  }

  // Get unread notifications count
  Future<int> getUnreadCount() async {
  await _repairLegacyCreatedAtIfNeeded();
    final countQuery = selectOnly(notificationsTable)
      ..addColumns([notificationsTable.id.count()])
      ..where(notificationsTable.isRead.equals(false));
    
    final result = await countQuery.getSingle();
    return result.read(notificationsTable.id.count()) ?? 0;
  }

  // Get notifications by type
  Future<List<NotificationsTableData>> getNotificationsByType(NotificationType type) async {
    await _repairLegacyCreatedAtIfNeeded();
    final query = select(notificationsTable)
      ..where((t) => t.type.equals(type.index))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]);
    return query.get();
  }

  // Get notifications for specific ids
  Future<List<NotificationsTableData>> getNotificationsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    await _repairLegacyCreatedAtIfNeeded();
    final query = select(notificationsTable)
      ..where((t) => t.id.isIn(ids))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]);
    return query.get();
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
        // customStatement expects raw serializable values (no Variable<> wrappers)
        await customStatement(
          'INSERT OR REPLACE INTO notifications (id, type, created_at, is_read, anime_id, episode, contexts, media_id, context, reason, deleted_media_titles, deleted_media_title, media_info, local_created_at, local_updated_at) '
          'VALUES (?, ?, ?, COALESCE((SELECT is_read FROM notifications WHERE id = ?), ?), ?, ?, ?, ?, ?, ?, ?, ?, ?, (strftime(\'%s\',\'now\')*1000), (strftime(\'%s\',\'now\')*1000))',
          [
            notification.id,                      // 1 id
            notification.type.index,              // 2 type
            notification.createdAt,               // 3 created_at (unix seconds)
            notification.id,                      // 4 id again for COALESCE subquery
            notification.isRead ? 1 : 0,          // 5 preserve existing is_read else default
            _getAnimeId(notification),            // 6 anime_id
            _getEpisode(notification),            // 7 episode
            _getContexts(notification),           // 8 contexts (JSON string or null)
            _getMediaId(notification),            // 9 media_id
            _getContext(notification),            // 10 context
            _getReason(notification),             // 11 reason
            _getDeletedMediaTitles(notification), // 12 deleted_media_titles (JSON string)
            _getDeletedMediaTitle(notification),  // 13 deleted_media_title
            _getMediaInfo(notification),          // 14 media_info (JSON string)
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
      case RelatedMediaAdditionNotification related:
        return related.mediaId;
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
      case RelatedMediaAdditionNotification related:
        return related.context;
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
      RelatedMediaAdditionNotification related => related.media,
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

  // Clear all notifications (force refresh from API)
  Future<int> clearAllNotifications() async => delete(notificationsTable).go();

  // Clear notifications of specific types (force refresh of problematic cached data)
  Future<int> clearNotificationsByTypes(List<NotificationType> types) async {
    if (types.isEmpty) return 0;
    final typeIndices = types.map((t) => t.index).toList();
    return (delete(notificationsTable)..where((t) => t.type.isIn(typeIndices))).go();
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
      case RelatedMediaAdditionNotification related:
        return NotificationsTableCompanion.insert(
          id: Value(related.id),
          type: related.type,
          createdAt: related.createdAt,
          isRead: Value(related.isRead),
          mediaId: Value(related.mediaId),
          context: Value(related.context),
          mediaInfo: Value(related.media),
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
      case NotificationType.RELATED_MEDIA_ADDITION:
        return RelatedMediaAdditionNotification(
          id: data.id,
          type: data.type,
          createdAt: data.createdAt,
          isRead: data.isRead,
          mediaId: data.mediaId ?? 0,
          context: data.context,
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
