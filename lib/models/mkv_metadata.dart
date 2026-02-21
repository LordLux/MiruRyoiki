import '../utils/units.dart' as units;

class MkvMetadata {
  final String format;
  final int bitrate; // in bits per second
  final List<String> attachments;
  final List<VideoStream> videoStreams;
  final List<AudioStream> audioStreams;
  final List<TextStream> textStreams;

  const MkvMetadata({
    this.format = '',
    this.bitrate = 0,
    this.attachments = const [],
    this.videoStreams = const [],
    this.audioStreams = const [],
    this.textStreams = const [],
  });

  factory MkvMetadata.fromJson(Map<dynamic, dynamic> json) {
    return MkvMetadata(
      format: json['format'] as String? ?? '',
      bitrate: json['bitrate'] as int? ?? 0,
      attachments: (json['attachments'] as List?)?.map((item) => item as String).toList() ?? [],
      videoStreams: (json['videoStreams'] as List?)?.map((stream) => VideoStream.fromJson(stream)).toList() ?? [],
      audioStreams: (json['audioStreams'] as List?)?.map((stream) => AudioStream.fromJson(stream)).toList() ?? [],
      textStreams: (json['textStreams'] as List?)?.map((stream) => TextStream.fromJson(stream)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'format': format,
      'bitrate': bitrate,
      'attachments': attachments,
      'videoStreams': videoStreams.map((stream) => stream.toJson()).toList(),
      'audioStreams': audioStreams.map((stream) => stream.toJson()).toList(),
      'textStreams': textStreams.map((stream) => stream.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) => //
      identical(this, other) || //
      other is MkvMetadata && //
          format == other.format &&
          bitrate == other.bitrate &&
          _listEquals(attachments, other.attachments) &&
          _listEquals(videoStreams, other.videoStreams) &&
          _listEquals(audioStreams, other.audioStreams) &&
          _listEquals(textStreams, other.textStreams);

  @override
  int get hashCode => Object.hash(format, bitrate, attachments.length, videoStreams.length, audioStreams.length, textStreams.length);

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // Helper method for bitrate display
  String get bitrateFormatted => units.fileTransferRate(bitrate);

  @override
  String toString() => 'MkvMetadata(format: $format, bitrate: $bitrateFormatted, videoStreams: ${videoStreams.length}, audioStreams: ${audioStreams.length}, textStreams: ${textStreams.length}, attachments: ${attachments.length})';
}

class Pair {
  final int width;
  final int height;

  const Pair({this.width = 0, this.height = 0});

  factory Pair.fromJson(Map<dynamic, dynamic> json) {
    return Pair(
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
    };
  }

  @override
  bool operator ==(Object other) => //
      identical(this, other) || //
      other is Pair && width == other.width && height == other.height;

  @override
  int get hashCode => Object.hash(width, height);

  @override
  String toString() => '$width, $height';
}

class VideoStream {
  final String format;
  final Pair size;
  final Pair aspectRatio;
  final double fps;
  final int bitrate;
  final int bitDepth;

  const VideoStream({
    this.format = '',
    this.size = const Pair(),
    this.aspectRatio = const Pair(),
    this.fps = 0.0,
    this.bitrate = 0,
    this.bitDepth = 0,
  });

  factory VideoStream.fromJson(Map<dynamic, dynamic> json) {
    return VideoStream(
      format: json['format'] as String? ?? '',
      size: json['size'] != null ? Pair.fromJson(json['size']) : const Pair(),
      aspectRatio: json['aspectRatio'] != null ? Pair.fromJson(json['aspectRatio']) : const Pair(),
      fps: (json['fps'] as num?)?.toDouble() ?? 0.0,
      bitrate: json['bitrate'] as int? ?? 0,
      bitDepth: json['bitDepth'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'format': format,
      'size': size.toJson(),
      'aspectRatio': aspectRatio.toJson(),
      'fps': fps,
      'bitrate': bitrate,
      'bitDepth': bitDepth,
    };
  }

  String get bitrateFormatted => units.fileTransferRate(bitrate);

  @override
  bool operator ==(Object other) => //
      identical(this, other) || //
      other is VideoStream && //
          format == other.format &&
          size == other.size &&
          aspectRatio == other.aspectRatio &&
          fps == other.fps &&
          bitrate == other.bitrate &&
          bitDepth == other.bitDepth;

  @override
  int get hashCode => Object.hash(format, size, aspectRatio, fps, bitrate, bitDepth);

  String get aspectRatioFormatted => aspectRatio.width > 0 && aspectRatio.height > 0 ? '${aspectRatio.width}:${aspectRatio.height}' : 'N/A';
}

class AudioStream {
  final String format;
  final int bitrate;
  final int channels;
  final String? language;

  const AudioStream({
    this.format = '',
    this.bitrate = 0,
    this.channels = 0,
    this.language,
  });

  factory AudioStream.fromJson(Map<dynamic, dynamic> json) {
    return AudioStream(
      format: json['format'] as String? ?? '',
      bitrate: json['bitrate'] as int? ?? 0,
      channels: json['channels'] as int? ?? 0,
      language: json['language'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'format': format,
      'bitrate': bitrate,
      'channels': channels,
      'language': language,
    };
  }

  String get bitrateFormatted => units.fileTransferRate(bitrate);

  @override
  bool operator ==(Object other) => //
      identical(this, other) || //
      other is AudioStream && //
          format == other.format &&
          bitrate == other.bitrate &&
          channels == other.channels &&
          language == other.language;

  @override
  int get hashCode => Object.hash(format, bitrate, channels, language);
}

class TextStream {
  final String format;
  final String language;
  final String? title;

  const TextStream({
    this.format = '',
    this.language = '',
    this.title,
  });

  factory TextStream.fromJson(Map<dynamic, dynamic> json) {
    return TextStream(
      format: json['format'] as String? ?? '',
      language: json['language'] as String? ?? '',
      title: json['title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'format': format,
      'language': language,
      'title': title,
    };
  }

  @override
  bool operator ==(Object other) => //
      identical(this, other) || //
      other is TextStream && //
          format == other.format &&
          language == other.language &&
          title == other.title;

  @override
  int get hashCode => Object.hash(format, language, title);
}
