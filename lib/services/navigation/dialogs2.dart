// ignore_for_file: use_build_context_synchronously

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:glossy/glossy.dart';
import 'package:miruryoiki/utils/screen.dart';
import '../../widgets/frosted_noise.dart';
import 'dialogs.dart';
import 'navigation.dart';

/// A navigation item that represents a dialog in the navigation system.
///
/// This class extends [NavigationItem] to provide dialog-specific functionality,
/// including lifecycle management, dismissal callbacks, and validation checks.
class DialogNavigationItem extends NavigationItem {
  /// Creates a navigation item for a dialog.
  ///
  /// The [id] and [title] are required.
  /// [data] can be used to pass arbitrary data.
  /// [onDismiss] is called when the dialog is dismissed.
  /// [dialogDoPopCheck] determines if the dialog can be popped (defaults to always true).
  DialogNavigationItem({
    required super.id,
    required super.title,
    super.data,
    this.onDismiss,
    bool Function()? dialogDoPopCheck = kReturnTrueCallback,
  })  : dialogDoPopCheck = dialogDoPopCheck ?? kReturnTrueCallback,
        super(level: NavigationLevel.dialog);

  /// Stores the active route so the Manager can pop it remotely.
  /// This is set automatically when showManagedDialog is called.
  Route<dynamic>? activeRoute;

  /// Callback to be called when the dialog is dismissed.
  final VoidCallback? onDismiss;

  /// A function that checks whether the dialog can be popped at the moment of non-barrier dismissal.
  final bool Function() dialogDoPopCheck;
}

/// Configuration options for dialogs with customizable barriers.
///
/// Controls the appearance and behavior of the semi-transparent barrier that
/// appears behind dialogs, including color, padding, and dismissal behavior.
class PaddedBarrierOptions {
  /// Creates configuration options for a dialog barrier.
  const PaddedBarrierOptions({
    this.barrierColor = const Color(0x8A000000),
    this.exactColor = false,
    this.barrierPadding = const EdgeInsets.only(top: ScreenUtils.kTitleBarHeight),
    this.userDismissable = true,
    this.transluscentBarrier = false,
  });

  /// The color of the barrier. Defaults to semi-transparent black.
  final Color? barrierColor;

  /// Whether to use the exact [barrierColor] or a lerped version of it.
  final bool exactColor;

  /// Whether the dialog can be dismissed by the user with outside taps, Escape key, or Mouse Back button.
  final bool userDismissable;

  /// Whether the barrier should let interactions through or not.
  final bool transluscentBarrier;

  /// Padding for the barrier, for example to allow interactions on custom titlebar.
  final EdgeInsets barrierPadding;

  /// Creates a copy of this object with the given fields replaced with the new values.
  PaddedBarrierOptions copyWith({
    Color? barrierColor,
    bool? exactColor,
    EdgeInsets? barrierPadding,
    bool? userDismissable,
    bool? transluscentBarrier,
  }) {
    return PaddedBarrierOptions(
      barrierColor: barrierColor ?? this.barrierColor,
      exactColor: exactColor ?? this.exactColor,
      barrierPadding: barrierPadding ?? this.barrierPadding,
      userDismissable: userDismissable ?? this.userDismissable,
      transluscentBarrier: transluscentBarrier ?? this.transluscentBarrier,
    );
  }
}

enum _PaddedDialogType {
  simple,
  custom,
}

/// Represents the position of a dialog on the screen.
class Position {
  /// Distance from the top edge.
  final double? top;

  /// Distance from the bottom edge.
  final double? bottom;

  /// Distance from the left edge.
  final double? left;

  /// Distance from the right edge.
  final double? right;

  /// Creates a [Position] with optional offsets.
  Position({this.top, this.bottom, this.left, this.right});

  /// Creates a [Position] from a standard [Alignment].
  factory Position.fromAlignment(Alignment alignment) {
    return switch (alignment) {
      Alignment.topLeft => Position(top: 0, left: 0),
      Alignment.topCenter => Position(top: 0),
      Alignment.topRight => Position(top: 0, right: 0),
      Alignment.centerRight => Position(right: 0),
      Alignment.center => Position(),
      Alignment.bottomRight => Position(bottom: 0, right: 0),
      Alignment.bottomCenter => Position(bottom: 0),
      Alignment.bottomLeft => Position(bottom: 0, left: 0),
      Alignment.centerLeft => Position(left: 0),
      _ => Position(
        top: ScreenUtils.height * ((alignment.y + 1) / 2),
        left: ScreenUtils.width * ((alignment.x + 1) / 2),
      ),
    };
  }
  
