import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import '../../utils/logging.dart';
import '../../utils/path_utils.dart';

/// Type of formatting action to perform
enum ActionType {
  moveFile,
  renameFile,
  createFolder,
  moveFolder,
  renameFolder,
  deleteEmptyFolder,
}

/// Represents a single file or folder operation to be performed
class FormatAction {
  /// Type of action to perform
  final ActionType type;

  /// Source path (original file/folder)
  final String sourcePath;

  /// Destination path (where it should be moved/renamed to)
  final String destPath;

  /// Optional season number this action is related to
  final int? seasonNumber;

  /// Optional episode number this action is related to
  final int? episodeNumber;

  /// Optional issue description if this action has a problem
  final String? issue;

  const FormatAction({
    required this.type,
    required this.sourcePath,
    required this.destPath,
    this.seasonNumber,
    this.episodeNumber,
    this.issue,
  });

  bool get hasIssue => issue != null;

  String get displayName => p.basename(sourcePath);
  String get destDisplayName => p.basename(destPath);

  @override
  String toString() => '$type: $displayName → $destDisplayName${hasIssue ? ' (Issue: $issue)' : ''}';
}

/// Preview of all formatting actions for a series
class SeriesFormatPreview {
  /// Path to the series folder
  final PathString seriesPath;

  /// Name of the series
  final String seriesName;

  /// All actions to be applied
  final List<FormatAction> actions;

  /// Any issues encountered during analysis
  final List<String> issues;

  /// Whether the preview contains actions with issues
  bool get hasIssues => actions.any((action) => action.hasIssue) || issues.isNotEmpty;

  /// Calculate statistics about what will change
  int get filesMoved => actions.where((a) => a.type == ActionType.moveFile).length;
  int get filesRenamed => actions.where((a) => a.type == ActionType.renameFile).length;
  int get foldersCreated => actions.where((a) => a.type == ActionType.createFolder).length;
  int get foldersMoved => actions.where((a) => a.type == ActionType.moveFolder).length;
  int get foldersRenamed => actions.where((a) => a.type == ActionType.renameFolder).length;
  int get foldersDeleted => actions.where((a) => a.type == ActionType.deleteEmptyFolder).length;

  SeriesFormatPreview({
    required this.seriesPath,
    required this.seriesName,
    required this.actions,
    this.issues = const [],
  });

  @override
  String toString() => 'SeriesFormatPreview: $seriesName (${actions.length} actions, ${hasIssues ? 'has issues' : 'no issues'})';
}

/// Configuration for the series formatter
class FormatterConfig {
  /// List of video file extensions to process
  final List<String> videoExtensions;

  /// Whether to try to detect seasons from folder names
  final bool detectSeasonsFromFolders;

  /// Whether to try to detect seasons from filenames
  final bool detectSeasonsFromFilenames;

  /// Whether to detect related media like OVAs
  final bool detectRelatedMedia;

  /// Whether to organize episodes by number
  final bool organizeEpisodesByNumber;

  /// Whether to delete empty folders after moving files
  final bool deleteEmptyFolders;

  const FormatterConfig({
    this.videoExtensions = const ['.mkv', '.mp4', '.avi', '.mov', '.wmv', '.m4v', '.flv'],
    this.detectSeasonsFromFolders = true,
    this.detectSeasonsFromFilenames = true,
    this.detectRelatedMedia = true,
    this.organizeEpisodesByNumber = true,
    this.deleteEmptyFolders = true,
  });
}

/// Helper class for season and episode detection
class MediaInfo {
  final int? seasonNumber;
  final int? episodeNumber;
  final bool isRelatedMedia;
  final String cleanTitle;
  final String originalFilename;

  const MediaInfo({
    this.seasonNumber,
    this.episodeNumber,
    this.isRelatedMedia = false,
    required this.cleanTitle,
    required this.originalFilename,
  });
}

