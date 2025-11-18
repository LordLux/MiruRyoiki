import 'package:fluent_ui/fluent_ui.dart';

import '../manager.dart';
import '../utils/screen.dart';
import '../utils/time.dart';

/// Create a styled scrollbar with consistent theming and right padding
Widget buildStyledScrollbar(Widget child, ScrollController controller) {
  return Scrollbar(
    controller: controller,
    thumbVisibility: true,
    style: ScrollbarThemeData(
      thickness: 3,
      hoveringThickness: 4.5,
      radius: const Radius.circular(4),
      backgroundColor: Colors.transparent,
      scrollbarPressingColor: Manager.accentColor.lightest.withOpacity(.7),
      contractDelay: dimDuration,
      scrollbarColor: Manager.accentColor.lightest.withOpacity(.4),
      trackBorderColor: Colors.transparent,
    ),
    child: Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: ScrollConfiguration(
        behavior: ScrollBehavior().copyWith(overscroll: false, scrollbars: false, physics: const ClampingScrollPhysics()),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(ScreenUtils.kStatCardBorderRadius)),
          child: child,
        ),
      ),
    ),
  );
}
