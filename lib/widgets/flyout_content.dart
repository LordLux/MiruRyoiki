import 'package:fluent_ui2/fluent_ui.dart' show Acrylic, HoverButton, kMenuColorOpacity;
import 'package:flutter/material.dart';

import '../utils/color_utils.dart';

/// Eyeballed value from Windows Home 11.
const kFlyoutMinConstraints = BoxConstraints(minWidth: 118);

/// The content of the flyout
///
/// See also:
///
///   * [FlyoutTarget], which the flyout is displayed attached to
///   * [SimpleFlyoutListTile], a list tile adapted to flyouts
class SimpleFlyoutContent extends StatelessWidget {
  /// Creates a flyout content
  const SimpleFlyoutContent({
    super.key,
    required this.child,
    this.color,
    this.shape,
    this.padding = const EdgeInsets.all(8.0),
    this.shadowColor = Colors.black,
    this.elevation = 8.0,
    this.constraints = kFlyoutMinConstraints,
    this.useAcrylic = true,
  });

  /// The content of the flyout
  final Widget child;

  /// The background color of the box.
  ///
  /// If null, [FluentThemeData.menuColor] is used by default
  final Color? color;

  /// The shape to fill the [color] of the box.
  final ShapeBorder? shape;

  /// Empty space to inscribe around the [child]
  ///
  /// Defaults to 8.0 on each side
  final EdgeInsetsGeometry padding;

  /// The color of the shadow. Not used if [elevation] is 0.0.
  ///
  /// Defaults to black.
  final Color shadowColor;

  /// The z-coordinate relative to the box at which to place this physical
  /// object.
  ///
  /// See also:
  ///
  ///  * [shadowColor], the color of the elevation shadow.
  final double elevation;

  /// Constraints to apply to the child.
  ///
  /// Defaults to [kFlyoutMinConstraints].
  final BoxConstraints constraints;

  /// Whether the background will be an [Acrylic].
  final bool useAcrylic;

  @override
  Widget build(BuildContext context) {
    final resolvedShape = shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            width: 1,
          ),
        );

    final resolvedBorderRadius = () {
      if (resolvedShape is RoundedRectangleBorder) {
        return resolvedShape.borderRadius;
      } else if (resolvedShape is ContinuousRectangleBorder) {
        return resolvedShape.borderRadius;
      } else if (resolvedShape is BeveledRectangleBorder) {
        return resolvedShape.borderRadius;
      } else {
        return null;
      }
    }();

    final content = Container(
      constraints: constraints,
      decoration: ShapeDecoration(
        color: color ?? darken(Colors.grey).withValues(alpha: kMenuColorOpacity + .3),
        shape: resolvedShape,
      ),
      padding: padding,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: 14,
          color: color,
          fontWeight: FontWeight.normal,
        ),
        child: child,
      ),
    );
    final content2 = Acrylic(
      tintAlpha: !useAcrylic ? 1.0 : null,
      shape: resolvedShape,
      child: content,
    );

    if (elevation > 0.0) {
      return PhysicalModel(
        elevation: elevation,
        color: Colors.transparent,
        borderRadius: resolvedBorderRadius?.resolve(TextDirection.ltr),
        shadowColor: shadowColor,
        child: content2,
      );
    }

    return content2;
  }
}

/// A tile that is used inside of [SimpleFlyoutContent].
///
/// See also:
///
///  * [FlyoutTarget], which the flyout is displayed attached to
///  * [SimpleFlyoutContent], the content of the flyout
class SimpleFlyoutListTile extends StatelessWidget {
  /// Creates a flyout list tile.
  const SimpleFlyoutListTile({
    super.key,
    this.onPressed,
    this.onLongPress,
    this.tooltip,
    this.icon,
    required this.text,
    this.trailing,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.margin = const EdgeInsetsDirectional.only(bottom: 5.0),
    this.selected = false,
    this.showSelectedIndicator = true,
  });

  /// Called when the tile is tapped or otherwise activated.
  final VoidCallback? onPressed;

  /// Called when the tile is long-pressed.
  final VoidCallback? onLongPress;

  /// The tile tooltip text
  final String? tooltip;

  /// The leading widget.
  ///
  /// Usually an [Icon]
  final Widget? icon;

  /// The title widget.
  ///
  /// Usually a [Text]
  final Widget text;

  /// The leading widget.
  final Widget? trailing;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// {@macro fluent_ui.controls.inputs.HoverButton.semanticLabel}
  final String? semanticLabel;

  final EdgeInsetsGeometry margin;

  final bool selected;

  final bool showSelectedIndicator;

  bool get isEnabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      builder: (context, states) {
        final radius = BorderRadius.circular(4.0);

        if (selected) {
          states = {WidgetState.hovered};
        }

        final foregroundColor = Colors.transparent;

        Widget content = Stack(children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: radius,
            ),
            padding: const EdgeInsetsDirectional.only(
              top: 4.0,
              bottom: 4.0,
              start: 10.0,
              end: 8.0,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10.0),
                  child: IconTheme.merge(
                    data: IconThemeData(size: 16.0, color: foregroundColor),
                    child: icon!,
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10.0),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      fontSize: 14.0,
                      letterSpacing: -0.15,
                      color: foregroundColor,
                    ),
                    child: text,
                  ),
                ),
              ),
              if (trailing != null)
                DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: 12.0,
                    height: 0.7,
                  ),
                  child: trailing!,
                ),
            ]),
          ),
          if (selected && showSelectedIndicator)
            PositionedDirectional(
              top: 0,
              bottom: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                width: 2.5,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
        ]);

        if (tooltip != null) {
          content = Tooltip(message: tooltip, child: content);
        }

        return Padding(
          padding: margin,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: radius,
            ),
            child: content,
          ),
        );
      },
    );
  }
}
