import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../models/series.dart';
import '../models/episode.dart';

class FileScanner {
  static const List<String> _videoExtensions = [
    '.mkv', '.mp4', '.avi', '.mov', '.wmv', '.m4v', '.flv'
  ];
  
  static const List<String> _imageExtensions = [
    '.ico', '.png', '.jpg', '.jpeg', '.webp'
  ];
  
  /// Scan the library directory and build the series list
  Future<List<Series>> scanLibrary(String libraryPath) async {
    final series = <Series>[];
    final dir = Directory(libraryPath);
    
    if (!await dir.exists()) {
      return series;
    }

    // Get all first level directories (each is a series)
    await for (final entity in dir.list()) {
      if (entity is Directory) {
        try {
          final seriesItem = await _processSeries(entity);
          series.add(seriesItem);
        } catch (e) {
          debugPrint('Error processing series ${entity.path}: $e');
        }
      }
    }
    
    return series;
  }
  
  /// Process a series directory to extract seasons and episodes
  Future<Series> _processSeries(Directory seriesDir) async {
    final name = p.basename(seriesDir.path);
    final posterPath = await _findPosterImage(seriesDir);
    
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
    
    return Series(
      name: name,
      path: seriesDir.path,
      folderImagePath: posterPath,
      seasons: seasons,
      relatedMedia: relatedMedia,
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
      if (entity is File && 
          _imageExtensions.contains(p.extension(entity.path).toLowerCase())) {
        return entity.path;
      }
    }
    
    // No image found
    return null;
  }
  
  /// Check if a filename is a video file
  bool _isVideoFile(String path) {
    return _videoExtensions.contains(p.extension(path).toLowerCase());
  }
  
  /// Check if a directory name matches the season pattern (S01, Season 01, etc.)
  bool _isSeasonDirectory(String name) {
    return RegExp(r'S\d{2}', caseSensitive: false).hasMatch(name) || 
           RegExp(r'Season\s+\d+', caseSensitive: false).hasMatch(name);
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