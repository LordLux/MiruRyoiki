// converters.dart
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../models/metadata.dart';
import '../models/mkv_metadata.dart';
import '../models/notification.dart';
import '../utils/path_utils.dart';
import '../enums.dart'; // per ImageSource

/// -------- String <-> PathString --------
class PathStringConverter extends TypeConverter<PathString, String> {
  const PathStringConverter();

  @override
  PathString fromSql(String fromDb) => PathString(fromDb);

  @override
  String toSql(PathString value) => value.path;
}

/// -------- ImageSource <-> TEXT --------
class ImageSourceConverter extends TypeConverter<ImageSource?, String?> {
  const ImageSourceConverter();

  @override
  ImageSource? fromSql(String? fromDb) {
    if (fromDb == null) return null;
    return ImageSource.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => ImageSource.autoLocal,
    );
  }

  @override
  String? toSql(ImageSource? value) => value?.name;
}

/// -------- Color <-> JSON TEXT --------
class ColorJsonConverter extends TypeConverter<Color?, String?> {
  const ColorJsonConverter();

  @override
  Color? fromSql(String? fromDb) {
    if (fromDb == null) return null;
    final map = jsonDecode(fromDb) as Map<String, dynamic>;
    // Se il JSON è malformato, jsonDecode lancerà FormatException
    return Color.fromARGB(map['a'], map['r'], map['g'], map['b']);
  }

  @override
  String? toSql(Color? value) {
    if (value == null) return null;
    return jsonEncode({
      'r': value.red,
      'g': value.green,
      'b': value.blue,
      'a': value.alpha,
    });
  }
}

/// -------- Metadata <-> JSON TEXT --------
class MetadataConverter extends TypeConverter<Metadata?, String?> {
  const MetadataConverter();

  @override
  Metadata? fromSql(String? sqlValue) {
    if (sqlValue == null) return null;
    final map = json.decode(sqlValue) as Map<String, dynamic>;
    // Se il JSON è malformato, json.decode lancerà FormatException
    return Metadata.fromJson(map);
  }

  @override
  String? toSql(Metadata? value) {
    if (value == null) return null;
    return json.encode(value.toJson());
  }
}

/// -------- MkvMetadata <-> JSON TEXT --------
class MkvMetadataConverter extends TypeConverter<MkvMetadata?, String?> {
  const MkvMetadataConverter();

  @override
  MkvMetadata? fromSql(String? sqlValue) {
    if (sqlValue == null) return null;
    final map = json.decode(sqlValue) as Map<String, dynamic>;
    // Se il JSON è malformato, json.decode lancerà FormatException
    return MkvMetadata.fromJson(map);
  }

  @override
  String? toSql(MkvMetadata? value) {
    if (value == null) return null;
    return json.encode(value.toJson());
  }
}

// Generic JSON string converter
class JsonMapConverter extends TypeConverter<Map<String, dynamic>?, String?> {
  const JsonMapConverter();

  @override
  Map<String, dynamic>? fromSql(String? fromDb) {
    if (fromDb == null) return null;
    // Se il JSON è malformato, jsonDecode lancerà FormatException
    return jsonDecode(fromDb) as Map<String, dynamic>;
  }

  @override
  String? toSql(Map<String, dynamic>? value) =>
      value == null ? null : jsonEncode(value);
}

/// -------- NotificationType <-> INTEGER --------
class NotificationTypeConverter extends TypeConverter<NotificationType, int> {
  const NotificationTypeConverter();

  @override
  NotificationType fromSql(int fromDb) => NotificationType.values[fromDb];

  @override
  int toSql(NotificationType value) => value.index;
}

/// -------- MediaInfo <-> JSON TEXT --------
class MediaInfoConverter extends TypeConverter<MediaInfo?, String?> {
  const MediaInfoConverter();

  @override
  MediaInfo? fromSql(String? sqlValue) {
    if (sqlValue == null) return null;
    final map = json.decode(sqlValue) as Map<String, dynamic>;
    return MediaInfo.fromJson(map);
  }

  @override
  String? toSql(MediaInfo? value) {
    if (value == null) return null;
    return json.encode(value.toJson());
  }
}

// ignore: unintended_html_in_doc_comment
/// -------- List<String> <-> JSON TEXT --------
class StringListConverter extends TypeConverter<List<String>?, String?> {
  const StringListConverter();

  @override
  List<String>? fromSql(String? sqlValue) {
    if (sqlValue == null) return null;
    final list = json.decode(sqlValue) as List<dynamic>;
    return list.cast<String>();
  }

  @override
  String? toSql(List<String>? value) {
    if (value == null) return null;
    return json.encode(value);
  }
}
