import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/utils/time.dart';

import '../../manager.dart';
import '../../utils/color.dart';
import '../../utils/text.dart';
import 'wrapper.dart';

const _kDefaultBuilder = _defaultBuilder;
Widget _defaultBuilder(Widget child) => child;

/// A customizable button widget with loading and tooltip capabilities.
///
/// When [onPressed] is null, the button acts as a styled display container:
/// no pointer interaction, cursor defaults to [SystemMouseCursors.basic],
/// and hover color is still shown via the surrounding [MouseRegion].
class StandardButton extends StatefulWidget {
  final Widget label;
  final VoidCallback? onPressed;
  final bool isButtonDisabled;
  final bool isSmall;
  final bool isWide;
  final bool isLoading;
  final bool isFilled;

  /// When true, always shows the filled background color regardless of hover
  /// state. Useful for "selected" display-only containers.
  final bool isSelected;

  final String? tooltip;
  final Widget? tooltipWidget;
  final bool expand;
  final bool expandY;
  final Duration? tooltipWaitDuration;
  final EdgeInsets? padding;

  /// Override for the rest/pressed background color.
  ///   - Filled:     defaults to [Manager.accentColor.lighter]
  ///   - Non-filled: defaults to [FluentTheme.of(context).resources.controlFillColorDefault]
  final Color? backgroundColor;

  /// Override for the hover background color.
  ///   - Filled:     defaults to [Manager.accentColor.lightest]
  ///   - Non-filled: defaults to [FluentTheme.of(context).resources.controlFillColorSecondary]
  final Color? hoverColor;

  final double? forcedHeight;

  /// Override for the mouse cursor. When null:
  ///   - [onPressed] is null → [SystemMouseCursors.basic]
  ///   - Otherwise           → [SystemMouseCursors.click]
  final MouseCursor? cursor;

  final Widget Function(Widget child) builder;
  final Widget? background;

  const StandardButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isButtonDisabled = false,
    this.isSmall = true,
    this.isWide = true,
    this.isFilled = false,
    this.isSelected = false,
    this.isLoading = false,
    this.tooltip,
    this.tooltipWidget,
    this.expand = false,
    this.expandY = false,
    this.tooltipWaitDuration,
    this.padding,
    this.forcedHeight,
    this.cursor,
    this.backgroundColor,
    this.hoverColor,
    this.builder = _kDefaultBuilder,
    this.background,
  });

  factory StandardButton.iconLabel({
    GlobalKey? key,
    required Widget icon,
    required Widget label,
    required VoidCallback? onPressed,
    bool isButtonDisabled = false,
    bool isSmall = true,
    bool isWide = true,
    bool switchIconWithLabel = false,
    bool isFilled = false,
    bool isSelected = false,
    bool isLoading = false,
    String? tooltip,
    Widget? tooltipWidget,
    bool expand = false,
    bool expandY = false,
    Duration? tooltipWaitDuration,
    EdgeInsets? padding,
    TextStyle? textStyle,
    Color? backgroundColor,
    Color? hoverColor,
    MouseCursor? cursor,
    Widget Function(Widget child) builder = _kDefaultBuilder,
    Widget? background,
  }) {
    final leftPad = const EdgeInsets.only(left: 4);
    final rightPad = const EdgeInsets.only(right: 4);
    var list = [
      icon,
      const SizedBox(width: 8),
      Transform.translate(
        offset: const Offset(0, -.75),
        child: Padding(padding: switchIconWithLabel ? leftPad : rightPad, child: label),
      ),
    ];
    if (switchIconWithLabel) list = list.reversed.toList();

    return StandardButton(
      key: key,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: list,
      ),
      onPressed: onPressed,
      isButtonDisabled: isButtonDisabled,
      isSmall: isSmall,
      isWide: isWide,
      isFilled: isFilled,
      isSelected: isSelected,
      isLoading: isLoading,
      tooltip: tooltip,
      tooltipWidget: tooltipWidget,
      expand: expand,
      expandY: expandY,
      tooltipWaitDuration: tooltipWaitDuration,
      padding: padding,
      backgroundColor: backgroundColor,
      hoverColor: hoverColor,
      cursor: cursor,
      builder: builder,
      background: background,
    );
  }

  factory StandardButton.icon({
    GlobalKey? key,
    required Widget icon,
    required VoidCallback? onPressed,
    bool isButtonDisabled = false,
    bool isSmall = true,
    bool isWide = true,
    bool isFilled = false,
    bool isSelected = false,
    bool isLoading = false,
    String? tooltip,
    Widget? tooltipWidget,
    bool expand = false,
    bool expandY = false,
    Duration? tooltipWaitDuration,
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? hoverColor,
    MouseCursor? cursor,
    Widget Function(Widget child) builder = _kDefaultBuilder,
    Widget? background,
  }) {
    return StandardButton(
      key: key,
      label: icon,
      onPressed: onPressed,
      isButtonDisabled: isButtonDisabled,
      isSmall: isSmall,
      isWide: isWide,
      isFilled: isFilled,
      isSelected: isSelected,
      isLoading: isLoading,
      tooltip: tooltip,
      tooltipWidget: tooltipWidget,
      expand: expand,
      expandY: expandY,
      tooltipWaitDuration: tooltipWaitDuration,
      padding: padding ?? (isSmall ? const EdgeInsets.symmetric(horizontal: 6, vertical: 4) : null),
      backgroundColor: backgroundColor,
      hoverColor: hoverColor,
      cursor: cursor,
      builder: builder,
      background: background,
    );
  }

  factory StandardButton.label({
    GlobalKey? key,
    required String label,
    required VoidCallback? onPressed,
    bool isButtonDisabled = false,
    bool isSmall = true,
    bool isWide = true,
    bool isFilled = false,
    bool isSelected = false,
    bool isLoading = false,
    String? tooltip,
    Widget? tooltipWidget,
    bool expand = false,
    bool expandY = false,
    Duration? tooltipWaitDuration,
    EdgeInsets? padding,
    TextStyle? textStyle,
    Color? backgroundColor,
    Color? hoverColor,
    MouseCursor? cursor,
    Widget Function(Widget child) builder = _kDefaultBuilder,
    Widget? background,
  }) {
    return StandardButton(
      key: key,
      label: Text(label, style: getStyleBasedOnAccent(isFilled)),
      onPressed: onPressed,
      isButtonDisabled: isButtonDisabled,
      isSmall: isSmall,
      isWide: isWide,
      isFilled: isFilled,
      isSelected: isSelected,
      expand: expand,
      expandY: expandY,
      tooltip: tooltip,
      tooltipWidget: tooltipWidget,
      isLoading: isLoading,
      tooltipWaitDuration: tooltipWaitDuration,
      padding: padding,
      backgroundColor: backgroundColor,
      hoverColor: hoverColor,
      cursor: cursor,
      builder: builder,
      background: background,
    );
  }

  @override
  State<StandardButton> createState() => _StandardButtonState();
}

