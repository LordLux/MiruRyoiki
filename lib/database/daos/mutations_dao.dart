// mutations_dao.dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';
import '../../models/anilist/mutation.dart';

part 'mutations_dao.g.dart';

@DriftAccessor(tables: [AnilistMutationsTable])
class MutationsDao extends DatabaseAccessor<AppDatabase> with _$MutationsDaoMixin {
  MutationsDao(super.db);

  /// Get all pending mutations, ordered by creation time (oldest first)
  Future<List<AnilistMutation>> getAllMutations() async {
    final results = await (select(db.anilistMutationsTable) //
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)]))
        .get();

    return results.map((row) => _mutationFromRow(row)).toList();
  }

  /// Add a new mutation to the queue
  Future<int> addMutation(AnilistMutation mutation) async {
    return into(db.anilistMutationsTable).insert(
      AnilistMutationsTableCompanion.insert(
        type: mutation.type,
        mediaId: mutation.mediaId,
        changes: mutation.changes,
        createdAt: mutation.createdAt,
      ),
    );
  }

  /// Delete a specific mutation by ID
  Future<int> deleteMutation(int id) async => (delete(db.anilistMutationsTable)..where((t) => t.id.equals(id))).go();

  /// Delete a mutation by matching its properties (for when we don't have the DB ID)
  Future<int> deleteMutationByProperties({
    required String type,
    required int mediaId,
    required DateTime createdAt,
  }) async {
    return (delete(db.anilistMutationsTable) //
          ..where((t) =>
              t.type.equals(type) & //
              t.mediaId.equals(mediaId) &
              t.createdAt.equals(createdAt)))
        .go();
  }

  /// Delete all mutations
  Future<int> deleteAllMutations() async => delete(db.anilistMutationsTable).go();

  /// Get mutations for a specific media
  Future<List<AnilistMutation>> getMutationsForMedia(int mediaId) async {
    final results = await (select(db.anilistMutationsTable) //
          ..where((t) => t.mediaId.equals(mediaId))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)]))
        .get();

    return results.map((row) => _mutationFromRow(row)).toList();
  }

  /// Get count of pending mutations
  Future<int> getMutationsCount() async {
    final countQuery = selectOnly(db.anilistMutationsTable) //
      ..addColumns([db.anilistMutationsTable.id.count()]);

    final result = await countQuery.getSingle();
    return result.read(db.anilistMutationsTable.id.count()) ?? 0;
  }

  /// Convert database row to AnilistMutation model
  AnilistMutation _mutationFromRow(AnilistMutationsTableData row) {
    return AnilistMutation(
      type: row.type,
      mediaId: row.mediaId,
      changes: row.changes ?? {},
      createdAt: row.createdAt,
    );
  }
}
