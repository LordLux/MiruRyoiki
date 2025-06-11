import 'package:video_thumbnail_exporter/video_thumbnail_exporter.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:flutter_file_info/flutter_file_info.dart';

import '../../utils/logging.dart';
import 'dart:io';

import '../../utils/path_utils.dart';
import '../thumbnail_manager.dart';

class MediaInfo {
  // Get video duration in milliseconds
  static Future<FileMetadata?> _getMetadata(PathString filepath) async {
    try {
      FileMetadata? fileMetadata = await FileInfo.instance.getFileInfo(filepath.path);
      return fileMetadata!;
    } catch (e) {
      logErr('Error getting video duration', e);
      return null;
    }
  }

  static Future<dynamic> _get(PathString filepath, [String attribute = ""]) async {
    final FileMetadata? metadata = await _getMetadata(filepath);
    return switch (attribute) {
      'accessedTime' => metadata?.accessedTime,
      'creationTime' => metadata?.creationTime,
      'fileSize' => metadata?.fileSize,
      'modifiedTime' => metadata?.modifiedTime,
      _ => metadata,
    };
  }

  static Future<DateTime?> getVideoLastAccess(PathString filepath) async => //
      await _get(filepath, 'accessedTime');

  static Future<DateTime?> getVideoCreationTime(PathString filepath) async => //
      await _get(filepath, 'creationTime');

  static Future<int?> getVideoFileSize(PathString filepath) async => //
      await _get(filepath, 'fileSize');
      
  static Future<DateTime?> getVideoLastModified(PathString filepath) async => //
      await _get(filepath, 'modifiedTime');

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
