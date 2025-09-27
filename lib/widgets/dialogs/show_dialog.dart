// ignore: file_names
// ignore_for_file: use_build_context_synchronously

import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/services/navigation/dialogs.dart';

import '../../manager.dart';

/// The default constraints for [ContentDialog]
const kDefaultContentDialogConstraints = BoxConstraints(
  maxWidth: 368.0,
  maxHeight: 756.0,
);

/// Shows a dialog with a customizable barrier that can have padding
///
/// The [barrierPadding] allows you to specify areas where the barrier
/// will not block interaction with underlying widgets.
Future<T?> showPaddedDialog<T extends Object?>({
  required BuildContext context,
  required WidgetBuilder builder,

  /// Padding for the barrier, for example to allow interactions on custom titlebar
  EdgeInsetsGeometry barrierPadding = EdgeInsets.zero,
  RouteTransitionsBuilder? transitionBuilder = PaddedDialogRoute._defaultTransitionBuilder,
  Duration? transitionDuration,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  String? barrierLabel,
  Color? barrierColor = const Color(0x8A000000),

  /// Whether to dismiss the dialog when tapping outside of it
  bool barrierDismissible = false,

  /// Whether to allow dialog to be dismissed with Escape key
  bool dismissWithEsc = true,

  /// Whether to close existing dialogs before showing this one
  bool closeExistingDialogs = false,

  /// Whether the barrier should let interactions through or not
  bool transparentBarrier = false,

  /// Callback to be called when the dialog is dismissed
  VoidCallback? onDismiss,
}) async {
  assert(debugCheckHasFluentLocalizations(context));

  final themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    ).context,
  );

  if (closeExistingDialogs) {
    if (Navigator.of(context, rootNavigator: useRootNavigator).canPop()) {
      Navigator.of(context, rootNavigator: useRootNavigator).pop();
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  if (!context.mounted) return null;

  return Navigator.of(
    context,
    rootNavigator: useRootNavigator,
  ).push<T>(PaddedDialogRoute<T>(
    context: context,
    builder: builder,
    barrierColor: barrierColor,
    barrierDismissible: barrierDismissible,
    barrierLabel: FluentLocalizations.of(context).modalBarrierDismissLabel,
    dismissWithEsc: dismissWithEsc,
    settings: routeSettings,
    transitionBuilder: transitionBuilder,
    onDismiss: onDismiss,
    barrierPadding: transparentBarrier ? null : barrierPadding,
    transitionDuration: transitionDuration ?? FluentTheme.maybeOf(context)?.fastAnimationDuration ?? const Duration(milliseconds: 300),
    themes: themes,
  ));
}

/// A dialog route with a barrier that supports padding
class PaddedDialogRoute<T> extends FluentDialogRoute<T> {
  final EdgeInsetsGeometry? barrierPadding;
  final VoidCallback? onDismiss;

  PaddedDialogRoute({
    required super.builder,
    required super.context,

    /// Padding for the barrier
    required this.barrierPadding,
    this.onDismiss,
    super.themes,
    super.barrierDismissible = true, // default to true
    super.barrierColor,
    super.barrierLabel,
    super.transitionDuration,
    super.transitionBuilder,
    super.settings,
    super.dismissWithEsc = false, /// Recommended false, to override default flutter behavior
  });

  static Widget _defaultTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: Tween<double>(
            begin: 1,
            end: 0.85,
          ).animate(animation),
          curve: Curves.easeOut,
        ),
        child: child,
      ),
    );
  }

  @override
  Widget buildModalBarrier() {
    // Create a barrier widget with padding
    Widget barrier = ModalBarrier(
      color: Colors.transparent,
      dismissible: barrierDismissible,
      semanticsLabel: barrierLabel,
      onDismiss: onDismiss,
    );

    if (barrierPadding != null && barrierPadding != EdgeInsets.zero) {
      return Stack(
        children: [
          AnimatedBuilder(
            animation: animation!,
            builder: (context, child) {
              final animValue = animation!.value;
              return Padding(
                padding: barrierPadding!,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [barrierColor!.withOpacity(.8), barrierColor!, barrierColor!.withOpacity(.0)],
                      stops: [0.0, animValue, animValue + 0.3],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcIn,
                  child: Container(
                    color: Colors.black.withOpacity(barrierColor?.opacity ?? 1),
                    child: child,
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: barrierPadding!,
            child: barrier,
          ),
        ],
      );
    }

    return barrierPadding != null
        ? barrier
        : Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) {
              onDismiss?.call();
              closeDialog(Manager.context);
              Navigator.of(Manager.context).maybePop();
            },
            child: IgnorePointer(
              child: Container(),
            ),
          );
  }
}
