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
        _libraryPath = data['libraryPath'];
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

      // Check for legacy JSON and migrate if it exists
      // await migrateFromJson();

      final rows = await seriesDao.getAllSeriesRows();
      final loaded = <Series>[];

      // Using Future.wait for faster loading
      await Future.wait(rows.map((row) async {
        final s = await seriesDao.loadFullSeries(row.id);
        if (s != null) loaded.add(s);
      }));

      _series = loaded;

      logDebug('>> Loaded ${_series.length} series from DB');

      // Initialize hidden series cache after loading
      _hiddenSeriesService.rebuildCache(_series);
      
      // Increment data version since series data was loaded
      _dataVersion++;
    } catch (e, st) {
      logErr('Error loading library from DB', e, st);
      _series = [];
    }
    notifyListeners();
  }

  /// Perform the actual save operation
  Future<void> _saveLibrary() async {
    logDebug('>> Syncing library with database...');

    // Show indeterminate progress bar
    LibraryScanProgressManager().showIndeterminate(text: 'Saving changes...');

    try {
      final dbSeriesRows = await seriesDao.getAllSeriesRows();
      final dbSeriesPaths = dbSeriesRows.map((row) => row.path.path).toSet();
      final modelSeriesPaths = _series.map((s) => s.path.path).toSet();

      // 1. Delete series that are in the DB but no longer in our library
      final pathsToDelete = dbSeriesPaths.difference(modelSeriesPaths);
      for (final path in pathsToDelete) {
        final row = dbSeriesRows.firstWhere((r) => r.path.path == path);
        await seriesDao.deleteSeriesRow(row.id);
      }
      if (pathsToDelete.isNotEmpty) logTrace('   - Deleted ${pathsToDelete.length} series from DB.');

      // 2. Insert or Update all series from our current library state
      // The syncSeries function is transactional and handles all nested changes.
      await Future.wait(_series.map((s) => seriesDao.syncSeries(s)));

      logTrace('   - Added ');
      logTrace('   - Synced ${_series.length} series.');

      logDebug('>> Library sync with DB complete.');
    } catch (e, st) {
      logErr('Error syncing library to DB', e, st);
    } finally {
      LibraryScanProgressManager().hide();
    }
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
      await Future.wait(legacySeries.map((s) => seriesDao.syncSeries(s)));

      logDebug('👍 Migration complete: ${legacySeries.length} series imported into DB.');

      // Rename the file to prevent re-migration
      final migratedFile = File('${dir.path}/${Library.miruryoikiLibrary}.migrated.json');
      await jsonFile.rename(migratedFile.path);
    } catch (e, st) {
      logErr('❌ Error during migration from JSON to DB', e, st);
    }
  }
}
