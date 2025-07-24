class MkvMetadata {
  final String title;
  final double duration;
  final int bitrate;
  final String muxingApp;
  final String writingApp;
  final List<VideoStream> videoStreams;
  final List<AudioStream> audioStreams;
  final List<Attachment> attachments;

  const MkvMetadata({
    this.title = '',
    this.duration = 0.0,
    this.bitrate = 0,
    this.muxingApp = '',
    this.writingApp = '',
    this.videoStreams = const [],
    this.audioStreams = const [],
    this.attachments = const [],
  });

  factory MkvMetadata.fromJson(Map<dynamic, dynamic> json) {
    return MkvMetadata(
      title: json['title'] as String? ?? '',
      duration: json['duration'] as double? ?? 0.0,
      bitrate: json['bitrate'] as int? ?? 0,
      muxingApp: json['muxingApp'] as String? ?? '',
      writingApp: json['writingApp'] as String? ?? '',
      videoStreams: (json['videoStreams'] as List?)?.map((stream) => VideoStream.fromJson(stream)).toList() ?? [],
      audioStreams: (json['audioStreams'] as List?)?.map((stream) => AudioStream.fromJson(stream)).toList() ?? [],
      attachments: (json['attachments'] as List?)?.map((attachment) => Attachment.fromJson(attachment)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'duration': duration,
      'bitrate': bitrate,
      'muxingApp': muxingApp,
      'writingApp': writingApp,
      'videoStreams': videoStreams.map((stream) => stream.toJson()).toList(),
      'audioStreams': audioStreams.map((stream) => stream.toJson()).toList(),
      'attachments': attachments.map((attachment) => attachment.toJson()).toList(),
    };
  }

  // Helper method for bitrate display
  String get bitrateFormatted => '${(bitrate / 1000).round()} kbps';

  // Helper method for duration display
  String get durationFormatted => '${duration.toStringAsFixed(2)} ms';
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

  Map<String, dynamic> toJson() {
    return {
      'trackNumber': trackNumber,
      'codecId': codecId,
      'codecName': codecName,
      'width': width,
      'height': height,
      'frameRate': frameRate,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'trackNumber': trackNumber,
      'codecId': codecId,
      'codecName': codecName,
      'channels': channels,
      'sampleRate': sampleRate,
      'bitDepth': bitDepth,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'fileName': fileName,
      'mimeType': mimeType,
      'description': description,
      'size': size,
    };
  }

  String get sizeFormatted => '${(size / 1024).round()} KB';
}
