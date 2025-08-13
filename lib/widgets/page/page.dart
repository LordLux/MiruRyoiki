import 'package:fluent_ui/fluent_ui.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../../manager.dart';
import '../../services/navigation/shortcuts.dart';
import '../../utils/screen_utils.dart';
import '../../utils/time_utils.dart';
import 'header_widget.dart';
import 'infobar.dart';

class MiruRyoikiHeaderInfoBarPage extends StatefulWidget {
  final HeaderWidget headerWidget;
  final MiruRyoikiInfobar infobar;
  final Widget content;
  final Color? backgroundColor;
  final bool hideInfoBar;

  const MiruRyoikiHeaderInfoBarPage({
    super.key,
    required this.headerWidget,
    required this.infobar,
    required this.content,
    this.backgroundColor,
    this.hideInfoBar = false,
  });

  @override
  State<MiruRyoikiHeaderInfoBarPage> createState() => _MiruRyoikiHeaderInfoBarPageState();
}

class _MiruRyoikiHeaderInfoBarPageState extends State<MiruRyoikiHeaderInfoBarPage> {
  double _headerHeight = ScreenUtils.kMaxHeaderHeight;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: gradientChangeDuration,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.backgroundColor ?? Manager.accentColor.withOpacity(0.15),
            Colors.transparent,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          children: [
            // Sticky header
            AnimatedContainer(
              height: _headerHeight,
              width: double.infinity,
              duration: stickyHeaderDuration,
              curve: Curves.ease,
              alignment: Alignment.center,
              child: widget.headerWidget,
            ),
            Expanded(
              child: SizedBox(
                width: ScreenUtils.kMaxContentWidth,
                child: Row(
                  children: [
                    // Info bar on the left
                    if (!widget.hideInfoBar)
                      SizedBox(
                        height: double.infinity,
                        width: ScreenUtils.kInfoBarWidth,
                        child: widget.infobar,
                      ),

                    // Content area on the right
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(left: 16.0 * Manager.fontSizeMultiplier, top: 16.0, right: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context).copyWith(overscroll: true, platform: TargetPlatform.windows, scrollbars: false),
                              child: DynMouseScroll(
                                stopScroll: KeyboardState.ctrlPressedNotifier,
                                scrollSpeed: 1.8,
                                enableSmoothScroll: Manager.animationsEnabled,
                                durationMS: 350,
                                animationCurve: Curves.easeOut,
                                builder: (context, controller, physics) {
                                  controller.addListener(() {
                                    final offset = controller.offset;
                                    final double newHeight = offset > 0 ? ScreenUtils.kMinHeaderHeight : ScreenUtils.kMaxHeaderHeight;

                                    if (newHeight != _headerHeight && mounted) //
                                      setState(() => _headerHeight = newHeight);
                                  });

                                  // Then use the controller for your scrollable content
                                  return CustomScrollView(
                                    controller: controller,
                                    physics: physics,
                                    slivers: [
                                      SliverToBoxAdapter(
                                        child: widget.content,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
