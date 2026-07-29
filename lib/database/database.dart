// database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:miruryoiki/database/converters.dart';
import '../manager.dart';
import '../models/metadata.dart';
import '../models/mkv_metadata.dart';
import '../models/notification.dart';
import '../utils/path.dart';
import 'tables.dart';
import 'migrations.dart';
import 'daos/series_dao.dart';
import 'daos/episodes_dao.dart';
import 'daos/watch_dao.dart';
import 'daos/notifications_dao.dart';
import 'daos/mutations_dao.dart';
import 'daos/user_cache_dao.dart';
import 'daos/settings_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    SeriesTable,
    SeasonsTable,
    EpisodesTable,
    AnilistMappingsTable,
    WatchRecordsTable,
    NotificationsTable,
    AnilistMutationsTable,
    AnilistUserCacheTable,
    SettingsTable,
  ],
  daos: [
    SeriesDao,
    EpisodesDao,
    WatchDao,
    NotificationsDao,
    MutationsDao,
    UserCacheDao,
    SettingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? db]) : super(db ?? _openConnection());

  @override
  int get schemaVersion => 13;

  @override
  Future<void> close() async {
    Manager.isDatabaseSaving.value = true;
    try {
      await super.close();
    } finally {
      Manager.isDatabaseSaving.value = false;
    }
  }

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
          await runUpgradeMigrations(m, this, from, to);
        },
        beforeOpen: (details) async {
          // if (details.wasCreated) {}
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final saveDirPath = PathString(miruRyoikiSaveDirectory.path);
    final file = File('${saveDirPath.path}${Platform.pathSeparator}$dbFileName');
    return NativeDatabase.createInBackground(file);
  });
}

const String dbFileName = 'miruryoiki.db';
