import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jovial_svg/jovial_svg.dart';

import '../utils/time.dart';
import '../utils/icons.dart' as icons;

late final ScalableImageWidget anilistLogo;
late final ScalableImageWidget offlineIcon;
late final ScalableImageWidget offlineLogo;
late final ScalableImageWidget vlc;
late final ScalableImageWidget mpcHc;

Widget defaultSwitcher(BuildContext context, Widget child) {
  return AnimatedSwitcher(
    duration: shortStickyHeaderDuration,
    child: child,
  );
}

class Svg extends StatelessWidget {
  final dynamic source;
  final Widget Function(BuildContext)? onError;
  final Alignment alignment;
  final BoxFit fit;
  final bool reload;
  final Widget Function(BuildContext, Widget)? switcher;
  final ScalableImageCache cache;
  final double? width;
  final double? height;

  Svg(
    this.source, {
    super.key,
    this.onError,
    this.alignment = Alignment.center,
    this.fit = BoxFit.contain,
    this.reload = false,
    this.switcher = defaultSwitcher,
    this.width,
    this.height,
    ScalableImageCache? cache,
  })  : assert(source is ScalableImageSource || source is String),
        cache = cache ?? ScalableImageCache();

  @override
  Widget build(BuildContext context) {
    if (source is ScalableImageSource)
      return SizedBox(
        width: width,
        height: height,
        child: ScalableImageWidget.fromSISource(
          key: ValueKey(source),
          scale: 1,
          si: source,
          alignment: alignment,
          fit: fit,
          reload: reload,
          switcher: switcher,
          cache: cache,
          onError: onError,
        ),
      );
    return SvgPicture.asset(
      source,
      key: ValueKey(source),
      alignment: alignment,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: onError != null ? (context, error, stackTrace) => onError!(context) : null,
    );
  }
}

Future<void> initializeSVGs() async {
  anilistLogo = ScalableImageWidget.fromSISource(si: ScalableImageSource.fromSI(rootBundle, icons.anilist_logo));
  offlineIcon = ScalableImageWidget.fromSISource(si: ScalableImageSource.fromSI(rootBundle, icons.icon_offline));
  offlineLogo = ScalableImageWidget.fromSISource(si: ScalableImageSource.fromSI(rootBundle, icons.anilist_logo_offline));
  vlc = ScalableImageWidget.fromSISource(si: ScalableImageSource.fromSI(rootBundle, icons.vlc));
  mpcHc = ScalableImageWidget.fromSISource(si: ScalableImageSource.fromSI(rootBundle, icons.mpcHc));
}
