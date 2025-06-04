import 'package:video_thumbnail_exporter/video_thumbnail_exporter.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

import 'dart:typed_data';
import '../../utils/logging.dart';
import 'dart:io';

import '../thumbnail_manager.dart';

class MediaInfo {
  // Get video duration in milliseconds
  static Future<int?> getVideoDuration(String path) async {
    try {
      final metadata = await getVideoMetadata(path);
    } catch (e) {
      logErr('Error getting video duration', e);
      return null;
    }
  }

  static Future<Metadata?> getVideoMetadata(String videoPath) async {
    try {
      if (!await File(videoPath).exists()) {
        logWarn('Video file does not exist: $videoPath');
        return null;
      }

      final Metadata metadata = await MetadataRetriever.fromFile(File(videoPath));
      return metadata;
    } catch (e, stackTrace) {
      logErr('Error retrieving metadata for $videoPath', e, stackTrace);
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

      final String thumbnailPath = outputPath ?? await ThumbnailManager.generateThumbnailPath(videoPath);

      final bool success = await VideoThumbnailExporter.getThumbnail(
        videoPath: videoPath,
        outputPath: thumbnailPath,
        size: 256, // TODO make configurable
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
}
