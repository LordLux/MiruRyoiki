import 'dart:async';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:video_data_utils/video_data_utils.dart';
import '../../main.dart' show rootIsolateToken;
import '../../models/metadata.dart';
import '../../utils/logging.dart';
import '../../utils/path_utils.dart';

class _IsolateProgressUpdate {
  final int processed;
  final int total;
  _IsolateProgressUpdate(this.processed, this.total);
}

class ProcessFilesParams {
  final List<PathString> files;
  final SendPort replyPort;
  ProcessFilesParams(this.files, this.replyPort);
}

class _IsolateTask {
  final Function task;
  final dynamic params;
  final RootIsolateToken token;

  _IsolateTask({
    required this.task,
    required this.params,
    required this.token,
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
    // The task is now responsible for sending its own completion message.
    await Function.apply(data.task, [data.params]);
  } catch (e, stack) {
    // If the whole task fails, send an error message.
    if (data.params is ProcessFilesParams) {
      data.params.replyPort.send(_IsolateError(e.toString(), stack.toString()));
    }
  }
}

class IsolateManager {
  static final IsolateManager _instance = IsolateManager._internal();
  factory IsolateManager() => _instance;
  IsolateManager._internal();

  /// Runs a task in an isolate, providing progress updates and a final result.
  Future<R> runIsolateWithProgress<P, R>({
    required dynamic Function(P params) task,
    required P params,
    required void Function(int processed, int total) onProgress,
  }) async {
    final completer = Completer<R>();
    final receivePort = ReceivePort();

    final token = rootIsolateToken;
    if (token == null) throw StateError('IsolateManager cannot run without a valid RootIsolateToken.');

    // Special handling for ProcessFilesParams to inject the correct SendPort
    P actualParams = params;
    if (params is ProcessFilesParams) {
      actualParams = ProcessFilesParams(params.files, receivePort.sendPort) as P;
    }

    // We pass the receivePort's sendPort to the task itself.
    final isolateTask = _IsolateTask(
      task: task,
      params: actualParams,
      token: token,
    );

    receivePort.listen((message) {
      if (message is _IsolateProgressUpdate) {
        onProgress(message.processed, message.total);
      } else if (message is _IsolateError) {
        completer.completeError(message.error, StackTrace.fromString(message.stackTrace));
        receivePort.close();
      } else {
        // Any other message type is considered the final result.
        completer.complete(message as R);
        receivePort.close();
      }
    });

    try {
      await Isolate.spawn(_isolateEntry, isolateTask);
    } catch (e) {
      receivePort.close();
      completer.completeError(e);
    }

    return completer.future;
  }
}

/// Isolate task that processes files and sends progress updates.
Future<void> processFilesIsolate(ProcessFilesParams params) async {
  final processedFileMetadata = <PathString, Metadata>{};
  final totalFiles = params.files.length;
  int processedCount = 0;

  final videoDataUtils = VideoDataUtils();

  for (final filePath in params.files) {
    try {
      final results = await Future.wait([
        videoDataUtils.getFileMetadataMap(filePath: filePath.path),
        videoDataUtils.getFileDuration(videoPath: filePath.path),
      ]);

      final metadata = Metadata.fromJson(results[0] as Map<String, dynamic>);
      final duration = Duration(milliseconds: ((results[1] as double?) ?? 0).toInt());

      processedFileMetadata[filePath] = metadata.copyWith(duration: duration);
    } catch (e, stack) {
      logErr('Error processing file in isolate: ${filePath.path}', e, stack);
    } finally {
      processedCount++;
      // Send a progress update after each file.
      if (processedCount % 10 == 0 || processedCount == totalFiles) {
        // Send progress update every 10 files or on completion
        params.replyPort.send(_IsolateProgressUpdate(processedCount, totalFiles));
      }
    }
  }

  // Send the final result when all files are processed.
  params.replyPort.send(processedFileMetadata);
}
