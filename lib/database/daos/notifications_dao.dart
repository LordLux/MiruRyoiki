// notifications_dao.dart
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

  // Batch insert/update notifications
  Future<void> upsertNotifications(List<AnilistNotification> notifications) async {
    await batch((batch) {
      for (final notification in notifications) {
        final companion = _notificationToCompanion(notification);
        batch.insert(notificationsTable, companion, mode: InsertMode.insertOrReplace);
      }
    });
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
      default:
        return null;
    }
  }
}
