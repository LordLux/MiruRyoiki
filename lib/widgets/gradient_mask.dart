import 'package:flutter/material.dart';

class FadingEdgeScrollView extends StatefulWidget {
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

  /// Duration for animations when gradientColors or gradientStops change
  final Duration animationDuration;

  const FadingEdgeScrollView({
    super.key,
    required this.child,
    this.fadeEdges = const EdgeInsets.symmetric(vertical: 32.0),
    this.gradientColors,
    this.gradientStops,
    this.debug = false,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<FadingEdgeScrollView> createState() => _FadingEdgeScrollViewState();
}

class _FadingEdgeScrollViewState extends State<FadingEdgeScrollView> {
  late List<Color> _colors;
  late List<double> _stops;

  @override
  void initState() {
    super.initState();
    // Will be initialized properly in build
    _colors = [];
    _stops = [];
  }

  List<Color> _getDefaultColors(bool debug) {
    return debug
        ? [
            Colors.red.withOpacity(1),
            Colors.red.withOpacity(.75),
            Colors.blue.withOpacity(.15),
            Colors.blue.withOpacity(.15),
            Colors.red.withOpacity(.75),
            Colors.red.withOpacity(1),
          ]
        : [
            Colors.black.withOpacity(0),
            Colors.black.withOpacity(.5),
            Colors.black,
            Colors.black,
            Colors.black.withOpacity(.5),
            Colors.black.withOpacity(0),
          ];
  }

  List<double> _getDefaultStops(Rect bounds) {
    return [
      0.01,
      (widget.fadeEdges.top / bounds.height) - 0.02,
      widget.fadeEdges.top / bounds.height,
      1 - (widget.fadeEdges.bottom / bounds.height),
      1 - (widget.fadeEdges.bottom / bounds.height) + 0.02,
      0.99,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Rect bounds = Offset.zero & constraints.biggest;
        
        // Get current values
        final List<Color> targetColors = widget.debug 
            ? _getDefaultColors(true) 
            : (widget.gradientColors ?? _getDefaultColors(false));
        final List<double> targetStops = widget.gradientStops ?? _getDefaultStops(bounds);

        // Initialize if needed
        if (_colors.isEmpty) {
          _colors = targetColors;
        }
        if (_stops.isEmpty) {
          _stops = targetStops;
        }

        return TweenAnimationBuilder<_GradientProps>(
          tween: _GradientPropsTween(
            begin: _GradientProps(colors: _colors, stops: _stops),
            end: _GradientProps(colors: targetColors, stops: targetStops),
          ),
          duration: widget.animationDuration,
          onEnd: () {
            // Update the current values when animation ends
            _colors = targetColors;
            _stops = targetStops;
          },
          builder: (context, value, child) {
            return ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: value.colors,
                  stops: value.stops,
                ).createShader(bounds);
              },
              blendMode: widget.debug ? BlendMode.src : BlendMode.dstIn,
              child: widget.child,
            );
          },
        );
      },
    );
  }
}

/// Helper class to store gradient properties
class _GradientProps {
  final List<Color> colors;
  final List<double> stops;

  _GradientProps({required this.colors, required this.stops});
}

/// Custom Tween to animate between gradient properties
class _GradientPropsTween extends Tween<_GradientProps> {
  _GradientPropsTween({required _GradientProps begin, required _GradientProps end})
      : super(begin: begin, end: end);

  @override
  _GradientProps lerp(double t) {
    // If the color or stop lists have different lengths, we'll need to handle that
    final int colorCount = begin!.colors.length;
    final int endColorCount = end!.colors.length;
    
    final int stopCount = begin!.stops.length;
    final int endStopCount = end!.stops.length;

    // Handle interpolation based on list lengths
    List<Color> lerpedColors;
    if (colorCount == endColorCount) {
      // Simple case: interpolate each color
      lerpedColors = List.generate(colorCount, (i) {
        return Color.lerp(begin!.colors[i], end!.colors[i], t)!;
      });
    } else {
      // Complex case: crossfade by opacity
      lerpedColors = t < 0.5 
          ? begin!.colors.map((c) => c.withOpacity((0.5 - t) * 2 * c.opacity)).toList()
          : end!.colors.map((c) => c.withOpacity((t - 0.5) * 2 * c.opacity)).toList();
    }

    List<double> lerpedStops;
    if (stopCount == endStopCount) {
      // Simple case: interpolate each stop
      lerpedStops = List.generate(stopCount, (i) {
        return begin!.stops[i] + (end!.stops[i] - begin!.stops[i]) * t;
      });
    } else {
      // Complex case: just switch halfway through
      lerpedStops = t < 0.5 ? begin!.stops : end!.stops;
    }

    return _GradientProps(colors: lerpedColors, stops: lerpedStops);
  }
}