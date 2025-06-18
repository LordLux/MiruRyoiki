import 'package:fluent_ui/fluent_ui.dart';
import 'wrapper.dart';

class NormalSwitch extends StatelessWidget {
  final ToggleSwitch toggleSwitch;
  final Widget? tooltipWidget;
  final String? tooltip;

  const NormalSwitch({
    super.key,
    required this.toggleSwitch,
    this.tooltipWidget,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return MouseButtonWrapper(
      isButtonDisabled: toggleSwitch.onChanged == null,
      isLoading: false,
      tooltip: tooltip,
      tooltipWidget: tooltipWidget,
      child: (isHovered) => toggleSwitch,
    );
  }
}
