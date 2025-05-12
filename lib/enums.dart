import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:miruryoiki/utils/logging.dart';
import 'package:recase/recase.dart';

// ENUMS
enum Dim { dimmed, normal, brightened }

enum PosterSource { local, anilist, autoLocal, autoAnilist }

enum LibraryColorView { all, onlyHover, onlyBackground, none }

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

extension PosterSourceX on PosterSource {
  String get name_ {
    switch (this) {
      case PosterSource.local:
        return 'Local';
      case PosterSource.anilist:
        return 'AniList';
      case PosterSource.autoLocal:
        return 'Auto Local';
      case PosterSource.autoAnilist:
        return 'Auto AniList';
    }
  }

  static PosterSource fromString(String value, {PosterSource? defaultValue}) => fromStringX<PosterSource>(
        value,
        PosterSource.values,
        defaultValue,
      );
}

String enumToString<T>(T enumValue, [bool pretty = true]) {
  if (!pretty) {
    logTrace(' [Enum to String: ${enumValue.toString().split('.').last.replaceAll(" ", "").toLowerCase()}]');
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
  logTrace('Converting string to enum: $value');
  return values.firstWhere(
    (e) => enumToString<T>(e, false).toLowerCase() == value,
    orElse: () {
      if (defaultValue == null) logTrace('Invalid value: $value not found in [${values.map((v) => enumToString<T>(v, false)).join(', ')}], returning first value: ${values.first}');
      return defaultValue ?? values.first;
    },
  );
}

// EXTRA EXTENSIONS
extension HexColor on Color {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
      
  int toHexInt() => int.parse(toHex().replaceAll('#', ''), radix: 16);
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
