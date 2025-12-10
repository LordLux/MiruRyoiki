import 'package:fluent_ui/fluent_ui.dart';

import '../utils/screen.dart';
import 'frosted_noise.dart';

class AcrylicHeader extends StatelessWidget {
  final Widget child;
  final bool useAcrylic;
  final bool useFrostedNoise;
  final BorderRadius borderRadius;
  final BoxConstraints boxConstraints;
  final EdgeInsetsGeometry padding;
  final double opacity;

  const AcrylicHeader({
    super.key,
    required this.child,
    this.useAcrylic = true,
    this.useFrostedNoise = true,
    BorderRadius? borderRadius,
    BoxConstraints? boxConstraints,
    EdgeInsetsGeometry? padding,
    double? opacity,
  })  : borderRadius = borderRadius ?? const BorderRadius.all(Radius.circular(ScreenUtils.kStatCardBorderRadius)),
        boxConstraints = boxConstraints ?? const BoxConstraints(minHeight: 50.0),
        padding = padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        opacity = opacity ?? 0.05;

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: double.infinity,
      constraints: boxConstraints,
      decoration: BoxDecoration(color: Colors.white.withOpacity(opacity), borderRadius: borderRadius),
      padding: padding,
      child: child,
    );

    if (useFrostedNoise) content = FrostedNoise(child: content);

    if (useAcrylic) content = Acrylic(luminosityAlpha: .5, child: content);

    return ClipRRect(borderRadius: borderRadius, child: content);
  }
}
