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
import '../../utils/series_hash.dart';

part 'series_dao.g.dart';

@DriftAccessor(tables: [
  SeriesTable,
  SeasonsTable,
  EpisodesTable,
  AnilistMappingsTable,
])
class SeriesDao extends DatabaseAccessor<AppDatabase> with _$SeriesDaoMixin {
  SeriesDao(AppDatabase db) : super(db);

  // ---------- BASIC CRUD ----------
  Future<List<SeriesTableData>> getAllSeriesRows() => select(seriesTable).get();

  Future<SeriesTableData?> getSeriesRowById(int id) => //
      (select(seriesTable)..where((tbl) => tbl.id.equals(id))) //
          .getSingleOrNull();

  Future<SeriesTableData?> getSeriesRowByPath(PathString path) => //
      (select(seriesTable)..where((t) => t.path.equals(path.path))) //
          .getSingleOrNull();

  Future<int> insertSeriesRow(SeriesTableCompanion comp) => into(seriesTable).insert(comp);

  Future<bool> updateSeriesRow(int id, SeriesTableCompanion comp) async => //
      (await (update(seriesTable)..where((t) => t.id.equals(id))).write(comp)) > 0;

  Future<int> deleteSeriesRow(int id) => (delete(seriesTable)..where((t) => t.id.equals(id))).go();

