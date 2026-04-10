import 'dart:math' as math show max, min;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import '../../manager.dart';
import '../../theme.dart';
import '../../utils/screen.dart';
import '../../utils/time.dart';

class HeaderWidget extends StatefulWidget {
  //TODO check if background gradient is being drawn twice with templatepage bg
  final Widget Function(TextStyle titleStyle, BoxConstraints constraints) title;
  final ImageProvider? image;
  final Widget? image_widget;
  final ColorFilter? colorFilter;
  final List<Widget> children;
  final bool titleLeftAligned;
  final EdgeInsets headerPadding;
  final double? contentRightPadding;
  final double? fixed;

  const HeaderWidget({
    super.key,
    required this.title,
    this.image,
    this.colorFilter,
    this.children = const [],
    this.titleLeftAligned = false,
    this.image_widget,
    this.headerPadding = EdgeInsets.zero,
    this.contentRightPadding,
    this.fixed,
  }) : assert(
          !(image != null && image_widget != null),
          'Only one of image or image_widget can be provided',
        );

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  @override
  Widget build(BuildContext context) {
    // Watch AppTheme so this rebuilds if theme colors change (like turning debug green on/off)
    Provider.of<AppTheme>(context);

    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          AnimatedContainer(
            duration: shortStickyHeaderDuration,
            height: widget.fixed ?? ScreenUtils.kMaxHeaderHeight,
            width: double.infinity,
            // Background image
            decoration: BoxDecoration(
              gradient: widget.image_widget == null
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        (Manager.currentDominantColor ?? Manager.accentColor).withOpacity(0.27),
                        Colors.transparent,
                      ],
                    )
                  : null,
              image: widget.image_widget == null
                  ? () {
                      final imageProvider = widget.image;
                      if (imageProvider == null) return null;

                      return DecorationImage(
                        alignment: Alignment.center,
                        image: imageProvider,
                        fit: BoxFit.cover,
                        isAntiAlias: true,
                        colorFilter: widget.colorFilter,
                      );
                    }()
                  : null,
            ),
            padding: widget.headerPadding,
            alignment: Alignment.bottomLeft,
            child: widget.image_widget,
          ),
          // Title and watched percentage
          HeaderCenterInPageWidget(
            titleLeftAligned: widget.titleLeftAligned,
            title: widget.title,
            constraints: constraints,
            contentRightPadding: widget.contentRightPadding,
            children: widget.children,
          )
        ],
      );
    });
  }
}

class HeaderCenterInPageWidget extends StatelessWidget {
  const HeaderCenterInPageWidget({
    super.key,
    required this.titleLeftAligned,
    required this.title,
    this.children = const [],
    required this.constraints,
    this.top,
    this.bottom,
    double? contentRightPadding,
  }) : contentRightPadding = contentRightPadding ?? 4.0;

  final bool titleLeftAligned;
  final Widget Function(TextStyle titleStyle, BoxConstraints constraints) title;
  final List<Widget> children;
  final BoxConstraints constraints;
  final double? top;
  final double? bottom;
  final double contentRightPadding;

  @override
  Widget build(BuildContext context) {
    final double? bottom_;
    if (top == null && bottom == null) // keep bottom at 0 as fallback
      bottom_ = 0;
    else
      bottom_ = bottom;

    return Positioned(
      bottom: bottom_,
      top: top,
      left: () {
        final double shrinkedI = ScreenUtils.kInfoBarWidth - (6 * 2) + 42;
        final double maximisedI = (constraints.maxWidth - ScreenUtils.kMaxContentWidth) / 2 + 310 + 20;
        final double shrinked = (constraints.maxWidth - ScreenUtils.kMaxContentWidth) / 2 + 20 + contentRightPadding;
        final double maximised = 20 + contentRightPadding;

        // Calculate value safely and prevent Infinity
        double result = titleLeftAligned ? math.max(maximised, shrinked) : math.max(maximisedI, shrinkedI) - 16;

        // Guard against invalid values
        if (result.isInfinite || result.isNaN) return 20.0;

        return result;
      }(),
      child: SizedBox(
        width: math.min(ScreenUtils.kMaxContentWidth, constraints.maxWidth) - (titleLeftAligned ? 0 : ScreenUtils.kInfoBarWidth) - 32, // 32 of right padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Series title
            title(
              Manager.bodyLargeStyle.copyWith(
                fontSize: 32 * Manager.fontSizeMultiplier,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              constraints,
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
