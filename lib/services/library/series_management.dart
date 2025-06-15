part of 'library_provider.dart';

extension LibrarySeriesManagement on Library {
  Series? getSeriesByPath(PathString path) {
    return _series.firstWhereOrNull((s) => s.path == path);
  }

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
  Future<void> updateSeries(Series series) async {
    final index = _series.indexWhere((s) => s.path == series.path);
    if (index >= 0) {
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

      if (homeKey.currentState != null) {
        homeKey.currentState!.seriesWasModified = true;
      }

      logTrace('Series updated: ${series.name}, ${PathUtils.getFileName(series.effectivePosterPath ?? '')}, ${PathUtils.getFileName(series.effectiveBannerPath ?? '')}');
      _isDirty = true;
      await _saveLibrary();
      notifyListeners();
    }
  }

  Future<void> refreshEpisode(Episode episode) async {
    episode.watchedPercentage = _mpcTracker.getWatchPercentage(episode.path);
    episode.watched = _mpcTracker.isWatched(episode.path);
    await _saveLibrary();
    notifyListeners();
  }

  void markEpisodeWatched(Episode episode, {bool watched = true, bool save = true}) {
    episode.watched = watched;
    episode.watchedPercentage = watched ? 1.0 : 0.0;

    if (save) {
      _isDirty = true;

      // Set the flag indicating a series was modified
      if (homeKey.currentState != null) {
        homeKey.currentState!.seriesWasModified = true;
      }
      
      _saveLibrary();
      notifyListeners();
    }
  }

  void markSeasonWatched(Season season, {bool watched = true, bool save = true}) {
    for (final episode in season.episodes) //
      markEpisodeWatched(episode, watched: watched, save: false);

    if (save) {
      _isDirty = true;
      _saveLibrary();
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

    _isDirty = true;
    _saveLibrary();
    notifyListeners();
  }
}
