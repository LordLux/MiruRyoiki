import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

extension PaneDisplayModeX on PaneDisplayMode {
  String get name {
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
  String get name {
    switch (this) {
      case ThemeMode.system:
        return 'Sistema';
      case ThemeMode.light:
        return 'Chiaro';
      case ThemeMode.dark:
        return 'Scuro';
    }
  }
}

extension WindowEffectX on WindowEffect {
  String get name => toString().split('.').last;
}

WindowEffect windowEffectfromString(String value) {
  return WindowEffect.values.firstWhere(
    (e) => e.toString().split('.').last == value,
    orElse: () => WindowEffect.disabled,
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
