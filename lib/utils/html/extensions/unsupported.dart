import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_html/flutter_html.dart';

class UnsupportedBlockExtension extends HtmlExtension {
  @override
  Set<String> get supportedTags => {"unsupported"};

  @override
  InlineSpan build(ExtensionContext context) {
    final String html = context.element!.innerHtml;
    final String text = html.replaceAll("<br>", "\n");
    return WidgetSpan(
      child: SelectionContainer.disabled(child: MouseRegion(cursor: SystemMouseCursors.forbidden, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Text(text, style: TextStyle(fontStyle: FontStyle.italic))))),
    );
  }
}
