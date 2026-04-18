import 'dart:async';
import 'dart:isolate';
import 'dart:io';
import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'package:miruryoiki/models/anilist/mapping.dart';
import '../library/video_metadata_service.dart';
import '../di/dependency_injection.dart';
import '../../main.dart' show rootIsolateToken;
import '../../models/metadata.dart';
import '../../utils/color.dart';
import '../../utils/logging.dart';
import '../../utils/path.dart';
import '../../utils/image_color_extractor.dart';

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

class CalculateDominantColorsParams {
  final List<Map<String, dynamic>> serializedMappings;
  final bool forceRecalculate;
  final SendPort replyPort;

  CalculateDominantColorsParams({
    required this.serializedMappings,
    required this.forceRecalculate,
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
  try {
    if (ServiceLocator.requireBackgroundIsolateBinaryMessenger) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(data.token);
    }

    // Send a signal that the task is starting
    if (data.params is ProcessFilesParams) {
      data.params.replyPort.send(const _IsolateStarted());
    } else if (data.params is CalculateDominantColorsParams) {
      data.params.replyPort.send(const _IsolateStarted());
    }
    // The task is now responsible for sending its own completion message.
    await Function.apply(data.task, [data.params]);
  } catch (e, stack) {
    // If the whole task fails, send an error message.
    if (data.params is ProcessFilesParams) {
      data.params.replyPort.send(_IsolateError(e.toString(), stack.toString()));
    } else if (data.params is CalculateDominantColorsParams) {
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

    // Special handling for ProcessFilesParams and CalculateDominantColorsParams to inject the correct SendPort
    P actualParams = params;
    if (params is ProcessFilesParams) {
      actualParams = ProcessFilesParams(params.files, receivePort.sendPort) as P;
    } else if (params is CalculateDominantColorsParams) {
      actualParams = CalculateDominantColorsParams(
        serializedMappings: params.serializedMappings,
        forceRecalculate: params.forceRecalculate,
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
        if (actualParams is CalculateDominantColorsParams) {
          final processedIndex = message.processed - 4;
          if (processedIndex >= 0 && processedIndex < actualParams.serializedMappings.length) {
            final mappingTitle = actualParams.serializedMappings[processedIndex]['title'] ?? 'Unknown';
            // print(actualParams.serializedMappings);
            // print("${actualParams.serializedMappings[processedIndex]['posterColor']}  ${actualParams.serializedMappings[processedIndex]['posterColor'].runtimeType}");
            final String posterColor = (actualParams.serializedMappings[processedIndex]['posterColor'] ?? "#000000").replaceAll('#', '');
            final String bannerColor = (actualParams.serializedMappings[processedIndex]['bannerColor'] ?? "#000000").replaceAll('#', '');
            final finalPosterColor = Color(int.parse('0xFF${posterColor.substring(posterColor.length - 6, posterColor.length)}'));
            final finalBannerColor = Color(int.parse('0xFF${bannerColor.substring(bannerColor.length - 6, bannerColor.length)}'));

            logMulti([
              ['Processed: $mappingTitle, Dominant Colors: '],
              ['Pos #$posterColor ‎', getTextColor(finalPosterColor), finalPosterColor],
              ['Ban #$bannerColor ‎', getTextColor(finalBannerColor), finalBannerColor],
            ]);
          }
        }
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
      if (!ServiceLocator.spawnIsolates) {
        await _isolateEntry(isolateTask);
      } else {
        await Isolate.spawn(_isolateEntry, isolateTask);
      }
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

  final videoMetadataService = VideoMetadataService();

  for (final filePath in params.files) {
    try {
      final metadata = await videoMetadataService.extractMetadata(filePath);
      processedFileMetadata[filePath] = metadata;
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

/// Isolate task that calculates dominant colors and sends progress updates.
Future<void> calculateDominantColorsIsolate(CalculateDominantColorsParams params) async {
  try {
    if (ServiceLocator.initializeWidgetsBindingInIsolates) WidgetsFlutterBinding.ensureInitialized();

    logDebug('   WidgetsBinding not initialized, initializing...');
  } catch (e) {
    // If we're in an isolate or WidgetsBinding is not available, skip this check
    logTrace('   WidgetsBinding not available (possibly in isolate), continuing...');
  }
  final results = <int, Map<String, dynamic>>{};
  final totalMappings = params.serializedMappings.length;
  int processedCount = 0;

  for (final serializedMapping in params.serializedMappings) {
    try {
      // Check if we need to process this series before deserializing
      final hasPosterDominantColor = serializedMapping['posterColor'] != null;
      final hasBannerDominantColor = serializedMapping['bannerColor'] != null;
      if (/*!params.forceRecalculate &&*/ (hasPosterDominantColor && hasBannerDominantColor)) {
        processedCount++;
        continue;
      }

      // Deserialize the series
      final mapping = AnilistMapping.fromJson(serializedMapping);

      // Calculate the dominant color using the isolate version
      final (colorResults, (success, errorMessage)) = await _calculateMappingDominantColorsInIsolate(mapping);

      if (!success) {
        results[mapping.anilistId] = {
          'error': 'Failed to extract color for ${mapping.title}: $errorMessage',
          'changed': false,
        };
        continue;
      }

      if (colorResults != null) {
        final (posterResult, bannerResult) = colorResults;
        final resultMap = <String, dynamic>{'changed': true};

        if (posterResult != null) resultMap['posterColor'] = posterResult.value;
        if (bannerResult != null) resultMap['bannerColor'] = bannerResult.value;

        // Only add if we have actual color data
        if (resultMap.length > 1) {
          results[mapping.anilistId] = resultMap;
        }
      }
    } catch (e, st) {
      // Log error but continue processing other series - include stack trace for debugging
      final seriesName = serializedMapping['title'] ?? 'Unknown';
      results[serializedMapping['anilistId'] as int] = {
        'error': 'Error processing $seriesName: $e\nStack: ${st.toString().split('\n').take(3).join('\n')}',
        'changed': false,
      };
    } finally {
      processedCount++;

      // Send progress update every few series or on completion
      if (processedCount % 3 == 0 || processedCount == totalMappings) {
        params.replyPort.send(_IsolateProgressUpdate(processedCount, totalMappings));
      }
    }
  }

  // Send the final result
  params.replyPort.send(results);
}


/// Helper function to calculate dominant color in isolate
Future<((Color?, Color?)?, (bool, String?))> _calculateMappingDominantColorsInIsolate(AnilistMapping mapping) async {
  String? posterPath;
  // Try to get the cached AniList image path
  if (mapping.anilistData?.posterImage != null) {
    posterPath = mapping.anilistData!.posterImage!;
  }

  String? bannerPath;
  // Banner source - same logic
  if (mapping.anilistData?.bannerImage != null) {
    // Try to get the cached AniList image path
    bannerPath = mapping.anilistData!.bannerImage!;
  }

  if (bannerPath == null && posterPath == null) return (null, (false, 'No AniList poster URL available'));

  PathString? posterCachedPath = await _getCachedAnilistImagePath(posterPath);
  PathString? bannerCachedPath = await _getCachedAnilistImagePath(bannerPath);

  if ((!PathString.valid(posterCachedPath)) && (!PathString.valid(bannerCachedPath))) return (null, (false, 'No image source available'));

  // Extract color from the image file
  try {
    final File posterFile;
    final File bannerFile;
    Color? extractedPosterColor;
    Color? extractedBannerColor;

    // Poster
    if (PathString.valid(posterCachedPath)) {
      posterFile = File(posterCachedPath!.path);
      if (!await posterFile.exists()) return (null, (false, 'Cached poster image file does not exist'));
      extractedPosterColor = await ImageColorExtractor.extractDominantColor(posterCachedPath.path, preferBackground: false);
    }

    // Banner
    if (PathString.valid(bannerCachedPath)) {
      bannerFile = File(bannerCachedPath!.path);
      if (!await bannerFile.exists()) return (null, (false, 'Cached banner image file does not exist'));
      extractedBannerColor = await ImageColorExtractor.extractDominantColor(bannerCachedPath.path, preferBackground: false);
    }

    return ((extractedPosterColor, extractedBannerColor), (true, null));
  } catch (e) {
    return (null, (false, 'Error extracting color: $e'));
  }
}

/// Helper to get cached AniList image path in isolate (simplified version)
Future<PathString?> _getCachedAnilistImagePath(String? url) async {
  if (url == null) return null;
  await initializeMiruRyoikiSaveDirectory();

  try {
    // Recreate the same caching logic used by ImageCacheService
    // Generate filename from URL using MD5 hash (matching the cache service logic)
    final bytes = utf8.encode(url);
    final digest = md5.convert(bytes);
    final extension = url.split('.').last.split('?').first;
    final filename = '${digest.toString()}.$extension';

    // Get the cache directory path (matching the cache service path)
    final dir = miruRyoikiSaveDirectory;
    final cacheDir = Directory('${dir.path}/image_cache');
    final cachedFile = File('${cacheDir.path}/$filename');

    if (await cachedFile.exists()) {
      return PathString(cachedFile.path);
    }

    return null;
  } catch (e) {
    return null;
  }
}
