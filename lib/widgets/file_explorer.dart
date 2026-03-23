import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

import '../manager.dart';
import '../services/navigation/shortcuts.dart';
import '../services/navigation/show_info.dart';
import '../utils/path.dart';

/// A file/folder browser widget that lets users navigate and select files
/// within a root directory.
///
/// Supports single or multi-select, optional folder/"(This Folder)" selection,
/// and file-only or folder-only modes.
class FileExplorer extends StatefulWidget {
  /// Root directory — the explorer cannot navigate above this.
  final PathString rootPath;

  /// Initial directory to show (defaults to [rootPath]).
  final PathString? initialDirectory;

  /// Allow selecting individual files.
  final bool allowFiles;

  /// Allow selecting directories (via the "(This Folder)" row).
  final bool allowCurrentFolder;

  /// Allow selecting multiple items. When false, selecting a new item
  /// replaces the previous selection.
  final bool multiSelect;

  /// Called when the selection changes (single-select) or an item is toggled
  /// (multi-select). The full current selection set is provided.
  final ValueChanged<Set<PathString>>? onSelectionChanged;

  /// Called when a file is double-tapped (e.g. to confirm selection).
  final ValueChanged<PathString>? onFileDoubleTap;

  /// Initial selection set.
  final Set<PathString>? initialSelection;

  const FileExplorer({
    super.key,
    required this.rootPath,
    this.initialDirectory,
    this.allowFiles = true,
    this.allowCurrentFolder = true,
    this.multiSelect = false,
    this.onSelectionChanged,
    this.onFileDoubleTap,
    this.initialSelection,
  });

  @override
  State<FileExplorer> createState() => FileExplorerState();
}

class FileExplorerState extends State<FileExplorer> {
  late PathString _currentDirectory;
  List<FileSystemEntity> _contents = [];
  final Set<PathString> _selection = {};

  Set<PathString> get selection => Set.unmodifiable(_selection);

  @override
  void initState() {
    super.initState();
    _currentDirectory = widget.initialDirectory ?? widget.rootPath;
    if (widget.initialSelection != null) _selection.addAll(widget.initialSelection!);
    _loadContents();
  }

  void _loadContents() {
    try {
      final dir = Directory(_currentDirectory.path);
      _contents = dir.listSync()
        ..sort((a, b) {
          final aIsDir = a is Directory;
          final bIsDir = b is Directory;
          if (aIsDir && !bIsDir) return -1;
          if (!aIsDir && bIsDir) return 1;
          return a.path.compareTo(b.path);
        });
      setState(() {});
    } catch (e, stack) {
      snackBar('Error loading folder contents: $e', severity: InfoBarSeverity.error, exception: e, stackTrace: stack);
    }
  }

  void _navigateUp() {
    final parent = Directory(_currentDirectory.path).parent;
    // Don't navigate above root
    final rootNorm = widget.rootPath.path.toLowerCase();
    final parentNorm = PathString(parent.path).path.toLowerCase();
    if (parentNorm.length < rootNorm.length) return;

    setState(() {
      _currentDirectory = PathString(parent.path);
      _loadContents();
    });
  }

  bool get _canNavigateUp {
    final rootNorm = widget.rootPath.path.toLowerCase();
    final currentNorm = _currentDirectory.path.toLowerCase();
    return currentNorm != rootNorm;
  }

  void _select(PathString path) {
    setState(() {
      if (widget.multiSelect) {
        if (_selection.contains(path)) {
          _selection.remove(path);
        } else {
          _selection.add(path);
        }
      } else {
        _selection.clear();
        _selection.add(path);
      }
    });
    widget.onSelectionChanged?.call(Set.unmodifiable(_selection));
  }

  String _displayPath(PathString path) {
    final root = widget.rootPath.path;
    if (path.path == root) return '(Root Folder)';
    if (path.path.startsWith(root)) return path.path.substring(root.length + 1);
    return path.path;
  }

  @override
  Widget build(BuildContext context) {
    final nothingSelected = _selection.isEmpty;
    return Card(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(8),
      backgroundColor: nothingSelected ? Manager.accentColor.lighter.withOpacity(0.1) : Colors.transparent,
      borderColor: nothingSelected ? Manager.accentColor.lighter : FluentTheme.of(context).resources.controlStrokeColorDefault,
      child: Column(
        children: [
          // Navigation bar
          Row(
            children: [
              Button(
                onPressed: _canNavigateUp ? _navigateUp : null,
                child: const Icon(FluentIcons.back),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _displayPath(_currentDirectory),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(),
          // File/folder list
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: KeyboardState.ctrlPressedNotifier,
              builder: (context, isCtrlPressed, _) {
                final itemCount = _contents.length + (widget.allowCurrentFolder ? 1 : 0);
                return Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: ListView.builder(
                    physics: isCtrlPressed ? const NeverScrollableScrollPhysics() : null,
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      if (widget.allowCurrentFolder && index == 0) {
                        return _buildCurrentFolderTile();
                      }

                      final entityIndex = widget.allowCurrentFolder ? index - 1 : index;
                      final entity = _contents[entityIndex];
                      final isDir = entity is Directory;
                      final fileName = entity.path.split(Platform.pathSeparator).last;
                      final entityPath = PathString(entity.path);
                      final isSelected = _selection.contains(entityPath);

                      return _SelectableTile(
                        title: Text(fileName, style: isSelected ? const TextStyle(fontWeight: FontWeight.bold) : null),
                        icon: _fileEntityIcon(context, isDir, isSelected),
                        isSelected: isSelected,
                        onTap: () {
                          if (isDir) {
                            setState(() {
                              _currentDirectory = entityPath;
                              _loadContents();
                            });
                            if (widget.allowCurrentFolder) {
                              // Don't auto-select folders when navigating into them
                            }
                          } else if (widget.allowFiles) {
                            _select(entityPath);
                          }
                        },
                        onDoubleTap: !isDir && widget.allowFiles
                            ? () {
                                _select(entityPath);
                                widget.onFileDoubleTap?.call(entityPath);
                              }
                            : null,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentFolderTile() {
    final isSelected = _selection.contains(_currentDirectory);
    return _SelectableTile(
      icon: _fileEntityIcon(context, true, isSelected),
      isSelected: isSelected,
      title: Text('(This Folder)', style: isSelected ? const TextStyle(fontWeight: FontWeight.bold) : null),
      onTap: () => _select(_currentDirectory),
    );
  }
}

// ---------------------------------------------------------------------------
// Supporting widgets
// ---------------------------------------------------------------------------

Widget _fileEntityIcon(BuildContext context, bool isDir, bool isSelected) {
  return Icon(
    isDir ? FluentIcons.folder : FluentIcons.document,
    color: isSelected ? FluentTheme.of(context).accentColor : null,
  );
}

class _SelectableTile extends StatelessWidget {
  final Widget title;
  final Widget icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  const _SelectableTile({
    required this.title,
    required this.icon,
    this.isSelected = false,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: Card(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(8),
        backgroundColor: isSelected ? FluentTheme.of(context).accentColor.darkest.withOpacity(0.2) : Colors.transparent,
        child: ListTile(
          cursor: SystemMouseCursors.click,
          leading: icon,
          title: title,
          onPressed: onTap,
        ),
      ),
    );
  }
}
