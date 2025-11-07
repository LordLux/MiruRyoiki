import 'package:fluent_ui/fluent_ui.dart';

import '../manager.dart';
import '../screens/series.dart';
import 'frosted_noise.dart';

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
  final bool useFrostedNoise;

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
    this.useFrostedNoise = true,
  }) : assert(tooltip is String || tooltip is Widget || tooltip is InlineSpan || tooltip == null, 'tooltip must be a String, Widget, or null');

  @override
  Widget build(BuildContext context) {
    if (tooltip == null) return child('');
    final decoration = FrostedNoiseDecoration(
      intensity: .35,
      backgroundColor: Color.lerp(Color.lerp(Colors.black, Colors.white, 0.2)!, SeriesScreenContainerState.mainDominantColor ?? Manager.accentColor, 0.4)!.withOpacity(0.8),
      borderRadius: BorderRadius.circular(5.0),
    );
    if (tooltip is String)
      return Tooltip(
        message: tooltip,
        enableFeedback: enableFeedback,
        displayHorizontally: displayHorizontally,
        excludeFromSemantics: excludeFromSemantics,
        style: TooltipThemeData(
          preferBelow: preferBelow,
          waitDuration: waitDuration,
          showDuration: showDuration,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
          decoration: decoration,
        ).merge(style),
        triggerMode: triggerMode,
        useMousePosition: useMousePosition,
        child: child(tooltip),
      );
    if (tooltip is InlineSpan) return Tooltip(
      richMessage: tooltip,
      enableFeedback: enableFeedback,
      displayHorizontally: displayHorizontally,
      excludeFromSemantics: excludeFromSemantics,
      style: TooltipThemeData(
        preferBelow: preferBelow,
        waitDuration: waitDuration,
        showDuration: showDuration,
        decoration: decoration,
      ).merge(style),
      triggerMode: triggerMode,
      useMousePosition: useMousePosition,
      child: child(''),
    );
    return Tooltip(
      richMessage: WidgetSpan(child: tooltip),
      enableFeedback: enableFeedback,
      displayHorizontally: displayHorizontally,
      excludeFromSemantics: excludeFromSemantics,
      style: TooltipThemeData(
        preferBelow: preferBelow,
        waitDuration: waitDuration,
        showDuration: showDuration,
        decoration: decoration,
      ).merge(style),
      triggerMode: triggerMode,
      useMousePosition: useMousePosition,
      child: child(''),
    );
  }
}
