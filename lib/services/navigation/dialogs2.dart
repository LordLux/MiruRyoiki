// ignore_for_file: use_build_context_synchronously

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:glossy/glossy.dart';
import 'dart:ui' show ImageFilter;
import 'package:miruryoiki/utils/screen.dart';
import 'dart:math' as math;
import '../../widgets/frosted_noise.dart';
import 'dialogs.dart';
import 'navigation.dart';

/// Interface for multi-state dialogs that need to intercept back/dismiss requests and handle them internally (e.g. "go up one step") before letting the navigation framework close the route
///
/// Mix this into a dialog's [State] with `with DialogController` and assign [DialogNavigationItem.controller] in [State.initState] to opt in
mixin DialogController {
  /// Whether the dialog can currently be closed by the user via barrier tap, ESC key, or the mouse-back button
  bool get canPop;

  /// Called when the user requests back/dismiss while [canPop] is false
  ///
  /// Return `true` if the dialog handled the request internally (e.g. returned to a previous inner step). Return `false` to let the navigation framework pop the route as usual
  bool onBackRequested();

  /// Called when the user presses ESC while this dialog is the top dialog, before the normal back/close flow runs
  ///
  /// Expected behavior for implementers:
  /// * Return `true` when the ESC key event should be consumed (preventing dialog closure)
  /// * Return `false` to allow normal handling (let the global handler proceed as usual)
  ///
  /// Unlike [canPop]/[onBackRequested], this hook fires regardless of [canPop] and does **not** contribute to [NavigationManager.isDialogLocked]
  /// 
  /// Use it for ESC-only local overrides that should not block other dismissal paths (barrier tap, mouse-back, programmatic close)
  bool onEscPressed() => false;
}

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

  /// Fallback pop-check for dialogs without a [controller]
  ///
  /// When a [controller] is attached, [effectiveCanPop] takes precedence.
  final bool Function() dialogDoPopCheck;

  /// Optional controller bound by a multi-state dialog's [State] in initState
  ///
  /// When non-null, [effectiveCanPop] delegates to [DialogController.canPop] instead of [dialogDoPopCheck]
  DialogController? controller;

  /// Whether this dialog can currently be popped
  ///
  /// Prefers [controller.canPop] when a controller is attached
  bool effectiveCanPop() => controller?.canPop ?? dialogDoPopCheck();
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

/// Configuration for how a dialog transitions in and out
abstract class DialogTransition {
  const DialogTransition();

  /// Applies the transition to the given [child]
  Widget build(BuildContext context, Animation<double> animation, Widget child);

  /// No transition, just fades (handled by the route)
  factory DialogTransition.none() = _DialogTransitionNone;

  /// Scales the dialog from the given [alignment]
  factory DialogTransition.scaleFromAlignment({required Alignment alignment}) = _DialogTransitionScaleFromAlignment;

  /// Scales the dialog from a point slightly above its top edge
  factory DialogTransition.scaleFromAbove({required Alignment alignment, required double offset}) = _DialogTransitionScaleFromAbove;

  /// A completely custom transition
  factory DialogTransition.custom(Widget Function(BuildContext, Animation<double>, Widget) builder) = _DialogTransitionCustom;
}

class _DialogTransitionNone extends DialogTransition {
  const _DialogTransitionNone();
  @override
  Widget build(BuildContext context, Animation<double> animation, Widget child) => child;
}

class _DialogTransitionScaleFromAlignment extends DialogTransition {
  final Alignment? alignment;
  const _DialogTransitionScaleFromAlignment({this.alignment});

  @override
  Widget build(BuildContext context, Animation<double> animation, Widget child) {
    return ScaleTransition(
      alignment: alignment ?? Alignment.center,
      scale: CurvedAnimation(
        parent: Tween<double>(begin: 0, end: 1.0).animate(animation),
        curve: Curves.easeOut,
      ),
      child: child,
    );
  }
}

class _DialogTransitionScaleFromAbove extends DialogTransition {
  final Alignment? alignment;
  final double offset;
  const _DialogTransitionScaleFromAbove({this.alignment, this.offset = 50.0});

