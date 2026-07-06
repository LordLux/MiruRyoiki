import 'package:fluent_ui/fluent_ui.dart';

/// Route transitions builder that mirrors [EntrancePageTransition].
Widget entranceRouteTransitionsBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return EntrancePageTransition(
    animation: animation,
    child: child,
  );
}

/// Route transitions builder that mirrors [DrillInPageTransition].
Widget drillInRouteTransitionsBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return DrillInPageTransition(
    animation: animation,
    child: child,
  );
}

/// Route transitions builder that mirrors [HorizontalSlidePageTransition].
///
/// Set [fromLeft] to control where the incoming route starts.
RouteTransitionsBuilder horizontalSlideRouteTransitionsBuilder({bool fromLeft = true}) {
  return (
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return HorizontalSlidePageTransition(
      animation: animation,
      fromLeft: fromLeft,
      child: child,
    );
  };
}

/// Base helper that mirrors the default resolve strategy and allows subclasses
/// to decide whether the entering and exiting routes should animate.
abstract class _MiruRyoikiBaseTransitionDelegate<T> extends TransitionDelegate<T> {
  const _MiruRyoikiBaseTransitionDelegate();

  bool shouldAnimateEntering({
    required bool isLastIteration,
    required bool hasExitingRouteAtLocation,
  });

  bool shouldAnimateExiting({
    required bool isLastExitingPageRoute,
    required bool hasPagelessRoute,
  });

  @override
  Iterable<RouteTransitionRecord> resolve({
    required List<RouteTransitionRecord> newPageRouteHistory,
    required Map<RouteTransitionRecord?, RouteTransitionRecord> locationToExitingPageRoute,
    required Map<RouteTransitionRecord?, List<RouteTransitionRecord>> pageRouteToPagelessRoutes,
  }) {
    final List<RouteTransitionRecord> results = <RouteTransitionRecord>[];

    void handleExitingRoute(RouteTransitionRecord? location, bool isLast) {
      final RouteTransitionRecord? exitingPageRoute = locationToExitingPageRoute[location];
      if (exitingPageRoute == null) {
        return;
      }

      if (exitingPageRoute.isWaitingForExitingDecision) {
        final bool hasPagelessRoute = pageRouteToPagelessRoutes.containsKey(exitingPageRoute);
        final bool isLastExitingPageRoute =
            isLast && !locationToExitingPageRoute.containsKey(exitingPageRoute);

        if (shouldAnimateExiting(
          isLastExitingPageRoute: isLastExitingPageRoute,
          hasPagelessRoute: hasPagelessRoute,
        )) {
          exitingPageRoute.markForPop(exitingPageRoute.route.currentResult);
        } else {
          exitingPageRoute.markForComplete(exitingPageRoute.route.currentResult);
        }

        if (hasPagelessRoute) {
          final List<RouteTransitionRecord> pagelessRoutes =
              pageRouteToPagelessRoutes[exitingPageRoute]!;

          for (final RouteTransitionRecord pagelessRoute in pagelessRoutes) {
            if (!pagelessRoute.isWaitingForExitingDecision) {
              continue;
            }

            final bool shouldAnimatePageless = shouldAnimateExiting(
              isLastExitingPageRoute:
                  isLastExitingPageRoute && identical(pagelessRoute, pagelessRoutes.last),
              hasPagelessRoute: false,
            );

            if (shouldAnimatePageless) {
              pagelessRoute.markForPop(pagelessRoute.route.currentResult);
            } else {
              pagelessRoute.markForComplete(pagelessRoute.route.currentResult);
            }
          }
        }
      }

      results.add(exitingPageRoute);
      handleExitingRoute(exitingPageRoute, isLast);
    }

    handleExitingRoute(null, newPageRouteHistory.isEmpty);

    for (final RouteTransitionRecord pageRoute in newPageRouteHistory) {
      final bool isLastIteration = identical(newPageRouteHistory.last, pageRoute);

      if (pageRoute.isWaitingForEnteringDecision) {
        final bool hasExitingRouteAtLocation =
            locationToExitingPageRoute.containsKey(pageRoute);

        if (shouldAnimateEntering(
          isLastIteration: isLastIteration,
          hasExitingRouteAtLocation: hasExitingRouteAtLocation,
        )) {
          pageRoute.markForPush();
        } else {
          pageRoute.markForAdd();
        }
      }

      results.add(pageRoute);
      handleExitingRoute(pageRoute, isLastIteration);
    }

    return results;
  }
}

/// Transition delegate for an Entrance-like navigation feel.
///
/// Incoming top routes animate in. Exiting routes complete without an exit
/// animation, matching the original widget behavior where the focus is on the
/// incoming route.
class EntranceTransitionDelegate<T> extends _MiruRyoikiBaseTransitionDelegate<T> {
  const EntranceTransitionDelegate();

  @override
  bool shouldAnimateEntering({
    required bool isLastIteration,
    required bool hasExitingRouteAtLocation,
  }) {
    return isLastIteration && !hasExitingRouteAtLocation;
  }

  @override
  bool shouldAnimateExiting({
    required bool isLastExitingPageRoute,
    required bool hasPagelessRoute,
  }) {
    return false;
  }
}

/// Transition delegate for a DrillIn-like navigation feel.
///
/// This keeps the same route decision strategy as [EntranceTransitionDelegate],
/// and is intended to be paired with [drillInRouteTransitionsBuilder].
class DrillInTransitionDelegate<T> extends _MiruRyoikiBaseTransitionDelegate<T> {
  const DrillInTransitionDelegate();

  @override
  bool shouldAnimateEntering({
    required bool isLastIteration,
    required bool hasExitingRouteAtLocation,
  }) {
    return isLastIteration && !hasExitingRouteAtLocation;
  }

  @override
  bool shouldAnimateExiting({
    required bool isLastExitingPageRoute,
    required bool hasPagelessRoute,
  }) {
    return false;
  }
}

/// Transition delegate for a HorizontalSlide-like navigation feel.
///
/// Incoming top routes animate in and the top-most exiting route is popped with
/// animation, preserving sibling-page movement in both directions.
class HorizontalSlideTransitionDelegate<T> extends _MiruRyoikiBaseTransitionDelegate<T> {
  const HorizontalSlideTransitionDelegate();

  @override
  bool shouldAnimateEntering({
    required bool isLastIteration,
    required bool hasExitingRouteAtLocation,
  }) {
    return isLastIteration && !hasExitingRouteAtLocation;
  }

  @override
  bool shouldAnimateExiting({
    required bool isLastExitingPageRoute,
    required bool hasPagelessRoute,
  }) {
    return isLastExitingPageRoute && !hasPagelessRoute;
  }
}
