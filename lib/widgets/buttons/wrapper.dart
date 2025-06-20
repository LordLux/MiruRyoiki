import 'package:fluent_ui/fluent_ui.dart';

class MouseButtonWrapper extends StatefulWidget {
  final Widget Function(bool isHovering) child;
  final bool isButtonDisabled;
  final bool isLoading;
  final String? tooltip;
  final Widget? tooltipWidget;
  final Duration? tooltipWaitDuration;

  const MouseButtonWrapper({
    super.key,
    required this.child,
    this.isButtonDisabled = false,
    this.isLoading = false,
    this.tooltip,
    this.tooltipWidget,
    this.tooltipWaitDuration,
  });

  @override
  State<MouseButtonWrapper> createState() => _MouseButtonWrapperState();
}

class _MouseButtonWrapperState extends State<MouseButtonWrapper> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return TooltipTheme(
      data: TooltipThemeData(waitDuration: widget.tooltipWaitDuration),
      child: Builder(builder: (context) {
        Widget button = MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          cursor: widget.isButtonDisabled
              ? SystemMouseCursors.forbidden
              : widget.isLoading
                  ? SystemMouseCursors.progress
                  : SystemMouseCursors.click,
          child: widget.child(_isHovering),
        );
        // no tooltip
        if (widget.tooltip == null && widget.tooltipWidget == null) return button;

        // only string tooltip
        if (widget.tooltip == null && widget.tooltipWidget != null) return Tooltip(richMessage: WidgetSpan(child: widget.tooltipWidget!), child: button);

        // only widget tooltip
        return Tooltip(message: widget.tooltip, child: button);
      }),
    );
  }
}
