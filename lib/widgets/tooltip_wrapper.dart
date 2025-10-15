import 'package:fluent_ui/fluent_ui.dart';

class TooltipWrapper extends StatelessWidget {
  final Widget Function(String) child;
  final dynamic tooltip;
  final bool? preferBelow;
  final bool enableFeedback;
  final Duration waitDuration;
  final Duration? showDuration;
  final bool displayHorizontally;
  final bool excludeFromSemantics;
  final TooltipThemeData? style;
  final TooltipTriggerMode? triggerMode;
  final bool useMousePosition;

  const TooltipWrapper({
    super.key,
    required this.child,
    required this.tooltip,
    this.preferBelow,
    this.enableFeedback = true,
    this.waitDuration = const Duration(milliseconds: 400),
    this.showDuration,
    this.displayHorizontally = false,
    this.excludeFromSemantics = false,
    this.style,
    this.triggerMode,
    this.useMousePosition = false,
  }) : assert(tooltip is String || tooltip is Widget || tooltip == null, 'tooltip must be a String, Widget, or null');

  @override
  Widget build(BuildContext context) {
    if (tooltip == null) return child('');
    if (this.tooltip is String)
      return Tooltip(
        message: tooltip,
        enableFeedback: enableFeedback,
        displayHorizontally: displayHorizontally,
        excludeFromSemantics: excludeFromSemantics,
        style: TooltipThemeData(preferBelow: preferBelow, waitDuration: waitDuration, showDuration: showDuration).merge(style),
        triggerMode: triggerMode,
        useMousePosition: useMousePosition,
        child: child(tooltip),
      );
    return Tooltip(
      richMessage: WidgetSpan(child: tooltip),
      enableFeedback: enableFeedback,
      displayHorizontally: displayHorizontally,
      excludeFromSemantics: excludeFromSemantics,
      style: TooltipThemeData(preferBelow: preferBelow, waitDuration: waitDuration, showDuration: showDuration).merge(style),
      triggerMode: triggerMode,
      useMousePosition: useMousePosition,
      child: child(''),
    );
  }
}
