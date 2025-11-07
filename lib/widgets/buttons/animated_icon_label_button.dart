import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/utils/text.dart';
import 'package:miruryoiki/utils/time.dart';
import 'package:miruryoiki/widgets/buttons/button.dart';
import 'package:miruryoiki/widgets/tooltip_wrapper.dart';

import '../../manager.dart';
import '../animated_translate.dart';

class AnimatedIconLabelButton extends StatefulWidget {
  final Widget Function(bool isHovered) icon;
  final String label;
  final VoidCallback onPressed;
  final Duration tooltipWaitDuration;
  final String? tooltip;

  const AnimatedIconLabelButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.tooltipWaitDuration = const Duration(milliseconds: 400),
    this.tooltip,
  });

  @override
  State<StatefulWidget> createState() => _AnimatedIconLabelButtonState();
}

class _AnimatedIconLabelButtonState extends State<AnimatedIconLabelButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // final Duration shortDuration = mediumDuration * 3;
    final textWidth = measureTextWidth(widget.label) + 10;
    return AnimatedContainer(
      height: 30,
      duration: shortDuration,
      width: _isHovered ? textWidth + 24 : 30,
      curve: Curves.easeInOutQuad,
      child: TooltipWrapper(
        tooltip: widget.tooltip ?? '',
        child: (_) => MouseRegion(
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
                    child: Transform.translate(
                      offset: const Offset(-1, 0),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: AnimatedRotation(
                          turns: _isHovered ? 0 : 0,
                          duration: shortDuration,
                          child: widget.icon(_isHovered),
                        ),
                      ),
                    ),
                  ),
                  ClipRRect(
                    child: AnimatedOpacity(
                      opacity: _isHovered ? 1.0 : 0.0,
                      duration: shortDuration,
                      child: AnimatedTranslate(
                        offset: Offset(0, -0.5),
                        duration: shortDuration,
                        curve: Curves.easeInOutQuad,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 22.0, right: 8.0),
                          child: Text(
                            widget.label,
                            overflow: TextOverflow.visible,
                            softWrap: false,
                            maxLines: 1,
                            style: Manager.bodyStyle.copyWith(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
