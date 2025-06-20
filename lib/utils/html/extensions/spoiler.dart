import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../widgets/spoilerbox.dart';

class SpoilerTagExtension extends HtmlExtension {
  // Static map to track revealed spoilers
  static final Map<String, bool> _revealedSpoilers = {};
  
  @override
  Set<String> get supportedTags => {"spoiler"};

  @override
  InlineSpan build(ExtensionContext context) {
    final String spoilerContent = context.innerHtml;
    final String spoilerId = _generateSpoilerId(spoilerContent);
    return WidgetSpan(
      child: Transform.translate(
        offset: const Offset(0, 3.5),
        child: SpoilerBox(
          id: spoilerId,
          initiallyRevealed: _revealedSpoilers[spoilerId] ?? false,
          onRevealChanged: (revealed) {
            _revealedSpoilers[spoilerId] = revealed;
          },
          child: Text(
            context.innerHtml,
            style: context.styledElement?.style.generateTextStyle(),
          ),
        ),
      ),
    );
  }

  // Generate a simple hash-based ID for the spoiler content
  String _generateSpoilerId(String content) {
    final bytes = utf8.encode(content);
    final digest = md5.convert(bytes);
    return digest.toString();
  }
}
