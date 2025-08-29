import 'package:fluent_ui/fluent_ui.dart';

import 'wrapper.dart';

class RotatingLoadingButton extends StatefulWidget {
  final Widget icon;
  final bool isLoading;
  final Size size;
  final VoidCallback onPressed;
  final bool isButtonDisabled;
  final String? tooltip;
  final Widget? tooltipWidget;
  final ButtonStyle style;
  final double rps;

  const RotatingLoadingButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.isLoading,
    this.size = const Size(35, 35),
    this.isButtonDisabled = false,
    this.tooltip,
    this.tooltipWidget,
    this.style = const ButtonStyle(),
    this.rps = 1.25,
  });

  @override
  RotatingLoadingButtonState createState() => RotatingLoadingButtonState();
}

class RotatingLoadingButtonState extends State<RotatingLoadingButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller with a 1-second duration for one full rotation
    _controller = AnimationController(
      duration: Duration(milliseconds: (1000 / widget.rps).round()),
      vsync: this,
    );

    // Start animation if initially loading
    if (widget.isLoading) _startLoading();
  }

  @override
  void didUpdateWidget(RotatingLoadingButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle loading state changes
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading)
        _startLoading();
      else
        _stopLoading();
    }
  }

  void _startLoading() => _controller.repeat();

  void _stopLoading() {
    // Calculate how much rotation is needed to complete the current cycle
    final currentValue = _controller.value;
    final remainingRotation = 1.0 - currentValue;

    // Stop repeating and animate to complete the current rotation
    _controller.stop();
    _controller.animateTo(currentValue + remainingRotation).then((_) {
      // Reset to 0 after completing the rotation
      _controller.reset();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseButtonWrapper(
      isButtonDisabled: widget.isButtonDisabled,
      isLoading: widget.isLoading,
      tooltip: widget.tooltip,
      tooltipWidget: widget.tooltipWidget,
      child: (isHovering) {
        ButtonStyle copy = widget.style.merge(ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.zero)))!;
        return IconButton(
          onPressed: widget.isButtonDisabled ? null : widget.onPressed,
          style: FluentTheme.of(context).buttonTheme.defaultButtonStyle!.copyWith(padding: copy.padding, backgroundColor: copy.backgroundColor),
          icon: SizedBox.fromSize(
            size: widget.size,
            child: RotationTransition(
              turns: _controller,
              child: widget.icon,
            ),
          ),
        );
      },
    );
  }
}
