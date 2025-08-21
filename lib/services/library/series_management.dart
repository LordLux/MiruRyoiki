part of 'library_provider.dart';

extension LibrarySeriesManagement on Library {
  Series? getSeriesByPath(PathString path) {
    return _series.firstWhereOrNull((s) => s.path == path);
  }

  Future<void> addSeries(Series series) async {
    _series.add(series);
  _version++;
    await _saveLibrary();
    notifyListeners();
  }

  Future<void> removeSeries(Series series) async {
    _series.removeWhere((s) => s.path == series.path);
  _version++;
    await _saveLibrary();
    notifyListeners();
  }

  /// Save a single series with updated properties
  Future<void> updateSeries(Series series, {bool invalidateCache = true}) async {
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
  _version++;

    if (invalidateCache && homeKey.currentState != null) {
      homeKey.currentState!.seriesWasModified = true;
    }

    logTrace('Series updated: ${series.name}, ${PathUtils.getFileName(series.effectivePosterPath ?? '')}, ${PathUtils.getFileName(series.effectiveBannerPath ?? '')}');
    await _saveLibrary();
    notifyListeners();
  }
  
  Future<void> playEpisode(Episode episode) async {
    try {
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

  Future<void> refreshEpisode(Episode episode) async {
    // TODO get watched percentage and watched status from player
    _version++;
    await _saveLibrary();
    notifyListeners();
  }

  void markEpisodeWatched(Episode episode, {bool watched = true, bool save = true}) {
    episode.watched = watched;
    episode.progress = watched ? 1.0 : 0.0;

    if (save) {
      // Set the flag indicating a series was modified
      if (homeKey.currentState != null) {
        homeKey.currentState!.seriesWasModified = true;
      }

      _saveLibrary();
  _version++;
      notifyListeners();
    }
  }

  void markSeasonWatched(Season season, {bool watched = true, bool save = true}) {
    for (final episode in season.episodes) //
      markEpisodeWatched(episode, watched: watched, save: false);

    if (save) {
      _saveLibrary();
  _version++;
      notifyListeners();
    }
  }

  void markSeriesWatched(Series series, {bool watched = true}) {
    for (final season in series.seasons) //
      markSeasonWatched(season, watched: watched, save: false);

    for (final episode in series.relatedMedia) {
      markEpisodeWatched(episode, watched: watched, save: false);
    }

    // Set the flag indicating a series was modified
    if (homeKey.currentState != null) {
      homeKey.currentState!.seriesWasModified = true;
    }

    _saveLibrary();
  _version++;
    notifyListeners();
  }

  /// Clear thumbnail cache for a specific series and reset episode thumbnail statuses
  Future<void> clearThumbnailCacheForSeries(PathString seriesPath) async {
    final series = getSeriesByPath(seriesPath);
    if (series == null) return;

    // Clear the thumbnail cache for this series
    await ThumbnailManager().clearThumbnailCacheForSeries(seriesPath.path);

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

    _version++;
    await _saveLibrary();
    notifyListeners();

    logDebug('Cleared thumbnail cache and reset statuses for series: ${series.name}');
  }

  /// Clear all thumbnail cache and reset all episode thumbnail statuses
  Future<void> clearAllThumbnailCache() async {
    // Clear all thumbnail caches
    await ThumbnailManager().clearAllThumbnailCache();
    await ImageCacheService().clearCache();

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

    _version++;
    await _saveLibrary();
    notifyListeners();

    logDebug('Cleared all thumbnail cache and reset all episode thumbnail statuses');
  }
}
