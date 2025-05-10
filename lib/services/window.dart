import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../main.dart';
import '../models/library.dart';

class MyWindowListener extends WindowListener {
  @override
  void onWindowClose() async {
    try {
      debugPrint('Window close requested - saving data...');
      // Get the library provider
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        final library = Provider.of<Library>(context, listen: false);
        // Force immediate save with await to ensure it completes
        await library.forceImmediateSave(); // TODO fix causes crash
        debugPrint('Library data saved successfully');
      }
    } catch (e) {
      debugPrint('Error during shutdown: $e');
    } finally {
      await windowManager.destroy();
    }
  }
}