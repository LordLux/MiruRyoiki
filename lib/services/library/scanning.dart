part of 'library_provider.dart';

extension LibraryScanning on Library {
  Future<void> updateLibraryPathAndReload(String path) async {
    _libraryPath = path;
    await _saveSettings();
    await reloadLibrary();
  }

  Future<void> syncLibraryWithScanResults({
    required List<Series> updatedSeriesList,
    required Set<PathString> newSeriesPaths,
    required Set<PathString> deletedSeriesPaths,
    required Set<PathString> dirtySeriesPaths,
    required bool anyChanged,
  }) async {
    _series = updatedSeriesList;
    _dataVersion++;

    _markDirtyPaths(newSeriesPaths);
    if (deletedSeriesPaths.isNotEmpty) _hasPendingDeletions = true;
    _markDirtyPaths(dirtySeriesPaths);

    if (anyChanged) await persistLibrary();

    notifyListeners();
  }
}
