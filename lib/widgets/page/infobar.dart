import 'dart:math' as math show max;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../../manager.dart';
import '../../services/navigation/shortcuts.dart';
import '../../utils/image_utils.dart';
import '../../utils/screen_utils.dart';
import '../../utils/time_utils.dart';

class MiruRyoikiInfobar extends StatefulWidget {
  final Future<ImageProvider<Object>?>? getPosterImage;
  final Widget content;
  final bool noHeaderBanner;
  final Widget Function({
    required ImageProvider<Object>? imageProvider,
    required double width,
    required double height,
    required double squareness,
    required double offset,
  })? poster;
  final EdgeInsets Function(double posterExtraVertical) contentPadding;
  final bool isProfilePicture;
  final VoidCallback? setStateCallback;
  final List<Widget>? footer;
  final EdgeInsets footerPadding;

  const MiruRyoikiInfobar({
    super.key,
    required this.content,
    this.noHeaderBanner = false,
    this.poster,
    this.getPosterImage,
    this.isProfilePicture = false,
    EdgeInsets Function(double posterExtraVertical)? contentPadding,
    this.setStateCallback,
    this.footer,
    this.footerPadding = const EdgeInsets.all(32.0),
  }) : contentPadding = contentPadding ?? _defaultContentPadding;

  static EdgeInsets _defaultContentPadding(double _) => const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);

  @override
  State<MiruRyoikiInfobar> createState() => _MiruRyoikiInfobarState();
}

class _MiruRyoikiInfobarState extends State<MiruRyoikiInfobar> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.getPosterImage,
        builder: (context, snapshot) {
          ImageProvider? imageProvider = snapshot.data;
          if (imageProvider == null) //
            nextFrame(() => (mounted) ? widget.setStateCallback?.call() : null);

          Widget fb(Widget Function(double squareness, double posterWidth, double posterHeight, ImageProvider<Object>? imageProvider, double getInfoBarOffset) child) {
            return FutureBuilder(
              future: getImageDimensions(imageProvider),
              builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
                double posterWidth = 230.0; // Default width
                double posterHeight = 326.0; // Default height
                final double squareSize = 253.0;
                double getInfoBarOffset = 0;

                if (snapshot.hasData && snapshot.data != null) {
                  final Size originalSize = snapshot.data!;

                  // Avoid division by zero when image is empty
                  if (originalSize.width > 0 && originalSize.height > 0) {
                    final double aspectRatio = originalSize.height / originalSize.width;

                    double maxWidth = 326.0;
                    double maxHeight = 300.0;

                    // Constrain aspect ratio between ScreenUtils.kDefaultAspectRatio and 1.41
                    double effectiveAspectRatio = aspectRatio;
                    if (aspectRatio < ScreenUtils.kDefaultAspectRatio) effectiveAspectRatio = ScreenUtils.kDefaultAspectRatio;
                    if (aspectRatio > 1.41) effectiveAspectRatio = 1.41;

                    // For square images (aspect ratio around 1), fit to the green box
                    if (effectiveAspectRatio < 1) {
                      // Wider than tall: linearly interpolate width based on distance from square
                      // As AR approaches ScreenUtils.kDefaultAspectRatio, width approaches maxWidth (326)
                      double ratioFactor = (1 - effectiveAspectRatio) / (1 - ScreenUtils.kDefaultAspectRatio); // 0 when AR=1, 1 when AR=ScreenUtils.kDefaultAspectRatio
                      posterWidth = squareSize + (maxWidth - squareSize) * ratioFactor;
                      posterHeight = posterWidth * effectiveAspectRatio;

                      // Ensure we don't exceed height bound
                      if (posterHeight > maxHeight) {
                        posterHeight = maxHeight;
                        posterWidth = posterHeight / effectiveAspectRatio;
                      }
                    } else {
                      double ratioFactor = (effectiveAspectRatio - 1) / (1.41 - 1); // 0 when AR=1, 1 when AR=1.41
                      posterHeight = squareSize + (maxHeight - squareSize) * ratioFactor;
                      posterWidth = posterHeight / effectiveAspectRatio;

                      // Ensure we don't exceed width bound
                      if (posterWidth > maxWidth) {
                        posterWidth = maxWidth;
                        posterHeight = posterWidth * effectiveAspectRatio;
                      }
                    }
                    getInfoBarOffset = math.max(posterHeight - squareSize - 16, 0);
                  }
                }
                print('width: $posterWidth, height: $posterHeight, offset: $getInfoBarOffset');

                final double squareness = (getInfoBarOffset / 31);
                return child(squareness, posterWidth, posterHeight, imageProvider, getInfoBarOffset);
              },
            );
          }

          Widget child({required double squareness, required double posterWidth, required double posterHeight, required ImageProvider<Object>? imageProvider, required double getInfoBarOffset}) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: widget.noHeaderBanner ? 0.0 : 16.0, left: 14.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context).copyWith(
                                overscroll: true,
                                platform: TargetPlatform.windows,
                                scrollbars: false,
                              ),
                              child: DynMouseScroll(
                                stopScroll: KeyboardState.ctrlPressedNotifier,
                                scrollSpeed: 1.0,
                                enableSmoothScroll: Manager.animationsEnabled,
                                durationMS: 350,
                                animationCurve: Curves.easeOutQuint,
                                builder: (context, controller, physics) {
                                  return SingleChildScrollView(
                                    controller: controller,
                                    physics: physics,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: 0,
                                        maxWidth: ScreenUtils.kInfoBarWidth,
                                      ),
                                      child: Padding(
                                        padding: widget.contentPadding(getInfoBarOffset),
                                        child: widget.content,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (widget.footer != null && widget.footer!.isNotEmpty) VDiv(8),
                      if (widget.footer != null && widget.footer!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 14.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Padding(
                              padding: widget.footerPadding,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: widget.footer!,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Poster image that overflows the info bar from above to appear 'in' the header
                if (widget.poster != null && imageProvider != null)
                  AnimatedPositioned(
                    duration: stickyHeaderDuration,
                    left: (ScreenUtils.kInfoBarWidth) / 2 - posterWidth / 2,
                    top: widget.isProfilePicture ? -30 - posterHeight : -(ScreenUtils.kMaxHeaderHeight) + 32,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(ScreenUtils.kProfilePictureBorderRadius),
                      child: widget.poster!(
                        imageProvider: imageProvider,
                        width: posterWidth,
                        height: posterHeight,
                        squareness: squareness,
                        offset: getInfoBarOffset,
                      ),
                    ),
                  ),
              ],
            );
          }

          if (imageProvider == null || widget.poster == null) //
            return child(
              squareness: 0,
              posterWidth: 0,
              posterHeight: 0,
              imageProvider: null,
              getInfoBarOffset: 0,
            );

          if (widget.isProfilePicture) {
            return child(
              squareness: 0,
              posterWidth: ScreenUtils.kProfilePictureSize,
              posterHeight: ScreenUtils.kProfilePictureSize,
              imageProvider: imageProvider,
              getInfoBarOffset: 0,
            );
          } else {
            // Dynamic poster size based on image aspect ratio
            return fb((squareness, posterWidth, posterHeight, imageProvider, getInfoBarOffset) {
              return child(
                squareness: squareness,
                posterWidth: posterWidth,
                posterHeight: posterHeight + getInfoBarOffset,
                imageProvider: imageProvider,
                getInfoBarOffset: getInfoBarOffset,
              );
            });
          }
        });
  }
}
