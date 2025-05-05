import 'package:fluent_ui2/fluent_ui.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;

class DismissOnEsc extends StatelessWidget {
  final VoidCallback onDismiss;
  final Widget child;

  const DismissOnEsc({
    super.key,
    required this.onDismiss,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (DismissIntent intent) {
              onDismiss();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}