/// Format the series folder structure (preview mode)
Future<SeriesFormatPreview> formatSeriesFolders({
  required PathString seriesPath,
  FormatterConfig config = const FormatterConfig(),
}) async {
  final seriesDir = Directory(seriesPath.path);
  final seriesName = p.basename(seriesPath.path);

  if (!await seriesDir.exists()) {
    return SeriesFormatPreview(
      seriesPath: seriesPath,
      seriesName: seriesName,
      actions: [],
      issues: ['Series folder does not exist: $seriesPath'],
    );
  }

  final List<FormatAction> actions = [];
  final List<String> issues = [];

  try {
    // Analyze directory structure
    final List<FileSystemEntity> entities = await seriesDir.list().toList();

    // Sort entities into directories and files
    final List<Directory> directories = [];
    final List<File> rootFiles = [];

    for (final entity in entities) {
      if (entity is Directory) {
        directories.add(entity);
      } else if (entity is File && _isVideoFile(entity.path, config.videoExtensions)) {
        rootFiles.add(entity);
      }
      // else ignore non-video files
    }

    // First pass: Identify season folders and related media
    final Map<int, Directory> seasonFolders = {};
    Directory? relatedMediaFolder;

    // Process existing folders to identify seasons and related media
    for (final dir in directories) {
      final dirName = p.basename(dir.path);
      final seasonInfo = _parseSeasonFolder(dirName);

      if (seasonInfo.seasonNumber != null) {
        // This is a season folder that may need standardization
        final seasonNum = seasonInfo.seasonNumber!;
        final standardName = 'Season ${seasonNum.toString().padLeft(2, '0')}';
        final standardPath = p.join(seriesPath.path, standardName);

        if (dirName != standardName) {
          actions.add(FormatAction(
            type: ActionType.renameFolder,
            sourcePath: dir.path,
            destPath: standardPath,
            seasonNumber: seasonNum,
          ));
        }

        seasonFolders[seasonNum] = dir;
      } else if (dirName.toLowerCase() == 'related media' || dirName.toLowerCase() == 'specials' || dirName.toLowerCase() == 'ovas' || dirName.toLowerCase() == 'extras') {
        // Already have a related media folder
        relatedMediaFolder = dir;

        // Standardize name if needed
        if (dirName != 'Related Media') {
          final standardPath = p.join(seriesPath.path, 'Related Media');
          actions.add(FormatAction(
            type: ActionType.renameFolder,
            sourcePath: dir.path,
            destPath: standardPath,
          ));
        }
      }
    }

    // Process multiple related media folders if present
    final List<Directory> relatedMediaFolders = directories.where((dir) {
      final dirName = p.basename(dir.path).toLowerCase();
      return dirName == 'related media' || dirName == 'specials' || dirName == 'ovas' || dirName == 'extras' || dirName == 'movies';
    }).toList();

    // If we have multiple related folders, consolidate them
    // If we have related folders
    if (relatedMediaFolders.isNotEmpty) {
      // First check if we already have a standard "Related Media" folder
      Directory? existingRelatedMedia = relatedMediaFolders.firstWhereOrNull((dir) => p.basename(dir.path) == 'Related Media');

      final targetPath = p.join(seriesPath.path, 'Related Media');

      // If no standard "Related Media" folder exists, create one
      if (existingRelatedMedia == null) {
        actions.add(FormatAction(
          type: ActionType.createFolder,
          sourcePath: targetPath,
          destPath: targetPath,
        ));

        // Process all related media folders
        for (final folder in relatedMediaFolders) {
          // Standardize folder name if necessary
          if (p.basename(folder.path) != 'Related Media') {
            // Get files from this folder
            final files = await _getVideoFilesInDir(folder, config.videoExtensions);

            // Move all files to the standard folder
            for (final file in files) {
              final destPath = p.join(targetPath, p.basename(file.path));

              actions.add(FormatAction(
                type: ActionType.moveFile,
                sourcePath: file.path,
                destPath: destPath,
              ));
            }
          }
        }
      }
      // We have an existing Related Media folder
      else {
        // Process other related folders only
        for (final folder in relatedMediaFolders) {
          if (folder.path == existingRelatedMedia.path) continue;

          // Standardize any other related media folder names if needed
          if (p.basename(folder.path) != 'Related Media') {
            // Get files from this folder
            final files = await _getVideoFilesInDir(folder, config.videoExtensions);

            // Move all files to the standard folder
            for (final file in files) {
              final destPath = p.join(existingRelatedMedia.path, p.basename(file.path));

              actions.add(FormatAction(
                type: ActionType.moveFile,
                sourcePath: file.path,
                destPath: destPath,
              ));
            }

            // Don't plan folder deletion
          }
        }
      }
    }

    // Special handling for flat structure (no subfolders or no season folders)
    if ((directories.isEmpty || seasonFolders.isEmpty) && rootFiles.isNotEmpty) {
      logTrace('Flat series structure detected. Organizing files into season folders.');

      // Analyze and group files by season
      final Map<int, List<FileInfo>> seasonGroups = {};
      final List<FileInfo> specialFiles = [];

      // First pass - identify files
      for (final file in rootFiles) {
        final info = _analyzeFile(file.path);

        if (info.isRelatedMedia) {
          specialFiles.add(FileInfo(file: file, mediaInfo: info));
        } else if (info.seasonNumber != null) {
          final seasonNum = info.seasonNumber!;
          seasonGroups.putIfAbsent(seasonNum, () => []);
          seasonGroups[seasonNum]!.add(FileInfo(file: file, mediaInfo: info));
        } else {
          // If we can't determine season or special, default to specials
          specialFiles.add(FileInfo(file: file, mediaInfo: info));
          issues.add('Could not determine type for file: ${p.basename(file.path)}');
        }
      }

      // Create season folders for each detected season (only if we don't already have them)
      for (final seasonNum in seasonGroups.keys) {
        if (!seasonFolders.containsKey(seasonNum)) {
          final seasonName = 'Season ${seasonNum.toString().padLeft(2, '0')}';
          final seasonPath = p.join(seriesPath.path, seasonName);

          actions.add(FormatAction(
            type: ActionType.createFolder,
            sourcePath: seasonPath,
            destPath: seasonPath,
            seasonNumber: seasonNum,
          ));
        }
      }

      // Plan episode moves
      for (final entry in seasonGroups.entries) {
        final seasonNum = entry.key;
        final episodes = entry.value;
        final seasonName = 'Season ${seasonNum.toString().padLeft(2, '0')}';
        final seasonPath = p.join(seriesPath.path, seasonName);

        for (final episodeInfo in episodes) {
          final file = episodeInfo.file;
          final mediaInfo = episodeInfo.mediaInfo;
          final episodeNum = mediaInfo.episodeNumber;

          String destFileName;
          if (episodeNum != null) {
            destFileName = '${episodeNum.toString().padLeft(2, '0')} - ${mediaInfo.cleanTitle}${p.extension(file.path)}';
          } else {
            destFileName = p.basename(file.path);
          }

          final destPath = p.join(seasonPath, destFileName);

          actions.add(FormatAction(
            type: ActionType.moveFile,
            sourcePath: file.path,
            destPath: destPath,
            seasonNumber: seasonNum,
            episodeNumber: episodeNum,
          ));
        }
      }

      // Handle special files if any exist
      if (specialFiles.isNotEmpty && relatedMediaFolder == null) {
        final relatedMediaPath = p.join(seriesPath.path, 'Related Media');

        actions.add(FormatAction(
          type: ActionType.createFolder,
          sourcePath: relatedMediaPath,
          destPath: relatedMediaPath,
        ));

        for (final specialInfo in specialFiles) {
          final file = specialInfo.file;
          final destPath = p.join(relatedMediaPath, p.basename(file.path));

          actions.add(FormatAction(
            type: ActionType.moveFile,
            sourcePath: file.path,
            destPath: destPath,
          ));
        }
      }
    }

    // Process files in existing folders to standardize filenames if needed
    for (final dir in directories) {
      final dirName = p.basename(dir.path);
      final seasonInfo = _parseSeasonFolder(dirName);

      if (seasonInfo.seasonNumber != null) {
        final seasonNum = seasonInfo.seasonNumber!;
        final seasonPath = p.join(seriesPath.path, 'Season ${seasonNum.toString().padLeft(2, '0')}');

        // Get files in this season folder
        final files = await _getVideoFilesInDir(dir, config.videoExtensions);

        // Only process files if we need to standardize episode names
        if (config.organizeEpisodesByNumber) {
          for (final file in files) {
            final info = _analyzeFile(file.path);
            final episodeNum = info.episodeNumber;

            if (episodeNum != null) {
              final standardName = '${episodeNum.toString().padLeft(2, '0')} - ${info.cleanTitle}${p.extension(file.path)}';
              final currentName = p.basename(file.path);

              if (standardName != currentName) {
                final destPath = p.join(seasonPath, standardName);

                actions.add(FormatAction(
                  type: ActionType.renameFile,
                  sourcePath: file.path,
                  destPath: destPath,
                  seasonNumber: seasonNum,
                  episodeNumber: episodeNum,
                ));
              }
            }
          }
        }
      }
    }

    // Deduplicate actions - prevent redundant moves/renames
    final Set<String> processedFiles = {};
    actions.removeWhere((action) {
      if (action.type == ActionType.moveFile || action.type == ActionType.renameFile) {
        if (processedFiles.contains(action.sourcePath)) {
          return true; // Remove duplicate actions
        }
        processedFiles.add(action.sourcePath);
      }
      return false;
    });
  } catch (e, stackTrace) {
    issues.add('Error analyzing series: $e');
    logErr('Error in formatSeriesFolders', e, stackTrace);
  }

  return SeriesFormatPreview(
    seriesPath: seriesPath,
    seriesName: seriesName,
    actions: actions,
    issues: issues,
  );
}

