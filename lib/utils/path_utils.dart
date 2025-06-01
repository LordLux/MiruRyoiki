import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PathUtils {
  /// Normalize file paths for consistent comparison
  static String normalizePath(String path) {
    return p.normalize(path).replaceAll('/', '\\');
  }

  /// Get relative path from a base directory
  static String relativePath(String path, String from) {
    return p.relative(path, from: from);
  }

  /// Check if a file exists
  static Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  /// Check if a directory exists
  static Future<bool> directoryExists(String path) async {
    return await Directory(path).exists();
  }

  static String getFileName(String path) {
    return p.basename(path);
  }

  static String getFileExtension(String path) {
    return p.extension(path);
  }
}

String get assets => "${(Platform.resolvedExecutable.split(ps)..removeLast()).join(ps)}${ps}data${ps}flutter_assets${ps}assets";
String get iconPath => '$assets${ps}system${ps}icon.ico';
String get iconPng => '$assets${ps}system${ps}icon.png';
String get ps => Platform.pathSeparator;

Future<Directory> get miruRyoiokiSaveDirectory async {
  final appDataDir = await getApplicationSupportDirectory();
  final parentPath = appDataDir.path.split('com.lordlux').first;
  final miruRyoiokiDir = Directory('${parentPath}MiruRyoiki');
  if (!await miruRyoiokiDir.exists()) await miruRyoiokiDir.create(recursive: true);
  return miruRyoiokiDir;
}
