import 'package:fluent_ui3/fluent_ui.dart';

class ToggleableFlyoutContent extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ToggleableFlyoutContent({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
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

    // Create animations that mimic the TweenAnimationBuilder usage:
    _opacity = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _scale = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _position = Tween<Offset>(begin: Offset(0, -0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
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