/// Apply the formatting actions to the filesystem
Future<bool> applySeriesFormatting(SeriesFormatPreview preview, {bool skipIssues = false}) async {
  final actionsCopy = List<FormatAction>.from(preview.actions);
  final List<String> errors = [];

  // Sort actions to ensure proper order (create folders first, then move files, etc)
  actionsCopy.sort((a, b) {
    final aOrder = _getActionPriority(a.type);
    final bOrder = _getActionPriority(b.type);
    return aOrder.compareTo(bOrder);
  });

  for (final action in actionsCopy) {
    try {
      if (action.hasIssue && !skipIssues) {
        logDebug('Skipping action with issue: ${action.toString()}');
        continue;
      }

      switch (action.type) {
        case ActionType.createFolder:
          final dir = Directory(action.destPath);
          if (!await dir.exists()) {
            await dir.create(recursive: true);
            logTrace('Created folder: ${action.destPath}');
          }
          break;

        case ActionType.moveFile:
          final sourceFile = File(action.sourcePath);
          if (await sourceFile.exists()) {
            final destDir = Directory(p.dirname(action.destPath));
            if (!await destDir.exists()) {
              await destDir.create(recursive: true);
            }

            // Check if destination exists
            final destFile = File(action.destPath);
            if (await destFile.exists() && action.sourcePath != action.destPath) {
              final extension = p.extension(action.destPath);
              final baseName = p.basenameWithoutExtension(action.destPath);
              final newName = '$baseName (copy)$extension';
              final newPath = p.join(p.dirname(action.destPath), newName);

              await sourceFile.copy(newPath);
              await sourceFile.delete();
              logTrace('Moved file with rename: ${action.sourcePath} → $newPath');
            } else {
              await sourceFile.rename(action.destPath);
              logTrace('Moved file: ${action.sourcePath} → ${action.destPath}');
            }
          }
          break;

        case ActionType.renameFile:
          final sourceFile = File(action.sourcePath);
          if (await sourceFile.exists()) {
            // Check if destination exists
            final destFile = File(action.destPath);
            if (await destFile.exists() && action.sourcePath != action.destPath) {
              final extension = p.extension(action.destPath);
              final baseName = p.basenameWithoutExtension(action.destPath);
              final newName = '$baseName (copy)$extension';
              final newPath = p.join(p.dirname(action.destPath), newName);

              await sourceFile.copy(newPath);
              await sourceFile.delete();
              logTrace('Renamed file with conflict: ${action.sourcePath} → $newPath');
            } else {
              await sourceFile.rename(action.destPath);
              logTrace('Renamed file: ${action.sourcePath} → ${action.destPath}');
            }
          }
          break;

        case ActionType.moveFolder:
          final sourceDir = Directory(action.sourcePath);
          if (await sourceDir.exists()) {
            final destDir = Directory(action.destPath);
            if (!await destDir.exists()) {
              await destDir.create(recursive: true);

              // Copy all contents
              await for (final entity in sourceDir.list(recursive: false)) {
                if (entity is File) {
                  final destFile = p.join(destDir.path, p.basename(entity.path));
                  await entity.copy(destFile);
                } else if (entity is Directory) {
                  final subDestDir = p.join(destDir.path, p.basename(entity.path));
                  await _recursiveCopyDirectory(entity, Directory(subDestDir));
                }
              }

              // Delete original after copy
              await sourceDir.delete(recursive: true);
              logTrace('Moved folder: ${action.sourcePath} → ${action.destPath}');
            } else {
              // Destination already exists, merge contents
              await for (final entity in sourceDir.list(recursive: false)) {
                if (entity is File) {
                  final destFile = p.join(destDir.path, p.basename(entity.path));
                  if (!await File(destFile).exists()) {
                    await entity.copy(destFile);
                  } else {
                    final baseName = p.basenameWithoutExtension(entity.path);
                    final extension = p.extension(entity.path);
                    final newName = '$baseName (copy)$extension';
                    final newPath = p.join(destDir.path, newName);
                    await entity.copy(newPath);
                  }
                } else if (entity is Directory) {
                  final subDestDir = p.join(destDir.path, p.basename(entity.path));
                  await _recursiveCopyDirectory(entity, Directory(subDestDir));
                }
              }

              // Delete original after copy
              await sourceDir.delete(recursive: true);
              logTrace('Merged folder: ${action.sourcePath} → ${action.destPath}');
            }
          }
          break;

        case ActionType.renameFolder:
          final sourceDir = Directory(action.sourcePath);
          if (await sourceDir.exists()) {
            await sourceDir.rename(action.destPath);
            logTrace('Renamed folder: ${action.sourcePath} → ${action.destPath}');
          }
          break;

        case ActionType.deleteEmptyFolder:
          final dir = Directory(action.sourcePath);
          if (await dir.exists()) {
            final contents = await dir.list().toList();
            if (contents.isEmpty) {
              await dir.delete();
              logTrace('Deleted empty folder: ${action.sourcePath}');
            } else {
              logDebug('Cannot delete non-empty folder: ${action.sourcePath}');
            }
          }
          break;
      }
    } catch (e, stackTrace) {
      final error = 'Error applying action ${action.type}: ${p.basename(action.sourcePath)} - $e';
      errors.add(error);
      logErr(error, e, stackTrace);
    }
  }

  if (errors.isNotEmpty) {
    logErr('Failed to apply all format actions. ${errors.length} errors occurred.');
    return false;
  }

  return true;
}

