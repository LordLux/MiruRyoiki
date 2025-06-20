import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../utils/path_utils.dart';
import 'file_system/media_info.dart';
import '../utils/logging.dart';

class ThumbnailManager {
  static final ThumbnailManager _instance = ThumbnailManager._();
  factory ThumbnailManager() => _instance;
  ThumbnailManager._();

  // Queue of pending thumbnail extractions
  final Map<PathString, Completer<PathString?>> _pendingExtractions = {};
  final List<PathString> _extractionQueue = [];

  int _activeExtractions = 0;
  static const int _maxConcurrentExtractions = 5;

  // Cache of failed attempts
  final Map<PathString, int> _failedAttempts = {};
  static const int _maxAttempts = 3;

  Future<PathString?> getThumbnail(PathString videoPath, {bool resetFailedStatus = false}) async {
    // Check if this path is already marked as failed too many times
    if (!resetFailedStatus && _failedAttempts.containsKey(videoPath) && _failedAttempts[videoPath]! >= _maxAttempts) {
      return null;
    }

    // If already being processed, return the existing future
    if (_pendingExtractions.containsKey(videoPath)) {
      return _pendingExtractions[videoPath]!.future;
    }

    // Check if thumbnail already exists
    final PathString cachePath = await generateThumbnailPath(videoPath);
    if (await File(cachePath.path).exists()) //
      return cachePath;

    // Create a completer for this extraction
    final completer = Completer<PathString?>();
    _pendingExtractions[videoPath] = completer;
    _extractionQueue.add(videoPath);

    // Process queue
    _processQueue();

    return completer.future;
  }

  void _processQueue() {
    if (_activeExtractions >= _maxConcurrentExtractions || _extractionQueue.isEmpty) //
      return;

    // Process up to max concurrent extractions
    while (_activeExtractions < _maxConcurrentExtractions && _extractionQueue.isNotEmpty) {
      final videoPath = _extractionQueue.removeAt(0);
      _extractThumbnail(videoPath);
    }
  }

  Future<void> _extractThumbnail(PathString videoPath) async {
    _activeExtractions++;

    try {
      final cachePath = await generateThumbnailPath(videoPath);

      final token = RootIsolateToken.instance;
      final PathString? thumbnailPath = await _extractThumbnailIsolate({
        'videoPath': videoPath,
        'outputPath': cachePath,
        'token': token,
      });

      if (thumbnailPath?.pathMaybe != null) {
        _failedAttempts.remove(videoPath);
        _pendingExtractions[videoPath]?.complete(thumbnailPath);
      } else {
        _failedAttempts[videoPath] = (_failedAttempts[videoPath] ?? 0) + 1;
        _pendingExtractions[videoPath]?.complete(PathString(null));
      }
    } catch (e) {
      logErr('Error extracting thumbnail', e);
      _failedAttempts[videoPath] = (_failedAttempts[videoPath] ?? 0) + 1;
      _pendingExtractions[videoPath]?.completeError(e);
    } finally {
      _pendingExtractions.remove(videoPath);
      _activeExtractions--;
      // Process next in queue
      _processQueue();
    }
  }

  static Future<PathString?> _extractThumbnailIsolate(Map<String, dynamic> params) async {
    final PathString videoPath = params['videoPath'] as PathString;
    final PathString outputPath = params['outputPath'] as PathString;
    final token = params['token'] as RootIsolateToken;

    BackgroundIsolateBinaryMessenger.ensureInitialized(token);

    // Ensure directory exists
    final directory = Directory(path.dirname(outputPath.path));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return await MediaInfo.extractThumbnail(videoPath, outputPath: outputPath);
  }

  void resetFailedAttemptsForPath(PathString path) {
    _failedAttempts.remove(path);
  }

  void resetAllFailedAttempts() {
    _failedAttempts.clear();
  }

  static Future<PathString> generateThumbnailPath(PathString videoPath) async {
    final tempDir = await getTemporaryDirectory();
    final String filename = path.basenameWithoutExtension(videoPath.path);

    final String pathHash = path.dirname(videoPath.path).hashCode.toString().replaceAll('-', '_');
    final String thumbnailPath = path.join(
      tempDir.path,
      'miruryoiki_thumbnails',
      '${pathHash}_$filename.png',
    );

    final directory = Directory(path.dirname(thumbnailPath));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return PathString(thumbnailPath);
  }
}