  @override
  Widget build(BuildContext context, Animation<double> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double scale = CurvedAnimation(
          parent: Tween<double>(begin: 0, end: 1.0).animate(animation),
          curve: Curves.easeOut,
        ).value;

        return Transform(
          transform: Matrix4.identity()
            ..translate(20.0, -offset * (1 - scale)) // for some reason the dialog is slightly off-center when scaling from the top, adding a small horizontal translation seems to fix it
            ..scale(scale),
          alignment: alignment ?? Alignment.topCenter,
          child: child,
        );
      },
      child: child,
    );
  }
}

class _DialogTransitionCustom extends DialogTransition {
  final Widget Function(BuildContext, Animation<double>, Widget) builder;
  const _DialogTransitionCustom(this.builder);

  @override
  Widget build(BuildContext context, Animation<double> animation, Widget child) {
    return builder(context, animation, child);
  }
}

class _ClampedAlignmentLayoutDelegate extends SingleChildLayoutDelegate {
  final Alignment alignment;
  final EdgeInsets padding;

  _ClampedAlignmentLayoutDelegate({
    required this.alignment,
    required this.padding,
  });

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.deflate(padding).loosen();
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // Calculate the ideal position from the alignment.
    final double idealX = (size.width - childSize.width) / 2 + alignment.x * (size.width - childSize.width) / 2;
    final double idealY = (size.height - childSize.height) / 2 + alignment.y * (size.height - childSize.height) / 2;

    // Clamp the position to be within the allowed bounds (size minus padding).
    final double minX = padding.left;
    final double minY = padding.top;
    final double maxX = size.width - padding.right - childSize.width;
    final double maxY = size.height - padding.bottom - childSize.height;

    return Offset(
      idealX.clamp(minX, math.max(minX, maxX)),
      idealY.clamp(minY, math.max(minY, maxY)),
    );
  }

  @override
  bool shouldRelayout(_ClampedAlignmentLayoutDelegate oldDelegate) {
    return alignment != oldDelegate.alignment || padding != oldDelegate.padding;
  }
}

/// Represents the position of a dialog on the screen
class Position {
  /// Distance from the top edge
  final double? top;

  /// Distance from the bottom edge
  final double? bottom;

  /// Distance from the left edge
  final double? left;

  /// Distance from the right edge
  final double? right;

  /// Creates a [Position] with optional offsets
  Position({this.top, this.bottom, this.left, this.right});

  /// Creates a [Position] from a standard [Alignment]
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

/// A dialog widget that supports custom padding, positioning, and barrier options
///
/// This widget can be created using one of the factory constructors:
/// * [PaddedDialog.simple] for a standard dialog with title, content, and actions
/// * [PaddedDialog.custom] for a fully custom dialog content
/// * [PaddedDialog.frosted] for a dialog with a frosted glass effect
class PaddedDialog extends StatefulWidget {
  /// Title of the dialog
  final Widget? title;

  /// Content builder for the dialog
  final Widget Function(BuildContext, BoxConstraints) contentBuilder;

  /// Actions builder for the dialog
  final List<Widget> Function(Object?)? actions;

  /// Constraints for the dialog
  final BoxConstraints constraints;

  /// Alignment for the dialog
  final Alignment? alignment;

  /// Theme for the dialog
  final ContentDialogThemeData? theme;

  /// Padding around the dialog content
  final EdgeInsets padding;

  /// Callback when the dialog is dismissed
  final VoidCallback? onDismiss;

  /// Navigation item associated with this dialog
  final DialogNavigationItem? navigationItem;

  /// Barrier options for this dialog
  final PaddedBarrierOptions barrierOptions;

  /// Transition for this dialog
  final DialogTransition transition;

  final _PaddedDialogType _type;

