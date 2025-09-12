// ignore_for_file: constant_identifier_names

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:recase/recase.dart';
import 'package:intl/intl.dart';

import 'models/anilist/user_list.dart';

// ENUMS
enum Dim { dimmed, normal, brightened }

enum ImageSource { local, anilist, autoLocal, autoAnilist }

enum DominantColorSource { poster, banner }

enum LibraryColorView { alwaysDominant, alwaysAccent, hoverDominant, hoverAccent, none }

enum LogLevel { none, error, warning, info, debug, trace }

// EXTENSIONS
extension ThemeX on ThemeMode {
  String get name_ => enumToString(this);

  static ThemeMode fromString(String value) => fromStringX<ThemeMode>(
        value,
        ThemeMode.values,
        ThemeMode.system,
      );
}

extension WindowEffectX on WindowEffect {
  String get name_ => enumToString(this);

  static WindowEffect fromString(String value) => fromStringX<WindowEffect>(
        value,
        WindowEffect.values,
        WindowEffect.disabled,
      );
}

extension DimX on Dim {
  String get name_ => enumToString(this);

  static Dim fromString(String value, {Dim? defaultValue}) => fromStringX<Dim>(
        value,
        Dim.values,
        defaultValue,
      );
}

extension LibraryColorViewX on LibraryColorView {
  String get name_ => enumToString(this);

  static LibraryColorView fromString(String value, {LibraryColorView? defaultValue}) => fromStringX<LibraryColorView>(
        value,
        LibraryColorView.values,
        defaultValue,
      );
}

extension PosterSourceX on ImageSource {
  String get name_ {
    switch (this) {
      case ImageSource.local:
        return 'Local';
      case ImageSource.anilist:
        return 'AniList';
      case ImageSource.autoLocal:
        return 'Auto Local';
      case ImageSource.autoAnilist:
        return 'Auto AniList';
    }
  }

  static ImageSource fromString(String value, {ImageSource? defaultValue}) => fromStringX<ImageSource>(
        value,
        ImageSource.values,
        defaultValue,
      );
}

extension LogLevelX on LogLevel {
  String get name_ => enumToString(this);

  String get displayName {
    switch (this) {
      case LogLevel.none:
        return 'None';
      case LogLevel.error:
        return 'Error';
      case LogLevel.warning:
        return 'Warning';
      case LogLevel.info:
        return 'Info';
      case LogLevel.debug:
        return 'Debug';
      case LogLevel.trace:
        return 'Trace';
    }
  }

  int get priority {
    switch (this) {
      case LogLevel.none:
        return 0;
      case LogLevel.error:
        return 1;
      case LogLevel.warning:
        return 2;
      case LogLevel.info:
        return 3;
      case LogLevel.debug:
        return 4;
      case LogLevel.trace:
        return 5;
    }
  }

  bool shouldLog(LogLevel currentLevel) => priority <= currentLevel.priority;

  static LogLevel fromString(String value, {LogLevel? defaultValue}) => fromStringX<LogLevel>(
        value,
        LogLevel.values,
        defaultValue ?? LogLevel.error,
      );
}

extension DominantColorSourceX on DominantColorSource {
  String get name_ {
    switch (this) {
      case DominantColorSource.poster:
        return 'Poster';
      case DominantColorSource.banner:
        return 'Banner';
    }
  }

  static DominantColorSource fromString(String value) {
    // Migration from old ImageSource values
    if (value == 'local' || value == 'anilist' || value == 'autoAnilist') {
      return DominantColorSource.poster;
    } else if (value == 'autoLocal') {
      return DominantColorSource.banner;
    }

    try {
      return DominantColorSource.values.firstWhere((e) => e.name_ == value);
    } catch (e) {
      return DominantColorSource.poster; // Default
    }
  }
}

extension AnilistListStatusX on AnilistListApiStatus? {
  String get name_ => enumToString(this, false);
}

