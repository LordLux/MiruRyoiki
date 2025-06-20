import 'package:fluent_ui/fluent_ui.dart';

/// A little code-style block with a left “gutter” line
/// and horizontal scrolling on long lines.
class CodeBlock extends StatelessWidget {
  /// The raw code string, including "\n" for newlines.
  final String code;

  /// Color of the left gutter bar.
  final Color gutterColor;

  /// Padding inside the card.
  final EdgeInsetsGeometry padding;

  /// Margin around the card.
  final EdgeInsetsGeometry? margin;

  /// Background color of the card.
  final Color? backgroundColor;

  /// Border color of the card.
  final Color? borderColor;

  const CodeBlock({
    super.key,
    required this.code,
    this.gutterColor = Colors.grey,
    this.padding = const EdgeInsets.all(12.0),
    this.margin,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      padding: padding,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      child: IntrinsicHeight(
        // ensures children match height
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch, // makes gutter fill height
          children: [
            Container(
              width: 4,
              color: gutterColor,
            ),

            const SizedBox(width: 8),

            // Expanded so the scroll-view takes all remaining width
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    code,
                    style: const TextStyle(
                      fontFamily: 'monospace', // or whichever font you like
                      fontSize: 14,
                    ),
                    softWrap: false, // disable soft wrapping
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
