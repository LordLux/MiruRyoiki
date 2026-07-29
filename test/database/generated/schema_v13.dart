// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class SeriesTable extends Table with TableInfo {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SeriesTable(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> folderPosterPath = GeneratedColumn<String>(
      'folder_poster_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> folderBannerPath = GeneratedColumn<String>(
      'folder_banner_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<int> primaryAnilistId = GeneratedColumn<int>(
      'primary_anilist_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
      'is_hidden', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_hidden" IN (0, 1))'),
      defaultValue: const CustomExpression('0'));
  late final GeneratedColumn<String> customListName = GeneratedColumn<String>(
      'custom_list_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> localPosterColor = GeneratedColumn<String>(
      'local_poster_color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> localBannerColor = GeneratedColumn<String>(
      'local_banner_color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> preferredPosterSource =
      GeneratedColumn<String>('preferred_poster_source', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> preferredBannerSource =
      GeneratedColumn<String>('preferred_banner_source', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> anilistPosterUrl = GeneratedColumn<String>(
      'anilist_poster_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> anilistBannerUrl = GeneratedColumn<String>(
      'anilist_banner_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<double> watchedPercentage =
      GeneratedColumn<double>('watched_percentage', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const CustomExpression('0.0'));
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
      'added_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        path,
        folderPosterPath,
        folderBannerPath,
        primaryAnilistId,
        isHidden,
        customListName,
        localPosterColor,
        localBannerColor,
        preferredPosterSource,
        preferredBannerSource,
        anilistPosterUrl,
        anilistBannerUrl,
        watchedPercentage,
        addedAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series_table';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Never map(Map<String, dynamic> data, {String? tablePrefix}) {
    throw UnsupportedError('TableInfo.map in schema verification code');
  }

  @override
  SeriesTable createAlias(String alias) {
    return SeriesTable(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['UNIQUE (path)'];
}

class SeasonsTable extends Table with TableInfo {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SeasonsTable(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<int> seriesId = GeneratedColumn<int>(
      'series_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES series_table (id) ON DELETE CASCADE'));
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, seriesId, name, path];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'seasons_table';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Never map(Map<String, dynamic> data, {String? tablePrefix}) {
    throw UnsupportedError('TableInfo.map in schema verification code');
  }

  @override
  SeasonsTable createAlias(String alias) {
    return SeasonsTable(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints =>
      const ['UNIQUE (series_id, name, path)'];
}

class EpisodesTable extends Table with TableInfo {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  EpisodesTable(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<int> seasonId = GeneratedColumn<int>(
      'season_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES seasons_table (id) ON DELETE CASCADE'));
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
      'thumbnail_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<bool> watched = GeneratedColumn<bool>(
      'watched', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("watched" IN (0, 1))'),
      defaultValue: const CustomExpression('0'));
  late final GeneratedColumn<double> watchedPercentage =
      GeneratedColumn<double>('watched_percentage', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const CustomExpression('0.0'));
  late final GeneratedColumn<bool> thumbnailUnavailable = GeneratedColumn<bool>(
      'thumbnail_unavailable', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("thumbnail_unavailable" IN (0, 1))'),
      defaultValue: const CustomExpression('0'));
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> mkvMetadata = GeneratedColumn<String>(
      'mkv_metadata', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> anilistTitle = GeneratedColumn<String>(
      'anilist_title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<int> episodeNumber = GeneratedColumn<int>(
      'episode_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  late final GeneratedColumn<String> parsedTitle = GeneratedColumn<String>(
      'parsed_title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        seasonId,
        name,
        path,
        thumbnailPath,
        watched,
        watchedPercentage,
        thumbnailUnavailable,
        metadata,
        mkvMetadata,
        anilistTitle,
        episodeNumber,
        parsedTitle
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'episodes_table';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Never map(Map<String, dynamic> data, {String? tablePrefix}) {
    throw UnsupportedError('TableInfo.map in schema verification code');
  }

  @override
  EpisodesTable createAlias(String alias) {
    return EpisodesTable(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['UNIQUE (season_id, path)'];
}

class AnilistMappingsTable extends Table with TableInfo {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AnilistMappingsTable(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<int> seriesId = GeneratedColumn<int>(
      'series_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES series_table (id) ON DELETE CASCADE'));
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<int> anilistId = GeneratedColumn<int>(
      'anilist_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<DateTime> lastSynced = GeneratedColumn<DateTime>(
      'last_synced', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  late final GeneratedColumn<String> posterColor = GeneratedColumn<String>(
      'poster_color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> bannerColor = GeneratedColumn<String>(
      'banner_color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> anilistData = GeneratedColumn<String>(
      'anilist_data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> viewType = GeneratedColumn<String>(
      'view_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        seriesId,
        localPath,
        anilistId,
        title,
        lastSynced,
        posterColor,
        bannerColor,
        anilistData,
        viewType
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'anilist_mappings_table';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Never map(Map<String, dynamic> data, {String? tablePrefix}) {
    throw UnsupportedError('TableInfo.map in schema verification code');
  }

  @override
  AnilistMappingsTable createAlias(String alias) {
    return AnilistMappingsTable(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints =>
      const ['UNIQUE (series_id, anilist_id)'];
}

class WatchRecordsTable extends Table with TableInfo {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  WatchRecordsTable(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<double> position = GeneratedColumn<double>(
      'position', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  late final GeneratedColumn<double> duration = GeneratedColumn<double>(
      'duration', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, filePath, position, duration, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watch_records_table';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Never map(Map<String, dynamic> data, {String? tablePrefix}) {
    throw UnsupportedError('TableInfo.map in schema verification code');
  }

  @override
  WatchRecordsTable createAlias(String alias) {
    return WatchRecordsTable(attachedDatabase, alias);
  }
}

class Notifications extends Table with TableInfo {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Notifications(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
      'type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const CustomExpression('0'));
  late final GeneratedColumn<int> animeId = GeneratedColumn<int>(
      'anime_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  late final GeneratedColumn<int> episode = GeneratedColumn<int>(
      'episode', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  late final GeneratedColumn<String> contexts = GeneratedColumn<String>(
      'contexts', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
      'format', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<int> mediaId = GeneratedColumn<int>(
      'media_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  late final GeneratedColumn<String> context = GeneratedColumn<String>(
      'context', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> deletedMediaTitles =
      GeneratedColumn<String>('deleted_media_titles', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> deletedMediaTitle =
      GeneratedColumn<String>('deleted_media_title', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> mediaInfo = GeneratedColumn<String>(
      'media_info', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<DateTime> localCreatedAt =
      GeneratedColumn<DateTime>('local_created_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: const CustomExpression(
              'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: const CustomExpression(
              'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        createdAt,
        isRead,
        animeId,
        episode,
        contexts,
        format,
        mediaId,
        context,
        reason,
        deletedMediaTitles,
        deletedMediaTitle,
        mediaInfo,
        localCreatedAt,
        localUpdatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Never map(Map<String, dynamic> data, {String? tablePrefix}) {
    throw UnsupportedError('TableInfo.map in schema verification code');
  }

  @override
  Notifications createAlias(String alias) {
    return Notifications(attachedDatabase, alias);
  }
}

class AnilistMutations extends Table with TableInfo {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AnilistMutations(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<int> mediaId = GeneratedColumn<int>(
      'media_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<String> changes = GeneratedColumn<String>(
      'changes', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  late final GeneratedColumn<DateTime> localCreatedAt =
      GeneratedColumn<DateTime>('local_created_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: const CustomExpression(
              'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, type, mediaId, changes, createdAt, localCreatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'anilist_mutations';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Never map(Map<String, dynamic> data, {String? tablePrefix}) {
    throw UnsupportedError('TableInfo.map in schema verification code');
  }

  @override
  AnilistMutations createAlias(String alias) {
    return AnilistMutations(attachedDatabase, alias);
  }
}

class AnilistUserCache extends Table with TableInfo {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AnilistUserCache(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
      'avatar', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> bannerImage = GeneratedColumn<String>(
      'banner_image', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> userData = GeneratedColumn<String>(
      'user_data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, avatar, bannerImage, userData, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'anilist_user_cache';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Never map(Map<String, dynamic> data, {String? tablePrefix}) {
    throw UnsupportedError('TableInfo.map in schema verification code');
  }

  @override
  AnilistUserCache createAlias(String alias) {
    return AnilistUserCache(attachedDatabase, alias);
  }
}

class SettingsTable extends Table with TableInfo {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SettingsTable(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_table';
  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Never map(Map<String, dynamic> data, {String? tablePrefix}) {
    throw UnsupportedError('TableInfo.map in schema verification code');
  }

  @override
  SettingsTable createAlias(String alias) {
    return SettingsTable(attachedDatabase, alias);
  }
}

class DatabaseAtV13 extends GeneratedDatabase {
  DatabaseAtV13(QueryExecutor e) : super(e);
  late final SeriesTable seriesTable = SeriesTable(this);
  late final SeasonsTable seasonsTable = SeasonsTable(this);
  late final EpisodesTable episodesTable = EpisodesTable(this);
  late final AnilistMappingsTable anilistMappingsTable =
      AnilistMappingsTable(this);
  late final WatchRecordsTable watchRecordsTable = WatchRecordsTable(this);
  late final Notifications notifications = Notifications(this);
  late final AnilistMutations anilistMutations = AnilistMutations(this);
  late final AnilistUserCache anilistUserCache = AnilistUserCache(this);
  late final SettingsTable settingsTable = SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        seriesTable,
        seasonsTable,
        episodesTable,
        anilistMappingsTable,
        watchRecordsTable,
        notifications,
        anilistMutations,
        anilistUserCache,
        settingsTable
      ];
  @override
  int get schemaVersion => 13;
}