  @override
  String toString() {
    final StringBuffer sb = StringBuffer('Position(');
    if (top != null) sb.write('top: $top, ');
    if (bottom != null) sb.write('bottom: $bottom, ');
    if (left != null) sb.write('left: $left, ');
    if (right != null) sb.write('right: $right)');
    return sb.toString();
  }
}

/// A dialog widget that supports custom padding, positioning, and barrier options.
///
/// This widget can be created using one of the factory constructors:
/// * [PaddedDialog.simple] for a standard dialog with title, content, and actions.
/// * [PaddedDialog.custom] for a fully custom dialog content.
/// * [PaddedDialog.frosted] for a dialog with a frosted glass effect.
class PaddedDialog extends StatefulWidget {
  /// Title of the dialog.
  final Widget? title;

  /// Content builder for the dialog.
  final Widget Function(BuildContext, BoxConstraints) contentBuilder;

  /// Actions builder for the dialog.
  final List<Widget> Function(Object?)? actions;

  /// Constraints for the dialog.
  final BoxConstraints constraints;

  /// Alignment for the dialog.
  final Position? alignment;

  /// Theme for the dialog.
  final ContentDialogThemeData? theme;

  /// Padding around the dialog content.
  final EdgeInsets padding;

  /// Callback when the dialog is dismissed.
  final VoidCallback? onDismiss;

  /// Navigation item associated with this dialog.
  final DialogNavigationItem? navigationItem;

  /// Barrier options for this dialog.
  final PaddedBarrierOptions barrierOptions;

  final _PaddedDialogType _type;

  /// Creates a [PaddedDialog].
  const PaddedDialog({
    super.key,
    required this.title,
    required this.contentBuilder,
    EdgeInsets? padding,
    this.actions,
    BoxConstraints? constraints,
    this.theme,
    this.alignment,
    this.onDismiss,
    this.navigationItem,
    PaddedBarrierOptions? barrierOptions,
    _PaddedDialogType type = _PaddedDialogType.custom,
  })  : _type = type,
        padding = padding ?? const EdgeInsets.all(16.0),
        constraints = constraints ?? const BoxConstraints(maxWidth: 500, maxHeight: 300, minWidth: 300),
        // [navigationItem] can't be defaulted here
        barrierOptions = barrierOptions ?? const PaddedBarrierOptions();

  /// Creates a simple dialog with title, content and actions.
  ///
  /// * [title]: Title of the dialog.
  /// * [content]: Content of the dialog.
  /// * [padding]: Padding around the dialog.
  /// * [actions]: Actions for the dialog.
  /// * [constraints]: Constraints for the dialog size.
  /// * [alignment]: Alignment of the dialog on screen. Use [Position.fromAlignment] for common alignments.
  /// * [theme]: Theme for the dialog.
  /// * [onDismiss]: Callback when the dialog is dismissed.
  /// * [navigationItem]: Navigation item for the dialog.
  /// * [barrierOptions]: Barrier options for the dialog.
  factory PaddedDialog.simple({
    required Widget? title,
    required Widget content,
    EdgeInsets? padding,
    List<Widget>? actions,
    required BoxConstraints? constraints,
    Position? alignment,
    ContentDialogThemeData? theme,
    VoidCallback? onDismiss,
    required DialogNavigationItem? navigationItem,
    required PaddedBarrierOptions? barrierOptions,
  }) {
    alignment ??= Position.fromAlignment(Alignment.center);
    constraints ??= BoxConstraints(maxWidth: 500, maxHeight: 300, minWidth: 300);
    return PaddedDialog(
      title: title,
      contentBuilder: (_, __) => content,
      padding: padding,
      actions: (data) => actions ?? [],
      constraints: constraints,
      alignment: alignment,
      theme: theme,
      onDismiss: onDismiss,
      navigationItem: navigationItem,
      barrierOptions: barrierOptions,
      type: _PaddedDialogType.simple,
    );
  }

  /// Creates a custom dialog with full control over content.
  ///
  /// * [content]: The content of the dialog.
  /// * [padding]: Padding around the dialog.
  /// * [constraints]: Constraints for the dialog size.
  /// * [alignment]: Alignment of the dialog on screen. Use [Position.fromAlignment] for common alignments.
  /// * [onDismiss]: Callback when the dialog is dismissed.
  /// * [navigationItem]: Navigation item for the dialog.
  /// * [barrierOptions]: Barrier options for the dialog.
  factory PaddedDialog.custom({
    required Widget Function(BuildContext, BoxConstraints) contentBuilder,
    EdgeInsets? padding,
    required BoxConstraints? constraints,
    Position? alignment,
    VoidCallback? onDismiss,
    required DialogNavigationItem? navigationItem,
    required PaddedBarrierOptions? barrierOptions,
  }) {
    alignment ??= Position.fromAlignment(Alignment.center);
    constraints ??= BoxConstraints(maxWidth: 500, maxHeight: 300, minWidth: 300);
    return PaddedDialog(
      title: null,
      contentBuilder: (context, constraints) {
        constraints = _fixConstraints(constraints);
        return contentBuilder(context, constraints);
      },
      padding: padding,
      constraints: constraints,
      alignment: alignment,
      onDismiss: onDismiss,
      navigationItem: navigationItem,
      barrierOptions: barrierOptions,
      type: _PaddedDialogType.custom,
    );
  }

