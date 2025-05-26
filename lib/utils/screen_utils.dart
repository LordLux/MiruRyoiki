import 'package:fluent_ui/fluent_ui.dart';

class ScreenUtils {
  static MediaQueryData get _mediaQuery => MediaQueryData.fromWindow(WidgetsBinding.instance.window);

  static double get width => _mediaQuery.size.width;
  static double get height => _mediaQuery.size.height;
  static double get pixelRatio => _mediaQuery.devicePixelRatio;
  static double get textScaleFactor => _mediaQuery.textScaleFactor;
  static double get devicePixelRatio => _mediaQuery.devicePixelRatio;

  static const double navigationBarWidth = 300.0;
  static const double maxHeaderHeight = 290.0;
  static const double minHeaderHeight = 150.0;
  static const double infoBarWidth = 300.0;
  static const double maxContentWidth = 1400.0;
}
