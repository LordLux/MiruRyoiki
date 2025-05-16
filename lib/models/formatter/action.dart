import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:fluent_ui/fluent_ui.dart';
import '../../utils/logging.dart';

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
  final String seriesPath;

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
  required String seriesPath,
  FormatterConfig config = const FormatterConfig(),
}) async {
  final seriesDir = Directory(seriesPath);
  final seriesName = p.basename(seriesPath);

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
    }

    // First pass: Identify season folders and related media
    final Map<int, Directory> seasonFolders = {};
    Directory? relatedMediaFolder;

    // Create standard directories if needed
    if (config.detectRelatedMedia) {
      final relatedMediaPath = p.join(seriesPath, 'Related Media');
      final relatedDir = Directory(relatedMediaPath);

      if (!await relatedDir.exists() && (await _hasRelatedMedia(seriesPath, config) || rootFiles.isNotEmpty)) {
        actions.add(FormatAction(
          type: ActionType.createFolder,
          sourcePath: relatedMediaPath,
          destPath: relatedMediaPath,
        ));
        relatedMediaFolder = relatedDir;
      } else if (await relatedDir.exists()) {
        relatedMediaFolder = relatedDir;
      }
    }

    // Process existing folders
    for (final dir in directories) {
      final dirName = p.basename(dir.path);
      final seasonInfo = _parseSeasonFolder(dirName);

      if (seasonInfo != null) {
        // This is a season folder that needs standardization
        final seasonNum = seasonInfo.seasonNumber!;
        final standardName = 'Season ${seasonNum.toString().padLeft(2, '0')}';
        final standardPath = p.join(seriesPath, standardName);

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
          final standardPath = p.join(seriesPath, 'Related Media');
          actions.add(FormatAction(
            type: ActionType.renameFolder,
            sourcePath: dir.path,
            destPath: standardPath,
          ));
        }
      }
    }

    // Process files in root directory
    final Map<int, List<FileInfo>> episodesBySeason = {};
    final List<FileInfo> relatedMediaFiles = [];

    // First pass: analyze files in root
    if (rootFiles.isNotEmpty) {
      for (final file in rootFiles) {
        final fileInfo = _analyzeFile(file.path);

        if (fileInfo.isRelatedMedia) {
          relatedMediaFiles.add(FileInfo(
            file: file,
            mediaInfo: fileInfo,
          ));
        } else if (fileInfo.seasonNumber != null) {
          final seasonNum = fileInfo.seasonNumber!;
          if (!episodesBySeason.containsKey(seasonNum)) {
            episodesBySeason[seasonNum] = [];
          }

          episodesBySeason[seasonNum]!.add(FileInfo(
            file: file,
            mediaInfo: fileInfo,
          ));
        } else {
          // If we can't determine season, assume it's related media
          relatedMediaFiles.add(FileInfo(
            file: file,
            mediaInfo: fileInfo,
          ));

          issues.add('Could not determine season for file: ${p.basename(file.path)}');
        }
      }

      // Create season folders that don't exist yet
      for (final seasonNum in episodesBySeason.keys) {
        if (!seasonFolders.containsKey(seasonNum)) {
          final seasonName = 'Season ${seasonNum.toString().padLeft(2, '0')}';
          final seasonPath = p.join(seriesPath, seasonName);

          actions.add(FormatAction(
            type: ActionType.createFolder,
            sourcePath: seasonPath,
            destPath: seasonPath,
            seasonNumber: seasonNum,
          ));

          seasonFolders[seasonNum] = Directory(seasonPath);
        }
      }

      // Plan moves for episodes by season
      for (final entry in episodesBySeason.entries) {
        final seasonNum = entry.key;
        final episodes = entry.value;
        final seasonName = 'Season ${seasonNum.toString().padLeft(2, '0')}';
        final seasonPath = p.join(seriesPath, seasonName);

        for (final episode in episodes) {
          final file = episode.file;
          final info = episode.mediaInfo;
          final episodeNum = info.episodeNumber;

          String destFileName;
          if (episodeNum != null) {
            // Format as standardized episode name
            destFileName = '${episodeNum.toString().padLeft(2, '0')} - ${info.cleanTitle}${p.extension(file.path)}';
          } else {
            // Keep original name if can't determine episode number
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

      // Plan moves for related media
      if (relatedMediaFiles.isNotEmpty) {
        if (relatedMediaFolder == null) {
          final relatedMediaPath = p.join(seriesPath, 'Related Media');
          actions.add(FormatAction(
            type: ActionType.createFolder,
            sourcePath: relatedMediaPath,
            destPath: relatedMediaPath,
          ));
          relatedMediaFolder = Directory(relatedMediaPath);
        }

        for (final fileInfo in relatedMediaFiles) {
          final file = fileInfo.file;
          final destPath = p.join(relatedMediaFolder.path, p.basename(file.path));

          actions.add(FormatAction(
            type: ActionType.moveFile,
            sourcePath: file.path,
            destPath: destPath,
          ));
        }
      }
    }

    // Process files in existing folders
    for (final dir in directories) {
      final dirName = p.basename(dir.path);
      final isSeasonFolder = _parseSeasonFolder(dirName) != null;
      final isRelatedFolder = dirName.toLowerCase() == 'related media' || dirName.toLowerCase() == 'specials' || dirName.toLowerCase() == 'ovas' || dirName.toLowerCase() == 'extras';

      // Skip if we already processed this as a season or related folder
      if (!isSeasonFolder && !isRelatedFolder) {
        // Analyze files in this unknown folder
        final files = await _getVideoFilesInDir(dir, config.videoExtensions);

        if (files.isEmpty) continue;

        // Try to determine what kind of folder this is
        int? detectedSeason;
        bool isAllRelatedMedia = true;

        for (final file in files) {
          final info = _analyzeFile(file.path);

          if (!info.isRelatedMedia) {
            isAllRelatedMedia = false;
          }

          if (info.seasonNumber != null && detectedSeason == null) {
            detectedSeason = info.seasonNumber;
          } else if (info.seasonNumber != null && detectedSeason != info.seasonNumber) {
            // Mixed seasons in one folder - mark as issue
            issues.add('Mixed seasons detected in folder: ${dir.path}');
            detectedSeason = null;
            break;
          }
        }

        if (detectedSeason != null) {
          // This appears to be a season folder with a non-standard name
          final seasonName = 'Season ${detectedSeason.toString().padLeft(2, '0')}';
          final seasonPath = p.join(seriesPath, seasonName);

          if (seasonFolders.containsKey(detectedSeason)) {
            // Season folder already exists, move files there
            for (final file in files) {
              final info = _analyzeFile(file.path);
              final episodeNum = info.episodeNumber;

              String destFileName;
              if (episodeNum != null) {
                destFileName = '${episodeNum.toString().padLeft(2, '0')} - ${info.cleanTitle}${p.extension(file.path)}';
              } else {
                destFileName = p.basename(file.path);
              }

              final destPath = p.join(seasonPath, destFileName);

              actions.add(FormatAction(
                type: ActionType.moveFile,
                sourcePath: file.path,
                destPath: destPath,
                seasonNumber: detectedSeason,
                episodeNumber: episodeNum,
              ));
            }

            // Plan to delete the empty folder if all files moved
            if (config.deleteEmptyFolders) {
              actions.add(FormatAction(
                type: ActionType.deleteEmptyFolder,
                sourcePath: dir.path,
                destPath: dir.path, // Not used but needed for the action
              ));
            }
          } else {
            // Rename this folder to standard season folder
            actions.add(FormatAction(
              type: ActionType.renameFolder,
              sourcePath: dir.path,
              destPath: seasonPath,
              seasonNumber: detectedSeason,
            ));

            // Plan to standardize episode filenames in this folder
            for (final file in files) {
              final info = _analyzeFile(file.path);
              final episodeNum = info.episodeNumber;

              if (episodeNum != null && config.organizeEpisodesByNumber) {
                final destFileName = '${episodeNum.toString().padLeft(2, '0')} - ${info.cleanTitle}${p.extension(file.path)}';
                final destPath = p.join(seasonPath, destFileName);

                if (p.basename(file.path) != destFileName) {
                  actions.add(FormatAction(
                    type: ActionType.renameFile,
                    sourcePath: file.path,
                    destPath: destPath,
                    seasonNumber: detectedSeason,
                    episodeNumber: episodeNum,
                  ));
                }
              }
            }
          }
        } else if (isAllRelatedMedia) {
          // This appears to be a related media folder with a non-standard name
          if (relatedMediaFolder != null && relatedMediaFolder.path != dir.path) {
            // Related media folder already exists, move files there
            for (final file in files) {
              final destPath = p.join(relatedMediaFolder.path, p.basename(file.path));

              actions.add(FormatAction(
                type: ActionType.moveFile,
                sourcePath: file.path,
                destPath: destPath,
              ));
            }

            // Plan to delete the empty folder if all files moved
            if (config.deleteEmptyFolders) {
              actions.add(FormatAction(
                type: ActionType.deleteEmptyFolder,
                sourcePath: dir.path,
                destPath: dir.path, // Not used but needed for the action
              ));
            }
          } else {
            // Rename this folder to standard related media folder
            final relatedMediaPath = p.join(seriesPath, 'Related Media');
            actions.add(FormatAction(
              type: ActionType.renameFolder,
              sourcePath: dir.path,
              destPath: relatedMediaPath,
            ));
            relatedMediaFolder = Directory(relatedMediaPath);
          }
        } else {
          // Mixed or unknown content, mark as issue
          issues.add('Could not determine folder type for: ${dir.path}');
        }
      }
    }
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
Future<Map<String, SeriesFormatPreview>> formatLibrary({
  required List<String> seriesPaths,
  FormatterConfig config = const FormatterConfig(),
  void Function(int processed, int total)? progressCallback,
}) async {
  final Map<String, SeriesFormatPreview> results = {};
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
        seriesName: p.basename(seriesPath),
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

Future<bool> _hasRelatedMedia(String seriesPath, FormatterConfig config) async {
  try {
    final dir = Directory(seriesPath);

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && _isVideoFile(entity.path, config.videoExtensions)) {
        final info = _analyzeFile(entity.path);
        if (info.isRelatedMedia) {
          return true;
        }
      }
    }
  } catch (e) {
    logErr('Error checking for related media', e);
  }

  return false;
}

MediaInfo _analyzeFile(String filePath) {
  final fileName = p.basenameWithoutExtension(filePath);

  // Check for S01E01 pattern
  final seasonEpisodePattern = RegExp(r'[Ss](\d{1,2})[Ee](\d{1,2})', caseSensitive: false);
  final seasonEpisodeMatch = seasonEpisodePattern.firstMatch(fileName);

  if (seasonEpisodeMatch != null) {
    final seasonNum = int.parse(seasonEpisodeMatch.group(1)!);
    final episodeNum = int.parse(seasonEpisodeMatch.group(2)!);

    // Clean up the title by removing the pattern and extra characters
    String cleanTitle = fileName.replaceFirst(seasonEpisodePattern, '').replaceAll(RegExp(r'[-_.]+'), ' ').replaceAll(RegExp(r'^\s+|\s+$'), '').replaceAll(RegExp(r'\s{2,}'), ' ');

    return MediaInfo(
      seasonNumber: seasonNum,
      episodeNumber: episodeNum,
      isRelatedMedia: false,
      cleanTitle: cleanTitle,
      originalFilename: fileName,
    );
  }

  // Check for specific numbered pattern like "01 - Episode Title"
  final numberedEpisodePattern = RegExp(r'^(\d{1,4})(\s*[-_.]\s*|\s+)(.+)$');
  final numberedMatch = numberedEpisodePattern.firstMatch(fileName);

  if (numberedMatch != null) {
    final episodeNum = int.parse(numberedMatch.group(1)!);
    final cleanTitle = numberedMatch.group(3)!.replaceAll(RegExp(r'[-_.]+'), ' ').replaceAll(RegExp(r'^\s+|\s+$'), '').replaceAll(RegExp(r'\s{2,}'), ' ');

    // Assume season 1 if episode number pattern is found but no season
    return MediaInfo(
      seasonNumber: 1,
      episodeNumber: episodeNum,
      isRelatedMedia: false,
      cleanTitle: cleanTitle,
      originalFilename: fileName,
    );
  }

  // Check for OVA/ONA/Movie/Special
  final specialPattern = RegExp(r'(OVA|ONA|Movie|Special|SP\d+|Extra)', caseSensitive: false);
  if (specialPattern.hasMatch(fileName)) {
    return MediaInfo(
      seasonNumber: null,
      episodeNumber: null,
      isRelatedMedia: true,
      cleanTitle: fileName,
      originalFilename: fileName,
    );
  }

  // If no pattern matched, return a default with no season/episode
  return MediaInfo(
    seasonNumber: null,
    episodeNumber: null,
    isRelatedMedia: false,
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
