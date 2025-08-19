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
  final MiruRyoikiInfobar Function(bool noHeaderBanner)? infobar;
  final Widget content;
  final Color? backgroundColor;
  final bool hideInfoBar;
  final bool noHeaderBanner;
  final double? headerMaxHeight;
  final double? headerMinHeight;
  final bool scrollableContent;

  const MiruRyoikiHeaderInfoBarPage({
    super.key,
    required this.headerWidget,
    this.infobar,
    required this.content,
    this.backgroundColor,
    this.hideInfoBar = false,
    this.noHeaderBanner = false,
    this.headerMaxHeight = ScreenUtils.kMaxHeaderHeight,
    this.headerMinHeight = ScreenUtils.kMinHeaderHeight,
    this.scrollableContent = true,
  });

  @override
  State<MiruRyoikiHeaderInfoBarPage> createState() => _MiruRyoikiHeaderInfoBarPageState();
}

class _MiruRyoikiHeaderInfoBarPageState extends State<MiruRyoikiHeaderInfoBarPage> {
  late double _headerHeight;
  late double _maxHeaderHeight;
  late double _minHeaderHeight;

  @override
  void initState() {
    _headerHeight = widget.headerMaxHeight ?? ScreenUtils.kMaxHeaderHeight;
    _maxHeaderHeight = _headerHeight;
    _minHeaderHeight = widget.headerMinHeight ?? ScreenUtils.kMinHeaderHeight;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.hideInfoBar || widget.infobar != null, 'infobar must not be null if hideInfoBar is false');
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
                        child: widget.infobar!(widget.noHeaderBanner),
                      ),

                    // Content area on the right
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(left: 16.0 * Manager.fontSizeMultiplier, top: widget.noHeaderBanner ? 0.0 : 16.0, right: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
                            child: Builder(builder: (context) {
                              if (!widget.scrollableContent) return widget.content;

                              return ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context).copyWith(overscroll: true, platform: TargetPlatform.windows, scrollbars: false),
                                child: DynMouseScroll(
                                  stopScroll: KeyboardState.ctrlPressedNotifier,
                                  scrollSpeed: 1.8,
                                  enableSmoothScroll: Manager.animationsEnabled,
                                  durationMS: 350,
                                  animationCurve: Curves.easeOut,
                                  builder: (context, controller, physics) {
                                    // Skip if we want a static header
                                    if (_maxHeaderHeight != _minHeaderHeight) {
                                    controller.addListener(() {
                                      final offset = controller.offset;
                                      final double newHeight = offset > 0 ? _minHeaderHeight : _maxHeaderHeight;

                                      if (mounted) setState(() => _headerHeight = newHeight);
                                    });
                                    }

                                    // Then use the controller for your scrollable content
                                    return CustomScrollView(
                                      controller: controller,
                                      physics: physics,
                                      slivers: [SliverToBoxAdapter(child: widget.content)],
                                    );
                                  },
                                ),
                              );
                            }),
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
