import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PathUtils {
  /// Normalize file paths for consistent comparison
  static String normalizePath(String path) {
    return p.normalize(path).replaceAll('/', ps).replaceAll('\\', ps);
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

class PathString {
  String _path;

  PathString(this._path);

  set path(String newPath) => _path = PathUtils.normalizePath(newPath);
  String get path => PathUtils.normalizePath(_path);
  
  String get original => _path;
  String get fileName => PathUtils.getFileName(_path);
  String get fileExtension => PathUtils.getFileExtension(_path);

  Future<String> get getRelativeToMiruRyoikiSaveDirectory async {
    final saveDir = miruRyoiokiSaveDirectory;
    return PathUtils.relativePath(path, saveDir.path);
  }

  @override
  String toString() => path;
}

String get assets => "${(Platform.resolvedExecutable.split(ps)..removeLast()).join(ps)}${ps}data${ps}flutter_assets${ps}assets";
String get iconPath => '$assets${ps}system${ps}icon.ico';
String get iconPng => '$assets${ps}system${ps}icon.png';
String get ps => Platform.pathSeparator;

String? _miruRyoiokiSaveDirectoryPath;

/// Initializes and stores the MiruRyoiki save directory path.
/// Call this once at app startup (e.g., in main()).
Future<void> initializeMiruRyoiokiSaveDirectory() async {
  final appDataDir = await getApplicationSupportDirectory();
  final parentPath = appDataDir.path.split('com.lordlux').first;
  final miruRyoiokiDir = Directory('${parentPath}MiruRyoiki');
  if (!await miruRyoiokiDir.exists()) await miruRyoiokiDir.create(recursive: true);
  _miruRyoiokiSaveDirectoryPath = miruRyoiokiDir.path;
}

/// Returns the MiruRyoiki save directory path.
///
/// Throws if [initializeMiruRyoiokiSaveDirectory] has not been called.
Directory get miruRyoiokiSaveDirectory {
  if (_miruRyoiokiSaveDirectoryPath == null) //
    throw StateError('miruRyoiokiSaveDirectoryPath not initialized. Call initializeMiruRyoiokiSaveDirectory() first.');

  return Directory(_miruRyoiokiSaveDirectoryPath!);
}
