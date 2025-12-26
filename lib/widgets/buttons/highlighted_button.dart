import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../manager.dart';
import '../../utils/screen.dart';
import '../../utils/time.dart';
import 'wrapper.dart';

class HighlightedButton extends StatelessWidget {
  final String? text;
  final Widget? title;
  final Widget? icon;
  final VoidCallback? onPressed;
  final TextStyle? style;
  final Color? iconColor;
  final String? tooltip;
  final Widget? tooltipWidget;
  final Duration tooltipWaitDuration;
  final Color? hoverColor;

  const HighlightedButton({
    super.key,
    this.text,
    this.title,
    this.icon,
    this.onPressed,
    this.style,
    this.iconColor,
    this.tooltip,
    this.tooltipWidget,
    this.tooltipWaitDuration = const Duration(milliseconds: 350),
    this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-12, 0),
      child: MouseButtonWrapper(
        tooltipWaitDuration: tooltipWaitDuration,
        tooltip: tooltip,
        tooltipWidget: tooltipWidget,
        child: (isHovering) => HyperlinkButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              final hoverCol = hoverColor?.toAccentColor() ?? Manager.currentDominantAccentColor ?? Manager.accentColor;
              if (states.isDisabled) {
                return hoverCol.darker.withOpacity(.2);
              } else if (states.isPressed) {
                return hoverCol.lightest.withOpacity(.2);
              } else if (states.isHovered) {
                return hoverCol.light.withOpacity(.2);
              } else {
                return null;
              }
            }),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (text != null) Text(text!, style: style ?? Manager.subtitleStyle),
              if (title != null) ...[
                if (text != null) HDiv(4),
                title!,
              ],
              HDiv(8),
              if (icon != null)
                AnimatedOpacity(
                  opacity: isHovering ? 1.0 : 0.0,
                  duration: shortDuration,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      iconColor ?? Manager.currentDominantAccentColor?.lightest ?? Manager.accentColor.lightest,
                      BlendMode.srcIn,
                    ),
                    child: icon!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
