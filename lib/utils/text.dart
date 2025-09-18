import 'package:fluent_ui/fluent_ui.dart';

import '../manager.dart';
import 'color.dart';

TextStyle getStyleBasedOnAccent(bool isFilled, {TextStyle? style}) => isFilled ? (style ?? Manager.bodyStyle).copyWith(color: getPrimaryColorBasedOnAccent()) : (style ?? Manager.bodyStyle);
