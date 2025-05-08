import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:recase/recase.dart';

// ENUMS
enum Dim { dimmed, normal, brightened }

enum PosterSource { local, anilist, unspecified }

enum LibraryColorView { all, onlyHover, onlyBackground, none }

// EXTENSIONS
extension ThemeX on ThemeMode{
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

String enumToString<T>(T enumValue) {
  final str = enumValue.toString().split('.').last; // Get the enum name
  final String finale = RegExp('[A-Z][a-z]*') // Titlecase every word, separated by spaces
      .allMatches(str)
      .map((m) => m.group(0)?.titleCase ?? '')
      .join(' ');
  if (finale.isEmpty) return str.titleCase;
  return finale.titleCase;
}

/// Extension to convert a string to an enum value, with a default value fallback
T fromStringX<T>(String value, List<T> values, [T? defaultValue]) {
  return values.firstWhere(
    (e) => enumToString<T>(e).toLowerCase() == value.toLowerCase(),
    orElse: () {
      if (defaultValue == null) print('Invalid value: $value, returning first value: ${values.first}');
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
