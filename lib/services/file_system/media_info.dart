import 'package:miruryoiki/models/metadata.dart';
import 'package:video_thumbnail_exporter/video_thumbnail_exporter.dart';

import '../../models/mkv_metadata.dart';
import '../../utils/logging.dart';
import 'dart:io';

import '../../utils/path_utils.dart';
import '../thumbnail_manager.dart';

class MediaInfo {
  // Get video duration in milliseconds
  static Future<MkvMetadata?> getMkvMetadata(PathString filepath) async {
    try {
      final MkvMetadata fileMetadata = MkvMetadata.fromJson(await VideoDataExtractor.getMkvMetadata(mkvPath: filepath.path));
      return fileMetadata;
    } catch (e) {
      logErr('Error getting MKV metadata', e);
      return null;
    }
  }

  static Future<Duration> getVideoDuration(PathString filepath) async {
    try {
      final double duration = await VideoDataExtractor.getVideoDuration(videoPath: filepath.path);
      return Duration(milliseconds: duration.toInt());
    } catch (e) {
      logErr('Error getting video duration', e);
      return Duration.zero;
    }
  }

  /// Get metadata for a video file
  static Future<Metadata?> getMetadata(PathString filepath) async {
    try {
      
      // Fetch base metadata and video duration in parallel for efficiency
      final results = await Future.wait([
        VideoDataExtractor.getFileMetadata(filePath: filepath.path),
        getVideoDuration(filepath),
      ]);

      final fileMetadata = results[0] as Map<String, dynamic>;
      final duration = results[1] as Duration;

      return Metadata.fromJson({
        ...fileMetadata,
        'duration': duration,
      });
    } catch (e) {
      logErr('Error getting video metadata', e);
      return null;
    }
  }

  /// Extract a thumbnail from a video file to a specified path.
  static Future<PathString?> extractThumbnail(PathString videoPath, {PathString? outputPath}) async {
    try {
      if (!await File(videoPath.path).exists()) {
        logErr('Video file does not exist: $videoPath');
        return null;
      }

      final PathString thumbnailPath = outputPath ?? await ThumbnailManager.generateThumbnailPath(videoPath);

      final bool success = await VideoDataExtractor.extractCachedThumbnail(
        videoPath: videoPath.path,
        outputPath: thumbnailPath.path,
        size: 256, // TODO make configurable
      );

      if (!success) {
        logErr('Failed to generate thumbnail for $videoPath');
        return null;
      }

      if (!await File(thumbnailPath.path).exists()) {
        logErr('Thumbnail file was not created at: $thumbnailPath');
        return null;
      }

      return thumbnailPath;
    } catch (e, stackTrace) {
      logErr('Error extracting thumbnail from $videoPath', e, stackTrace);
      return null;
    }
  }
}