/// Format all series in the library
Future<Map<PathString, SeriesFormatPreview>> formatLibrary({
  required List<PathString> seriesPaths,
  FormatterConfig config = const FormatterConfig(),
  void Function(int processed, int total)? progressCallback,
}) async {
  final Map<PathString, SeriesFormatPreview> results = {};
  int processed = 0;

  for (final seriesPath in seriesPaths) {
    try {
      final preview = await formatSeriesFolders(
        seriesPath: seriesPath,
        config: config,
      );

      results[seriesPath] = preview;
      processed++;

      if (progressCallback != null) {
        progressCallback(processed, seriesPaths.length);
      }
    } catch (e, stackTrace) {
      logErr('Error formatting series: $seriesPath', e, stackTrace);
      results[seriesPath] = SeriesFormatPreview(
        seriesPath: seriesPath,
        seriesName: p.basename(seriesPath.path),
        actions: [],
        issues: ['Error analyzing series: $e'],
      );
      processed++;

      if (progressCallback != null) {
        progressCallback(processed, seriesPaths.length);
      }
    }
  }

  return results;
}

// Helper class for file processing
class FileInfo {
  final File file;
  final MediaInfo mediaInfo;

  const FileInfo({
    required this.file,
    required this.mediaInfo,
  });
}

// Helper methods

