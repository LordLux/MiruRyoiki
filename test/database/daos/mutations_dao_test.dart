import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/database/database.dart';
import 'package:miruryoiki/models/anilist/mutation.dart';

AnilistMutation _makeMutation({
  String type = 'progress',
  int mediaId = 1,
  Map<String, dynamic>? changes,
  DateTime? createdAt,
}) {
  return AnilistMutation(
    type: type,
    mediaId: mediaId,
    changes: changes ?? {'progress': 5},
    createdAt: createdAt,
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

  test('addMutation then getAllMutations round-trips type/mediaId/changes', () async {
    await db.mutationsDao.addMutation(_makeMutation(type: 'progress', mediaId: 42, changes: {'progress': 7}));

    final all = await db.mutationsDao.getAllMutations();

    expect(all, hasLength(1));
    expect(all.single.type, 'progress');
    expect(all.single.mediaId, 42);
    expect(all.single.changes, {'progress': 7});
  });

  test('getAllMutations orders oldest first', () async {
    final older = DateTime(2020, 1, 1);
    final newer = DateTime(2021, 1, 1);
    await db.mutationsDao.addMutation(_makeMutation(mediaId: 2, createdAt: newer));
    await db.mutationsDao.addMutation(_makeMutation(mediaId: 1, createdAt: older));

    final all = await db.mutationsDao.getAllMutations();

    expect(all.map((m) => m.mediaId), [1, 2]);
  });

  test('getMutationsForMedia filters by mediaId', () async {
    await db.mutationsDao.addMutation(_makeMutation(mediaId: 1));
    await db.mutationsDao.addMutation(_makeMutation(mediaId: 2));

    final forMedia1 = await db.mutationsDao.getMutationsForMedia(1);

    expect(forMedia1, hasLength(1));
    expect(forMedia1.single.mediaId, 1);
  });

  test('getMutationsCount reflects the number of queued mutations', () async {
    expect(await db.mutationsDao.getMutationsCount(), 0);

    await db.mutationsDao.addMutation(_makeMutation());
    await db.mutationsDao.addMutation(_makeMutation());

    expect(await db.mutationsDao.getMutationsCount(), 2);
  });

  test('deleteMutation removes only the targeted row', () async {
    final id1 = await db.mutationsDao.addMutation(_makeMutation(mediaId: 1));
    await db.mutationsDao.addMutation(_makeMutation(mediaId: 2));

    await db.mutationsDao.deleteMutation(id1);

    final remaining = await db.mutationsDao.getAllMutations();
    expect(remaining.map((m) => m.mediaId), [2]);
  });

  test('deleteMutationByProperties matches on type/mediaId/createdAt', () async {
    final createdAt = DateTime(2022, 5, 5);
    await db.mutationsDao.addMutation(_makeMutation(type: 'status', mediaId: 9, createdAt: createdAt));

    await db.mutationsDao.deleteMutationByProperties(type: 'status', mediaId: 9, createdAt: createdAt);

    expect(await db.mutationsDao.getAllMutations(), isEmpty);
  });

  test('deleteAllMutations clears the queue', () async {
    await db.mutationsDao.addMutation(_makeMutation(mediaId: 1));
    await db.mutationsDao.addMutation(_makeMutation(mediaId: 2));

    await db.mutationsDao.deleteAllMutations();

    expect(await db.mutationsDao.getAllMutations(), isEmpty);
  });
}
