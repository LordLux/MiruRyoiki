import 'package:fluent_ui3/fluent_ui.dart';

class ToggleableFlyoutConfig {
  final double scaleBegin;
  final double scaleEnd;
  final double opacityBegin;
  final double opacityEnd;
  final Offset positionBegin;
  final Offset positionEnd;

  const ToggleableFlyoutConfig({
    this.scaleBegin = 0.98,
    this.scaleEnd = 1.0,
    this.opacityBegin = 0.5,
    this.opacityEnd = 1.0,
    this.positionBegin = const Offset(0.0, -0.5),
    this.positionEnd = Offset.zero,
  });
}

class ToggleableFlyoutContent extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final ToggleableFlyoutConfig config;

  const ToggleableFlyoutContent({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.config = const ToggleableFlyoutConfig(),
    this.curve = Curves.easeOutCubic,
  });

  /// Provides a way to start the closing (reverse) animation.
  /// For example, save the state key and then call:
  ///   await toggleableKey.currentState?.reverseAnimation();
  @override
  ToggleableFlyoutContentState createState() => ToggleableFlyoutContentState();
}

class ToggleableFlyoutContentState extends State<ToggleableFlyoutContent> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final Animation<Offset> _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    final config = widget.config;
    // Create animations that mimic the TweenAnimationBuilder usage:
    _opacity = Tween<double>(begin: config.opacityBegin, end: config.opacityEnd).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _scale = Tween<double>(begin: config.scaleBegin, end: config.scaleEnd).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _position = Tween<Offset>(begin: config.positionBegin, end: config.positionEnd).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _controller.forward();
  }

  Future<void> reverseAnimation() async {
    await _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: SlideTransition(
              position: _position,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
