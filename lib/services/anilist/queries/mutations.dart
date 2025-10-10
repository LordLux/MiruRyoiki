part of 'anilist_service.dart';

extension AnilistServiceMutations on AnilistService {
  /// Update progress for an anime
  Future<bool> updateProgress(int mediaId, int progress) async {
    if (_client == null) return false;

    const mutation = r'''
      mutation UpdateProgress($mediaId: Int!, $progress: Int!) {
        SaveMediaListEntry(mediaId: $mediaId, progress: $progress) {
          id
          progress
        }
      }
    ''';

    try {
      final result = await RetryUtils.retry<bool>(
        () async {
          final mutationResult = await _client!.mutate(
            MutationOptions(
              document: gql(mutation),
              variables: {
                'mediaId': mediaId,
                'progress': progress,
              },
            ),
          );

          if (mutationResult.hasException) {
            // Check if offline before logging
            if (!RetryUtils.isExpectedOfflineError(mutationResult.exception)) {
              logErr('Error updating progress', mutationResult.exception);
            }
            return false;
          }

          return mutationResult.data?['SaveMediaListEntry'] != null;
        },
        maxRetries: 3,
        retryIf: RetryUtils.shouldRetryAnilistError,
        operationName: 'updateProgress(mediaId: $mediaId, progress: $progress)',
      );

      return result ?? false;
    } catch (e) {
      if (ConnectivityService().isOffline && RetryUtils.isExpectedOfflineError(e)) {
        logDebug('Cannot update progress - device is offline');
        return false;
      }
      logErr('Error updating progress', e);
      return false;
    }
  }

  /// Update status for an anime
  Future<bool> updateStatus(int mediaId, AnilistListApiStatus status) async {
    if (_client == null) return false;

    const mutation = r'''
      mutation UpdateStatus($mediaId: Int!, $status: MediaListStatus!) {
        SaveMediaListEntry(mediaId: $mediaId, status: $status) {
          id
          status
        }
      }
    ''';

    try {
      final result = await RetryUtils.retry<bool>(
        () async {
          final mutationResult = await _client!.mutate(
            MutationOptions(
              document: gql(mutation),
              variables: {
                'mediaId': mediaId,
                'status': status.name_,
              },
            ),
          );

          if (mutationResult.hasException) {
            // Check if offline before logging
            if (!RetryUtils.isExpectedOfflineError(mutationResult.exception)) {
              logErr('Error updating status', mutationResult.exception);
            }
            return false;
          }

          return mutationResult.data?['SaveMediaListEntry'] != null;
        },
        maxRetries: 3,
        retryIf: RetryUtils.shouldRetryAnilistError,
        operationName: 'updateStatus(mediaId: $mediaId, status: $status)',
      );

      return result ?? false;
    } catch (e) {
      if (ConnectivityService().isOffline && RetryUtils.isExpectedOfflineError(e)) {
        logDebug('Cannot update status - device is offline');
        return false;
      }
      logErr('Error updating status', e);
      return false;
    }
  }

  /// Update score for an anime
  Future<bool> updateScore(int mediaId, int score) async {
    if (_client == null) return false;

    const mutation = r'''
      mutation UpdateScore($mediaId: Int!, $score: Float!) {
        SaveMediaListEntry(mediaId: $mediaId, score: $score) {
          id
          score
        }
      }
    ''';

    try {
      final result = await RetryUtils.retry<bool>(
        () async {
          final mutationResult = await _client!.mutate(
            MutationOptions(
              document: gql(mutation),
              variables: {
                'mediaId': mediaId,
                'score': score.toDouble(),
              },
            ),
          );

          if (mutationResult.hasException) {
            // Check if offline before logging
            if (!RetryUtils.isExpectedOfflineError(mutationResult.exception)) {
              logErr('Error updating score', mutationResult.exception);
            }
            return false;
          }

          return mutationResult.data?['SaveMediaListEntry'] != null;
        },
        maxRetries: 3,
        retryIf: RetryUtils.shouldRetryAnilistError,
        operationName: 'updateScore(mediaId: $mediaId, score: $score)',
      );

      return result ?? false;
    } catch (e) {
      if (ConnectivityService().isOffline && RetryUtils.isExpectedOfflineError(e)) {
        logDebug('Cannot update score - device is offline');
        return false;
      }
      logErr('Error updating score', e);
      return false;
    }
  }
}
