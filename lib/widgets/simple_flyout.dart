import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'esc.dart';

typedef FlyoutTransitionBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Widget child,
);

/// A simple controller for managing flyout overlays
class SimpleFlyoutController with ChangeNotifier {
  SimpleFlyoutController();

  NavigatorState? _currentNavigator;
  OverlayEntry? _overlayEntry;
  Duration _closingDuration = Duration.zero;
  bool get isOpen => _route != null;
  PageRouteBuilder? _route;
  final GlobalKey<_FlyoutPageState> _barrierColorKey =
      GlobalKey<_FlyoutPageState>();

  void _ensureAttached() {
    assert(isAttached, 'This controller must be attached to a FlyoutTarget');
  }

  _SimpleFlyoutTargetState? _attachState;

  /// Whether this flyout controller is attached to any [SimpleFlyoutTarget]
  bool get isAttached => _attachState != null;

  void _attach(_SimpleFlyoutTargetState state) {
    if (_attachState == state) return;
    if (isAttached) _detach();

    _attachState = state;
  }

  void _detach() {
    _ensureAttached();
    _attachState = null;
  }

  /// Shows a flyout overlay
  Future<void> showFlyout({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    void Function()? onBarrierDismiss,
    bool dismissWithEsc = true,
    bool barrierBlocking = true,
    EdgeInsets barrierMargin = const EdgeInsets.all(0),
    bool dismissOnPointerMoveAway = false,
    Duration closingDuration = Duration.zero,
    Duration transitionDuration = const Duration(milliseconds: 200),
    Duration? reverseTransitionDuration,
    FlyoutTransitionBuilder? transitionBuilder,
    Color? barrierColor,
    double margin = 8.0,
    Offset? position,
  }) async {
    _ensureAttached();
    assert(_attachState!.mounted);

    assert(closingDuration >= Duration.zero);
    _closingDuration = closingDuration;
    reverseTransitionDuration ??= transitionDuration;

    final context = _attachState!.context;

    _currentNavigator = Navigator.of(context);

    final RenderBox navigatorBox =
        _currentNavigator!.context.findRenderObject() as RenderBox;
    final RenderBox targetBox =
        _currentNavigator!.context.findRenderObject() as RenderBox;
    final Size targetSize = targetBox.size;
    final Offset targetOffset = targetBox.localToGlobal(
          Offset.zero,
          ancestor: navigatorBox,
        ) +
        Offset(0, targetSize.height);
    final Rect targetRect = targetBox.localToGlobal(
          Offset.zero,
          ancestor: navigatorBox,
        ) &
        targetSize;

    final GlobalKey flyoutKey = GlobalKey();
    final OverlayState overlay = Overlay.of(_currentNavigator!.context);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return DismissOnEsc(
          onDismiss: closeOverlay,
          child: Builder(builder: (context) {
            transitionBuilder = (context, animation, flyout) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.25),
                    end: const Offset(0, 0),
                  ).animate(animation),
                  child: flyout,
                );
            return _FlyoutPage(
              key: _barrierColorKey,
              navigator: _currentNavigator ?? Navigator.of(context),
              targetRect: targetRect,
              attachState: _attachState,
              targetOffset: targetOffset,
              targetSize: targetSize,
              flyoutKey: flyoutKey,
              navigatorBox: navigatorBox,
              animation: CurvedAnimation(
                  curve: Curves.linear,
                  parent: const AlwaysStoppedAnimation<double>(1)),
              onDismiss: () {
                onBarrierDismiss?.call();
                closeOverlay();
              },
              barrierColor: barrierColor ?? Colors.black.withOpacity(0.3),
              barrierMargin: barrierMargin,
              barrierDismissible: barrierDismissible,
              barrierBlocking: barrierBlocking,
              dismissWithEsc: dismissWithEsc,
              dismissOnPointerMoveAway: dismissOnPointerMoveAway,
              transitionDuration: transitionDuration,
              transitionBuilder: transitionBuilder!,
              reverseTransitionDuration: reverseTransitionDuration,
              builder: builder,
              margin: margin,
              position: position,
            );
          }),
        );
      },
    );

    overlay.insert(_overlayEntry!);
    notifyListeners();
  }

  @override
  void dispose() {
    if (isOpen) close();
    super.dispose();
  }

  void close([bool force = false]) {
    if (!isAttached) return;
    closeOverlay(force);
  }

  void closeOverlay([bool force = false]) {
    if (_overlayEntry != null) {
      if (_barrierColorKey.currentState != null) {
        _barrierColorKey.currentState!.updateBarrierColor(Colors.transparent);
      }
      // Wait for the closingDuration so that the flyout content's closing animation can play.
      Future.delayed(_closingDuration, () {
        if (_overlayEntry != null) {
          _overlayEntry!.remove();
          _overlayEntry = null;
        }
      });
    } else if (_route != null) {
      // fallback if a route was used
      if (force) {
        _currentNavigator!.removeRoute(_route!);
      } else {
        _currentNavigator!.maybePop();
      }
      _route = _currentNavigator = null;
    }
  }
}


