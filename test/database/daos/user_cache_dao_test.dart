import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/database/database.dart';
import 'package:miruryoiki/models/anilist/user_list.dart';

AnilistUser _makeUser({int id = 1, String name = 'LordLux', String? avatar}) {
  return AnilistUser(id: id, name: name, avatar: avatar);
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('getCachedUser returns null when nothing is cached', () async {
    expect(await db.userCacheDao.getCachedUser(), isNull);
  });

  test('hasCachedUser is false before any upsert and true after', () async {
    expect(await db.userCacheDao.hasCachedUser(), isFalse);

    await db.userCacheDao.upsertUser(_makeUser());

    expect(await db.userCacheDao.hasCachedUser(), isTrue);
  });

  test('upsertUser then getCachedUser round-trips id/name/avatar', () async {
    await db.userCacheDao.upsertUser(_makeUser(id: 7, name: 'Test User', avatar: 'http://example.com/a.png'));

    final cached = await db.userCacheDao.getCachedUser();

    expect(cached, isNotNull);
    expect(cached!.id, 7);
    expect(cached.name, 'Test User');
    expect(cached.avatar, 'http://example.com/a.png');
  });

  test('upsertUser replaces the previous cached user rather than adding a second row', () async {
    await db.userCacheDao.upsertUser(_makeUser(id: 1, name: 'First'));
    await db.userCacheDao.upsertUser(_makeUser(id: 2, name: 'Second'));

    final cached = await db.userCacheDao.getCachedUser();

    expect(cached!.id, 2);
    expect(cached.name, 'Second');
  });

  test('deleteCachedUser clears the cache', () async {
    await db.userCacheDao.upsertUser(_makeUser());
    await db.userCacheDao.deleteCachedUser();

    expect(await db.userCacheDao.getCachedUser(), isNull);
    expect(await db.userCacheDao.hasCachedUser(), isFalse);
  });

  test('getCacheTimestamp is null before caching and non-null after', () async {
    expect(await db.userCacheDao.getCacheTimestamp(), isNull);

    await db.userCacheDao.upsertUser(_makeUser());

    expect(await db.userCacheDao.getCacheTimestamp(), isNotNull);
  });
}
