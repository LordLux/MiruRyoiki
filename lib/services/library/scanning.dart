part of 'library_provider.dart';

extension LibraryScanning on Library {
  Future<void> setLibraryPath(String path) async {
    _libraryPath = path;
    _isInitialScan = true;
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

    // Try to acquire a lock for library scanning
    final lockHandle = await _lockManager.acquireLock(
      OperationType.libraryScanning,
      description: 'Scanning Library...',
      exclusive: true,
      waitForOthers: false,
    );

    if (lockHandle == null) {
      if (showSnack) snackBar('Library scan is already in progress or another operation is active', severity: InfoBarSeverity.warning);
      return;
    }

    logDebug('\n3 | Scanning library at $_libraryPath', splitLines: true);
    _isScanning = true;
    notifyListeners();

    try {
      // ==============
      //  Scan changes
      // ==============

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

      // ============================
      //  Process changes in isolate
      // ============================
      Map<PathString, Metadata> scanResult = {};
      if (filesToProcess.isEmpty) {
        logWarn('3 | No files to process, skipping isolate scan.');
      } else {
        logDebug('3 | Processing ${filesToProcess.length} files in a background isolate...');
        if (LoggingConfig.doLogTrace) for (final file in filesToProcess) logTrace('3 |  Processing: ${p.basename(file.path)}');

        final isolateManager = IsolateManager();

        // The SendPort will be replaced by the isolate manager with the correct one
        final dummyReceivePort = ReceivePort();
        final dummySendPort = dummyReceivePort.sendPort;
        dummyReceivePort.close(); // Close immediately since it's just for the constructor

        scanResult = await isolateManager.runIsolateWithProgress<ProcessFilesParams, Map<PathString, Metadata>>(
          task: processFilesIsolate,
          params: ProcessFilesParams(filesToProcess.toList(), dummySendPort),
          onStart: () {
            LibraryScanProgressManager().resetProgress();
          },
          onProgress: (processed, total) {
            scanProgress.value = (processed, total);
            LibraryScanProgressManager().show(processed.toDouble() / total.toDouble());
            Manager.setState();
          },
        );

        // Future.delayed(Duration(milliseconds: 1000), () => LibraryScanProgressManager().hide()); // NOT awaited

        logDebug('3 | Isolate processing complete. Found metadata for ${scanResult.length} files.');
        if (LoggingConfig.doLogTrace) for (final result in scanResult.entries) logTrace('  Processed: ${p.basename(result.key.path)} -> ${result.value.duration}');
      }

      // ===============
      //  Merge results
      // ===============
      logDebug('3 | Merging scan results...');
      final List<Series> updatedSeriesList = List.from(_series);

      // -Delete series that no longer exist
      updatedSeriesList.removeWhere((s) => deletedSeriesPaths.contains(s.path));
      if (deletedSeriesPaths.isNotEmpty) logDebug('3 | Removed ${deletedSeriesPaths.length} deleted series.');

      // Add new series
      for (final newSeriesPath in newSeriesPaths) {
        final newSeries = await _buildSeriesFromScan(
          newSeriesPath,
          seriesDirsOnDisk[newSeriesPath]!,
          scanResult,
        );
        updatedSeriesList.add(newSeries);
      }
      if (newSeriesPaths.isNotEmpty) logDebug('3 | Added ${newSeriesPaths.length} new series.');

      // Update existing series
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

            final updatedEpisode = oldEpisode.copyWith(path: newPath, name: p.basenameWithoutExtension(newPath.path), metadata: newMetadata);
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
          final rebuiltSeries = await _rebuildSeries(originalSeries, episodesToAdd, episodesToDelete, episodesToUpdate);
          updatedSeriesList[seriesIndex] = rebuiltSeries;
          logTrace('  Series updated in list');
        } else {
          logTrace('  No changes needed for ${originalSeries.name}');
        }
      }
      logTrace('3 | Updated ${existingSeriesPathsToCheck.length} existing series.');

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
      LibraryScanProgressManager().hide();
      lockHandle.dispose();
      _isScanning = false;
      _isInitialScan = false;
      scanProgress.value = null;
      notifyListeners();
    }
  }

  /// Creates a consistent key from metadata for matching renamed files.
  String _createMetadataKey(Metadata meta) => '${meta.size}_${meta.duration.inMilliseconds}';

  /// Discovers all first-level directories and .lnk (series), and their video files.
  Future<Map<PathString, Set<PathString>>> _discoverSeriesDirectories(String libraryPath) async {
    final seriesMap = <PathString, Set<PathString>>{};
    final dir = Directory(libraryPath);
    if (!await dir.exists()) {
      logWarn('Library directory does not exist: $libraryPath');
      return seriesMap;
    }

    // logDebug('Scanning library directory: $libraryPath');
    int seriesCount = 0;

    final entities = await dir.list().toList();

    for (final entity in entities) {
      if (entity is Directory) {
        seriesCount++;
        final seriesPath = PathString(entity.path);
        final seriesName = p.basename(entity.path);
        logTrace('Found series directory: $seriesName');

        seriesMap[seriesPath] = <PathString>{};
        int fileCount = 0;

        try {
          final files = await entity.list(recursive: true, followLinks: false).toList();
          for (final file in files) {
            if (file is File && FileUtils.isVideoFile(file.path)) {
              fileCount++;
              seriesMap[seriesPath]!.add(PathString(file.path));
              logTrace('  Found video file: ${p.basename(file.path)}');
            }
          }
        } catch (e) {
          logErr('Error scanning series directory: $seriesName', e);
        }

        logTrace('Series "$seriesName" has $fileCount video files');
      } else if (entity is File && ShellUtils.isShortcut(entity.path)) {
        // Handle Windows shortcut files
        final shortcutName = p.basenameWithoutExtension(entity.path);
        logTrace('Found shortcut: $shortcutName.lnk');

        try {
          final targetPath = await ShellUtils.resolveShortcut(entity.path);
          if (targetPath != null && targetPath.isNotEmpty) {
            final targetDir = Directory(targetPath);
            if (targetDir.existsSync()) {
              seriesCount++;
              // Use the target directory path as the series key (not the shortcut path)
              final seriesPath = PathString(targetPath);

              logTrace('  Resolved to: $targetPath');
              logTrace('  Scanning target directory...');

              seriesMap[seriesPath] = <PathString>{};
              int fileCount = 0;

              // Scan the target directory recursively
              try {
                final files = await targetDir.list(recursive: true, followLinks: false).toList();
                for (final file in files) {
                  if (file is File && FileUtils.isVideoFile(file.path)) {
                    fileCount++;
                    seriesMap[seriesPath]!.add(PathString(file.path));
                    logTrace('    Found video file: ${p.basename(file.path)}');
                  }
                }
              } catch (e) {
                logErr('Error scanning shortcut target directory: $targetPath', e);
              }

              logTrace('  Series "$shortcutName" (via shortcut) has $fileCount video files');
            } else {
              logWarn('Shortcut target directory does not exist: $targetPath');
            }
          } else {
            logWarn('Could not resolve shortcut: $shortcutName.lnk');
          }
        } catch (e, st) {
          logErr('Error processing shortcut: $shortcutName.lnk', e, st);
        }
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

    final series = Series(name: name, path: seriesPath, seasons: [], folderPosterPath: posterPath, folderBannerPath: bannerPath);
    return await _organizeEpisodesIntoSeasons(series, episodes);
  }

  /// Creates a single Episode object.
  Episode _createEpisode(PathString path, Metadata metadata) {
    return Episode(
      path: path,
      name: p.basenameWithoutExtension(path.path),
      metadata: metadata,
      watched: false,
      progress: 0.0,
      thumbnailUnavailable: false,
    );
  }

  /// Rebuilds an existing series with add/delete/update changes.
  Future<Series> _rebuildSeries(Series original, Set<Episode> toAdd, Set<Episode> toDelete, Map<Episode, Episode> toUpdate) async {
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

    final rebuilt = await _organizeEpisodesIntoSeasons(original, currentEpisodes);
    logTrace('    After organization - Seasons: ${rebuilt.seasons.length}, Related: ${rebuilt.relatedMedia.length}');
    return rebuilt;
  }

  /// Organizes a flat list of episodes into the correct Season/Related Media structure.
  /// This logic scans all subdirectories and creates seasons even if they're empty.
  Future<Series> _organizeEpisodesIntoSeasons(Series series, List<Episode> allEpisodes) async {
    final seasons = <Season>[];
    final relatedMedia = <Episode>[];

    // Group episodes by their parent directory path
    final episodesByParentDir = groupBy(allEpisodes, (ep) => p.dirname(ep.path.path));

    final seriesRootPath = series.path.path;
    final seasonDirPaths = <String>[];
    final otherDirPaths = <String>[];

    // Scan ALL subdirectories in the series folder, not just those with episodes
    final seriesDir = Directory(seriesRootPath);
    if (await seriesDir.exists()) {
      await for (final entity in seriesDir.list()) {
        if (entity is Directory) {
          final dirPath = entity.path;
          final dirName = p.basename(dirPath);

          if (_isSeasonDirectory(dirName)) {
            seasonDirPaths.add(dirPath);
          } else {
            // Only add to other directories if it contains episodes
            if (episodesByParentDir.containsKey(dirPath)) otherDirPaths.add(dirPath);
          }
        }
      }
    }

    // Also include any directories that contain episodes but weren't found in the file system scan
    // (this handles the case where episodes exist but directory was removed/renamed)
    for (final dirPath in episodesByParentDir.keys) {
      if (dirPath == seriesRootPath) continue; // Skip the root, handle it separately
      if (!seasonDirPaths.contains(dirPath) && !otherDirPaths.contains(dirPath)) {
        if (_isSeasonDirectory(p.basename(dirPath))) {
          seasonDirPaths.add(dirPath);
        } else {
          otherDirPaths.add(dirPath);
        }
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
      // Case 2: Season folders exist, process them (including empty ones)
      for (final seasonPath in seasonDirPaths) {
        final seasonName = p.basename(seasonPath);
        final episodesInSeason = episodesByParentDir[seasonPath] ?? <Episode>[];

        seasons.add(Season(
          name: _formatSeasonName(seasonName),
          path: PathString(seasonPath),
          episodes: episodesInSeason,
        ));
      }
      // Any videos in the root folder are now related media
      relatedMedia.addAll(rootVideoFiles);
    }

    // Process "other" directories (OVAs, Specials, etc.) as related media
    for (final otherPath in otherDirPaths) {
      relatedMedia.addAll(episodesByParentDir[otherPath]!);
    }

    // Sort seasons by season number (preserve original numbering)
    seasons.sort((a, b) {
      final aNum = a.seasonNumber;
      final bNum = b.seasonNumber;

      // If both have valid season numbers, sort by number
      if (aNum != null && bNum != null) {
        return aNum.compareTo(bNum);
      }

      // If only one has a valid season number, it comes first
      if (aNum != null) return -1;
      if (bNum != null) return 1;

      // If neither has a valid season number, sort alphabetically
      return a.name.compareTo(b.name);
    });

    return series.copyWith(
      seasons: seasons,
      relatedMedia: relatedMedia,
    );
  }

  /// Check if a directory name matches the season pattern ([S or s]eason (\d){1+} or [S or s](\s){0 or 1}(\d){1+})
  bool _isSeasonDirectory(String name) {
    // Match "[S or s]eason (\d){1+}" - e.g., "Season 1", "season 12", etc.
    final seasonPattern = RegExp(r'^[Ss]eason\s+\d+$');
    // Match "[S or s](\s){0 or 1}(\d){1+}" - e.g., "S1", "s1", "S 12", "s 12", etc.
    final shortPattern = RegExp(r'^[Ss]\s?\d+$');

    return seasonPattern.hasMatch(name.trim()) || shortPattern.hasMatch(name.trim());
  }

  /// Format season name to be consistent
  String _formatSeasonName(String name) {
    final match = RegExp(r'(\d+)').firstMatch(name);
    if (match != null) {
      final num = int.parse(match.group(1)!).toString().padLeft(2, '0');
      return 'Season $num';
    }
    return name;
  }

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
      if (entity is File && FileUtils.imageExtensions.contains(p.extension(entity.path).toLowerCase())) {
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
        for (final extension in FileUtils.imageExtensions) {
          final bannerFile = files.whereType<File>().firstWhereOrNull((f) => p.basename(f.path).toLowerCase() == '$name$extension');
          if (bannerFile != null) return PathString(bannerFile.path);
        }
      }

      // If no specific banner found, look for any image with banner dimensions
      for (final file in files.whereType<File>()) {
        final extension = p.extension(file.path).toLowerCase();
        if (FileUtils.imageExtensions.contains(extension)) {
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
    // Try to acquire a lock for dominant color calculation
    final lockHandle = await _lockManager.acquireLock(
      OperationType.dominantColorCalculation,
      description: 'Recalculating Colors...',
      waitForOthers: false,
    );

    if (lockHandle == null) {
      snackBar(
        'Dominant color calculation is already in progress',
        severity: InfoBarSeverity.warning,
      );
      return;
    }

    try {
      // Determine which series need processing
      final mappingsToProcess = forceRecalculate
          ? _series.expand((s) => s.anilistMappings).toList()
          : _series
              .expand((s) => s.anilistMappings.where((m) => !(Manager.settings.dominantColorSource == DominantColorSource.banner ? m.bannerColor != null : m.posterColor != null)))
              .toList();

      if (mappingsToProcess.isEmpty) {
        logTrace('No series need dominant color calculation');
        return;
      }

      logTrace('Calculating dominant colors for ${mappingsToProcess.length} series using isolate manager');

      // Use the isolate-based approach with progress tracking
      final results = await color_utils.calculateMappingDominantColorsWithProgress(
        mappings: mappingsToProcess,
        forceRecalculate: forceRecalculate,
        onStart: () {
          LibraryScanProgressManager().resetProgress();
          logTrace('Starting dominant color calculation in isolate');
        },
        onProgress: (processed, total) {
          final progress = processed.toDouble() / total.toDouble();
          LibraryScanProgressManager().show(progress);
          logTrace('Dominant color progress: $processed/$total (${(progress * 100).toStringAsFixed(1)}%)');
          notifyListeners();
        },
      );

      // Apply the results to the actual series objects
      int successCount = 0;
      bool anyChanged = false;

      for (final entry in results.entries) {
        final anilistId = entry.key;
        final result = entry.value;

        if (result.containsKey('error')) {
          if ((result['error'] as String).contains('No image source available'))
        logWarn('Skipped dominant color calculation for AnilistId $anilistId: ${result['error']}');
          else
        logErr('Error calculating dominant color for AnilistId $anilistId: ${result['error']}');
          continue;
        }

        if (result['changed'] != true) continue;

        final posterColorValue = result['posterColor'] as int?;
        final bannerColorValue = result['bannerColor'] as int?;

        if (posterColorValue == null && bannerColorValue == null) continue;

        final newPosterColor = posterColorValue != null ? Color(posterColorValue) : null;
        final newBannerColor = bannerColorValue != null ? Color(bannerColorValue) : null;

        // Find all series that have mappings with this anilistId
        for (int seriesIndex = 0; seriesIndex < _series.length; seriesIndex++) {
          final series = _series[seriesIndex];
          final mappingsWithId = series.anilistMappings.where((m) => m.anilistId == anilistId).toList();
          
          if (mappingsWithId.isEmpty) continue;

          // Update all mappings with this anilistId
          final updatedMappings = series.anilistMappings.map((m) {
        if (m.anilistId == anilistId) {
          final oldPosterColor = m.posterColor;
          final oldBannerColor = m.bannerColor;
          
          final updated = m.copyWith(
            posterColor: newPosterColor ?? m.posterColor,
            bannerColor: newBannerColor ?? m.bannerColor,
          );

          if (oldPosterColor != newPosterColor || oldBannerColor != newBannerColor) {
            anyChanged = true;
            if (!mappingsWithId.any((mapping) => mapping == m && successCount > 0)) {
          successCount++;
            }
          }

          return updated;
        }
        return m;
          }).toList();

          _series[seriesIndex] = series.copyWith(anilistMappings: updatedMappings);
        }
      }
      
      libraryScreenKey.currentState?.updateColorsInSortCache();

      // Save and notify when done
      if (anyChanged || forceRecalculate) {
        await _saveLibrary();
        notifyListeners();
        logTrace('Finished calculating dominant colors for $successCount series');
      }
        } catch (e, st) {
      logErr('Error during batch dominant color calculation', e, st);
      snackBar(
        'Error calculating dominant colors: $e',
        severity: InfoBarSeverity.error,
      );
    } finally {
      lockHandle.dispose();

      // Hide progress indicator
      LibraryScanProgressManager().hide();
    }
  }
}
