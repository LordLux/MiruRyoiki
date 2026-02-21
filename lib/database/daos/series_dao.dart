// daos/series_dao.dart
import 'dart:convert';
import 'dart:ui';
import 'package:drift/drift.dart';
import 'package:flutter_anitomy/flutter_anitomy.dart';
import '../../models/season.dart';
import '../../utils/time.dart';
import '../database.dart';
import '../tables.dart';
import '../../models/series.dart';
import '../../models/episode.dart';
import '../../models/anilist/mapping.dart';
import '../../models/anilist/anime.dart';
import '../../utils/path.dart';
import '../../enums.dart';
import '../converters.dart';

part 'series_dao.g.dart';

@DriftAccessor(tables: [
  SeriesTable,
  SeasonsTable,
  EpisodesTable,
  AnilistMappingsTable,
])
class SeriesDao extends DatabaseAccessor<AppDatabase> with _$SeriesDaoMixin {
  SeriesDao(super.db);

  // ---------- BASIC CRUD ----------
  Future<List<SeriesTableData>> getAllSeriesRows() => select(seriesTable).get();

  Future<SeriesTableData?> getSeriesRowById(int id) => (select(seriesTable)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<SeriesTableData?> getSeriesRowByPath(PathString path) => (select(seriesTable)..where((t) => t.path.equals(path.path))).getSingleOrNull();

  Future<int> insertSeriesRow(SeriesTableCompanion comp) => into(seriesTable).insert(comp);

  Future<bool> updateSeriesRow(int id, SeriesTableCompanion comp) async => (await (update(seriesTable)..where((t) => t.id.equals(id))).write(comp)) > 0;

  Future<int> deleteSeriesRow(int id) => (delete(seriesTable)..where((t) => t.id.equals(id))).go();

  Future<int> getIdByPath(PathString path) async {
    final row = await getSeriesRowByPath(path);
    return row?.id ?? -1; // Return -1 if not found
  }

  /// Synchronizes a single Series object with the database.
  /// This performs targeted inserts, updates, and deletes for the series, its seasons, and its episodes in a single transaction
  Future<void> syncSeries(Series series) async {
    return transaction(() async {
      await _syncSeriesInner(series);
    });
  }

  /// Synchronize multiple series in a single transaction
  Future<void> syncSeriesBatch(List<Series> seriesList) async {
    if (seriesList.isEmpty) return;
    return transaction(() async {
      for (final series in seriesList) {
        await _syncSeriesInner(series);
      }
    });
  }

  /// Inner implementation shared by [syncSeries] and [syncSeriesBatch]
  Future<void> _syncSeriesInner(Series series) async {
    // Sync the Series row
    final existingSeriesRow = await getSeriesRowByPath(series.path);
    int seriesId;

    if (existingSeriesRow == null) {
      final seriesCompanion = _modelToSeriesCompanion(series);
      seriesId = await into(seriesTable).insert(seriesCompanion);
    } else {
      seriesId = existingSeriesRow.id;
      // Only write if data changed
      if (_hasSeriesChanged(series, existingSeriesRow)) {
        final seriesCompanion = _modelToSeriesCompanion(series);
        await (update(seriesTable)..where((t) => t.id.equals(seriesId))).write(seriesCompanion);
      }
    }

    // Sync Seasons
    await _syncSeasons(seriesId, series.seasons, series.relatedMedia);

    // Sync Anilist Mappings
    await _syncMappings(seriesId, series.anilistMappings);
  }

  /// Synchronizes the seasons for a given seriesId.
  Future<void> _syncSeasons(int seriesId, List<Season> modelSeasons, List<Episode> modelRelatedMedia) async {
    final dbSeasons = await (select(seasonsTable)..where((t) => t.seriesId.equals(seriesId))).get();

    // Use path as the unique key for seasons
    final modelSeasonsMap = {for (var s in modelSeasons) s.path.path: s};
    final dbSeasonsMap = {for (var s in dbSeasons) s.path.path: s};

    // Delete seasons that are in DB but not in model
    for (final dbSeasonPath in dbSeasonsMap.keys) {
      if (!modelSeasonsMap.containsKey(dbSeasonPath)) {
        await (delete(seasonsTable)..where((t) => t.id.equals(dbSeasonsMap[dbSeasonPath]!.id))).go();
      }
    }

    // Insert or Update seasons
    for (final modelSeason in modelSeasons) {
      final seasonCompanion = SeasonsTableCompanion(
        seriesId: Value(seriesId),
        name: Value(modelSeason.name),
        path: Value(modelSeason.path),
      );
      int seasonId;
      final existingSeason = dbSeasonsMap[modelSeason.path.path];

      if (existingSeason == null) {
        seasonId = await into(seasonsTable).insert(seasonCompanion);
      } else {
        seasonId = existingSeason.id;
        // Optionally update if name can change, otherwise skip
        if (existingSeason.name != modelSeason.name) {
          await (update(seasonsTable)..where((t) => t.id.equals(seasonId))).write(seasonCompanion);
        }
      }

      // Sync episodes for this season
      await _syncEpisodes(seasonId, modelSeason.episodes);
    }

    // TODO Handle related media (as a special season with a known ID or name, e.g., ID -1)
    // For simplicity, let's assume related media doesn't have a season. We could adapt this if needed.
  }

  /// Synchronizes the episodes for a given seasonId.
  Future<void> _syncEpisodes(int seasonId, List<Episode> modelEpisodes) async {
    final dbEpisodes = await (select(episodesTable)..where((t) => t.seasonId.equals(seasonId))).get();

    final modelEpisodesMap = {for (var e in modelEpisodes) e.path.path: e};
    final dbEpisodesMap = {for (var e in dbEpisodes) e.path.path: e};

    await batch((batch) {
      // Delete episodes in DB but not in model
      for (final dbEpisodePath in dbEpisodesMap.keys) {
        if (!modelEpisodesMap.containsKey(dbEpisodePath)) {
          batch.delete(episodesTable, dbEpisodesMap[dbEpisodePath]!);
        }
      }

      // Insert or Update episodes
      for (final modelEpisode in modelEpisodes) {
        final existingEpisode = dbEpisodesMap[modelEpisode.path.path];

        if (existingEpisode == null) {
          batch.insert(episodesTable, _episodeToCompanion(modelEpisode, seasonId));
        } else {
          // Only write to DB if data has actually changed
          if (_hasEpisodeChanged(modelEpisode, existingEpisode)) {
            batch.update(
              episodesTable,
              _episodeToCompanion(modelEpisode, seasonId),
              where: (t) => t.id.equals(existingEpisode.id),
            );
          }
        }
      }
    });
  }

  Future<void> _syncMappings(int seriesId, List<AnilistMapping> modelMappings) async {
    final dbMappings = await (select(anilistMappingsTable)..where((t) => t.seriesId.equals(seriesId))).get();
    final modelMappingsMap = {for (var m in modelMappings) m.anilistId: m};
    final dbMappingsMap = {for (var m in dbMappings) m.anilistId: m};

    await batch((batch) {
      // Delete
      for (final dbAnilistId in dbMappingsMap.keys) {
        if (!modelMappingsMap.containsKey(dbAnilistId)) {
          batch.delete(anilistMappingsTable, dbMappingsMap[dbAnilistId]!);
        }
      }

      // Insert or Update
      for (final modelMapping in modelMappings) {
        final existingMapping = dbMappingsMap[modelMapping.anilistId];

        if (existingMapping == null) {
          batch.insert(anilistMappingsTable, _mappingToCompanion(modelMapping, seriesId));
        } else {
          // Only write if data has changed
          if (_hasMappingChanged(modelMapping, existingMapping)) {
            batch.update(
              anilistMappingsTable,
              _mappingToCompanion(modelMapping, seriesId),
              where: (t) => t.id.equals(existingMapping.id),
            );
          }
        }
      }
    });
  }

  /// Load a full Series object by id (Series + Seasons + Episodes + Mappings).
  Future<Series?> loadFullSeries(int seriesId) async {
    final row = await getSeriesRowById(seriesId);
    if (row == null) return null;

    // Seasons
    final seasonRows = await (select(seasonsTable) //
          ..where((t) => t.seriesId.equals(seriesId))) //
        .get();

    final List<Season> seasons = [];
    for (final s in seasonRows) {
      final epRows = await (select(episodesTable)..where((t) => t.seasonId.equals(s.id))) //
          .get();
      final eps = epRows.map(_tableToEpisode).toList()
        ..sort((a, b) {
          final aNum = a.episodeNumber;
          final bNum = b.episodeNumber;
          if (aNum != null && bNum != null) return aNum.compareTo(bNum);
          if (aNum != null) return -1;
          if (bNum != null) return 1;
          return a.name.compareTo(b.name);
        });
      seasons.add(Season(name: s.name, path: s.path, episodes: eps));
    }

    // Mappings
    final mappingRows = await (select(anilistMappingsTable) //
          ..where((t) => t.seriesId.equals(seriesId))) //
        .get();

    final mappings = mappingRows.map(_tableToMapping).toList();

    return _rowToSeries(row, seasons, mappings);
  }

  /// Load ALL series from the database in bulk using 4 queries
  ///
  /// This is vastly faster than calling [loadFullSeries] per series, which generates N+M queries (1 per series + 1 per season for episodes)
  ///
  /// Note: [relatedMedia] (movies/specials not attached to a season) are not yet persisted in the DB, so they will be `const []` until the related media TODO is addressed
  Future<List<Series>> loadAllSeries() async {
    // 4 bulk queries
    final allSeriesRows = await select(seriesTable).get();
    final allSeasonRows = await select(seasonsTable).get();
    final allEpisodeRows = await select(episodesTable).get();
    final allMappingRows = await select(anilistMappingsTable).get();

    // Group episodes by seasonId
    final episodesBySeasonId = <int, List<Episode>>{};
    for (final ep in allEpisodeRows) {
      (episodesBySeasonId[ep.seasonId] ??= []).add(_tableToEpisode(ep));
    }
    // Sort each season's episodes
    for (final episodes in episodesBySeasonId.values) {
      episodes.sort((a, b) {
        final aNum = a.episodeNumber;
        final bNum = b.episodeNumber;
        if (aNum != null && bNum != null) return aNum.compareTo(bNum);
        if (aNum != null) return -1;
        if (bNum != null) return 1;
        return a.name.compareTo(b.name);
      });
    }

    // Group seasons by seriesId
    final seasonsBySeriesId = <int, List<Season>>{};
    for (final s in allSeasonRows) {
      final episodes = episodesBySeasonId[s.id] ?? const [];
      (seasonsBySeriesId[s.seriesId] ??= []).add(
        Season(name: s.name, path: s.path, episodes: episodes),
      );
    }

    // Group mappings by seriesId
    final mappingsBySeriesId = <int, List<AnilistMapping>>{};
    for (final m in allMappingRows) {
      (mappingsBySeriesId[m.seriesId] ??= []).add(_tableToMapping(m));
    }

    // Assemble Series objects
    return allSeriesRows.map((row) {
      final seasons = seasonsBySeriesId[row.id] ?? const [];
      final mappings = mappingsBySeriesId[row.id] ?? const [];
      return _rowToSeries(row, seasons, mappings);
    }).toList();
  }

  Future<void> updateMappingLastSynced(int seriesId, int anilistId, DateTime lastSynced) {
    return (update(anilistMappingsTable) //
          ..where((t) => t.seriesId.equals(seriesId) & t.anilistId.equals(anilistId)))
        .write(AnilistMappingsTableCompanion(lastSynced: Value(lastSynced)));
  }

  Future<void> updateMappingAnilistData(int seriesId, int anilistId, AnilistAnime anilistData, DateTime lastSynced) {
    return (update(anilistMappingsTable) //
          ..where((t) => t.seriesId.equals(seriesId) & t.anilistId.equals(anilistId)))
        .write(AnilistMappingsTableCompanion(
      anilistData: Value(jsonEncode(anilistData.toJson())),
      lastSynced: Value(lastSynced),
    ));
  }

  Future<void> updateMappingViewType(int anilistId, ViewType viewType) {
    return (update(anilistMappingsTable)..where((t) => t.anilistId.equals(anilistId))) //
        .write(AnilistMappingsTableCompanion(viewType: Value(viewType.name_)));
  }

  // ---------- HELPERS ----------
  AnilistMappingsTableCompanion _mappingToCompanion(AnilistMapping m, int seriesId) {
    return AnilistMappingsTableCompanion(
      seriesId: Value(seriesId),
      localPath: Value(m.localPath),
      anilistId: Value(m.anilistId),
      title: Value(m.title),
      lastSynced: Value(m.lastSynced),
      posterColor: Value(const ColorJsonConverter().toSql(m.posterColor)),
      bannerColor: Value(const ColorJsonConverter().toSql(m.bannerColor)),
      anilistData: Value(m.anilistData != null ? jsonEncode(m.anilistData!.toJson()) : null),
      viewType: Value(m.viewType?.name_),
    );
  }

  // ---------- UPDATE HELPERS ----------
  Future<bool> updateSingleEpisode(Episode episode, int seasonId) async {
    final row = await (select(episodesTable) //
          ..where((t) => t.path.equals(episode.path.path))) //
        .getSingleOrNull();

    final comp = _episodeToCompanion(episode, seasonId);
    if (row == null) {
      await into(episodesTable).insert(comp);
      return true;
    }
    return (await (update(episodesTable)..where((t) => t.id.equals(row.id))).write(comp)) > 0;
  }

  Future<bool> updateSeriesFields({
    required int seriesId,
    String? name,
    PathString? folderPosterPath,
    PathString? folderBannerPath,
    double? watchedPercentage,
    Color? localPosterColor,
    Color? localBannerColor,
    ImageSource? preferredPosterSource,
    ImageSource? preferredBannerSource,
    String? anilistPosterUrl,
    String? anilistBannerUrl,
    int? primaryAnilistId,
    bool? isHidden,
  }) async {
    final comp = SeriesTableCompanion(
      name: name == null ? const Value.absent() : Value(name),
      folderPosterPath: folderPosterPath == null //
          ? const Value.absent()
          : Value(folderPosterPath),
      folderBannerPath: folderBannerPath == null //
          ? const Value.absent()
          : Value(folderBannerPath),
      watchedPercentage: watchedPercentage == null //
          ? const Value.absent()
          : Value(watchedPercentage),
      localPosterColor: localPosterColor == null //
          ? const Value.absent()
          : Value(const ColorJsonConverter().toSql(localPosterColor)),
      localBannerColor: localBannerColor == null //
          ? const Value.absent()
          : Value(const ColorJsonConverter().toSql(localBannerColor)),
      preferredPosterSource: preferredPosterSource == null //
          ? const Value.absent()
          : Value(preferredPosterSource.name),
      preferredBannerSource: preferredBannerSource == null //
          ? const Value.absent()
          : Value(preferredBannerSource.name),
      anilistPosterUrl: anilistPosterUrl == null //
          ? const Value.absent()
          : Value(anilistPosterUrl),
      anilistBannerUrl: anilistBannerUrl == null //
          ? const Value.absent()
          : Value(anilistBannerUrl),
      primaryAnilistId: primaryAnilistId == null //
          ? const Value.absent()
          : Value(primaryAnilistId),
      isHidden: isHidden == null //
          ? const Value.absent()
          : Value(isHidden),
      updatedAt: Value(now),
    );
    return (await (update(seriesTable)..where((t) => t.id.equals(seriesId))).write(comp)) > 0;
  }

  // ---------- MAPPERS ----------
  SeriesTableCompanion _modelToSeriesCompanion(Series s) {
    return SeriesTableCompanion(
      name: Value(s.name),
      path: Value(s.path),
      folderPosterPath: Value(s.localPosterPath),
      folderBannerPath: Value(s.localBannerPath),
      primaryAnilistId: Value(s.primaryAnilistId),
      isHidden: Value(s.isForcedHidden),
      customListName: Value(s.customListName),
      localPosterColor: Value(const ColorJsonConverter().toSql(s.localPosterColor)),
      localBannerColor: Value(const ColorJsonConverter().toSql(s.localBannerColor)),
      preferredPosterSource: Value(s.preferredPosterSource?.name),
      preferredBannerSource: Value(s.preferredBannerSource?.name),
      anilistPosterUrl: Value(s.anilistPosterUrl),
      anilistBannerUrl: Value(s.anilistBannerUrl),
      watchedPercentage: Value(s.watchedPercentage),
      updatedAt: Value(now), // only update when write is actually performed
    );
  }

  // ---------- CHANGE DETECTION ----------
  /// Returns true if the in-memory Series model differs from the DB row
  bool _hasSeriesChanged(Series model, SeriesTableData db) {
    final colorConv = const ColorJsonConverter();
    return model.name != db.name ||
        model.path != db.path ||
        model.localPosterPath != db.folderPosterPath ||
        model.localBannerPath != db.folderBannerPath ||
        model.primaryAnilistId != db.primaryAnilistId ||
        model.isForcedHidden != db.isHidden ||
        model.customListName != db.customListName ||
        colorConv.toSql(model.localPosterColor) != db.localPosterColor ||
        colorConv.toSql(model.localBannerColor) != db.localBannerColor ||
        model.preferredPosterSource?.name != db.preferredPosterSource ||
        model.preferredBannerSource?.name != db.preferredBannerSource ||
        model.anilistPosterUrl != db.anilistPosterUrl ||
        model.anilistBannerUrl != db.anilistBannerUrl ||
        model.watchedPercentage != db.watchedPercentage;
  }

  /// Returns true if the in-memory Episode model differs from the DB row
  bool _hasEpisodeChanged(Episode model, EpisodesTableData db) {
    return model.name != db.name ||
        model.path != db.path ||
        model.watched != db.watched ||
        model.progress != db.watchedPercentage ||
        model.thumbnailPath != db.thumbnailPath ||
        model.thumbnailUnavailable != db.thumbnailUnavailable ||
        model.anilistTitle != db.anilistTitle ||
        model.metadata != db.metadata ||
        model.mkvMetadata != db.mkvMetadata;
  }

  /// Returns true if the in-memory AnilistMapping model differs from the DB row
  bool _hasMappingChanged(AnilistMapping model, AnilistMappingsTableData db) {
    final colorConv = const ColorJsonConverter();
    // Compare non-expensive fields first
    if (model.localPath != db.localPath ||
        model.anilistId != db.anilistId ||
        model.title != db.title ||
        model.lastSynced != db.lastSynced ||
        colorConv.toSql(model.posterColor) != db.posterColor ||
        colorConv.toSql(model.bannerColor) != db.bannerColor ||
        model.viewType?.name_ != db.viewType) {
      return true;
    }
    // Compare anilistData last (requires JSON serialization)
    final modelAnilistJson = model.anilistData != null ? jsonEncode(model.anilistData!.toJson()) : null;
    return modelAnilistJson != db.anilistData;
  }

  EpisodesTableCompanion _episodeToCompanion(Episode e, int seasonId) {
    return EpisodesTableCompanion(
      seasonId: Value(seasonId),
      name: Value(e.name),
      path: Value(e.path),
      thumbnailPath: e.thumbnailPath == null ? const Value.absent() : Value(e.thumbnailPath!),
      watched: Value(e.watched),
      watchedPercentage: Value(e.progress),
      thumbnailUnavailable: Value(e.thumbnailUnavailable),
      metadata: e.metadata == null ? const Value.absent() : Value(e.metadata),
      mkvMetadata: e.mkvMetadata == null ? const Value.absent() : Value(e.mkvMetadata),
      anilistTitle: e.anilistTitle == null ? const Value.absent() : Value(e.anilistTitle!),
    );
  }

  /// Skip the native FFI parse when loading from DB — the filename was already
  /// parsed at scan time and the episode number is derived from the name.
  static final ParsedAnime _emptyParsed = ParsedAnime();

  /// Parse episode number from filename without using the native FFI library.
  /// This avoids loading the native Anitomy DLL when constructing episodes from
  /// DB rows, while still preserving episode number derivation.
  static int? _parseEpisodeNumberFromName(String filename) {
    // Match patterns like "Episode 01", "E01", "Ep01", "- 01", "S01E01"
    final match = RegExp(r'(?:[Ee](?:pisode)?|[Ss]\d+[Ee])[\s._-]*(\d{1,4})', caseSensitive: false).firstMatch(filename);
    if (match != null) return int.tryParse(match.group(1)!);
    // Fallback: last standalone number group in the filename (before extension)
    final fallback = RegExp(r'(?:^|[\s._\-\[])(\d{1,4})(?=[\s._\-\]]|$)').allMatches(filename.replaceFirst(RegExp(r'\.[^.]+$'), ''));
    return fallback.isNotEmpty ? int.tryParse(fallback.last.group(1)!) : null;
  }

  Episode _tableToEpisode(EpisodesTableData d) => Episode(
        id: d.id,
        path: d.path,
        name: d.name,
        episodeNumber: _parseEpisodeNumberFromName(d.name),
        thumbnailPath: d.thumbnailPath,
        watched: d.watched,
        progress: d.watchedPercentage,
        thumbnailUnavailable: d.thumbnailUnavailable,
        metadata: d.metadata,
        mkvMetadata: d.mkvMetadata,
        anilistTitle: d.anilistTitle,
        parsedAnime: _emptyParsed,
      );

  AnilistMapping _tableToMapping(AnilistMappingsTableData d) => AnilistMapping(
        localPath: d.localPath,
        anilistId: d.anilistId,
        title: d.title,
        lastSynced: d.lastSynced,
        posterColor: const ColorJsonConverter().fromSql(d.posterColor),
        bannerColor: const ColorJsonConverter().fromSql(d.bannerColor),
        anilistData: d.anilistData == null ? null : AnilistAnime.fromJson(jsonDecode(d.anilistData!)),
        viewType: d.viewType != null ? ViewTypeX.fromString(d.viewType!) : null,
      );

  Series _rowToSeries(SeriesTableData row, List<Season> seasons, List<AnilistMapping> mappings) {
    return Series(
      id: row.id,
      name: row.name,
      path: row.path,
      localPosterPath: row.folderPosterPath, // TODO rename
      localBannerPath: row.folderBannerPath,
      seasons: seasons.map((season) => season.copyWith(seriesId: row.id)).toList(),
      relatedMedia: const [],
      anilistMappings: mappings,
      posterColor: const ColorJsonConverter().fromSql(row.localPosterColor),
      bannerColor: const ColorJsonConverter().fromSql(row.localBannerColor),
      preferredPosterSource: const ImageSourceConverter().fromSql(row.preferredPosterSource),
      preferredBannerSource: const ImageSourceConverter().fromSql(row.preferredBannerSource),
      anilistPoster: row.anilistPosterUrl,
      anilistBanner: row.anilistBannerUrl,
      primaryAnilistId: row.primaryAnilistId,
      isHidden: row.isHidden,
      customListName: row.customListName,
    );
  }
}
