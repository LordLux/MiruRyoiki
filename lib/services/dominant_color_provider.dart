import 'package:fluent_ui/fluent_ui.dart';

/// Holds the app's dominant-colour UI state (previously plain statics on [Manager]).
///
/// Part of the Phase 4 strangler effort to move `Manager`'s mutable global UI
/// state off the static god-object and onto a proper `ChangeNotifier`, so
/// widgets can `context.watch` a colour change instead of relying on a
/// GlobalKey `setState` punch-through.
///
/// This provider is additive for now: `Manager.currentDominantColor` /
/// `Manager.seriesDominantColor` still exist and all 113 existing read call
/// sites are untouched. Delegating `Manager`'s getters to this provider, and
/// converting call sites to `context.watch<DominantColorProvider>()`, are
/// separate follow-up steps (see TECH_DEBT_AUDIT.md, Phase 4).
class DominantColorProvider extends ChangeNotifier {
  Color? _currentDominantColor;
  Color? get currentDominantColor => _currentDominantColor;
  set currentDominantColor(Color? value) {
    if (_currentDominantColor == value) return;
    _currentDominantColor = value;
    notifyListeners();
  }

  Color? _seriesDominantColor;
  Color? get seriesDominantColor => _seriesDominantColor;
  set seriesDominantColor(Color? value) {
    if (_seriesDominantColor == value) return;
    _seriesDominantColor = value;
    notifyListeners();
  }

  AccentColor? get currentDominantAccentColor => _currentDominantColor?.toAccentColor();
}
