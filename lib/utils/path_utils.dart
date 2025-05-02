import 'dart:io';
import 'package:path/path.dart' as p;

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
}