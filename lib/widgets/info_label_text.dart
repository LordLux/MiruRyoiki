import 'package:fluent_ui/fluent_ui.dart';

import '../manager.dart';

InfoLabel InfoLabelText({required String label, required String text, TextStyle? labelStyle, TextStyle? textStyle}) {
  return InfoLabel(
    label: label,
    labelStyle: labelStyle ?? Manager.bodyStrongStyle,
    child: Text(text, style: textStyle ?? Manager.bodyStyle.copyWith(fontSize: 13 * Manager.fontSizeMultiplier)),
  );
}
