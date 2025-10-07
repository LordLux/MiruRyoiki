import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/utils/time.dart';

import '../../manager.dart';
import 'wrapper.dart';

class LoadingButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;
  final bool isButtonDisabled;
  final bool isSmall;
  final bool isBigEvenWithoutLoading;
  final bool isFilled;
  final String? tooltip;
  final Widget? tooltipWidget;
  final Color? filledColor;
  final Color? hoverFillColor;
  final bool expand;
  final Duration? tooltipWaitDuration;

  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.isLoading,
    this.isButtonDisabled = false,
    this.isSmall = false,
    this.isBigEvenWithoutLoading = false,
    this.isFilled = false,
    this.tooltip,
    this.tooltipWidget,
    this.filledColor,
    this.hoverFillColor,
    this.expand = false,
    this.tooltipWaitDuration,
  });

  @override
  LoadingButtonState createState() => LoadingButtonState();
}

class LoadingButtonState extends State<LoadingButton> {
  bool isLocalLoading = false;

  double get minusSmall => widget.isSmall ? 12 : 0;

  double get horizPadding {
    if (widget.isLoading) return 32;
    if (widget.isBigEvenWithoutLoading) return 32;
    return widget.isSmall ? 12 : 16;
  }

  @override
  Widget build(BuildContext context) {
    final fill = widget.filledColor ?? (widget.isFilled ? Manager.accentColor.lighter : FluentTheme.of(context).resources.cardBackgroundFillColorDefault);
    final hoverFill = widget.hoverFillColor ?? (widget.isFilled ? Manager.accentColor.lightest : FluentTheme.of(context).resources.cardBackgroundFillColorDefault);

    return MouseButtonWrapper(
      isButtonDisabled: widget.isButtonDisabled,
      isLoading: widget.isLoading,
      tooltip: widget.tooltip,
      tooltipWaitDuration: widget.tooltipWaitDuration,
      tooltipWidget: widget.tooltipWidget,
      child: (isHovering) {
        final Color? bg = widget.isLoading ? null : (isHovering ? hoverFill : fill);
        final Color fg = widget.isFilled && !widget.isLoading ? Colors.black : Colors.white;

        ButtonStyle copy = ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.zero),
          foregroundColor: WidgetStatePropertyAll<Color>(fg),
          backgroundColor: WidgetStateProperty.all<Color?>(bg),
        );
        Widget child = AnimatedContainer(
          duration: shortDuration,
          height: widget.isSmall ? 32 : 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedSlide(
                offset: widget.isLoading ? const Offset(-0.125, 0) : Offset.zero,
                duration: mediumDuration,
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
                  duration: mediumDuration,
                  child: AnimatedContainer(
                    duration: shortDuration,
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
        Widget buttonWidget = Button(
          onPressed: widget.isButtonDisabled ? null : widget.onPressed,
          style: (!widget.isFilled ? FluentTheme.of(context).buttonTheme.defaultButtonStyle! : FluentTheme.of(context).buttonTheme.filledButtonStyle!).merge(copy),
          child: child,
        );
        if (widget.expand) {
          return AnimatedContainer(
            duration: shortDuration,
            width: double.infinity,
            child: buttonWidget,
          );
        }
        return buttonWidget;
      },
    );
  }
}
