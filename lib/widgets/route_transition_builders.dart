import 'package:fluent_ui/fluent_ui.dart';

Widget noneTransitionsBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return child;
}

Widget fadeTransitionsBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    ),
    child: FadeTransition(
      opacity: CurvedAnimation(
        parent: ReverseAnimation(secondaryAnimation),
        curve: Curves.easeInOut,
      ),
      child: child,
    ),
  );
}

Widget slideTransitionsBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
  int direction,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: Offset(0, direction >= 0 ? 0.15 : -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    )),
    child: FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: ReverseAnimation(secondaryAnimation),
          curve: Curves.easeInOut,
        ),
        child: child,
      ),
    ),
  );
}

Widget scaleTransitionsBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return ScaleTransition(
    scale: CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    ),
    child: FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: ReverseAnimation(secondaryAnimation),
          curve: Curves.easeInOut,
        ),
        child: child,
      ),
    ),
  );
}