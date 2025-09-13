import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show InkWell, Material;
import 'package:transparent_image/transparent_image.dart';
import '../enums.dart';
import '../manager.dart';
import '../models/series.dart';
import '../services/navigation/statusbar.dart';
import '../utils/logging.dart';
import 'context_menu/series.dart';
import 'series_card_indicators.dart';

class SeriesListTile extends StatefulWidget {
  final Series series;
  final VoidCallback onTap;

  const SeriesListTile({
    super.key,
    required this.series,
    required this.onTap,
  });

  @override
  State<SeriesListTile> createState() => _SeriesListTileState();
}

class _SeriesListTileState extends State<SeriesListTile> {
  bool _isHovering = false;
  bool _loading = true;
  bool _hasError = false;
  ImageProvider? _posterImageProvider;
  final GlobalKey<SeriesContextMenuState> _contextMenuKey = GlobalKey<SeriesContextMenuState>();

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      _posterImageProvider = await widget.series.getPosterImage();
    } catch (e, stackTrace) {
      logErr('Failed to load series poster image', e, stackTrace);
      _posterImageProvider = null;
      _hasError = true;
    }

    if (mounted) setState(() => _loading = false);
  }

  Widget _buildPosterImage() {
    const double imageWidth = 35;
    const double imageHeight = 50;

    Widget buildImageContent() {
      if (_loading) {
        return Container(
          width: imageWidth,
          height: imageHeight,
          decoration: BoxDecoration(
            color: Manager.genericGray.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: const Center(
              child: ProgressRing(strokeWidth: 2),
            ),
          ),
        );
      }

      if (_hasError || _posterImageProvider == null) {
        return Container(
          width: imageWidth,
          height: imageHeight,
          decoration: BoxDecoration(
            color: Manager.pastelDominantColor.toAccentColor().darkest.withOpacity(.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            FluentIcons.file_image,
            size: 16,
            color: Manager.pastelDominantColor.withOpacity(.7),
          ),
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: imageWidth,
          height: imageHeight,
          child: FadeInImage(
            placeholder: MemoryImage(kTransparentImage),
            image: _posterImageProvider!,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            fadeInDuration: const Duration(milliseconds: 250),
            fadeInCurve: Curves.easeIn,
            imageErrorBuilder: (context, error, stackTrace) => Container(
              color: Manager.genericGray.withOpacity(0.3),
              child: Icon(
                FluentIcons.file_image,
                size: 16,
                color: Manager.genericGray,
              ),
            ),
          ),
        ),
      );
    }

    return buildImageContent();
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor;
    switch (Manager.settings.libColView) {
      case LibraryColorView.alwaysDominant:
        mainColor = widget.series.dominantColor ?? Manager.genericGray;
        break;
      case LibraryColorView.hoverDominant:
        mainColor = _isHovering ? (widget.series.dominantColor ?? Manager.genericGray) : Manager.genericGray;
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

    return LayoutBuilder(builder: (context, constraints) {
      final double tileHeight = 51;
      final String extra = constraints.maxWidth > 450 ? ' (${(widget.series.watchedPercentage * 100).round()}%)' : '';
      final progressText = '${widget.series.watchedEpisodes} / ${widget.series.totalEpisodes}$extra';

      return KeyedSubtree(
        key: ValueKey('${widget.series.path}-${widget.series.dominantColor?.value ?? 0}-list'),
        child: SeriesContextMenu(
          key: _contextMenuKey,
          series: widget.series,
          context: context,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovering = true),
            onExit: (_) {
              StatusBarManager().hide();
              setState(() => _isHovering = false);
            },
            onHover: (_) => StatusBarManager().showDelayed(widget.series.name),
            cursor: SystemMouseCursors.click,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: tileHeight,
                decoration: BoxDecoration(
                  color: _isHovering ? mainColor.withOpacity(0.15) : mainColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: LayoutBuilder(builder: (context, constraints) {
                  final indicatorSpace = 60.0;
                  return Stack(
                    children: [
                      // Main content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            // Poster image with fade and scale animation
                            Builder(
                              builder: (context) {
                                const double spacing = 10;
                                final double totalWidth = 35 + spacing;

                                return SizedBox(
                                  width: totalWidth,
                                  child: totalWidth <= 1
                                      ? const SizedBox.shrink()
                                      : Row(children: [
                                          _buildPosterImage(),
                                          const SizedBox(width: spacing),
                                        ]),
                                );
                              },
                            ),

                            // Series name (flexible width)
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: indicatorSpace),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.series.name,
                                      style: Manager.bodyStyle.copyWith(fontSize: 12.5 * Manager.fontSizeMultiplier, fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                    ),
                                    // Animated progress bar for detailed view
                                    LayoutBuilder(builder: (context, constraints) {
                                      return Column(
                                        children: [
                                          const SizedBox(height: 4),
                                          Container(
                                            width: constraints.maxWidth,
                                            height: 2.5,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              color: Color.lerp(Colors.black.withOpacity(0.2), widget.series.dominantColor, .4),
                                            ),
                                            child: Align(
                                              alignment: Alignment.topLeft,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  color: widget.series.watchedPercentage == 0 ? Colors.transparent : widget.series.dominantColor,
                                                ),
                                                width: constraints.maxWidth * widget.series.watchedPercentage,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),

                            // Progress (fixed width)
                            SizedBox(
                              width: 100,
                              child: Text(
                                progressText,
                                style: Manager.miniBodyStyle.copyWith(color: _isHovering ? mainColor : Manager.bodyStyle.color?.withOpacity(0.7), fontSize: 11 * Manager.fontSizeMultiplier),
                                textAlign: TextAlign.right,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Indicators with animation
                      Positioned(
                        right: 80, // Position to the left of progress text
                        child: Transform.scale(
                          scale: 0.85,
                          child: CardIndicators(series: widget.series, isListView: true),
                        ),
                      ),

                      // Hover overlay
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: GestureDetector(
                            onSecondaryTapDown: (_) => _contextMenuKey.currentState?.openMenu(),
                            child: InkWell(
                              onTap: widget.onTap,
                              splashColor: mainColor.withOpacity(0.1),
                              highlightColor: mainColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(4),
                              child: Container(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      );
    });
  }
}
