part of 'library_provider.dart';


extension LibraryScanning on Library {
  Future<void> setLibraryPath(String path) async {
    _libraryPath = path;
    await _saveSettings();
    await reloadLibrary();
  }

  /// Scans the local library using a non-blocking, task-based approach.
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
      // ===================================================================
      //        DISCOVERY - Quickly find changes without heavy I/O
      // ===================================================================

      final existingSeriesMap = {for (var s in _series) s.path: s};
      final seriesDirsOnDisk = await _discoverSeriesDirectories(_libraryPath!);

      final seriesPathsOnDisk = seriesDirsOnDisk.keys.toSet();
      final seriesPathsInMemory = existingSeriesMap.keys.toSet();

      final newSeriesPaths = seriesPathsOnDisk.difference(seriesPathsInMemory);
      final deletedSeriesPaths = seriesPathsInMemory.difference(seriesPathsOnDisk);
      final existingSeriesPathsToCheck = seriesPathsOnDisk.intersection(seriesPathsInMemory);

      final filesToProcess = <PathString>{};

      // Collect all files from brand new series
      for (final newPath in newSeriesPaths) {
        filesToProcess.addAll(seriesDirsOnDisk[newPath]!);
      }

      // For existing series, find new/deleted files by path comparison
      final unresolvedFiles = <PathString, Set<PathString>>{}; // Files that are new or renamed
      final unresolvedEpisodes = <PathString, Set<Episode>>{}; // Episodes that are deleted or renamed

      for (final seriesPath in existingSeriesPathsToCheck) {
        final series = existingSeriesMap[seriesPath]!;
        final filesInSeriesDir = seriesDirsOnDisk[seriesPath]!;
        final episodesInSeries = series.seasons.expand((s) => s.episodes).toList()..addAll(series.relatedMedia);
        final episodePaths = episodesInSeries.map((e) => e.path).toSet();

        final newFilePaths = filesInSeriesDir.where((file) => !episodePaths.contains(file)).toSet();
        if (newFilePaths.isNotEmpty) {
          filesToProcess.addAll(newFilePaths);
          unresolvedFiles[seriesPath] = newFilePaths;
        }

        final missingEpisodePaths = episodePaths.where((path) => !filesInSeriesDir.contains(path)).toSet();
        if (missingEpisodePaths.isNotEmpty) {
          unresolvedEpisodes[seriesPath] = episodesInSeries.where((e) => missingEpisodePaths.contains(e.path)).toSet();
        }
      }

      // ===================================================================
      //          PROCESSING - Offload heavy work to an isolate
      // ===================================================================
      IsolateScanResult scanResult;
      if (filesToProcess.isNotEmpty) {
        logTrace('3 | Processing ${filesToProcess.length} files in a background isolate...');
        
        // Prepare the payload for the isolate
        final token = rootIsolateToken!;
        final payload = IsolateScanPayload(
          filesToProcess: filesToProcess,
          rootIsolateToken: token,
        );
        
        scanResult = await compute(processFilesIsolate, payload);
        logTrace('3 | Isolate processing complete. Found metadata for ${scanResult.processedFileMetadata.length} files.');
      } else {
        scanResult = IsolateScanResult(processedFileMetadata: {});
      }

      // ===================================================================
      //        MERGING - Apply changes using data from the isolate
      // ===================================================================
      logTrace('3 | Merging scan results...');
      final List<Series> updatedSeriesList = List.from(_series);

      // --- 3a. Delete series that no longer exist ---
      updatedSeriesList.removeWhere((s) => deletedSeriesPaths.contains(s.path));
      logTrace('3 | Removed ${deletedSeriesPaths.length} deleted series.');

      // --- 3b. Add brand new series ---
      for (final newSeriesPath in newSeriesPaths) {
        final newSeries = await _buildSeriesFromScan(
          newSeriesPath,
          seriesDirsOnDisk[newSeriesPath]!,
          scanResult.processedFileMetadata,
        );
        updatedSeriesList.add(newSeries);
      }
      logTrace('3 | Added ${newSeriesPaths.length} new series.');

