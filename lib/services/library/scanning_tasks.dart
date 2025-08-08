import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:md5_file_checksum/md5_file_checksum.dart';
import 'package:miruryoiki/utils/logging.dart';
import 'package:video_data_utils/video_data_utils.dart';
import '../../models/metadata.dart';
import '../../utils/path_utils.dart';
import '../file_system/media_info.dart';

/// Data payload sent to the isolate for processing.
class IsolateScanPayload {
  final Set<PathString> filesToProcess;
  final RootIsolateToken rootIsolateToken;

  IsolateScanPayload({required this.filesToProcess, required this.rootIsolateToken});
}

/// Result data returned from the isolate.
class IsolateScanResult {
  final Map<PathString, Metadata> processedFileMetadata;

  IsolateScanResult({required this.processedFileMetadata});
}

/// Entry point for the isolate.
/// It performs heavy I/O tasks without blocking the main thread.
Future<IsolateScanResult> processFilesIsolate(IsolateScanPayload payload) async {
  // Ensure the isolate has access to the root isolate token.
  BackgroundIsolateBinaryMessenger.ensureInitialized(payload.rootIsolateToken);

  // Prepare a map to hold processed file metadata.
  final processedFileMetadata = <PathString, Metadata>{};

  // Process all files in parallel for maximum efficiency.
  await Future.wait(payload.filesToProcess.map((filePath) async {
    try {
      final videoDataUtils = VideoDataUtils();

      // Fetch metadata and checksum concurrently.
      final results = await Future.wait([
        videoDataUtils.getFileMetadataMap(filePath: filePath.path),
        videoDataUtils.getFileDuration(videoPath: filePath.path),
        Md5FileChecksum.getFileChecksum(filePath: filePath.path),
      ]);

      final metadata = results[0] as Metadata?;
      final durationMs = results[1] as double?;
      final checksum = results[2] as String?;

      final duration = Duration(milliseconds: (durationMs ?? 0).toInt());

      if (metadata != null) {
        // Store the result with the newly calculated checksum.
        processedFileMetadata[filePath] = metadata.copyWith(checksum: checksum, duration: duration);
      } else {
        logWarn('No metadata found for file: ${filePath.path}');
      }
    } catch (e) {
      // Log error but don't stop the whole process.
      logErr('Error processing file in isolate: ${filePath.path}. Error: $e');
      rethrow;
    }
  }));

  return IsolateScanResult(processedFileMetadata: processedFileMetadata);
}
