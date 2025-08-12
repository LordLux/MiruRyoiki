import '../enums.dart';
import '../utils/units.dart' as units;
import '../utils/units.dart';

/// Represents metadata for a video file.
class Metadata {
  /// Size in bytes.
  late final int size;

  /// Duration in milliseconds.
  late final Duration duration;

  /// Creation time of the file.
  late final DateTime creationTime;

  /// Last modified time of the file.
  late final DateTime lastModified;

  /// Last accessed time of the file.
  late final DateTime lastAccessed;

  Metadata({
    int? size,
    Duration? duration,
    DateTime? creationTime,
    DateTime? lastModified,
    DateTime? lastAccessed,
  }) {
    this.size = size ?? 0;
    this.duration = duration ?? Duration.zero;
    this.creationTime = creationTime ?? DateTimeX.epoch;
    this.lastModified = lastModified ?? DateTimeX.epoch;
    this.lastAccessed = lastAccessed ?? DateTimeX.epoch;
  }

  factory Metadata.fromJson(Map<dynamic, dynamic> json) {
    return Metadata(
      size: json['fileSize'] as int? ?? 0,
      duration: parseDuration(json['duration']),
      creationTime: parseDate(json['creationTime']),
      lastModified: parseDate(json['lastModified']),
      lastAccessed: parseDate(json['lastAccessed']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'fileSize': size,
      'duration': duration.inMilliseconds,
      'creationTime': creationTime.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'lastAccessed': lastAccessed.toIso8601String(),
    };
  }

  String get durationFormattedTimecode {
    final hours = duration.inHours;
    final minutes = (duration.inMinutes % 60);
    final seconds = (duration.inSeconds % 60);
    final milliseconds = (duration.inMilliseconds % 1000);
    final parts = <String>[];

    if (hours > 0) parts.add('${hours.toString().padLeft(2, '0')}:');
    if (minutes > 0 || hours > 0) parts.add('${minutes.toString().padLeft(2, '0')}:');
    if (seconds > 0 || minutes > 0 || hours > 0) parts.add('${seconds.toString().padLeft(2, '0')}.');
    if (milliseconds > 0 || seconds > 0 || minutes > 0 || hours > 0) parts.add(milliseconds.toString().padLeft(3, '0'));

    if (parts.isEmpty) return '00:00:00.000';

    return parts.join();
  }

  String get durationFormatted {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    final parts = <String>[];

    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}min${minutes == 1 ? '' : 's'}');
    if (seconds > 0) parts.add('${seconds}s');

    // If duration is zero, show "0ms"
    if (parts.isEmpty) return '0s';

    return parts.join(' ');
  }

  String get durationFormattedMs {
    final milliseconds = duration.inMilliseconds % 1000;
    return '$durationFormatted ${milliseconds}ms';
  }

  String fileSize([FileSizeUnit? unit]) => units.fileSize(size, unit);

  @override
  String toString() {
    return """Metadata(
      fileSize: ${fileSize()},
      duration: $durationFormattedTimecode,
      creationTime: $creationTime,
      lastModified: $lastModified,
      lastAccessed: $lastAccessed
    )""";
  }

  Metadata copyWith({
    int? size,
    Duration? duration,
    DateTime? creationTime,
    DateTime? lastModified,
    DateTime? lastAccessed
  }) {
    return Metadata(
      size: size ?? this.size,
      duration: duration ?? this.duration,
      creationTime: creationTime ?? this.creationTime,
      lastModified: lastModified ?? this.lastModified,
      lastAccessed: lastAccessed ?? this.lastAccessed
    );
  }
}

Duration parseDuration(dynamic value) {
  if (value == null) return Duration.zero;

  if (value is Duration) return value;
  if (value is int) return Duration(milliseconds: value);
  if (value is double) return Duration(milliseconds: value.toInt());
  if (value is String) {
    try {
      return Duration(milliseconds: int.parse(value));
    } catch (_) {
      // Handle custom formats or fallback
      return Duration.zero;
    }
  }
  return Duration.zero;
}

DateTime parseDate(dynamic value) {
  if (value == null) return DateTimeX.epoch;
  if (value is int) {
    // Assume milliseconds since epoch
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      // Optionally handle custom formats or fallback
      return DateTimeX.epoch;
    }
  }
  return DateTimeX.epoch;
}
