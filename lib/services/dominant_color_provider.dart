import 'package:fluent_ui/fluent_ui.dart';

/// Holds the app's dominant accent-colour state.
///
/// [seriesDominantColor] is the colour derived for whichever series is
/// currently being viewed. [currentDominantColor] is the colour actually
/// applied to the app's UI chrome, which can differ from it depending on
/// navigation state (e.g. reset to null when leaving a series).
///
/// A [ChangeNotifier] so widgets can rebuild when either colour changes.
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
