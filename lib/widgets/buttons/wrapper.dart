import 'package:fluent_ui/fluent_ui.dart';

import '../tooltip_wrapper.dart';

class MouseButtonWrapper extends StatefulWidget {
  final Widget Function(bool isHovering) child;
  final bool isButtonDisabled;
  final bool isLoading;
  final String? tooltip;
  final Widget? tooltipWidget;
  final Duration? tooltipWaitDuration;
  final MouseCursor? cursor;

  const MouseButtonWrapper({
    super.key,
    required this.child,
    this.isButtonDisabled = false,
    this.isLoading = false,
    this.cursor,
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
    return TooltipWrapper(
      tooltip: widget.tooltipWidget ?? widget.tooltip,
      waitDuration: widget.tooltipWaitDuration ?? const Duration(milliseconds: 500),
      child: (_) => MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        cursor: widget.cursor ??
            (widget.isLoading //
                ? SystemMouseCursors.progress
                : widget.isButtonDisabled
                    ? SystemMouseCursors.forbidden
                    : SystemMouseCursors.click),
        child: AbsorbPointer(
          absorbing: widget.isButtonDisabled || widget.isLoading,
          child: AnimatedOpacity(
            opacity: widget.isButtonDisabled ? 0.75 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: widget.child(_isHovering),
          ),
        ),
      ),
    );
  }
}
