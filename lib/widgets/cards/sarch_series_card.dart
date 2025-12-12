import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons, InkWell, Material;
import 'package:miruryoiki/models/anilist/anime.dart';
import 'package:miruryoiki/widgets/frosted_noise.dart';
import '../../enums.dart';
import '../../manager.dart';

import '../../services/navigation/statusbar.dart';
import '../../utils/screen.dart';
import '../../utils/time.dart';
import '../context_menu/searched_series.dart';
import '../context_menu/controller.dart';
import '../series_card_indicators.dart';

class SearchSeriesCard extends StatefulWidget {
  final AnilistAnime series;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const SearchSeriesCard({
    super.key,
    required this.series,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
  });

  @override
  State<SearchSeriesCard> createState() => _SearchSeriesCardState();
}

class _SearchSeriesCardState extends State<SearchSeriesCard> {
  bool _isHovering = false;
  late final DesktopContextMenuController _menuController;
  Color? _dominantColor;

  @override
  void initState() {
    super.initState();
    _menuController = DesktopContextMenuController();
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  Widget _getSeriesImage() {
    return LayoutBuilder(builder: (context, constraints) {
      return AspectRatio(
        aspectRatio: ScreenUtils.kDefaultAspectRatio,
        child: CachedNetworkImage(
          memCacheHeight: constraints.maxHeight.toInt(),
          memCacheWidth: constraints.minHeight.toInt(),
          imageUrl: widget.series.posterImage ?? '',
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: const Color(0xFF1B222C)),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color? cachedPrimaryColor = widget.series.dominantColor?.fromHex();

    final Color mainColor;
    switch (Manager.settings.libColView) {
      case LibraryColorView.alwaysDominant:
        mainColor = _dominantColor ?? cachedPrimaryColor ?? Manager.genericGray;
        break;
      case LibraryColorView.hoverDominant:
        mainColor = _isHovering ? (_dominantColor ?? cachedPrimaryColor ?? Manager.genericGray) : Manager.genericGray;
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
      key: ValueKey('${widget.series.id}-${_dominantColor ?? cachedPrimaryColor?.value ?? 0}'),
      child: SearchedSeriesContextMenu(
        controller: _menuController,
        series: widget.series,
        context: context,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) {
            StatusBarManager().hide();
            setState(() => _isHovering = false);
          },
          onHover: (_) => StatusBarManager().showDelayed(widget.series.title.userPreferred),
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
                  Positioned.fill(top: 0, child: Container(child: _getSeriesImage())),
                  Card(
                    padding: EdgeInsets.zero,
                    borderRadius: widget.borderRadius,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Poster image
                        Expanded(child: SizedBox.shrink()),

                        // Series info
                        Builder(builder: (context) {
                          final Color nicerColor = mainColor.lerpWith(Colors.grey, .76);

                          Widget child = AnimatedContainer(
                            duration: splashScreenFadeAnimationIn,
                            width: double.infinity,
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
                                constraints: BoxConstraints(minHeight: 35 * min(Manager.fontSizeMultiplier, 1)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.series.title.userPreferred ?? widget.series.title.romaji ?? widget.series.title.native ?? 'Anime',
                                      style: Manager.bodyStrongStyle.copyWith(fontSize: 12 * Manager.fontSizeMultiplier),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (widget.series.episodes != null) ...[
                                      VDiv(4),
                                      Text(
                                        '${widget.series.episodes} Episodes',
                                        style: Manager.miniBodyStyle.copyWith(color: Color.lerp(_dominantColor ?? cachedPrimaryColor, Colors.white, .7)),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          );
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

                  AiringIndicator(series: widget.series, isHovered: _isHovering),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
