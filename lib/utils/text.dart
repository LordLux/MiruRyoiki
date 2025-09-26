import 'package:fluent_ui/fluent_ui.dart';

import '../manager.dart';
import 'color.dart';

TextStyle getStyleBasedOnAccent(bool isFilled, {TextStyle? style}) => isFilled ? (style ?? Manager.bodyStyle).copyWith(color: getPrimaryColorBasedOnAccent()) : (style ?? Manager.bodyStyle);

Size measureText(
  String text, {
  TextStyle? style,
  int maxLines = 1,
  TextDirection? textDirection,
  double minWidth = 0,
  double maxWidth = double.infinity,
}) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style ?? Manager.bodyStyle),
    maxLines: maxLines,
    textDirection: textDirection ?? TextDirection.ltr,
  )..layout(minWidth: minWidth, maxWidth: maxWidth);
  return textPainter.size;
}

double measureTextHeight(String text, {TextStyle? style, int maxLines = 1, TextDirection? textDirection, double minWidth = 0, double maxWidth = double.infinity}) => //
    measureText(text, style: style, maxLines: maxLines, textDirection: textDirection, minWidth: minWidth, maxWidth: maxWidth).height;

double measureTextWidth(String text, {TextStyle? style, int maxLines = 1, TextDirection? textDirection, double minWidth = 0, double maxWidth = double.infinity}) => //
    measureText(text, style: style, maxLines: maxLines, textDirection: textDirection, minWidth: minWidth, maxWidth: maxWidth).width;
