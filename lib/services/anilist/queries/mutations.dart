part of 'anilist_service.dart';

extension AnilistServiceMutations on AnilistService {
  /// Update progress for an anime
  Future<bool> updateProgress(int mediaId, int progress) async {
    const mutation = r'''
      mutation UpdateProgress($mediaId: Int!, $progress: Int!) {
        SaveMediaListEntry(mediaId: $mediaId, progress: $progress) {
          id
          progress
        }
      }
    ''';

    final result = await executeMutation<bool>(
      options: MutationOptions(
        document: gql(mutation),
        variables: {
          'mediaId': mediaId,
          'progress': progress,
        },
      ),
      operationName: 'updateProgress(mediaId: $mediaId, progress: $progress)',
      parser: (data) => data['SaveMediaListEntry'] != null,
    );

    return result ?? false;
  }

  /// Update status for an anime
  Future<bool> updateStatus(int mediaId, AnilistListApiStatus status) async {
    const mutation = r'''
      mutation UpdateStatus($mediaId: Int!, $status: MediaListStatus!) {
        SaveMediaListEntry(mediaId: $mediaId, status: $status) {
          id
          status
        }
      }
    ''';

    final result = await executeMutation<bool>(
      options: MutationOptions(
        document: gql(mutation),
        variables: {
          'mediaId': mediaId,
          'status': status.name_,
        },
      ),
      operationName: 'updateStatus(mediaId: $mediaId, status: $status)',
      parser: (data) => data['SaveMediaListEntry'] != null,
    );

    return result ?? false;
  }

  /// Update score for an anime
  Future<bool> updateScore(int mediaId, int score) async {
    const mutation = r'''
      mutation UpdateScore($mediaId: Int!, $score: Float!) {
        SaveMediaListEntry(mediaId: $mediaId, score: $score) {
          id
          score
        }
      }
    ''';

    final result = await executeMutation<bool>(
      options: MutationOptions(
        document: gql(mutation),
        variables: {
          'mediaId': mediaId,
          'score': score.toDouble(),
        },
      ),
      operationName: 'updateScore(mediaId: $mediaId, score: $score)',
      parser: (data) => data['SaveMediaListEntry'] != null,
    );

    return result ?? false;
  }
}
