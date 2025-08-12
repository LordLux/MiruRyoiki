import 'dart:math' as math show max;

import 'package:fluent_ui/fluent_ui.dart';

import '../../manager.dart';
import '../../utils/screen_utils.dart';
import '../../utils/time_utils.dart';

class HeaderWidget extends StatefulWidget {
  final Widget Function(TextStyle titleStyle, BoxConstraints constraints) title;
  final ImageProvider? image;
  final Widget? image_widget;
  final ColorFilter? colorFilter;
  final List<Widget> children;
  final bool titleLeftAligned;
  final EdgeInsets headerPadding;

  const HeaderWidget({
    super.key,
    required this.title,
    this.image,
    this.colorFilter,
    this.children = const [],
    this.titleLeftAligned = false,
    this.image_widget,
    this.headerPadding = const EdgeInsets.only(bottom: 16.0),
  })  : assert(
          image != null || image_widget != null,
          'Either image or image_widget must be provided',
        ),
        assert(
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
            height: ScreenUtils.kMaxHeaderHeight,
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
                        alignment: Alignment.topCenter,
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
              final double shrinkedI = ScreenUtils.kInfoBarWidth - (6 * 2) + 42; // when the window is shorter than the maximum content width and there is a poster on the left
              final double maximisedI = (constraints.maxWidth - ScreenUtils.kMaxContentWidth) / 2 + 310 + 20; // when the window is larger than the maximum content width and there is a poster on the left
              final double shrinked = (constraints.maxWidth - ScreenUtils.kMaxContentWidth) / 2 + 20; // when the window is shorter than the maximum content width and there is no poster on the left
              final double maximised = 20; // when the window is larger than the maximum content width and there is no poster on the left
              return widget.titleLeftAligned ? math.max(maximised, shrinked) : math.max(maximisedI, shrinkedI);
            }(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Series title
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: ScreenUtils.kMaxContentWidth - ScreenUtils.kInfoBarWidth - 32,
                      child: widget.title(
                        const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        constraints,
                      ),
                    );
                  },
                ),
                VDiv(8),
                ...widget.children,
                if (widget.children.isNotEmpty) VDiv(12),
              ],
            ),
          ),
        ],
      );
    });
  }
}
