import 'dart:math' as math show max, min;

import 'package:fluent_ui/fluent_ui.dart';

import '../../manager.dart';
import '../../utils/screen.dart';
import '../../utils/time.dart';

class HeaderWidget extends StatefulWidget {
  final Widget Function(TextStyle titleStyle, BoxConstraints constraints) title;
  final ImageProvider? image;
  final Widget? image_widget;
  final ColorFilter? colorFilter;
  final List<Widget> children;
  final bool titleLeftAligned;
  final EdgeInsets headerPadding;
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
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          AnimatedContainer(
            duration: shortStickyHeaderDuration,
            height: widget.fixed ?? ScreenUtils.kMaxHeaderHeight,
            width: double.infinity,
            // Background image
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Manager.accentColor.withOpacity(0.27),
                  Colors.transparent,
                ],
              ),
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
          Positioned(
            bottom: 0,
            left: () {
              final double shrinkedI = ScreenUtils.kInfoBarWidth - (6 * 2) + 42;
              final double maximisedI = (constraints.maxWidth - ScreenUtils.kMaxContentWidth) / 2 + 310 + 20;
              final double shrinked = (constraints.maxWidth - ScreenUtils.kMaxContentWidth) / 2 + 20;
              final double maximised = 20;

              // Calculate value safely and prevent Infinity
              double result = widget.titleLeftAligned ? math.max(maximised, shrinked) : math.max(maximisedI, shrinkedI) - 16;

              // Guard against invalid values
              if (result.isInfinite || result.isNaN) return 20.0;

              return result;
            }(),
            child: SizedBox(
              width: math.min(ScreenUtils.kMaxContentWidth, constraints.maxWidth - 16 /*right padding*/) - (widget.titleLeftAligned ? 0 : ScreenUtils.kInfoBarWidth) - 32,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Series title
                  widget.title(
                    Manager.bodyLargeStyle.copyWith(
                      fontSize: 32 * Manager.fontSizeMultiplier,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    constraints,
                  ),
                  ...widget.children,
                  if (widget.children.isNotEmpty) VDiv(8),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
