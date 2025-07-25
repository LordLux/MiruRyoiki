// library_scanner.dart
import 'dart:io';
import 'dart:isolate';
import 'package:miruryoiki/models/series.dart';
import 'package:miruryoiki/utils/path_utils.dart';
import '../file_system/file_scanner.dart';

class LibraryScannerMessage {
  final String libraryPath;
  final SendPort replyPort;
  LibraryScannerMessage(this.libraryPath, this.replyPort);
}

class LibraryScannerProgress {
  final int processed;
  final int total;
  LibraryScannerProgress(this.processed, this.total);
}

class LibraryScannerResult {
  final List<Series> series;
  LibraryScannerResult(this.series);
}
