import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../widgets/codeblock.dart';

class CodeBlockExtension extends HtmlExtension {
  @override
  Set<String> get supportedTags => {"code"};

  @override
  InlineSpan build(ExtensionContext context) {
    final String html = context.element!.innerHtml;
    final String text = html.replaceAll("<br>", "\n");
    return WidgetSpan(
      child: Transform.translate(
        offset: const Offset(0, 3.5),
        child: CodeBlock(
          padding: const EdgeInsets.all(4),
          code: text,
        ),
      ),
    );
  }
}
