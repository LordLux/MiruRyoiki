part of 'library_provider.dart';

extension LibraryPersistence on Library {
  /// Load settings from saved JSON file
  Future<void> _loadSettings() async {
    try {
      final dir = miruRyoiokiSaveDirectory;
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
      final dir = miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/${Library.settingsFileName}.json');

      final data = {
        'libraryPath': _libraryPath,
      };

      await file.writeAsString(jsonEncode(data));
    } catch (e, st) {
      logErr('Error saving settings', e, st);
    }
  }

  /// Load library from saved JSON file
  Future<void> _loadLibrary() async {
    try {
      await _loadSettings();

      final dir = miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/${Library.miruryoikiLibrary}.json');
      final backupFile = File('${dir.path}/${Library.miruryoikiLibrary}.backup.json');

      if (await file.exists()) {
        try {
          final content = await file.readAsString();
          final data = jsonDecode(content) as List;
          _series = data.map((s) => Series.fromJson(s)).toList();

          // log('1 | Loaded library from file (${_series.length} series, ${_series.map((s) => "${s.name}: ${(s.watchedPercentage*100).toInt()}%").join(',\n')})', splitLines: true);
          // Log loaded dominant colors for debugging
          // for (final series in _series) {
          //   logTrace('Loaded series: ${series.name}, AnilistPoster: ${series.anilistPosterUrl}, AnilistBanner: ${series.anilistBannerUrl}');
          // }

          // Validate that we loaded series properly
          if (_series.isNotEmpty) {
            // Success - create a backup
            await file.copy(backupFile.path);
            logDebug('\n1 | Library loaded successfully (${_series.length} series)', splitLines: true);
          } else {
            throw Exception('Loaded library contains no series');
          }
        } catch (e, st) {
          logWarn('1 | Error loading library file, trying with backup...', splitLines: true);
          // If main file load fails, try the backup
          if (await backupFile.exists()) {
            final backupContent = await backupFile.readAsString();
            final backupData = jsonDecode(backupContent) as List;
            _series = backupData.map((s) => Series.fromJson(s)).toList();
            logDebug('1 | Loaded library from backup (${_series.length} series)');

            // Restore from backup
            await backupFile.copy(file.path);
          } else {
            logErr('1 | No backup file found, starting with an empty library', e, st);
            _series = [];
          }
        }
      }
    } catch (e, st) {
      logErr('1 | Error loading library', e, st);
    }
    notifyListeners();
  }

  Future<void> forceImmediateSave() async => _saveLibrary(immediate: true);

  /// Perform the actual save operation
  Future<void> _performSave() async {
    if (!_isDirty) return;
    logDebug('Saving library...');

    try {
      final dir = miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/${Library.miruryoikiLibrary}.json');
      final backupFile = File('${dir.path}/${Library.miruryoikiLibrary}.backup.json');
      final tempFile = File('${dir.path}/${Library.miruryoikiLibrary}.temp.json');

      // Write to temporary file first
      final data = _series.map((s) => s.toJson()).toList();

      await tempFile.writeAsString(jsonEncode(data));

      // If successful, rename temp file to replace the actual file (atomic operation)
      if (await tempFile.exists()) {
        // Create backup of existing file if it exists
        if (await file.exists()) //
          await file.copy(backupFile.path);

        // Replace original with new file
        await tempFile.rename(file.path);
        logDebug('Library saved successfully (${_series.length} series)');
        _isDirty = false;
        notifyListeners();
        Manager.setState();
      }
    } catch (e, st) {
      logErr('Error saving library', e, st);
    }
  }

  /// Save library with optional debouncing
  Future<void> _saveLibrary({bool immediate = false}) async {
    _isDirty = true;

    if (immediate) {
      // Cancel any pending saves
      _saveDebouncer?.cancel();
      _saveDebouncer = null;
      return _performSave();
    } else {
      // Use debounce pattern
      _saveDebouncer?.cancel();
      _saveDebouncer = Timer(const Duration(milliseconds: 500), _performSave);
    }
  }
}
