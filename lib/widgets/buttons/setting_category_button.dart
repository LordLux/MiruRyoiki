import 'package:fluent_ui/fluent_ui.dart';
import '../../screens/settings.dart';
import 'category_tile_button.dart';

class SettingCategoryButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final thisButton = SettingsScreenState.settingsList[index];
    final Icon icon = thisButton["icon"];
    final Color col = icon.color!;

    return CategoryTileButton(
      title: thisButton["title"] ?? "",
      icon: icon.icon!,
      color: col,
      isSelected: isSelected,
      onPressed: () => onCategoryPressed(index),
      bottomPadding: SettingsScreenState.settingsList.length - 1 != index ? 8.0 : 0.0,
    );
  }
}
