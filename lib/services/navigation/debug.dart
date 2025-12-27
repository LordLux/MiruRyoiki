import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../../utils/screen.dart';
import '../../widgets/buttons/button.dart';
import 'navigation.dart';

class NavigationHistoryDebug extends StatefulWidget {
  const NavigationHistoryDebug({super.key});

  @override
  State<NavigationHistoryDebug> createState() => _NavigationHistoryDebugState();
}

class _NavigationHistoryDebugState extends State<NavigationHistoryDebug> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationManager>(
      builder: (context, navManager, _) {
        final lines = navManager.currentStackString
            .split('\n')
            .where((l) => l.trim().isNotEmpty)
            .toList();

        const int cap = 20;
        final bool hasMore = lines.length > cap;
        final List<String> visibleLines = _showAll ? lines : lines.take(cap).toList();

        final double maxHeight = MediaQuery.of(context).size.height * 0.5;

        return Container(
          color: Colors.black.withOpacity(0.8),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Navigation Stack:', style: TextStyle(color: Colors.white)),
              VDiv(8),

              // Constrain vertically to avoid overflow
              SizedBox(
                height: maxHeight,
                child: ListView(
                  physics: _showAll
                      ? const BouncingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: visibleLines.map(_buildLineRow).toList(),
                ),
              ),

              if (hasMore && !_showAll) ...[
                VDiv(8),
                StandardButton.iconLabel(
                  icon: Icon(FluentIcons.chevron_down),
                  label: Text('Show all'),
                  onPressed: () => setState(() => _showAll = true),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLineRow(String line) {
    final isCurrent = line.contains('→');
    final cleanLine = line.replaceAll('→', '').trim();
    final parts = cleanLine.split(': ');
    final levelName = parts[0];
    final content = parts.length > 1 ? parts.sublist(1).join(': ') : '';

    final lastParen = content.lastIndexOf('(');
    final title = (lastParen != -1) ? content.substring(0, lastParen).trim() : content;
    final id = (lastParen != -1 && content.endsWith(')'))
        ? content.substring(lastParen + 1, content.length - 1)
        : '';

    NavigationLevel level;
    switch (levelName) {
      case 'Pane':
        level = NavigationLevel.pane;
        break;
      case 'Dialog':
        level = NavigationLevel.dialog;
        break;
      default:
        level = NavigationLevel.page;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '${isCurrent ? '→ ' : ''}$levelName',
              style: TextStyle(color: _getLevelColor(level)),
            ),
          ),
          Expanded(
            child: Text(
              '$title ($id)',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
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