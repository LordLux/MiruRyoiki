import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'highlighted_button.dart';

class WrappedHyperlinkButton extends StatelessWidget {
  final String? text;
  final Widget? title;
  final Widget? icon;
  final String url;
  final VoidCallback? onPressed;
  final TextStyle? style;
  final Color? iconColor;
  final String? tooltip;
  final Widget? tooltipWidget;
  final Duration tooltipWaitDuration;
  final Color? hoverColor;

  const WrappedHyperlinkButton({
    super.key,
    required this.url,
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
    return HighlightedButton(
      text: text,
      title: title,
      icon: icon,
      onPressed: () async {
        if (url.isNotEmpty) {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) await launchUrl(uri);
        }

        if (onPressed != null) onPressed!();
      },
      style: style,
      iconColor: iconColor,
      tooltip: tooltip,
      tooltipWidget: tooltipWidget,
      tooltipWaitDuration: tooltipWaitDuration,
      hoverColor: hoverColor,
    );
  }
}
