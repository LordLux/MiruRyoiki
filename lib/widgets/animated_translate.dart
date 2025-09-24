import 'package:flutter/material.dart';

class AnimatedTranslate extends ImplicitlyAnimatedWidget {
  /// The position to translate the child to in logical pixels.
  final Offset offset;

  /// The widget below this widget in the tree.
  final Widget child;

  /// Creates a widget that animates its translation to a new position.
  const AnimatedTranslate({
    super.key,
    required this.offset,
    required super.duration,
    required this.child,
    super.curve,
  });

  @override
  ImplicitlyAnimatedWidgetState<AnimatedTranslate> createState() => _AnimatedTranslateState();
}

class _AnimatedTranslateState extends AnimatedWidgetBaseState<AnimatedTranslate> {
  Tween<Offset>? _offsetTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    // A function that returns the result of the visitor
    _offsetTween = visitor(
      _offsetTween,
      widget.offset,
      (dynamic value) => Tween<Offset>(begin: value as Offset),
    ) as Tween<Offset>?;
  }

  @override
  Widget build(BuildContext context) {
    final animation = controller;
    final currentOffset = _offsetTween?.evaluate(animation) ?? widget.offset;

    return Transform.translate(
      offset: currentOffset,
      child: widget.child,
    );
  }
}
