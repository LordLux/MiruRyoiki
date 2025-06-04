part of 'library_provider.dart';

extension LibraryWatchTracking on Library {
  Future<void> _processWatchedFiles() async {
    final watchedFiles = await _mpcTracker.checkForUpdates();
    bool updated = false;

    for (final filePath in watchedFiles) {
      for (final series in _series) {
        for (final season in series.seasons) {
          for (final episode in season.episodes) {
            if (episode.path == filePath && !episode.watched) {
              // Check if the episode is already watched
              // Mark the episode as watched
              episode.watched = true;
              episode.watchedPercentage = 1.0;
              updated = true;
            }
          }
        }

        // Check in related media
        for (final episode in series.relatedMedia) {
          if (episode.path == filePath && !episode.watched) {
            episode.watched = true;
            episode.watchedPercentage = 1.0;
            updated = true;
          }
        }
      }
    }

    if (updated) {
      _isDirty = true;
      _saveLibrary();
      notifyListeners();
    }
  }

  Future<void> playEpisode(Episode episode) async {
    try {
      await OpenAppFile.open(episode.path);
    } catch (e) {
      logErr('Error playing episode: ${episode.path}', e);
      snackBar('Could not play episode: ${episode.path}', severity: InfoBarSeverity.error);
    }
  }
}
