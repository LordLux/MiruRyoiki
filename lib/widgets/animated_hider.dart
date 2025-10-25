import 'package:flutter/material.dart';

class AnimatedHider extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  final bool shouldShowChild;

  const AnimatedHider({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.switchInCurve = Curves.easeInOut,
    this.switchOutCurve = Curves.easeInOut,
    this.shouldShowChild = true,
  });

  @override
  State<StatefulWidget> createState() => _AnimatedHiderState();
}

class _AnimatedHiderState extends State<AnimatedHider> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.duration,
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        axisAlignment: -1,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: widget.shouldShowChild ? widget.child : const SizedBox.shrink(),
    );
  }
}