/// A toggleable content with animation support for flyouts
class ToggleableFlyoutContent extends StatefulWidget {
  const ToggleableFlyoutContent({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
  });

  final Widget child;
  final Duration duration;

  @override
  State<ToggleableFlyoutContent> createState() =>
      _ToggleableFlyoutContentState();
}

class _ToggleableFlyoutContentState extends State<ToggleableFlyoutContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> close() async {
    await _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(_animation),
        child: widget.child,
      ),
    );
  }
}

class _FlyoutPage extends StatefulWidget {
  const _FlyoutPage({
    super.key,
    required this.navigator,
    required this.targetRect,
    required _SimpleFlyoutTargetState? attachState,
    required this.targetOffset,
    required this.targetSize,
    required this.flyoutKey,
    required this.navigatorBox,
    required this.onDismiss,
    required this.barrierColor,
    required this.barrierMargin,
    required this.barrierBlocking,
    required this.barrierDismissible,
    required this.dismissWithEsc,
    required this.dismissOnPointerMoveAway,
    required this.margin,
    required this.transitionBuilder,
    required this.animation,
    required this.transitionDuration,
    required this.reverseTransitionDuration,
    required this.position,
    required this.builder,
  });

  final NavigatorState navigator;
  final Rect targetRect;
  final Offset targetOffset;
  final Size targetSize;
  final GlobalKey<State<StatefulWidget>> flyoutKey;
  final RenderBox navigatorBox;
  final Color? barrierColor;
  final EdgeInsets barrierMargin;
  final bool barrierBlocking;
  final bool barrierDismissible;
  final void Function() onDismiss;
  final bool dismissWithEsc;
  final bool dismissOnPointerMoveAway;
  final double margin;
  final FlyoutTransitionBuilder transitionBuilder;
  final Animation<double> animation;
  final Duration? transitionDuration;
  final Duration? reverseTransitionDuration;
  final Offset? position;
  final WidgetBuilder builder;

  @override
  State<_FlyoutPage> createState() => _FlyoutPageState();
}

class _FlyoutPageState extends State<_FlyoutPage> {
  Color _barrierColor = Colors.transparent;

  final _key = GlobalKey<State>();

  @override
  void initState() {
    super.initState();
    _updateBarrierColor();
  }

  void _updateBarrierColor() async {
    await Future.delayed(
        (widget.transitionDuration ?? const Duration(milliseconds: 200)) ~/ 2);
    setState(() {
      _barrierColor =
          widget.barrierColor ?? Colors.black.withValues(alpha: 0.3);
    });
  }

