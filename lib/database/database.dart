// database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:miruryoiki/database/converters.dart';
import '../utils/path_utils.dart';
import 'tables.dart';
import 'daos/series_dao.dart';
import 'daos/episodes_dao.dart';
import 'daos/watch_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    SeriesTable,
    SeasonsTable,
    EpisodesTable,
    AnilistMappingsTable,
    WatchRecordsTable,
  ],
  daos: [
    SeriesDao,
    EpisodesDao,
    WatchDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // future migrations here
        },
        beforeOpen: (details) async {
          if (details.wasCreated) {
            // init default data if needed
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final saveDirPath = PathString(miruRyoiokiSaveDirectory.path);
    final file = File('${saveDirPath.path}${Platform.pathSeparator}miruryoiki.db');
    return NativeDatabase.createInBackground(file);
  });
}
