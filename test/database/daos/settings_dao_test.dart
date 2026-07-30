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

  test('get returns null for a key that was never set', () async {
    expect(await db.settingsDao.get('missing'), isNull);
  });

  test('set then get round-trips a value', () async {
    await db.settingsDao.set('theme', 'dark');
    expect(await db.settingsDao.get('theme'), 'dark');
  });

  test('set on an existing key overwrites it (insertOnConflictUpdate)', () async {
    await db.settingsDao.set('theme', 'dark');
    await db.settingsDao.set('theme', 'light');
    expect(await db.settingsDao.get('theme'), 'light');
  });

  test('getAll returns every stored key/value pair', () async {
    await db.settingsDao.set('a', '1');
    await db.settingsDao.set('b', '2');

    expect(await db.settingsDao.getAll(), {'a': '1', 'b': '2'});
  });

  test('deleteKey removes only the targeted key', () async {
    await db.settingsDao.set('a', '1');
    await db.settingsDao.set('b', '2');

    await db.settingsDao.deleteKey('a');

    expect(await db.settingsDao.getAll(), {'b': '2'});
  });
}
