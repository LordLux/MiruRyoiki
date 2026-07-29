import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:silky_scroll/silky_scroll.dart';

/// Smooth mouse-wheel scrolling with a runtime opt-out.
///
/// Thin wrapper over [SilkyScroll] that adds the one capability it lacks: an
/// [enableSmoothScroll] switch, so the app can honour `Manager.animationsEnabled`.
/// When smooth scrolling is off the builder receives a plain controller and
/// bouncing physics, i.e. ordinary native scrolling with no interpolation —
/// matching the behaviour of the `dyn_mouse_scroll` fork this replaces.
///
/// The builder signature is deliberately identical to that fork's, so migrating
/// call sites was a rename.
class SmoothScroll extends StatefulWidget {
  const SmoothScroll({
    super.key,
    this.controller,
    this.scrollSpeed = 2.5,
    this.durationMS = 350,
    this.animationCurve = Curves.easeOutQuint,
    this.enableSmoothScroll = true,
    this.direction = Axis.vertical,
    this.stopScroll,
    required this.builder,
  });

  /// Scroll controller to drive. If null, one is created and owned internally.
  final ScrollController? controller;

  /// Wheel-delta multiplier.
  final double scrollSpeed;

  /// Duration of the smooth-scroll animation, in milliseconds.
  final int durationMS;

  /// Easing applied to the smooth-scroll animation.
  final Curve animationCurve;

  /// When false, falls back to native scrolling with no interpolation.
  final bool enableSmoothScroll;

  /// Axis the scrollable built by [builder] scrolls along.
  final Axis direction;

  /// While this listenable is true, [builder] receives
  /// [NeverScrollableScrollPhysics] instead of the usual physics.
  ///
  /// Used to hold the view still during ctrl+wheel zoom (see
  /// `KeyboardState.ctrlPressedNotifier`), which would otherwise zoom and scroll
  /// at the same time. Some call sites additionally do this themselves further
  /// down their widget tree; several rely solely on this.
  final ValueListenable<bool>? stopScroll;

  /// Builds the scrollable, receiving the controller and physics to apply.
  final Widget Function(BuildContext context, ScrollController controller, ScrollPhysics physics) builder;

  @override
  State<SmoothScroll> createState() => _SmoothScrollState();
}

class _SmoothScrollState extends State<SmoothScroll> {
  /// Only created when smooth scrolling is off and no controller was supplied;
  /// otherwise SilkyScroll provides one.
  ScrollController? _ownedController;

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  /// Runs [widget.builder], swapping in non-scrollable physics while
  /// [widget.stopScroll] is true. Mirrors what the previous fork did.
  Widget _build(BuildContext context, ScrollController controller, ScrollPhysics physics) {
    final stopScroll = widget.stopScroll;
    if (stopScroll == null) return widget.builder(context, controller, physics);

    return ValueListenableBuilder<bool>(
      valueListenable: stopScroll,
      builder: (context, shouldStop, _) => widget.builder(
        context,
        controller,
        shouldStop ? const NeverScrollableScrollPhysics() : physics,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableSmoothScroll) {
      final controller = widget.controller ?? (_ownedController ??= ScrollController());
      return _build(context, controller, const BouncingScrollPhysics());
    }

    return SilkyScroll(
      controller: widget.controller,
      scrollSpeed: widget.scrollSpeed,
      silkyScrollDuration: Duration(milliseconds: widget.durationMS),
      animationCurve: widget.animationCurve,
      direction: widget.direction,
      builder: _build,
    );
  }
}
