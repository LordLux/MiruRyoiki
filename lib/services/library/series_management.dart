// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'library_provider.dart';

extension LibrarySeriesManagement on Library {
  Series? getSeriesByPath(PathString path) {
    // First check for exact match
    final exactMatch = _series.firstWhereOrNull((s) => s.path == path);
    if (exactMatch != null) return exactMatch;

    // If no exact match, check if the path is inside any series directory
    return _series.firstWhereOrNull((s) => p.isWithin(s.path.path, path.path));
  }

  /// Find an episode by file path across all series
  Episode? getEpisodeByPath(PathString path) {
    final series = getSeriesByPath(path);
    if (series != null) {
      for (final episode in series.collections.expand((c) => c.episodes)) {
        if (episode.path == path) return episode;
      }
    }

    // Brute-force: file is outside the library path (symlink target) or inference failed
    for (final series in _series) {
      for (final episode in series.collections.expand((c) => c.episodes)) {
        if (episode.path == path) return episode;
      }
    }
    return null;
  }

  Series? getSeriesByAnilistId(int anilistId) => _series.firstWhereOrNull((s) => s.anilistMappings.any((m) => m.anilistId == anilistId));

  T? applyFunctionToSeriesByAnilistId<T>(int anilistId, T Function(Series series) func) {
    // Check if user actions are disabled
    if (_lockManager.shouldDisableAction(UserAction.updateSeriesInfo)) {
      snackBar(
        _lockManager.getDisabledReason(UserAction.updateSeriesInfo),
        severity: InfoBarSeverity.warning,
      );
      null;
    }

    for (final series in _series) {
      if (series.anilistMappings.any((m) => m.anilistId == anilistId)) {
        return func(series); // Returns after first match
      }
    }
    return null; // No match found
  }

  T? applyFunctionToSeriesById<T>(int id, T Function(Series series) func) {
    for (final series in _series) {
      if (series.id == id) return func(series); // Returns after first match
    }
    return null; // No match found
  }

  T? applyFunctionToSeriesByPath<T>(PathString path, T Function(Series series) func) {
    final series = getSeriesByPath(path);
    if (series != null) return func(series);
    return null;
  }

  Series? getSeriesById(int id) => _series.firstWhereOrNull((s) => s.id == id);

  Future<void> addSeries(Series series) async {
    _series.add(series);
    _incrementDataVersion();
    _markDirty(series);
    await persistLibrary();
    notifyListeners();
  }

  Future<void> removeSeries(Series series) async {
    _series.removeWhere((s) => s.path == series.path);
    _incrementDataVersion();
    _hasPendingDeletions = true;
    await persistLibrary();
    notifyListeners();
  }

  Future<void> updateMappingLastSynced(Series series, int anilistId, DateTime lastSynced) async {
    final mappingIndex = series.anilistMappings.indexWhere((m) => m.anilistId == anilistId);
    if (mappingIndex == -1) return;

    // Update in memory
    series.anilistMappings[mappingIndex].lastSynced = lastSynced;

    // Update DB
    if (series.id != null) await seriesDao.updateMappingLastSynced(series.id!, anilistId, lastSynced);

    // notifyListeners() not needed
  }

  Future<void> updateMappingAnilistData(Series series, int anilistId, AnilistAnime anilistData, DateTime lastSynced) async {
    final mappingIndex = series.anilistMappings.indexWhere((m) => m.anilistId == anilistId);
    if (mappingIndex == -1) return;

    // Update in memory
    series.anilistMappings[mappingIndex].anilistData = anilistData;
    series.anilistMappings[mappingIndex].lastSynced = lastSynced;

    // Update DB
    if (series.id != null) await seriesDao.updateMappingAnilistData(series.id!, anilistId, anilistData, lastSynced);

    _incrementDataVersion();
    notifyListeners();
  }

