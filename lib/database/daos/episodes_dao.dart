// daos/episodes_dao.dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';
import '../../models/episode.dart';
import '../../utils/path.dart';

part 'episodes_dao.g.dart';

@DriftAccessor(tables: [EpisodesTable, SeasonsTable])
class EpisodesDao extends DatabaseAccessor<AppDatabase> with _$EpisodesDaoMixin {
  EpisodesDao(super.db);

  Future<List<EpisodesTableData>> getEpisodesForSeason(int seasonId) => (select(episodesTable) //
        ..where((t) => t.seasonId.equals(seasonId))) //
      .get();

  Future<EpisodesTableData?> getEpisodeByPath(PathString path) => (select(episodesTable) //
        ..where((t) => t.path.equals(path.path))) //
      .getSingleOrNull();

  Future<int> insertEpisode(EpisodesTableCompanion comp) => into(episodesTable).insert(comp);

  Future<bool> updateEpisode(int id, EpisodesTableCompanion comp) async => //
      (await (update(episodesTable)..where((t) => t.id.equals(id))).write(comp)) > 0;

  Future<bool> updateEpisodeMetadata(Episode episode, int id) async {
    final comp = EpisodesTableCompanion(
      metadata: episode.metadata == null ? const Value.absent() : Value(episode.metadata),
      mkvMetadata: episode.mkvMetadata == null ? const Value.absent() : Value(episode.mkvMetadata),
    );
    return updateEpisode(id, comp);
  }

  Future<int> deleteEpisode(int id) => (delete(episodesTable)..where((t) => t.id.equals(id))).go();

  EpisodesTableCompanion toCompanion(Episode e, int seasonId) => EpisodesTableCompanion(
        seasonId: Value(seasonId),
        name: Value(e.name),
        path: Value(e.path),
        thumbnailPath: e.thumbnailPath == null ? const Value.absent() : Value(e.thumbnailPath!),
        watched: Value(e.watched),
        watchedPercentage: Value(e.progress),
        thumbnailUnavailable: Value(e.thumbnailUnavailable),
        metadata: e.metadata == null ? const Value.absent() : Value(e.metadata),
        mkvMetadata: e.mkvMetadata == null ? const Value.absent() : Value(e.mkvMetadata),
      );

  Episode fromRow(EpisodesTableData d) => Episode(
        path: d.path,
        name: d.name,
        thumbnailPath: d.thumbnailPath,
        watched: d.watched,
        progress: d.watchedPercentage,
        thumbnailUnavailable: d.thumbnailUnavailable,
        metadata: d.metadata,
        mkvMetadata: d.mkvMetadata,
      );
}
