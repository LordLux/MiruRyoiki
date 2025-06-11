import '../enums.dart';

/// Represents metadata for a video file.
class Metadata {
  /// Size in bytes.
  final int size;
  
  /// Creation time of the file.
  late final DateTime creationTime;
  
  /// Last modified time of the file.
  late final DateTime lastModified;
  
  /// Last accessed time of the file.
  late final DateTime lastAccessed;

  Metadata({
    this.size = 0,
    creationTime,
    lastModified,
    lastAccessed,
  }) {
    this.creationTime = creationTime ?? DateTimeX.epoch;
    this.lastModified = lastModified ?? DateTimeX.epoch;
    this.lastAccessed = lastAccessed ?? DateTimeX.epoch;
  }

  factory Metadata.fromJson(Map<dynamic, dynamic> json) {
    return Metadata(
      size: json['size'] as int? ?? 0,
      creationTime: DateTime.tryParse(json['creationTime'] as String) ?? DateTimeX.epoch,
      lastModified: DateTime.tryParse(json['lastModified'] as String) ?? DateTimeX.epoch,
      lastAccessed: DateTime.tryParse(json['lastAccessed'] as String) ?? DateTimeX.epoch,
    );
  }
}

class VideoStream {
  final int trackNumber;
  final String codecId;
  final String codecName;
  final int width;
  final int height;
  final double frameRate;

  const VideoStream({
    this.trackNumber = 0,
    this.codecId = '',
    this.codecName = '',
    this.width = 0,
    this.height = 0,
    this.frameRate = 0.0,
  });

  factory VideoStream.fromJson(Map<dynamic, dynamic> json) {
    return VideoStream(
      trackNumber: json['trackNumber'] as int? ?? 0,
      codecId: json['codecId'] as String? ?? '',
      codecName: json['codecName'] as String? ?? '',
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
      frameRate: json['frameRate'] as double? ?? 0.0,
    );
  }

  String get resolution => '$width×$height';
  String get codec => '$codecName ($codecId)';
}

class AudioStream {
  final int trackNumber;
  final String codecId;
  final String codecName;
  final int channels;
  final double sampleRate;
  final int bitDepth;

  const AudioStream({
    this.trackNumber = 0,
    this.codecId = '',
    this.codecName = '',
    this.channels = 0,
    this.sampleRate = 0.0,
    this.bitDepth = 0,
  });

  factory AudioStream.fromJson(Map<dynamic, dynamic> json) {
    return AudioStream(
      trackNumber: json['trackNumber'] as int? ?? 0,
      codecId: json['codecId'] as String? ?? '',
      codecName: json['codecName'] as String? ?? '',
      channels: json['channels'] as int? ?? 0,
      sampleRate: json['sampleRate'] as double? ?? 0.0,
      bitDepth: json['bitDepth'] as int? ?? 0,
    );
  }

  String get codec => '$codecName ($codecId)';
  String get sampleRateFormatted => '${sampleRate.round()} Hz';
  String get bitDepthFormatted => '$bitDepth bit';
}

class Attachment {
  final int index;
  final String fileName;
  final String mimeType;
  final String description;
  final int size;

  const Attachment({
    this.index = 0,
    this.fileName = '',
    this.mimeType = '',
    this.description = '',
    this.size = 0,
  });

  factory Attachment.fromJson(Map<dynamic, dynamic> json) {
    return Attachment(
      index: json['index'] as int? ?? 0,
      fileName: json['fileName'] as String? ?? '',
      mimeType: json['mimeType'] as String? ?? '',
      description: json['description'] as String? ?? '',
      size: json['size'] as int? ?? 0,
    );
  }

  String get sizeFormatted => '${(size / 1024).round()} KB';
}