  // ---------- FULL SAVE / LOAD ----------
  /// Save (insert or update) a whole Series (with seasons, episodes, mappings) in a transaction.
  Future<int> saveSeries(Series series) async {
    return transaction(() async {
      final newHash = computeSeriesHash(series);

      final existingRow = await getSeriesRowByPath(series.path);
      if (existingRow != null && existingRow.metadataHash == newHash) {
        // nothing changed → skip the heavy season/episode writes
        return existingRow.id;
      }

      final seriesComp = _modelToSeriesCompanion(series, isInsert: existingRow == null).copyWith(metadataHash: Value(newHash));
      late final int seriesId;
      if (existingRow == null) {
        seriesId = await into(seriesTable).insert(seriesComp);
      } else {
        seriesId = existingRow.id;
        await (update(seriesTable)..where((t) => t.id.equals(seriesId))).write(seriesComp);
      }

      // Save seasons
      // First, get current seasons in DB
      final dbSeasons = await (select(seasonsTable) //
            ..where((t) => t.seriesId.equals(seriesId))) //
          .get();

      // Map by name to detect inserts/updates
      final Map<String, SeasonsTableData> dbSeasonsByKey = {for (var s in dbSeasons) '${s.name}|${s.path.path}': s};

      for (final season in series.seasons) {
        final key = '${season.name}|${season.path.path}';
        final existingSeason = dbSeasonsByKey[key];
        int seasonId;
        final seasonComp = SeasonsTableCompanion(
          seriesId: Value(seriesId),
          name: Value(season.name),
          path: Value(season.path),
        );

        if (existingSeason == null) {
          seasonId = await into(seasonsTable).insert(seasonComp);
        } else {
          seasonId = existingSeason.id;
          await (update(seasonsTable)..where((t) => t.id.equals(seasonId))) //
              .write(seasonComp);
        }

        // EPISODES
        final dbEpisodes = await (select(episodesTable) //
              ..where((t) => t.seasonId.equals(seasonId))) //
            .get();
        final Map<String, EpisodesTableData> dbEpByPath = {
          for (var e in dbEpisodes) e.path.path: e //
        };

        for (final ep in season.episodes) {
          final existingEp = dbEpByPath[ep.path.path];
          final epComp = _episodeToCompanion(ep, seasonId);

          if (existingEp == null) {
            // New episode, insert with all its data
            await into(episodesTable).insert(epComp);
          } else {
            // Episode exists -> Check if we need to update it
            final bool metadataNeedsUpdate = (ep.metadata != null && existingEp.metadata == null) || (ep.mkvMetadata != null && existingEp.mkvMetadata == null);

            // Only write to database if something actually changed
            // Create new companion for the update to be explicit
            final updateComp = epComp.copyWith(
              // Preserve existing metadata if new scan didn't find any
              metadata: ep.metadata == null ? Value(existingEp.metadata) : Value(ep.metadata),
              mkvMetadata: ep.mkvMetadata == null ? Value(existingEp.mkvMetadata) : Value(ep.mkvMetadata),
            );

            // By comparing the companions, we can detect any change, not just metadata
            if (updateComp != _episodeToCompanion(ep.copyWith(metadata: existingEp.metadata, mkvMetadata: existingEp.mkvMetadata), seasonId) || metadataNeedsUpdate) {
              await (update(episodesTable)..where((t) => t.id.equals(existingEp.id))) //
                  .write(updateComp);
            }
          }
        }

        // Delete eps not present anymore
        final paths = season.episodes.map((e) => e.path.path).toSet();
        for (final old in dbEpisodes) {
          if (!paths.contains(old.path.path)) {
            await (delete(episodesTable)..where((t) => t.id.equals(old.id))).go();
          }
        }
      }

      // AniList mappings
      await _saveMappings(seriesId, series.anilistMappings);

      return seriesId;
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

  // ---------- MAPPINGS ----------
  Future<void> _saveMappings(int seriesId, List<AnilistMapping> mappings) async {
    // Current in DB
    final current = await (select(anilistMappingsTable) //
          ..where((t) => t.seriesId.equals(seriesId))) //
        .get();

    final Map<int, AnilistMappingsTableData> byAniId = {
      for (var m in current) m.anilistId: m //
    };

    for (final mapModel in mappings) {
      final existing = byAniId[mapModel.anilistId];
      final comp = AnilistMappingsTableCompanion(
        seriesId: Value(seriesId),
        localPath: Value(mapModel.localPath),
        anilistId: Value(mapModel.anilistId),
        title: Value(mapModel.title),
        lastSynced: Value(mapModel.lastSynced),
        anilistData: Value(mapModel.anilistData != null ? jsonEncode(mapModel.anilistData!.toJson()) : null),
      );

      if (existing == null) {
        await into(anilistMappingsTable).insert(comp);
      } else {
        await (update(anilistMappingsTable)..where((t) => t.id.equals(existing.id))) //
            .write(comp);
      }
    }
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
  SeriesTableCompanion _modelToSeriesCompanion(Series s, {required bool isInsert}) {
    final colorStr = const ColorJsonConverter().toSql(s.dominantColor);

    return SeriesTableCompanion(
      name: Value(s.name),
      path: Value(s.path),
      folderPosterPath: s.folderPosterPath == null //
          ? const Value.absent()
          : Value(s.folderPosterPath!),
      folderBannerPath: s.folderBannerPath == null //
          ? const Value.absent()
          : Value(s.folderBannerPath!),
      primaryAnilistId: s.primaryAnilistId == null //
          ? const Value.absent()
          : Value(s.primaryAnilistId!),
      isHidden: Value(s.isHidden),
      dominantColor: colorStr == null //
          ? const Value.absent()
          : Value(colorStr),
      preferredPosterSource: s.preferredPosterSource == null //
          ? const Value.absent()
          : Value(s.preferredPosterSource!.name),
      preferredBannerSource: s.preferredBannerSource == null //
          ? const Value.absent()
          : Value(s.preferredBannerSource!.name),
      anilistPosterUrl: s.anilistPosterUrl == null //
          ? const Value.absent()
          : Value(s.anilistPosterUrl!),
      anilistBannerUrl: s.anilistBannerUrl == null //
          ? const Value.absent()
          : Value(s.anilistBannerUrl!),
      watchedPercentage: Value(s.watchedPercentage),
      addedAt: isInsert ? Value(DateTime.now()) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
      metadataHash: Value.absent(), // will be set later
    );
  }

  EpisodesTableCompanion _episodeToCompanion(Episode e, int seasonId) {
    return EpisodesTableCompanion(seasonId: Value(seasonId), name: Value(e.name), path: Value(e.path), thumbnailPath: e.thumbnailPath == null ? const Value.absent() : Value(e.thumbnailPath!), watched: Value(e.watched), watchedPercentage: Value(e.watchedPercentage), thumbnailUnavailable: Value(e.thumbnailUnavailable), metadata: e.metadata == null ? const Value.absent() : Value(e.metadata), mkvMetadata: e.mkvMetadata == null ? const Value.absent() : Value(e.mkvMetadata));
  }

  Episode _tableToEpisode(EpisodesTableData d) => Episode(
        path: d.path,
        name: d.name,
        thumbnailPath: d.thumbnailPath,
        watched: d.watched,
        watchedPercentage: d.watchedPercentage,
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
      name: row.name,
      path: row.path,
      folderPosterPath: row.folderPosterPath,
      folderBannerPath: row.folderBannerPath,
      seasons: seasons,
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

  // ---------- LIBRARY SAVE ----------
  /// Salva una lista di Series in una transazione.
  Future<void> saveLibrary(List<Series> all) async {
    await transaction(() async {
      for (final s in all) {
        await saveSeries(s);
      }
    });
  }
}
