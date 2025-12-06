import 'dart:math' show max, min;
import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../../manager.dart';
import '../../services/navigation/shortcuts.dart';
import '../../utils/screen.dart';
import '../../utils/time.dart';
import '../frosted_noise.dart';
import '../gradient_mask.dart';
import 'header_widget.dart';

class SearchTemplatePage extends StatefulWidget {
  final Widget header;
  final Widget content;
  final Color? backgroundColor;
  final double searchBarCollapsedWidth;
  final double searchBarMinCollapsedWidth;
  final double? Function(double maxWidthConstraint)? searchBarMaxCollapsedWidth;
  final double contentExtraHeaderPadding;
  final Widget? floatingButton;
  final ScrollController? scrollController;
  final Widget Function(double? width, double? height, double animationValue) searchBar;

  const SearchTemplatePage({
    super.key,
    required this.header,
    required this.content,
    required this.searchBar,
    this.searchBarCollapsedWidth = 200,
    this.searchBarMinCollapsedWidth = 200,
    this.searchBarMaxCollapsedWidth,
    this.backgroundColor,
    this.contentExtraHeaderPadding = 16.0,
    this.floatingButton,
    this.scrollController,
  });

  @override
  State<SearchTemplatePage> createState() => _SearchTemplatePageState();
}

class _SearchTemplatePageState extends State<SearchTemplatePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAxisCurve;
  late Animation<double> _xAxisCurve;
  
  /// Indicates whether the page is currently scrolled down (not at top)
  bool _isScrolled = false;

  double _lastPixels = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _yAxisCurve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeOutCubic,
    );

    _xAxisCurve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInCubic,
      reverseCurve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleScroll(bool scrolled) {
    if (_isScrolled != scrolled) {
      setState(() => _isScrolled = scrolled);
      scrolled ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
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
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, outerConstraints) => FrostedNoise(
            intensity: 0.25,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  SizedBox(
                    width: ScreenUtils.kMaxContentWidth,
                    child: LayoutBuilder(builder: (context, constraints) {
                      final screenHeight = constraints.maxHeight;
                      final screenWidth = constraints.maxWidth;
                      final topPadding = 0;

                      final double collapsedWidth = max(widget.searchBarCollapsedWidth, widget.searchBarMinCollapsedWidth);
                      const double expandedHeight = 60.0;
                      const double collapsedHeight = 40.0;

                      // Positions
                      final double startWidth = screenWidth * 0.85;
                      final double endWidth = collapsedWidth;
                      final double startTop = (screenHeight / 1.5) - expandedHeight; // height searchbar - centered
                      final double endTop = topPadding + 36; // height searchbar - top right
                      final double startRight = (screenWidth - startWidth) / 2;
                      final double endRight = 16.0;

                      final double contentPaddingStartTop = (screenHeight / 2) + 280; // content top padding - centered
                      final double contentPaddingEndTop = 56 + topPadding + 100; // content top padding - top right
                      final double contentPaddingTop = _isScrolled ? contentPaddingEndTop : contentPaddingStartTop; // content top padding

                      // THRESHOLD CONFIGURATION
                      // How many pixels "early" do you want to trigger the expansion when scrolling up?
                      const double expansionThreshold = 100.0;

                      return Stack(
                        children: [
                          SizedBox(
                            width: ScreenUtils.kMaxContentWidth,
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (notification) {
                                // We only care about updates that change scroll position
                                if (notification is ScrollUpdateNotification) {
                                  final currentPixels = notification.metrics.pixels;

                                  // 1. Determine Direction
                                  final isScrollingDown = currentPixels > _lastPixels;
                                  final isScrollingUp = currentPixels < _lastPixels;

                                  // Update tracker for next frame
                                  _lastPixels = currentPixels;

                                  // 2. LOGIC

                                  // SCENARIO A: Scrolling DOWN (Leaving top)
                                  // Trigger: Immediate collapse as soon as we leave 0
                                  if (isScrollingDown && currentPixels > 0 && !_isScrolled) {
                                    _handleScroll(true);
                                  }

                                  // SCENARIO B: Scrolling UP (Returning to top)
                                  // Trigger: Early expansion if we are within the threshold
                                  else if (isScrollingUp && currentPixels < expansionThreshold && _isScrolled) {
                                    _handleScroll(false);
                                  }

                                  // SCENARIO C: Bounce safety
                                  // If we hit 0 or negative (iOS bounce), strictly ensure we are expanded
                                  else if (currentPixels <= 0 && _isScrolled) {
                                    _handleScroll(false);
                                  }
                                }
                                return false;
                              },
                              child: FadingEdgeScrollView(
                                fadeEdges: const EdgeInsets.symmetric(vertical: 132.0),
                                gradientColors: [
                                  Colors.black.withOpacity(0),
                                  Colors.black.withOpacity(0.1),
                                  Colors.black,
                                  Colors.black,
                                  Colors.black,
                                  Colors.black,
                                ],
                                gradientStops: [
                                  0.08,
                                  0.09,
                                  0.11,
                                  0.80,
                                  0.885,
                                  0.9,
                                ],
                                child: SizedBox(
                                  width: ScreenUtils.kMaxContentWidth,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 16.0 * Manager.fontSizeMultiplier, top: widget.contentExtraHeaderPadding, right: 4.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
                                      child: ScrollConfiguration(
                                        behavior: ScrollConfiguration.of(context).copyWith(overscroll: true, platform: TargetPlatform.windows, scrollbars: false),
                                        child: DynMouseScroll(
                                          controller: widget.scrollController,
                                          stopScroll: KeyboardState.ctrlPressedNotifier,
                                          scrollSpeed: 1.0,
                                          enableSmoothScroll: Manager.animationsEnabled,
                                          durationMS: 350,
                                          animationCurve: Curves.easeOutQuint,
                                          builder: (context, controller, physics) {
                                            return ValueListenableBuilder(
                                              valueListenable: KeyboardState.ctrlPressedNotifier,
                                              builder: (context, isCtrlPressed, _) {
                                                return CustomScrollView(
                                                  controller: controller,
                                                  physics: physics,
                                                  slivers: [
                                                    SliverToBoxAdapter(
                                                      child: AnimatedContainer(
                                                        duration: !_isScrolled ? _controller.reverseDuration! : _controller.duration!,
                                                        curve: Curves.easeInOutCubic,
                                                        height: contentPaddingTop,
                                                      ),
                                                    ),
                                                    SliverToBoxAdapter(child: widget.content),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          HeaderCenterInPageWidget(
                            top: topPadding + 36,
                            title: (titleStyle, _) => widget.header,
                            constraints: constraints,
                            titleLeftAligned: true,
                          ),
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              final currentTop = lerpDouble(startTop, endTop, _yAxisCurve.value);
                              final currentRight = lerpDouble(startRight, endRight, _xAxisCurve.value);
                              final currentWidth = min(lerpDouble(startWidth, endWidth, _controller.value)!, widget.searchBarMaxCollapsedWidth?.call(constraints.maxWidth) ?? double.infinity);
                              final currentHeight = lerpDouble(expandedHeight, collapsedHeight, _controller.value);

                              return Positioned(
                                top: currentTop,
                                right: currentRight,
                                child: widget.searchBar(currentWidth, currentHeight, _controller.value),
                              );
                            },
                          ),
                        ],
                      );
                    }),
                  ),
                  if (widget.floatingButton != null)
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: min(ScreenUtils.kMaxContentWidth + 100, outerConstraints.maxWidth),
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0), // to always keep some space from the right edge when the screen is smaller than max content width
                          child: widget.floatingButton!,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ));
  }
}