int _getActionPriority(ActionType type) {
  switch (type) {
    case ActionType.createFolder:
      return 0; // Do first
    case ActionType.renameFolder:
      return 1;
    case ActionType.moveFolder:
      return 2;
    case ActionType.moveFile:
      return 3;
    case ActionType.renameFile:
      return 4;
    case ActionType.deleteEmptyFolder:
      return 5; // Do last
  }
}

MediaInfo _parseSeasonFolder(String folderName) {
  // Common patterns: "Season 01", "Season 1", "S01", etc.
  final seasonPatterns = [
    RegExp(r'[Ss]eason\s*(\d+)', caseSensitive: false),
    RegExp(r'[Ss](\d+)', caseSensitive: false),
  ];

  for (final pattern in seasonPatterns) {
    final match = pattern.firstMatch(folderName);
    if (match != null) {
      final seasonNum = int.parse(match.group(1)!);
      if (seasonNum > 0) {
        return MediaInfo(
          seasonNumber: seasonNum,
          episodeNumber: null,
          isRelatedMedia: false,
          cleanTitle: folderName,
          originalFilename: folderName,
        );
      }
    }
  }
  // Check for season names with words (Season Two, Season Three, etc.)
  final wordSeasonPattern = RegExp(r'[Ss]eason\s+(Two|Three|Four|Five|Six|Seven|Eight|Nine|Ten)', caseSensitive: false);
  final wordMatch = wordSeasonPattern.firstMatch(folderName);
  if (wordMatch != null) {
    final word = wordMatch.group(1)!.toLowerCase();
    int seasonNum;

    switch (word) {
      case 'two':
        seasonNum = 2;
        break;
      case 'three':
        seasonNum = 3;
        break;
      case 'four':
        seasonNum = 4;
        break;
      case 'five':
        seasonNum = 5;
        break;
      case 'six':
        seasonNum = 6;
        break;
      case 'seven':
        seasonNum = 7;
        break;
      case 'eight':
        seasonNum = 8;
        break;
      case 'nine':
        seasonNum = 9;
        break;
      case 'ten':
        seasonNum = 10;
        break;
      default:
        seasonNum = 1;
        break;
    }

    return MediaInfo(
      seasonNumber: seasonNum,
      episodeNumber: null,
      isRelatedMedia: false,
      cleanTitle: folderName,
      originalFilename: folderName,
    );
  }

  return MediaInfo(
    seasonNumber: null,
    episodeNumber: null,
    isRelatedMedia: false,
    cleanTitle: folderName,
    originalFilename: folderName,
  );
}

