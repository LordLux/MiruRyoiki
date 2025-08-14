import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/widgets/buttons/button.dart';

import '../../screens/settings.dart';

class SettingCategoryButton extends StandardButton {
  final int index;
  final bool isSelected;

  SettingCategoryButton(
    this.index, {
    super.key,
    required void Function(int index) onPressed,
    this.isSelected = false,
  }) : super(
          label: Text(SettingsScreenState.settingsList[index] ?? ""),
          onPressed: () => onPressed(index),
          expand: true,
        );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: super.build(context),
    );
  }
}