      // --- 3c. Update existing series ---
      for (final seriesPath in existingSeriesPathsToCheck) {
        final originalSeries = existingSeriesMap[seriesPath]!;
        final seriesIndex = updatedSeriesList.indexWhere((s) => s.path == seriesPath);
        if (seriesIndex == -1) continue;

        // Get unresolved items for this specific series
        final newFilesForSeries = unresolvedFiles[seriesPath] ?? <PathString>{};
        final missingEpisodesForSeries = unresolvedEpisodes[seriesPath] ?? <Episode>{};

        // Create maps for efficient lookup by checksum
        final newFilesMetaByChecksum = {
          for (var path in newFilesForSeries)
            if (scanResult.processedFileMetadata[path]?.checksum != null) scanResult.processedFileMetadata[path]!.checksum!: scanResult.processedFileMetadata[path]!
        };
        final missingEpisodesByChecksum = {
          for (var ep in missingEpisodesForSeries)
            if (ep.metadata?.checksum != null) ep.metadata!.checksum!: ep
        };

        final Set<Episode> episodesToAdd = {};
        final Set<Episode> episodesToDelete = {};
        final Map<Episode, Episode> episodesToUpdate = {}; // Map<Old, New>

        // Match renamed files by checksum
        final Set<String> matchedChecksums = {};
        for (var checksum in newFilesMetaByChecksum.keys) {
          if (missingEpisodesByChecksum.containsKey(checksum)) {
            final oldEpisode = missingEpisodesByChecksum[checksum]!;
            final newMetadata = newFilesMetaByChecksum[checksum]!;
            final newPath = seriesDirsOnDisk[seriesPath]!.firstWhere((p) => scanResult.processedFileMetadata[p] == newMetadata);

            // This is a RENAMED file. Update path, name, and metadata.
            final updatedEpisode = oldEpisode.copyWith(
              path: newPath,
              name: _cleanEpisodeName(p.basenameWithoutExtension(newPath.path)),
              metadata: newMetadata,
            );
            episodesToUpdate[oldEpisode] = updatedEpisode;
            matchedChecksums.add(checksum);
          }
        }

        // Identify truly new and deleted episodes
        newFilesMetaByChecksum.forEach((checksum, metadata) {
          if (!matchedChecksums.contains(checksum)) {
            final path = seriesDirsOnDisk[seriesPath]!.firstWhere((p) => scanResult.processedFileMetadata[p] == metadata);
            episodesToAdd.add(_createEpisode(path, metadata));
          }
        });

        missingEpisodesByChecksum.forEach((checksum, episode) {
          if (!matchedChecksums.contains(checksum)) {
            episodesToDelete.add(episode);
          }
        });

        // Rebuild the series with all the collected changes
        final rebuiltSeries = _rebuildSeries(originalSeries, episodesToAdd, episodesToDelete, episodesToUpdate);
        updatedSeriesList[seriesIndex] = rebuiltSeries;
      }
      logTrace('3 | Updated ${existingSeriesPathsToCheck.length} existing series.');

      // --- 3d. Finalize ---
      _series = updatedSeriesList;
      _updateWatchedStatusAndResetThumbnailFetchFailedAttemptsCount();
      await _saveLibrary(); // This now saves the fully updated list to DB and/or JSON

