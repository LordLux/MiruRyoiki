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

  /// Custom list name for unlinked series
  TextColumn get customListName => text().nullable()();

  // JSON colors
  TextColumn get localPosterColor => text().nullable()();
  TextColumn get localBannerColor => text().nullable()();

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
        'UNIQUE (series_id, name, path)' // evita duplicati "Season 1"
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
  
  TextColumn get metadata => text().map(const MetadataConverter()).nullable()();
  TextColumn get mkvMetadata => text().map(const MkvMetadataConverter()).nullable()();
  TextColumn get anilistTitle => text().nullable()();

  @override
  List<String> get customConstraints => [
        'UNIQUE (season_id, path)'
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
  
  // JSON colors
  TextColumn get posterColor => text().nullable()();
  TextColumn get bannerColor => text().nullable()();

  // JSON cached data
  TextColumn get anilistData => text().nullable()();

  @override
  List<String> get customConstraints => ['UNIQUE (series_id, anilist_id)'];
}

// ------------------ WATCH RECORDS ------------------
class WatchRecordsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get filePath => text()();
  RealColumn get position => real()();
  RealColumn get duration => real()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}

// ------------------ ANILIST NOTIFICATIONS ------------------
class NotificationsTable extends Table {
  IntColumn get id => integer()(); // Anilist notification ID
  IntColumn get type => integer().map(const NotificationTypeConverter())(); // NotificationType enum
  IntColumn get createdAt => integer()(); // Unix timestamp from Anilist
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  
  // AiringNotification specific fields
  IntColumn get animeId => integer().nullable()();
  IntColumn get episode => integer().nullable()();
  TextColumn get contexts => text().map(const StringListConverter()).nullable()(); // JSON array of strings
  TextColumn get format => text().nullable()(); // Anime format (TV, MOVIE, OVA, ONA, etc.)
  
  // MediaDataChangeNotification, MediaMergeNotification specific fields
  IntColumn get mediaId => integer().nullable()();
  TextColumn get context => text().nullable()();
  TextColumn get reason => text().nullable()();
  
  // MediaMergeNotification specific field
  TextColumn get deletedMediaTitles => text().map(const StringListConverter()).nullable()(); // JSON array of strings
  
  // MediaDeletionNotification specific field
  TextColumn get deletedMediaTitle => text().nullable()();
  
  // Common media info (cached)
  TextColumn get mediaInfo => text().map(const MediaInfoConverter()).nullable()(); // JSON MediaInfo object
  
  DateTimeColumn get localCreatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get localUpdatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  String get tableName => 'notifications';
  
  @override
  Set<Column> get primaryKey => {id};
}

// ------------------ ANILIST MUTATIONS QUEUE ------------------
class AnilistMutationsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  TextColumn get type => text()(); // 'progress', 'status', 'score', etc.
  IntColumn get mediaId => integer()();
  TextColumn get changes => text().map(const JsonMapConverter())(); // JSON map of changes
  
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get localCreatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  String get tableName => 'anilist_mutations';
}

// ------------------ ANILIST USER CACHE ------------------
class AnilistUserCacheTable extends Table {
  IntColumn get id => integer()(); // Anilist user ID
  TextColumn get name => text()();
  TextColumn get avatar => text().nullable()();
  TextColumn get bannerImage => text().nullable()();
  TextColumn get userData => text().map(const JsonMapConverter()).nullable()(); // JSON AnilistUserData
  
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  String get tableName => 'anilist_user_cache';
  
  @override
  Set<Column> get primaryKey => {id};
}
