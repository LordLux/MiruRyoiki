import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/widgets/buttons/button.dart';

import '../../manager.dart';
import '../../screens/settings.dart';
import '../cutout.dart';

class SettingCategoryButton extends StandardButton {
  final int index;
  final bool isSelected;
  final void Function(int index) onCategoryPressed;

  SettingCategoryButton(
    this.index, {
    super.key,
    required this.onCategoryPressed,
    this.isSelected = false,
  }) : super(
          label: const SizedBox.shrink(), // placeholder
          onPressed: () {}, // placeholder
          expand: true,
          isWide: true,
          padding: const EdgeInsets.all(6),
          isSmall: false,
        );

  @override
  Widget build(BuildContext context) {
    final thisButton = SettingsScreenState.settingsList[index];
    final Icon icon = thisButton["icon"];
    final Color col = icon.color!;
    return Padding(
      padding: SettingsScreenState.settingsList.length != index ? EdgeInsets.only(bottom: 8.0) : EdgeInsets.zero,
      child: StandardButton(
        label: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            isSelected
                ? Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: col.withOpacity(.15),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(child: icon),
                  )
                : SquircleCutoutWidget(
                    borderRadius: 8.0,
                    size: const Size(35, 35),
                    color: Colors.white.withOpacity(0.15),
                    child: Center(child: icon),
                  ),
            const SizedBox(width: 10),
            Text(
              thisButton["title"] ?? "",
              style: isSelected ? Manager.bodyStrongStyle.copyWith(color: col) : Manager.bodyStyle.copyWith(color: Colors.white.withOpacity(.75)),
            ),
          ],
        ),
        onPressed: () => onCategoryPressed(index),
        expand: true,
        isWide: true,
        padding: const EdgeInsets.all(6),
        isSmall: false,
      ),
    );
  }
}
