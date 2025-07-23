// daos/watch_dao.dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'watch_dao.g.dart';

@DriftAccessor(tables: [WatchRecordsTable])
class WatchDao extends DatabaseAccessor<AppDatabase> with _$WatchDaoMixin {
  WatchDao(AppDatabase db) : super(db);

  Future<int> recordWatchEvent(
    String filePath,
    double position,
    double duration,
  ) {
    return into(watchRecordsTable).insert(
      WatchRecordsTableCompanion.insert(
        filePath: filePath,
        position: position,
        duration: duration,
      ),
    );
  }

  Future<WatchRecordsTableData?> getLatestWatchRecord(String filePath) {
    return (select(watchRecordsTable)
          ..where((t) => t.filePath.equals(filePath))
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)])
          ..limit(1)) //
        .getSingleOrNull();
  }

  Future<List<WatchRecordsTableData>> getWatchRecordsForFile(String filePath) {
    return (select(watchRecordsTable)
          ..where((t) => t.filePath.equals(filePath))
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)]))
        .get();
  }

  /// Keep only last 10 per file
  // Future<int> cleanupOldWatchRecords() async {
  //   final files = await customSelect(
  //     'SELECT DISTINCT file_path FROM watch_records_table',
  //   ).get();

  //   int deleted = 0;
  //   for (final row in files) {
  //     final filePath = row.data['file_path'] as String;
  //     final recs = await (select(watchRecordsTable)
  //           ..where((t) => t.filePath.equals(filePath))
  //           ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)]))
  //         .get();
  //     if (recs.length > 10) {
  //       final toDelete = recs.sublist(10);
  //       for (final r in toDelete) //
  //         deleted += await (delete(watchRecordsTable)..where((t) => t.id.equals(r.id))).go();
  //     }
  //   }
  //   return deleted;
  // }
}
