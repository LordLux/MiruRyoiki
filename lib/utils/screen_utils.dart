import 'package:fluent_ui/fluent_ui.dart';

class ScreenUtils {
  static MediaQueryData get _mediaQuery => MediaQueryData.fromWindow(WidgetsBinding.instance.window);
  
  static double get width => _mediaQuery.size.width;
  static double get height => _mediaQuery.size.height;
  static double get pixelRatio => _mediaQuery.devicePixelRatio;
  static double get textScaleFactor => _mediaQuery.textScaleFactor;
  static double get devicePixelRatio => _mediaQuery.devicePixelRatio;
}