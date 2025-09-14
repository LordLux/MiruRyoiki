import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter_custom_cursor/flutter_custom_cursor.dart';

import '../manager.dart';
import '../utils/time_utils.dart';
import 'cursors.dart';

class AnimatedReorderableTile extends StatefulWidget {
  final String listName;
  final String displayName;
  final int index;
  final bool selected;
  final bool isReordering;
  final bool initialAnimation;
  final bool reorderable;
  final void Function(int index)? onPressed;

  const AnimatedReorderableTile({
    required super.key,
    required this.listName,
    required this.displayName,
    required this.index,
    required this.selected,
    required this.isReordering,
    this.initialAnimation = false,
    this.reorderable = true,
    this.onPressed,
  });

  @override
  State<AnimatedReorderableTile> createState() => _AnimatedReorderableTileState();
}

class _AnimatedReorderableTileState extends State<AnimatedReorderableTile> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // Create the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: dimDuration,
    );

    // Create the color tween
    _colorAnimation = ColorTween(
      begin: Colors.white.withOpacity(.05),
      end: Color.lerp(Colors.white.withOpacity(.15), Manager.accentColor, .75)!,
    ).animate(_animationController);

    // If initially selected, start the animation
    if (widget.selected || widget.initialAnimation) {
      _animationController.value = widget.initialAnimation ? 0.0 : 1.0;
      if (widget.initialAnimation) {
        _animationController.forward();
      }
    }
  }

  @override
  void didUpdateWidget(AnimatedReorderableTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If selected state changed, animate accordingly
    if (oldWidget.selected != widget.selected) {
      if (widget.selected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: widget.index,
      child: MouseRegion(
        cursor: widget.reorderable ? FlutterCustomMemoryImageCursor(key: widget.isReordering ? systemMouseCursorGrabbing : systemMouseCursorGrab) : SystemMouseCursors.click,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            // Get animated color based on selection state
            final Color tileColor = widget.selected
                ? _colorAnimation.value!
                : _animationController.isDismissed
                    ? Colors.white.withOpacity(.05)
                    : _colorAnimation.value!;

            return ListTile(
              onPressed: () => widget.onPressed?.call(widget.index),
              margin: EdgeInsets.only(top: 4),
              tileColor: WidgetStatePropertyAll(tileColor),
              title: Text(widget.displayName, style: Manager.bodyStyle),
              leading: widget.reorderable ? Icon(!widget.selected ? Icons.drag_handle : FluentIcons.drag_object, size: 12 * Manager.fontSizeMultiplier) : null,
              contentPadding: widget.reorderable ? kDefaultListTilePadding : EdgeInsets.symmetric(horizontal: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            );
          },
        ),
      ),
    );
  }
}
