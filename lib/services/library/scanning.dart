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
    if (_isScanning) return;

    logDebug('\n3 | Scanning library at $_libraryPath', splitLines: true);
    _isScanning = true;
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
      final unresolvedFiles = <PathString, Set<PathString>>{}; // Files that are new or renamed
      final unresolvedEpisodes = <PathString, Set<Episode>>{}; // Episodes that are deleted or renamed

      logTrace("SCAN  New series found: ${newSeriesPaths.length}");
      logTrace("SCAN  Deleted series found: ${deletedSeriesPaths.length}");
      logTrace("SCAN  Existing series to check: ${existingSeriesPathsToCheck.length}");

      // Collect all files from brand new series
      for (final newPath in newSeriesPaths) //
        filesToProcess.addAll(seriesDirsOnDisk[newPath]!);

      for (final seriesPath in existingSeriesPathsToCheck) {
        final series = existingSeriesMap[seriesPath]!;
        final filesInSeriesDir = seriesDirsOnDisk[seriesPath]!;
        final episodesInSeries = series.seasons.expand((s) => s.episodes).toList()..addAll(series.relatedMedia);
        final episodePaths = episodesInSeries.map((e) => e.path).toSet();

        logTrace('SCAN Checking series: ${series.name}');
        logTrace('SCAN  Files on disk: ${filesInSeriesDir.length}');
        logTrace('SCAN  Episodes in memory: ${episodePaths.length}');

        final newFilePaths = filesInSeriesDir.where((file) => !episodePaths.contains(file)).toSet();
        if (newFilePaths.isNotEmpty) {
          logTrace('SCAN  New files found: ${newFilePaths.length}');
          for (final newFile in newFilePaths) {
            logTrace('SCAN    New: ${p.basename(newFile.path)}');
          }
          filesToProcess.addAll(newFilePaths);
          unresolvedFiles[seriesPath] = newFilePaths;
        }

        final missingEpisodePaths = episodePaths.where((path) => !filesInSeriesDir.contains(path)).toSet();
        if (missingEpisodePaths.isNotEmpty) {
          logTrace('SCAN  Missing episodes: ${missingEpisodePaths.length}');
          for (final missingPath in missingEpisodePaths) {
            logTrace('SCAN    Missing: ${p.basename(missingPath.path)}');
          }
          unresolvedEpisodes[seriesPath] = episodesInSeries.where((e) => missingEpisodePaths.contains(e.path)).toSet();
        }
      }

      // ===================================================================
      //          PROCESSING - Offload heavy work to an isolate
      // ===================================================================
      Map<PathString, Metadata> scanResult = {};
      if (filesToProcess.isEmpty) {
        logWarn('3 | No files to process, skipping isolate scan.');
      } else {
        logDebug('3 | Processing ${filesToProcess.length} files in a background isolate...');
        if (doLogTrace) for (final file in filesToProcess) logTrace('3 |  Processing: ${p.basename(file.path)}');

        final isolateManager = IsolateManager();

        // The SendPort will be replaced by the isolate manager with the correct one
        final dummyReceivePort = ReceivePort();
        final dummySendPort = dummyReceivePort.sendPort;
        dummyReceivePort.close(); // Close immediately since it's just for the constructor

        scanResult = await isolateManager.runIsolateWithProgress<ProcessFilesParams, Map<PathString, Metadata>>(
          task: processFilesIsolate,
          params: ProcessFilesParams(filesToProcess.toList(), dummySendPort),
          onStart: () => LibraryScanProgressManager().show(0.015),
          onProgress: (processed, total) {
            scanProgress.value = (processed, total);
            LibraryScanProgressManager().show(processed.toDouble() / total.toDouble());
            Manager.setState();
          },
        );
        Future.delayed(Duration(milliseconds: 1000), () => LibraryScanProgressManager().hide()); // NOT awaited

        logDebug('3 | Isolate processing complete. Found metadata for ${scanResult.length} files.');
        if (doLogTrace) for (final result in scanResult.entries) logTrace('  Processed: ${p.basename(result.key.path)} -> ${result.value.duration}');
      }

      // ===================================================================
      //        MERGING - Apply changes using data from the isolate
      // ===================================================================
      logDebug('3 | Merging scan results...');
      final List<Series> updatedSeriesList = List.from(_series);

      // --- 3a. Delete series that no longer exist ---
      updatedSeriesList.removeWhere((s) => deletedSeriesPaths.contains(s.path));
      if (deletedSeriesPaths.isNotEmpty) logDebug('3 | Removed ${deletedSeriesPaths.length} deleted series.');

      // --- 3b. Add brand new series ---
      for (final newSeriesPath in newSeriesPaths) {
        final newSeries = await _buildSeriesFromScan(
          newSeriesPath,
          seriesDirsOnDisk[newSeriesPath]!,
          scanResult,
        );
        updatedSeriesList.add(newSeries);
      }
      if (newSeriesPaths.isNotEmpty) logDebug('3 | Added ${newSeriesPaths.length} new series.');

      // --- 3c. Update existing series ---
      for (final seriesPath in existingSeriesPathsToCheck) {
        final originalSeries = existingSeriesMap[seriesPath]!;
        final seriesIndex = updatedSeriesList.indexWhere((s) => s.path == seriesPath);
        if (seriesIndex == -1) continue;

        final newFilesForSeries = unresolvedFiles[seriesPath] ?? <PathString>{};
        final missingEpisodesForSeries = unresolvedEpisodes[seriesPath] ?? <Episode>{};

        // For rename detection, we create a key from size and duration
        final newFilesByMetadata = {
          for (var path in newFilesForSeries)
            if (scanResult.containsKey(path)) _createMetadataKey(scanResult[path]!): path
        };
        final missingEpisodesByMetadata = {
          for (var ep in missingEpisodesForSeries)
            if (ep.metadata != null) _createMetadataKey(ep.metadata!): ep
        };

        final Set<Episode> episodesToAdd = {};
        final Set<Episode> episodesToDelete = {};
        final Map<Episode, Episode> episodesToUpdate = {}; // Map<Old, New>
        final Set<String> matchedKeys = {};

        // Match renamed files by metadata key
        for (var metaKey in newFilesByMetadata.keys) {
          if (missingEpisodesByMetadata.containsKey(metaKey)) {
            final oldEpisode = missingEpisodesByMetadata[metaKey]!;
            final newPath = newFilesByMetadata[metaKey]!;
            final newMetadata = scanResult[newPath]!;

            final updatedEpisode = oldEpisode.copyWith(path: newPath, name: _cleanEpisodeName(p.basenameWithoutExtension(newPath.path)), metadata: newMetadata);
            episodesToUpdate[oldEpisode] = updatedEpisode;
            matchedKeys.add(metaKey);
          }
        }

        // Identify truly new and deleted episodes
        newFilesByMetadata.forEach((metaKey, path) {
          if (!matchedKeys.contains(metaKey)) {
            logTrace('    Adding new episode: ${p.basename(path.path)}');
            episodesToAdd.add(_createEpisode(path, scanResult[path]!));
          }
        });
        missingEpisodesByMetadata.forEach((metaKey, episode) {
          if (!matchedKeys.contains(metaKey)) {
            logTrace('    Deleting episode: ${p.basename(episode.path.path)}');
            episodesToDelete.add(episode);
          }
        });

        logTrace('  Episodes to add: ${episodesToAdd.length}');
        logTrace('  Episodes to delete: ${episodesToDelete.length}');
        logTrace('  Episodes to update: ${episodesToUpdate.length}');

        // Rebuild the series with all the collected changes
        if (episodesToAdd.isNotEmpty || episodesToDelete.isNotEmpty || episodesToUpdate.isNotEmpty) {
          logTrace('  Rebuilding series due to changes...');
          final rebuiltSeries = _rebuildSeries(originalSeries, episodesToAdd, episodesToDelete, episodesToUpdate);
          updatedSeriesList[seriesIndex] = rebuiltSeries;
          logTrace('  Series updated in list');
        } else {
          logTrace('  No changes needed for this series');
        }
      }
      logTrace('3 | Updated ${existingSeriesPathsToCheck.length} existing series.');

      // --- 3d. Finalize ---
      _series = updatedSeriesList; // Save the updated series list to memory
      
      await _saveLibrary(); // Save the updated library to database

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
      _isScanning = false;
      scanProgress.value = null;
      notifyListeners();
    }
  }

  /// Creates a consistent key from metadata for matching renamed files.
  String _createMetadataKey(Metadata meta) => '${meta.size}_${meta.duration.inMilliseconds}';

  /// Discovers all first-level directories (series) and their video files.
  Future<Map<PathString, Set<PathString>>> _discoverSeriesDirectories(String libraryPath) async {
    final seriesMap = <PathString, Set<PathString>>{};
    final dir = Directory(libraryPath);
    if (!await dir.exists()) {
      logWarn('Library directory does not exist: $libraryPath');
      return seriesMap;
    }

    // logDebug('Scanning library directory: $libraryPath');
    int seriesCount = 0;

    await for (final entity in dir.list()) {
      if (entity is Directory) {
        seriesCount++;
        final seriesPath = PathString(entity.path);
        final seriesName = p.basename(entity.path);
        logTrace('Found series directory: $seriesName');

        seriesMap[seriesPath] = <PathString>{};
        int fileCount = 0;

        await for (final file in entity.list(recursive: true)) {
          if (file is File && _isVideoFile(file.path)) {
            fileCount++;
            seriesMap[seriesPath]!.add(PathString(file.path));
            logTrace('  Found video file: ${p.basename(file.path)}');
          }
        }

        logTrace('Series "$seriesName" has $fileCount video files');
      }
    }

    logDebug('Total series directories found: $seriesCount');
    return seriesMap;
  }

  /// Creates a brand new Series object from scanned file data.
  Future<Series> _buildSeriesFromScan(PathString seriesPath, Set<PathString> files, Map<PathString, Metadata> metadataMap) async {
    final name = p.basename(seriesPath.path);
    final posterPath = await _findPosterImage(Directory(seriesPath.path));
    final bannerPath = await _findBannerImage(Directory(seriesPath.path));

    final episodes = files //
        .map((path) => metadataMap.containsKey(path) ? _createEpisode(path, metadataMap[path]!) : null)
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
      watched: false,
      progress: 0.0,
      thumbnailUnavailable: false,
    );
  }

  /// Rebuilds an existing series with add/delete/update changes.
  Series _rebuildSeries(Series original, Set<Episode> toAdd, Set<Episode> toDelete, Map<Episode, Episode> toUpdate) {
    List<Episode> currentEpisodes = original.seasons.expand((s) => s.episodes).toList()..addAll(original.relatedMedia);

    logTrace('  Rebuilding series: ${original.name}');
    logTrace('    Current episodes: ${currentEpisodes.length}');
    logTrace('    To add: ${toAdd.length}');
    logTrace('    To delete: ${toDelete.length}');
    logTrace('    To update: ${toUpdate.length}');

    // Apply updates
    currentEpisodes = currentEpisodes.map((ep) => toUpdate[ep] ?? ep).toList();

    // Apply deletions
    final toDeletePaths = toDelete.map((e) => e.path).toSet();
    currentEpisodes.removeWhere((ep) => toDeletePaths.contains(ep.path));

    // Apply additions
    currentEpisodes.addAll(toAdd);

    logTrace('    Final episodes: ${currentEpisodes.length}');

    // Reset thumbnail status for updated episodes if metadata changed
    toUpdate.forEach((oldEp, newEp) {
      if (oldEp.metadata?.size != newEp.metadata?.size || oldEp.metadata?.duration != newEp.metadata?.duration) {
        newEp.resetThumbnailStatus();
      }
    });

    final rebuilt = _organizeEpisodesIntoSeasons(original, currentEpisodes);
    logTrace('    After organization - Seasons: ${rebuilt.seasons.length}, Related: ${rebuilt.relatedMedia.length}');
    return rebuilt;
  }

  /// Organizes a flat list of episodes into the correct Season/Related Media structure.
  /// This logic is ported from the original, working FileScanner.
  Series _organizeEpisodesIntoSeasons(Series series, List<Episode> allEpisodes) {
    final seasons = <Season>[];
    final relatedMedia = <Episode>[];

    // Group episodes by their parent directory path
    final episodesByParentDir = groupBy(allEpisodes, (ep) => p.dirname(ep.path.path));

    final seriesRootPath = series.path.path;
    final seasonDirPaths = <String>[];
    final otherDirPaths = <String>[];

    // Categorize all directories within the series folder
    for (final dirPath in episodesByParentDir.keys) {
      if (dirPath == seriesRootPath) continue; // Skip the root, handle it separately
      if (_isSeasonDirectory(p.basename(dirPath))) {
        seasonDirPaths.add(dirPath);
      } else {
        otherDirPaths.add(dirPath);
      }
    }

    final rootVideoFiles = episodesByParentDir[seriesRootPath] ?? [];

    // Case 1: No season folders found, treat root videos as "Season 01"
    if (seasonDirPaths.isEmpty && rootVideoFiles.isNotEmpty) {
      seasons.add(Season(
        name: 'Season 01',
        path: series.path,
        episodes: rootVideoFiles,
      ));
    } else {
      // Case 2: Season folders exist, process them
      for (final seasonPath in seasonDirPaths) {
        seasons.add(Season(
          name: _formatSeasonName(p.basename(seasonPath)),
          path: PathString(seasonPath),
          episodes: episodesByParentDir[seasonPath]!,
        ));
      }
      // Any videos in the root folder are now related media
      relatedMedia.addAll(rootVideoFiles);
    }

    // Process "other" directories (OVAs, Specials, etc.) as related media
    for (final otherPath in otherDirPaths) {
      relatedMedia.addAll(episodesByParentDir[otherPath]!);
    }

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

  /// Check if a directory name matches the season pattern (S1, S01, Season 01, etc.)
  bool _isSeasonDirectory(String name) => RegExp(r'S\d+', caseSensitive: false).hasMatch(name) || RegExp(r'Season\s+\d+', caseSensitive: false).hasMatch(name);

  /// Format season name to be consistent
  String _formatSeasonName(String name) {
    final match = RegExp(r'(\d+)').firstMatch(name);
    if (match != null) {
      final num = int.parse(match.group(1)!).toString().padLeft(2, '0');
      return 'Season $num';
    }
    return name;
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
