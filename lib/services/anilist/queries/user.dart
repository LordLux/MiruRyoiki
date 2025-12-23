part of 'anilist_service.dart';

extension AnilistServiceUser on AnilistService {
  /// Get current user information
  Future<AnilistUser?> getCurrentUser() async {
    if (_client == null) return null;

    logTrace('Fetching current user info from Anilist...');

    final result = await executeQuery<Query$GetCurrentUser>(
      options: QueryOptions(
        document: documentNodeQueryGetCurrentUser,
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      operationName: 'GetCurrentUser',
      parser: (data) => Query$GetCurrentUser.fromJson(data),
    );

    if (result == null || result.Viewer == null) return null;

    return AnilistUser.fromJson(result.Viewer!.toJson());
  }

  Future<AnilistUserData?> getCurrentUserData() async {
    if (_client == null) return null;

    logTrace('Fetching current user data from Anilist...');

    final result = await executeQuery<Query$GetCurrentUserData>(
      options: QueryOptions(
        document: documentNodeQueryGetCurrentUserData,
        fetchPolicy: FetchPolicy.networkOnly,
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
      ),
      operationName: 'GetCurrentUserData',
      parser: (data) => Query$GetCurrentUserData.fromJson(data),
    );

    if (result == null || result.Viewer == null) return null;

    return AnilistUserData.fromJson(result.Viewer!.toJson());
  }
}
