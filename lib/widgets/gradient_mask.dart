

import 'package:flutter/material.dart';

class GradientMask extends StatelessWidget {
  final Alignment begin;
  final Alignment end;
  final List<Color> colors;
  final List<double> stops;
  final BlendMode blendMode;
  final Widget child;

  const GradientMask({
    super.key,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    required this.colors,
    this.stops = const [0.0, 1.0],
    this.blendMode = BlendMode.srcOver,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
          stops: stops,
        ).createShader(bounds);
      },
      blendMode: blendMode,
      child: child,
    );
  }
}
