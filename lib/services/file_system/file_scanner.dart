import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart' show decodeImageFromList;
import 'package:path/path.dart' as p;

import '../../models/series.dart';
import '../../models/episode.dart';
import '../../utils/logging.dart';
import '../../utils/path_utils.dart';

class FileScanner {
  static const List<String> _videoExtensions = ['.mkv', '.mp4', '.avi', '.mov', '.wmv', '.m4v', '.flv'];

  static const List<String> _imageExtensions = ['.ico', '.png', '.jpg', '.jpeg', '.webp'];

  /// Scan the library directory and build the series list
  Future<List<Series>> scanLibrary(String libraryPath, [Map<String, Series>? existingSeries]) async {
    final series = <Series>[];
    final dir = Directory(libraryPath);
    existingSeries ??= {};

    if (!await dir.exists()) return series;

    // Get all first level directories (each is a series)
    await for (final entity in dir.list()) {
      if (entity is Directory) {
        try {
          final existingSeries_ = existingSeries[entity.path];
          final seriesItem = await _processSeries(entity, existingSeries: existingSeries_);
          series.add(seriesItem);
        } catch (e, st) {
          logErr('3 | Error processing series ${entity.path}', e, st);
        }
      }
    }

    return series;
  }

  /// Process a series directory to extract seasons and episodes
  Future<Series> _processSeries(Directory seriesDir, {Series? existingSeries}) async {
    final name = p.basename(seriesDir.path);
    // Use existing poster/banner paths if the series already exists
    String? posterPath = existingSeries?.folderPosterPath;
    String? bannerPath = existingSeries?.folderBannerPath;

    // Only auto-detect images if this is a new series
    if (existingSeries == null) {
      posterPath = await _findPosterImage(seriesDir);
      bannerPath = await _findBannerImage(seriesDir);
      logTrace('New series: $name | Auto-detected Poster: ${posterPath?.split(ps).lastOrNull ?? 'None'} | Banner: ${bannerPath?.split(ps).lastOrNull ?? 'None'}');
    } else {
      // logTrace('Existing series: $name | Using saved Poster: ${posterPath?.split(ps).lastOrNull ?? 'None'} | Banner: ${bannerPath?.split(ps).lastOrNull ?? 'None'}');
    }

    // Check for subdirectories that match the season pattern
    final seasonDirs = <Directory>[];
    final otherDirs = <Directory>[];
    final rootVideoFiles = <File>[];

    await for (final entity in seriesDir.list()) {
      if (entity is Directory) {
        if (_isSeasonDirectory(p.basename(entity.path))) {
          seasonDirs.add(entity);
        } else {
          otherDirs.add(entity);
        }
      } else if (entity is File && _isVideoFile(entity.path)) {
        rootVideoFiles.add(entity);
      }
    }

    // Process seasons
    final seasons = <Season>[];

    // If no season directories, create a single default season from root videos
    if (seasonDirs.isEmpty && rootVideoFiles.isNotEmpty) {
      final episodes = await _processEpisodeFiles(rootVideoFiles);
      seasons.add(Season(
        name: 'Season 01',
        path: seriesDir.path,
        episodes: episodes,
      ));
    } else {
      // Process each season directory
      for (final seasonDir in seasonDirs) {
        final seasonName = p.basename(seasonDir.path);
        final episodeFiles = <File>[];

        await for (final entity in seasonDir.list(recursive: true)) {
          if (entity is File && _isVideoFile(entity.path)) {
            episodeFiles.add(entity);
          }
        }

        final episodes = await _processEpisodeFiles(episodeFiles);
        seasons.add(Season(
          name: _formatSeasonName(seasonName),
          path: seasonDir.path,
          episodes: episodes,
        ));
      }
    }

    // Process related media from other directories
    final relatedMedia = <Episode>[];

    for (final otherDir in otherDirs) {
      final episodeFiles = <File>[];

      await for (final entity in otherDir.list(recursive: true)) {
        if (entity is File && _isVideoFile(entity.path)) {
          episodeFiles.add(entity);
        }
      }

      final episodes = await _processEpisodeFiles(episodeFiles);
      relatedMedia.addAll(episodes);
    }

    // Add any videos from the root that weren't put into the default season
    if (seasonDirs.isNotEmpty && rootVideoFiles.isNotEmpty) {
      final episodes = await _processEpisodeFiles(rootVideoFiles);
      relatedMedia.addAll(episodes);
    }

    return existingSeries?.copyWith(
          name: name,
          path: seriesDir.path,
          folderPosterPath: posterPath,
          folderBannerPath: bannerPath,
          seasons: seasons,
          relatedMedia: relatedMedia,
        ) ??
        Series(
          name: name,
          path: seriesDir.path,
          folderPosterPath: posterPath,
          folderBannerPath: bannerPath,
          seasons: seasons,
          relatedMedia: relatedMedia,
          preferredPosterSource: existingSeries?.preferredPosterSource,
          preferredBannerSource: existingSeries?.preferredBannerSource,
          anilistMappings: existingSeries?.anilistMappings ?? [],
          dominantColor: existingSeries?.dominantColor,
          primaryAnilistId: existingSeries?.primaryAnilistId,
          anilistPoster: existingSeries?.anilistPosterUrl,
          anilistBanner: existingSeries?.anilistBannerUrl,
        );
  }

