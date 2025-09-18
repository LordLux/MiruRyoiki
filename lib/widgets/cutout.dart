import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

/// A widget that creates a squircle (rounded rectangle) cutout overlay with a child widget
/// rendered inside the cutout area.
/// 
/// This widget captures the visual representation of its [child] and displays it within
/// a squircle-shaped cutout against a solid background color. The child is scaled to
/// fit within 60% of the container size and centered within the cutout.
/// 
/// The widget uses a two-step rendering process:
/// 1. Captures the child widget as an image off-screen
/// 2. Renders the captured image within a squircle cutout using blend modes
/// 
/// Example usage:
/// ```dart
/// SquircleCutoutWidget(
///   borderRadius: 12.0,
///   size: Size(50, 50),
///   color: Colors.blue,
///   child: Icon(Icons.star),
/// )
/// ```

class SquircleCutoutWidget extends StatelessWidget {
  /// The widget to be displayed inside the squircle cutout.
  /// 
  /// This widget will be captured as an image and rendered within the cutout area,
  /// scaled to 60% of the container size and centered.
  final Widget child;

  /// The border radius for the squircle corners.
  /// 
  /// Controls how rounded the corners of the squircle cutout appear.
  /// Defaults to 8.0.
  final double borderRadius;

  /// The size of the entire cutout widget.
  /// 
  /// Defines the dimensions of the container that holds the squircle cutout.
  /// The child will be scaled relative to this size.
  /// Defaults to Size(35, 35).
  final Size size;

  /// The background color of the squircle overlay.
  /// 
  /// This color fills the area around the cutout, creating the frame effect.
  /// Defaults to Colors.white.
  final Color color;
  
  const SquircleCutoutWidget({
    super.key,
    required this.child,
    this.borderRadius = 8.0,
    this.size = const Size(35, 35),
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return _SquircleCutoutBuilder(
      borderRadius: borderRadius,
      size: size,
      color: color,
      child: child,
    );
  }
}

class _SquircleCutoutBuilder extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final Size size;
  final Color color;

  const _SquircleCutoutBuilder({
    required this.child,
    required this.borderRadius,
    required this.size,
    required this.color,
  });

  @override
  State<_SquircleCutoutBuilder> createState() => _SquircleCutoutBuilderState();
}

class _SquircleCutoutBuilderState extends State<_SquircleCutoutBuilder> {
  ui.Image? _childImage;
  final GlobalKey _repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _captureChildImage());
  }

  @override
  void didUpdateWidget(_SquircleCutoutBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _captureChildImage());
    }
  }

  Future<void> _captureChildImage() async {
    try {
      final RenderRepaintBoundary boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: MediaQuery.of(context).devicePixelRatio);
      setState(() {
        _childImage = image;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Invisible child for capturing
        Positioned(
          top: -1000, // Move off-screen
          child: RepaintBoundary(
            key: _repaintKey,
            child: widget.child,
          ),
        ),
        // The actual cutout widget
        CustomPaint(
          painter: _SquircleCutoutPainter(
            childImage: _childImage,
            borderRadius: widget.borderRadius,
            color: widget.color,
          ),
          child: SizedBox.fromSize(size: widget.size),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _childImage?.dispose();
    super.dispose();
  }
}

class _SquircleCutoutPainter extends CustomPainter {
  final ui.Image? childImage;
  final double borderRadius;
  final Color color;

  _SquircleCutoutPainter({
    required this.childImage,
    required this.borderRadius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final squircleRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Paint for the white squircle with srcOut blend mode
    final squirclePaint = Paint()
      ..color = color
      ..blendMode = BlendMode.srcOut;

    // Save layer for the blend operation
    canvas.saveLayer(squircleRect, Paint());

    // First paint the child image (this will be the "hole")
    if (childImage != null) {
      _paintChildImage(canvas, size);
    }

    // Then paint the squircle with srcOut blend mode to cut out the child shape
    final squirclePath = _createSquirclePath(size);
    canvas.drawPath(squirclePath, squirclePaint);

    canvas.restore();
  }

  void _paintChildImage(Canvas canvas, Size size) {
    if (childImage == null) return;

    // Calculate scaling and positioning to center the child image
    final imageSize = Size(childImage!.width.toDouble(), childImage!.height.toDouble());
    final scale = (size.width * 0.6) / imageSize.width; // Scale to 60% of container

    final scaledSize = Size(imageSize.width * scale, imageSize.height * scale);
    final offset = Offset(
      (size.width - scaledSize.width) / 2,
      (size.height - scaledSize.height) / 2,
    );

    final srcRect = Rect.fromLTWH(0, 0, imageSize.width, imageSize.height);
    final dstRect = Rect.fromLTWH(offset.dx, offset.dy, scaledSize.width, scaledSize.height);

    final paint = Paint()
      ..color = Colors.black // Color doesn't matter for cutout
      ..filterQuality = FilterQuality.high;

    canvas.drawImageRect(childImage!, srcRect, dstRect, paint);
  }

  Path _createSquirclePath(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    final radius = borderRadius;

    // Create a squircle path
    path.moveTo(radius, 0);
    path.lineTo(width - radius, 0);
    path.quadraticBezierTo(width, 0, width, radius);
    path.lineTo(width, height - radius);
    path.quadraticBezierTo(width, height, width - radius, height);
    path.lineTo(radius, height);
    path.quadraticBezierTo(0, height, 0, height - radius);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant _SquircleCutoutPainter oldDelegate) {
    return childImage != oldDelegate.childImage || borderRadius != oldDelegate.borderRadius;
  }
}
