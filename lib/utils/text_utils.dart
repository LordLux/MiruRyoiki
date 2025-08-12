import 'package:fluent_ui/fluent_ui.dart';

import '../manager.dart';
import 'color_utils.dart';

TextStyle getStyleBasedOnAccent(bool isFilled) => isFilled ? Manager.bodyStyle.copyWith(color: getPrimaryColorBasedOnAccent()) : Manager.bodyStyle;
