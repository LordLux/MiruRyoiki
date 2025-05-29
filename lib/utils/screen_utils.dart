import 'package:fluent_ui/fluent_ui.dart';

import '../manager.dart';
import 'logging.dart';

class ScreenUtils {
  static const double kDefaultAspectRatio = 0.71; // 7:10 aspect ratio
  static const double kDefaultCardPadding = 14.0;
  static const double kMaxFontSize = 24.0;
  static const double kMinFontSize = 8.0;
  static const double kDefaultCardWidth = 200.0;
  static const double kNavigationBarWidth = 300.0;
  static const double kMaxHeaderHeight = 290.0;
  static const double kMinHeaderHeight = 150.0;
  static const double kInfoBarWidth = 300.0;
  static const double kMaxContentWidth = 1400.0;

  static MediaQueryData get _mediaQuery => MediaQueryData.fromWindow(WidgetsBinding.instance.window);
  static double get width => _mediaQuery.size.width;
  static double get height => _mediaQuery.size.height;
  static double get pixelRatio => _mediaQuery.devicePixelRatio;
  static double get textScaleFactor => _mediaQuery.textScaleFactor;
  static double get devicePixelRatio => _mediaQuery.devicePixelRatio;

  static double get maxCardWidth => Manager.fontSizeMultiplier * kDefaultCardWidth;
  static double get cardPadding => Manager.fontSizeMultiplier * kDefaultCardPadding;

  static int crossAxisCount([double? maxConstrainedWidth]) {
    return ((maxConstrainedWidth ?? (width - kNavigationBarWidth - 32 /*padding*/)) ~/ (maxCardWidth + ScreenUtils.cardPadding)).clamp(1, 10);
  }

  static int mainAxisCount(int cardNumber) => //
      ((cardNumber / crossAxisCount()).ceil()).clamp(1, 10);

  static double cardWidth(double maxConstrainedWidth) => //
      (maxConstrainedWidth / (ScreenUtils.crossAxisCount(maxConstrainedWidth) + ScreenUtils.cardPadding * (ScreenUtils.crossAxisCount(maxConstrainedWidth) - 1))) //
          .clamp(0, ScreenUtils.maxCardWidth);

  static double cardHeight(double maxWidth) => //
      ((ScreenUtils.cardWidth(maxWidth) / ScreenUtils.kDefaultAspectRatio) + ScreenUtils.cardPadding) * 8.2575; //7.757575
}

/// Creates a horizontal divider with a fixed width based on the current font size multiplier
Widget HDiv(double width) => SizedBox(width: width * Manager.fontSizeMultiplier);

/// Creates a vertical divider with a fixed height based on the current font size multiplier
Widget VDiv(double height) => SizedBox(height: height * Manager.fontSizeMultiplier);

/// Creates a horizontal divider with a fixed pixel width
Widget HDivPx(double width) => SizedBox(width: width);

/// Creates a vertical divider with a fixed pixel height
Widget VDivPx(double height) => SizedBox(height: height);
