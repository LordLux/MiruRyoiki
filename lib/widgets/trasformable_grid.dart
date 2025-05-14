import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A grid that can display widgets in an infinitely repeating pattern
/// with transformation options and caching for performance.
class TransformableGrid extends StatefulWidget {
  /// The widgets to display in the repeating grid pattern
  final List<Widget> children;

  /// Number of items per row in the pattern
  final int crossAxisCount;

  /// Spacing between grid items
  final double spacing;

  /// Horizontal offset of the entire grid
  final double xOffset;

  /// Vertical offset of the entire grid
  final double yOffset;

  /// Rotation in degrees for the entire grid
  final double globalRotation;

  /// Color to overlay on all widgets (null keeps original colors)
  final Color? overlayColor;

  /// How the overlay color should be applied
  final BlendMode colorBlendMode;

  /// Size of each grid cell
  final double cellSize;

  /// Number of pattern repetitions to render (higher values fill more space)
  final int repetitions;

  const TransformableGrid({
    super.key,
    required this.children,
    required this.crossAxisCount,
    this.spacing = 8.0,
    this.xOffset = 0.0,
    this.yOffset = 0.0,
    this.globalRotation = 0.0,
    this.overlayColor,
    this.colorBlendMode = BlendMode.srcATop,
    this.cellSize = 100.0,
    this.repetitions = 5,
  });

  @override
  State<TransformableGrid> createState() => _TransformableGridState();
}

class _TransformableGridState extends State<TransformableGrid> {
  final List<GlobalKey> _widgetKeys = [];
  final Map<int, ui.Image?> _imageCache = {};
  bool _widgetsRendered = false;

  @override
  void initState() {
    super.initState();
    _initWidgetKeys();
  }

  @override
  void didUpdateWidget(TransformableGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children != widget.children || oldWidget.cellSize != widget.cellSize) {
      _initWidgetKeys();
      _imageCache.clear();
      _widgetsRendered = false;
    }
  }

  void _initWidgetKeys() {
    _widgetKeys.clear();
    for (int i = 0; i < widget.children.length; i++) {
      _widgetKeys.add(GlobalKey());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!_widgetsRendered) {
      // First render: create off-screen widgets with RepaintBoundary
      return Stack(
        children: [
          // Invisible stack of widgets to render
          Opacity(
            opacity: 0.0,
            child: Stack(
              children: List<Widget>.generate(
                widget.children.length,
                (index) => RepaintBoundary(
                  key: _widgetKeys[index],
                  child: SizedBox(
                    width: widget.cellSize,
                    height: widget.cellSize,
                    child: Center(child: widget.children[index]),
                  ),
                ),
              ),
            ),
          ),
          // This will trigger the post-frame callback
          Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _captureWidgets().then((_) {
                  setState(() {
                    _widgetsRendered = true;
                  });
                });
              });
              return const SizedBox();
            },
          ),
        ],
      );
    }

    // Subsequent renders: use the cached images
    return LayoutBuilder(
      builder: (context, constraints) {
        return Transform.rotate(
          angle: widget.globalRotation * (pi / 180),
          alignment: Alignment.center,
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _InfiniteGridPainter(
              imageCache: _imageCache,
              childCount: widget.children.length,
              crossAxisCount: widget.crossAxisCount,
              spacing: widget.spacing,
              xOffset: widget.xOffset,
              yOffset: widget.yOffset,
              overlayColor: widget.overlayColor,
              colorBlendMode: widget.colorBlendMode,
              cellSize: widget.cellSize,
              repetitions: widget.repetitions,
            ),
          ),
        );
      },
    );
  }

  Future<void> _captureWidgets() async {
    for (int i = 0; i < _widgetKeys.length; i++) {
      await _captureWidget(i);
    }
  }

  Future<void> _captureWidget(int index) async {
    final RenderRepaintBoundary boundary = _widgetKeys[index].currentContext?.findRenderObject() as RenderRepaintBoundary;

    if (boundary.debugNeedsPaint) {
      await Future.delayed(const Duration(milliseconds: 100));
      return _captureWidget(index);
    }

    final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    _imageCache[index] = image;
  }
}

class _InfiniteGridPainter extends CustomPainter {
  final Map<int, ui.Image?> imageCache;
  final int childCount;
  final int crossAxisCount;
  final double spacing;
  final double xOffset;
  final double yOffset;
  final Color? overlayColor;
  final BlendMode colorBlendMode;
  final double cellSize;
  final int repetitions;

  _InfiniteGridPainter({
    required this.imageCache,
    required this.childCount,
    required this.crossAxisCount,
    required this.spacing,
    required this.xOffset,
    required this.yOffset,
    required this.overlayColor,
    required this.colorBlendMode,
    required this.cellSize,
    required this.repetitions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Skip if no images are cached yet
    if (imageCache.isEmpty) return;

    // Apply global translation
    canvas.translate(xOffset, yOffset);

    // Calculate grid parameters
    final double patternWidth = (cellSize + spacing) * crossAxisCount;
    final int rowCount = (childCount / crossAxisCount).ceil();
    final double patternHeight = (cellSize + spacing) * rowCount;

    // Calculate how many repetitions we need to fill the space with some overflow
    final int horizontalReps = (size.width / patternWidth).ceil() + repetitions;
    final int verticalReps = (size.height / patternHeight).ceil() + repetitions;

    // Calculate starting offsets to center the pattern
    final double startX = (size.width - horizontalReps * patternWidth) / 2;
    final double startY = (size.height - verticalReps * patternHeight) / 2;

    // Set up paint for coloring if needed
    final Paint paint = Paint();
    if (overlayColor != null) {
      paint.colorFilter = ColorFilter.mode(overlayColor!, colorBlendMode);
    }

    // Draw the repeating pattern
    for (int y = -verticalReps; y < verticalReps * 2; y++) {
      for (int x = -horizontalReps; x < horizontalReps * 2; x++) {
        // Calculate the top-left corner of this repetition block
        final double blockX = startX + x * patternWidth;
        final double blockY = startY + y * patternHeight;

        // Draw all widgets in this repetition block
        for (int i = 0; i < childCount; i++) {
          final int row = i ~/ crossAxisCount;
          final int col = i % crossAxisCount;

          final double itemX = blockX + col * (cellSize + spacing);
          final double itemY = blockY + row * (cellSize + spacing);

          final ui.Image? image = imageCache[i];
          if (image != null) {
            final Rect rect = Rect.fromLTWH(itemX, itemY, cellSize, cellSize);
            canvas.drawImageRect(
              image,
              Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
              rect,
              paint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _InfiniteGridPainter oldDelegate) {
    return oldDelegate.spacing != spacing || oldDelegate.xOffset != xOffset || oldDelegate.yOffset != yOffset || oldDelegate.overlayColor != overlayColor || oldDelegate.colorBlendMode != colorBlendMode || oldDelegate.cellSize != cellSize || oldDelegate.repetitions != repetitions || oldDelegate.imageCache != imageCache;
  }
}
