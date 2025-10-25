import 'package:fluent_ui/fluent_ui.dart';

import '../utils/time.dart';

class AnimatedColor extends StatefulWidget {
  final Color color;
  final Widget Function(Color color) builder;
  final Duration duration;
  final Curve curve;

  AnimatedColor({
    super.key,
    required Color? color,
    required this.builder,
    Duration? duration,
    this.curve = Curves.easeInOut,
  })  : duration = duration ?? mediumDuration,
        color = color ?? Colors.transparent;

  @override
  State<StatefulWidget> createState() => _AnimatedColorState();
}

class _AnimatedColorState extends State<AnimatedColor> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Color _previousColor;

  @override
  void initState() {
    super.initState();
    _previousColor = widget.color;

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: _previousColor,
      end: widget.color,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedColor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.color != widget.color) {
      _previousColor = _colorAnimation.value ?? _previousColor;

      _controller.duration = widget.duration;
      _colorAnimation = ColorTween(
        begin: _previousColor,
        end: widget.color,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));

      _controller.forward(from: 0.0);
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
      builder: (context, child) =>
         widget.builder(_colorAnimation.value ?? widget.color)
      ,
    );
  }
}
