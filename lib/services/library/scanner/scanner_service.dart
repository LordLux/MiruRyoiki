import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../../../enums.dart';
import '../../../main.dart';
import '../../../manager.dart';
import '../../../models/episode.dart';
import '../../../models/metadata.dart';
import '../../../models/season.dart';
import '../../../models/series.dart';
import '../../../settings.dart';
import '../../../utils/color.dart' as color_utils;
import '../../../utils/file.dart';
import '../../../viewmodels/library_screen_viewmodel.dart';
import '../../../utils/logging.dart';
import '../../lock_manager.dart';
import '../../../utils/shell.dart';
import '../../navigation/show_info.dart';
import '../../../utils/path.dart';
import '../../../widgets/dialogs/splash/progress.dart';
import '../../isolates/isolate_manager.dart';
import '../library_provider.dart';

class LibraryScannerService extends ChangeNotifier {
  final SettingsManager _settings;
  Library? _library;

  bool _isScanning = false;
  bool _isInitialScan = false;
  final ValueNotifier<(int, int)?> scanProgress = ValueNotifier(null);

  bool get isIndexing => _isScanning;
  bool get isInitialScan => _isInitialScan;

  LibraryScannerService(this._settings);

  /// Called by LibraryProvider to set or update the library reference after initialization
  void update(Library library) => _library = library;

  Future<void> setLibraryPath(String path) async {
    if (_library == null) return;
    _isInitialScan = true;
    await _library!.updateLibraryPathAndReload(path);
  }

