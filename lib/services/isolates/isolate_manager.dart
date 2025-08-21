import 'dart:async';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:video_data_utils/video_data_utils.dart';
import '../../main.dart' show rootIsolateToken;
import '../../models/metadata.dart';
import '../../models/series.dart';
import '../../enums.dart';
import '../../models/anilist/anime.dart';
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

class SortSeriesParams {
  final List<Map<String, dynamic>> serializedSeries;
  final int sortOrderIndex;
  final bool sortDescending;
  final Map<int, Map<String, dynamic>> sortData;
  final Map<int, double> progressData; // Pre-calculated progress percentages
  final SendPort replyPort;

  SortSeriesParams({
    required this.serializedSeries,
    required this.sortOrderIndex,
    required this.sortDescending,
    required this.sortData,
    required this.progressData,
    required this.replyPort,
  });
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

class _IsolateStarted {
  const _IsolateStarted();
}

Future<void> _isolateEntry(dynamic isolateTask) async {
  final _IsolateTask data = isolateTask as _IsolateTask;
  BackgroundIsolateBinaryMessenger.ensureInitialized(data.token);

  try {
    // Send a signal that the task is starting
    if (data.params is ProcessFilesParams) {
      data.params.replyPort.send(const _IsolateStarted());
    } else if (data.params is SortSeriesParams) {
      data.params.replyPort.send(const _IsolateStarted());
    }
    // The task is now responsible for sending its own completion message.
    await Function.apply(data.task, [data.params]);
  } catch (e, stack) {
    // If the whole task fails, send an error message.
    if (data.params is ProcessFilesParams) {
      data.params.replyPort.send(_IsolateError(e.toString(), stack.toString()));
    } else if (data.params is SortSeriesParams) {
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
    void Function()? onStart,
    void Function(int processed, int total)? onProgress,
  }) async {
    final completer = Completer<R>();
    final receivePort = ReceivePort();

    final token = rootIsolateToken;
    if (token == null) throw StateError('IsolateManager cannot run without a valid RootIsolateToken.');

    // Special handling for ProcessFilesParams and SortSeriesParams to inject the correct SendPort
    P actualParams = params;
    if (params is ProcessFilesParams) {
      actualParams = ProcessFilesParams(params.files, receivePort.sendPort) as P;
    } else if (params is SortSeriesParams) {
      actualParams = SortSeriesParams(
        serializedSeries: params.serializedSeries,
        sortOrderIndex: params.sortOrderIndex,
        sortDescending: params.sortDescending,
        sortData: params.sortData,
        progressData: params.progressData,
        replyPort: receivePort.sendPort,
      ) as P;
    }

    // We pass the receivePort's sendPort to the task itself.
    final isolateTask = _IsolateTask(
      task: task,
      params: actualParams,
      token: token,
    );

    receivePort.listen((message) {
      if (message is _IsolateStarted) {
        if (onStart != null) onStart();
      } else if (message is _IsolateProgressUpdate) {
        onProgress?.call(message.processed, message.total);
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
      // final int divisions = (totalFiles ~/ 10).clamp(1, totalFiles);

      // Send a progress update after each file.
      if (processedCount % 5 == 0 || processedCount == totalFiles) {
        // Send progress update every 5 files or on completion
        params.replyPort.send(_IsolateProgressUpdate(processedCount, totalFiles));
      }
    }
  }

  // Send the final result when all files are processed.
  params.replyPort.send(processedFileMetadata);
}

/// Isolate task that sorts series and sends progress updates.
Future<void> sortSeriesIsolate(SortSeriesParams params) async {
  final sortOrder = SortOrder.values[params.sortOrderIndex];
  
  // Convert serialized series back to Series objects
  final series = params.serializedSeries.map((json) => Series.fromJson(json)).toList();
  
  final List<Series> seriesCopy = List.from(series);

  Comparator<Series> comparator;

  switch (sortOrder) {
    // Alphabetical order by title
    case SortOrder.alphabetical:
      comparator = (a, b) => a.name.compareTo(b.name);

    // Median score from Anilist
    case SortOrder.score:
      comparator = (a, b) {
        final aScore = a.meanScore ?? 0;
        final bScore = b.meanScore ?? 0;
        return aScore.compareTo(bScore);
      };

    // Progress percentage from pre-calculated data
    case SortOrder.progress:
      comparator = (a, b) {
        final aProgress = params.progressData[a.hashCode] ?? 0.0;
        final bProgress = params.progressData[b.hashCode] ?? 0.0;
        return aProgress.compareTo(bProgress);
      };

    // Date the List Entry was last modified
    case SortOrder.lastModified:
      comparator = (a, b) {
        final aUpdated = a.currentAnilistData?.updatedAt ?? 0;
        final bUpdated = b.currentAnilistData?.updatedAt ?? 0;
        return aUpdated.compareTo(bUpdated);
      };

    // Date the user added the series to their list
    case SortOrder.dateAdded:
      comparator = (a, b) {
        final aCreated = params.sortData[a.hashCode]?['createdAt'] ?? 0;
        final bCreated = params.sortData[b.hashCode]?['createdAt'] ?? 0;
        return aCreated.compareTo(bCreated);
      };

    // Date the user started watching the series
    case SortOrder.startDate:
      comparator = (a, b) {
        final aStarted = params.sortData[a.hashCode]?['startedAt'];
        final bStarted = params.sortData[b.hashCode]?['startedAt'];

        final aDate = aStarted != null ? DateValue.fromJson(aStarted).toDateTime() : null;
        final bDate = bStarted != null ? DateValue.fromJson(bStarted).toDateTime() : null;

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return aDate.compareTo(bDate);
      };

    // Date the user completed watching the series
    case SortOrder.completedDate:
      comparator = (a, b) {
        final aCompleted = params.sortData[a.hashCode]?['completedAt'];
        final bCompleted = params.sortData[b.hashCode]?['completedAt'];

        final aDate = aCompleted != null ? DateValue.fromJson(aCompleted).toDateTime() : null;
        final bDate = bCompleted != null ? DateValue.fromJson(bCompleted).toDateTime() : null;

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return aDate.compareTo(bDate);
      };

    // Average score from Anilist
    case SortOrder.averageScore:
      comparator = (a, b) {
        final aScore = a.currentAnilistData?.averageScore ?? 0;
        final bScore = b.currentAnilistData?.averageScore ?? 0;
        return aScore.compareTo(bScore);
      };

    // Release date from Anilist
    case SortOrder.releaseDate:
      comparator = (a, b) {
        final aDate = a.currentAnilistData?.startDate?.toDateTime();
        final bDate = b.currentAnilistData?.startDate?.toDateTime();

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return aDate.compareTo(bDate);
      };

    // Popularity from Anilist
    case SortOrder.popularity:
      comparator = (a, b) {
        final aPopularity = a.currentAnilistData?.popularity ?? 0;
        final bPopularity = b.currentAnilistData?.popularity ?? 0;
        return aPopularity.compareTo(bPopularity);
      };
  }

  // Apply the sorting direction
  if (params.sortDescending) {
    seriesCopy.sort((a, b) => comparator(b, a)); // Reverse the comparison
  } else {
    seriesCopy.sort(comparator);
  }

  // Send the final result
  params.replyPort.send(seriesCopy);
}
