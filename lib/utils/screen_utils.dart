import 'package:fluent_ui/fluent_ui.dart';

import '../manager.dart';
import 'logging.dart';

class ScreenUtils {
  static const int _kcrossAxisCountMax = 10;
  static const double kDefaultAspectRatio = 0.71; // 7:10 aspect ratio
  static const double kDefaultCardAspectRatio = 0.65388983532; // 7:10 aspect ratio
  static const double kDefaultCardPadding = 14.0;
  static const double kMaxFontSize = 24.0;
  static const double kMinFontSize = 8.0;
  static const double kDefaultCardWidth = 200.0;
  static const double kDefaultCardHeight = 200.0 * kDefaultCardAspectRatio;
  static const double kNavigationBarWidth = 300.0;
  static const double kMaxHeaderHeight = 290.0;
  static const double kMinHeaderHeight = 150.0;
  static const double kInfoBarWidth = 300.0;
  static const double kMaxContentWidth = 1400.0;
  static const double kTitleBarHeight = 40.0;
  static const double kOfflineBarMaxHeight = 20.0;

  static Size? cardSize;

  static MediaQueryData get _mediaQuery => MediaQueryData.fromWindow(WidgetsBinding.instance.window);
  static double get width => _mediaQuery.size.width;
  static double get height => _mediaQuery.size.height;
  static double get pixelRatio => _mediaQuery.devicePixelRatio;
  static double get textScaleFactor => _mediaQuery.textScaleFactor;
  static double get fallbackWidth => (width - kNavigationBarWidth - 32 /*padding*/);
  static double get maxCardWidth => Manager.fontSizeMultiplier * kDefaultCardWidth;
  static double get cardPadding => Manager.fontSizeMultiplier * kDefaultCardPadding;
  static double? get cardWidth => cardSize?.width;
  static double? get cardHeight => cardSize?.height;
  static double get paddedCardHeight => (cardHeight ?? kDefaultCardHeight) + cardPadding;

  static int crossAxisCount([double? maxConstrainedWidth]) => //
      ((maxConstrainedWidth ?? fallbackWidth) ~/ (maxCardWidth + cardPadding)) //
          .clamp(1, _kcrossAxisCountMax);

  static int mainAxisCount(int cardNumber) => //
      ((cardNumber / crossAxisCount()).ceil()) //
          .clamp(1, _kcrossAxisCountMax);
}

/// Creates a horizontal divider with a fixed width based on the current font size multiplier
Widget HDiv(double width) => SizedBox(width: width * Manager.fontSizeMultiplier);

/// Creates a vertical divider with a fixed height based on the current font size multiplier
Widget VDiv(double height) => SizedBox(height: height * Manager.fontSizeMultiplier);

/// Creates a horizontal divider with a fixed pixel width
Widget HDivPx(double width) => SizedBox(width: width);

/// Creates a vertical divider with a fixed pixel height
Widget VDivPx(double height) => SizedBox(height: height);