bool _isVideoFile(String path, List<String> extensions) {
  final ext = p.extension(path).toLowerCase();
  return extensions.contains(ext);
}

Future<List<File>> _getVideoFilesInDir(Directory dir, List<String> extensions) async {
  final files = <File>[];

  await for (final entity in dir.list(recursive: false)) {
    if (entity is File && _isVideoFile(entity.path, extensions)) {
      files.add(entity);
    }
  }

  return files;
}

/// Cleans up a string by removing unwanted characters and reducing multiple spaces
String cleanedString(String input) {
  // Remove unwanted characters and reduce multiple spaces
  return input
      .replaceAll(RegExp(r'[-_.]+'), ' ') // - _ . -> space
      .replaceAll(RegExp(r'^\s+|\s+$'), '') // Trim leading/trailing spaces
      .replaceAll(RegExp(r'\s{2,}'), ' '); // Reduce multiple spaces to single space
}

MediaInfo _analyzeFile(String filePath) {
  final fileName = p.basenameWithoutExtension(filePath);

  // 1. Check for S01E01 pattern (standard season/episode)
  final seasonEpisodePattern = RegExp(r'[Ss](\d{1,2})[Ee](\d{1,2})', caseSensitive: false);
  final seasonEpisodeMatch = seasonEpisodePattern.firstMatch(fileName);

  if (seasonEpisodeMatch != null) {
    final seasonNum = int.parse(seasonEpisodeMatch.group(1)!);
    final episodeNum = int.parse(seasonEpisodeMatch.group(2)!);

    // Clean up the title by removing the pattern and extra characters
    String cleanTitle = cleanedString(fileName.replaceFirst(seasonEpisodePattern, ''));

    return MediaInfo(
      seasonNumber: seasonNum,
      episodeNumber: episodeNum,
      isRelatedMedia: false,
      cleanTitle: cleanTitle,
      originalFilename: fileName,
    );
  }

  // 2. Check for standalone season marker (S01 without episode part)
  // This should be treated as a special if not followed by E01 pattern
  final standaloneSeasonPattern = RegExp(r'^[Ss](\d{1,2})(?![Ee])', caseSensitive: false);
  final standaloneSeasonMatch = standaloneSeasonPattern.firstMatch(fileName);

  if (standaloneSeasonMatch != null) {
    return MediaInfo(
      seasonNumber: null,
      episodeNumber: null,
      isRelatedMedia: true, // Treat as special/related media
      cleanTitle: fileName,
      originalFilename: fileName,
    );
  }

  // 3. Check for specific numbered pattern like "01 - Episode Title"
  final numberedEpisodePattern = RegExp(r'^(\d{1,4})(\s*[-_.]\s*|\s+)(.+)$');
  final numberedMatch = numberedEpisodePattern.firstMatch(fileName);

  if (numberedMatch != null) {
    final episodeNum = int.parse(numberedMatch.group(1)!);
    final cleanTitle = cleanedString(numberedMatch.group(3)!);

    // Always assume season 1 if only episode number is found
    return MediaInfo(
      seasonNumber: 1, // Default to Season 1 for numbered episodes
      episodeNumber: episodeNum,
      isRelatedMedia: false,
      cleanTitle: cleanTitle,
      originalFilename: fileName,
    );
  }

  // 4. Enhanced special detection: Check for Special, SP prefixes
  final specialPrefixPattern = RegExp(r'^(Special|SP\d*|OVA|ONA|Movie|Extra)', caseSensitive: false);
  if (specialPrefixPattern.hasMatch(fileName)) {
    return MediaInfo(
      seasonNumber: null,
      episodeNumber: null,
      isRelatedMedia: true, // Mark as related media
      cleanTitle: fileName,
      originalFilename: fileName,
    );
  }

  // 5. If no pattern matched, return a default with no season/episode
  return MediaInfo(
    seasonNumber: null,
    episodeNumber: null,
    isRelatedMedia: false, // defaults to not related media
    cleanTitle: fileName,
    originalFilename: fileName,
  );
}

Future<void> _recursiveCopyDirectory(Directory source, Directory target) async {
  await target.create(recursive: true);

  await for (final entity in source.list(recursive: false)) {
    if (entity is File) {
      final newPath = p.join(target.path, p.basename(entity.path));
      await entity.copy(newPath);
    } else if (entity is Directory) {
      final newDirectory = Directory(p.join(target.path, p.basename(entity.path)));
      await _recursiveCopyDirectory(entity, newDirectory);
    }
  }
}
