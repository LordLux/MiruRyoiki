import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jovial_svg/jovial_svg.dart';

import '../utils/time.dart';
import '../utils/icons.dart' as icons;

late ScalableImageWidget anilistLogo;
late ScalableImageWidget offlineIcon;
late ScalableImageWidget offlineLogo;
late ScalableImageWidget vlc;
late ScalableImageWidget mpcHc;
late ScalableImageWidget sonarr;
late ScalableImageWidget qbittorrent;

Widget defaultSwitcher(BuildContext context, Widget child) {
  return AnimatedSwitcher(
    duration: shortStickyHeaderDuration,
    child: child,
  );
}

enum _SvgType { asset, network, file, si }

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
  final _SvgType type;

  Svg._(
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
    this.type = _SvgType.asset,
  })  : assert(source is ScalableImageSource || source is String),
        cache = cache ?? ScalableImageCache();

  factory Svg.si(
    ScalableImageSource source, {
    Key? key,
    Widget Function(BuildContext)? onError,
    Alignment alignment = Alignment.center,
    BoxFit fit = BoxFit.contain,
    bool reload = false,
    Widget Function(BuildContext, Widget)? switcher = defaultSwitcher,
    double? width,
    double? height,
    ScalableImageCache? cache,
  }) {
    return Svg._(
      source,
      key: key,
      onError: onError,
      alignment: alignment,
      fit: fit,
      reload: reload,
      switcher: switcher,
      width: width,
      height: height,
      cache: cache,
      type: _SvgType.si,
    );
  }

  factory Svg.asset(
    String assetName, {
    Key? key,
    Widget Function(BuildContext)? onError,
    Alignment alignment = Alignment.center,
    BoxFit fit = BoxFit.contain,
    bool reload = false,
    Widget Function(BuildContext, Widget)? switcher = defaultSwitcher,
    double? width,
    double? height,
  }) {
    return Svg._(
      assetName,
      key: key,
      onError: onError,
      alignment: alignment,
      fit: fit,
      reload: reload,
      switcher: switcher,
      width: width,
      height: height,
      type: _SvgType.asset,
    );
  }

  factory Svg.network(
    String url, {
    Key? key,
    Widget Function(BuildContext)? onError,
    Alignment alignment = Alignment.center,
    BoxFit fit = BoxFit.contain,
    bool reload = false,
    Widget Function(BuildContext, Widget)? switcher = defaultSwitcher,
    double? width,
    double? height,
  }) {
    return Svg._(
      url,
      key: key,
      onError: onError,
      alignment: alignment,
      fit: fit,
      reload: reload,
      switcher: switcher,
      width: width,
      height: height,
      type: _SvgType.network,
    );
  }

  factory Svg.file(
    String filePath, {
    Key? key,
    Widget Function(BuildContext)? onError,
    Alignment alignment = Alignment.center,
    BoxFit fit = BoxFit.contain,
    bool reload = false,
    Widget Function(BuildContext, Widget)? switcher = defaultSwitcher,
    double? width,
    double? height,
  }) {
    return Svg._(
      filePath,
      key: key,
      onError: onError,
      alignment: alignment,
      fit: fit,
      reload: reload,
      switcher: switcher,
      width: width,
      height: height,
      type: _SvgType.file,
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      _SvgType.si => SizedBox(
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
        ),
      _SvgType.asset => SvgPicture.asset(
          source,
          key: ValueKey(source),
          alignment: alignment,
          fit: fit,
          width: width,
          height: height,
          cacheColorFilter: true,
          placeholderBuilder: onError != null ? (context) => onError!(context) : null,
        ),
      _SvgType.network => SvgPicture.network(
          source,
          key: ValueKey(source),
          alignment: alignment,
          fit: fit,
          width: width,
          height: height,
          cacheColorFilter: true,
          placeholderBuilder: onError != null ? (context) => onError!(context) : null,
        ),
      _SvgType.file => SvgPicture.file(
          File(source),
          key: ValueKey(source),
          alignment: alignment,
          fit: fit,
          width: width,
          height: height,
          cacheColorFilter: true,
          placeholderBuilder: onError != null ? (context) => onError!(context) : null,
        )
    };
  }
}

Future<void> initializeSVGs() async {
  anilistLogo = ScalableImageWidget.fromSISource(si: ScalableImageSource.fromSI(rootBundle, icons.anilist_logo));
  offlineIcon = ScalableImageWidget.fromSISource(si: ScalableImageSource.fromSI(rootBundle, icons.icon_offline));
  offlineLogo = ScalableImageWidget.fromSISource(si: ScalableImageSource.fromSI(rootBundle, icons.anilist_logo_offline));
  vlc = ScalableImageWidget.fromSISource(si: ScalableImageSource.fromSI(rootBundle, icons.vlc));
  mpcHc = ScalableImageWidget.fromSISource(si: ScalableImageSource.fromSI(rootBundle, icons.mpcHc));
  sonarr = ScalableImageWidget.fromSISource(si: ScalableImageSource.fromSI(rootBundle, icons.sonarr));
  qbittorrent = ScalableImageWidget.fromSISource(si: ScalableImageSource.fromSI(rootBundle, icons.qbittorrent));
}
