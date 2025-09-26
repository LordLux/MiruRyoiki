import 'package:flutter/material.dart';

/// A custom clipper that returns an RRect (Rounded Rectangle)
/// inset by a specified amount from all sides.
class InwardRRectClipper extends CustomClipper<RRect> {
  final double inset;
  final BorderRadius borderRadius;
  final bool vertical;
  final bool horizontal;

  /// Creates an InwardRRectClipper with a specified inset and border radius.
  const InwardRRectClipper(
    this.inset, {
    this.borderRadius = BorderRadius.zero,
    this.vertical = true,
    this.horizontal = true,
  });

  @override
  RRect getClip(Size size) {
    // 1. Define the Rect (Rectangle) for the visible area.
    final double left = horizontal ? inset : 0;
    final double top = vertical ? inset : 0;
    final double right = horizontal ? size.width - inset : size.width;
    final double bottom = vertical ? size.height - inset : size.height;

    final Rect rect = Rect.fromLTRB(left, top, right, bottom);

    // 2. Apply the BorderRadius to the inset Rect to create the RRect.
    return RRect.fromRectAndCorners(
      rect,
      topLeft: horizontal ? borderRadius.topLeft : Radius.zero,
      topRight: horizontal ? borderRadius.topRight : Radius.zero,
      bottomLeft: vertical ? borderRadius.bottomLeft : Radius.zero,
      bottomRight: vertical ? borderRadius.bottomRight : Radius.zero,
    );
  }

  @override
  bool shouldReclip(covariant InwardRRectClipper oldClipper) {
    // Reclip if the inset or border radius changes.
    return oldClipper.inset != inset || oldClipper.borderRadius != borderRadius;
  }
}
