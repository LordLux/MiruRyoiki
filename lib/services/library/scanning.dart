part of 'library_provider.dart';

extension LibraryScanning on Library {
  Future<void> setLibraryPath(String path) async {
    _libraryPath = path;
    await _saveSettings();
    await reloadLibrary();
  }

  /// Scan the library for new series
  Future<void> scanLocalLibrary({bool showSnack = false}) async {
    if (_libraryPath == null) {
      logDebug('\n3 | Skipping scan, library path is null', splitLines: true);
      return;
    }

    if (_isLoading) return;
    logDebug('\n3 | Scanning library at $_libraryPath', splitLines: true);

    _isLoading = true;
    notifyListeners();

    try {
      // Create a map of existing series for quick lookup
      final existingSeriesMap = {for (var s in _series) s.path: s};

      // Track current series count to identify new ones
      final previousSeriesCount = _series.length;
      final previousSeriesPaths = _series.map((s) => s.path).toSet();

      final scannedSeries = await _fileScanner.scanLibrary(_libraryPath!, existingSeriesMap);

      // Identify new series
      final newSeries = scannedSeries.where((s) => !previousSeriesPaths.contains(s.path)).toList();

      // Identify removed series (exist in memory but not on disk anymore)
      final scannedPaths = scannedSeries.map((s) => s.path).toSet();
      final removedSeries = _series.where((s) => !scannedPaths.contains(s.path)).toList();

      // Update existing series (maintain same instance but update content)
      for (final scanned in scannedSeries) {
        final existingIndex = _series.indexWhere((s) => s.path == scanned.path);
        if (existingIndex >= 0) {
          // Replace with updated version while preserving metadata
          final mergedSeries = _mergeSeriesMetadata(_series[existingIndex], scanned);

          _series[existingIndex] = mergedSeries;
        }
      }

      // Update watched status from tracker
      _updateWatchedStatusAndResetThumbnailFetchFailedAttemptsCount();

      // Add new series
      if (newSeries.isNotEmpty) {
        logDebug('3 | Found ${newSeries.length} new series');
        _series.addAll(newSeries);
      }

      // Remove deleted series
      if (removedSeries.isNotEmpty) {
        logDebug('3 | Removing ${removedSeries.length} deleted series from memory and DB');
        // Delete from db
        for (final seriesToRemove in removedSeries) {
          final row = await seriesDao.getSeriesRowByPath(seriesToRemove.path);
          if (row != null) await seriesDao.deleteSeriesRow(row.id);
        }

        // Delete from memory
        _series.removeWhere((s) => removedSeries.any((removed) => removed.path == s.path));
      }

      if (showSnack) {
        final newCount = _series.length - previousSeriesCount;
        if (newCount > 0) {
          snackBar('Found $newCount new serie(s)', severity: InfoBarSeverity.success);
        } else {
          snackBar('Library scan complete', severity: InfoBarSeverity.info);
        }
      }
    } catch (e, stackTrace) {
      if (showSnack)
        snackBar('Error scanning library: $e', severity: InfoBarSeverity.error, exception: e, stackTrace: stackTrace);
      else
        logErr('Error scanning library', e, stackTrace);
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
          notifyListeners();

          // Save more frequently to preserve progress
          // if (processed % 10 == 0) {
          //   logTrace('Saving library after processing $processed series');
          //   await _saveLibrary();
          // }
        }
      } catch (e) {
        logErr('Error calculating dominant color for ${series.name}', e);
      }

      // Delay to avoid overwhelming the UI
      await Future.delayed(const Duration(milliseconds: 15));
    }

    // Save and notify when done
    if (anyChanged || forceRecalculate) {
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

/// Merges metadata from existing series with updated content from scanned series
Series _mergeSeriesMetadata(Series existing, Series scanned) {
  return existing.copyWith(
    // Update basic properties
    name: scanned.name,
    folderPosterPath: scanned.folderPosterPath,
    folderBannerPath: scanned.folderBannerPath,

    // Merge seasons while preserving watched status
    seasons: _mergeSeasonsWithMetadata(existing.seasons, scanned.seasons),

    // Merge related media while preserving watched status
    relatedMedia: _mergeEpisodesWithMetadata(existing.relatedMedia, scanned.relatedMedia),
  )..isHidden = existing.isHidden; // Ensure hidden status is preserved
}

/// Merges seasons from existing and scanned series, preserving watch metadata
List<Season> _mergeSeasonsWithMetadata(List<Season> existing, List<Season> scanned) {
  final result = <Season>[];

  // For each scanned season, find matching existing season (if any)
  for (final scannedSeason in scanned) {
    final existingSeason = existing.firstWhereOrNull((s) => s.path == scannedSeason.path);

    if (existingSeason != null) {
      // Merge episodes while preserving watched status
      final mergedEpisodes = _mergeEpisodesWithMetadata(existingSeason.episodes, scannedSeason.episodes);
      result.add(Season(
        name: scannedSeason.name,
        path: scannedSeason.path,
        episodes: mergedEpisodes,
      ));
    } else {
      // This is a new season
      result.add(scannedSeason);
    }
  }

  return result;
}

/// Merges episodes while preserving watch status
List<Episode> _mergeEpisodesWithMetadata(List<Episode> existing, List<Episode> scanned) {
  final result = <Episode>[];

  // For each scanned episode, find matching existing episode (if any)
  for (final scannedEpisode in scanned) {
    final existingEpisode = existing.firstWhereOrNull((e) => e.path == scannedEpisode.path);

    if (existingEpisode != null) {
      // Preserve watched status and percentage
      result.add(Episode(
        path: scannedEpisode.path,
        name: scannedEpisode.name,
        thumbnailPath: existingEpisode.thumbnailPath,
        thumbnailUnavailable: existingEpisode.thumbnailUnavailable,
        watched: existingEpisode.watched,
        watchedPercentage: existingEpisode.watchedPercentage,
        metadata: scannedEpisode.metadata ?? existingEpisode.metadata,
        mkvMetadata: scannedEpisode.mkvMetadata ?? existingEpisode.mkvMetadata,
      ));
    } else {
      // This is a new episode
      result.add(scannedEpisode);
    }
  }

  return result;
}
