import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:video_data_utils/video_data_utils.dart';

import '../utils/path_utils.dart';
import '../utils/logging.dart';
import 'isolates/isolate_manager.dart';

class _ThumbnailIsolateParams {
  final PathString videoPath;
  final PathString outputPath;
  _ThumbnailIsolateParams(this.videoPath, this.outputPath);
}

/// Isolate task to generate a thumbnail for a video file.
Future<PathString?> _thumbnailIsolateTask(_ThumbnailIsolateParams params) async {
  try {
    // Ensure the output directory exists
    final directory = Directory(path.dirname(params.outputPath.path));
    if (!await directory.exists()) await directory.create(recursive: true);

    // Create fresh VideoDataUtils instance inside the isolate
    final videoDataUtils = VideoDataUtils();
    final bool success = await videoDataUtils.extractCachedThumbnail(
      videoPath: params.videoPath.path,
      outputPath: params.outputPath.path,
      size: 256, // TODO: Make this configurable if needed
    );

    if (success && await File(params.outputPath.path).exists()) //
      return params.outputPath;

    // Log the failure but return null to handle it gracefully.
    logErr('Isolate failed to generate or find thumbnail for ${params.videoPath}');
    return null;
  } catch (e, stack) {
    logErr('Exception in _thumbnailIsolateTask for ${params.videoPath}', e, stack);
    return null;
  }
}

/// Manager for handling thumbnail extraction in a controlled manner.
class ThumbnailManager {
  static final ThumbnailManager _instance = ThumbnailManager._();
  factory ThumbnailManager() => _instance;
  ThumbnailManager._();

  final Map<PathString, Completer<PathString?>> _pendingExtractions = {};
  final List<PathString> _extractionQueue = [];

  int _activeExtractions = 0;
  static const int _maxConcurrentExtractions = 5;

  final Map<PathString, int> _failedAttempts = {};
  static const int _maxAttempts = 3;

  Future<PathString?> getThumbnail(PathString videoPath, {bool resetFailedStatus = false}) async {
    if (!resetFailedStatus && _failedAttempts.containsKey(videoPath) && _failedAttempts[videoPath]! >= _maxAttempts) //
      return null;

    if (_pendingExtractions.containsKey(videoPath)) //
      return _pendingExtractions[videoPath]!.future;

    final PathString cachePath = await generateThumbnailPath(videoPath);
    if (await File(cachePath.path).exists()) //
      return cachePath;

    final completer = Completer<PathString?>();
    _pendingExtractions[videoPath] = completer;
    _extractionQueue.add(videoPath);

    _processQueue();

    return completer.future;
  }

  Future<void> _processQueue() async {
    if (_activeExtractions >= _maxConcurrentExtractions || _extractionQueue.isEmpty) return;

    while (_activeExtractions < _maxConcurrentExtractions && _extractionQueue.isNotEmpty) {
      final videoPath = _extractionQueue.removeAt(0);
      _extractThumbnail(videoPath);
    }
  }

  /// This is the refactored method that now uses IsolateManager.
  Future<void> _extractThumbnail(PathString videoPath) async {
    _activeExtractions++;

    try {
      final cachePath = await generateThumbnailPath(videoPath);

      final isolateManager = IsolateManager();
      final params = _ThumbnailIsolateParams(videoPath, cachePath);

      final PathString? thumbnailPath = await isolateManager.runInIsolate(_thumbnailIsolateTask, params);

      if (thumbnailPath?.pathMaybe != null) {
        _failedAttempts.remove(videoPath);
        _pendingExtractions[videoPath]?.complete(thumbnailPath);
      } else {
        _failedAttempts[videoPath] = (_failedAttempts[videoPath] ?? 0) + 1;
        _pendingExtractions[videoPath]?.complete(null); // failed
      }
    } catch (e, stack) {
      logErr('Error extracting thumbnail for $videoPath', e, stack);
      _failedAttempts[videoPath] = (_failedAttempts[videoPath] ?? 0) + 1;
      _pendingExtractions[videoPath]?.completeError(e, stack);
    } finally {
      _pendingExtractions.remove(videoPath);
      _activeExtractions--;
      _processQueue();
    }
  }

  void resetFailedAttemptsForPath(PathString path) => _failedAttempts.remove(path);

  void resetAllFailedAttempts() => _failedAttempts.clear();

  static Future<PathString> generateThumbnailPath(PathString videoPath) async {
    final tempDir = await getTemporaryDirectory();
    final String filename = path.basenameWithoutExtension(videoPath.path);
    final String pathHash = path.dirname(videoPath.path).hashCode.toString().replaceAll('-', '_');
    final String thumbnailPath = path.join(tempDir.path, 'miruryoiki_thumbnails', '${pathHash}_$filename.png');

    final directory = Directory(path.dirname(thumbnailPath));
    if (!await directory.exists()) //
      await directory.create(recursive: true);

    return PathString(thumbnailPath);
  }
}
