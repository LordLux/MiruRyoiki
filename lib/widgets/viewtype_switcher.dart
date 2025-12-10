// ignore_for_file: use_build_context_synchronously

import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/widgets/tooltip_wrapper.dart';

import '../enums.dart';
import '../utils/screen.dart';
import '../widgets/buttons/button.dart';
import '../widgets/pill.dart';

class ViewTypeSwitcher extends StatelessWidget {
  final ViewType currentViewType;
  final Color textColor;
  final Color selectedTextColor;
  final void Function(ViewType p1) onViewTypeChanged;
  final bool useBorder;

  const ViewTypeSwitcher({
    super.key,
    required this.currentViewType,
    required this.textColor,
    required this.selectedTextColor,
    required this.onViewTypeChanged,
    this.useBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final pills = Transform.translate(
      offset: const Offset(3, 0),
      child: buildViewTypePills(
        currentViewType,
        textColor,
        selectedTextColor,
        onViewTypeChanged,
      ),
    );
    if (useBorder)
      return SizedBox(
        height: ScreenUtils.kDefaultButtonSize + 1,
        child: StandardButton.iconLabel(
          tooltip: 'Change View Type',
          switchIconWithLabel: true,
          label: Padding(
            padding: EdgeInsets.only(left: 3),
            child: Text("View", style: Manager.subtitleStyle.copyWith(fontSize: 12)),
          ),
          padding: EdgeInsets.all(2),
          cursor: SystemMouseCursors.basic,
          icon: pills,
          onPressed: () {}, // Disabled as selection is done via pills
        ),
      );
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Transform.translate(
        offset: const Offset(-3, 0),
        child: TooltipWrapper(
          tooltip: 'Change View Type',
          child: (text) => Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 3),
                child: Text("View", style: Manager.subtitleStyle.copyWith(fontSize: 12)),
              ),
              SizedBox(width: 6),
              pills,
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildViewTypePills(ViewType currentViewType, Color textColor, Color selectedTextColor, void Function(ViewType) onViewTypeChanged) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: ViewType.values.map((viewType) {
      final isSelected = currentViewType == viewType;

      return Padding(
        padding: EdgeInsets.only(right: 3),
        child: Pill(
          text: viewType.label,
          icon: viewType.icon,
          tooltip: viewType.tooltip,
          color: textColor,
          selectedColor: selectedTextColor,
          isSelected: isSelected,
          onTap: () => onViewTypeChanged(viewType),
        ),
      );
    }).toList(),
  );
}
