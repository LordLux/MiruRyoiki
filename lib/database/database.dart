// database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:miruryoiki/database/converters.dart';
import '../models/metadata.dart';
import '../models/mkv_metadata.dart';
import '../models/notification.dart';
import '../utils/path_utils.dart';
import 'tables.dart';
import 'daos/series_dao.dart';
import 'daos/episodes_dao.dart';
import 'daos/watch_dao.dart';
import 'daos/notifications_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    SeriesTable,
    SeasonsTable,
    EpisodesTable,
    AnilistMappingsTable,
    WatchRecordsTable,
    NotificationsTable,
  ],
  daos: [
    SeriesDao,
    EpisodesDao,
    WatchDao,
    NotificationsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? db]) : super(db ?? _openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // indexes
          await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_series_path ON series_table(path);');
          await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_seasons_series_id ON seasons_table(series_id);');
          await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_episodes_season_id ON episodes_table(season_id);');
          await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_episodes_path ON episodes_table(path);');
          await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_anilist_mappings_series_id ON anilist_mappings_table(series_id);');
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
            // recreate the indexes in case we skipped onCreate
            await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_series_path ON series_table(path);');
            await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_seasons_series_id ON seasons_table(series_id);');
            await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_episodes_season_id ON episodes_table(season_id);');
            await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_episodes_path ON episodes_table(path);');
            await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_anilist_mappings_series_id ON anilist_mappings_table(series_id);');
          }
          if (from < 4) {
            await m.addColumn(episodesTable, episodesTable.metadata);
            await m.addColumn(episodesTable, episodesTable.mkvMetadata);
          }
          if (from < 5) {
            await m.alterTable(TableMigration(seriesTable));
          }
          if (from < 6) {
            await m.createTable(notificationsTable);
            await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);');
            await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);');
            await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);');
          }
        },
        beforeOpen: (details) async {
          // if (details.wasCreated) {}
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final saveDirPath = PathString(miruRyoikiSaveDirectory.path);
    final file = File('${saveDirPath.path}${Platform.pathSeparator}miruryoiki.db');
    return NativeDatabase.createInBackground(file);
  });
}
