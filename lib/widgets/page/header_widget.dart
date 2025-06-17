import 'dart:math' as math show max;

import 'package:fluent_ui/fluent_ui.dart';

import '../../manager.dart';
import '../../utils/screen_utils.dart';
import '../../utils/time_utils.dart';

class HeaderWidget extends StatefulWidget {
  final Widget Function(TextStyle titleStyle) title;
  final ImageProvider? image;
  final ColorFilter? colorFilter;
  final List<Widget> children;
  final bool titleLeftAligned;

  const HeaderWidget({
    super.key,
    required this.title,
    required this.image,
    this.colorFilter,
    this.children = const [],
    this.titleLeftAligned = false,
  });

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
              image: () {
                final imageProvider = widget.image;
                if (imageProvider == null) return null;

                return DecorationImage(
                  alignment: Alignment.topCenter,
                  image: imageProvider,
                  fit: BoxFit.cover,
                  isAntiAlias: true,
                  colorFilter: widget.colorFilter,
                );
              }(),
            ),
            padding: const EdgeInsets.only(bottom: 16.0),
            alignment: Alignment.bottomLeft,
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
                SizedBox(
                  width: ScreenUtils.kMaxContentWidth - ScreenUtils.kInfoBarWidth - 32,
                  child: widget.title(
                    const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
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
