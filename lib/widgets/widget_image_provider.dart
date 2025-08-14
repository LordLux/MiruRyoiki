import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// An ImageProvider that renders a Widget as a raster image.
/// Useful for placing widgets in contexts that require an ImageProvider,
/// such as Google Maps markers or custom painting.
class WidgetImageProvider extends ImageProvider<WidgetImageProvider> {
  /// The widget to render as an image.
  final Widget widget;

  /// The scale of the image.
  final double scale;

  /// The size of the image in logical pixels.
  final Size size;

  /// The background color for the image (optional).
  final Color? backgroundColor;

  /// Constructs a WidgetImageProvider.
  const WidgetImageProvider(
    this.widget, {
    this.scale = 1.0,
    required this.size,
    this.backgroundColor,
  });

  @override
  Future<WidgetImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<WidgetImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(WidgetImageProvider key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: key.scale,
      debugLabel: 'WidgetImageProvider(${key.widget})',
    );
  }

  Future<ui.Codec> _loadAsync(WidgetImageProvider key) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // Optionally paint a background color
    if (backgroundColor != null) {
      final paint = Paint()..color = backgroundColor!;
      canvas.drawRect(Offset.zero & size, paint);
    }

    // Use a RenderRepaintBoundary to render the widget to an image
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

    final RenderView renderView = RenderView(
      view: WidgetsBinding.instance.platformDispatcher.views.first,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(
        physicalConstraints: BoxConstraints(
          maxWidth: size.width,
          maxHeight: size.height,
        ),
        devicePixelRatio: ui.window.devicePixelRatio,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    renderView.attach(pipelineOwner);
    pipelineOwner.rootNode = renderView;

    final BuildOwner buildOwner = BuildOwner();
    final RenderObjectToWidgetElement<RenderBox> rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: widget,
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final ui.Image image = await repaintBoundary.toImage(
      pixelRatio: ui.window.devicePixelRatio,
    );

    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List bytes = byteData!.buffer.asUint8List();
    final ui.ImmutableBuffer immutableBuffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final ui.ImageDescriptor descriptor = await ui.ImageDescriptor.encoded(immutableBuffer);

    return descriptor.instantiateCodec(
      targetHeight: size.height.toInt(),
      targetWidth: size.width.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is WidgetImageProvider && other.widget == widget && other.scale == scale && other.size == size && other.backgroundColor == backgroundColor;
  }

  @override
  int get hashCode => Object.hash(widget, scale, size, backgroundColor);

  @override
  String toString() => '$runtimeType($widget, scale: $scale, size: $size, backgroundColor: $backgroundColor)';
}
