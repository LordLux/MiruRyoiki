part of 'library_provider.dart';

extension LibraryPersistence on Library {
  /// Load settings from saved JSON file
  Future<void> _loadSettings() async {
    try {
      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/${Library.settingsFileName}.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content);
        _libraryPath = data['libraryPath'];
        logInfo('0 Loaded settings: $_libraryPath');
      }
    } catch (e) {
      logDebug('0 Error loading settings: $e');
    }
  }

  /// Save settings to JSON file
  Future<void> _saveSettings() async {
    try {
      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/${Library.settingsFileName}.json');

      final data = {
        'libraryPath': _libraryPath,
      };

      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      logDebug('Error saving settings: $e');
    }
  }

  /// Load library from saved JSON file
  Future<void> _loadLibrary() async {
    try {
      await _loadSettings();

      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/${Library.miruryoikiLibrary}.json');
      final backupFile = File('${dir.path}/${Library.miruryoikiLibrary}.backup.json');

      if (await file.exists()) {
        try {
          final content = await file.readAsString();
          final data = jsonDecode(content) as List;
          _series = data.map((s) => Series.fromJson(s)).toList();

          // Log loaded dominant colors for debugging
          // for (final series in _series) {
          //   logTrace('Loaded series: ${series.name}, AnilistPoster: ${series.anilistPosterUrl}, AnilistBanner: ${series.anilistBannerUrl}');
          // }

          // Validate that we loaded series properly
          if (_series.isNotEmpty) {
            // Success - create a backup
            await file.copy(backupFile.path);
            logDebug('1 Library loaded successfully (${_series.length} series)');
          } else {
            throw Exception('Loaded library contains no series');
          }
        } catch (e) {
          logDebug('1 Error loading library file, trying backup: $e');
          // If main file load fails, try the backup
          if (await backupFile.exists()) {
            final backupContent = await backupFile.readAsString();
            final backupData = jsonDecode(backupContent) as List;
            _series = backupData.map((s) => Series.fromJson(s)).toList();
            logDebug('1 Loaded library from backup (${_series.length} series)');

            // Restore from backup
            await backupFile.copy(file.path);
          } else {
            logDebug('1 No backup file found, starting with an empty library');
            _series = [];
          }
        }
      }

      // Update watched status
      _updateWatchedStatus();
    } catch (e) {
      logDebug('1 Error loading library: $e');
    }
    notifyListeners();
  }

  Future<void> forceImmediateSave() async => _saveLibrary(immediate: true);

  /// Perform the actual save operation
  Future<void> _performSave() async {
    if (!_isDirty) return;
    logDebug('Saving library...');

    try {
      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/${Library.miruryoikiLibrary}.json');
      final backupFile = File('${dir.path}/${Library.miruryoikiLibrary}.backup.json');

      // Write to temporary file first
      final data = _series.map((s) => s.toJson()).toList();
      await backupFile.writeAsString(jsonEncode(data));

      // If successful, rename temp file to replace the actual file (atomic operation)
      if (await backupFile.exists()) {
        // Create backup of existing file if it exists
        if (await file.exists()) {
          final backupFile = File('${dir.path}/${Library.miruryoikiLibrary}.backup.json');
          await file.copy(backupFile.path);
        }

        // Replace original with new file
        await backupFile.rename(file.path);
        logDebug('Library saved successfully (${_series.length} series)');
        _isDirty = false;
        return;
      }
    } catch (e) {
      logDebug('Error saving library: $e');
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

  /// Create a backup of the mappings
  Future<bool> _backupMappings() async {
    try {
      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/${Library.miruryoikiLibrary}.json');
      final backupFile = File('${dir.path}/${Library.miruryoikiLibrary}.mappings.json');
      if (await file.exists()) {
        await file.copy(backupFile.path);
        logDebug('Created backup after updating mappings');
      }
    } catch (e) {
      logDebug('Error creating mapping backup: $e');
    }
    return true;
  }
}
