import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/window_effect.dart';

enum Dim { dimmed, normal, brightened }

extension ThemeX on ThemeMode {
  String get name_ {
    switch (this) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  static ThemeMode fromString(String value) => fromStringX<ThemeMode>(
        value,
        ThemeMode.values,
        ThemeMode.system,
      );
}

extension WindowEffectX on WindowEffect {
  String get name_ => toString().split('.').last;

  static WindowEffect fromString(String value) => fromStringX<WindowEffect>(
        value,
        WindowEffect.values,
        WindowEffect.disabled,
      );
}

extension DimX on Dim {
  String get name_ {
    switch (this) {
      case Dim.dimmed:
        return 'Dimmed';
      case Dim.normal:
        return 'Normal';
      case Dim.brightened:
        return 'Brightened';
    }
  }

  static Dim fromString(String value, {Dim? defaultValue}) => fromStringX<Dim>(
        value,
        Dim.values,
        defaultValue,
      );
}

T fromStringX<T>(String value, List<T> values, [T? defaultValue]) {
  return values.firstWhere(
    (e) => e.toString().split('.').last.toLowerCase() == value.toLowerCase(),
    orElse: () {
      if (defaultValue == null) print('Invalid value: $value, returning first value: ${values.first}');
      return defaultValue ?? values.first;
    },
  );
}

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
