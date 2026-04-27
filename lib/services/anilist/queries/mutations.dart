part of 'anilist_service.dart';

extension AnilistServiceMutations on AnilistService {
  /// Comprehensive save/update of a media list entry.
  /// Only non-null fields are sent to the API.
  ///
  /// [scoreRaw] is the score in 0-100 raw format (format-independent).
  /// Our internal POINT_10 values should be multiplied by 10 before passing here.
  Future<Map<String, dynamic>?> saveMediaListEntry({
    int? id,
    int? mediaId,
    AnilistListApiStatus? status,
    int? scoreRaw,
    int? progress,
    int? repeat,
    int? priority,
    bool? private,
    String? notes,
    bool? hiddenFromStatusLists,
    List<String>? customLists,
    DateValue? startedAt,
    DateValue? completedAt,
  }) async {
    final statusEnum = status != null
        ? Enum$MediaListStatus.values.firstWhereOrNull((e) => e.name == status.name_)
        : null;

    if (status != null && statusEnum == null) return null;

    final result = await executeMutation<Mutation$SaveMediaListEntry>(
      options: MutationOptions(
        document: documentNodeMutationSaveMediaListEntry,
        variables: Variables$Mutation$SaveMediaListEntry(
          id: id,
          mediaId: mediaId,
          status: statusEnum,
          scoreRaw: scoreRaw,
          progress: progress,
          repeat: repeat,
          priority: priority,
          private: private,
          notes: notes,
          hiddenFromStatusLists: hiddenFromStatusLists,
          customLists: customLists,
          startedAt: startedAt != null ? Input$FuzzyDateInput(year: startedAt.year, month: startedAt.month, day: startedAt.day) : null,
          completedAt: completedAt != null ? Input$FuzzyDateInput(year: completedAt.year, month: completedAt.month, day: completedAt.day) : null,
        ).toJson(),
      ),
      operationName: 'SaveMediaListEntry',
      parser: (data) => Mutation$SaveMediaListEntry.fromJson(data),
    );

    return result?.SaveMediaListEntry?.toJson();
  }

  /// Delete a media list entry by its list entry ID (not media ID).
  Future<bool> deleteMediaListEntry(int entryId) async {
    final result = await executeMutation<Mutation$DeleteMediaListEntry>(
      options: MutationOptions(
        document: documentNodeMutationDeleteMediaListEntry,
        variables: Variables$Mutation$DeleteMediaListEntry(id: entryId).toJson(),
      ),
      operationName: 'DeleteMediaListEntry',
      parser: (data) => Mutation$DeleteMediaListEntry.fromJson(data),
    );

    return result?.DeleteMediaListEntry?.deleted == true;
  }

  /// Toggle favourite status for an anime.
  /// Returns true if the mutation succeeded (the new state is not returned —
  /// the caller should refetch the anime or toggle locally).
  Future<bool> toggleFavourite(int animeId) async {
    final result = await executeMutation<Mutation$ToggleFavourite>(
      options: MutationOptions(
        document: documentNodeMutationToggleFavourite,
        variables: Variables$Mutation$ToggleFavourite(animeId: animeId).toJson(),
      ),
      operationName: 'ToggleFavourite',
      parser: (data) => Mutation$ToggleFavourite.fromJson(data),
    );

    return result != null;
  }

  // -- Convenience wrappers for common single-field updates --

  /// Update progress for an anime
  Future<bool> updateProgress(int mediaId, int progress) async {
    final entry = await saveMediaListEntry(mediaId: mediaId, progress: progress);
    return entry != null;
  }

  /// Update status for an anime
  Future<bool> updateStatus(int mediaId, AnilistListApiStatus status) async {
    final entry = await saveMediaListEntry(mediaId: mediaId, status: status);
    return entry != null;
  }

  /// Update score for an anime. [score] is in POINT_100 (0-100, format-independent).
  Future<bool> updateScore(int mediaId, int score) async {
    final entry = await saveMediaListEntry(mediaId: mediaId, scoreRaw: score);
    return entry != null;
  }
}
