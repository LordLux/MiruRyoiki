import 'dart:math' show max, min;
import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../../manager.dart';
import '../../services/navigation/shortcuts.dart';
import '../../utils/screen.dart';
import '../../utils/time.dart';
import '../frosted_noise.dart';
import '../fading_edge_scrollview.dart';
import 'header_widget.dart';

double kDefaultSearchBarMinCollapsedWidth(double _) => 200.0;
double kDefaultSearchBarMaxCollapsedWidth(double maxWidthConstraint) => maxWidthConstraint;

enum SearchBarStatus { automatic, collapsed, expanded }

class SearchTemplatePage extends StatefulWidget {
  final Widget header;
  final Widget content;
  final Color? backgroundColor;
  final double Function(double maxWidthConstraint) searchBarCollapsedWidth;
  final double Function(double maxWidthConstraint) searchBarMinCollapsedWidth;
  final double Function(double maxWidthConstraint) searchBarMaxCollapsedWidth;
  final double Function(double maxWidthConstraint)? searchBarMinExpandedWidth;
  final double Function(double maxWidthConstraint)? searchBarMaxExpandedWidth;
  final double contentExtraHeaderPadding;
  final Widget? floatingButton;
  final ScrollController? scrollController;
  final Widget Function(double animationValue)? behindSearchBar;
  final Widget Function(double? width, double? height, double animationValue, FocusNode focusNode) searchBar;
  final SearchBarStatus searchBarStatus;

  const SearchTemplatePage({
    super.key,
    required this.header,
    required this.content,
    required this.searchBar,
    this.searchBarCollapsedWidth = kDefaultSearchBarMinCollapsedWidth,
    this.searchBarMinCollapsedWidth = kDefaultSearchBarMinCollapsedWidth,
    this.searchBarMaxCollapsedWidth = kDefaultSearchBarMaxCollapsedWidth,
    this.searchBarMinExpandedWidth,
    this.searchBarMaxExpandedWidth,
    this.backgroundColor,
    this.contentExtraHeaderPadding = 0.0,
    this.floatingButton,
    this.scrollController,
    this.behindSearchBar,
    this.searchBarStatus = SearchBarStatus.automatic,
  });

  @override
  State<SearchTemplatePage> createState() => _SearchTemplatePageState();
}

class _SearchTemplatePageState extends State<SearchTemplatePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAxisCurve;
  late Animation<double> _xAxisCurve;
  final FocusNode _searchBarFocusNode = FocusNode();

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

    if (widget.searchBarStatus == SearchBarStatus.collapsed) {
      _isScrolled = true;
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(SearchTemplatePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchBarStatus != oldWidget.searchBarStatus) {
      if (widget.searchBarStatus == SearchBarStatus.collapsed) {
        _handleScroll(true);
      } else if (widget.searchBarStatus == SearchBarStatus.expanded) {
        _handleScroll(false);
      }
    }
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
              child: Builder(builder: (context) {
                Widget searchbarBuilder({required Widget Function(double currentWidth, double currentHeight, double animationValue) child, required double startTop, required double endTop, required double startRight, required double endRight, required double startWidth, required double endWidth, required double expandedHeight, required double collapsedHeight}) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final currentTop = lerpDouble(startTop, endTop, _yAxisCurve.value)!;
                      final currentRight = lerpDouble(startRight, endRight, _xAxisCurve.value)!;
                      final currentWidth = lerpDouble(startWidth, endWidth, _controller.value)!;
                      final currentHeight = lerpDouble(expandedHeight, collapsedHeight, _controller.value)!;

                      return Positioned(
                        top: currentTop,
                        right: currentRight,
                        width: currentWidth,
                        child: child.call(currentWidth, currentHeight, _controller.value),
                      );
                    },
                  );
                }

                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    SizedBox(
                      width: min(ScreenUtils.kMaxContentWidth, outerConstraints.maxWidth),
                      child: LayoutBuilder(builder: (context, constraints) {
                        final screenHeight = constraints.maxHeight;
                        final screenWidth = constraints.maxWidth;
                        final topPadding = 0;

                        // Expanded Width Logic
                        final double minExpanded = widget.searchBarMinExpandedWidth?.call(screenWidth) ?? 0.0;
                        final double maxExpanded = widget.searchBarMaxExpandedWidth?.call(screenWidth) ?? double.infinity;
                        final double maxAllowedExpanded = screenWidth * 0.85;

                        double startWidth = (screenWidth * 0.85).clamp(minExpanded, maxExpanded);
                        if (startWidth > maxAllowedExpanded) startWidth = maxAllowedExpanded;

                        // Collapsed Width Logic
                        final double minCollapsed = widget.searchBarMinCollapsedWidth(screenWidth);
                        final double maxCollapsed = widget.searchBarMaxCollapsedWidth(screenWidth);
                        final double maxAllowedCollapsed = screenWidth * 0.5;

                        double endWidth = widget.searchBarCollapsedWidth(screenWidth).clamp(minCollapsed, maxCollapsed);
                        if (endWidth > maxAllowedCollapsed) endWidth = maxAllowedCollapsed;

                        const double expandedHeight = 60.0;
                        const double collapsedHeight = 40.0;

                        // Positions
                        final double startTop = (screenHeight / 3) - expandedHeight; // height searchbar - centered
                        final double endTop = topPadding + 36; // height searchbar - top right
                        final double startRight = (screenWidth - startWidth) / 2;
                        final double endRight = 16.0;

                        final double contentPaddingStartTop = (screenHeight / 2) + 0; // content top padding - centered
                        final double contentPaddingEndTop = 56 + topPadding + 126; // content top padding - top right
                        final double contentPaddingEndTopAlt = 56 + topPadding + 40; // content top padding - top right
                        final double contentPaddingTop = _isScrolled ? (widget.searchBarStatus == SearchBarStatus.collapsed ? contentPaddingEndTopAlt : contentPaddingEndTop) : contentPaddingStartTop; // content top padding

                        // THRESHOLD CONFIGURATION
                        // How many pixels "early" do you want to trigger the expansion when scrolling up?
                        const double expansionThreshold = 100.0;

                        return Stack(
                          children: [
                            // Background behind search bar
                            if (widget.behindSearchBar != null)
                              AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) {
                                  final extraTop = -600;
                                  final currentTop = lerpDouble(startTop + extraTop, (endTop + extraTop) / 2, _yAxisCurve.value);

                                  return Positioned.fill(
                                    top: currentTop,
                                    child: widget.behindSearchBar!(_controller.value),
                                  );
                                },
                              ),

                            // Content with scroll listener
                            SizedBox(
                              width: constraints.maxWidth,
                              child: NotificationListener<ScrollNotification>(
                                onNotification: (notification) {
                                  if (widget.searchBarStatus != SearchBarStatus.automatic) return false;

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

                            // Search Bar
                            searchbarBuilder(
                              child: (currentWidth, currentHeight, animationValue) => widget.searchBar(currentWidth, currentHeight, animationValue, _searchBarFocusNode),
                              startTop: startTop,
                              endTop: endTop,
                              startRight: startRight,
                              endRight: endRight,
                              startWidth: startWidth,
                              endWidth: endWidth,
                              expandedHeight: expandedHeight,
                              collapsedHeight: collapsedHeight,
                            ),
                            // Header
                            HeaderCenterInPageWidget(
                              top: topPadding + 36,
                              title: (titleStyle, _) => widget.header,
                              constraints: constraints,
                              titleLeftAligned: true,
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
                );
              }),
            ),
          ),
        ));
  }
}
