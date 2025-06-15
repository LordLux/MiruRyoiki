import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:jovial_svg/jovial_svg.dart';

import '../utils/time_utils.dart';

late final ScalableImageWidget anilistLogo;
late final ScalableImageWidget offlineIcon;
late final ScalableImageWidget offlineLogo;

Widget defaultSwitcher(BuildContext context, Widget child) {
  return AnimatedSwitcher(
    duration: shortStickyHeaderDuration,
    child: child,
  );
}

class Svg extends StatelessWidget {
  final ScalableImageSource source;
  final Widget Function(BuildContext)? onError;
  final Alignment alignment;
  final BoxFit fit;
  final bool reload;
  final Widget Function(BuildContext, Widget)? switcher;
  final ScalableImageCache cache;

  Svg(
    this.source, {
    super.key,
    this.onError,
    this.alignment = Alignment.center,
    this.fit = BoxFit.contain,
    this.reload = false,
    this.switcher = defaultSwitcher,
    ScalableImageCache? cache,
  }) : cache = cache ?? ScalableImageCache();

  @override
  Widget build(BuildContext context) {
    return ScalableImageWidget.fromSISource(
      key: ValueKey(source),
      scale: 1,
      si: source,
      alignment: alignment,
      fit: fit,
      reload: reload,
      switcher: switcher,
      cache: cache,
      onError: onError,
    );
  }
}

Future<void> initializeSVGs() async {
  anilistLogo = ScalableImageWidget.fromSISource(si: ScalableImageSource.fromSI(rootBundle, 'assets/anilist/logo.si'));
  offlineIcon = ScalableImageWidget.fromSISource(si: ScalableImageSource.fromSI(rootBundle, 'assets/anilist/offline.si'));
  offlineLogo = ScalableImageWidget.fromSISource(si: ScalableImageSource.fromSI(rootBundle, 'assets/anilist/offline_logo.si'));
}
