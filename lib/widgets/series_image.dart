import 'dart:math' show min;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:miruryoiki/models/series.dart';
import 'package:miruryoiki/utils/time_utils.dart';

/// A widget that displays a series image (poster or banner) with loading state handling
class SeriesImageBuilder extends StatefulWidget {
  final Future<ImageProvider?> imageProviderFuture;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Duration fadeInDuration;
  final Curve fadeInCurve;
  final bool skipLoadingIndicator;

  const SeriesImageBuilder({
    super.key,
    required this.imageProviderFuture,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.loadingWidget,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 250),
    this.fadeInCurve = Curves.easeIn,
    this.skipLoadingIndicator = false,
  });

  /// Convenience method to create a poster image
  static Widget poster(
    Series series, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Alignment alignment = Alignment.topCenter,
    Widget? loadingWidget,
    Widget? errorWidget,
    Duration fadeInDuration = const Duration(milliseconds: 250),
    Curve fadeInCurve = Curves.easeIn,
    bool skipLoadingIndicator = false,
  }) {
    return SeriesImageBuilder(
      key: key,
      imageProviderFuture: series.getPosterImage(),
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
      fadeInDuration: fadeInDuration,
      fadeInCurve: fadeInCurve,
      skipLoadingIndicator: skipLoadingIndicator,
    );
  }

  /// Convenience method to create a banner image
  static Widget banner(
    Series series, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Alignment alignment = Alignment.center,
    Widget? loadingWidget,
    Widget? errorWidget,
    Duration fadeInDuration = const Duration(milliseconds: 250),
    Curve fadeInCurve = Curves.easeIn,
    bool skipLoadingIndicator = false,
  }) {
    return SeriesImageBuilder(
      key: key,
      imageProviderFuture: series.getBannerImage(),
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
      fadeInDuration: fadeInDuration,
      fadeInCurve: fadeInCurve,
      skipLoadingIndicator: skipLoadingIndicator,
    );
  }

  @override
  State<SeriesImageBuilder> createState() => _SeriesImageBuilderState();
}

class _SeriesImageBuilderState extends State<SeriesImageBuilder> {
  bool _loading = true;
  ImageProvider? _imageProvider;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(SeriesImageBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only reload if the future reference has actually changed
    if (oldWidget.imageProviderFuture != widget.imageProviderFuture) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      final imageProvider = await widget.imageProviderFuture;

      if (!mounted) return;

      setState(() {
        _imageProvider = imageProvider;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Default loading widget
    Widget loadingWidget = widget.loadingWidget ?? const Center(child: ProgressRing(strokeWidth: 3));

    // Default no-image widget
    Widget noImageWidget = widget.errorWidget ??
        LayoutBuilder(builder: (context, constraints) {
          final size = constraints.biggest;
          return Container(
            width: widget.width ?? size.width,
            height: widget.height ?? size.height,
            alignment: Alignment.center,
            child: Icon(
              FluentIcons.file_image,
              size: min((widget.width ?? size.width) * 0.25, (widget.height ?? size.height) * 0.25),
            ),
          );
        });

    // If we're skipping the loading indicator and we've already loaded once before,
    // don't show the loading state
    if (_loading && !widget.skipLoadingIndicator) return loadingWidget;

    if (_hasError || _imageProvider == null) return noImageWidget;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: FadeInImage(
        placeholder: MemoryImage(kTransparentImage),
        image: _imageProvider!,
        fit: widget.fit,
        alignment: widget.alignment,
        fadeInDuration: getDuration(widget.fadeInDuration),
        fadeInCurve: widget.fadeInCurve,
        imageErrorBuilder: (context, error, stackTrace) => noImageWidget,
      ),
    );
  }
}
