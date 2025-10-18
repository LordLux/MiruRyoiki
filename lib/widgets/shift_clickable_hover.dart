
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:miruryoiki/utils/screen.dart';

import '../manager.dart';
import '../models/series.dart';
import '../services/navigation/shortcuts.dart';
import '../utils/time.dart';

class ShiftClickableHover extends StatefulWidget {
  const ShiftClickableHover({
    super.key,
    required this.series,
    required this.enabled,
    required this.onEnter,
    required this.onHover,
    required this.onExit,
    required this.onTap,
    required this.finalChild,
  });

  final Series series;
  final bool enabled;
  final VoidCallback onEnter;
  final VoidCallback? onHover;
  final VoidCallback onExit;
  final void Function(BuildContext)? onTap;
  final Widget Function(BuildContext, bool) finalChild;

  @override
  State<ShiftClickableHover> createState() => _ShiftClickableHoverState();
}

class _ShiftClickableHoverState extends State<ShiftClickableHover> {
  bool _isHovered = false;
  bool? _lastShift;

  @override
  void initState() {
    super.initState();
    // 1) Initialize _lastShift so the first shift‐toggle is recognized
    _lastShift = KeyboardState.shiftPressedNotifier.value;
    // 2) Add our listener once
    KeyboardState.shiftPressedNotifier.addListener(_onShiftChanged);
  }

  @override
  void dispose() {
    KeyboardState.shiftPressedNotifier.removeListener(_onShiftChanged);
    super.dispose();
  }

  void _onShiftChanged() {
    final isShift = KeyboardState.shiftPressedNotifier.value;

    // 3) If pointer is inside AND the shift state actually flipped…
    if (_isHovered && isShift != _lastShift) {
      // …then re-fire your hover/enter logic on the next frame
      nextFrame(() {
        if (widget.onHover != null) {
          widget.onHover!();
        } else {
          widget.onEnter();
        }
      });
    }

    // 4) Store for next time, and rebuild to update cursor/color/child
    _lastShift = isShift;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isShiftPressed = KeyboardState.shiftPressedNotifier.value;

    return MouseRegion(
      cursor: isShiftPressed && widget.enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) {
        _isHovered = true;
        widget.onEnter();
      },
      onExit: (_) {
        _isHovered = false;
        widget.onExit();
      },
      onHover: (_) {
        widget.onHover?.call();
      },
      hitTestBehavior: HitTestBehavior.translucent,
      child: mat.Material(
        color: Colors.transparent,
        child: mat.InkWell(
          onTap: isShiftPressed && widget.enabled ? () => widget.onTap?.call(context) : null,
          splashColor: (widget.series.localPosterColor ?? Manager.accentColor).withOpacity(1),
          borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
          child: AnimatedContainer(
            duration: shortStickyHeaderDuration,
            decoration: BoxDecoration(
              color: (widget.series.localPosterColor ?? Manager.accentColor).withOpacity(
                isShiftPressed && widget.enabled ? .15 : 0,
              ),
              borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
            ),
            child: widget.finalChild(
              context,
              isShiftPressed && widget.enabled,
            ),
          ),
        ),
      ),
    );
  }
}