  /// Update the view type for a specific mapping
  Future<void> updateMappingViewType(int anilistId, ViewType viewType) async {
    final seriesIndex = _series.indexWhere((s) => s.anilistMappings.any((m) => m.anilistId == anilistId));
    if (seriesIndex == -1) return;

    final series = _series[seriesIndex];

    final mappingIndex = series.anilistMappings.indexWhere((m) => m.anilistId == anilistId);
    if (mappingIndex == -1) return;

    final updatedMapping = series.anilistMappings[mappingIndex].copyWith(viewType: viewType);

    final updatedMappings = List<AnilistMapping>.from(series.anilistMappings);
    updatedMappings[mappingIndex] = updatedMapping;

    final updatedSeries = series.copyWith(anilistMappings: updatedMappings);

    _series[seriesIndex] = updatedSeries;
    _incrementDataVersion();

    await seriesDao.updateMappingViewType(anilistId, viewType);
    notifyListeners();
  }

  /// Save a single series with updated properties
  Future<void> updateSeries(Series series, {bool invalidateCache = true}) async {
    final index = _series.indexWhere((s) => s.path == series.path);
    if (index < 0) return;

    final oldSeries = _series[index];

    // Check if images changed
    bool posterChanged = oldSeries.localPosterPath != series.localPosterPath;
    bool bannerChanged = oldSeries.localBannerPath != series.localBannerPath;
    bool anilistChanged = oldSeries.primaryAnilistId != series.primaryAnilistId;
    bool preferenceChanged = oldSeries.preferredPosterSource != series.preferredPosterSource || //
        oldSeries.preferredBannerSource != series.preferredBannerSource;

    // Recalculate dominant color if relevant changes occurred
    if (posterChanged && !bannerChanged) {
      logDebug('Image source changed for ${series.name} - updating dominant colors');
      await series.effectivePrimaryColor(forceRecalculate: true, overrideIsPoster: true); // poster
    } else if (bannerChanged && !posterChanged) {
      logDebug('Image source changed for ${series.name} - updating dominant colors');
      await series.effectivePrimaryColor(forceRecalculate: true, overrideIsPoster: false); // banner
    } else if (anilistChanged || preferenceChanged) {
      logDebug('Anilist mapping or preference changed for ${series.name} - updating dominant colors');
      await series.effectivePrimaryColor(forceRecalculate: true, overrideIsPoster: true); // poster
      await series.effectivePrimaryColor(forceRecalculate: true, overrideIsPoster: false); // banner
    }

    // Update the series
    _series[index] = series;
    _incrementDataVersion(); // Invalidate caches when series updated

    if (invalidateCache && homeKey.currentState != null) homeKey.currentState!.seriesWasModified = true;

    logTrace('Series updated: ${series.name}, ${PathUtils.getFileName(series.effectivePosterPath ?? '')}, ${PathUtils.getFileName(series.effectiveBannerPath ?? '')}');

    // Acquire database save lock
    final saveLockHandle = await _lockManager.acquireLock(
      OperationType.databaseSave,
      description: 'saving series update',
      waitForOthers: true,
    );

    try {
      _markDirty(series);
      await persistLibrary();
      notifyListeners();
    } finally {
      saveLockHandle?.dispose();
    }
    notifyListeners();
  }

  Future<void> playEpisode(Episode episode) async {
    // If the OS default player is MPC-HC, launch it in slave mode
    try {
      final monitor = Provider.of<MediaPlayerMonitorService>(Manager.context, listen: false);
      if (await monitor.tryLaunchViaSlave(episode.path)) return;
    } catch (e, stackTrace) {
      logErr('MPC-HC slave launch failed; falling back to default open', e, stackTrace);
    }

    try {
      // In case the MPC-HC slave launch fails, open with the OS default handler and let the media player system monitor it
      openFile(episode.path);
    } catch (e, stackTrace) {
      snackBar(
        'Could not play episode: ${episode.path}',
        severity: InfoBarSeverity.error,
        exception: e,
        stackTrace: stackTrace,
      );
    }
  }

