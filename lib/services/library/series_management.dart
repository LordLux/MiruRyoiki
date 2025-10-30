part of 'library_provider.dart';

extension LibrarySeriesManagement on Library {
  Series? getSeriesByPath(PathString path) {
    // First check for exact match
    final exactMatch = _series.firstWhereOrNull((s) => s.path == path);
    if (exactMatch != null) return exactMatch;

    // If no exact match, check if the path is inside any series directory
    return _series.firstWhereOrNull((s) {
      // Check if the given path starts with the series path
      if (path.path.startsWith(s.path.path)) {
        // Get the relative path from series to the given path
        final relativePath = path.path.substring(s.path.path.length);

        // If the relative path is empty or starts with a separator, it's inside this series
        return relativePath.isEmpty || relativePath.startsWith('/') || relativePath.startsWith('\\');
      }
      return false;
    });
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
    _dataVersion++;
    await _saveLibrary();
    notifyListeners();
  }

  Future<void> removeSeries(Series series) async {
    _series.removeWhere((s) => s.path == series.path);
    _dataVersion++;
    await _saveLibrary();
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
    _dataVersion++; // Invalidate caches when series updated

    if (invalidateCache && homeKey.currentState != null) homeKey.currentState!.seriesWasModified = true;

    logTrace('Series updated: ${series.name}, ${PathUtils.getFileName(series.effectivePosterPath ?? '')}, ${PathUtils.getFileName(series.effectiveBannerPath ?? '')}');

    // Acquire database save lock
    final saveLockHandle = await _lockManager.acquireLock(
      OperationType.databaseSave,
      description: 'saving series update',
      waitForOthers: true,
    );

    try {
      await _saveLibrary();
      notifyListeners();
    } finally {
      saveLockHandle?.dispose();
    }
    notifyListeners();
  }

  Future<void> playEpisode(Episode episode) async {
    try {
      // Use openFile and monitor by the media player system
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

      _saveLibrary();
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

      _saveLibrary();
      notifyListeners();
    }
  }

  void markSeasonWatched(Season season, {bool watched = true, bool save = true}) {
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
      _saveLibrary();
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

    for (final season in series.seasons) //
      markSeasonWatched(season, watched: watched, save: false);

    for (final episode in series.relatedMedia) //
      markEpisodeWatched(episode, watched: watched, save: false, overrideProgress: true);

    // Set the flag indicating a series was modified
    if (homeKey.currentState != null) homeKey.currentState!.seriesWasModified = true;

    _saveLibrary();
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

    if (target.isSeason) {
      final season = target.asSeason;
      if (season != null) markSeasonWatched(season, watched: watched, save: false);
    } else {
      final episode = target.asEpisode;
      if (episode != null) markEpisodeWatched(episode, watched: watched, save: false, overrideProgress: true);
    }

    // Set the flag indicating a series was modified
    if (homeKey.currentState != null) homeKey.currentState!.seriesWasModified = true;

    _saveLibrary();
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
      snackBar('Mapping removed', severity: InfoBarSeverity.success);
    } else {
      snackBar('Failed to remove mapping', severity: InfoBarSeverity.error);
    }
    Manager.setState();
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
    Manager.setState();

    // Reset thumbnail statuses for all episodes in this series
    for (final season in series.seasons) {
      for (final episode in season.episodes) {
        episode.resetThumbnailStatus();
        episode.thumbnailPath = null; // Clear the cached path so it will be regenerated
      }
    }

    // Also reset for related media episodes
    for (final episode in series.relatedMedia) {
      episode.resetThumbnailStatus();
      episode.thumbnailPath = null;
    }

    await _saveLibrary();
    notifyListeners();

    logDebug('Cleared thumbnail cache and reset statuses for series: ${series.name}');
  }

  /// Clear all thumbnail cache and reset all episode thumbnail statuses
  Future<void> clearAllThumbnailCache() async {
    // Clear all thumbnail caches
    await ThumbnailManager().clearAllThumbnailCache();
    await ImageCacheService().clearCache();
    notifyListeners();
    Manager.setState();

    // Reset all episode thumbnail statuses
    for (final series in _series) {
      for (final season in series.seasons) {
        for (final episode in season.episodes) {
          episode.resetThumbnailStatus();
          episode.thumbnailPath = null;
        }
      }
      for (final episode in series.relatedMedia) {
        episode.resetThumbnailStatus();
        episode.thumbnailPath = null;
      }
    }

    // Reset all failed attempts in ThumbnailManager
    Episode.resetAllFailedAttempts();

    await _saveLibrary();
    notifyListeners();

    logDebug('Cleared all thumbnail cache and reset all episode thumbnail statuses');
  }
}
