import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [SettingsTable])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> get(String key) async {
    final row = await (select(settingsTable)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> set(String key, String value) async {
    await into(settingsTable).insertOnConflictUpdate(SettingsTableCompanion(
      key: Value(key),
      value: Value(value),
    ));
  }

  Future<Map<String, String>> getAll() async {
    final rows = await select(settingsTable).get();
    return {for (var row in rows) row.key: row.value};
  }
}
