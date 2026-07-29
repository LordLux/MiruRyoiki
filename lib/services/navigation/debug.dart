import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../../utils/path.dart';
import '../../utils/screen.dart';
import '../../widgets/buttons/button.dart';
import '../library/library_provider.dart';
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
        final libraryRoot = context.read<Library>().libraryPath;

        final entries = <_HistoryEntry>[
          for (final item in navManager.forwardStack) (item: item, isCurrent: false),
        ];
        final stackRev = navManager.stack.reversed.toList();
        for (var i = 0; i < stackRev.length; i++) //
          entries.add((item: stackRev[i], isCurrent: i == 0));

        const int cap = 20;
        final bool hasMore = entries.length > cap;
        final visibleEntries = _showAll ? entries : entries.take(cap).toList();

        final double maxHeight = MediaQuery.of(context).size.height * 0.5;

        return Container(
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
                  physics: _showAll ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: visibleEntries.map((e) => _buildEntryRow(e, libraryRoot)).toList(),
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

  Widget _buildEntryRow(_HistoryEntry entry, String? libraryRoot) {
    final item = entry.item;
    final levelName = item.level.name;
    final displayId = _displayId(item, libraryRoot);
    final isCurrent = entry.isCurrent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '${isCurrent ? '→ ' : '    '}$levelName',
              style: TextStyle(color: _getLevelColor(item.level), fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal),
            ),
          ),
          Expanded(
            child: Text(
              '${item.title} ',
              style: TextStyle(color: Colors.white, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '($displayId)',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  /// For a series page, show the *current node's* path relative to the library by reading
  /// the deepest entry in its drill-down stack. Other routes keep their raw id
  String _displayId(NavigationItem item, String? libraryRoot) {
    const prefix = '/series:';
    if (!item.id.startsWith(prefix)) return item.id; // not a series page, just show the raw id

    final nodeStack = (item.viewStateSection(seriesNodeStackNamespace)?['nodeStack'] as List?)?.whereType<String>().toList() ?? const <String>[];
    final String abs;
    if (nodeStack.isNotEmpty)
      abs = nodeStack.last; // the deepest drilled-into folder/mapping
    else if (item.data is PathString)
      abs = (item.data as PathString).path; // series root
    else
      abs = item.id.substring(prefix.length);

    return prefix + PathUtils.relativeToRootOrFull(PathString(abs).path, libraryRoot);
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

/// A single entry in the navigation history, which is either in the forward stack or the (reversed) back stack;
/// [isCurrent] marks the top of the back stack
typedef _HistoryEntry = ({NavigationItem item, bool isCurrent});
