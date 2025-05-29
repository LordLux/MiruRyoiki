import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/utils/time_utils.dart';

import '../../manager.dart';
import '../../utils/color_utils.dart';
import 'loading_button.dart';
import 'wrapper.dart';

class SwitchButton extends StatelessWidget {
  final String? label;
  final Widget Function(TextStyle)? labelWidget;
  final VoidCallback onPressed;
  final bool isButtonDisabled;
  final bool isSmall;
  final bool isWide;
  final bool isLoading;
  final bool isFilled;
  final bool isPressed;
  final String? tooltip;
  final Widget? tooltipWidget;

  const SwitchButton({
    super.key,
    this.label,
    this.labelWidget,
    required this.onPressed,
    required this.isPressed,
    this.isButtonDisabled = false,
    this.isSmall = true,
    this.isWide = true,
    this.isFilled = false,
    this.isLoading = false,
    this.tooltip,
    this.tooltipWidget,
  }) : assert((label != null && labelWidget == null) || (label == null && labelWidget != null), 'Either label or labelWidget must be provided, not both.');

  Color getColor(bool isHovered) {
    if (isPressed) return isHovered ? darken(Manager.accentColor.lighter) : Manager.accentColor.light;
    /*           */ return isHovered ? Manager.accentColor.lightest : Manager.accentColor.lighter;
  }

  @override
  Widget build(BuildContext context) {
    return MouseButtonWrapper(
      isButtonDisabled: isButtonDisabled,
      isLoading: isLoading,
      tooltip: tooltip,
      tooltipWidget: tooltipWidget,
      child: (isHovered) => Button(
        onPressed: isButtonDisabled ? null : onPressed,
        style: ( //
                isFilled //
                    ? FluentTheme.of(context).buttonTheme.filledButtonStyle!.copyWith(
                          backgroundColor: WidgetStatePropertyAll(getColor(isHovered)),
                          foregroundColor: WidgetStatePropertyAll(getPrimaryColorBasedOnAccent()),
                        )
                    : FluentTheme.of(context).buttonTheme.defaultButtonStyle! //
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
                  padding: EdgeInsets.symmetric(horizontal: isWide ? 16 : 12),
                  child: Builder(builder: (context) {
                    final TextStyle style = isFilled //
                        ? Manager.bodyStyle.copyWith(color: getPrimaryColorBasedOnAccent())
                        : Manager.bodyStyle;

                    if (label != null) return Text(label!, style: style);
                    return labelWidget!.call(style);
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
