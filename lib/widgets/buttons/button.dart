import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/utils/time.dart';

import '../../manager.dart';
import '../../utils/color.dart';
import '../../utils/text.dart';
import 'wrapper.dart';

/// A customizable button widget with loading and tooltip capabilities.
class StandardButton extends StatefulWidget {
  final Widget label;
  final VoidCallback? onPressed;
  final bool isButtonDisabled;
  final bool isSmall;
  final bool isWide;
  final bool isLoading;
  final bool isFilled;
  final String? tooltip;
  final Widget? tooltipWidget;
  final bool expand;
  final Duration? tooltipWaitDuration;
  final EdgeInsets? padding;
  final Color filledColor;
  final Color hoverFillColor;

  StandardButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isButtonDisabled = false,
    this.isSmall = true,
    this.isWide = true,
    this.isFilled = false,
    this.isLoading = false,
    this.tooltip,
    this.tooltipWidget,
    this.expand = false,
    this.tooltipWaitDuration,
    this.padding,
    Color? filledColor,
    Color? hoverFillColor,
  })  : filledColor = filledColor ?? Manager.accentColor.lighter,
        hoverFillColor = hoverFillColor ?? Manager.accentColor.lightest;

  factory StandardButton.icon({
    required Widget icon,
    required Widget label,
    required VoidCallback? onPressed,
    bool isButtonDisabled = false,
    bool isSmall = true,
    bool isWide = true,
    bool isFilled = false,
    bool isLoading = false,
    String? tooltip,
    Widget? tooltipWidget,
    bool expand = false,
    Duration? tooltipWaitDuration,
    EdgeInsets? padding,
    TextStyle? textStyle,
    Color? filledColor,
    Color? hoverFillColor,
  }) {
    return StandardButton(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 8),
          label,
        ],
      ),
      onPressed: onPressed,
      isButtonDisabled: isButtonDisabled,
      isSmall: isSmall,
      isWide: isWide,
      isFilled: isFilled,
      isLoading: isLoading,
      tooltip: tooltip,
      tooltipWidget: tooltipWidget,
      expand: expand,
      tooltipWaitDuration: tooltipWaitDuration,
      padding: padding,
      filledColor: filledColor,
      hoverFillColor: hoverFillColor,
    );
  }

  @override
  State<StandardButton> createState() => _StandardButtonState();
}

class _StandardButtonState extends State<StandardButton> {
  late Color _previousFilledColor;
  late Color? _previousHoverFillColor;
  late bool _previousIsFilled;

  @override
  void initState() {
    super.initState();
    _previousFilledColor = widget.filledColor;
    _previousHoverFillColor = widget.hoverFillColor;
    _previousIsFilled = widget.isFilled;
  }

  @override
  void didUpdateWidget(StandardButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filledColor != widget.filledColor) {
      _previousFilledColor = oldWidget.filledColor;
    }
    if (oldWidget.hoverFillColor != widget.hoverFillColor) {
      _previousHoverFillColor = oldWidget.hoverFillColor;
    }
    if (oldWidget.isFilled != widget.isFilled) {
      _previousIsFilled = oldWidget.isFilled;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buttonWidget = MouseButtonWrapper(
      isButtonDisabled: widget.isButtonDisabled,
      isLoading: widget.isLoading,
      tooltip: widget.tooltip,
      tooltipWaitDuration: widget.tooltipWaitDuration,
      tooltipWidget: widget.tooltipWidget,
      child: (isHovered) {
        // Get foreground color based on accent
        final foregroundColor = getPrimaryColorBasedOnAccent();

        return TweenAnimationBuilder<Color?>(
          tween: ColorTween(
            begin: _previousIsFilled != widget.isFilled ? (widget.isFilled ? Colors.transparent : _previousFilledColor) : _previousFilledColor,
            end: widget.filledColor,
          ),
          duration: const Duration(milliseconds: 200),
          builder: (context, animatedFilledColor, _) {
            return TweenAnimationBuilder<Color?>(
              tween: ColorTween(
                begin: _previousHoverFillColor,
                end: widget.hoverFillColor,
              ),
              duration: const Duration(milliseconds: 200),
              builder: (context, animatedHoverColor, _) {
                return Button(
                  onPressed: widget.isButtonDisabled ? null : widget.onPressed,
                  style: (widget.isFilled
                          ? FluentTheme.of(context).buttonTheme.filledButtonStyle!.copyWith(
                                backgroundColor: WidgetStateProperty.all<Color?>(isHovered ? animatedHoverColor : animatedFilledColor),
                                foregroundColor: WidgetStatePropertyAll(foregroundColor),
                              )
                          : ButtonStyle())
                      .copyWith(padding: WidgetStatePropertyAll(EdgeInsets.zero)),
                  child: SizedBox(
                    height: widget.isSmall ? 32 : 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          color: widget.isFilled ? (isHovered ? animatedHoverColor : animatedFilledColor) : Colors.transparent,
                          child: AnimatedSlide(
                            offset: Offset.zero,
                            duration: shortStickyHeaderDuration,
                            curve: Curves.easeInOut,
                            child: Padding(
                              padding: widget.padding ?? EdgeInsets.symmetric(horizontal: widget.isWide ? 16 : 12),
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: getStyleBasedOnAccent(widget.isFilled),
                                child: widget.label,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (widget.expand) {
      return SizedBox(
        width: double.infinity,
        child: buttonWidget,
      );
    }
    return buttonWidget;
  }
}

class NormalButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isButtonDisabled;
  final bool isSmall;
  final bool isWide;
  final bool isFilled;
  final bool expand;
  final bool isLoading;
  final String? tooltip;
  final Widget? tooltipWidget;
  final Duration? tooltipWaitDuration;
  final EdgeInsets? padding;
  final Color? filledColor;
  final Color? hoverFillColor;

  const NormalButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isButtonDisabled = false,
    this.isSmall = true,
    this.isWide = true,
    this.isFilled = false,
    this.expand = false,
    this.tooltip,
    this.tooltipWidget,
    this.isLoading = false,
    this.tooltipWaitDuration,
    this.padding,
    this.filledColor,
    this.hoverFillColor,
  });

  @override
  Widget build(BuildContext context) {
    return StandardButton(
      label: Text(label, style: getStyleBasedOnAccent(isFilled)),
      onPressed: onPressed,
      isButtonDisabled: isButtonDisabled,
      isSmall: isSmall,
      isWide: isWide,
      isFilled: isFilled,
      expand: expand,
      tooltip: tooltip,
      tooltipWidget: tooltipWidget,
      isLoading: isLoading,
      tooltipWaitDuration: tooltipWaitDuration,
      padding: padding,
      filledColor: filledColor,
      hoverFillColor: hoverFillColor,
    );
  }
}
