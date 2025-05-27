import 'package:fluent_ui/fluent_ui.dart';

class ScreenUtils {
  static MediaQueryData get _mediaQuery => MediaQueryData.fromWindow(WidgetsBinding.instance.window);

  static double get width => _mediaQuery.size.width;
  static double get height => _mediaQuery.size.height;
  static double get pixelRatio => _mediaQuery.devicePixelRatio;
  static double get textScaleFactor => _mediaQuery.textScaleFactor;
  static double get devicePixelRatio => _mediaQuery.devicePixelRatio;

  static int crossAxisCount([double? maxConstrainedWidth]) => //
      ((maxConstrainedWidth ?? (width - navigationBarWidth)) ~/ (maxCardWidth + ScreenUtils.cardPadding)).clamp(1, 10);

  static int mainAxisCount(int cardNumber) => //
      ((cardNumber / crossAxisCount()).ceil()).clamp(1, 10);

  static double cardWidth(double maxConstrainedWidth) => //
      (maxConstrainedWidth / (ScreenUtils.crossAxisCount(maxConstrainedWidth) + ScreenUtils.cardPadding * (ScreenUtils.crossAxisCount(maxConstrainedWidth) - 1))) //
          .clamp(0, ScreenUtils.maxCardWidth);

  static double cardHeight(double maxWidth) => //
      ((ScreenUtils.cardWidth(maxWidth) / 0.71) + ScreenUtils.cardPadding) * 8.4575; //7.757575

  static const double maxCardWidth = 200.0;
  static const double cardPadding = 16.0;
  static const double navigationBarWidth = 300.0;
  static const double maxHeaderHeight = 290.0;
  static const double minHeaderHeight = 150.0;
  static const double infoBarWidth = 300.0;
  static const double maxContentWidth = 1400.0;
}
