import 'package:path/path.dart' as p;

class FileUtils {
  static const List<String> videoExtensions = ['.mkv', '.mp4', '.avi', '.mov', '.wmv', '.m4v', '.flv'];

  static const List<String> imageExtensions = ['.ico', '.png', '.jpg', '.jpeg', '.webp'];

  /// Check if a filename is a video file
  static bool isVideoFile(String path, [List<String>? videoExtensions]) => //
      (videoExtensions ?? FileUtils.videoExtensions).contains(p.extension(path).toLowerCase());
}
