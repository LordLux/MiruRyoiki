import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:video_data_utils/video_data_utils.dart';

import '../../utils/path_utils.dart';
import '../../utils/logging.dart';

/// Manager for handling thumbnail extraction in a controlled manner.
class ThumbnailManager {
  static final ThumbnailManager _instance = ThumbnailManager._();
  factory ThumbnailManager() => _instance;
  ThumbnailManager._();

  // ignore: constant_identifier_names
  static const String miruryoiki_thumbnails = 'miruryoiki_thumbnails';

  final _thumbnailIsolate = ThumbnailIsolateManager();

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

  Future<void> _extractThumbnail(PathString videoPath) async {
    _activeExtractions++;

    try {
      final cachePath = await generateThumbnailPath(videoPath);

      final PathString? thumbnailPath = await _thumbnailIsolate.generateThumbnail(videoPath, cachePath);

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

  /// Clear thumbnail cache for a specific series by deleting all thumbnails that match the series path
  Future<void> clearThumbnailCacheForSeries(String seriesPath) async {
    try {
      final thumbnailsDir = Directory(await thumbnailDirectoryPath);

      if (!await thumbnailsDir.exists()) return;

      final pathHash = seriesPath.hashCode.toString().replaceAll('-', '_');
      final files = await thumbnailsDir.list().toList();

      for (final file in files) {
        if (file is File && path.basename(file.path).startsWith(pathHash)) {
          try {
            await file.delete();
            logTrace('Deleted thumbnail cache: ${file.path}');
          } catch (e) {
            logErr('Failed to delete thumbnail cache for file: ${file.path}', e);
          }
        }
      }

      // Also reset failed attempts for this series
      _failedAttempts.removeWhere((videoPath, _) => videoPath.path.startsWith(seriesPath));

      logDebug('Cleared thumbnail cache for series: $seriesPath');
    } catch (e, stack) {
      logErr('Error clearing thumbnail cache for series: $seriesPath', e, stack);
    }
  }

  /// Clear all thumbnail cache by deleting the entire thumbnails directory
  Future<void> clearAllThumbnailCache() async {
    try {
      final thumbnailsDir = Directory(await thumbnailDirectoryPath);

      if (await thumbnailsDir.exists()) {
        await thumbnailsDir.delete(recursive: true);
        logDebug('Deleted entire thumbnail cache directory');
      }

      // Reset all failed attempts
      _failedAttempts.clear();

      logDebug('Cleared all thumbnail cache');
    } catch (e, stack) {
      logErr('Error clearing all thumbnail cache', e, stack);
    }
  }

  static Future<String> get thumbnailDirectoryPath async {
    final tempDir = await getTemporaryDirectory();
    return path.join(tempDir.path, miruryoiki_thumbnails);
  }

  static Future<PathString> generateThumbnailPath(PathString videoPath) async {
    final thumbDir = await thumbnailDirectoryPath;
    final String filename = path.basenameWithoutExtension(videoPath.path);
    final String pathHash = path.dirname(videoPath.path).hashCode.toString().replaceAll('-', '_');
    final String thumbnailPath = path.join(thumbDir, '${pathHash}_$filename.png');

    final directory = Directory(path.dirname(thumbnailPath));
    if (!await directory.exists()) //
      await directory.create(recursive: true);

    return PathString(thumbnailPath);
  }
}

class ThumbnailJob {
  final String id;
  final PathString videoPath;
  final PathString outputPath;

  ThumbnailJob(this.id, this.videoPath, this.outputPath);
}

class ThumbnailResult {
  final String id;
  final PathString? thumbnailPath;
  final String? error;

  ThumbnailResult(this.id, {this.thumbnailPath, this.error});
}

class ThumbnailIsolateManager {
  static final ThumbnailIsolateManager _instance = ThumbnailIsolateManager._();
  factory ThumbnailIsolateManager() => _instance;

  Isolate? _isolate;
  SendPort? _sendPort;
  final _receivePort = ReceivePort();
  final _resultStreamController = StreamController<ThumbnailResult>.broadcast();
  Stream<ThumbnailResult> get resultStream => _resultStreamController.stream;

  final Map<String, Completer<PathString?>> _pendingJobs = {};
  bool _isInitialized = false;

  ThumbnailIsolateManager._() {
    _init();
  }

  Future<void> _init() async {
    if (_isInitialized) return;

    try {
      // Setup communication
      _receivePort.listen(_handleMessage);

      // Create the isolate
      _isolate = await Isolate.spawn(_thumbnailIsolateEntryPoint, _receivePort.sendPort);

      // Wait for the isolate to send back its SendPort
      _isInitialized = true;
    } catch (e, stack) {
      logErr('Error initializing thumbnail isolate', e, stack);
      _isInitialized = false;
    }
  }

  void _handleMessage(dynamic message) {
    if (message is SendPort) {
      // Store the send port for communicating with the isolate
      _sendPort = message;
    } else if (message is ThumbnailResult) {
      // Handle a thumbnail result
      _resultStreamController.add(message);

      final completer = _pendingJobs.remove(message.id);
      if (completer != null) {
        if (message.error != null) {
          completer.completeError(message.error!);
        } else {
          completer.complete(message.thumbnailPath);
        }
      }
    }
  }

  Future<PathString?> generateThumbnail(PathString videoPath, PathString outputPath) async {
    if (!_isInitialized) await _init();
    if (_sendPort == null) throw Exception('Thumbnail isolate not initialized');

    final id = '${DateTime.now().millisecondsSinceEpoch}_${videoPath.hashCode}';
    final job = ThumbnailJob(id, videoPath, outputPath);

    final completer = Completer<PathString?>();
    _pendingJobs[id] = completer;

    _sendPort!.send(job);
    return completer.future;
  }

  void dispose() {
    _isolate?.kill();
    _isolate = null;
    _receivePort.close();
    _resultStreamController.close();
    _isInitialized = false;
  }
}

/// Entry point for the thumbnail isolate
void _thumbnailIsolateEntryPoint(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  // Create VideoDataUtils instance once for the whole isolate
  final videoDataUtils = VideoDataUtils();

  receivePort.listen((message) async {
    if (message is ThumbnailJob) {
      try {
        final directory = Directory(path.dirname(message.outputPath.path));
        if (!await directory.exists()) await directory.create(recursive: true);

        final String videoPath;
        final prefix = "\\\\?\\";
        if (message.videoPath.path.startsWith(prefix)) {
          // Remove the "\\?\" prefix if it exists
          videoPath = message.videoPath.path.substring(prefix.length);
        } else {
          videoPath = message.videoPath.path;
        }

        final bool success = await videoDataUtils.extractCachedThumbnail(
          videoPath: videoPath,
          outputPath: message.outputPath.path,
          size: 256,
        );

        if (success && await File(message.outputPath.path).exists()) {
          sendPort.send(ThumbnailResult(message.id, thumbnailPath: message.outputPath));
        } else {
          sendPort.send(ThumbnailResult(message.id, thumbnailPath: null));
        }
      } catch (e) {
        sendPort.send(ThumbnailResult(message.id, error: e.toString()));
      }
    }
  });
}
