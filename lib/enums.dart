import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/window_effect.dart';

enum Dim { dimmed, normal, brightened }

extension PaneDisplayModeX on PaneDisplayMode {
  String get name_ {
    switch (this) {
      case PaneDisplayMode.auto:
        return 'Automatico';
      case PaneDisplayMode.compact:
        return 'Compatto';
      case PaneDisplayMode.minimal:
        return 'Minimal';
      case PaneDisplayMode.open:
        return 'Aperto';
      case PaneDisplayMode.top:
        return 'In alto';
    }
  }
}

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

  static ThemeMode fromString(String value) {
    return ThemeMode.values.firstWhere(
      (e) => e.name_.toLowerCase() == value.toLowerCase(),
      orElse: () => ThemeMode.system,
    );
  }
}

extension WindowEffectX on WindowEffect {
  String get name_ => toString().split('.').last;

  static WindowEffect fromString(String value) {
    return WindowEffect.values.firstWhere(
      (e) => e.name_ == value,
      orElse: () => WindowEffect.disabled,
    );
  }
}

extension HexColor on Color {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