  /// Scans the local library using a non-blocking, task-based approach.
  Future<void> scanLocalLibrary({bool showSnack = false}) async {
    if (_library == null) return;
    if (kDebugMode && Manager.skipScan) {
      logDebug('Skipping scan, Manager.skipScan is true');
      return;
    }
    if (_library!.libraryPath == null) {
      logDebug('\n3 | Skipping scan, library path is null', splitLines: true);
      return;
    }
    if (_isScanning) return;

    // Show progress bar with initial text
    LibraryScanProgressManager().show(0, text: 'Indexing library...');

    // Try to acquire a lock for library scanning
    final lockHandle = await _library!.lockManager.acquireLock(
      OperationType.libraryScanning,
      description: 'Scanning Library...',
      exclusive: true,
      waitForOthers: false,
    );

    if (lockHandle == null) {
      if (showSnack) snackBar('Library scan is already in progress or another operation is active', severity: InfoBarSeverity.warning);
      return;
    }

    logDebug('\n3 | Scanning library at ${_library!.libraryPath}', splitLines: true);
    _isScanning = true;
    notifyListeners();

    try {
      // ==============
      //  Scan changes
      // ==============

      final existingSeriesMap = {for (var s in _library!.series) s.path: s};
      final seriesDirsOnDisk = await _discoverSeriesDirectories(_library!.libraryPath!);

      final seriesPathsOnDisk = seriesDirsOnDisk.keys.toSet();
      final seriesPathsInMemory = existingSeriesMap.keys.toSet();

      final newSeriesPaths = seriesPathsOnDisk.difference(seriesPathsInMemory);
      final deletedSeriesPaths = seriesPathsInMemory.difference(seriesPathsOnDisk);
      final existingSeriesPathsToCheck = seriesPathsOnDisk.intersection(seriesPathsInMemory);

      final filesToProcess = <PathString>{};
      final unresolvedFiles = <PathString, Set<PathString>>{}; // Files that are new or renamed
      final unresolvedEpisodes = <PathString, Set<Episode>>{}; // Episodes that are deleted or renamed
      final seriesNeedingCollectionRebuild = <PathString>{};

      logTrace("SCAN  New series found: ${newSeriesPaths.length}");
      logTrace("SCAN  Deleted series found: ${deletedSeriesPaths.length}");
      logTrace("SCAN  Existing series to check: ${existingSeriesPathsToCheck.length}");

      // Collect all files from brand new series
      for (final newPath in newSeriesPaths) //
        filesToProcess.addAll(seriesDirsOnDisk[newPath]!);

      for (final seriesPath in existingSeriesPathsToCheck) {
        final series = existingSeriesMap[seriesPath]!;
        final filesInSeriesDir = seriesDirsOnDisk[seriesPath]!;
        final episodesInSeries = series.collections.expand((c) => c.episodes).toList();
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

        // Folder-only changes do not show up in file diffs.
        // If a mapped directory exists on disk but is missing from collections, force a rebuild
        bool mappedDirMissingFromCollections = false;
        for (final mapping in series.anilistMappings) {
          final mappedPath = mapping.localPath.path;
          if (mappedPath == series.path.path) continue;
          if (!p.isWithin(series.path.path, mappedPath)) continue;

          final mappedDir = Directory(mappedPath);
          if (!await mappedDir.exists()) continue;

          final inCollections = series.collections.any((c) => c.path.path == mappedPath);
          if (!inCollections) {
            mappedDirMissingFromCollections = true;
            logTrace('SCAN  Collection rebuild needed (mapped empty folder): ${p.basename(mappedPath)}');
            break;
          }
        }

        if (mappedDirMissingFromCollections) //
          seriesNeedingCollectionRebuild.add(seriesPath);
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
            notifyListeners();
            // Manager.setState();
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
      final List<Series> updatedSeriesList = List.from(_library!.series);

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
      int newSeries = 0;
      for (final seriesPath in existingSeriesPathsToCheck) {
        final originalSeries = existingSeriesMap[seriesPath]!;
        final seriesIndex = updatedSeriesList.indexWhere((s) => s.path == seriesPath);
        if (seriesIndex == -1) {
          newSeries += 1;
          continue;
        }

        final newFilesForSeries = unresolvedFiles[seriesPath] ?? <PathString>{};
        final missingEpisodesForSeries = unresolvedEpisodes[seriesPath] ?? <Episode>{};

        // For rename detection, we create a key from size and duration.
        // A key is only usable for matching when it is unique on BOTH sides:
        // files with identical size+duration (NCOP/NCED pairs, padded releases,
        // or whole folders moved at once) would otherwise collapse in the maps
        // and silently drop adds/deletes, leaving phantom episodes behind.
        // Ambiguous keys fall back to plain add+delete (watch state is lost for
        // those files, but the library stays consistent with the disk)
        final newFilesByMetadata = <String, PathString>{};
        final ambiguousKeys = <String>{};

        for (final path in newFilesForSeries) {
          final meta = scanResult[path];
          if (meta == null) continue; // metadata extraction failed; handled below

          final key = _createMetadataKey(meta);
          if (newFilesByMetadata.containsKey(key))
            ambiguousKeys.add(key);
          else
            newFilesByMetadata[key] = path;
        }

        final missingEpisodesByMetadata = <String, Episode>{};

        for (final ep in missingEpisodesForSeries) {
          final meta = ep.metadata;
          if (meta == null) continue;

          final key = _createMetadataKey(meta);
          if (missingEpisodesByMetadata.containsKey(key))
            ambiguousKeys.add(key);
          else
            missingEpisodesByMetadata[key] = ep;
        }

        final Set<Episode> episodesToAdd = {};
        final Set<Episode> episodesToDelete = {};
        final Map<Episode, Episode> episodesToUpdate = {}; // Map<Old, New>
        final Set<String> matchedKeys = {};

        // Match renamed files by metadata key
        for (var metaKey in newFilesByMetadata.keys) {
          if (ambiguousKeys.contains(metaKey)) continue; // skip ambiguous keys

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
        // Iterate the full sets so files sharing a metadata key are never silently dropped
        for (final path in newFilesForSeries) {
          final meta = scanResult[path];
          if (meta == null) continue; // no metadata -> episode can't be built (same as initial scan)

          final key = _createMetadataKey(meta);
          final wasRenameMatched = matchedKeys.contains(key) && newFilesByMetadata[key] == path;
          if (!wasRenameMatched) {
            logTrace('    Adding new episode: ${p.basename(path.path)}');
            episodesToAdd.add(_createEpisode(path, meta));
          }
        }

        for (final episode in missingEpisodesForSeries) {
          final meta = episode.metadata;
          final key = meta != null ? _createMetadataKey(meta) : null;
          final wasRenameMatched = key != null && matchedKeys.contains(key) && identical(missingEpisodesByMetadata[key], episode);
          if (!wasRenameMatched) {
            logTrace('    Deleting episode: ${p.basename(episode.path.path)}');
            episodesToDelete.add(episode);
          }
        }

        logTrace('  Episodes to add: ${episodesToAdd.length}');
        logTrace('  Episodes to delete: ${episodesToDelete.length}');
        logTrace('  Episodes to update: ${episodesToUpdate.length}');

        final needsCollectionRebuild = seriesNeedingCollectionRebuild.contains(seriesPath);
        if (needsCollectionRebuild) logTrace('  Collection rebuild requested for mapped empty folder changes');

        // Rebuild the series with all the collected changes
        if (episodesToAdd.isNotEmpty || episodesToDelete.isNotEmpty || episodesToUpdate.isNotEmpty || needsCollectionRebuild) {
          logTrace('  Rebuilding series due to changes...');
          final rebuiltSeries = await _rebuildSeries(originalSeries, episodesToAdd, episodesToDelete, episodesToUpdate);
          updatedSeriesList[seriesIndex] = rebuiltSeries;
          logTrace('  Series updated in list');
        } else {
          logTrace('  No changes needed for ${originalSeries.name}');
        }
      }
      logTrace('3 | Updated ${existingSeriesPathsToCheck.length} existing series.');
      if (newSeries > 0) logTrace('  | New series processed: $newSeries');

      final dirtySeriesPaths = <PathString>{};
      // existing that had changes
      for (final seriesPath in existingSeriesPathsToCheck) {
        final newFiles = unresolvedFiles[seriesPath] ?? <PathString>{};
        final missingEpisodes = unresolvedEpisodes[seriesPath] ?? <Episode>{};
        if (newFiles.isNotEmpty || missingEpisodes.isNotEmpty || seriesNeedingCollectionRebuild.contains(seriesPath)) {
          dirtySeriesPaths.add(seriesPath);
        }
      }

      await _library!.syncLibraryWithScanResults(
        updatedSeriesList: updatedSeriesList,
        newSeriesPaths: newSeriesPaths,
        deletedSeriesPaths: deletedSeriesPaths,
        dirtySeriesPaths: dirtySeriesPaths,
        anyChanged: newSeriesPaths.isNotEmpty || deletedSeriesPaths.isNotEmpty || dirtySeriesPaths.isNotEmpty,
      );

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
      } else if (entity is File) {
        bool isShortcut = ShellUtils.isShortcut(entity.path);

        if (isShortcut) {
          // Handle Windows shortcut files
          final shortcutName = p.basenameWithoutExtension(entity.path);
          logTrace('Found shortcut: $shortcutName.lnk');

          try {
            String? targetPath = await ShellUtils.resolveShortcut(entity.path);

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
                if (File(targetPath).existsSync())
                  logWarn('Shortcut target is not a directory: $targetPath, the target is a file.');
                else
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

    final series = Series(name: name, path: seriesPath, collections: [], localPosterPath: posterPath, localBannerPath: bannerPath);
    return await _organizeEpisodesIntoCollections(series, episodes);
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
    List<Episode> currentEpisodes = original.collections.expand((c) => c.episodes).toList();

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

    final rebuilt = await _organizeEpisodesIntoCollections(original, currentEpisodes);
    logTrace('    After organization - Collections: ${rebuilt.collections.length}');
    return rebuilt;
  }

  /// Organizes a flat list of episodes into EpisodeCollection objects (Season and Folder)
  ///
  /// Scans all subdirectories and creates collections even for empty season folders
  ///
  /// For non-season folders, empty directories are only included when they are
  /// explicitly mapped to AniList, so pre-created folders keep their mapping cards
  Future<Series> _organizeEpisodesIntoCollections(Series series, List<Episode> allEpisodes) async {
    final collections = <EpisodeCollection>[];

    // Group episodes by their parent directory path
    final episodesByParentDir = groupBy(allEpisodes, (ep) => p.dirname(ep.path.path));

    final seriesRootPath = series.path.path;
    final seasonDirPaths = <String>[];
    final otherDirPaths = <String>[];
    final mappedDirectoryPaths = <String>{};

    // Keep mapped empty directories so they can still resolve MappingTarget.collection
    for (final mapping in series.anilistMappings) {
      final mappedPath = mapping.localPath.path;
      if (mappedPath == seriesRootPath) continue;
      if (!p.isWithin(seriesRootPath, mappedPath)) continue;

      final mappedDir = Directory(mappedPath);
      if (await mappedDir.exists()) mappedDirectoryPaths.add(mappedPath);
    }

    // Scan ALL subdirectories in the series folder, not just those with episodes
    final seriesDir = Directory(seriesRootPath);
    if (await seriesDir.exists()) {
      await for (final entity in seriesDir.list()) {
        if (entity is Directory) {
          final dirPath = entity.path;
          final dirName = p.basename(dirPath);

          if (isSeasonName(dirName)) {
            seasonDirPaths.add(dirPath);
          } else {
            // Keep directories that contain episodes, plus mapped empty folders
            if (episodesByParentDir.containsKey(dirPath) || mappedDirectoryPaths.contains(dirPath)) {
              otherDirPaths.add(dirPath);
            }
          }
        }
      }
    }

    // Include mapped directories not returned by top-level scan (for nested mapped folders)
    for (final mappedDirPath in mappedDirectoryPaths) {
      if (seasonDirPaths.contains(mappedDirPath) || otherDirPaths.contains(mappedDirPath)) continue;

      final mappedDirName = p.basename(mappedDirPath);
      if (isSeasonName(mappedDirName)) {
        seasonDirPaths.add(mappedDirPath);
      } else {
        otherDirPaths.add(mappedDirPath);
      }
    }

    // Also include any directories that contain episodes but weren't found in the file system scan
    // (this handles the case where episodes exist but directory was removed/renamed)
    for (final dirPath in episodesByParentDir.keys) {
      if (dirPath == seriesRootPath) continue; // Skip the root, handle it separately
      if (!seasonDirPaths.contains(dirPath) && !otherDirPaths.contains(dirPath)) {
        if (isSeasonName(p.basename(dirPath))) {
          seasonDirPaths.add(dirPath);
        } else {
          otherDirPaths.add(dirPath);
        }
      }
    }

    final rootVideoFiles = episodesByParentDir[seriesRootPath] ?? [];
    final hasSubfolders = seasonDirPaths.isNotEmpty || otherDirPaths.isNotEmpty;

    // Case 1: No subfolders found at all, treat root videos as "Season 01"
    if (!hasSubfolders && rootVideoFiles.isNotEmpty) {
      collections.add(Season(
        name: 'Season 01',
        path: series.path,
        episodes: rootVideoFiles,
        seasonNumber: 1,
      ));
    } else {
      // Case 2: Subfolders exist — create Season objects for season-pattern folders
      for (final seasonPath in seasonDirPaths) {
        final seasonName = p.basename(seasonPath);
        final episodesInSeason = episodesByParentDir[seasonPath] ?? <Episode>[];
        final seasonNum = parseSeasonNumber(seasonName)!;

        collections.add(Season(
          name: 'Season ${seasonNum.toString().padLeft(2, '0')}',
          path: PathString(seasonPath),
          episodes: episodesInSeason,
          seasonNumber: seasonNum,
        ));
      }

      // Create Folder objects for non-season subfolders
      for (final otherPath in otherDirPaths) {
        final folderName = p.basename(otherPath);
        final episodesInFolder = episodesByParentDir[otherPath] ?? <Episode>[];

        collections.add(Folder(
          name: folderName,
          path: PathString(otherPath),
          episodes: episodesInFolder,
        ));
      }

      // Root-level loose files go into a synthetic Uncategorized folder
      if (rootVideoFiles.isNotEmpty) {
        collections.add(Folder(
          name: Folder.uncategorizedName,
          path: series.path,
          episodes: rootVideoFiles,
        ));
      }
    }

    // Sort episodes within each collection by episode number, then by filename
    for (final collection in collections) {
      collection.episodes.sort(_compareEpisodes);
    }

    // Sort collections: Seasons first (by number), then Folders alphabetically
    collections.sort((a, b) {
      // Seasons come before Folders
      if (a is Season && b is! Season) return -1;
      if (a is! Season && b is Season) return 1;

      // Both Seasons — sort by season number
      if (a is Season && b is Season) {
        return a.seasonNumber.compareTo(b.seasonNumber);
      }

      // Both Folders — sort alphabetically, but Uncategorized last
      final aIsUncat = a is Folder && a.isUncategorized;
      final bIsUncat = b is Folder && b.isUncategorized;
      if (aIsUncat && !bIsUncat) return 1;
      if (!aIsUncat && bIsUncat) return -1;
      return a.name.compareTo(b.name);
    });

    return series.copyWith(
      collections: collections,
    );
  }

  /// Compare two episodes for sorting: by episode number first (if available), then by filename.
  static int _compareEpisodes(Episode a, Episode b) {
    final aNum = a.episodeNumber;
    final bNum = b.episodeNumber;

    // Both have episode numbers — sort numerically
    if (aNum != null && bNum != null) return aNum.compareTo(bNum);

    // Episodes with a number come before those without
    if (aNum != null) return -1;
    if (bNum != null) return 1;

    // Neither has an episode number — fall back to filename
    return a.name.compareTo(b.name);
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
    if (_library == null) return;
    // Try to acquire a lock for dominant color calculation
    final lockHandle = await _library!.lockManager.acquireLock(
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
      final mappingsToProcess = forceRecalculate //
          ? _library!.series.expand((s) => s.anilistMappings).toList()
          : _library!.series //
              .expand((s) => s.anilistMappings.where((m) => !(_settings.dominantColorSource == DominantColorSource.banner ? m.bannerColor != null : m.posterColor != null)))
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
          final progress = (processed / total).clamp(0, 1).toDouble();
          LibraryScanProgressManager().show(progress);
          logTrace('Dominant color progress: $processed/$total (${(progress * 100).toStringAsFixed(1)}%)');
          notifyListeners();
        },
      );

      // Apply the results to the actual series objects
      int successCount = 0;
      bool anyChanged = false;

      final updatedSeriesList = List<Series>.from(_library!.series);
      final dirtySeriesPaths = <PathString>{};

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
        for (int seriesIndex = 0; seriesIndex < updatedSeriesList.length; seriesIndex++) {
          final series = updatedSeriesList[seriesIndex];
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
                dirtySeriesPaths.add(series.path);
                if (!mappingsWithId.any((mapping) => mapping == m && successCount > 0)) {
                  successCount++;
                }
              }

              return updated;
            }
            return m;
          }).toList();

          updatedSeriesList[seriesIndex] = series.copyWith(anilistMappings: updatedMappings);
        }
      }

      // Refresh dominant colors in the app-scoped Library sort cache, then
      // trigger a global rebuild so other open screens pick up the colors too
      try {
        Provider.of<LibraryScreenViewModel>(Manager.context, listen: false).updateColorsInSortCache();
        Manager.setState(() {});
      } catch (e) {
        logErr('Failed to refresh sort-cache colors', e);
      }

      // Save and notify when done
      if (anyChanged || forceRecalculate) {
        _library!.syncLibraryWithScanResults(
          updatedSeriesList: updatedSeriesList,
          newSeriesPaths: {},
          deletedSeriesPaths: {},
          dirtySeriesPaths: forceRecalculate ? updatedSeriesList.map((s) => s.path).toSet() : dirtySeriesPaths,
          anyChanged: anyChanged,
        );
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