  void playNextEpisode(MappingTarget target) {
    for (final episode in target.episodes) {
      if (episode.watched == false) {
        playEpisode(episode);
        return;
      }
    }
  }

  /// Play the next unwatched episode for the whole series, crossing seasons/folders.
  ///
  /// For linked series this uses [AnilistProgressManager] (which handles per-season
  /// vs absolute numbering and cross-season transitions); otherwise it falls back to
  /// the first unwatched episode in display (collection) order.
  void playNextEpisodeForSeries(Series series) {
    Episode? next;

    if (series.isLinked) {
      try {
        final provider = Provider.of<AnilistProvider>(Manager.context, listen: false);
        next = AnilistProgressManager.instance.getNextEpisodeToWatch(series, provider);
      } catch (e, st) {
        logErr('playNextEpisodeForSeries: progress lookup failed', e, st);
      }
    }

    // Fallback: first unwatched episode in display order
    next ??= series.collections.expand((c) => c.episodes).firstWhereOrNull((e) => !e.watched);

    if (next == null) {
      snackBar('No unwatched episodes', severity: InfoBarSeverity.info);
      return;
    }

    playEpisode(next);
  }

  void markEpisodeWatched(
    /// The episode to mark
    Episode episode, {
    /// True to mark as watched, false to unmark
    bool watched = true,

    /// Whether to save the library after marking
    bool save = true,

    /// Whether to override progress when marking as unwatched
    bool overrideProgress = false,
  }) {
    // Check if user actions are disabled
    if (_lockManager.shouldDisableAction(UserAction.markEpisodeWatched)) {
      snackBar(
        _lockManager.getDisabledReason(UserAction.markEpisodeWatched),
        severity: InfoBarSeverity.warning,
      );
      return;
    }

    episode.watched = watched;
    if (watched) episode.progress = 1.0; // always override to 1 when watched, but not when unwatching
    if (overrideProgress && !watched) episode.progress = 0.0; // reset progress when unmarking as watched and overrideProgress is true

    if (save) {
      // Set the flag indicating a series was modified
      if (homeKey.currentState != null) homeKey.currentState!.seriesWasModified = true;

      // Find the series containing this episode and mark it dirty
      final series = _series.firstWhereOrNull((s) => //
          s.collections.any((c) => c.episodes.contains(episode)));
      if (series != null) _markDirty(series);
      _scheduleDebouncedSave();
      notifyListeners();
    }
  }

  void markEpisodesWatched(List<Episode> episodes, {bool watched = true, bool save = true, bool overrideProgress = false}) {
    // Check if user actions are disabled
    if (_lockManager.shouldDisableAction(UserAction.markEpisodeWatched)) {
      snackBar(
        _lockManager.getDisabledReason(UserAction.markEpisodeWatched),
        severity: InfoBarSeverity.warning,
      );
      return;
    }
    for (final episode in episodes) {
      episode.watched = watched;
      if (watched) episode.progress = 1.0; // always override to 1 when watched, but not when unwatching
      if (overrideProgress && !watched) episode.progress = 0.0; // reset progress when unmarking as watched and overrideProgress is true
    }

    if (save) {
      // Set the flag indicating a series was modified
      if (homeKey.currentState != null) homeKey.currentState!.seriesWasModified = true;

      // Find series containing these episodes and mark dirty
      for (final episode in episodes) {
        final series = _series.firstWhereOrNull((s) => s.collections.any((c) => c.episodes.contains(episode)));
        if (series != null) _markDirty(series);
      }
      _scheduleDebouncedSave();
      notifyListeners();
    }
  }

