import 'package:fluent_ui/fluent_ui.dart';

import '../manager.dart';
import 'tooltip.dart' as tp;

class TooltipWrapper extends StatelessWidget {
  final Widget Function(String) child;
  final dynamic tooltip;
  final bool? preferBelow;
  final bool enableFeedback;
  final Duration waitDuration;
  final Duration? showDuration;
  final bool displayHorizontally;
  final bool excludeFromSemantics;
  final tp.TooltipThemeData? style;
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
  }) : assert(tooltip is String || tooltip is Widget || tooltip == null, 'tooltip must be a String, Widget, or null');

  @override
  Widget build(BuildContext context) {
    if (tooltip == null) return child('');

    final decoration = BoxDecoration(
      color: (Manager.currentDominantColor ?? Manager.accentColor).withOpacity(.1),
      borderRadius: BorderRadius.circular(5.0),
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8.0,
          offset: const Offset(0, 4),
        ),
      ],
    );

    if (Manager.settings.useAcrylicTooltips) {
      // Acrylic tooltips
      if (tooltip is String)
        return tp.Tooltip(
          message: tooltip,
          enableFeedback: enableFeedback,
          displayHorizontally: displayHorizontally,
          excludeFromSemantics: excludeFromSemantics,
          // tooltipBuilder: ({required Widget child}) => FrostedNoise(child: child),
          style: tp.TooltipThemeData(
            preferBelow: preferBelow,
            waitDuration: waitDuration,
            showDuration: showDuration,
            // padding: padding,
            decoration: decoration,
          ).merge(style),
          triggerMode: triggerMode,
          useMousePosition: useMousePosition,
          child: child(tooltip),
        );
      return tp.Tooltip(
        richMessage: WidgetSpan(child: tooltip),
        enableFeedback: enableFeedback,
        displayHorizontally: displayHorizontally,
        excludeFromSemantics: excludeFromSemantics,
        // tooltipBuilder: ({required Widget child}) => FrostedNoise(child: child),
        style: tp.TooltipThemeData(
          preferBelow: preferBelow,
          waitDuration: waitDuration,
          showDuration: showDuration,
          // padding: padding,
          decoration: decoration,
        ).merge(style),
        triggerMode: triggerMode,
        useMousePosition: useMousePosition,
        child: child(''),
      );
    }
    // Non-acrylic tooltips
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
        ).merge(toTooltipThemeData(style)),
        triggerMode: triggerMode,
        useMousePosition: useMousePosition,
        child: child(tooltip),
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
      ).merge(toTooltipThemeData(style)),
      triggerMode: triggerMode,
      useMousePosition: useMousePosition,
      child: child(''),
    );
  }
}

TooltipThemeData? toTooltipThemeData(tp.TooltipThemeData? data) {
  if (data == null) return null;
  return TooltipThemeData(
    preferBelow: data.preferBelow,
    waitDuration: data.waitDuration,
    showDuration: data.showDuration,
    padding: data.padding,
    margin: data.margin,
    decoration: data.decoration,
    textStyle: data.textStyle,
    verticalOffset: data.verticalOffset,
    height: data.height,
    maxWidth: data.maxWidth,
  );
}