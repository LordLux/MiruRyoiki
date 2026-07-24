import 'dart:io';
import 'dart:math' show min;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'logging.dart';

class PathUtils {
  static final int MaxShortPathLength = 260; // Windows max path length, excluding null terminator
  static final String LongPathPrefix = r'\\?\'; // Windows long path prefix
  
  /// Normalize file paths for consistent comparison
  static String? normalizePath(String? path) {
    if (path == null || path.isEmpty) return null;

    // Normalize path separators
    path = p.normalize(path).replaceAll('/', ps).replaceAll('\\', ps);

    // Windows long path support
    if (path.length > MaxShortPathLength && !path.startsWith(LongPathPrefix)) //
      path = LongPathPrefix + path;

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

  static String? removeDriveLetter(String? path) {
    if (path == null || path.isEmpty) return null;
    if (Platform.isWindows && path.length > 2 && path[1] == ':') {
      return path.substring(2);
    }
    return path;
  }
}

class PathString {
  String? _path;

  PathString(this._path);

  set path(String? newPath) => _path = PathUtils.normalizePath(newPath);
  String get path => PathUtils.normalizePath(_path)!;
  String? get pathMaybe => PathUtils.normalizePath(_path);

  String? get original => _path;
  String? get fileName => PathUtils.getFileName(_path);
  String? get ext => PathUtils.getFileExtension(_path);

  /// Returns the asset path if this path is within the assets directory, otherwise null
  ///
  /// For example, if the path is "C:/Programs/MiruRyioiki/flutter_assets/assets/icons/anilist/logo.si", this returns "assets/icons/anilist/logo.si"
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

  String get linux => path.replaceAll('\\', '/');
  String get windows => path.replaceAll('/', '\\');

  /// **Forbidden printable ASCII characters**
  ///
  /// - `<` (less than)
  /// - `>` (greater than)
  /// - `:` (colon - sometimes works, but is actually NTFS Alternate Data Streams)
  /// - `"` (double quote)
  /// - `/` (forward slash)
  /// - `\` (backslash)
  /// - `|` (vertical bar or pipe)
  /// - `?` (question mark)
  /// - `*` (asterisk)

  /// **Non-printable characters**
  ///
  /// If your data comes from a source that would permit non-printable characters then there is more to check for
  ///
  /// - `0`-`31` (ASCII control characters)

  /// **Reserved file names**
  ///
  /// The following filenames are reserved:
  /// - `CON`, `PRN`, `AUX`, `NUL`
  ///
  /// - `COM1`, `COM2`, `COM3`, `COM4`, `COM5`, `COM6`, `COM7`, `COM8`, `COM9`
  ///
  /// - `LPT1`, `LPT2`, `LPT3`, `LPT4`, `LPT5`, `LPT6`, `LPT7`, `LPT8`, `LPT9`
  ///
  /// (both on their own and with arbitrary file extensions, e.g. LPT1.txt)

  /// **Other rules**
  /// - Filenames cannot end in a space or dot

  /// Windows-forbidden + control characters — sanitizers replace these (e.g. with '-')
  static String forbiddenWindowsCharsPattern = r'[<>:"/\\|?*\x00-\x1F]';

  /// Reserved device names and trailing dots/spaces — sanitizers strip these
  static String reservedWindowsNameOrTrailingPattern = r'^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\..*)?$|[. ]+$';

  static String unallowedWindowsCharactersPattern = '$forbiddenWindowsCharsPattern|$reservedWindowsNameOrTrailingPattern';
  
  static FilteringTextInputFormatter get pathInputFormatter {
    if (Platform.isWindows) return FilteringTextInputFormatter.deny(RegExp(PathString.unallowedWindowsCharactersPattern, caseSensitive: false));
    return FilteringTextInputFormatter.deny(RegExp(r'[<>:"/\\|?*]'));
  }
}

String get assets => "${(Platform.resolvedExecutable.split(ps)..removeLast()).join(ps)}${ps}data${ps}flutter_assets${ps}assets";
String get ps => Platform.pathSeparator;

String iconPathSize(String size) => '$assets${ps}system${ps}icon$size.ico';
String get iconPath => iconPathSize('');
String get iconPath32 => iconPathSize('32');
String get iconPath48 => iconPathSize('48');
String get iconPath64 => iconPathSize('64');
String get iconPath156 => iconPathSize('156');

String iconPngSize(String size) => '$assets${ps}system${ps}icon$size.png';
String get iconPng => iconPngSize('');

String? _miruRyoiokiSaveDirectoryPath;

/// Initializes and stores the MiruRyoiki save directory path
///
/// Call this once at app startup (e.g., in main())
Future<void> initializeMiruRyoikiSaveDirectory() async {
  if (_miruRyoiokiSaveDirectoryPath != null) return; // Already initialized
  final appDataDir = await getApplicationSupportDirectory();
  final parentPath = appDataDir.path.split('com.lordlux').first;
  final name = kDebugMode ? 'MiruRyoikiDev' : 'MiruRyoiki'; // Separate folder for dev builds
  final miruRyoiokiDir = Directory('$parentPath$name');
  if (!await miruRyoiokiDir.exists()) await miruRyoiokiDir.create(recursive: true);
  _miruRyoiokiSaveDirectoryPath = miruRyoiokiDir.path;
}

/// Returns the MiruRyoiki save directory path
///
/// Throws if [initializeMiruRyoikiSaveDirectory] has not been called
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
