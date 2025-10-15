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

enum FirstDayOfWeek { sunday, monday, tuesday, wednesday, thursday, friday, saturday }

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

  // Check if this message level should be logged given the configured threshold
  // Lower priority numbers = more important/less verbose
  // When threshold is ERROR (1),   log messages with priority <= 1 (just ERROR and NONE)
  // When threshold is WARNING (2), log messages with priority <= 2 (ERROR, WARNING)
  // When threshold is INFO (3),    log messages with priority <= 3 (ERROR, WARNING, INFO)
  // When threshold is DEBUG (4),   log messages with priority <= 4 (ERROR, WARNING, INFO, DEBUG)
  // When threshold is TRACE (5),   log messages with priority <= 5 (everything)
  bool shouldLog(LogLevel currentLevel) => priority <= currentLevel.priority;

  static LogLevel fromString(String value, {LogLevel? defaultValue}) => fromStringX<LogLevel>(
        value,
        LogLevel.values,
        defaultValue ?? LogLevel.error,
      );
}

extension FirstDayOfWeekX on FirstDayOfWeek {
  String get name_ => enumToString(this);

  String get displayName {
    switch (this) {
      case FirstDayOfWeek.sunday:
        return 'Sunday';
      case FirstDayOfWeek.monday:
        return 'Monday';
      case FirstDayOfWeek.tuesday:
        return 'Tuesday';
      case FirstDayOfWeek.wednesday:
        return 'Wednesday';
      case FirstDayOfWeek.thursday:
        return 'Thursday';
      case FirstDayOfWeek.friday:
        return 'Friday';
      case FirstDayOfWeek.saturday:
        return 'Saturday';
    }
  }

  /// Convert to DateTime.weekday value (1 = Monday, 7 = Sunday)
  int get toWeekdayValue {
    switch (this) {
      case FirstDayOfWeek.monday:
        return 1;
      case FirstDayOfWeek.tuesday:
        return 2;
      case FirstDayOfWeek.wednesday:
        return 3;
      case FirstDayOfWeek.thursday:
        return 4;
      case FirstDayOfWeek.friday:
        return 5;
      case FirstDayOfWeek.saturday:
        return 6;
      case FirstDayOfWeek.sunday:
        return 7;
    }
  }

  static FirstDayOfWeek fromString(String value, {FirstDayOfWeek? defaultValue}) => fromStringX<FirstDayOfWeek>(
        value,
        FirstDayOfWeek.values,
        defaultValue ?? FirstDayOfWeek.monday,
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

enum LibraryView { all, linked } // TODO add anilist/remote (not caring about local files)

enum ViewType { grid, detailedList }

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

extension SortOrderX on SortOrder {
  String get name_ => enumToString(this);

  static SortOrder fromString(String value, {SortOrder? defaultValue}) => fromStringX<SortOrder>(
        value,
        SortOrder.values,
        defaultValue,
      );
}

enum GroupBy { none, anilistLists }

extension DateTimeX on DateTime? {
  String pretty({bool time = false}) {
    if (this == null) return 'null';
    final dateFormat = DateFormat('dd MMM yyyy', 'en');
    final timeFormat = DateFormat('HH:mm:ss', 'en');
    return '${dateFormat.format(this!)}${time ? ' ${timeFormat.format(this!)}' : ''}';
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
