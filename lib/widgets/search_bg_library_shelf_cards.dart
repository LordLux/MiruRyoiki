
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:marquee/marquee.dart';

import '../utils/screen.dart';

class SearchLibraryShelfDisplay extends StatelessWidget {
  final List<String> imageUrls;
  final bool reverseAnimation;
  final double verticalOffset;
  final double sigma = 2.0;

  const SearchLibraryShelfDisplay({
    super.key,
    required this.imageUrls,
    this.reverseAnimation = false,
    this.verticalOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final rows = ((constraints.maxHeight + 480) / 195).ceil(); //~ 4 rows at 300 height and 8 rows at 1080 height
      return ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: SizedBox(
          height: constraints.maxHeight + 100,
          width: constraints.maxWidth,
          child: Slanted3DGrid(
            images: imageUrls,
            rows: rows,
            speed: reverseAnimation ? -20 : 20,
            angle: -0.2, // The slant angle
            verticalOffset: verticalOffset,
          ),
        ),
      );
    });
  }
}

class Slanted3DGrid extends StatefulWidget {
  final List<String> images;
  final int rows;
  final double speed;
  final double angle;
  final double verticalOffset;

  const Slanted3DGrid({
    super.key,
    required this.images,
    this.rows = 4,
    this.speed = 16.0, // Pixels per second
    this.angle = -0.1, // Rotation Z
    this.verticalOffset = 0.0,
  });

  @override
  State<Slanted3DGrid> createState() => _Slanted3DGridState();
}

class _Slanted3DGridState extends State<Slanted3DGrid> {
  late List<List<String>> _rowImages;

  @override
  void initState() {
    super.initState();
    _initializeRows();
  }

  void _initializeRows() {
    _rowImages = List.generate(
      widget.rows,
      (_) => List.of(widget.images)..shuffle(),
    );
  }

  @override
  void didUpdateWidget(Slanted3DGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.images != oldWidget.images) {
      _initializeRows();
    } else if (widget.rows != oldWidget.rows) {
      if (widget.rows > _rowImages.length) {
        final int newRowsCount = widget.rows - _rowImages.length;
        _rowImages.addAll(
          List.generate(
            newRowsCount,
            (_) => List.of(widget.images)..shuffle(),
          ),
        );
      } else {
        _rowImages.length = widget.rows;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    const double imageWidth = 80.0;
    const double imageHeight = imageWidth * 1.71;
    const double gap = 8.0;

    return LayoutBuilder(builder: (context, constraints) {
      final double width = constraints.maxWidth * 1.5;
      final double height = constraints.maxHeight * 1.5;

      return OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: Transform(
          alignment: Alignment.center,
          filterQuality: FilterQuality.medium,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..translate(0.0, widget.verticalOffset, 0.0)
            ..rotateX(-0.4)
            ..rotateY(0.1)
            ..rotateZ(widget.angle)
            ..scale(1.6)
            ..translate(0.0, -200.0, 0.0),
          child: SizedBox(
            width: width,
            height: height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.rows, (rowIndex) {
                // Calculate a unique speed multiplier for each row to ensure different speeds
                final double speedVariation = 0.8 + ((rowIndex * 3) % 5) * 0.2;

                // Alternate direction for each row
                final double direction = (rowIndex % 2 == 0) ? 1.0 : -1.0;

                final double rowSpeed = widget.speed * speedVariation * direction;

                final List<String> rowImageList = (rowIndex < _rowImages.length) ? _rowImages[rowIndex] : widget.images;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: gap / 2),
                  child: SizedBox(
                    height: imageHeight,
                    child: Marquee(
                      startPadding: rowIndex * (imageWidth + gap) / 2,
                      velocity: rowSpeed,
                      containerExtent: (imageWidth + gap) * rowImageList.length,
                      blankSpace: 0,
                      child: Row(
                        children: rowImageList.map((imgUrl) {
                          return Container(
                            width: imageWidth,
                            height: imageHeight,
                            margin: EdgeInsets.only(right: gap),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                  imgUrl,
                                  maxHeight: (imageHeight * ScreenUtils.pixelResolution * 5).toInt(),
                                  maxWidth: (imageWidth * ScreenUtils.pixelResolution * 5).toInt(),
                                ),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 4,
                                  offset: const Offset(2, 2),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );
    });
  }
}
