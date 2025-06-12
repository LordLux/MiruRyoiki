part of 'library_provider.dart';

extension LibraryWatchTracking on Library {
  /// Called on every registry change event.
  Future<void> _onMpcHistoryChanged() async {
    // Get only the changed files with their new percentages
    final changedPathsToPercentages = await _mpcTracker.checkForUpdates();

    if (changedPathsToPercentages.isEmpty) return;

    await _updateSpecificEpisodes(changedPathsToPercentages);
  }

  Future<void> _updateSpecificEpisodes(Map<String, double> changedFiles) async {
    bool anyEpisodeUpdated = false;
    int updatedCount = 0;

    // Loop through all series/episodes
    for (final series in _series) {
      for (final season in series.seasons) {
        for (final episode in season.episodes) {
          final path = episode.path.path;
          if (!changedFiles.containsKey(path)) continue; // Skip if not changed

          if (_updateEpisodeWatchStatus(episode, changedFiles[path]!)) {
            anyEpisodeUpdated = true;
            updatedCount++;
          }
        }
      }

      for (final episode in series.relatedMedia) {
        final path = episode.path.path;
        if (!changedFiles.containsKey(path)) continue; // Skip if not changed

        if (_updateEpisodeWatchStatus(episode, changedFiles[path]!)) {
          anyEpisodeUpdated = true;
          updatedCount++;
        }
      }
    }

    if (anyEpisodeUpdated) {
      logDebug('Updated watch status for $updatedCount episodes');
      _isDirty = true;
      await forceImmediateSave();
      notifyListeners();
      Manager.setState();
    }
  }

  Future<void> playEpisode(Episode episode) async {
    try {
      await OpenAppFile.open(episode.path.path);
    } catch (e) {
      logErr('Error playing episode: ${episode.path}', e);
      snackBar('Could not play episode: ${episode.path}', severity: InfoBarSeverity.error);
    }
  }

  /// Updates an episode's watch status and returns true if it was changed
  bool _updateEpisodeWatchStatus(Episode episode, [double? newPercentage]) {
    final newPct = newPercentage ?? _mpcTracker.getWatchPercentage(episode.path);
    final wasWatched = episode.watched;

    if (episode.watchedPercentage != newPct) {
      episode.watchedPercentage = newPct;

      if (newPct >= MPCHCTracker.watchedThreshold && !wasWatched)
        episode.watched = true;
      else if (newPct < MPCHCTracker.watchedThreshold && wasWatched) //
        episode.watched = false;

      return true;
    }
    return false;
  }
}
