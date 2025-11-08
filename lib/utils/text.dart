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
  return measureInlineSpan(
    TextSpan(text: text, style: style),
    maxLines: maxLines,
    textDirection: textDirection,
    minWidth: minWidth,
    maxWidth: maxWidth,
  );
}

double measureTextHeight(String text, {TextStyle? style, int maxLines = 1, TextDirection? textDirection, double minWidth = 0, double maxWidth = double.infinity}) => //
    measureText(text, style: style, maxLines: maxLines, textDirection: textDirection, minWidth: minWidth, maxWidth: maxWidth).height;

double measureTextWidth(String text, {TextStyle? style, int maxLines = 1, TextDirection? textDirection, double minWidth = 0, double maxWidth = double.infinity}) => //
    measureText(text, style: style, maxLines: maxLines, textDirection: textDirection, minWidth: minWidth, maxWidth: maxWidth).width;

Size measureInlineSpan(
  InlineSpan span, {
  int maxLines = 1,
  TextDirection? textDirection,
  double minWidth = 0,
  double maxWidth = double.infinity,
}) {
  final TextPainter textPainter = TextPainter(
    text: span,
    maxLines: maxLines,
    textDirection: textDirection ?? TextDirection.ltr,
  );
  
  // Count placeholder spans and set their dimensions if needed
  int placeholderCount = 0;
  span.visitChildren((InlineSpan child) {
    if (child is PlaceholderSpan) {
      placeholderCount++;
    }
    return true;
  });
  
  if (placeholderCount > 0) {
    // Set placeholder dimensions before layout
    textPainter.setPlaceholderDimensions(
      List.generate(placeholderCount, (_) => const PlaceholderDimensions(
        size: Size.zero,
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
      )),
    );
  }
  
  textPainter.layout(minWidth: minWidth, maxWidth: maxWidth);
  return textPainter.size;
}

String parseFormat(String? format) {
  return switch (format?.toUpperCase()) {
    'TV' => 'TV',
    'TV_SHORT' => 'TV Short',
    'MOVIE' => 'Movie',
    'SPECIAL' => 'Special',
    'OVA' => 'OVA',
    'ONA' => 'ONA',
    'MUSIC' => 'Music',
    // 'MANGA' => 'Manga',
    // 'NOVEL' => 'Novel',
    // 'ONE_SHOT' => 'One Shot',
    _ => '',
  };
}