  /// Creates a [PaddedDialog]
  const PaddedDialog({
    super.key,
    required this.title,
    required this.contentBuilder,
    EdgeInsets? padding,
    this.actions,
    BoxConstraints? constraints,
    ContentDialogThemeData? theme,
    this.alignment,
    this.onDismiss,
    this.navigationItem,
    PaddedBarrierOptions? barrierOptions,
    DialogTransition? transition,
    _PaddedDialogType type = _PaddedDialogType.custom,
  })  : _type = type,
        padding = padding ?? const EdgeInsets.all(16.0),
        constraints = constraints ?? const BoxConstraints(maxWidth: 500, maxHeight: 300, minWidth: 300),
        // ignore: prefer_initializing_formals
        theme = theme,
        transition = transition ?? const _DialogTransitionNone(),

        // [navigationItem] can't be defaulted here
        barrierOptions = barrierOptions ?? const PaddedBarrierOptions();

  /// Creates a simple dialog with title, content and actions
  ///
  /// * [title]: Title of the dialog
  /// * [content]: Content of the dialog
  /// * [padding]: Padding around the dialog
  /// * [actions]: Actions for the dialog
  /// * [constraints]: Constraints for the dialog size
  /// * [alignment]: Alignment of the dialog on screen. Use [Position.fromAlignment] for common alignments
  /// * [theme]: Theme for the dialog
  /// * [onDismiss]: Callback when the dialog is dismissed
  /// * [navigationItem]: Navigation item for the dialog
  /// * [barrierOptions]: Barrier options for the dialog
  factory PaddedDialog.simple({
    required Widget? title,
    required Widget content,
    EdgeInsets? padding,
    List<Widget>? actions,
    required BoxConstraints? constraints,
    Alignment? alignment,
    ContentDialogThemeData? theme,
    VoidCallback? onDismiss,
    required DialogNavigationItem? navigationItem,
    required PaddedBarrierOptions? barrierOptions,
    DialogTransition? transition,
  }) {
    alignment ??= Alignment.center;
    constraints ??= BoxConstraints(maxWidth: 500, maxHeight: 300, minWidth: 300);
    return PaddedDialog(
      title: title,
      contentBuilder: (_, constraints) => ConstrainedBox(constraints: constraints, child: content),
      padding: padding,
      actions: (data) => actions ?? [],
      constraints: constraints,
      alignment: alignment,
      theme: theme,
      onDismiss: onDismiss,
      navigationItem: navigationItem,
      barrierOptions: barrierOptions,
      transition: transition,
      type: _PaddedDialogType.simple,
    );
  }

  /// Creates a custom dialog with full control over content
  ///
  /// * [content]: The content of the dialog
  /// * [padding]: Padding around the dialog
  /// * [constraints]: Constraints for the dialog size
  /// * [alignment]: Alignment of the dialog on screen. Use [Position.fromAlignment] for common alignments
  /// * [onDismiss]: Callback when the dialog is dismissed
  /// * [navigationItem]: Navigation item for the dialog
  /// * [barrierOptions]: Barrier options for the dialog
  factory PaddedDialog.custom({
    required Widget Function(BuildContext, BoxConstraints) contentBuilder,
    EdgeInsets? padding,
    required BoxConstraints? constraints,
    Alignment? alignment,
    VoidCallback? onDismiss,
    required DialogNavigationItem? navigationItem,
    required PaddedBarrierOptions? barrierOptions,
    DialogTransition? transition,
  }) {
    alignment ??= Alignment.center;
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
      transition: transition,
      type: _PaddedDialogType.custom,
    );
  }

