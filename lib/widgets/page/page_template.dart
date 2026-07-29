import 'dart:math' show min;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../smooth_scroll.dart';

import '../../manager.dart';
import '../../theme.dart';
import '../../screens/settings.dart';
import '../../services/navigation/navigation.dart';
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
  final double? contentRightPadding;
  final Widget? stickyHeader;
  final String? scrollRestorationId;
  final ScrollController? scrollController;

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
    this.contentRightPadding,
    this.cardPadding,
    this.floatingButton,
    this.stickyHeader,
    this.scrollRestorationId,
    this.scrollController,
  }) : assert(
          (scrollableContent || (!scrollableContent && stickyHeader == null)),
          'stickyHeader can only be used when scrollableContent is true',
        );

  @override
  State<MiruRyoikiTemplatePage> createState() => _MiruRyoikiTemplatePageState();
}

class _MiruRyoikiTemplatePageState extends State<MiruRyoikiTemplatePage> {
  late double _headerHeight;
  late double _maxHeaderHeight;
  late double _minHeaderHeight;
  ScrollController? _scrollController;
  bool _scrollRestored = false;
  bool _isHoveringContent = false;
  bool _isHoveringSidebar = false;
  double _futurePosition = 0;
  bool _prevDeltaPositive = false;

  void _handleExternalScroll(PointerScrollEvent event) {
    if (_scrollController == null || !_scrollController!.hasClients) return;
    if (!Manager.animationsEnabled) {
      final position = _scrollController!.position;
      final newOffset = (position.pixels + event.scrollDelta.dy).clamp(position.minScrollExtent, position.maxScrollExtent);
      position.jumpTo(newOffset);
      return;
    }

    final double scrollSpeed = 1.8;
    final bool currentDeltaPositive = event.scrollDelta.dy > 0;
    final position = _scrollController!.position;

    if (position.pixels == position.minScrollExtent || position.pixels == position.maxScrollExtent) {
      _futurePosition = position.pixels;
    }

    if (currentDeltaPositive == _prevDeltaPositive) {
      _futurePosition += event.scrollDelta.dy * scrollSpeed;
    } else {
      _futurePosition = position.pixels + event.scrollDelta.dy * scrollSpeed;
    }
    _prevDeltaPositive = currentDeltaPositive;

    _futurePosition = _futurePosition.clamp(position.minScrollExtent, position.maxScrollExtent);

    if (_futurePosition != position.pixels) {
      _scrollController!.animateTo(
        _futurePosition,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    _headerHeight = widget.headerMaxHeight ?? ScreenUtils.kMaxHeaderHeight;
    _maxHeaderHeight = _headerHeight;
    _minHeaderHeight = widget.headerMinHeight ?? ScreenUtils.kMinHeaderHeight;
    if (widget.scrollableContent && widget.scrollController == null)
      _scrollController = ScrollController();
    else
      _scrollController = widget.scrollController;

    _scrollController?.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    if (_scrollController != null) {
      _scrollController!.removeListener(_onScroll);
      if (widget.scrollController == null) _scrollController!.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(MiruRyoikiTemplatePage oldWidget) {
    if (oldWidget.scrollController != widget.scrollController) {
      _scrollController?.removeListener(_onScroll);
      if (oldWidget.scrollController == null) _scrollController?.dispose();

      if (widget.scrollableContent && widget.scrollController == null)
        _scrollController = ScrollController();
      else
        _scrollController = widget.scrollController;

      _scrollController?.addListener(_onScroll);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onScroll() {
    if (_maxHeaderHeight != _minHeaderHeight && _scrollController != null) {
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
      if (_headerHeight == newHeight) return;

      try {
        setState(() => _headerHeight = newHeight);
      } catch (e) {
        nextFrame(() {
          if (mounted) setState(() => _headerHeight = newHeight);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch AppTheme so this rebuilds if theme colors change (like turning debug green on/off)
    Provider.of<AppTheme>(context);

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
                child: LayoutBuilder(builder: (context, constraints) {
                  Widget buildStack(ScrollController? controller, ScrollPhysics? physics) {
                    return Container(
                      color: Colors.transparent,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Actual page with optional infobar
                          SizedBox(
                            width: ScreenUtils.kMaxContentWidth, // Limit max width for better readability on large screens
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Info bar on the left
                                if (!widget.hideInfoBar)
                                  MouseRegion(
                                    hitTestBehavior: HitTestBehavior.opaque,
                                    onEnter: (_) => _isHoveringSidebar = true,
                                    onExit: (_) => _isHoveringSidebar = false,
                                    // Absorb ALL of the sidebar's scroll-related notifications so they never reach the page Scrollbar below
                                    child: NotificationListener<ScrollMetricsNotification>(
                                      onNotification: (_) => true,
                                      child: NotificationListener<ScrollNotification>(
                                        onNotification: (_) => true,
                                        child: SizedBox(
                                          height: widget.infobarHeight ?? double.infinity,
                                          width: ScreenUtils.kInfoBarWidth,
                                          child: widget.infobar!(widget.noHeaderBanner),
                                        ),
                                      ),
                                    ),
                                  ),
                                // Content area on the right
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 16.0 * Manager.fontSizeMultiplier, top: widget.noHeaderBanner && !widget.enableContentExtraHeaderPadding ? 0.0 : widget.contentExtraHeaderPadding, right: widget.contentRightPadding ?? 16.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
                                        child: SizedBox(
                                          height: widget.contentHeight ?? double.infinity,
                                          child: Builder(builder: (context) {
                                            if (!widget.scrollableContent || controller == null) return widget.content;

                                            final scrollableContent = Builder(
                                              builder: (context) {
                                                final child = ScrollConfiguration(
                                                  behavior: ScrollConfiguration.of(context).copyWith(overscroll: true, platform: TargetPlatform.windows, scrollbars: false),
                                                  child: MouseRegion(
                                                    hitTestBehavior: HitTestBehavior.opaque,
                                                    onEnter: (_) => _isHoveringContent = true,
                                                    onExit: (_) => _isHoveringContent = false,
                                                    child: SmoothScroll(
                                                      controller: _scrollController,
                                                      stopScroll: KeyboardState.ctrlPressedNotifier,
                                                      enableSmoothScroll: Manager.animationsEnabled,
                                                      animationCurve: Curves.easeOut,
                                                      builder: (context, controller, physics) {
                                                        // Register with NavigationManager for scroll offset persistence
                                                        if (widget.scrollRestorationId != null) {
                                                          NavigationManager.registerActiveScrollController(
                                                            widget.scrollRestorationId!,
                                                            controller,
                                                          );

                                                          // Restore saved offset once after the route is created
                                                          if (!_scrollRestored) {
                                                            _scrollRestored = true;
                                                            final savedOffset = NavigationManager.getSavedScrollOffset(widget.scrollRestorationId!);

                                                            if (savedOffset != null && savedOffset > 0) {
                                                              nextFrame(() {
                                                                if (!mounted) return;

                                                                if (controller.hasClients) {
                                                                  final maxExtent = controller.position.maxScrollExtent;
                                                                  controller.jumpTo(savedOffset.clamp(0.0, maxExtent));
                                                                }
                                                              });
                                                            }
                                                          }
                                                        }

                                                        // Then use the controller for your scrollable content
                                                        return CustomScrollView(
                                                          controller: controller,
                                                          physics: physics,
                                                          slivers: [SliverToBoxAdapter(child: widget.content)],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                );
                                                if (widget.wrapContentWithCard) {
                                                  return SettingsCard(
                                                    children: [Expanded(child: child)],
                                                    padding: widget.cardPadding,
                                                  );
                                                }
                                                return child;
                                              },
                                            );

                                            if (widget.stickyHeader != null) {
                                              return Column(
                                                children: [
                                                  widget.stickyHeader!,
                                                  VDiv(16.0),
                                                  Expanded(child: scrollableContent),
                                                ],
                                              );
                                            }
                                            return scrollableContent;
                                          }),
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

                  return SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Listener(
                      behavior: HitTestBehavior.translucent,
                      onPointerSignal: (event) {
                        // Scrolling over the header/margins drives the content scroll;
                        // over the sidebar or content itself, their own scrollables handle it
                        if (widget.scrollableContent && event is PointerScrollEvent && !_isHoveringContent && !_isHoveringSidebar) {
                          _handleExternalScroll(event);
                        }
                      },
                      child: widget.scrollableContent && _scrollController != null
                          ? Scrollbar(
                              controller: _scrollController,
                              child: buildStack(_scrollController, null),
                            )
                          : buildStack(_scrollController, null),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
