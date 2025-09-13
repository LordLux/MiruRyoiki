import 'package:fluent_ui/fluent_ui.dart';
import '../../utils/time_utils.dart';
import 'wrapper.dart';

class NormalSwitch extends StatelessWidget {
  final ToggleSwitch toggleSwitch;
  final bool disabled;
  final Widget? tooltipWidget;
  final String? tooltip;
  final Duration? tooltipWaitDuration;

  const NormalSwitch(
    this.toggleSwitch, {
    super.key,
    this.tooltipWidget,
    this.tooltip,
    this.disabled = false,
    this.tooltipWaitDuration,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: dimDuration,
      opacity: disabled ? 0.6 : 1.0,
      child: MouseButtonWrapper(
        isButtonDisabled: disabled || toggleSwitch.onChanged == null,
        isLoading: false,
        tooltip: tooltip,
        tooltipWidget: tooltipWidget,
        tooltipWaitDuration: tooltipWaitDuration,
        child: (isHovered) => toggleSwitch,
      ),
    );
  }
}
