import 'package:flutter/material.dart';

class FadingEdgeScrollView extends StatelessWidget {
  /// The scrollable child (ListView, SingleChildScrollView, etc.)
  final Widget child;

  /// The size of fade regions at each edge (top, right, bottom, left)
  /// Only top and bottom values are used.
  final EdgeInsets fadeEdges;

  /// The colors of the gradient mask. Usually black with various alpha levels.
  /// Default: [ transparent, opaque, opaque, transparent ]
  final List<Color>? gradientColors;

  /// The stops for each color, values 0.0–1.0.
  /// Default: calculated based on fadeEdges.top and fadeEdges.bottom
  final List<double>? gradientStops;

  /// Whether to show debug information (gradient bounds and colored overlay).
  final bool debug;

  const FadingEdgeScrollView({
    super.key,
    required this.child,
    this.fadeEdges = const EdgeInsets.symmetric(vertical: 32.0),
    this.gradientColors,
    this.gradientStops,
    this.debug = false,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        // If user provided both colors & stops, use them directly.
        final colors = debug
            ? [
                Colors.red.withOpacity(1),
                Colors.red.withOpacity(.75),
                Colors.blue.withOpacity(.15),
                Colors.blue.withOpacity(.15),
                Colors.red.withOpacity(.75),
                Colors.red.withOpacity(1),
              ]
            : gradientColors ??
                [
                  Colors.black.withOpacity(0),
                  Colors.black.withOpacity(.25),
                  Colors.black,
                  Colors.black,
                  Colors.black.withOpacity(.25),
                  Colors.black.withOpacity(0),
                ];
        final stops = gradientStops ??
            [
              0.01,
              (fadeEdges.top / bounds.height) - 0.02,
              fadeEdges.top / bounds.height,
              1 - (fadeEdges.bottom / bounds.height),
              1 - (fadeEdges.bottom / bounds.height) + 0.02,
              0.99,
            ];

        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: stops,
        ).createShader(bounds);
      },
      blendMode: debug ? BlendMode.darken : BlendMode.dstIn,
      child: child,
    );
  }
}