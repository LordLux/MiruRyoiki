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

  Series? getSeriesByAnilistId(int anilistId) => _series.firstWhereOrNull((s) => s.primaryAnilistId == anilistId);

  Series? getSeriesById(int id) => _series.firstWhereOrNull((s) => s.id == id);

  Future<void> addSeries(Series series) async {
    _series.add(series);
    await _saveLibrary();
    notifyListeners();
  }

  Future<void> removeSeries(Series series) async {
    _series.removeWhere((s) => s.path == series.path);
    await _saveLibrary();
    notifyListeners();
  }

  /// Save a single series with updated properties
  Future<void> updateSeries(Series series, {bool invalidateCache = true}) async {
    // Check if user actions are disabled
    if (_lockManager.shouldDisableAction(UserAction.updateSeriesInfo)) {
      snackBar(
        _lockManager.getDisabledReason(UserAction.updateSeriesInfo),
        severity: InfoBarSeverity.warning,
      );
      return;
    }

    final index = _series.indexWhere((s) => s.path == series.path);
    if (index < 0) return;

    final oldSeries = _series[index];

    // Check if images changed
    bool posterChanged = oldSeries.folderPosterPath != series.folderPosterPath;
    bool bannerChanged = oldSeries.folderBannerPath != series.folderBannerPath;
    bool anilistChanged = oldSeries.primaryAnilistId != series.primaryAnilistId;
    bool preferenceChanged = oldSeries.preferredPosterSource != series.preferredPosterSource || //
        oldSeries.preferredBannerSource != series.preferredBannerSource;

    // Recalculate dominant color if relevant changes occurred
    if (posterChanged || bannerChanged || anilistChanged || preferenceChanged) {
      logDebug('Image source changed for ${series.name} - updating dominant color');
      await series.calculateDominantColor(forceRecalculate: true);
    }

    // Update the series
    _series[index] = series;

    if (invalidateCache && homeKey.currentState != null) {
      homeKey.currentState!.seriesWasModified = true;
    }

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

  void markEpisodeWatched(Episode episode, {bool watched = true, bool save = true, bool overrideProgress = false}) {
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

    for (final episode in series.relatedMedia) {
      markEpisodeWatched(episode, watched: watched, save: false, overrideProgress: true);
    }

    // Set the flag indicating a series was modified
    if (homeKey.currentState != null) {
      homeKey.currentState!.seriesWasModified = true;
    }

    _saveLibrary();
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
