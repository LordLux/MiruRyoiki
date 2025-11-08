import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show InkWell, Material;
import 'package:miruryoiki/models/anilist/mapping.dart';
import 'package:miruryoiki/widgets/frosted_noise.dart';
import 'package:transparent_image/transparent_image.dart';
import '../enums.dart';
import '../manager.dart';

import '../models/mapping_target.dart';
import '../models/series.dart';
import '../services/file_system/cache.dart';
import '../services/navigation/statusbar.dart';
import '../utils/logging.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import 'context_menu/mapping.dart';
import 'context_menu/controller.dart';

class MappingCard extends StatefulWidget {
  final MappingTarget target;
  final AnilistMapping mapping;
  final Series series;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const MappingCard({
    super.key,
    required this.target,
    required this.mapping,
    required this.onTap,
    required this.series,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
  });

  @override
  State<MappingCard> createState() => _MappingCardState();
}

class _MappingCardState extends State<MappingCard> {
  bool _isHovering = false;
  bool _loading = true;
  bool _hasError = false;
  ImageProvider? _posterImageProvider;
  late final DesktopContextMenuController _menuController;
  Color? _dominantColor;

  @override
  void initState() {
    super.initState();
    _menuController = DesktopContextMenuController();
    _loadImage();
    _loadDominantColor();
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MappingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mapping != widget.mapping || oldWidget.target != widget.target) {
      _loadImage();
      _loadDominantColor();
    }
  }

  Future<void> _loadDominantColor() async {
    final color = await widget.mapping.effectivePrimaryColor();
    if (mounted) setState(() => _dominantColor = color);
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      _posterImageProvider = await _getPosterImage();
    } catch (e, stackTrace) {
      logErr('Failed to load mapping poster image', e, stackTrace);
      _posterImageProvider = null;
      _hasError = true;
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<ImageProvider?> _getPosterImage() async {
    final posterUrl = widget.mapping.anilistData?.posterImage;

    if (posterUrl != null) {
      // Try to get cached image
      final imageCache = ImageCacheService();
      final File? cachedFile = await imageCache.getCachedImageFile(posterUrl);

      if (cachedFile != null && await cachedFile.exists()) {
        return FileImage(cachedFile);
      }

      // Start caching in background
      imageCache.cacheImage(posterUrl);

      // Return network image provider
      return CachedNetworkImageProvider(
        posterUrl,
        errorListener: (error) => logWarn('Failed to load poster from network: $error'),
      );
    }

    return null;
  }

  Widget _getPosterWidget() {
    Widget loadingWidget = const Center(child: ProgressRing(strokeWidth: 3));

    Widget noImageWidget = LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxWidth * 1.05,
          child: Icon(FluentIcons.file_image, size: constraints.maxWidth * 0.25),
        ),
      ),
    );

    // If loading and we have an image provider already, keep showing the image
    if (_loading && _posterImageProvider != null) {
      return FadeInImage(
        placeholder: MemoryImage(kTransparentImage),
        image: _posterImageProvider!,
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
        fadeInDuration: getAnimationDuration(const Duration(milliseconds: 250)),
        fadeInCurve: Curves.easeIn,
        imageErrorBuilder: (context, error, stackTrace) => noImageWidget,
      );
    }

    if (_loading) return loadingWidget;

    if (_hasError || _posterImageProvider == null) return noImageWidget;

    return FadeInImage(
      placeholder: MemoryImage(kTransparentImage),
      image: _posterImageProvider!,
      fit: BoxFit.fitWidth,
      alignment: Alignment.topCenter,
      fadeInDuration: getAnimationDuration(const Duration(milliseconds: 250)),
      fadeInCurve: Curves.easeIn,
      imageErrorBuilder: (context, error, stackTrace) => noImageWidget,
    );
  }

  String get _displayTitle {
    return widget.target.when(
      episode: (ep) => ep.displayTitle ?? ep.name,
      season: (season) => season.prettyName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor;
    switch (Manager.settings.libColView) {
      case LibraryColorView.alwaysDominant:
        mainColor = _dominantColor ?? widget.mapping.effectivePrimaryColorSync() ?? Manager.genericGray;
        break;
      case LibraryColorView.hoverDominant:
        mainColor = _isHovering ? (_dominantColor ?? widget.mapping.effectivePrimaryColorSync() ?? Manager.genericGray) : Manager.genericGray;
        break;
      case LibraryColorView.alwaysAccent:
        mainColor = Manager.accentColor;
        break;
      case LibraryColorView.hoverAccent:
        mainColor = _isHovering ? Manager.accentColor : Manager.genericGray;
        break;
      case LibraryColorView.none:
        mainColor = Manager.genericGray;
        break;
    }

    return KeyedSubtree(
      key: ValueKey('${widget.mapping.localPath}-${_dominantColor ?? widget.mapping.effectivePrimaryColorSync()?.value ?? 0}'),
      child: MappingContextMenu(
        controller: _menuController,
        series: widget.series,
        target: widget.target,
        context: context,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) {
            StatusBarManager().hide();
            setState(() => _isHovering = false);
          },
          onHover: (_) => StatusBarManager().showDelayed(_displayTitle),
          cursor: SystemMouseCursors.click,
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            child: AnimatedContainer(
              duration: shortDuration,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                color: Colors.transparent,
                boxShadow: _isHovering
                    ? [
                        BoxShadow(
                          color: mainColor.withOpacity(0.05),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  // Poster image
                  Positioned.fill(
                    top: 0,
                    child: Container(
                      child: _getPosterWidget(),
                    ),
                  ),
                  Card(
                    padding: EdgeInsets.zero,
                    borderRadius: widget.borderRadius,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Poster image space
                        Expanded(child: SizedBox.shrink()),

                        // Progress bar
                        LayoutBuilder(builder: (context, constraints) {
                          return Transform.scale(
                            scale: 1.01,
                            child: Transform.translate(
                              offset: Offset(0, .5),
                              child: AnimatedContainer(
                                duration: splashScreenFadeAnimationIn,
                                width: constraints.maxWidth,
                                height: 4,
                                color: Color.lerp(Colors.black.withOpacity(0.2), _dominantColor ?? widget.mapping.effectivePrimaryColorSync(), .4),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: AnimatedContainer(
                                    duration: splashScreenFadeAnimationIn,
                                    color: widget.target.watchedPercentage == 0 ? Colors.transparent : _dominantColor ?? widget.mapping.effectivePrimaryColorSync(),
                                    width: constraints.maxWidth * widget.target.watchedPercentage,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),

                        // Mapping info
                        Builder(builder: (context) {
                          final double value = (_posterImageProvider != null) ? .76 : .9;
                          final Color nicerColor = mainColor.lerpWith(Colors.grey, value);

                          Widget child = AnimatedContainer(
                            duration: splashScreenFadeAnimationIn,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(.3),
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.transparent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.0 * Manager.fontSizeMultiplier),
                              child: AnimatedContainer(
                                duration: splashScreenFadeAnimationIn,
                                constraints: BoxConstraints(minHeight: 42 * min(Manager.fontSizeMultiplier, 1)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _displayTitle,
                                      style: Manager.bodyStrongStyle.copyWith(fontSize: 12 * Manager.fontSizeMultiplier),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    VDiv(4),
                                    Row(
                                      children: [
                                        Text(
                                          '${widget.target.watchedCount} / ${widget.target.totalCount} Episodes',
                                          style: Manager.miniBodyStyle.copyWith(color: Color.lerp(_dominantColor ?? widget.mapping.effectivePrimaryColorSync(), Colors.white, .7)),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${(widget.target.watchedPercentage * 100).round()}%',
                                          style: Manager.miniBodyStyle.copyWith(color: Color.lerp(_dominantColor ?? widget.mapping.effectivePrimaryColorSync(), Colors.white, .7)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );

                          if (_posterImageProvider != null) {
                            return Transform.scale(
                              scale: 1.02,
                              child: Transform.translate(
                                offset: Offset(0, 1),
                                child: Acrylic(
                                  blurAmount: 2,
                                  tint: nicerColor.lerpWith(Colors.grey, 0.2),
                                  elevation: 0.5,
                                  tintAlpha: 0.5,
                                  luminosityAlpha: 0.8,
                                  child: FrostedNoise(
                                    child: child,
                                  ),
                                ),
                              ),
                            );
                          }
                          return AnimatedContainer(
                            duration: splashScreenFadeAnimationIn,
                            color: nicerColor,
                            child: child,
                          );
                        }),
                      ],
                    ),
                  ),

                  // Hover overlay
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: GestureDetector(
                        onSecondaryTapDown: (_) => _menuController.open(),
                        child: InkWell(
                          onTap: widget.onTap,
                          splashColor: mainColor.withOpacity(0.1),
                          highlightColor: mainColor.withOpacity(0.05),
                          borderRadius: widget.borderRadius,
                          child: AnimatedContainer(
                            duration: shortDuration,
                            decoration: BoxDecoration(
                              borderRadius: widget.borderRadius,
                              color: _isHovering ? mainColor.withOpacity(0.1) : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
