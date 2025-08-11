import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import '../../library/library_provider.dart';
import 'statusbar.dart';

class LibraryScanStatusBar extends StatefulWidget {
  const LibraryScanStatusBar({super.key});

  @override
  State<LibraryScanStatusBar> createState() => _LibraryScanStatusBarState();
}

class _LibraryScanStatusBarState extends State<LibraryScanStatusBar> {
  final StatusBarManager _statusBarManager = StatusBarManager();

  @override
  Widget build(BuildContext context) {
    // This widget's only job is to listen and react. It builds nothing itself.
    // return Consumer<Library>(
    //   builder: (context, library, child) {
    //     final progress = library.scanProgress.value;

    //     // Use a post-frame callback to avoid calling manager during build.
    //     // WidgetsBinding.instance.addPostFrameCallback((_) {
    //     //   if (progress != null) {
    //     //     final percentage = progress.$2 > 0 ? (progress.$1 / progress.$2 * 100).toInt() : 0;
    //     //     _statusBarManager.show(
    //     //       'Scanning Library... $percentage% (${progress.$1}/${progress.$2})',
    //     //       autoHideDuration: Duration.zero, // Keep it visible
    //     //     );
    //     //   } else {
    //     //     // If the last known state was "scanning", show a completion message.
    //     //     if (_statusBarManager.message.startsWith('Scanning')) {
    //     //        _statusBarManager.show(
    //     //         'Scan Complete!',
    //     //         autoHideDuration: const Duration(seconds: 4), // Hide after 4s
    //     //       );
    //     //     }
    //     //   }
    //     // });

    //     return const SizedBox(); // Render nothing.
    //   },
    // );
    return Container();
  }
}
