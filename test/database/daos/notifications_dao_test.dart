import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/database/database.dart';
import 'package:miruryoiki/database/daos/notifications_dao.dart';
import 'package:miruryoiki/models/notification.dart';

AiringNotification _makeAiring({
  int id = 1,
  int createdAt = 1000,
  bool isRead = false,
  int animeId = 42,
  int episode = 3,
}) {
  return AiringNotification(
    id: id,
    type: NotificationType.AIRING,
    createdAt: createdAt,
    isRead: isRead,
    animeId: animeId,
    episode: episode,
    contexts: const [],
  );
}

MediaDeletionNotification _makeDeletion({int id = 2, int createdAt = 2000}) {
  return MediaDeletionNotification(
    id: id,
    type: NotificationType.MEDIA_DELETION,
    createdAt: createdAt,
    deletedMediaTitle: 'Deleted Show',
  );
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('upsertNotification then getAllNotifications round-trips an AiringNotification', () async {
    await db.notificationsDao.upsertNotification(_makeAiring());

    final all = await db.notificationsDao.getAllNotifications();

    expect(all, hasLength(1));
    final parsed = NotificationsDao.dataToNotification(all.single);
    expect(parsed, isA<AiringNotification>());
    expect((parsed as AiringNotification).animeId, 42);
    expect(parsed.episode, 3);
  });

  test('getAllNotifications orders newest (createdAt) first', () async {
    await db.notificationsDao.upsertNotification(_makeAiring(id: 1, createdAt: 1000));
    await db.notificationsDao.upsertNotification(_makeDeletion(id: 2, createdAt: 2000));

    final all = await db.notificationsDao.getAllNotifications();

    expect(all.map((n) => n.id), [2, 1]);
  });

  test('getRecentNotifications respects the limit', () async {
    for (var i = 1; i <= 5; i++) {
      await db.notificationsDao.upsertNotification(_makeAiring(id: i, createdAt: i * 1000));
    }

    final recent = await db.notificationsDao.getRecentNotifications(limit: 2);

    expect(recent, hasLength(2));
    expect(recent.map((n) => n.id), [5, 4]);
  });

  test('getUnreadCount counts only unread rows', () async {
    await db.notificationsDao.upsertNotification(_makeAiring(id: 1, isRead: false));
    await db.notificationsDao.upsertNotification(_makeAiring(id: 2, isRead: true, createdAt: 1001));

    expect(await db.notificationsDao.getUnreadCount(), 1);
  });

  test('markAsRead flips isRead for a single notification', () async {
    await db.notificationsDao.upsertNotification(_makeAiring(id: 1));

    await db.notificationsDao.markAsRead(1);

    final all = await db.notificationsDao.getAllNotifications();
    expect(all.single.isRead, isTrue);
  });

  test('markAllAsRead flips isRead for every notification', () async {
    await db.notificationsDao.upsertNotification(_makeAiring(id: 1));
    await db.notificationsDao.upsertNotification(_makeDeletion(id: 2, createdAt: 1001));

    await db.notificationsDao.markAllAsRead();

    final all = await db.notificationsDao.getAllNotifications();
    expect(all.every((n) => n.isRead), isTrue);
  });

  test('upsertNotification on an existing id updates rather than duplicating', () async {
    await db.notificationsDao.upsertNotification(_makeAiring(id: 1, episode: 1));
    await db.notificationsDao.upsertNotification(_makeAiring(id: 1, episode: 2));

    final all = await db.notificationsDao.getAllNotifications();
    expect(all, hasLength(1));
    expect((NotificationsDao.dataToNotification(all.single) as AiringNotification).episode, 2);
  });

  test('upsertNotifications (batch) preserves existing read status via COALESCE', () async {
    await db.notificationsDao.upsertNotification(_makeAiring(id: 1, isRead: false));
    await db.notificationsDao.markAsRead(1);

    // Re-sync the same notification id from a fresh AniList fetch (isRead: false upstream).
    await db.notificationsDao.upsertNotifications([_makeAiring(id: 1, isRead: false)]);

    final all = await db.notificationsDao.getAllNotifications();
    expect(all.single.isRead, isTrue, reason: 'batch upsert must not clobber the local read flag');
  });

  test('getNotificationsByType filters by NotificationType', () async {
    await db.notificationsDao.upsertNotification(_makeAiring(id: 1));
    await db.notificationsDao.upsertNotification(_makeDeletion(id: 2, createdAt: 1001));

    final airing = await db.notificationsDao.getNotificationsByType(NotificationType.AIRING);

    expect(airing.map((n) => n.id), [1]);
  });

  test('getNotificationsByIds returns only requested ids, empty list short-circuits', () async {
    await db.notificationsDao.upsertNotification(_makeAiring(id: 1));
    await db.notificationsDao.upsertNotification(_makeDeletion(id: 2, createdAt: 1001));
    await db.notificationsDao.upsertNotification(_makeAiring(id: 3, createdAt: 1002));

    expect((await db.notificationsDao.getNotificationsByIds([])), isEmpty);
    final some = await db.notificationsDao.getNotificationsByIds([1, 3]);
    expect(some.map((n) => n.id), containsAll([1, 3]));
    expect(some, hasLength(2));
  });

  test('clearAllNotifications removes every row', () async {
    await db.notificationsDao.upsertNotification(_makeAiring(id: 1));
    await db.notificationsDao.upsertNotification(_makeDeletion(id: 2, createdAt: 1001));

    await db.notificationsDao.clearAllNotifications();

    expect(await db.notificationsDao.getAllNotifications(), isEmpty);
  });

  test('clearNotificationsByTypes removes only matching types', () async {
    await db.notificationsDao.upsertNotification(_makeAiring(id: 1));
    await db.notificationsDao.upsertNotification(_makeDeletion(id: 2, createdAt: 1001));

    await db.notificationsDao.clearNotificationsByTypes([NotificationType.AIRING]);

    final all = await db.notificationsDao.getAllNotifications();
    expect(all.map((n) => n.id), [2]);
  });

  test('deleteOldNotifications keeps only the newest keepCount rows', () async {
    for (var i = 1; i <= 5; i++) {
      await db.notificationsDao.upsertNotification(_makeAiring(id: i, createdAt: i * 1000));
    }

    final deleted = await db.notificationsDao.deleteOldNotifications(keepCount: 2);

    expect(deleted, 3);
    final remaining = await db.notificationsDao.getAllNotifications();
    expect(remaining.map((n) => n.id), containsAll([4, 5]));
    expect(remaining, hasLength(2));
  });
}
