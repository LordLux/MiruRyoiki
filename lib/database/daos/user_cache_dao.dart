// user_cache_dao.dart
import 'package:drift/drift.dart';
import 'package:miruryoiki/utils/time.dart';
import '../database.dart';
import '../tables.dart';
import '../../models/anilist/user_list.dart';
import '../../models/anilist/user_data.dart';

part 'user_cache_dao.g.dart';

@DriftAccessor(tables: [AnilistUserCacheTable])
class UserCacheDao extends DatabaseAccessor<AppDatabase> with _$UserCacheDaoMixin {
  UserCacheDao(super.db);

  /// Get the cached user
  Future<AnilistUser?> getCachedUser() async {
    final results = await select(db.anilistUserCacheTable).get();
    if (results.isEmpty) return null;

    return _userFromRow(results.first);
  }

  /// Save or update the user cache
  Future<void> upsertUser(AnilistUser user) async {
    await into(db.anilistUserCacheTable).insertOnConflictUpdate(
      AnilistUserCacheTableCompanion.insert(
        id: Value(user.id),
        name: user.name,
        avatar: Value(user.avatar),
        bannerImage: Value(user.bannerImage),
        userData: Value(user.userData?.toJson()),
        cachedAt: Value(now),
      ),
    );
  }

  /// Delete the cached user
  Future<int> deleteCachedUser() async => delete(db.anilistUserCacheTable).go();

  /// Check if user cache exists
  Future<bool> hasCachedUser() async {
    final countQuery = selectOnly(db.anilistUserCacheTable) //
      ..addColumns([db.anilistUserCacheTable.id.count()]);

    final result = await countQuery.getSingle();
    final count = result.read(db.anilistUserCacheTable.id.count()) ?? 0;
    return count > 0;
  }

  /// Get the cache timestamp
  Future<DateTime?> getCacheTimestamp() async {
    final results = await (select(db.anilistUserCacheTable) //
          ..orderBy([(t) => OrderingTerm(expression: t.cachedAt, mode: OrderingMode.desc)])
          ..limit(1))
        .get();

    return results.isEmpty ? null : results.first.cachedAt;
  }

  /// Convert database row to AnilistUser model
  AnilistUser _userFromRow(AnilistUserCacheTableData row) {
    return AnilistUser(
      id: row.id,
      name: row.name,
      avatar: row.avatar,
      bannerImage: row.bannerImage,
      userData: row.userData != null //
          ? AnilistUserData.fromJson(row.userData!)
          : null,
    );
  }
}
