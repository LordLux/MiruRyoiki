import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/utils/time_utils.dart';

import '../../manager.dart';
import 'wrapper.dart';

class LoadingButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;
  final bool isButtonDisabled;
  final bool isSmall;
  final bool isAlreadyBig;
  final bool isFilled;
  final String? tooltip;
  final Widget? tooltipWidget;
  final Color? filledColor;
  final Color? hoverFillColor;
  final bool expand;

  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.isLoading,
    this.isButtonDisabled = false,
    this.isSmall = false,
    this.isAlreadyBig = false,
    this.isFilled = false,
    this.tooltip,
    this.tooltipWidget,
    this.filledColor,
    this.hoverFillColor,
    this.expand = false,
  });

  @override
  LoadingButtonState createState() => LoadingButtonState();
}

class LoadingButtonState extends State<LoadingButton> {
  bool isLocalLoading = false;

  double get minusSmall => widget.isSmall ? 12 : 0;

  double get horizPadding {
    if (widget.isLoading) return 32;
    if (widget.isAlreadyBig) return 32;
    return widget.isSmall ? 12 : 16;
  }

  @override
  Widget build(BuildContext context) {
    return MouseButtonWrapper(
      isButtonDisabled: widget.isButtonDisabled,
      isLoading: widget.isLoading,
      tooltip: widget.tooltip,
      tooltipWidget: widget.tooltipWidget,
      child: (_) {
        ButtonStyle copy = ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.zero),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.hovered) ? widget.hoverFillColor : widget.filledColor,
          ),
        );
        Widget btn(Widget child) => Button(
              onPressed: widget.isButtonDisabled ? null : widget.onPressed,
              style: FluentTheme.of(context).buttonTheme.defaultButtonStyle!.copyWith(padding: copy.padding, backgroundColor: copy.backgroundColor),
              child: child,
            );
        Widget filled_btn(Widget child) => FilledButton(
              onPressed: widget.isButtonDisabled ? null : widget.onPressed,
              style: FluentTheme.of(context).buttonTheme.filledButtonStyle!.copyWith(padding: copy.padding, backgroundColor: copy.backgroundColor),
              child: child,
            );
        Widget child = SizedBox(
          height: widget.isSmall ? 32 : 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedSlide(
                offset: widget.isLoading ? const Offset(-0.125, 0) : Offset.zero,
                duration: shortStickyHeaderDuration,
                curve: Curves.easeInOut,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizPadding),
                  child: Text(widget.label),
                ),
              ),
              Positioned(
                right: 15,
                child: AnimatedOpacity(
                  opacity: widget.isLoading ? 1.0 : 0.0,
                  duration: shortStickyHeaderDuration,
                  child: SizedBox(
                    width: widget.isSmall ? 20 : 25,
                    height: widget.isSmall ? 20 : 25,
                    child: ProgressRing(
                      strokeWidth: widget.isSmall ? 3.5 : 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        Widget buttonWidget = widget.isFilled ? filled_btn(child) : btn(child);
        if (widget.expand) {
          return SizedBox(
            width: double.infinity,
            child: buttonWidget,
          );
        }
        return buttonWidget;
      },
    );
  }
}
