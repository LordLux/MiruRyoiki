import 'dart:io';
import 'dart:math' show min;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'logging.dart';

class PathUtils {
  /// Normalize file paths for consistent comparison
  static String? normalizePath(String? path) {
    if (path == null || path.isEmpty) return null;

    // Normalize path separators
    path = p.normalize(path).replaceAll('/', ps).replaceAll('\\', ps);

    // Windows long path support
    if (path.length > 260 && !path.startsWith('\\\\?\\')) //
      path = r'\\?\' + path;

    return path;
  }

  /// Get relative path from a base directory
  static String? relativePath(String? path, String from) {
    if (path == null || path.isEmpty) return null;
    return p.relative(path, from: from);
  }

  static String? getFileName(String? path) {
    if (path == null || path.isEmpty) return null;
    return p.basename(path);
  }

  static String? getFileExtension(String? path) {
    if (path == null || path.isEmpty) return null;
    return p.extension(path);
  }
}

class PathString {
  String? _path;

  PathString(this._path);

  set path(String? newPath) => _path = PathUtils.normalizePath(newPath);
  String get path => PathUtils.normalizePath(_path)!;
  String? get pathMaybe => PathUtils.normalizePath(_path);

  String? get original => _path;
  String? get name => PathUtils.getFileName(_path);
  String? get ext => PathUtils.getFileExtension(_path);

  /// Returns the asset path if this path is within the assets directory, otherwise null.
  /// For example, if the path is "C:/Programs/MiruRyioiki/flutter_assets/assets/icons/anilist/logo.si",
  /// this returns "assets/icons/anilist/logo.si".
  String? get asset {
    if (pathMaybe == null || pathMaybe!.isEmpty) return null;

    final parts = path.split(ps);
    final assetsIndex = parts.indexOf('assets');
    if (assetsIndex == -1) return null;

    return parts.sublist(assetsIndex).join('/');
  }

  Directory? get directory {
    if (_path == null || _path!.isEmpty) return null;
    return Directory(_path!);
  }

  Directory? get parentFolder {
    if (_path == null || _path!.isEmpty) return null;
    return Directory(_path!).parent;
  }

  String? get getRelativeToMiruRyoikiSaveDirectory {
    final saveDir = miruRyoikiSaveDirectory;
    return PathUtils.relativePath(path, saveDir.path);
  }
  
  static bool valid(PathString? thisPath) => thisPath != null && thisPath.pathMaybe != null && thisPath.pathMaybe!.isNotEmpty;

  @override
  String toString() => "$pathMaybe";

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PathString) return false;
    return pathMaybe == other.pathMaybe;
  }

  @override
  int get hashCode => path.hashCode;

  /// JSON serialization/deserialization
  /// Accepts String or Map&lt;String, dynamic&gt; for deserialization
  static PathString? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) return PathString(json);
    if (json is Map<String, dynamic>) return PathString(json['path'] as String?);
    throw FormatException('Expected String or Map<String, dynamic>, got ${json.runtimeType}');
  }

  factory PathString.fromFile(File file) => PathString(file.path);
  factory PathString.fromDirectory(Directory dir) => PathString(dir.path);
  Map<String, dynamic> toJson() => {'path': path};

  Map<String, dynamic> toMap() => toJson();
  factory PathString.fromMap(Map<String, dynamic> map) => fromJson(map)!;
}

String get assets => "${(Platform.resolvedExecutable.split(ps)..removeLast()).join(ps)}${ps}data${ps}flutter_assets${ps}assets";
String get iconPath => '$assets${ps}system${ps}icon.ico';
String get iconPng => '$assets${ps}system${ps}icon.png';
String get ps => Platform.pathSeparator;

String? _miruRyoiokiSaveDirectoryPath;

/// Initializes and stores the MiruRyoiki save directory path.
/// Call this once at app startup (e.g., in main()).
Future<void> initializeMiruRyoikiSaveDirectory() async {
  if (_miruRyoiokiSaveDirectoryPath != null) return; // Already initialized
  final appDataDir = await getApplicationSupportDirectory();
  final parentPath = appDataDir.path.split('com.lordlux').first;
  final name = kDebugMode ? 'MiruRyoikiDev' : 'MiruRyoiki'; // Separate folder for dev builds
  final miruRyoiokiDir = Directory('$parentPath$name');
  if (!await miruRyoiokiDir.exists()) await miruRyoiokiDir.create(recursive: true);
  _miruRyoiokiSaveDirectoryPath = miruRyoiokiDir.path;
}

/// Returns the MiruRyoiki save directory path.
///
/// Throws if [initializeMiruRyoikiSaveDirectory] has not been called.
Directory get miruRyoikiSaveDirectory {
  if (_miruRyoiokiSaveDirectoryPath != null) return Directory(_miruRyoiokiSaveDirectoryPath!);

  // For debug builds, return a fixed path to avoid initialization issues
  if (kDebugMode) {
    logErr('miruRyoiokiSaveDirectoryPath not initialized, returning default debug path');
    return Directory(r'C:\Users\LordLux\AppData\Roaming\MiruRyoikiDev');
  }

  // In release builds, throw if not initialized
  throw StateError('miruRyoiokiSaveDirectoryPath not initialized. initializeMiruRyoiokiSaveDirectory() has to be called first.');
}

String substringSafe(String text, int start, [int? end, String wrap = '']) => //
    wrap + text.substring(min(start, text.length - 1), end != null ? min(end, text.length) : text.length) + wrap;
