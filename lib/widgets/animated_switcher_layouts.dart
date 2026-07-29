import 'package:fluent_ui/fluent_ui.dart';

/// Builds an [AnimatedSwitcher.layoutBuilder] that stacks [previousChildren] under the current child at [alignment],
/// optionally de-duplicating previous children that share a key with the current child
Widget Function(Widget?, List<Widget>) stackLayoutBuilder({
  Alignment alignment = Alignment.center,
  bool dedupeByKey = false,
}) {
  return (currentChild, previousChildren) {
    return Stack(
      alignment: alignment,
      children: <Widget>[
        if (dedupeByKey) //
          ...previousChildren.where((w) => w.key != currentChild?.key)
        else
          ...previousChildren,
        if (currentChild != null) currentChild,
      ],
    );
  };
}
