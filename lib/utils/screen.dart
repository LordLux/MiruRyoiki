import 'package:fluent_ui/fluent_ui.dart';

import '../manager.dart';

class ScreenUtils {
  static const int _kcrossAxisCountMax = 10;

  static const double kDefaultAspectRatio = 0.71; // 7:10 aspect ratio
  static const double kDefaultCardAspectRatio = 0.707901322849; // 7:10 actual aspect ratio
  static const double kDefaultCardPadding = 14.0;
  static const double kDefaultCardWidth = 198.0;
  static const double kDefaultCardHeight = kDefaultCardWidth / kDefaultCardAspectRatio;
  
  static const double kMinStatCardWidth = 130.0;
  static const double kMaxStatCardWidth = 200.0;
  static const double kMinDistrCardWidth = 430.0;
  static const double kMaxDistrCardWidth = 900.0;

  static const double kDefaultSplashScreenWidth = 500.0;
  static const double kDefaultSplashScreenHeight = 300.0;

  static const double kDefaultMinWindowWidth = 800.0;
  static const double kDefaultMinWindowHeight = 600.0;
  static const double kDefaultMaxWindowWidth = 100000.0;
  static const double kDefaultMaxWindowHeight = 100000.0;

  static const double kMaxFontSize = 24.0;
  static const double kMinFontSize = 8.0;
  
  static const double kDefaultListViewItemHeight = 53.5;

  static const double kNavigationBarWidth = 300.0;
  static const double kStatusBarHeight = 24.0;
  static const double kMaxHeaderHeight = 290.0;
  static const double kMinHeaderHeight = 150.0;
  static const double kInfoBarWidth = 300.0;
  static const double kMaxContentWidth = 1400.0;
  static const double kTitleBarHeight = 40.0;
  static const double kOfflineBarMaxHeight = 20.0;
  static const double kEpisodeCardBorderRadius = 4.0;
  static const double kStatCardBorderRadius = 8.0;
  static const double kLibraryHeaderContentSeparatorHeight = 8.0;
  static const double kLibraryHeaderHeaderSeparatorHeight = 16.0;
  static const double kProfilePictureSize = 150.0;
  static const double kProfilePictureBorderRadius = 6.0;

  static double libraryContentWidthWithoutPadding = 0.0;
  static Size libraryCardSize = Size(kDefaultCardWidth, kDefaultCardHeight);

  static MediaQueryData get _mediaQuery => MediaQueryData.fromWindow(WidgetsBinding.instance.window);
  static double get width => _mediaQuery.size.width;
  static double get height => _mediaQuery.size.height;
  static double get pixelRatio => _mediaQuery.devicePixelRatio;
  static double get textScaleFactor => _mediaQuery.textScaleFactor;
  static double get fallbackWidth => (width - kNavigationBarWidth - 32 /*padding*/);
  static double get maxCardWidth => Manager.fontSizeMultiplier * kDefaultCardWidth;
  static double get maxCardHeight => Manager.fontSizeMultiplier * kDefaultCardHeight;
  static double get cardPadding => Manager.fontSizeMultiplier * kDefaultCardPadding;
  static double get paddedCardHeight => kDefaultCardHeight + cardPadding;

  static int crossAxisCount(double? maxConstrainedWidth) {
    final totalWidth = (maxConstrainedWidth ?? fallbackWidth);
    final size = (maxCardWidth + cardPadding);
    final nCards = (totalWidth ~/ size);
    final clamped = nCards.clamp(1, _kcrossAxisCountMax);
    // if (clamped != nCards) print("clamped: $clamped");
    return clamped;
  }

  static int mainAxisCount(int cardNumber) {
    return ((cardNumber / crossAxisCount(libraryContentWidthWithoutPadding)).ceil()) //
        .clamp(1, _kcrossAxisCountMax);
  }
}

/// Creates a horizontal divider with a fixed width based on the current font size multiplier
Widget HDiv(double width) => SizedBox(width: width * Manager.fontSizeMultiplier);

/// Creates a vertical divider with a fixed height based on the current font size multiplier
Widget VDiv(double height) => SizedBox(height: height * Manager.fontSizeMultiplier);

/// Creates a horizontal divider with a fixed pixel width
Widget HDivPx(double width) => SizedBox(width: width);

/// Creates a vertical divider with a fixed pixel height
Widget VDivPx(double height) => SizedBox(height: height);
