import 'package:flutter/material.dart' as mat;

class AnimatedSwitcher extends mat.StatefulWidget {
  final mat.Widget child;
  final Duration duration;
  final mat.Curve switchInCurve;
  final mat.Curve switchOutCurve;
  final bool showChild;

  const AnimatedSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.switchInCurve = mat.Curves.easeInOut,
    this.switchOutCurve = mat.Curves.easeInOut,
    this.showChild = true,
  });

  @override
  mat.State<mat.StatefulWidget> createState() => _AnimatedSwitcherState();
}

class _AnimatedSwitcherState extends mat.State<AnimatedSwitcher> {
  @override
  mat.Widget build(mat.BuildContext context) {
    return mat.AnimatedSwitcher(
      duration: widget.duration,
      transitionBuilder: (child, animation) => mat.SizeTransition(
        sizeFactor: animation,
        axisAlignment: -1,
        child: mat.FadeTransition(opacity: animation, child: child),
      ),
      child: widget.showChild ? widget.child : const mat.SizedBox.shrink(),
    );
  }
}
