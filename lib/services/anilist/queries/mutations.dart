part of 'anilist_service.dart';

extension AnilistServiceMutations on AnilistService {
  /// Update progress for an anime
  Future<bool> updateProgress(int mediaId, int progress) async {
    final result = await executeMutation<Mutation$UpdateProgress>(
      options: MutationOptions(
        document: documentNodeMutationUpdateProgress,
        variables: Variables$Mutation$UpdateProgress(
          mediaId: mediaId,
          progress: progress,
        ).toJson(),
      ),
      operationName: 'UpdateProgress',
      parser: (data) => Mutation$UpdateProgress.fromJson(data),
    );

    return result?.SaveMediaListEntry != null;
  }

  /// Update status for an anime
  Future<bool> updateStatus(int mediaId, AnilistListApiStatus status) async {
    final statusEnum = Enum$MediaListStatus.values.firstWhereOrNull((e) => e.name == status.name_);
    
    if (statusEnum == null) return false;

    final result = await executeMutation<Mutation$UpdateStatus>(
      options: MutationOptions(
        document: documentNodeMutationUpdateStatus,
        variables: Variables$Mutation$UpdateStatus(
          mediaId: mediaId,
          status: statusEnum,
        ).toJson(),
      ),
      operationName: 'UpdateStatus',
      parser: (data) => Mutation$UpdateStatus.fromJson(data),
    );

    return result?.SaveMediaListEntry != null;
  }

  /// Update score for an anime
  Future<bool> updateScore(int mediaId, int score) async {
    final result = await executeMutation<Mutation$UpdateScore>(
      options: MutationOptions(
        document: documentNodeMutationUpdateScore,
        variables: Variables$Mutation$UpdateScore(
          mediaId: mediaId,
          score: score.toDouble(),
        ).toJson(),
      ),
      operationName: 'UpdateScore',
      parser: (data) => Mutation$UpdateScore.fromJson(data),
    );

    return result?.SaveMediaListEntry != null;
  }
}
