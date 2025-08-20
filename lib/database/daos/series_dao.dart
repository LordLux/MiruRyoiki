// daos/series_dao.dart
import 'dart:convert';
import 'dart:ui';
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';
import '../../models/series.dart';
import '../../models/episode.dart';
import '../../models/anilist/mapping.dart';
import '../../models/anilist/anime.dart';
import '../../utils/path_utils.dart';
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
  /// This performs targeted inserts, updates, and deletes for the series, its seasons, and its episodes in a single transaction.
  Future<void> syncSeries(Series series) async {
    return transaction(() async {
      // 1. Sync the Series row itself
      final seriesCompanion = _modelToSeriesCompanion(series);
      final existingSeriesRow = await getSeriesRowByPath(series.path);
      int seriesId;

      if (existingSeriesRow == null) {
        seriesId = await into(seriesTable).insert(seriesCompanion);
      } else {
        seriesId = existingSeriesRow.id;
        await (update(seriesTable)..where((t) => t.id.equals(seriesId))).write(seriesCompanion);
      }

      // 2. Sync Seasons and their Episodes
      await _syncSeasons(seriesId, series.seasons, series.relatedMedia);

      // 3. Sync Anilist Mappings
      await _syncMappings(seriesId, series.anilistMappings);
    });
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

    // Handle related media (as a special season with a known ID or name, e.g., ID -1)
    // For simplicity, let's assume related media doesn't have a season. We could adapt this if needed.
  }

  /// Synchronizes the episodes for a given seasonId.
  Future<void> _syncEpisodes(int seasonId, List<Episode> modelEpisodes) async {
    final dbEpisodes = await (select(episodesTable)..where((t) => t.seasonId.equals(seasonId))).get();

    final modelEpisodesMap = {for (var e in modelEpisodes) e.path.path: e};
    final dbEpisodesMap = {for (var e in dbEpisodes) e.path.path: e};

    // Delete episodes in DB but not in model
    for (final dbEpisodePath in dbEpisodesMap.keys) {
      if (!modelEpisodesMap.containsKey(dbEpisodePath)) {
        await (delete(episodesTable)..where((t) => t.id.equals(dbEpisodesMap[dbEpisodePath]!.id))).go();
      }
    }

    // Insert or Update episodes
    for (final modelEpisode in modelEpisodes) {
      final episodeCompanion = _episodeToCompanion(modelEpisode, seasonId);
      final existingEpisode = dbEpisodesMap[modelEpisode.path.path];

      if (existingEpisode == null) {
        await into(episodesTable).insert(episodeCompanion);
      } else {
        // Only write to DB if data has actually changed
        final oldCompanion = _episodeToCompanion(_tableToEpisode(existingEpisode), seasonId);
        if (episodeCompanion != oldCompanion) {
          await (update(episodesTable)..where((t) => t.id.equals(existingEpisode.id))).write(episodeCompanion);
        }
      }
    }
  }

  Future<void> _syncMappings(int seriesId, List<AnilistMapping> modelMappings) async {
    final dbMappings = await (select(anilistMappingsTable)..where((t) => t.seriesId.equals(seriesId))).get();
    final modelMappingsMap = {for (var m in modelMappings) m.anilistId: m};
    final dbMappingsMap = {for (var m in dbMappings) m.anilistId: m};

    // Delete
    for (final dbAnilistId in dbMappingsMap.keys) {
      if (!modelMappingsMap.containsKey(dbAnilistId)) {
        await (delete(anilistMappingsTable)..where((t) => t.id.equals(dbMappingsMap[dbAnilistId]!.id))).go();
      }
    }

    // Insert/Update
    for (final modelMapping in modelMappings) {
      final companion = _mappingToCompanion(modelMapping, seriesId);
      final existingMapping = dbMappingsMap[modelMapping.anilistId];
      if (existingMapping == null) {
        await into(anilistMappingsTable).insert(companion);
      } else {
        if (companion != _mappingToCompanion(_tableToMapping(existingMapping), seriesId)) {
          await (update(anilistMappingsTable)..where((t) => t.id.equals(existingMapping.id))).write(companion);
        }
      }
    }
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
      final eps = epRows.map(_tableToEpisode).toList();
      seasons.add(Season(name: s.name, path: s.path, episodes: eps));
    }

    // Mappings
    final mappingRows = await (select(anilistMappingsTable) //
          ..where((t) => t.seriesId.equals(seriesId))) //
        .get();

    final mappings = mappingRows.map(_tableToMapping).toList();

    return _rowToSeries(row, seasons, mappings);
  }

  // ---------- HELPERS ----------
  AnilistMappingsTableCompanion _mappingToCompanion(AnilistMapping m, int seriesId) {
    return AnilistMappingsTableCompanion(
      seriesId: Value(seriesId),
      localPath: Value(m.localPath),
      anilistId: Value(m.anilistId),
      title: Value(m.title),
      lastSynced: Value(m.lastSynced),
      anilistData: Value(m.anilistData != null ? jsonEncode(m.anilistData!.toJson()) : null),
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
    Color? dominantColor,
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
      dominantColor: dominantColor == null //
          ? const Value.absent()
          : Value(const ColorJsonConverter().toSql(dominantColor)),
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
      updatedAt: Value(DateTime.now()),
    );
    return (await (update(seriesTable)..where((t) => t.id.equals(seriesId))).write(comp)) > 0;
  }

  // ---------- MAPPERS ----------
  SeriesTableCompanion _modelToSeriesCompanion(Series s) {
    return SeriesTableCompanion(
      name: Value(s.name),
      path: Value(s.path),
      folderPosterPath: Value(s.folderPosterPath),
      folderBannerPath: Value(s.folderBannerPath),
      primaryAnilistId: Value(s.primaryAnilistId),
      isHidden: Value(s.isHidden),
      dominantColor: Value(const ColorJsonConverter().toSql(s.dominantColor)),
      preferredPosterSource: Value(s.preferredPosterSource?.name),
      preferredBannerSource: Value(s.preferredBannerSource?.name),
      anilistPosterUrl: Value(s.anilistPosterUrl),
      anilistBannerUrl: Value(s.anilistBannerUrl),
      watchedPercentage: Value(s.watchedPercentage),
      updatedAt: Value(DateTime.now()),
    );
  }

  EpisodesTableCompanion _episodeToCompanion(Episode e, int seasonId) {
    return EpisodesTableCompanion(seasonId: Value(seasonId), name: Value(e.name), path: Value(e.path), thumbnailPath: e.thumbnailPath == null ? const Value.absent() : Value(e.thumbnailPath!), watched: Value(e.watched), watchedPercentage: Value(e.progress), thumbnailUnavailable: Value(e.thumbnailUnavailable), metadata: e.metadata == null ? const Value.absent() : Value(e.metadata), mkvMetadata: e.mkvMetadata == null ? const Value.absent() : Value(e.mkvMetadata));
  }

  Episode _tableToEpisode(EpisodesTableData d) => Episode(
        path: d.path,
        name: d.name,
        thumbnailPath: d.thumbnailPath,
        watched: d.watched,
        progress: d.watchedPercentage,
        thumbnailUnavailable: d.thumbnailUnavailable,
        metadata: d.metadata,
        mkvMetadata: d.mkvMetadata,
      );

  AnilistMapping _tableToMapping(AnilistMappingsTableData d) => AnilistMapping(
        localPath: d.localPath,
        anilistId: d.anilistId,
        title: d.title,
        lastSynced: d.lastSynced,
        anilistData: d.anilistData == null ? null : AnilistAnime.fromJson(jsonDecode(d.anilistData!)),
      );

  Series _rowToSeries(SeriesTableData row, List<Season> seasons, List<AnilistMapping> mappings) {
    return Series(
      id: row.id,
      name: row.name,
      path: row.path,
      folderPosterPath: row.folderPosterPath,
      folderBannerPath: row.folderBannerPath,
      seasons: seasons.map((season) => season.copyWith(
      seriesId: row.id,           // NEW: Set parent ID
    )).toList(),
      relatedMedia: const [], // gestisci se necessario come season speciale
      anilistMappings: mappings,
      dominantColor: const ColorJsonConverter().fromSql(row.dominantColor),
      preferredPosterSource: const ImageSourceConverter().fromSql(row.preferredPosterSource),
      preferredBannerSource: const ImageSourceConverter().fromSql(row.preferredBannerSource),
      anilistPoster: row.anilistPosterUrl,
      anilistBanner: row.anilistBannerUrl,
      primaryAnilistId: row.primaryAnilistId,
      isHidden: row.isHidden,
    );
  }
}