      if (showSnack) {
        final changeCount = newSeriesPaths.length + deletedSeriesPaths.length;
        snackBar(changeCount > 0 ? 'Library updated: $changeCount changes found.' : 'Library is up to date.', severity: InfoBarSeverity.success);
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

  /// Discovers all first-level directories (series) and their video files.
  Future<Map<PathString, Set<PathString>>> _discoverSeriesDirectories(String libraryPath) async {
    final seriesMap = <PathString, Set<PathString>>{};
    final dir = Directory(libraryPath);
    if (!await dir.exists()) return seriesMap;

    await for (final entity in dir.list()) {
      if (entity is Directory) {
        final seriesPath = PathString(entity.path);
        seriesMap[seriesPath] = <PathString>{};
        await for (final file in entity.list(recursive: true)) {
          if (file is File && _isVideoFile(file.path)) {
            seriesMap[seriesPath]!.add(PathString(file.path));
          }
        }
      }
    }
    return seriesMap;
  }

  /// Creates a brand new Series object from scanned file data.
  Future<Series> _buildSeriesFromScan(PathString seriesPath, Set<PathString> files, Map<PathString, Metadata> metadataMap) async {
    final name = p.basename(seriesPath.path);
    final posterPath = await _findPosterImage(Directory(seriesPath.path));
    final bannerPath = await _findBannerImage(Directory(seriesPath.path));

    final episodes = files
        .map((path) {
          return metadataMap.containsKey(path) ? _createEpisode(path, metadataMap[path]!) : null;
        })
        .whereNotNull()
        .toList();

    final series = Series.fromValues(name: name, path: seriesPath, seasons: [], folderPosterPath: posterPath, folderBannerPath: bannerPath);
    return _organizeEpisodesIntoSeasons(series, episodes);
  }

  /// Creates a single Episode object.
  Episode _createEpisode(PathString path, Metadata metadata) {
    return Episode(
      path: path,
      name: _cleanEpisodeName(p.basenameWithoutExtension(path.path)),
      metadata: metadata,
      // Default values for new episodes
      watched: false,
      watchedPercentage: 0.0,
      thumbnailUnavailable: false,
    );
  }

  /// Rebuilds an existing series with add/delete/update changes.
  Series _rebuildSeries(Series original, Set<Episode> toAdd, Set<Episode> toDelete, Map<Episode, Episode> toUpdate) {
    List<Episode> currentEpisodes = original.seasons.expand((s) => s.episodes).toList()..addAll(original.relatedMedia);

    // Apply updates
    currentEpisodes = currentEpisodes.map((ep) => toUpdate[ep] ?? ep).toList();

    // Apply deletions
    final toDeletePaths = toDelete.map((e) => e.path).toSet();
    currentEpisodes.removeWhere((ep) => toDeletePaths.contains(ep.path));

    // Apply additions
    currentEpisodes.addAll(toAdd);

    // Reset thumbnail status for updated episodes if metadata changed
    toUpdate.forEach((oldEp, newEp) {
      if (oldEp.metadata?.size != newEp.metadata?.size || oldEp.metadata?.duration != newEp.metadata?.duration) {
        newEp.resetThumbnailStatus();
      }
    });

    return _organizeEpisodesIntoSeasons(original, currentEpisodes);
  }

  /// Organizes a flat list of episodes into the correct Season/Related Media structure based on file paths.
  Series _organizeEpisodesIntoSeasons(Series series, List<Episode> allEpisodes) {
    final seasons = <Season>[];
    final relatedMedia = <Episode>[];

    // Group episodes by their parent directory (which defines the season)
    final episodesBySeasonDir = groupBy(allEpisodes, (ep) => PathString(p.dirname(ep.path.path)));

    // Directory seriesDir = Directory(series.path.path);

    episodesBySeasonDir.forEach((seasonPath, episodes) {
      if (seasonPath == series.path) {
        // Files in the root of the series folder
        relatedMedia.addAll(episodes);
      } else {
        final seasonName = p.basename(seasonPath.path);
        seasons.add(Season(
          name: _isSeasonDirectory(seasonName) ? _formatSeasonName(seasonName) : seasonName,
          path: seasonPath,
          episodes: episodes,
        ));
      }
    });

    // Edge Case: If there are no season folders but files exist in the root,
    // move them into a default "Season 01".
    if (seasons.isEmpty && relatedMedia.isNotEmpty) {
      seasons.add(Season(
        name: 'Season 01',
        path: series.path,
        episodes: relatedMedia,
      ));
      relatedMedia.clear();
    }

    // Sort seasons by name for consistency
    seasons.sort((a, b) => a.name.compareTo(b.name));

    return series.copyWith(
      seasons: seasons,
      relatedMedia: relatedMedia,
    );
  }

  static const List<String> _videoExtensions = ['.mkv', '.mp4', '.avi', '.mov', '.wmv', '.m4v', '.flv'];

  static const List<String> _imageExtensions = ['.ico', '.png', '.jpg', '.jpeg', '.webp'];

  /// Check if a filename is a video file
  bool _isVideoFile(String path) => _videoExtensions.contains(p.extension(path).toLowerCase());

  /// Check if a directory name matches the season pattern (S01, Season 01, etc.)
  bool _isSeasonDirectory(String name) => RegExp(r'S\d{1,2}|Season\s*\d+', caseSensitive: false).hasMatch(name);

  /// Format season name to be consistent
  String _formatSeasonName(String name) {
    final match = RegExp(r'(\d+)').firstMatch(name);
    return 'Season ${int.parse(match?.group(1) ?? '1').toString().padLeft(2, '0')}';
  }

  /// Clean up episode name from filename
  String _cleanEpisodeName(String name) => name.replaceAll(RegExp(r'\[[^\]]+\]|\([^)]+\)|[sS]\d{1,2}[eE]\d{1,2}|\.\w{3,4}$'), '').trim();

  /// Find a poster image in the directory
  Future<PathString?> _findPosterImage(Directory dir) async {
    // First try to find an .ico file
    await for (final entity in dir.list()) {
      if (entity is File && p.extension(entity.path).toLowerCase() == '.ico') {
        return PathString(entity.path);
      }
    }

    // Then try other image formats
    await for (final entity in dir.list()) {
      if (entity is File && _imageExtensions.contains(p.extension(entity.path).toLowerCase())) {
        return PathString(entity.path);
      }
    }

    // No image found
    return null;
  }

  /// Find a banner image in the series directory
  Future<PathString?> _findBannerImage(Directory seriesDir) async {
    try {
      final List<FileSystemEntity> files = await seriesDir.list().toList();

      // Look for common banner image filenames
      final bannerNames = ['banner', 'background', 'backdrop', 'fanart'];
      for (final name in bannerNames) {
        for (final extension in _imageExtensions) {
          final bannerFile = files.whereType<File>().firstWhereOrNull((f) => p.basename(f.path).toLowerCase() == '$name$extension');
          if (bannerFile != null) return PathString(bannerFile.path);
        }
      }

      // If no specific banner found, look for any image with banner dimensions
      for (final file in files.whereType<File>()) {
        final extension = p.extension(file.path).toLowerCase();
        if (_imageExtensions.contains(extension)) {
          try {
            // Check if the image has banner-like dimensions (wider than tall)
            final imageBytes = await file.readAsBytes();
            final decodedImage = await decodeImageFromList(imageBytes);
            if (decodedImage.width > decodedImage.height * 1.7) {
              return PathString(file.path);
            }
          } catch (e) {
            // Ignore errors reading image files
          }
        }
      }
    } catch (e) {
      logDebug('Error finding banner image: $e');
    }
    return null;
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
