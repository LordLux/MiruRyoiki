part of 'library_provider.dart';

extension LibraryScanning on Library {
  Future<void> setLibraryPath(String path) async {
    _libraryPath = path;
    await _saveSettings();
    await reloadLibrary();
  }

  /// Scan the library for new series
  Future<void> scanLibrary({bool showSnack = false}) async {
    if (_libraryPath == null) {
      logDebug('3 Skipping scan, library path is null');
      return;
    }
    
    if (_isLoading) return;
    logDebug('3 Scanning library at $_libraryPath');

    _isLoading = true;
    notifyListeners();

    try {
      // Create a map of existing series for quick lookup
      final existingSeriesMap = {for (var s in _series) s.path: s};

      // Track current series count to identify new ones
      final previousSeriesCount = _series.length;
      final previousSeriesPaths = _series.map((s) => s.path).toSet();

      _series = await _fileScanner.scanLibrary(_libraryPath!, existingSeriesMap);

      // Identify new series
      final newSeries = _series.where((s) => !previousSeriesPaths.contains(s.path)).toList();

      // Update watched status from tracker
      _updateWatchedStatusAndResetThumbnailFetchFailedAttemptsCount();

      if (newSeries.isNotEmpty) {
        logDebug('3 Calculating dominant colors for ${newSeries.length} new series');
        for (final series in newSeries) {
          await series.calculateDominantColor();
        }
      }

      _isDirty = true;
      _saveLibrary().then((_) {
        if (showSnack) {
          final newCount = _series.length - previousSeriesCount;
          if (newCount > 0) {
            snackBar('Found $newCount new serie(s)', severity: InfoBarSeverity.success);
          } else {
            snackBar('Library scan complete', severity: InfoBarSeverity.info);
          }
        }
      });
    } catch (e) {
      logErr('Error scanning library', e);
      if (showSnack) snackBar('Error scanning library: $e', severity: InfoBarSeverity.error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Calculate dominant colors only for series that need it
  Future<void> calculateDominantColors({bool forceRecalculate = false}) async {
    // Determine which series need processing
    final seriesToProcess = forceRecalculate //
        ? _series
        : _series.where((s) => s.dominantColor == null).toList();

    if (seriesToProcess.isEmpty) {
      logTrace('No series need dominant color calculation');
      return;
    }

    logTrace('Calculating dominant colors for ${seriesToProcess.length} series');
    int processed = 0;
    bool anyChanged = false;

    // Process one series at a time to avoid UI freezes
    for (final series in seriesToProcess) {
      try {
        final oldColor = series.dominantColor;
        await series.calculateDominantColor(forceRecalculate: forceRecalculate);
        processed++;

        // Check if color actually changed
        if (oldColor != series.dominantColor) {
          anyChanged = true;
        }

        // Update UI periodically
        if (processed % 3 == 0 || processed == seriesToProcess.length) {
          _isDirty = true;
          notifyListeners();

          // Save more frequently to preserve progress
          if (processed % 10 == 0) {
            logTrace('Saving library after processing $processed series');
            await _saveLibrary();
          }
        }
      } catch (e) {
        logErr('Error calculating dominant color for ${series.name}', e);
      }

      // Delay to avoid overwhelming the UI
      await Future.delayed(const Duration(milliseconds: 15));
    }

    // Save and notify when done
    if (anyChanged || forceRecalculate) {
      _isDirty = true;
      await _saveLibrary();
      notifyListeners();
      logTrace('Finished calculating dominant colors for $processed series');
      snackBar(
        'Finished calculating dominant colors for $processed series',
        severity: InfoBarSeverity.success,
      );
    }
  }
}