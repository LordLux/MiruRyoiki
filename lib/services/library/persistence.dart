
part of 'library_provider.dart';

extension LibraryPersistence on Library {
  /// Load settings from saved JSON file
  Future<void> _loadSettings() async {
    try {
      final dir = miruRyoikiSaveDirectory;
      final file = File('${dir.path}/${Library.settingsFileName}.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content);
        _libraryPath = data['libraryPath']; // TODO validate path exists and is a directory
        logDebug('0 | Loaded settings: $_libraryPath');
      }
    } catch (e, st) {
      logErr('0 | Error loading settings', e, st);
    }
  }

  /// Save settings to JSON file
  Future<void> _saveSettings() async {
    try {
      final dir = miruRyoikiSaveDirectory;
      final file = File('${dir.path}/${Library.settingsFileName}.json');

      final data = {
        'libraryPath': _libraryPath,
      };

      await file.writeAsString(jsonEncode(data));
    } catch (e, st) {
      logErr('Error saving settings', e, st);
    }
  }

  /// Load library from saved database
  Future<void> _loadLibrary() async {
    try {
      await _loadSettings();

      // Bulk-load all series
      _series = await seriesDao.loadAllSeries();

      logDebug('>> Loaded ${_series.length} series from DB');

      // Initialize hidden series cache after loading
      _hiddenSeriesService.rebuildCache(_series);

      // Increment data version since series data was loaded
      _incrementDataVersion();
    } catch (e, st) {
      handleDatabaseError(e, st, 'loading library from DB');
      _series = [];
    }
    notifyListeners();
  }

  /// Perform the actual save operation
  Future<void> persistLibrary({bool forceFull = false}) async {
    // nothing to do
    if (!forceFull && _dirtySeries.isEmpty && !_hasPendingDeletions) {
      logTrace('nothing dirty, skipping...');
      return;
    }

    logDebug('>> Syncing library with database (dirty: ${_dirtySeries.length}, deletions: $_hasPendingDeletions, forceFull: $forceFull)...');

    // Show indeterminate progress bar
    LibraryScanProgressManager().showIndeterminate(text: 'Saving changes...');

    try {
      // Deletions
      if (_hasPendingDeletions || forceFull) {
        final dbSeriesRows = await seriesDao.getAllSeriesRows();
        final dbSeriesPaths = dbSeriesRows.map((row) => row.path.path).toSet();
        final modelSeriesPaths = _series.map((s) => s.path.path).toSet();

        final pathsToDelete = dbSeriesPaths.difference(modelSeriesPaths);
        for (final path in pathsToDelete) {
          final row = dbSeriesRows.firstWhere((r) => r.path.path == path);
          await seriesDao.deleteSeriesRow(row.id);
        }
        if (pathsToDelete.isNotEmpty) logTrace('   - Deleted ${pathsToDelete.length} series from DB.');
        _hasPendingDeletions = false;
      }

      // Determine series to sync
      final seriesToSync = forceFull //
          ? _series
          : _series.where((s) => _dirtySeries.contains(s.path)).toList();

      if (seriesToSync.isNotEmpty) {
        await seriesDao.syncSeriesBatch(seriesToSync);
        logTrace('   - Synced ${seriesToSync.length} series.');
      }

      _dirtySeries.clear();

      logDebug('>> Library sync with DB complete.');
    } catch (e, st) {
      handleDatabaseError(e, st, 'syncing library to DB');
    } finally {
      LibraryScanProgressManager().hide();
    }
  }

  /// Mark a single series as needing a DB sync on the next save
  void _markDirty(Series series) => _dirtySeries.add(series.path);

  /// Mark specific series paths as dirty
  void _markDirtyPaths(Iterable<PathString> paths) => _dirtySeries.addAll(paths);

  /// Mark all series as dirty
  void _markAllDirty() => _dirtySeries.addAll(_series.map((s) => s.path));

  /// Save only a specific series immediately (bypasses dirty set).
  /// Use for targeted single-series saves like episode progress updates.
  // ignore: unused_element
  Future<void> _saveSingleSeries(Series series) async {
    try {
      await seriesDao.syncSeries(series);
      // Remove from dirty set since it's now saved
      _dirtySeries.remove(series.path);
    } catch (e, st) {
      handleDatabaseError(e, st, 'saving single series ${series.name}');
    }
  }

  /// Save only an episode's progress and watched status directly by ID
  Future<bool> saveEpisodeProgress(Episode episode) async {
    if (episode.id == null) return false;
    try {
      await seriesDao.updateEpisodeProgress(
        episode.id!,
        progress: episode.progress,
        watched: episode.watched,
      );
      return true;
    } catch (e, st) {
      handleDatabaseError(e, st, 'saving episode progress for "${episode.displayTitle}"');
      return false;
    }
  }

  /// Debounced save: schedules a save after a short delay
  /// Multiple calls within the delay window are coalesced into one save
  void _scheduleDebouncedSave({Duration delay = const Duration(milliseconds: 500)}) {
    _debouncedSaveTimer?.cancel();
    _debouncedSaveTimer = Timer(delay, () async {
      await persistLibrary();
    });
  }

  Future<void> migrateFromJson() async {
    final dir = miruRyoikiSaveDirectory;
    final jsonFile = File('${dir.path}/${Library.miruryoikiLibrary}.json');

    if (!await jsonFile.exists()) {
      return; // No file to migrate
    }

    logDebug('!! Found legacy library.json, attempting to migrate to database...');
    try {
      final content = await jsonFile.readAsString();
      if (content.isEmpty) {
        await jsonFile.delete(); // Delete empty legacy file
        return;
      }

      final data = jsonDecode(content) as List<dynamic>;
      final legacySeries = data.map((e) => Series.fromJson(e as Map<String, dynamic>)).toList();

      if (legacySeries.isEmpty) {
        await jsonFile.delete(); // Delete empty legacy file
        return;
      }

      // Save all migrated series to the DB
      await seriesDao.syncSeriesBatch(legacySeries);

      logDebug('Migration complete: ${legacySeries.length} series imported into DB.');

      // Rename the file to prevent re-migration
      final migratedFile = File('${dir.path}/${Library.miruryoikiLibrary}.migrated.json');
      await jsonFile.rename(migratedFile.path);
    } catch (e, st) {
      handleDatabaseError(e, st, 'migration from JSON to DB', customMessage: 'Error during migration from JSON to DB');
    }
  }
}