String enumToString<T>(T enumValue, [bool pretty = true]) {
  if (!pretty) {
    // logTrace(' [Enum to String: ${enumValue.toString().split('.').last.replaceAll(" ", "").toLowerCase()}]');
    return enumValue.toString().split('.').last.replaceAll(" ", "").toLowerCase();
  }

  String str = enumValue.toString().split('.').last; // Get the enum name
  str = str[0].toUpperCase() + str.substring(1); // Capitalize the first letter

  final String finale = RegExp('[A-Z][a-z]*') // Titlecase every word, separated by spaces
      .allMatches(str)
      .map((m) => m.group(0)?.titleCase ?? '')
      .join(' ');

  if (finale.isEmpty) return str.titleCase;
  return finale.titleCase;
}

/// Extension to convert a string to an enum value, with a default value fallback
T fromStringX<T>(String value, List<T> values, [T? defaultValue]) {
  value = value.replaceAll(" ", "").toLowerCase();
  // logTrace('Converting string to enum: $value');
  return values.firstWhere(
    (e) => enumToString<T>(e, false).toLowerCase() == value,
    orElse: () {
      // if (defaultValue == null) logTrace('Invalid value: $value not found in [${values.map((v) => enumToString<T>(v, false)).join(', ')}], returning first value: ${values.first}');
      return defaultValue ?? values.first;
    },
  );
}

// EXTRA EXTENSIONS
extension HexColor on Color {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true, bool includeAlpha = false}) => '${leadingHashSign ? '#' : ''}'
      '${includeAlpha ? alpha.toRadixString(16).padLeft(2, '0') : ''}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';

  int toHexInt() => int.parse(toHex().replaceAll('#', ''), radix: 16);

  Color shiftHue(double amount) {
    final hsl = HSLColor.fromColor(this);
    final shiftedHsl = hsl.withHue((hsl.hue + amount * 360) % 360);
    return shiftedHsl.toColor();
  }

  Color lighten([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final lightenedHsl = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return lightenedHsl.toColor();
  }

  Color darken([double amount = 0.1]) => lighten(-amount);

  Color saturate([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final saturatedHsl = hsl.withSaturation((hsl.saturation + amount).clamp(0.0, 1.0));
    return saturatedHsl.toColor();
  }
}


extension IntString on String {
  int toInt() => int.parse(this);

  int? toIntMaybe() => int.tryParse(this);
}


extension HexString on String {
  Color fromHex() {
    final hexColor = replaceAll('#', '');
    if (hexColor.length == 6) {
      return Color(int.parse('FF$hexColor', radix: 16));
    } else if (hexColor.length == 8) {
      return Color(int.parse(hexColor, radix: 16));
    } else {
      throw FormatException('Invalid hex color format: $this');
    }
  }
}

extension DurationX on Duration {
  Duration copyWith({
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
    int? milliseconds,
    int? microseconds,
  }) {
    return Duration(
      days: days ?? inDays,
      hours: hours ?? inHours,
      minutes: minutes ?? inMinutes,
      seconds: seconds ?? inSeconds,
      milliseconds: milliseconds ?? inMilliseconds,
      microseconds: microseconds ?? inMicroseconds,
    );
  }

  /// Adds a number of milliseconds to the duration
  Duration operator /(int other) {
    return copyWith(
      milliseconds: inMilliseconds + other,
    );
  }
}

enum LibraryView { all, linked }

enum ViewType { 
  grid,
  detailedList 
}

enum SortOrder {
  alphabetical,
  score,
  progress,
  lastModified,
  dateAdded,
  startDate,
  completedDate,
  averageScore,
  releaseDate,
  popularity,
}

enum GroupBy { none, anilistLists }

extension DateTimeX on DateTime? {
  String pretty() {
    if (this == null) return 'null';
    return DateFormat('dd MMM yyyy', 'en').format(this!);
  }

  static DateTime get epoch => DateTime.fromMillisecondsSinceEpoch(0);
}

extension ListSeries on List<String> {
  bool equals(List<String> other) {
    if (length != other.length) return false;
    return Set.from(this).difference(Set.from(other)).isEmpty;
  }
}

extension MapSwitch on Map<String, String> {
  /// Swaps keys and values in the map.
  Map<String, String> get swap {
    return Map.fromEntries(entries.map((e) => MapEntry(e.value, e.key)));
  }
}