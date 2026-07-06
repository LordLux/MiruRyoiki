import 'package:cached_network_image/cached_network_image.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';

import '../manager.dart';
import '../utils/logging.dart';
import '../utils/screen.dart';
import '../utils/time.dart';

/// Account avatar in the navigation pane that smoothly scales up when the
/// Accounts page is selected and shrinks back when another page is active.
///
/// This is a dedicated [StatefulWidget] driven by an explicit
/// [AnimationController] because fluent_ui reconstructs the pane item's
/// trailing subtree on every rebuild. An implicit animation (e.g.
/// `AnimatedScale`) loses its state on those rebuilds and snaps instead of
/// animating. Holding this widget with a [GlobalKey] keeps the same [State]
/// (and its controller) alive across rebuilds, so the scale can tween on
/// [didUpdateWidget].
class AnimatedAccountAvatar extends StatefulWidget {
  const AnimatedAccountAvatar({
    super.key,
    required this.avatarUrl,
    required this.isSelected,
    required this.onTap,
    this.link,
    this.avatarRadius = 17.0,
    this.normalScale = 1.0,
    this.selectedScale = 1.67,
  });

  final String avatarUrl;
  final bool isSelected;
  final VoidCallback onTap;
  final DeferredPointerHandlerLink? link;
  final double avatarRadius;
  final double normalScale;
  final double selectedScale;

  @override
  State<AnimatedAccountAvatar> createState() => _AnimatedAccountAvatarState();
}

class _AnimatedAccountAvatarState extends State<AnimatedAccountAvatar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: mediumDuration,
      value: widget.isSelected ? 1.0 : 0.0,
    );
    _scale = Tween<double>(begin: widget.normalScale, end: widget.selectedScale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack, reverseCurve: Curves.easeInBack),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedAccountAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarDiameter = widget.avatarRadius * 1.9;
    // Resolve the image at the largest scale so it stays crisp and doesn't reload on scale change.
    final realDiameter = widget.selectedScale * ScreenUtils.kDefaultPaneTileHeight;

    return Align(
      alignment: Alignment.centerRight,
      child: DeferPointer(
        link: widget.link,
        paintOnTop: true,
        child: SizedOverflowBox(
          size: Size.square(avatarDiameter),
          alignment: Alignment.bottomRight,
          child: ScaleTransition(
            scale: _scale,
            alignment: Alignment.bottomRight,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(widget.avatarRadius),
              child: CircleAvatar(
                backgroundImage: ResizeImage.resizeIfNeeded(
                  realDiameter.toInt(),
                  realDiameter.toInt(),
                  CachedNetworkImageProvider(
                    widget.avatarUrl,
                    errorListener: (error) {
                      logWarn('Failed to load Anilist avatar image: $error');
                    },
                  ),
                ),
                backgroundColor: Manager.accentColor.withOpacity(0.25),
                radius: widget.avatarRadius,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
