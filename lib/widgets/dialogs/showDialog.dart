// ignore: file_names
import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/main.dart';

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
  EdgeInsetsGeometry barrierPadding = EdgeInsets.zero,
  RouteTransitionsBuilder transitionBuilder = PaddedDialogRoute._defaultTransitionBuilder,
  Duration? transitionDuration,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  String? barrierLabel,
  Color? barrierColor = const Color(0x8A000000),
  bool barrierDismissible = false,
  bool dismissWithEsc = true,
}) {
  assert(debugCheckHasFluentLocalizations(context));

  final themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    ).context,
  );

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
    barrierPadding: barrierPadding,
    transitionDuration: transitionDuration ?? FluentTheme.maybeOf(context)?.fastAnimationDuration ?? const Duration(milliseconds: 300),
    themes: themes,
  ));
}

/// A dialog route with a barrier that supports padding
class PaddedDialogRoute<T> extends FluentDialogRoute<T> {
  final EdgeInsetsGeometry barrierPadding;

  PaddedDialogRoute({
    required super.builder,
    required super.context,
    required this.barrierPadding, // Padding for the barrier
    super.themes,
    super.barrierDismissible = true, // default to true
    super.barrierColor,
    super.barrierLabel,
    super.transitionDuration,
    super.transitionBuilder,
    super.settings,
    super.dismissWithEsc = false, // override default behavior
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
    );

    if (barrierPadding != EdgeInsets.zero) {
      return Stack(
        children: [
          AnimatedBuilder(
            animation: animation!,
            builder: (context, child) {
              final animValue = animation!.value;
              return Padding(
                padding: barrierPadding,
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
                    color: Colors.black,
                    child: child,
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: barrierPadding,
            child: barrier,
          ),
        ],
      );
    }

    return barrier;
  }
}
