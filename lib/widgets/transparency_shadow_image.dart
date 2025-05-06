import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ShadowedImage extends StatelessWidget {
  final ImageProvider imageProvider;
  final BoxFit fit;
  final ColorFilter? colorFilter;
  final double blurSigma;
  final Offset shadowOffset;
  final double shadowOpacity;

  const ShadowedImage({
    super.key,
    required this.imageProvider,
    this.fit = BoxFit.cover,
    this.colorFilter,
    this.blurSigma = 10,
    this.shadowOffset = const Offset(0, 0),
    this.shadowOpacity = 0.3,
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1) blurred, black-tinted silhouette
        Transform.translate(
          offset: shadowOffset,
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: blurSigma,
              sigmaY: blurSigma,
            ),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(shadowOpacity),
                BlendMode.srcATop,
              ),
              child: _buildFilteredImage(),
            ),
          ),
        ),

        // 2) your actual image on top
        _buildFilteredImage(),
      ],
    );
  }
}
