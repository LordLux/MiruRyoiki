import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/utils/time.dart';

import '../../manager.dart';
import '../../utils/color.dart';
import '../../utils/text.dart';
import 'wrapper.dart';

class StandardButton extends StatelessWidget {
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

  const StandardButton({
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
  });
  
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
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget buttonWidget = MouseButtonWrapper(
      isButtonDisabled: isButtonDisabled,
      isLoading: isLoading,
      tooltip: tooltip,
      tooltipWaitDuration: tooltipWaitDuration,
      tooltipWidget: tooltipWidget,
      child: (isHovered) => Button(
        onPressed: isButtonDisabled ? null : onPressed,
        style: ( //
                isFilled //
                    ? FluentTheme.of(context).buttonTheme.filledButtonStyle!.copyWith(
                          backgroundColor: WidgetStatePropertyAll(isHovered ? Manager.accentColor.lightest : Manager.accentColor.lighter),
                          foregroundColor: WidgetStatePropertyAll(getPrimaryColorBasedOnAccent()),
                        )
                    : ButtonStyle() //
            )
            .copyWith(padding: WidgetStatePropertyAll(EdgeInsets.zero)),
        child: SizedBox(
          height: isSmall ? 32 : 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedSlide(
                offset: Offset.zero,
                duration: shortStickyHeaderDuration,
                curve: Curves.easeInOut,
                child: Padding(
                  padding: padding ?? EdgeInsets.symmetric(horizontal: isWide ? 16 : 12),
                  child: label,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (expand) {
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
    );
  }
}
