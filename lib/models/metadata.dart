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

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'creationTime': creationTime.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'lastAccessed': lastAccessed.toIso8601String(),
    };
  }
}
