import 'dart:async';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:video_data_utils/video_data_utils.dart';
import '../../main.dart' show rootIsolateToken;
import '../../models/metadata.dart';
import '../../utils/logging.dart';
import '../../utils/path_utils.dart';

class _IsolateTask {
  final Function task;
  final dynamic params;
  final RootIsolateToken token;
  final SendPort replyPort;

  _IsolateTask({
    required this.task,
    required this.params,
    required this.token,
    required this.replyPort,
  });
}

class _IsolateError {
  final String error;
  final String stackTrace;
  _IsolateError(this.error, this.stackTrace);
}

Future<void> _isolateEntry(dynamic isolateTask) async {
  final _IsolateTask data = isolateTask as _IsolateTask;
  BackgroundIsolateBinaryMessenger.ensureInitialized(data.token);

  try {
    final result = await Function.apply(data.task, [data.params]);
    data.replyPort.send(result);
  } catch (e, stack) {
    data.replyPort.send(_IsolateError(e.toString(), stack.toString()));
  }
}

class IsolateManager {
  static final IsolateManager _instance = IsolateManager._internal();
  factory IsolateManager() => _instance;
  IsolateManager._internal();

  /// Runs a given [task] in a separate isolate with [params]
  Future<R> runInIsolate<P, R>(dynamic Function(P params) task, P params) async {
    final completer = Completer<R>();
    final receivePort = ReceivePort();

    final token = rootIsolateToken;
    if (token == null) throw StateError('IsolateManager cannot run without a valid RootIsolateToken.');

    final isolateTask = _IsolateTask(
      task: task,
      params: params,
      token: token,
      replyPort: receivePort.sendPort,
    );

    // Listen for the result from the isolate
    receivePort.listen((message) {
      if (message is _IsolateError)
        completer.completeError(message.error, StackTrace.fromString(message.stackTrace));
      else
        completer.complete(message as R);

      receivePort.close();
    });

    try {
      await Isolate.spawn(_isolateEntry, isolateTask as dynamic);
    } catch (e) {
      receivePort.close();
      completer.completeError(e);
    }

    return completer.future;
  }
}

/// Entry point for the isolate.
/// It performs heavy I/O tasks without blocking the main thread.
Future<Map<PathString, Metadata>> processFilesIsolate(List<PathString> payload) async {
  // The IsolateManager handles messenger initialization.

  final processedFileMetadata = <PathString, Metadata>{};

  await Future.wait(payload.map((filePath) async {
    try {
      final videoDataUtils = VideoDataUtils();

      // Fetch metadata and duration concurrently.
      final results = await Future.wait([
        videoDataUtils.getFileMetadataMap(filePath: filePath.path),
        videoDataUtils.getFileDuration(videoPath: filePath.path),
      ]);

      final res = results[0] as Map<String, dynamic>;
      final metadata = Metadata.fromJson(res);
      final durationMs = results[1] as double?;

      final duration = Duration(milliseconds: (durationMs ?? 0).toInt());

      // Store the result.
      processedFileMetadata[filePath] = metadata.copyWith(duration: duration);
    } catch (e, stack) {
      logErr('Error processing file in isolate: ${filePath.path}', e, stack);
      // Don't rethrow, just log, so one bad file doesn't stop the whole scan.
    }
  }));

  return processedFileMetadata;
}
