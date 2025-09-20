import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/widgets/buttons/button.dart';

import '../../manager.dart';
import '../../screens/settings.dart';
import '../cutout.dart';

class SettingCategoryButton extends StatefulWidget {
  final int index;
  final bool isSelected;
  final void Function(int index) onCategoryPressed;

  const SettingCategoryButton(
    this.index, {
    super.key,
    required this.onCategoryPressed,
    this.isSelected = false,
  });

  @override
  State<SettingCategoryButton> createState() => _SettingCategoryButtonState();
}

class _SettingCategoryButtonState extends State<SettingCategoryButton> {
  @override
  Widget build(BuildContext context) {
    final thisButton = SettingsScreenState.settingsList[widget.index];
    final Icon icon = thisButton["icon"];
    final Color col = icon.color!;
    return Padding(
      padding: SettingsScreenState.settingsList.length != widget.index ? EdgeInsets.only(bottom: 8.0) : EdgeInsets.zero,
      child: StandardButton(
        label: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            widget.isSelected
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
              style: widget.isSelected ? Manager.bodyStrongStyle.copyWith(color: col) : Manager.bodyStyle.copyWith(color: Colors.white.withOpacity(.75)),
            ),
          ],
        ),
        onPressed: () => widget.onCategoryPressed(widget.index),
        expand: true,
        isWide: true,
        padding: const EdgeInsets.all(6),
        isSmall: false,
      ),
    );
  }
}

