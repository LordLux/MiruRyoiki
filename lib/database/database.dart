// database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:miruryoiki/database/converters.dart';
import '../models/metadata.dart';
import '../models/mkv_metadata.dart';
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
  AppDatabase([QueryExecutor? db]) : super(db ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // indexes
          await m.issueCustomQuery('CREATE INDEX idx_series_path       ON series_table(path);');
          await m.issueCustomQuery('CREATE INDEX idx_seasons_series_id ON seasons_table(series_id);');
          await m.issueCustomQuery('CREATE INDEX idx_episodes_season_id ON episodes_table(season_id);');
          await m.issueCustomQuery('CREATE INDEX idx_episodes_path      ON episodes_table(path);');
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Droppa e ricrea le tabelle affette
            await m.drop(seasonsTable);
            await m.drop(episodesTable);
            await m.drop(anilistMappingsTable);
            // Ricrea tutto da zero
            await m.createAll();
          }
          if (from < 3) {
            // add our new column
            await m.addColumn(seriesTable, seriesTable.metadataHash);
            // recreate the indexes in case we skipped onCreate
            await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_series_path ON series_table(path);');
            // …and the others, same pattern…
          }
          if (from < 4) {
            await m.addColumn(episodesTable, episodesTable.metadata);
            await m.addColumn(episodesTable, episodesTable.mkvMetadata);
          }
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
