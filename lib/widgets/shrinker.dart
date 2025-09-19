import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:miruryoiki/widgets/gradient_mask.dart';

import '../manager.dart';
import '../utils/time.dart';
import 'buttons/button.dart';

/// Controller for the Shrinker widget to programmatically expand/collapse
class ShrinkerController extends ChangeNotifier {
  bool _isExpanded = false;

  bool get isExpanded => _isExpanded;

  void expand() {
    if (!_isExpanded) {
      _isExpanded = true;
      notifyListeners();
    }
  }

  void collapse() {
    if (_isExpanded) {
      _isExpanded = false;
      notifyListeners();
    }
  }

  void toggle() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }
}

class Shrinker extends StatefulWidget {
  final Widget child;
  final double minHeight;
  final double maxHeight;
  final ShrinkerController? controller;
  final Duration animationDuration;
  final Curve animationCurve;
  final Widget? readMoreButton;
  final Widget? readLessButton;
  final Color? buttonBackgroundColor;
  final double buttonHeight;

  const Shrinker({
    super.key,
    required this.child,
    required this.minHeight,
    required this.maxHeight,
    this.controller,
    this.animationDuration = const Duration(milliseconds: 400),
    this.animationCurve = Curves.easeInOutQuad,
    this.readMoreButton,
    this.readLessButton,
    this.buttonBackgroundColor,
    this.buttonHeight = 40.0,
  }) : assert(minHeight > 0 && maxHeight > minHeight);

  @override
  State<Shrinker> createState() => _ShrinkerState();
}

class _ShrinkerState extends State<Shrinker> with SingleTickerProviderStateMixin {
  late ShrinkerController _controller;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  bool _needsShrinker = false;
  double _contentHeight = 0;
  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ShrinkerController();
    _controller.addListener(_handleControllerChange);

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _heightAnimation = Tween<double>(
      begin: widget.minHeight,
      end: widget.maxHeight,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));

    // Measure content height after first frame
    nextFrame(() => _measureContent());
  }

  @override
  void didUpdateWidget(covariant Shrinker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChange);
      _controller = widget.controller ?? ShrinkerController();
      _controller.addListener(_handleControllerChange);
    }

    if (oldWidget.minHeight != widget.minHeight || oldWidget.maxHeight != widget.maxHeight) {
      _heightAnimation = Tween<double>(
        begin: widget.minHeight,
        end: widget.maxHeight,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: widget.animationCurve,
      ));
    }

    // Re-measure content if child changes
    nextFrame(() => _measureContent());
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    if (widget.controller == null) _controller.dispose();

    _animationController.dispose();
    super.dispose();
  }

  void _measureContent() {
    final RenderBox? renderBox = _contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _contentHeight = renderBox.size.height;
        _needsShrinker = _contentHeight > widget.minHeight;
      });
    }
  }

  void _handleControllerChange() {
    if (_controller.isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Widget _buildButton([bool readMore = false]) {
    if (widget.readLessButton != null) return widget.readLessButton!;

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, right: 12.0),
        child: SizedBox(
          height: 25 * Manager.fontSizeMultiplier,
          width: 85 * Manager.fontSizeMultiplier,
          child: StandardButton(
            isFilled: readMore,
            isSmall: true,
            filledColor: widget.buttonBackgroundColor,
            hoverFillColor: widget.buttonBackgroundColor?.toAccentColor().light,
            onPressed: () => readMore ? _controller.expand() : _controller.collapse(),
            label: Text(readMore ? 'Read More' : 'Read Less', style: Manager.miniBodyStyle),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Wrap content in a measurable container
    final content = Column(
      key: _contentKey,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [widget.child],
    );

    // If content doesn't need shrinking, just return it as is
    if (!_needsShrinker) return content;

    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        final isExpanded = _controller.isExpanded;
        // Use the minimum of maxHeight and actual content height to prevent blank space
        final expandedHeight = _contentHeight > 0 ? _contentHeight.clamp(widget.minHeight, widget.maxHeight) : widget.maxHeight;

        return Stack(
          children: [
            // Content container
            AnimatedContainer(
              duration: widget.animationDuration,
              curve: widget.animationCurve,
              height: isExpanded ? expandedHeight : widget.minHeight,
              child: FadingEdgeScrollView(
                gradientColors: [
                  (widget.buttonBackgroundColor ?? Theme.of(context).scaffoldBackgroundColor).withOpacity(1.0),
                  (widget.buttonBackgroundColor ?? Theme.of(context).scaffoldBackgroundColor).withOpacity(0.0),
                ],
                gradientStops: isExpanded ? const [0.99, 1.0] : const [0.6, 0.85],
                child: ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(overscroll: false, scrollbars: isExpanded),
                  child: SingleChildScrollView(
                    physics: isExpanded ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
                    child: content,
                  ),
                ),
              ),
            ),

            // Read More/Less button overlay
            Positioned.fill(bottom: 0, right: 0, child: _buildButton(!isExpanded)),
          ],
        );
      },
    );
  }
}
