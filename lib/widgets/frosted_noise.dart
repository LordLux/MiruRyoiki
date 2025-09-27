import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';

/// FrostedNoise overlays a tiled noise image (from assets) and uses a
/// subtle blend mode to produce tiny per-pixel lightness deviations on
/// the content underneath. The noise image is loaded once and reused
/// to avoid expensive per-frame calculations.
class FrostedNoise extends StatefulWidget {
  /// Path to the tiled noise image in assets. The image should be
  /// relatively small and tile well (e.g. 256x256) so it can be repeated.
  final String assetPath;

  /// How strong the effect should be. Typical values: 0.0 - 0.2.
  final double intensity;

  /// Which blend mode to use when applying the noise. Default uses
  /// `BlendMode.overlay` which will both darken and lighten subtly.
  final BlendMode blendMode;

  final Widget? child;

  final Color? color;

  const FrostedNoise({
    super.key,
    this.assetPath = 'assets/images/noise.png',
    this.intensity = 0.5,
    this.blendMode = BlendMode.overlay,
    this.child,
    this.color,
  });

  @override
  State<FrostedNoise> createState() => _FrostedNoiseState();
}

class _FrostedNoiseState extends State<FrostedNoise> {
  ui.Image? _image;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Resolve the image here because it depends on the inherited
    // widgets (like MediaQuery) via createLocalImageConfiguration.
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant FrostedNoise oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _resolveImage();
    }
  }

  void _resolveImage() {
    final provider = AssetImage(widget.assetPath);
    final config = createLocalImageConfiguration(context);
    _stream?.removeListener(_listener!);
    _stream = provider.resolve(config);
    _listener = ImageStreamListener((ImageInfo info, bool _) {
      if (mounted) {
        setState(() {
          _image = info.image;
        });
      }
    });
    _stream!.addListener(_listener!);
  }

  @override
  void dispose() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If the image isn't ready yet, just return an empty transparent box.
    // Once loaded, CustomPaint will draw the tiled noise shader.
    return CustomPaint(
      painter: _FrostedNoisePainter(
        image: _image,
        intensity: (widget.intensity/10).clamp(0.0, 1.0),
        blendMode: widget.blendMode,
        color: widget.color,
      ),
      size: Size.infinite,
      child: widget.child,
    );
  }
}

class _FrostedNoisePainter extends CustomPainter {
  final ui.Image? image;
  final double intensity;
  final BlendMode blendMode;
  final Color color;

  _FrostedNoisePainter({
    required this.image,
    required this.intensity,
    required this.blendMode,
    Color? color,
  }) : color = color ?? Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;

    // Create an image shader that repeats the noise texture.
    final shader = ImageShader(
      image!,
      TileMode.repeated,
      TileMode.repeated,
      Float64List.fromList([
        1, 0, 0, 0, //
        0, 1, 0, 0, //
        0, 0, 1, 0, //
        0, 0, 0, 1
      ]),
    );

    // Paint the shader with a low-intensity color. The shader will be
    // modulated by the paint.color; using white keeps the image colors
    // intact while the alpha controls overall strength.
    final paint = Paint()
      ..shader = shader
      ..blendMode = blendMode
      ..color = color.withOpacity(intensity.clamp(0.0, 1.0));

    // Draw the full rect using the shader. This overlays the noise
    // texture onto whatever is beneath this layer using the selected
    // blend mode and alpha, producing slight lightness deviations.
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _FrostedNoisePainter oldDelegate) {
    return oldDelegate.image != image || //
        oldDelegate.intensity != intensity ||
        oldDelegate.blendMode != blendMode;
  }
}