class _StandardButtonState extends State<StandardButton> {
  /// Last resolved background color (rest state), used as the animation start
  /// for the next color transition.
  Color? _prevBg;

  /// Last resolved hover color, used as the animation start for the next
  /// color transition.
  Color? _prevHover;

  Color _resolveBg(BuildContext ctx) {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    final resources = FluentTheme.of(ctx).resources;
    return widget.isFilled ? Manager.accentColor.lighter : resources.controlFillColorDefault;
  }

  Color _resolveHover(BuildContext ctx) {
    if (widget.hoverColor != null) return widget.hoverColor!;
    final resources = FluentTheme.of(ctx).resources;
    return widget.isFilled ? Manager.accentColor.lightest : resources.controlFillColorSecondary;
  }

  Color _resolvePressed(BuildContext ctx) {
    // For filled: same as rest (accent lighter).
    // For non-filled: use the theme's "tertiary" fill (darker than secondary).
    // If the caller provided a backgroundColor override, keep that for pressed too.
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    final resources = FluentTheme.of(ctx).resources;
    return widget.isFilled ? Manager.accentColor.lighter : resources.controlFillColorTertiary;
  }

  @override
  Widget build(BuildContext context) {
    final bg = _resolveBg(context);
    final hover = _resolveHover(context);
    final pressed = _resolvePressed(context);

    // Capture previous values for the animation start, then update stored
    // values so the NEXT change animates from where we currently are.
    final fromBg = _prevBg ?? bg;
    final fromHover = _prevHover ?? hover;
    _prevBg = bg;
    _prevHover = hover;

    final foregroundColor = getPrimaryColorBasedOnAccent();

    final effectiveCursor = widget.cursor ?? (widget.onPressed == null && !widget.isLoading && !widget.isButtonDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click);

    Widget buttonWidget = MouseButtonWrapper(
      isButtonDisabled: widget.isButtonDisabled,
      isLoading: widget.isLoading,
      cursor: effectiveCursor,
      tooltip: widget.tooltip,
      tooltipWaitDuration: widget.tooltipWaitDuration,
      tooltipWidget: widget.tooltipWidget,
      child: (isHovered) => TweenAnimationBuilder<Color?>(
        tween: ColorTween(begin: fromBg, end: bg),
        duration: dimDuration,
        builder: (context, animBg, _) => TweenAnimationBuilder<Color?>(
          tween: ColorTween(begin: fromHover, end: hover),
          duration: dimDuration,
          builder: (context, animHover, _) => AbsorbPointer(
            absorbing: widget.isButtonDisabled || widget.isLoading || widget.onPressed == null,
            child: Button(
              onPressed: widget.isButtonDisabled ? null : widget.onPressed,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (widget.isSelected) return animBg;
                  if (states.isPressed) return pressed;
                  // Use isHovered from MouseRegion so hover works even when
                  // onPressed == null (Button is disabled, states.isHovered won't fire).
                  if (isHovered) return animHover;
                  return animBg;
                }),
                foregroundColor: WidgetStatePropertyAll(foregroundColor),
                padding: WidgetStatePropertyAll(EdgeInsets.zero),
              ),
              child: SizedBox(
                height: widget.forcedHeight ?? (widget.isSmall ? 32 : 48),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (widget.background != null) Positioned.fill(child: widget.background!),
                    widget.builder(
                      AnimatedSlide(
                        offset: Offset.zero,
                        duration: shortStickyHeaderDuration,
                        curve: Curves.easeInOut,
                        child: Padding(
                          padding: widget.padding ?? EdgeInsets.symmetric(horizontal: widget.isWide ? 16 : 12),
                          child: FluentTheme(
                            data: FluentTheme.of(context).copyWith(
                              iconTheme: FluentTheme.of(context).iconTheme.copyWith(color: getIconColorBasedOnAccent(widget.isFilled)),
                            ),
                            child: AnimatedDefaultTextStyle(
                              duration: dimDuration,
                              style: getStyleBasedOnAccent(widget.isFilled),
                              child: widget.label,
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
      ),
    );

    if (widget.expand || widget.expandY) {
      return SizedBox(
        width: widget.expand ? double.infinity : null,
        height: widget.expandY ? double.infinity : null,
        child: buttonWidget,
      );
    }
    return buttonWidget;
  }
}
