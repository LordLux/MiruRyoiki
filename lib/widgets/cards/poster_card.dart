import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show InkWell, Material;
import 'package:miruryoiki/widgets/frosted_noise.dart';
import 'package:transparent_image/transparent_image.dart';
import '../../enums.dart';
import '../../manager.dart';
import '../../services/file_system/cache.dart';
import '../../services/navigation/statusbar.dart';
import '../../utils/logging.dart';
import '../../utils/screen.dart';
import '../../utils/time.dart';
import '../context_menu/controller.dart';

/// Shared poster/progress/menu card shell used by both [MappingCard] (a single
/// AniList mapping) and [FolderCard] (a folder node). It owns the async poster
/// image + dominant-color loading, the hover/progress visuals, and the
/// right-click controller; callers supply the data source and the menu wrapper.
class PosterCard extends StatefulWidget {
  /// AniList poster URL, or null to show the [placeholderIcon].
  final String? posterUrl;

  /// Async/sync dominant color resolvers (sync is the immediate fallback).
  final Future<Color?> Function() loadDominantColor;
  final Color? Function() dominantColorSync;

  final String title;
  final int watchedCount;
  final int totalCount;
  final double watchedPercentage;

  final IconData placeholderIcon;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  /// Stable identity used to detect when to reload (e.g. the node/mapping path).
  final Object identityKey;

  /// Wraps the card body with the appropriate context menu. Receives the body,
  /// the menu [controller] to attach, and a [refresh] callback for the menu's
  /// onChanged.
  final Widget Function(BuildContext context, Widget child, DesktopContextMenuController controller, VoidCallback refresh) menuBuilder;

  const PosterCard({
    super.key,
    required this.posterUrl,
    required this.loadDominantColor,
    required this.dominantColorSync,
    required this.title,
    required this.watchedCount,
    required this.totalCount,
    required this.watchedPercentage,
    required this.placeholderIcon,
    required this.onTap,
    required this.identityKey,
    required this.menuBuilder,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
  });

  @override
  State<PosterCard> createState() => _PosterCardState();
}

class _PosterCardState extends State<PosterCard> {
  bool _isHovering = false;
  bool _loading = true;
  bool _hasError = false;
  ImageProvider? _posterImageProvider;
  String? _loadedPosterUrl;
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
  void didUpdateWidget(PosterCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_loadedPosterUrl != widget.posterUrl) _loadImage();

    final currentDominant = widget.dominantColorSync();
    if (oldWidget.identityKey != widget.identityKey || _dominantColor?.value != currentDominant?.value) _loadDominantColor();
  }

  Future<void> _loadDominantColor() async {
    final color = await widget.loadDominantColor();
    if (mounted) setState(() => _dominantColor = color);
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    final posterUrl = widget.posterUrl;
    _loadedPosterUrl = posterUrl;

    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      _posterImageProvider = await _getPosterImageForUrl(posterUrl);
    } catch (e, stackTrace) {
      logErr('Failed to load poster image', e, stackTrace);
      _posterImageProvider = null;
      _hasError = true;
    }

    // If another reload started while this one was in-flight, drop stale result
    if (_loadedPosterUrl != posterUrl) return;

    if (mounted) setState(() => _loading = false);
  }

  Future<ImageProvider?> _getPosterImageForUrl(String? posterUrl) async {
    if (posterUrl == null || posterUrl.isEmpty) return null;
    return await ImageCacheService().getImageProvider(posterUrl);
  }

  Widget _getPosterWidget() {
    Widget loadingWidget = const Center(child: ProgressRing(strokeWidth: 3));

    Widget noImageWidget = LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxWidth * 1.05,
          child: Icon(widget.placeholderIcon, size: constraints.maxWidth * 0.25),
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

    // Only show a spinner while a real URL is being fetched (not for placeholders)
    if (_loading && _posterImageProvider == null && _loadedPosterUrl != null) return loadingWidget;

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

  Color? get _baseColor => _dominantColor ?? widget.dominantColorSync();

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor;
    switch (Manager.settings.libColView) {
      case LibraryColorView.alwaysDominant:
        mainColor = _baseColor ?? Manager.genericGray;
        break;
      case LibraryColorView.hoverDominant:
        mainColor = _isHovering ? (_baseColor ?? Manager.genericGray) : Manager.genericGray;
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

    final percentage = widget.watchedPercentage;

    return KeyedSubtree(
      key: ValueKey('${widget.identityKey}-${_baseColor?.value ?? 0}'),
      child: widget.menuBuilder(
        context,
        MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) {
            StatusBarManager().hide();
            setState(() => _isHovering = false);
          },
          onHover: (_) => StatusBarManager().showDelayed(widget.title),
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
                    child: Container(child: _getPosterWidget()),
                  ),
                  Card(
                    padding: EdgeInsets.zero,
                    borderRadius: widget.borderRadius,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(child: SizedBox.shrink()),

                        // Progress bar
                        LayoutBuilder(builder: (context, constraints) {
                          return Transform.scale(
                            scale: 1.01,
                            child: Transform.translate(
                              offset: const Offset(0, .5),
                              child: AnimatedContainer(
                                duration: splashScreenFadeAnimationIn,
                                width: constraints.maxWidth,
                                height: 4,
                                color: Color.lerp(Colors.black.withOpacity(0.2), _baseColor, .4),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: AnimatedContainer(
                                    duration: splashScreenFadeAnimationIn,
                                    color: percentage == 0 ? Colors.transparent : _baseColor,
                                    width: constraints.maxWidth * percentage,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),

                        // Info
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
                                      widget.title,
                                      style: Manager.bodyStrongStyle.copyWith(fontSize: 12 * Manager.fontSizeMultiplier),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    VDiv(4),
                                    Row(
                                      children: [
                                        Text(
                                          '${widget.watchedCount} / ${widget.totalCount} Episodes',
                                          style: Manager.miniBodyStyle.copyWith(color: Color.lerp(_baseColor, Colors.white, .7)),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${(percentage * 100).round()}%',
                                          style: Manager.miniBodyStyle.copyWith(color: Color.lerp(_baseColor, Colors.white, .7)),
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
                                offset: const Offset(0, 1),
                                child: Acrylic(
                                  blurAmount: 2,
                                  tint: nicerColor.lerpWith(Colors.grey, 0.2),
                                  elevation: 0.5,
                                  tintAlpha: 0.5,
                                  luminosityAlpha: 0.8,
                                  child: FrostedNoise(child: child),
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
                      child: InkWell(
                        onTap: widget.onTap,
                        onSecondaryTapDown: (details) => _menuController.open(),
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
                ],
              ),
            ),
          ),
        ),
        _menuController,
        _refresh,
      ),
    );
  }
}
