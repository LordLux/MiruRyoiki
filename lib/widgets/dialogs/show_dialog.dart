// ignore: file_names
// ignore_for_file: use_build_context_synchronously

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../../manager.dart';
import '../../services/navigation/dialogs2.dart';
import '../../services/navigation/navigation.dart';
import 'padded_dialog_route.dart';

Widget _defaultTransitionBuilder(
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
    child: child,
  );
}

/// Shows a dialog with a customizable barrier that can have padding.
///
/// The [barrierOptions] allows you to specify areas where the barrier
/// will not block interaction with underlying widgets.
///
/// * [context]: The build context.
/// * [navigationItem]: The navigation item for the dialog.
/// * [builder]: The content builder for the dialog.
/// * [barrierOptions]: Options for the dialog barrier.
/// * [closeExistingDialogs]: Whether to close existing dialogs before showing this one.
/// * [transitionDuration]: The duration of the transition.
/// * [transitionBuilder]: A custom transition builder.
/// * [routeSettings]: Settings for the route.
///
/// Returns a [Future] that resolves to `true` if the dialog was shown,
/// or `false` if it couldn't be shown.
Future<bool> showPaddedDialog(
  BuildContext context, {
  required DialogNavigationItem navigationItem,
  required PaddedDialog Function(BuildContext, DialogNavigationItem, PaddedBarrierOptions) builder,
  PaddedBarrierOptions barrierOptions = const PaddedBarrierOptions(),
  bool closeExistingDialogs = false,
  Duration? transitionDuration,
  RouteTransitionsBuilder transitionBuilder = _defaultTransitionBuilder,
  RouteSettings? routeSettings,
}) async {
  assert(debugCheckHasFluentLocalizations(Manager.context));

  final navigator = context.read<NavigationManager>();

  if (closeExistingDialogs) {
    if (navigator.hasDialog) {
      if (navigator.isDialogLocked) return false;
      // Close the top dialog programmatically
      navigator.popDialog();
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  if (!context.mounted) return false;

  final themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(
      context,
      rootNavigator: true,
    ).context,
  );

  final route = PaddedDialogRoute(
    context: Manager.context,
    item: navigationItem,
    options: barrierOptions,
    themes: themes,
    transitionDuration: transitionDuration ?? FluentTheme.maybeOf(context)?.fastAnimationDuration ?? const Duration(milliseconds: 300),
    contentBuilder: (ctx, item, opt) => builder(ctx, item, opt),
    barrierLabel: FluentLocalizations.of(context).modalBarrierDismissLabel,
    settings: routeSettings,
    transitionBuilder: transitionBuilder,
  );

  // Bind the active route to the navigation item
  navigationItem.activeRoute = route;

  // Update NavigationManager Stack
  navigator.pushDialog(navigationItem);

  // Push the route
  Navigator.of(Manager.context).push(route).then((_) {
    // Cleanup when the dialog is closed
    navigator.handleDialogPopped(navigationItem);
  });

  return true;
}
