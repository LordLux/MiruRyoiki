import 'package:fluent_ui2/fluent_ui.dart';

import '../utils/logging.dart';

// Later in your widget build method:
Widget buildHamburgerButton(BuildContext context) {
  return IconButton(
    icon: const Icon(FluentIcons.test_add),
    onPressed: () {
      // Your custom action when the button is pressed
      log('Menu button pressed');
    },
  );
}
