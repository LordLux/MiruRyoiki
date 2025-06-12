part of 'library_provider.dart';

extension LibraryWatchTracking on Library {
  /// Called on every registry change event.
  Future<void> _onMpcHistoryChanged() async {
    bool anyEpisodeUpdated = false;
    int updatedCount = 0;

    // Loop through all your series/episodes… adjust to your data structure
    for (final series in _series) {
      for (final season in series.seasons) {
        for (final episode in season.episodes) {
          final wasUpdated = _updateEpisodeWatchStatus(episode);
          if (wasUpdated) {
            anyEpisodeUpdated = true;
            updatedCount++;
          }
        }
      }
      for (final episode in series.relatedMedia) {
        final wasUpdated = _updateEpisodeWatchStatus(episode);
        if (wasUpdated) {
          anyEpisodeUpdated = true;
          updatedCount++;
        }
      }
    }

    if (anyEpisodeUpdated) {
      // mark dirty, persist immediately, then notify listeners/UI
      _isDirty = true;
      await forceImmediateSave();
      notifyListeners();
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
  bool _updateEpisodeWatchStatus(Episode episode) {
    final newPct = _mpcTracker.getWatchPercentage(episode.path);
    final wasWatched = episode.watched;

    if (episode.watchedPercentage != newPct) {
      episode.watchedPercentage = newPct;

      if (newPct >= MPCHCTracker.watchedThreshold && !wasWatched) {
        episode.watched = true;
      }
      return true;
    }
    return false;
  }
}