  /// Within the episode's own collection, mark every episode up to and including
  /// [episode] as watched, and every episode after it as unwatched.
  ///
  /// Episodes are ordered by [Episode.episodeNumber]; episodes with a null number
  /// keep their original list order (stable, sorted last among numbered ones).
  /// Local-only by design — matches the other mark methods.
  void setProgressUpToEpisode(Episode episode, Series series, {bool save = true}) {
    // Check if user actions are disabled
    if (_lockManager.shouldDisableAction(UserAction.markEpisodeWatched)) {
      snackBar(
        _lockManager.getDisabledReason(UserAction.markEpisodeWatched),
        severity: InfoBarSeverity.warning,
      );
      return;
    }

    // Find the collection that owns this episode
    final collection = series.collections.firstWhereOrNull((c) => c.episodes.contains(episode));
    if (collection == null) {
      logWarn('setProgressUpToEpisode: episode not found in any collection of ${series.name}');
      return;
    }

    // Stable order by episodeNumber, falling back to original list order (nulls last)
    final indexed = <(int, Episode)>[
      for (int i = 0; i < collection.episodes.length; i++) (i, collection.episodes[i])
    ];
    indexed.sort((a, b) {
      final an = a.$2.episodeNumber;
      final bn = b.$2.episodeNumber;
      if (an != null && bn != null && an != bn) return an.compareTo(bn);
      if (an == null && bn != null) return 1; // nulls last
      if (an != null && bn == null) return -1;
      return a.$1.compareTo(b.$1); // stable tiebreak by original index
    });
    final ordered = [for (final e in indexed) e.$2];

    // Use == (id/path-based) rather than identical(): must match the `contains`
    // check above, which also uses ==, so an equal-but-not-same instance
    // (e.g. a copy from a UI wrapper) still resolves to the right pivot.
    final pivotIndex = ordered.indexWhere((e) => e == episode);
    if (pivotIndex == -1) {
      logWarn('setProgressUpToEpisode: pivot episode not found in its collection (${episode.path})');
      return;
    }

    final upToAndIncluding = ordered.sublist(0, pivotIndex + 1);
    final after = ordered.sublist(pivotIndex + 1);

    markEpisodesWatched(upToAndIncluding, watched: true, save: false);
    markEpisodesWatched(after, watched: false, overrideProgress: true, save: false);

    if (save) {
      if (homeKey.currentState != null) homeKey.currentState!.seriesWasModified = true;
      _markDirty(series);
      _scheduleDebouncedSave();
      notifyListeners();
    }
  }

  void markSeasonWatched(EpisodeCollection season, {bool watched = true, bool save = true}) {
    // Check if user actions are disabled
    if (_lockManager.shouldDisableAction(UserAction.markSeriesWatched)) {
      snackBar(
        _lockManager.getDisabledReason(UserAction.markSeriesWatched),
        severity: InfoBarSeverity.warning,
      );
      return;
    }

    for (final episode in season.episodes) //
      markEpisodeWatched(episode, watched: watched, save: false, overrideProgress: true);

    if (save) {
      // Find the series containing this season and mark dirty
      final parentSeries = _series.firstWhereOrNull((s) => s.collections.contains(season));
      if (parentSeries != null) _markDirty(parentSeries);
      _scheduleDebouncedSave();
      notifyListeners();
    }
  }

  void markSeriesWatched(Series series, {bool watched = true}) {
    // Check if user actions are disabled
    if (_lockManager.shouldDisableAction(UserAction.markSeriesWatched)) {
      snackBar(
        _lockManager.getDisabledReason(UserAction.markSeriesWatched),
        severity: InfoBarSeverity.warning,
      );
      return;
    }

    for (final collection in series.collections) //
      markSeasonWatched(collection, watched: watched, save: false);

    // Set the flag indicating a series was modified
    if (homeKey.currentState != null) homeKey.currentState!.seriesWasModified = true;

    _markDirty(series);
    _scheduleDebouncedSave();
    notifyListeners();
  }

