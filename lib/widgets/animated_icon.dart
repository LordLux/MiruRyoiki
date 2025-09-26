import 'package:flutter/material.dart';

class AnimatedIcon extends StatefulWidget {
  final Icon icon;
  final Duration duration;

  const AnimatedIcon(
    this.icon, {
    super.key,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedIcon> createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<AnimatedIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  Color? _currentColor;

  @override
  void initState() {
    super.initState();

    _currentColor = widget.icon.color ?? Theme.of(context).iconTheme.color ?? Colors.black;

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: _currentColor,
      end: _currentColor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update duration if it changed
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }

    // Check if the color has changed
    final newColor = widget.icon.color ?? Theme.of(context).iconTheme.color ?? Colors.black;
    if (newColor != _currentColor) {
      // Start animation from current animated value to new color
      _colorAnimation = ColorTween(
        begin: _colorAnimation.value ?? _currentColor,
        end: newColor,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));

      _currentColor = newColor;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Icon(
          widget.icon.icon,
          color: _colorAnimation.value,
          size: widget.icon.size,
          semanticLabel: widget.icon.semanticLabel,
          textDirection: widget.icon.textDirection,
          shadows: widget.icon.shadows,
          weight: widget.icon.weight,
          fill: widget.icon.fill,
          grade: widget.icon.grade,
          opticalSize: widget.icon.opticalSize,
          applyTextScaling: widget.icon.applyTextScaling,
        );
      },
    );
  }
}