  /// Creates a frosted glass style dialog.
  ///
  /// * [content]: The content of the dialog.
  /// * [padding]: Padding around the dialog.
  /// * [constraints]: Constraints for the dialog size.
  /// * [alignment]: Alignment of the dialog on screen. Use [Position.fromAlignment] for common alignments.
  /// * [onDismiss]: Callback when the dialog is dismissed.
  /// * [navigationItem]: Navigation item for the dialog.
  /// * [barrierOptions]: Barrier options for the dialog.
  factory PaddedDialog.frosted({
    required Widget content,
    required BoxConstraints? constraints,
    EdgeInsets? padding,
    Position? alignment,
    VoidCallback? onDismiss,
    required DialogNavigationItem? navigationItem,
    required PaddedBarrierOptions? barrierOptions,
  }) {
    alignment ??= Position.fromAlignment(Alignment.center);
    constraints ??= BoxConstraints(maxWidth: 250, minWidth: 250);
    return PaddedDialog(
      title: null,
      contentBuilder: (context, constraints) {
        constraints = _fixConstraints(constraints);
        return GlossyContainer(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: Colors.black,
          opacity: 0.1,
          strengthX: 20,
          strengthY: 20,
          blendMode: BlendMode.src,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              FrostedNoise(
                intensity: 0.7,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: content,
                ),
              ),
            ],
          ),
        );
      },
      padding: padding,
      constraints: constraints,
      alignment: alignment,
      onDismiss: onDismiss,
      navigationItem: navigationItem,
      barrierOptions: barrierOptions,
      type: _PaddedDialogType.custom,
    );
  }

  static BoxConstraints _fixConstraints(BoxConstraints constraints) {
    if (constraints.maxWidth == double.infinity || constraints.maxHeight == double.infinity) constraints = constraints.copyWith(maxWidth: ScreenUtils.width, maxHeight: ScreenUtils.height);
    return constraints;
  }

  @override
  State<PaddedDialog> createState() => PaddedDialogState();
}

/// State for [PaddedDialog].
class PaddedDialogState extends State<PaddedDialog> {
  late BoxConstraints currentConstraints;
  late Position? alignment;

  @override
  void initState() {
    super.initState();
    currentConstraints = widget.constraints;
    alignment = widget.alignment;
  }

  /// Resizes the dialog to the given dimensions or constraints.
  void resizeDialog({double? width, double? height, BoxConstraints? constraints}) {
    setState(() {
      if (constraints != null) {
        currentConstraints = constraints;
      } else {
        currentConstraints = BoxConstraints(
          minWidth: width ?? currentConstraints.minWidth,
          maxWidth: width ?? currentConstraints.maxWidth,
          minHeight: height ?? currentConstraints.minHeight,
          maxHeight: height ?? currentConstraints.maxHeight,
        );
      }
      currentConstraints = PaddedDialog._fixConstraints(currentConstraints);
    });
  }

  /// Positions the dialog on screen.
  void positionDialog(Position? alignment) => setState(() => this.alignment = alignment);

  Positioned _AlignmentWidget({required Widget child}) {
    return Positioned(
      top: alignment?.top,
      bottom: alignment?.bottom,
      left: alignment?.left,
      right: alignment?.right,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.barrierOptions.barrierPadding,
      child: Stack(
        children: [
          _AlignmentWidget(
            child: Padding(
              padding: widget.padding,
              child: Builder(builder: (context) {
                currentConstraints = PaddedDialog._fixConstraints(currentConstraints);
                return switch (widget._type) {
                  _PaddedDialogType.simple => ContentDialog(
                      constraints: currentConstraints,
                      style: widget.theme,
                      title: widget.title,
                      content: mat.Material(
                        color: Colors.transparent,
                        child: Container(
                          constraints: currentConstraints,
                          child: widget.contentBuilder(context, currentConstraints),
                        ),
                      ),
                      actions: widget.actions != null ? widget.actions!(null) : [],
                    ),
                  _PaddedDialogType.custom => mat.Material(
                      color: Colors.transparent,
                      child: Container(
                        constraints: currentConstraints,
                        child: widget.contentBuilder(context, currentConstraints),
                      ),
                    ),
                };
              }),
            ),
          ),
        ],
      ),
    );
  }
}