  void markTargetWatched(MappingTarget target, {bool watched = true}) {
    // Check if user actions are disabled
    if (_lockManager.shouldDisableAction(UserAction.markSeriesWatched)) {
      snackBar(
        _lockManager.getDisabledReason(UserAction.markSeriesWatched),
        severity: InfoBarSeverity.warning,
      );
      return;
    }

    if (target.isCollection) {
      final collection = target.asCollection;
      if (collection != null) {
        // Recursive: a folder represents everything inside it, so mark this
        // collection's episodes AND any nested sub-collections (matched by path).
        // Keeps "mark watched" consistent with the recursive progress shown on
        // folder cards. Falls back to shallow if the owning series isn't found.
        final owner = _series.firstWhereOrNull((s) => s.collections.contains(collection));
        if (owner != null) {
          final folderPath = collection.path.path;
          final episodes = owner.collections //
              .where((c) => c.path.path == folderPath || p.isWithin(folderPath, c.path.path))
              .expand((c) => c.episodes)
              .toList();
          markEpisodesWatched(episodes, watched: watched, save: false, overrideProgress: true);
        } else {
          markSeasonWatched(collection, watched: watched, save: false);
        }
      }
    } else {
      final episode = target.asEpisode;
      if (episode != null) markEpisodeWatched(episode, watched: watched, save: false, overrideProgress: true);
    }

    // Set the flag indicating a series was modified
    if (homeKey.currentState != null) homeKey.currentState!.seriesWasModified = true;

    // Mark the series that owns this target as dirty
    final parentSeries = _series.firstWhereOrNull((s) => s.collections.any((c) => c.episodes.any((e) => target.episodes.contains(e))));
    if (parentSeries != null) _markDirty(parentSeries);
    _scheduleDebouncedSave();
    notifyListeners();
  }

  void removeMapping(Series series, MappingTarget target) {
    // Check if user actions are disabled
    if (_lockManager.shouldDisableAction(UserAction.updateSeriesInfo)) {
      snackBar(
        _lockManager.getDisabledReason(UserAction.updateSeriesInfo),
        severity: InfoBarSeverity.warning,
      );
      return;
    }

    // Remove the mapping from the series inside the _series list
    final index = _series.indexWhere((s) => s.path == series.path);
    bool success = false;
    if (index != -1) success = _series[index].removeMapping(target);

    if (success) {
      _markDirty(series);
      seriesDao.syncSeries(series);
      notifyListeners();
    } else {
      snackBar('Failed to remove mapping', severity: InfoBarSeverity.error);
    }
    notifyListeners();
  }

  /// Clear thumbnail cache for a specific series and reset episode thumbnail statuses
  Future<void> clearThumbnailCacheForSeries(PathString? seriesPath) async {
    if (seriesPath == null) return;

    final series = getSeriesByPath(seriesPath);
    if (series == null) {
      logErr('Series not found for path: ${seriesPath.path}');
      return;
    }

    // Clear the thumbnail cache for this series
    await ThumbnailManager().clearThumbnailCacheForSeries(seriesPath.path);
    notifyListeners();
    notifyListeners();

    // Reset thumbnail statuses for all episodes in this series
    for (final collection in series.collections) {
      for (final episode in collection.episodes) {
        episode.resetThumbnailStatus();
        episode.thumbnailPath = null; // Clear the cached path so it will be regenerated
      }
    }

    _markDirty(series);
    await persistLibrary();
    notifyListeners();

    logDebug('Cleared thumbnail cache and reset statuses for series: ${series.name}');
  }

  /// Clear all thumbnail cache and reset all episode thumbnail statuses
  Future<void> clearAllThumbnailCache() async {
    // Clear all thumbnail caches
    await ThumbnailManager().clearAllThumbnailCache();
    await ImageCacheService().clearCache();
    notifyListeners();
    notifyListeners();

    // Reset all episode thumbnail statuses
    for (final series in _series) {
      for (final collection in series.collections) {
        for (final episode in collection.episodes) {
          episode.resetThumbnailStatus();
          episode.thumbnailPath = null;
        }
      }
    }

    // Reset all failed attempts in ThumbnailManager
    Episode.resetAllFailedAttempts();

    _markAllDirty();
    await persistLibrary();
    notifyListeners();

    logDebug('Cleared all thumbnail cache and reset all episode thumbnail statuses');
  }
}
