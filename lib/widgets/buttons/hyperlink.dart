import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../manager.dart';
import '../../utils/screen_utils.dart';
import '../../utils/time_utils.dart';
import 'wrapper.dart';

class WrappedHyperlinkButton extends StatelessWidget {
  final String? text;
  final Widget? title;
  final Widget? icon;
  final String url;
  final VoidCallback? onPressed;

  const WrappedHyperlinkButton({
    super.key,
    required this.url,
    this.text,
    this.title,
    this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-12, 0),
      child: MouseButtonWrapper(
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
              if (text != null) Text(text!, style: Manager.subtitleStyle),
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
                      Manager.accentColor.lightest,
                      BlendMode.srcIn,
                    ),
                    child: icon!,
                  ),
                ),
            ],
          ),
          onPressed: () {
            launchUrl(Uri.parse(url));
            onPressed?.call();
          },
        ),
      ),
    );
  }
}
