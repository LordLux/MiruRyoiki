import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// A widget that displays an image with a shadow effect considering the image's transparency and shape.
class ShadowedImage extends StatelessWidget {
  /// The image to display. This is the image that will be blurred and tinted.
  final ImageProvider imageProvider;
  
  /// The fit of the image. This is the fit of the image itself.
  final BoxFit fit;
  
  /// The color filter to apply to the image. This is the color filter applied to the image itself.
  final ColorFilter? colorFilter;
  
  /// The amount of blur to apply to the shadow. This is the amount of blur applied to the shadow image.
  final double blurSigma;
  
  /// The offset of the shadow. This is the offset of the shadow relative to the image.
  final Offset shadowOffset;
  
  /// The opacity of the shadow color. 0 = `shadowColor` fully opaque, 1 = black.
  final double shadowColorOpacity;

  /// The color of the shadow. If null, the shadow will get the colors from the image itself.
  final Color? shadowColor;

  const ShadowedImage({
    super.key,
    required this.imageProvider,
    this.fit = BoxFit.cover,
    this.colorFilter,
    this.blurSigma = 10,
    this.shadowOffset = const Offset(0, 0),
    this.shadowColorOpacity = 0,
    this.shadowColor,
  });

  Widget _buildFilteredImage() {
    Widget img = Image(
      image: imageProvider,
      fit: fit,
    );
    if (colorFilter != null) {
      img = ColorFiltered(
        colorFilter: colorFilter!,
        child: img,
      );
    }
    return img;
  }

  Widget _getImageShadow() {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
        sigmaX: blurSigma,
        sigmaY: blurSigma,
      ),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.black.withOpacity(shadowColorOpacity),
          BlendMode.srcATop,
        ),
        child: _buildFilteredImage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1) blurred, black-tinted silhouette
        Transform.translate(
          offset: shadowOffset,
          child: Builder(builder: (context) {
            if (shadowColor == null) return _getImageShadow();
            
            return ColorFiltered(
              // Tint the image black
              colorFilter: ColorFilter.mode(shadowColor!, BlendMode.srcATop),
              child: _getImageShadow(),
            );
          }),
        ),

        // 2) your actual image on top
        _buildFilteredImage(),
      ],
    );
  }
}
