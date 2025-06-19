import 'dart:math' as math show max;

import 'package:defer_pointer/defer_pointer.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../../manager.dart';
import '../../services/navigation/shortcuts.dart';
import '../../utils/screen_utils.dart';
import '../../utils/time_utils.dart';
import '../gradient_mask.dart';
import 'header_widget.dart';
import 'infobar.dart';

class MiruRyoikiHeaderInfoBarPage extends StatefulWidget {
  final HeaderWidget headerWidget;
  final MiruRyoikiInfobar infobar;
  final Widget content;
  final Color? backgroundColor;
  final bool hideInfoBar;

  const MiruRyoikiHeaderInfoBarPage({
    super.key,
    required this.headerWidget,
    required this.infobar,
    required this.content,
    this.backgroundColor,
    this.hideInfoBar = false,
  });

  @override
  State<MiruRyoikiHeaderInfoBarPage> createState() => _MiruRyoikiHeaderInfoBarPageState();
}

class _MiruRyoikiHeaderInfoBarPageState extends State<MiruRyoikiHeaderInfoBarPage> {
  double _headerHeight = ScreenUtils.kMaxHeaderHeight;
  ImageProvider? _cachedImage;
  Future<ImageProvider?>? _imageFuture;

  @override
  void initState() {
    super.initState();
    // Start loading the image immediately and cache it
    _loadPosterImage();
  }

  Future<void> _loadPosterImage() async {
    try {
      // Use the infobar's getPosterImage method but only once
      final infobarCreator = widget.infobar;
      // Create a temporary infobar just to access its getPosterImage
      final tempInfobar = infobarCreator;

      _imageFuture = tempInfobar.getPosterImage;
      _cachedImage = await _imageFuture;
    } catch (e) {
      // Handle any errors during image loading
      print('Error loading poster image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create a modified infobar function that uses the cached image
    MiruRyoikiInfobar cachedInfobar() {
      final originalInfobar = widget.infobar;

      // Create a new infobar that uses the cached image
      return MiruRyoikiInfobar(
        key: originalInfobar.key,
        content: originalInfobar.content,
        poster: originalInfobar.poster,
        isProfilePicture: originalInfobar.isProfilePicture,
        // Replace the getPosterImage with a function that returns the cached image
        getPosterImage: Future.value(_cachedImage),
      );
    }

    return AnimatedContainer(
      duration: gradientChangeDuration,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.backgroundColor ?? Manager.accentColor.withOpacity(0.15),
            Colors.transparent,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          children: [
            // Sticky header
            AnimatedContainer(
              height: _headerHeight,
              width: double.infinity,
              duration: stickyHeaderDuration,
              curve: Curves.ease,
              alignment: Alignment.center,
              child: widget.headerWidget,
            ),
            Expanded(
              child: SizedBox(
                width: ScreenUtils.kMaxContentWidth,
                child: Row(
                  children: [
                    // Info bar on the left
                    if (!widget.hideInfoBar)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, left: 14.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          height: double.infinity,
                          width: ScreenUtils.kInfoBarWidth,
                          child: cachedInfobar(),
                        ),
                      ),
                    // Content area on the right
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: FadingEdgeScrollView(
                          fadeEdges: const EdgeInsets.symmetric(vertical: 16),
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(overscroll: true, platform: TargetPlatform.windows, scrollbars: false),
                            child: DynMouseScroll(
                              stopScroll: KeyboardState.ctrlPressedNotifier,
                              scrollSpeed: 1.8,
                              enableSmoothScroll: Manager.animationsEnabled,
                              durationMS: 350,
                              animationCurve: Curves.easeOut,
                              builder: (context, controller, physics) {
                                controller.addListener(() {
                                  final offset = controller.offset;
                                  final double newHeight = offset > 0 ? ScreenUtils.kMinHeaderHeight : ScreenUtils.kMaxHeaderHeight;
    
                                  if (newHeight != _headerHeight && mounted) //
                                    setState(() => _headerHeight = newHeight);
                                });
    
                                // Then use the controller for your scrollable content
                                return CustomScrollView(
                                  controller: controller,
                                  physics: physics,
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: widget.content,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
