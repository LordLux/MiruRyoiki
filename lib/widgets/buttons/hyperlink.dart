import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../manager.dart';
import '../../utils/screen.dart';
import '../../utils/time.dart';
import 'wrapper.dart';

class WrappedHyperlinkButton extends StatelessWidget {
  final String? text;
  final Widget? title;
  final Widget? icon;
  final String? url;
  final VoidCallback? onPressed;
  final TextStyle? style;
  final Color? iconColor;
  final String? tooltip;
  final Widget? tooltipWidget;
  final Duration tooltipWaitDuration;

  const WrappedHyperlinkButton({
    super.key,
    this.url,
    this.text,
    this.title,
    this.icon,
    this.onPressed,
    this.style,
    this.iconColor,
    this.tooltip,
    this.tooltipWidget,
    this.tooltipWaitDuration = const Duration(milliseconds: 350),
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
              if (states.isDisabled) {
                return Manager.accentColor.darker.withOpacity(.2);
              } else if (states.isPressed) {
                return Manager.accentColor.lightest.withOpacity(.2);
              } else if (states.isHovered) {
                return Manager.accentColor.light.withOpacity(.2);
              } else {
                return null;
              }
            }),
          ),
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
                      iconColor ?? Manager.accentColor.lightest,
                      BlendMode.srcIn,
                    ),
                    child: icon!,
                  ),
                ),
            ],
          ),
          onPressed: () {
            if (url != null && url!.isNotEmpty) launchUrl(Uri.parse(url!));

            onPressed?.call();
          },
        ),
      ),
    );
  }
}
