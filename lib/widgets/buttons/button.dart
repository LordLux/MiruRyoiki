import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/utils/time_utils.dart';

import '../../manager.dart';
import '../../utils/color_utils.dart';
import 'wrapper.dart';

class NormalButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isButtonDisabled;
  final bool isSmall;
  final bool isWide;
  final bool isLoading;
  final bool isFilled;
  final String? tooltip;
  final Widget? tooltipWidget;
  final bool expand;

  const NormalButton({
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
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonWidget = MouseButtonWrapper(
      isButtonDisabled: isButtonDisabled,
      isLoading: isLoading,
      tooltip: tooltip,
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
                  padding: EdgeInsets.symmetric(horizontal: isWide ? 16 : 12),
                  child: Text(
                    label,
                    style: isFilled //
                        ? Manager.bodyStyle.copyWith(color: getPrimaryColorBasedOnAccent())
                        : Manager.bodyStyle,
                  ),
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
