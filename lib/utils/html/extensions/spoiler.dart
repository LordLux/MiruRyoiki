import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../widgets/spoilerbox.dart';

class SpoilerTagExtension extends HtmlExtension {
  @override
  Set<String> get supportedTags => {"spoiler"};

  @override
  InlineSpan build(ExtensionContext context) {
    return WidgetSpan(
      child: Transform.translate(
        offset: const Offset(0, 3.5),
        child: SpoilerBox(
          child: Text(
            context.innerHtml,
            style: context.styledElement?.style.generateTextStyle(),
          ),
        ),
      ),
    );
  }
}
