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

      final rows = await seriesDao.getAllSeriesRows();
      final loaded = <Series>[];

      for (final row in rows) {
        final s = await seriesDao.loadFullSeries(row.id);
        if (s != null) loaded.add(s);
      }
      _series = loaded;

      logDebug('>> Loaded ${_series.length} series from DB');
    } catch (e, st) {
      logErr('Error loading library from DB', e, st);
      _series = [];
    }
    notifyListeners();
  }

  Future<void> forceImmediateSave() async => _saveLibrary();

  /// Perform the actual save operation
  Future<void> _saveToDb() async {
    try {
      await seriesDao.saveLibrary(_series);
      logDebug('>> Library saved to DB (${_series.length} serie)');
    } catch (e, st) {
      logErr('Error saving library to DB', e, st);
    }
  }

  /// Save library with optional debouncing
  Future<void> _saveLibrary() async => await _saveToDb();

  Future<void> migrateFromJson() async {
    // 1) Percorso del file JSON legacy
    final dir = miruRyoikiSaveDirectory;
    final jsonFile = File('${dir.path}/${Library.miruryoikiLibrary}.json');
    final backupFile = File('${dir.path}/${Library.miruryoikiLibrary}.backup.json');

    if (!await jsonFile.exists()) {
      // Nessun file da migrare
      return;
    }

    try {
      // 2) Leggi e deserializza la lista di Series
      final content = await jsonFile.readAsString();
      final data = jsonDecode(content) as List<dynamic>;
      final legacySeries = data.map((e) => Series.fromJson(e as Map<String, dynamic>)).toList();

      if (legacySeries.isEmpty) {
        // File vuoto: niente da fare
        return;
      }

      // 3) Salva tutto nel DB in transazione
      await seriesDao.saveLibrary(legacySeries);
      logDebug('👍 Migrazione completata: ${legacySeries.length} series importate nel DB');

      // 4) Rinomina il file JSON per non rieseguire la migrazione
      final migratedFile = File('${dir.path}/${Library.miruryoikiLibrary}.migrated.json');
      await jsonFile.rename(migratedFile.path);

      // Opzionale: rinomina anche il backup
      if (await backupFile.exists()) {
        final migratedBackup = File('${dir.path}/${Library.miruryoikiLibrary}.backup.migrated.json');
        await backupFile.rename(migratedBackup.path);
      }
    } catch (e, st) {
      logErr('❌ Errore durante la migrazione da JSON a DB', e, st);
      // Se vuoi, puoi rilanciare oppure lasciar fallire silenziosamente
    }
  }
}
