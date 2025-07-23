// tables.dart
import 'package:drift/drift.dart';
import 'converters.dart';

// ------------------ SERIES ------------------
class SeriesTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();
  TextColumn get path => text().map(const PathStringConverter())();

  TextColumn get folderPosterPath => text().map(const PathStringConverter()).nullable()();
  TextColumn get folderBannerPath => text().map(const PathStringConverter()).nullable()();

  IntColumn get primaryAnilistId => integer().nullable()();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();

  // JSON color
  TextColumn get dominantColor => text().nullable()();

  // Preferred sources + cached URLs
  TextColumn get preferredPosterSource => text().nullable()();
  TextColumn get preferredBannerSource => text().nullable()();
  TextColumn get anilistPosterUrl => text().nullable()();
  TextColumn get anilistBannerUrl => text().nullable()();

  // Watched %
  RealColumn get watchedPercentage => real().withDefault(const Constant(0.0))();

  // timestamps
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => ['UNIQUE (path)'];
}

// ------------------ SEASON ------------------
class SeasonsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get seriesId => integer().references(SeriesTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get path => text().map(const PathStringConverter())();

  @override
  List<String> get customConstraints => [
        'UNIQUE (seriesId, name)' // evita duplicati "Season 1"
      ];
}

// ------------------ EPISODE ------------------
class EpisodesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get seasonId => integer().references(SeasonsTable, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text()();
  TextColumn get path => text().map(const PathStringConverter())();

  TextColumn get thumbnailPath => text().map(const PathStringConverter()).nullable()();

  BoolColumn get watched => boolean().withDefault(const Constant(false))();
  RealColumn get watchedPercentage => real().withDefault(const Constant(0.0))();
  BoolColumn get thumbnailUnavailable => boolean().withDefault(const Constant(false))();

  @override
  List<String> get customConstraints => [
        'UNIQUE (seasonId, path)' // path è unico comunque, ma per sicurezza
      ];
}

// ------------------ ANILIST MAPPINGS ------------------
class AnilistMappingsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get seriesId => integer().references(SeriesTable, #id, onDelete: KeyAction.cascade)();

  TextColumn get localPath => text().map(const PathStringConverter())();

  IntColumn get anilistId => integer()();

  TextColumn get title => text().nullable()();

  DateTimeColumn get lastSynced => dateTime().nullable()();

  // JSON cached data
  TextColumn get anilistData => text().nullable()();

  @override
  List<String> get customConstraints => ['UNIQUE (seriesId, anilistId)'];
}

// ------------------ WATCH RECORDS ------------------
class WatchRecordsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get filePath => text()();
  RealColumn get position => real()();
  RealColumn get duration => real()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}