  /// Creates a frosted glass style dialog
  ///
  /// * [content]: The content of the dialog
  /// * [padding]: Padding around the dialog
  /// * [constraints]: Constraints for the dialog size
  /// * [alignment]: Alignment of the dialog on screen. Use [Position.fromAlignment] for common alignments
  /// * [onDismiss]: Callback when the dialog is dismissed
  /// * [navigationItem]: Navigation item for the dialog
  /// * [barrierOptions]: Barrier options for the dialog
  factory PaddedDialog.frosted({
    required Widget content,
    required BoxConstraints? constraints,
    EdgeInsets? padding,
    Alignment? alignment,
    VoidCallback? onDismiss,
    required DialogNavigationItem? navigationItem,
    required PaddedBarrierOptions? barrierOptions,
    DialogTransition? transition,
  }) {
    alignment ??= Alignment.center;
    constraints ??= BoxConstraints(maxWidth: 250, minWidth: 250);
    return PaddedDialog(
      title: null,
      contentBuilder: (context, constraints) {
        constraints = _fixConstraints(constraints);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  blendMode: BlendMode.src,
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(color: Colors.transparent),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),
              GlossyContainer(
                height: constraints.maxHeight != double.infinity ? constraints.maxHeight : 250,
                width: constraints.maxWidth != double.infinity ? constraints.maxWidth : 250,
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                opacity: 0.05,
                child: FrostedNoise(
                  intensity: 0.7,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: content,
                  ),
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
      transition: transition ?? _DialogTransitionScaleFromAbove(alignment: alignment),
      type: _PaddedDialogType.custom,
    );
  }

  static BoxConstraints _fixConstraints(BoxConstraints constraints) {
    return constraints.copyWith(
      maxWidth: constraints.maxWidth.clamp(0.0, ScreenUtils.width),
      maxHeight: constraints.maxHeight.clamp(0.0, ScreenUtils.height),
    );
  }

  @override
  State<PaddedDialog> createState() => PaddedDialogState();
}

/// State for [PaddedDialog]
class PaddedDialogState extends State<PaddedDialog> {
  late BoxConstraints currentConstraints;
  late Alignment alignment;

  @override
  void initState() {
    super.initState();
    currentConstraints = widget.constraints;
    alignment = widget.alignment ?? Alignment.center;
  }

  /// Resizes the dialog to the given dimensions or constraints
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

  /// Positions the dialog on screen
  void positionDialog(Alignment alignment) => setState(() => this.alignment = alignment);

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    final Animation<double> animation = route?.animation ?? const AlwaysStoppedAnimation(1.0);

    return CustomSingleChildLayout(
      delegate: _ClampedAlignmentLayoutDelegate(
        alignment: alignment,
        padding: widget.barrierOptions.barrierPadding,
      ),
      child: widget.transition.build(
        context,
        animation,
        Padding(
          padding: widget.padding,
          child: Builder(builder: (context) {
            currentConstraints = PaddedDialog._fixConstraints(currentConstraints);
            switch (widget._type) {
              case _PaddedDialogType.simple:
                if (widget.actions == null || widget.actions!(null).isEmpty) {
                  return ContentActionlessDialog(
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
                  );
                }
                return ContentDialog(
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
                  actions: [
                    ...?widget.actions?.call(widget.navigationItem?.data),
                  ],
                );
              case _PaddedDialogType.custom:
                return mat.Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: currentConstraints,
                    child: widget.contentBuilder(context, currentConstraints),
                  ),
                );
            }
          }),
        ),
      ),
    );
  }
}

class ContentActionlessDialog extends StatelessWidget {
  /// Creates a content dialog without actions
  const ContentActionlessDialog({
    super.key,
    this.title,
    this.content,
    this.style,
    this.constraints = kDefaultContentDialogConstraints,
  });

  /// The title of the dialog
  final Widget? title;

  /// The content of the dialog
  final Widget? content;

  /// The style used by this dialog. If non-null, it's merged with [FluentThemeData.dialogTheme]
  final ContentDialogThemeData? style;

  /// The constraints of the dialog. Defaults to `BoxConstraints(maxWidth: 368, maxHeight: 756)`
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style = ContentDialogThemeData.standard(FluentTheme.of(context)) //
        .merge(FluentTheme.of(context).dialogTheme.merge(this.style));

    return Align(
      alignment: AlignmentDirectional.center,
      child: Container(
        constraints: constraints,
        decoration: style.decoration,
        child: Padding(
          padding: style.padding ?? EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Padding(
                  padding: style.titlePadding ?? EdgeInsets.zero,
                  child: DefaultTextStyle.merge(
                    style: style.titleStyle,
                    child: title!,
                  ),
                ),
              if (content != null)
                Flexible(
                  child: Padding(
                    padding: style.bodyPadding ?? EdgeInsets.zero,
                    child: DefaultTextStyle.merge(
                      style: style.bodyStyle,
                      child: content!,
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
