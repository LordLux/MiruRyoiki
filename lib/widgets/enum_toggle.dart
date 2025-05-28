import 'package:fluent_ui/fluent_ui.dart';
import 'package:toggle_switch/toggle_switch.dart' as toggle;

import '../manager.dart';
import '../utils/color_utils.dart';
import '../utils/time_utils.dart';

class EnumToggle<T> extends StatefulWidget {
  final List<T> enumValues;
  final String Function(T) labelExtractor;
  final T currentValue;
  final Function(T) onChanged;

  const EnumToggle({
    super.key,
    required this.enumValues,
    required this.labelExtractor,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  State<StatefulWidget> createState() => _EnumToggleState<T>();
}

class _EnumToggleState<T> extends State<EnumToggle<T>> {
  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.enumValues.indexOf(widget.currentValue);
    final theme = FluentTheme.of(context);
    
    return toggle.ToggleSwitch(
      animate: true,
      animationDuration: getDuration(dimDuration).inMilliseconds,
      initialLabelIndex: currentIndex,
      customTextStyles: [ for (var i = 0; i < widget.enumValues.length; i++)
        Manager.bodyStyle.copyWith(color: currentIndex == i ? getPrimaryColorBasedOnAccent() : null),
      ],
      totalSwitches: widget.enumValues.length,
      activeFgColor: getPrimaryColorBasedOnAccent(),
      activeBgColors: List.generate(
        widget.enumValues.length,
        (index) => [theme.accentColor.lighter],
      ),
      minWidth: 130.0,
      labels: widget.enumValues.map((value) => widget.labelExtractor(value)).toList(),
      onToggle: (int? index) {
        if (index != null) {
          final selectedValue = widget.enumValues[index];
          widget.onChanged(selectedValue);
        }
      },
    );
  }
}