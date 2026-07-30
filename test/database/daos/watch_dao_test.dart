import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('getLatestWatchRecord returns null when no record exists for the path', () async {
    expect(await db.watchDao.getLatestWatchRecord(r'M:\Series\Test\ep1.mkv'), isNull);
  });

  test('recordWatchEvent then getLatestWatchRecord returns the recorded values', () async {
    await db.watchDao.recordWatchEvent(r'M:\Series\Test\ep1.mkv', 120.0, 1440.0);

    final record = await db.watchDao.getLatestWatchRecord(r'M:\Series\Test\ep1.mkv');

    expect(record, isNotNull);
    expect(record!.position, 120.0);
    expect(record.duration, 1440.0);
  });

  test('getLatestWatchRecord returns the most recent of several records for the same file', () async {
    // Insert directly with explicit timestamps — recordWatchEvent relies on
    // currentDateAndTime (second precision), which two same-test inserts can tie on.
    final now = DateTime.now();
    await db.into(db.watchRecordsTable).insert(WatchRecordsTableCompanion.insert(
          filePath: r'M:\Series\Test\ep1.mkv',
          position: 10.0,
          duration: 1440.0,
          timestamp: Value(now.subtract(const Duration(minutes: 5))),
        ));
    await db.into(db.watchRecordsTable).insert(WatchRecordsTableCompanion.insert(
          filePath: r'M:\Series\Test\ep1.mkv',
          position: 500.0,
          duration: 1440.0,
          timestamp: Value(now),
        ));

    final record = await db.watchDao.getLatestWatchRecord(r'M:\Series\Test\ep1.mkv');

    expect(record!.position, 500.0);
  });

  test('getWatchRecordsForFile returns only records for the requested path, newest first', () async {
    final now = DateTime.now();
    Future<void> insert(String path, double position, DateTime timestamp) => db.into(db.watchRecordsTable).insert(WatchRecordsTableCompanion.insert(
          filePath: path,
          position: position,
          duration: 100.0,
          timestamp: Value(timestamp),
        ));

    await insert(r'M:\Series\A\ep1.mkv', 10.0, now.subtract(const Duration(minutes: 5)));
    await insert(r'M:\Series\A\ep1.mkv', 20.0, now);
    await insert(r'M:\Series\B\ep1.mkv', 5.0, now);

    final records = await db.watchDao.getWatchRecordsForFile(r'M:\Series\A\ep1.mkv');

    expect(records, hasLength(2));
    expect(records.first.position, 20.0);
    expect(records.last.position, 10.0);
  });
}
