import 'dart:math' show min;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../../manager.dart';
import '../../screens/settings.dart';
import '../../services/navigation/shortcuts.dart';
import '../../utils/screen.dart';
import '../../utils/time.dart';
import '../frosted_noise.dart';
import 'header_widget.dart';
import 'infobar.dart';

class MiruRyoikiTemplatePage extends StatefulWidget {
  final HeaderWidget headerWidget;
  final MiruRyoikiInfobar Function(bool noHeaderBanner)? infobar;
  final Widget content;
  final Color? backgroundColor;
  final bool hideInfoBar;
  final bool noHeaderBanner;
  final double? headerMaxHeight;
  final double? headerMinHeight;
  final bool scrollableContent;
  final bool enableContentExtraHeaderPadding;
  final double contentExtraHeaderPadding;
  final VoidCallback? onHeaderCollapse;
  final VoidCallback? onHeaderExpand;
  final double? infobarHeight;
  final double? contentHeight;
  final bool wrapContentWithCard;
  final EdgeInsets? cardPadding;
  final Widget? floatingButton;

  const MiruRyoikiTemplatePage({
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
    this.enableContentExtraHeaderPadding = false,
    this.contentExtraHeaderPadding = 16.0,
    this.onHeaderCollapse,
    this.onHeaderExpand,
    this.infobarHeight,
    this.contentHeight,
    this.wrapContentWithCard = false,
    this.cardPadding,
    this.floatingButton,
  });

  @override
  State<MiruRyoikiTemplatePage> createState() => _MiruRyoikiTemplatePageState();
}

class _MiruRyoikiTemplatePageState extends State<MiruRyoikiTemplatePage> {
  late double _headerHeight;
  late double _maxHeaderHeight;
  late double _minHeaderHeight;
  ScrollController? _scrollController;

  @override
  void initState() {
    _headerHeight = widget.headerMaxHeight ?? ScreenUtils.kMaxHeaderHeight;
    _maxHeaderHeight = _headerHeight;
    _minHeaderHeight = widget.headerMinHeight ?? ScreenUtils.kMinHeaderHeight;
    super.initState();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    if (_maxHeaderHeight != _minHeaderHeight && _scrollController != null) {
      _scrollController!.addListener(() {
        final offset = _scrollController!.offset;
        final double newHeight;
        if (offset > 0) {
          newHeight = _minHeaderHeight;
          widget.onHeaderCollapse?.call();
        } else {
          newHeight = _maxHeaderHeight;
          widget.onHeaderExpand?.call();
        }

        if (!mounted) return;

        try {
          setState(() => _headerHeight = newHeight);
        } catch (e) {
          nextFrame(() {
            if (mounted) setState(() => _headerHeight = newHeight);
          });
        }
      });
    }
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
            widget.backgroundColor ?? Manager.accentColor.withOpacity(0.35),
            Colors.transparent,
          ],
        ),
      ),
      child: FrostedNoise(
        intensity: 0.25,
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: ScreenUtils.kMaxContentWidth,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Info bar on the left
                                if (!widget.hideInfoBar)
                                  SizedBox(
                                    height: widget.infobarHeight ?? double.infinity,
                                    width: ScreenUtils.kInfoBarWidth,
                                    child: widget.infobar!(widget.noHeaderBanner),
                                  ),
                                // Content area on the right
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 16.0 * Manager.fontSizeMultiplier, top: widget.noHeaderBanner && !widget.enableContentExtraHeaderPadding ? 0.0 : widget.contentExtraHeaderPadding, right: 4.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
                                        child: SizedBox(
                                          height: widget.contentHeight ?? double.infinity,
                                          child: Builder(
                                            builder: (context) {
                                              if (!widget.scrollableContent) return widget.content;
                    
                                              final child = ScrollConfiguration(
                                                behavior: ScrollConfiguration.of(context).copyWith(overscroll: true, platform: TargetPlatform.windows, scrollbars: false),
                                                child: DynMouseScroll(
                                                  stopScroll: KeyboardState.ctrlPressedNotifier,
                                                  scrollSpeed: 1.8,
                                                  enableSmoothScroll: Manager.animationsEnabled,
                                                  durationMS: 350,
                                                  animationCurve: Curves.easeOut,
                                                  builder: (context, controller, physics) {
                                                    // Skip if we want a static header
                                                    _scrollController = controller;
                                                    if (_scrollController != null) _setupScrollListener();
                    
                                                    // Then use the controller for your scrollable content
                                                    return CustomScrollView(
                                                      controller: controller,
                                                      physics: physics,
                                                      slivers: [SliverToBoxAdapter(child: widget.content)],
                                                    );
                                                  },
                                                ),
                                              );
                                              if (widget.wrapContentWithCard)
                                                return SettingsCard(
                                                  children: [Expanded(child: child)],
                                                  padding: widget.cardPadding,
                                                );
                                              return child;
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
                          if (widget.floatingButton != null)
                            Positioned(
                              bottom: 0,
                              child: Container(
                                width: min(ScreenUtils.kMaxContentWidth + 100, constraints.maxWidth),
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0), // to always keep some space from the right edge when the screen is smaller than max content width
                                  child: widget.floatingButton!,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
