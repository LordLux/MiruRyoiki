import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../../utils/screen.dart';
import 'navigation.dart';

class NavigationHistoryDebug extends StatelessWidget {
  const NavigationHistoryDebug({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationManager>(
      builder: (context, navManager, _) {
        return Container(
          color: Colors.black.withOpacity(0.8),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Navigation Stack:', style: TextStyle(color: Colors.white)),
              VDiv(8),
              ...navManager.stack.reversed.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          item.level.toString().split('.').last,
                          style: TextStyle(color: _getLevelColor(item.level)),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${item.title} (${item.id})',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Color _getLevelColor(NavigationLevel level) {
    switch (level) {
      case NavigationLevel.pane:
        return Colors.blue;
      case NavigationLevel.page:
        return Colors.green;
      case NavigationLevel.dialog:
        return Colors.orange;
    }
  }
}