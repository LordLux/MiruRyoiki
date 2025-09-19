import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

import '../manager.dart';

class SimpleHtmlParser {
  final BuildContext context;

  SimpleHtmlParser(this.context);

  /// Parses HTML string and returns a RichText or SelectableText widget
  /// [html] - The HTML string to parse
  /// [selectable] - If true, returns a SelectableText widget with purple selection color
  Widget parse(String html, {bool selectable = false, Color? selectionColor}) {
    selectionColor ??= Manager.accentColor;
    final spans = _parseHtml(html);

    if (selectable) {
      return Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: selectionColor.withOpacity(0.3),
            selectionHandleColor: selectionColor,
          ),
        ),
        child: SelectableText.rich(
          TextSpan(
            children: spans,
            style: Manager.bodyStyle,
          ),
          selectionControls: fluent.fluentTextSelectionControls,
          cursorColor: selectionColor,
          selectionHeightStyle: ui.BoxHeightStyle.tight,
          selectionWidthStyle: ui.BoxWidthStyle.tight,
        ),
      );
    } else {
      return RichText(
        text: TextSpan(
          children: spans,
          style: Manager.bodyStyle,
        ),
      );
    }
  }

  /// Parses HTML and returns list of TextSpans
  List<InlineSpan> _parseHtml(String html) {
    List<InlineSpan> result = [];

    // Clean up the HTML
    html = html.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

    // Stack to keep track of open tags and their styles
    List<_TagInfo> tagStack = [];

    // Current position in the string
    int currentPos = 0;

    // Regular expression to find tags
    final tagRegex = RegExp(r'<(/?)([^>]+)>');

    for (final match in tagRegex.allMatches(html)) {
      // Add any text before this tag
      if (match.start > currentPos) {
        String text = html.substring(currentPos, match.start);
        if (text.isNotEmpty) {
          result.add(_createTextSpan(text, tagStack));
        }
      }

      bool isClosingTag = match.group(1) == '/';
      String tagContent = match.group(2)!.toLowerCase().trim();
      String tagName = tagContent.split(' ')[0];

      if (isClosingTag) {
        // Remove the tag from the stack
        tagStack.removeWhere((tag) => tag.name == tagName);

        // Add line breaks for block elements
        if (_isBlockElement(tagName)) {
          result.add(const TextSpan(text: '\n\n'));
        }
      } else {
        // Handle self-closing br tag
        if (tagName == 'br') {
          result.add(const TextSpan(text: '\n'));
        } else {
          // Add the tag to the stack
          tagStack.add(_TagInfo(tagName));

          // Add line breaks for block elements
          if (_isBlockElement(tagName) && result.isNotEmpty) {
            result.add(const TextSpan(text: '\n\n'));
          }
        }
      }

      currentPos = match.end;
    }

    // Add any remaining text
    if (currentPos < html.length) {
      String text = html.substring(currentPos);
      if (text.isNotEmpty) {
        result.add(_createTextSpan(text, tagStack));
      }
    }

    return result;
  }

  /// Creates a TextSpan with appropriate style based on tag stack
  TextSpan _createTextSpan(String text, List<_TagInfo> tagStack) {
    TextStyle style = Manager.bodyStyle;

    // Process tags to determine final style
    bool isBold = false;
    bool isItalic = false;
    String? headerTag;

    for (final tag in tagStack) {
      switch (tag.name) {
        case 'b':
        case 'strong':
          isBold = true;
          break;
        case 'i':
        case 'em':
          isItalic = true;
          break;
        case 'h1':
        case 'h2':
        case 'h3':
        case 'h4':
          headerTag = tag.name;
          break;
        case 'p':
          // Keep default style for p
          break;
      }
    }

    // Apply header styles
    if (headerTag != null) {
      switch (headerTag) {
        case 'h1':
          style = Manager.displayStyle;
          break;
        case 'h2':
          style = Manager.titleLargeStyle;
          break;
        case 'h3':
          style = Manager.titleStyle;
          break;
        case 'h4':
          style = Manager.subtitleStyle;
          break;
      }
    } else if (isBold) {
      // Use bodyStrongStyle for bold text in paragraphs
      style = Manager.bodyStrongStyle;
    }

    // Apply italic if needed (on top of existing style)
    if (isItalic) {
      style = style.copyWith(fontStyle: FontStyle.italic);
    }

    // If both bold and italic in a non-header context
    if (isBold && isItalic && headerTag == null) {
      style = Manager.bodyStrongStyle.copyWith(fontStyle: FontStyle.italic);
    }

    return TextSpan(
      text: text,
      style: style,
    );
  }

  /// Checks if a tag is a block element
  bool _isBlockElement(String tagName) {
    return ['p', 'h1', 'h2', 'h3', 'h4'].contains(tagName);
  }
}

/// Helper class to store tag information
class _TagInfo {
  final String name;

  _TagInfo(this.name);
}