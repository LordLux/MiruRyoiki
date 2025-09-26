import 'package:fluent_ui/fluent_ui.dart';

class TooltipWrapper extends StatelessWidget {
  final Widget Function(String) child;
  final String message;
  final bool? preferBelow;
  final bool enableFeedback;
  final Duration waitDuration;
  final Duration? showDuration;
  final bool displayHorizontally;
  final bool excludeFromSemantics;
  final InlineSpan? richMessage;
  final TooltipThemeData? style;
  final TooltipTriggerMode? triggerMode;
  final bool useMousePosition;

  const TooltipWrapper({
    super.key,
    required this.child,
    required this.message,
    this.preferBelow,
    this.enableFeedback = true,
    this.waitDuration = const Duration(milliseconds: 400),
    this.showDuration,
    this.displayHorizontally = false,
    this.excludeFromSemantics = false,
    this.style,
    this.triggerMode,
    this.useMousePosition = false,
    this.richMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      enableFeedback: enableFeedback,
      displayHorizontally: displayHorizontally,
      excludeFromSemantics: excludeFromSemantics,
      richMessage: richMessage,
      style: TooltipThemeData(preferBelow: preferBelow, waitDuration: waitDuration, showDuration: showDuration).merge(style),
      triggerMode: triggerMode,
      useMousePosition: useMousePosition,
      child: child(message),
    );
  }
}
