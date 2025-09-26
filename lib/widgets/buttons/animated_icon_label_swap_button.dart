import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/utils/text.dart';
import 'package:miruryoiki/utils/time.dart';
import 'package:miruryoiki/widgets/buttons/button.dart';

import '../../manager.dart';
import '../animated_translate.dart';

class AnimatedIconLabelButton extends StatefulWidget {
  final Widget icon;
  final String label;
  final VoidCallback onPressed;

  const AnimatedIconLabelButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  State<StatefulWidget> createState() => _AnimatedIconLabelButtonState();
}

class _AnimatedIconLabelButtonState extends State<AnimatedIconLabelButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // final Duration shortDuration = mediumDuration * 3;
    final textWidth = measureTextWidth(widget.label);
    return AnimatedContainer(
      height: 30,
      duration: shortDuration,
      width: _isHovered ? textWidth + 30 : 30,
      curve: Curves.easeInOutQuad,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: StandardButton.icon(
            onPressed: widget.onPressed,
            icon: Stack(
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.centerRight,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedTranslate(
                    offset: _isHovered ? Offset(-textWidth + 9, 1) : Offset(-1, 0),
                    duration: shortDuration,
                    curve: Curves.easeInOutQuad,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: AnimatedRotation(
                        turns: _isHovered ? 0 : 0,
                        duration: shortDuration,
                        child: widget.icon,
                      ),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _isHovered ? 1.0 : 0.0,
                  duration: _isHovered ? shortDuration * 3 : shortDuration / 2, // shorter when hiding
                  child: AnimatedTranslate(
                    offset: _isHovered ? Offset.zero : Offset(textWidth, 0),
                    duration: shortDuration,
                    curve: Curves.easeInOutQuad,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 28.0),
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        style: Manager.bodyStyle.copyWith(fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
