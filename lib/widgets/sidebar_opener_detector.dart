

import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/utils/screen.dart';
import 'package:miruryoiki/utils/time.dart';

class SidebarOpenerDetector extends StatelessWidget {
  final VoidCallback onHover;
  final VoidCallback onExit;
  final bool isSeriesView;
  final bool shouldExpand;

  const SidebarOpenerDetector({
    super.key,
    required this.onHover,
    required this.onExit,
    required this.shouldExpand,
    required this.isSeriesView,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      child: AnimatedContainer(
        duration: dimDuration,
        curve: Curves.easeInOut,
        width: shouldExpand ? ScreenUtils.kPaneBarExpandedWidth : ScreenUtils.kPaneBarCollapsedWidth,
        height: ScreenUtils.height,
        child: MouseRegion(
          hitTestBehavior: HitTestBehavior.translucent,
          onEnter: (_) => isSeriesView ? onHover() : null,
          onExit: (_) => isSeriesView ? onExit() : null,
        ),
      ),
    );
  }
}