import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../main.dart';
import '../manager.dart';
import '../models/library.dart';
import '../utils/logging.dart';
import '../utils/time_utils.dart';

class MyWindowListener extends WindowListener {
  @override
  void onWindowResize() {
    nextFrame(() => Manager.setState()); // Update the state when the window is resized
    super.onWindowResize();
  }

  @override
  void onWindowMaximize() {
    nextFrame(() => Manager.setState()); // Update the state when the window is maximized
    super.onWindowMaximize();
  }

  @override
  void onWindowUnmaximize() {
    nextFrame(() => Manager.setState()); // Update the state when the window is unmaximized
    super.onWindowUnmaximize();
  }

  @override
  void onWindowClose() async {
    try {
      logDebug('Window close requested - saving data...');
      // Get the library provider
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        final library = Provider.of<Library>(context, listen: false);
        // Force immediate save with await to ensure it completes
        await library.forceImmediateSave(); // TODO fix causes crash
        logDebug('Library data saved successfully');
      }
    } catch (e) {
      logDebug('Error during shutdown: $e');
    } finally {
      await windowManager.destroy();
    }
  }
}