  void updateBarrierColor(Color color) {
    setState(() {
      _barrierColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MenuInfoProvider(builder: (context, _, menus, keys) {
      assert(menus.length == keys.length);

      final barrier = AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: _barrierColor,
      );

      Widget box = Stack(children: [
        if (widget.barrierDismissible)
          Positioned(
            top: widget.barrierMargin.top,
            right: widget.barrierMargin.right,
            bottom: widget.barrierMargin.bottom,
            left: widget.barrierMargin.left,
            child: GestureDetector(
              behavior: widget.barrierBlocking
                  ? HitTestBehavior.opaque
                  : HitTestBehavior.deferToChild,
              onTap: widget.barrierDismissible ? widget.onDismiss : null,
              child: barrier,
            ),
          ),
        Positioned.fill(
          child: SafeArea(
            child: CustomSingleChildLayout(
              delegate: _FlyoutPositionDelegate(
                targetOffset: widget.position ?? widget.targetOffset,
                targetSize:
                    widget.position == null ? widget.targetSize : Size.zero,
                margin: widget.margin,
              ),
              child: StatefulBuilder(
                key: _key,
                builder: (context, setState) {
                  return SimpleFlyout(
                    rootFlyout: widget.flyoutKey,
                    additionalOffset: 8.0,
                    margin: widget.margin,
                    transitionDuration: widget.transitionDuration!,
                    reverseTransitionDuration:
                        widget.reverseTransitionDuration!,
                    root: widget.navigator,
                    menuKey: null,
                    transitionBuilder: widget.transitionBuilder,
                    builder: (context) {
                      Widget flyout = Padding(
                        key: widget.flyoutKey,
                        padding: EdgeInsets.zero,
                        child: widget.builder(context),
                      );

                      return widget.transitionBuilder(
                        context,
                        widget.animation,
                        flyout,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
        ...menus,
      ]);

      if (widget.dismissOnPointerMoveAway) {
        box = MouseRegion(
          onHover: (hover) {
            if (widget.flyoutKey.currentContext == null) return;

            final navigatorBox =
                widget.navigator.context.findRenderObject() as RenderBox;

            // the flyout box needs to be fetched at each [onHover] because the
            // flyout size may change (a MenuFlyout, for example)
            final flyoutBox = widget.flyoutKey.currentContext!
                .findRenderObject() as RenderBox;
            final flyoutRect = flyoutBox.localToGlobal(
                  Offset.zero,
                  ancestor: navigatorBox,
                ) &
                flyoutBox.size;
            final menusRects = keys.map((key) {
              if (key.currentContext == null) return Rect.zero;

              final menuBox =
                  key.currentContext!.findRenderObject() as RenderBox;
              return menuBox.localToGlobal(
                    Offset.zero,
                    ancestor: navigatorBox,
                  ) &
                  menuBox.size;
            });

            if (!flyoutRect.contains(hover.position) &&
                !widget.targetRect.contains(hover.position) &&
                !menusRects.any((rect) => rect.contains(hover.position))) {
              widget.onDismiss();
            }
          },
          child: box,
        );
      }

      if (widget.dismissWithEsc) {
        box = Actions(
          actions: {
            DismissIntent: _DismissAction(() {
              widget.onDismiss();
            })
          },
          child: FocusScope(
            autofocus: true,
            child: box,
          ),
        );
      }

      return FadeTransition(
        opacity: CurvedAnimation(
          curve: Curves.ease,
          parent: widget.animation,
        ),
        child: box,
      );
    });
  }
}

class _FlyoutPositionDelegate extends SingleChildLayoutDelegate {
  /// Creates a delegate for computing the layout of a flyout.
  ///
  /// The arguments must not be null.
  _FlyoutPositionDelegate({
    required this.targetOffset,
    required this.targetSize,
    required this.margin,
  });

  final Offset targetOffset;
  final Size targetSize;

  final double margin;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.loosen();
  }

  @override
  Offset getPositionForChild(Size rootSize, Size flyoutSize) {
    double clampHorizontal(double x) {
      final max = rootSize.width - flyoutSize.width - margin;

      return clampDouble(
        x,
        clampDouble(margin, double.negativeInfinity, max),
        max,
      );
    }

    double clampVertical(double y) {
      return clampDouble(
        y,
        margin,
        (rootSize.height - flyoutSize.height - margin).clamp(
          margin,
          rootSize.height - margin,
        ),
      );
    }

    final topY = clampVertical(
      targetOffset.dy - targetSize.height - flyoutSize.height,
    );

    final centerX = clampHorizontal(
      (targetOffset.dx + targetSize.width / 2) - (flyoutSize.width / 2.0),
    );

    return Offset(centerX, topY); // or targetOffset
  }

  @override
  bool shouldRelayout(covariant _FlyoutPositionDelegate oldDelegate) {
    return targetOffset != oldDelegate.targetOffset;
  }
}

/// See also:
///
///  * [FlyoutController], the controller that displays a flyout attached to the
///    given [child]
class SimpleFlyoutTarget extends StatefulWidget {
  /// The controller that displays a flyout attached to the given [child]
  final SimpleFlyoutController controller;

  /// The flyout target widget. Flyouts are displayed attached to this
  final Widget child;

  /// Creates a flyout target
  const SimpleFlyoutTarget({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<SimpleFlyoutTarget> createState() => _SimpleFlyoutTargetState();
}

class _SimpleFlyoutTargetState extends State<SimpleFlyoutTarget> {
  @override
  Widget build(BuildContext context) {
    widget.controller._attach(this);
    return widget.child;
  }
}

class _DismissAction extends DismissAction {
  _DismissAction(this.onDismiss);

  final VoidCallback onDismiss;

  @override
  Object? invoke(covariant DismissIntent intent) {
    onDismiss();
    return null;
  }
}

/// Stores info about the current flyout, such as positioning, sub menus and transitions
///
/// See also:
///
///  * [FlyoutAttach], which the flyout is displayed attached to
class SimpleFlyout extends StatefulWidget {
  final WidgetBuilder builder;

  final NavigatorState? root;
  final GlobalKey? rootFlyout;
  final GlobalKey? menuKey;

  final double additionalOffset;
  final double margin;

  final Duration transitionDuration;
  final Duration reverseTransitionDuration;

  final FlyoutTransitionBuilder transitionBuilder;

  /// Create a flyout.
  const SimpleFlyout({
    super.key,
    required this.builder,
    required this.root,
    required this.rootFlyout,
    required this.menuKey,
    required this.additionalOffset,
    required this.margin,
    required this.transitionDuration,
    required this.reverseTransitionDuration,
    required this.transitionBuilder,
  });

  /// Gets the current flyout info
  static SimpleFlyoutState of(BuildContext context) {
    return context.findAncestorStateOfType<SimpleFlyoutState>()!;
  }

  static SimpleFlyoutState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<SimpleFlyoutState>();
  }

  @override
  State<SimpleFlyout> createState() => SimpleFlyoutState();
}

class SimpleFlyoutState extends State<SimpleFlyout> {
  final _key = GlobalKey(debugLabel: 'FlyoutState key');

  /// The flyout in the beggining of the flyout tree
  GlobalKey get rootFlyout => widget.rootFlyout!;

  /// How far the flyout should be from the target
  double get additionalOffset => widget.additionalOffset;

  /// How far the flyout should be from the screen
  double get margin => widget.margin;

  /// The duration of the transition animation
  Duration get transitionDuration => widget.transitionDuration;

  /// The duration of the reverse transition animation
  Duration get reverseTransitionDuration => widget.reverseTransitionDuration;

  /// The transition builder
  FlyoutTransitionBuilder get transitionBuilder => widget.transitionBuilder;

  /// Closes the current open flyout.
  ///
  /// If the current flyout is a sub menu, the submenu is closed.
  void close() {
    if (widget.menuKey != null) {
      MenuInfoProvider.of(context).remove(widget.menuKey!);
      return;
    }
    final parent = SimpleFlyout.maybeOf(context);

    final navigatorKey = parent?.widget.root ?? widget.root;
    assert(navigatorKey != null, 'The flyout is not open');

    navigatorKey!.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: Builder(builder: widget.builder),
    );
  }
}

typedef MenuBuilder = Widget Function(
  BuildContext context,
  BoxConstraints rootSize,
  Iterable<Widget> menus,
  Iterable<GlobalKey> keys,
);

class MenuInfoProvider extends StatefulWidget {
  final MenuBuilder builder;

  @protected
  const MenuInfoProvider({super.key, required this.builder});

  /// Gets the current state of the sub menus of the root flyout
  static MenuInfoProviderState of(BuildContext context) {
    return context.findAncestorStateOfType<MenuInfoProviderState>()!;
  }

  /// Gets the current state of the sub menus of the root flyout
  static MenuInfoProviderState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<MenuInfoProviderState>();
  }

  @override
  State<MenuInfoProvider> createState() => MenuInfoProviderState();
}

class MenuInfoProviderState extends State<MenuInfoProvider> {
  final _menus = <GlobalKey, Widget>{};

  /// Inserts a sub menu in the tree. If already existing, it's updated with the
  /// provided [menu]
  void add(Widget menu, GlobalKey key) {
    setState(() => _menus[key] = menu);
  }

  /// Removes any sub menu from the flyout tree
  void remove(GlobalKey key) {
    if (contains(key)) setState(() => _menus.remove(key));
  }

  /// Whether then given sub menu is present in the tree
  bool contains(GlobalKey key) {
    return _menus.containsKey(key);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return widget.builder(
        context,
        constraints,
        _menus.values,
        _menus.keys,
      );
    });
  }
}
