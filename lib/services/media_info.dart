import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail_exporter/video_thumbnail_exporter.dart';

import '../utils/logging.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class MediaInfo {
  // Get video duration in milliseconds
  static Future<int?> getVideoDuration(String path) async {
    try {
      // This is a simplified version; in a real implementation you would use
      // a media info library like ffprobe through process.run() or a plugin
      // For this implementation, we'll return a placeholder value

      // TODO: Implement proper duration extraction
      await Future.delayed(const Duration(milliseconds: 100));

      // Return fake duration for testing (2 hours)
      return 7200000;
    } catch (e) {
      logErr('Error getting video duration', e);
      return null;
    }
  }

  /// Extract a thumbnail from a video file
  static Future<String?> extractThumbnail(String videoPath, {String? outputPath}) async {
    try {
      if (!await File(videoPath).exists()) {
        logErr('Video file does not exist: $videoPath');
        return null;
      }

      final String thumbnailPath = outputPath ?? await _generateThumbnailPath(videoPath);

      final bool success = await VideoThumbnailExporter.getThumbnail(
        videoPath: videoPath,
        outputPath: thumbnailPath,
        size: 512, // TODO make configurable
      );

      if (!success) {
        logErr('Failed to generate thumbnail for $videoPath');
        return null;
      }

      if (!await File(thumbnailPath).exists()) {
        logErr('Thumbnail file was not created at $thumbnailPath');
        return null;
      }

      return thumbnailPath;
    } catch (e, stackTrace) {
      logErr('Error extracting thumbnail from $videoPath', e, stackTrace);
      return null;
    }
  }

  static Future<String> _generateThumbnailPath(String videoPath) async {
    final tempDir = await getTemporaryDirectory();
    final String filename = path.basenameWithoutExtension(videoPath);

    final String pathHash = path.dirname(videoPath).hashCode.toString().replaceAll('-', '_');
    final String thumbnailPath = path.join(
      tempDir.path,
      'miruryoiki_thumbnails',
      '${pathHash}_$filename.png',
    );

    final directory = Directory(path.dirname(thumbnailPath));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return thumbnailPath;
  }
}
