import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/utils/time_utils.dart';

import '../utils/logging.dart';

class LoadingButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;
  final bool isButtonDisabled;
  final bool isSmall;
  final bool isAlreadyBig;

  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.isLoading,
    this.isButtonDisabled = false,
    this.isSmall = false,
    this.isAlreadyBig = false,
  });

  @override
  _LoadingButtonState createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool isLocalLoading = false;

  double get minusSmall => widget.isSmall ? 12 : 0;

  double get horizPadding {
    if (widget.isLoading) return 32;
    if (widget.isAlreadyBig) return 32;
    return widget.isSmall ? 12 : 16;
  }

  @override
  Widget build(BuildContext context) {
    return MouseButtonWrapper(
      isButtonDisabled: widget.isButtonDisabled,
      isLoading: widget.isLoading,
      child: Button(
        onPressed: widget.isButtonDisabled ? null : widget.onPressed,
        style: ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.zero)),
        child: SizedBox(
          height: widget.isSmall ? 32 : 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedSlide(
                offset: widget.isLoading ? const Offset(-0.125, 0) : Offset.zero,
                duration: shortStickyHeaderDuration,
                curve: Curves.easeInOut,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizPadding),
                  child: Text(widget.label),
                ),
              ),
              Positioned(
                right: 15,
                child: AnimatedOpacity(
                  opacity: widget.isLoading ? 1.0 : 0.0,
                  duration: shortStickyHeaderDuration,
                  child: SizedBox(
                    width: widget.isSmall ? 20 : 25,
                    height: widget.isSmall ? 20 : 25,
                    child: ProgressRing(
                      strokeWidth: widget.isSmall ? 3.5 : 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget MouseButtonWrapper({
  required Widget child,
  bool isButtonDisabled = false,
  bool isLoading = false,
}) {
  return MouseRegion(
    cursor: isButtonDisabled
        ? SystemMouseCursors.forbidden
        : isLoading
            ? SystemMouseCursors.progress
            : SystemMouseCursors.click,
    child: child,
  );
}