  /// Process video files into Episode objects
  Future<List<Episode>> _processEpisodeFiles(List<File> files) async {
    final episodes = <Episode>[];

    for (final file in files) {
      final name = _cleanEpisodeName(p.basenameWithoutExtension(file.path));
      episodes.add(Episode(
        path: file.path,
        name: name,
      ));
    }

    return episodes;
  }

  /// Find a poster image in the directory
  Future<String?> _findPosterImage(Directory dir) async {
    // First try to find an .ico file
    await for (final entity in dir.list()) {
      if (entity is File && p.extension(entity.path).toLowerCase() == '.ico') {
        return entity.path;
      }
    }

    // Then try other image formats
    await for (final entity in dir.list()) {
      if (entity is File && _imageExtensions.contains(p.extension(entity.path).toLowerCase())) {
        return entity.path;
      }
    }

    // No image found
    return null;
  }

  /// Find a banner image in the series directory
  Future<String?> _findBannerImage(Directory seriesDir) async {
    try {
      final List<FileSystemEntity> files = await seriesDir.list().toList();

      // Look for common banner image filenames
      final bannerNames = ['banner', 'background', 'backdrop', 'fanart'];
      for (final name in bannerNames) {
        for (final extension in _imageExtensions) {
          final bannerFile = files.whereType<File>().firstWhereOrNull((f) => p.basename(f.path).toLowerCase() == '$name$extension');
          if (bannerFile != null) return bannerFile.path;
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
              return file.path;
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

  /// Check if a filename is a video file
  bool _isVideoFile(String path) {
    return _videoExtensions.contains(p.extension(path).toLowerCase());
  }

  /// Check if a directory name matches the season pattern (S01, Season 01, etc.)
  bool _isSeasonDirectory(String name) {
    return RegExp(r'S\d{2}', caseSensitive: false).hasMatch(name) || RegExp(r'Season\s+\d+', caseSensitive: false).hasMatch(name);
  }

  /// Format season name to be consistent
  String _formatSeasonName(String name) {
    // Extract the season number
    final seasonMatch = RegExp(r'(\d+)', caseSensitive: false).firstMatch(name);
    if (seasonMatch != null) {
      final num = int.parse(seasonMatch.group(1)!).toString().padLeft(2, '0');
      return 'Season $num';
    }
    return name;
  }

  /// Clean up episode name from filename
  String _cleanEpisodeName(String name) {
    // Remove common patterns like S01E01, [Group], etc.
    return name
        .replaceAll(RegExp(r'[sS]\d{1,2}[eE]\d{1,2}\s*'), '') // Remove S01E01
        .replaceAll(RegExp(r'\[[^\]]+\]'), '') // Remove [Group]
        .replaceAll(RegExp(r'\([^)]+\)'), '') // Remove (info)
        .replaceAll(RegExp(r'\.\w{3,4}$'), '') // Remove extension if still present
        // .replaceAll(RegExp(r'[-_.]+'), ' ') // Replace separators with space
        .trim();
  }
}
