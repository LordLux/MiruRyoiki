part of 'library_provider.dart';

extension LibraryWatchTracking on Library {
  /// Called on every registry change event.
  // Future<void> _onMpcHistoryChanged() async {
  //   // Get only the changed files with their new percentages
  //   final changedPathsToPercentages = await _mpcTracker.checkForUpdates();

  //   if (changedPathsToPercentages.isEmpty) return;

  //   await _updateSpecificEpisodes(changedPathsToPercentages);
  // }
}
