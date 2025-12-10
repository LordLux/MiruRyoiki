import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AlphaMask extends MultiChildRenderObjectWidget {
  AlphaMask({
    super.key,
    required Widget background,
    required Widget mask,
    this.alignment = AlignmentDirectional.topStart,
    this.fit = StackFit.loose,
  }) : super(children: [background, mask]);

  final AlignmentGeometry alignment;
  final StackFit fit;

  @override
  RenderAlphaMask createRenderObject(BuildContext context) {
    return RenderAlphaMask(
      alignment: alignment,
      fit: fit,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderAlphaMask renderObject) {
    renderObject
      ..alignment = alignment
      ..fit = fit
      ..textDirection = Directionality.of(context);
  }
}

class RenderAlphaMask extends RenderStack {
  RenderAlphaMask({
    super.children,
    super.alignment,
    super.textDirection,
    super.fit,
  });

  @override
  void paint(PaintingContext context, Offset offset) {
    if (firstChild == null) return;
    
    // 1. We create a new compositing layer. This is crucial for the blend mode to work.
    context.canvas.saveLayer(offset & size, Paint());

    // 2. Paint the Background (the first child)
    final background = firstChild;
    if (background != null) {
      final backgroundData = background.parentData as StackParentData;
      context.paintChild(background, backgroundData.offset + offset);
      
      // 3. Paint the Mask (the second child) with BlendMode.dstOut
      // dstOut = "Keep the Destination (Background) where Source (Mask) is Transparent."
      // Effectively: Remove Background where Mask is Opaque.
      final mask = childAfter(background);
      if (mask != null) {
        final maskData = mask.parentData as StackParentData;
        
        // This paint with blendMode is the magic sauce
        context.canvas.saveLayer(
            offset & size, Paint()..blendMode = BlendMode.dstOut);
        context.paintChild(mask, maskData.offset + offset);
        context.canvas.restore();
      }
    }

    context.canvas.restore();
  }
}