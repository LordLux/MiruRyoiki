// migrations.dart
import 'package:drift/drift.dart';
import 'database.dart';

// Mechanical extraction of database.dart's inline onUpgrade if-chain into one
// named function per version step. Same logic, same behavior as before the
// extraction — including the fragile string-matching idempotency checks and
// the destructive drop in _v1to2. Do not "fix" those here; see the tech debt
// audit memory (tech_debt_audit_phases.md, Phase 2) for context.
//
// Table getters (seasonsTable, episodesTable, ...) are generated instance
// members on AppDatabase, not free-standing globals, so each step takes the
// db alongside the Migrator.

Future<void> _v1to2(Migrator m, AppDatabase db) async {
  // Droppa e ricrea le tabelle affette
  await m.drop(db.seasonsTable);
  await m.drop(db.episodesTable);
  await m.drop(db.anilistMappingsTable);
  // Ricrea tutto da zero
  await m.createAll();
}

Future<void> _v2to3(Migrator m) async {
  // recreate the indexes in case we skipped onCreate
  await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_series_path ON series_table(path);');
  await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_seasons_series_id ON seasons_table(series_id);');
  await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_episodes_season_id ON episodes_table(season_id);');
  await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_episodes_path ON episodes_table(path);');
  await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_anilist_mappings_series_id ON anilist_mappings_table(series_id);');
}

Future<void> _v3to4(Migrator m, AppDatabase db) async {
  await m.addColumn(db.episodesTable, db.episodesTable.metadata);
  await m.addColumn(db.episodesTable, db.episodesTable.mkvMetadata);
}

Future<void> _v4to5(Migrator m, AppDatabase db) async {
  await m.alterTable(TableMigration(db.seriesTable));
}

Future<void> _v5to6(Migrator m, AppDatabase db) async {
  await m.createTable(db.notificationsTable);
  await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);');
  await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);');
  await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);');
}

Future<void> _v6to7(Migrator m) async {
  // Add customListName column for unlinked series custom list selection
  try {
    await m.issueCustomQuery('ALTER TABLE series_table ADD COLUMN custom_list_name TEXT;');
  } catch (e) {
    // Column might already exist if migration was interrupted, ignore error
    if (!e.toString().contains('duplicate column name')) rethrow;
  }
}

Future<void> _v7to8(Migrator m) async {
  // Add anilistTitle column for episode titles from AniList
  try {
    await m.issueCustomQuery('ALTER TABLE episodes_table ADD COLUMN anilist_title TEXT;');
  } catch (e) {
    // Column might already exist if migration was interrupted, ignore error
    if (!e.toString().contains('duplicate column name')) rethrow;
  }
}

Future<void> _v8to9(Migrator m) async {
  // Add format column to notifications table for anime format (MOVIE, TV, OVA, etc.)
  try {
    await m.issueCustomQuery('ALTER TABLE notifications ADD COLUMN format TEXT;');
  } catch (e) {
    // Column might already exist if migration was interrupted, ignore error
    if (!e.toString().contains('duplicate column name')) rethrow;
  }
}

Future<void> _v9to10(Migrator m) async {
  // Rename dominant_color to local_poster_color and add local_banner_color in series_table
  // Add poster_color and banner_color columns to anilist_mappings_table
  try {
    await m.issueCustomQuery('ALTER TABLE series_table RENAME COLUMN dominant_color TO local_poster_color;');
  } catch (e) {
    // Column might already be renamed if migration was interrupted, ignore error
    if (!e.toString().contains('no such column') && !e.toString().contains('duplicate column name')) rethrow;
  }

  try {
    await m.issueCustomQuery('ALTER TABLE series_table ADD COLUMN local_banner_color TEXT;');
  } catch (e) {
    // Column might already exist if migration was interrupted, ignore error
    if (!e.toString().contains('duplicate column name')) rethrow;
  }

  try {
    await m.issueCustomQuery('ALTER TABLE anilist_mappings_table ADD COLUMN poster_color TEXT;');
  } catch (e) {
    // Column might already exist if migration was interrupted, ignore error
    if (!e.toString().contains('duplicate column name')) rethrow;
  }

  try {
    await m.issueCustomQuery('ALTER TABLE anilist_mappings_table ADD COLUMN banner_color TEXT;');
  } catch (e) {
    // Column might already exist if migration was interrupted, ignore error
    if (!e.toString().contains('duplicate column name')) rethrow;
  }
}

Future<void> _v10to11(Migrator m, AppDatabase db) async {
  // Add Anilist mutations queue and user cache tables
  await m.createTable(db.anilistMutationsTable);
  await m.createTable(db.anilistUserCacheTable);

  // Create indexes for efficient querying
  await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_mutations_media_id ON anilist_mutations(media_id);');
  await m.issueCustomQuery('CREATE INDEX IF NOT EXISTS idx_mutations_created_at ON anilist_mutations(created_at ASC);');
}

Future<void> _v11to12(Migrator m, AppDatabase db) async {
  await m.createTable(db.settingsTable);
  try {
    await m.addColumn(db.anilistMappingsTable, db.anilistMappingsTable.viewType);
  } catch (e) {
    // Column might already exist if migration was interrupted, ignore error
    if (!e.toString().contains('duplicate column name')) rethrow;
  }
}

Future<void> _v12to13(Migrator m) async {
  // Add episodeNumber and parsedTitle columns to episodes_table
  try {
    await m.issueCustomQuery('ALTER TABLE episodes_table ADD COLUMN episode_number INTEGER;');
  } catch (e) {
    if (!e.toString().contains('duplicate column name')) rethrow;
  }
  try {
    await m.issueCustomQuery('ALTER TABLE episodes_table ADD COLUMN parsed_title TEXT;');
  } catch (e) {
    if (!e.toString().contains('duplicate column name')) rethrow;
  }
}

Future<void> runUpgradeMigrations(Migrator m, AppDatabase db, int from, int to) async {
  if (from < 2) await _v1to2(m, db);
  if (from < 3) await _v2to3(m);
  if (from < 4) await _v3to4(m, db);
  if (from < 5) await _v4to5(m, db);
  if (from < 6) await _v5to6(m, db);
  if (from < 7) await _v6to7(m);
  if (from < 8) await _v7to8(m);
  if (from < 9) await _v8to9(m);
  if (from < 10) await _v9to10(m);
  if (from < 11) await _v10to11(m, db);
  if (from < 12) await _v11to12(m, db);
  if (from < 13) await _v12to13(m);
}
