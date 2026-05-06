import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

import 'package:flutter_desktop_context_menu/flutter_desktop_context_menu.dart';
import 'package:path/path.dart' as p;

import '../manager.dart';
import '../services/navigation/shortcuts.dart';
import '../services/navigation/show_info.dart';
import '../utils/path.dart';
import '../utils/shell.dart';
import '../utils/time.dart';

class FileExplorerOptions {
  /// Allow selecting individual files
  final bool allowFiles;

  /// Allow selecting directories (via the "(This Folder)" row)
  final bool allowCurrentFolder;

  /// Allow selecting multiple items
  ///
  /// When false, selecting a new item replaces the previous selection
  final bool multiSelect;

  /// Allow creating new folders in the current directory
  final bool allowCreateFolder;

  /// Allow renaming files and folders
  final bool allowRename;

  /// Allow deleting files and folders
  final bool allowDelete;

  /// Automatically select the folder when opening it
  final bool autoSelectFolder;

  const FileExplorerOptions({
    this.allowFiles = true,
    this.allowCurrentFolder = true,
    this.multiSelect = false,
    this.allowCreateFolder = false,
    this.allowRename = false,
    this.allowDelete = false,
    this.autoSelectFolder = false,
  });
}

/// A file/folder browser widget that lets users navigate and select files within a root directory
///
/// Supports single or multi-select, optional folder/"(This Folder)" selection, and file-only or folder-only modes
class FileExplorer extends StatefulWidget {
  /// Root directory
  final PathString rootPath;

  /// Initial directory to show (defaults to [rootPath])
  final PathString? initialDirectory;

  /// Called when the selection changes (single-select) or an item is toggled (multi-select)
  ///
  /// The full current selection set is provided
  final ValueChanged<Set<PathString>>? onSelectionChanged;

  /// Called when a file is double-tapped (e.g. to confirm selection)
  final ValueChanged<PathString>? onFileDoubleTap;

  /// Initial selection set
  final Set<PathString>? initialSelection;

  /// Whether the file explorer is interactive and visually enabled
  final bool enabled;

  /// The options for configuring the behavior of the file explorer
  final FileExplorerOptions options;

  const FileExplorer({
    super.key,
    required this.rootPath,
    this.initialDirectory,
    this.onSelectionChanged,
    this.onFileDoubleTap,
    this.initialSelection,
    this.enabled = true,
    this.options = const FileExplorerOptions(),
  });

  @override
  State<FileExplorer> createState() => FileExplorerState();
}

class FileExplorerState extends State<FileExplorer> {
  late PathString _currentDirectory;
  List<FileSystemEntity> _contents = [];
  final Set<PathString> _selection = {};

  // Inline rename state
  String? _renamingPath;
  TextEditingController? _renameController;
  FocusNode? _renameFocusNode;

  // Softdelete state
  /// Paths hidden from the UI while the undo snackbar is live
  final Set<String> _pendingDeletes = {};
  final Map<String, Timer> _deleteTimers = {};

  // Main focus node to capture shortcuts like F2 when file explorer is focused
  late final FocusNode _listFocusNode;

  // Guards against the background context menu also firing when right-clicking a tile
  bool _itemSecondaryTapHandled = false;

  Set<PathString> get selection => Set.unmodifiable(_selection);

  @override
  void initState() {
    super.initState();
    _listFocusNode = FocusNode();
    _currentDirectory = widget.initialDirectory ?? widget.rootPath;
    if (widget.initialSelection != null) _selection.addAll(widget.initialSelection!);
    _loadContents();
  }

  @override
  void dispose() {
    _listFocusNode.dispose();
    _cleanupRenameState();
    for (final timer in _deleteTimers.values) timer.cancel();
    for (final path in _pendingDeletes) {
      ShellUtils.moveToRecycleBin(path);
    }
    super.dispose();
  }

  void _loadContents() {
    try {
      final dir = Directory(_currentDirectory.path);
      _contents = dir //
          .listSync()
          .where((e) => !_pendingDeletes.contains(e.path))
          .toList()
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
    if (!_listFocusNode.hasFocus) _listFocusNode.requestFocus();

    setState(() {
      if (widget.options.multiSelect) {
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

  //
  // Inline rename

  void _cleanupRenameState() {
    _renamingPath = null;
    _renameController?.dispose();
    _renameController = null;

    // Capture and null-out before deferring dispose
    // the listener on this node may be what triggered cleanup, and disposing during notifyListeners() crashes
    final staleNode = _renameFocusNode;
    _renameFocusNode = null;
    nextFrame(() => staleNode?.dispose());
  }

  void _startRename(FileSystemEntity entity) {
    _cleanupRenameState();

    final isDir = entity is Directory;
    final name = p.basename(entity.path);
    final extIndex = name.lastIndexOf('.');
    final extentOffset = isDir || extIndex <= 0 ? name.length : extIndex;

    _renameController = TextEditingController(text: name)..selection = TextSelection(baseOffset: 0, extentOffset: extentOffset);
    _renameFocusNode = FocusNode();
    _renameFocusNode!.addListener(() {
      if (!(_renameFocusNode?.hasFocus ?? true)) _submitRename(entity);
    });

    setState(() => _renamingPath = entity.path);
    nextFrame(() => _renameFocusNode?.requestFocus());
  }

  void _submitRename(FileSystemEntity entity) {
    if (_renamingPath == null || _renamingPath != entity.path) return;

    final newName = _renameController!.text.trim();
    final oldName = p.basename(entity.path);
    final originalPath = _renamingPath!;

    _cleanupRenameState();
    if (mounted) setState(() {});

    if (newName.isEmpty || newName == oldName) return;

    try {
      final parentPath = entity.parent.path;
      final newPath = p.join(parentPath, newName);
      final renamed = entity.renameSync(newPath);

      final oldPathString = PathString(originalPath);
      if (_selection.contains(oldPathString)) {
        setState(() {
          _selection.remove(oldPathString);
          _selection.add(PathString(renamed.path));
        });
        widget.onSelectionChanged?.call(Set.unmodifiable(_selection));
      }
      _loadContents();
    } catch (e, stack) {
      final typeName = entity is Directory ? 'Folder' : 'File';
      snackBar('Error renaming $typeName: $e', severity: InfoBarSeverity.error, exception: e, stackTrace: stack);
    }
  }

  void _createFolder() {
    const baseName = 'New Folder';
    var name = baseName;
    var counter = 1;
    while (Directory(p.join(_currentDirectory.path, name)).existsSync()) {
      name = '$baseName ($counter)';
      counter++;
    }

    try {
      final newDir = Directory(p.join(_currentDirectory.path, name));
      newDir.createSync();
      _loadContents();
      _startRename(newDir);
    } catch (e, stack) {
      snackBar('Error creating folder: $e', severity: InfoBarSeverity.error, exception: e, stackTrace: stack);
    }
  }

  //
  // Delete with undo (hide in UI → recycle bin after snackbar fades out)

  void _deleteEntity(FileSystemEntity entity) {
    final typeName = entity is Directory ? 'Folder' : 'File';
    final name = p.basename(entity.path);
    final originalPath = entity.path;

    _pendingDeletes.add(originalPath);

    final pathString = PathString(originalPath);
    if (_selection.contains(pathString)) {
      setState(() => _selection.remove(pathString));
      widget.onSelectionChanged?.call(Set.unmodifiable(_selection));
    }
    _loadContents();
    
    final snackDuration = const Duration(seconds: 5);

    snackBar(
      '$typeName "$name" deleted',
      severity: InfoBarSeverity.warning,
      action: Button(
        child: const Text('Undo'),
        onPressed: () {
          _undoDelete(originalPath);
          hideCurrentSnackBar();
        },
      ),
      duration: snackDuration,
    );

    _deleteTimers[originalPath] = Timer(snackDuration + const Duration(milliseconds: 400), () {
      _pendingDeletes.remove(originalPath);
      _deleteTimers.remove(originalPath);
      ShellUtils.moveToRecycleBin(originalPath);
    });
  }

  void _undoDelete(String originalPath) {
    final timer = _deleteTimers.remove(originalPath);
    timer?.cancel();
    _pendingDeletes.remove(originalPath);
    _loadContents();
  }

  void _showBackgroundContextMenu() {
    popUpContextMenu(Menu(
      items: [
        if (widget.options.allowCreateFolder)
          MenuItem(label: 'New Folder', onClick: (_) => _createFolder()),
        MenuItem(label: 'Refresh', onClick: (_) => _loadContents()),
      ],
    ));
  }

  void _showItemContextMenu(FileSystemEntity entity) {
    final hasRename = widget.options.allowRename;
    final hasDelete = widget.options.allowDelete;
    if (!hasRename && !hasDelete) return;

    popUpContextMenu(Menu(items: [
      if (hasRename) MenuItem(label: 'Rename', onClick: (_) => _startRename(entity)),
      if (hasRename && hasDelete) MenuItem.separator(),
      if (hasDelete) MenuItem(label: 'Delete', onClick: (_) => _deleteEntity(entity)),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    final nothingSelected = _selection.isEmpty;
    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !widget.enabled,
        child: Focus(
          focusNode: _listFocusNode,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.f2) {
              if (widget.options.allowRename && _selection.length == 1) {
                final selectedPath = _selection.first;
                // Exclude the (This Folder) pseudo-item
                if (selectedPath == _currentDirectory && widget.options.allowCurrentFolder) return KeyEventResult.ignored;

                final entityIndex = _contents.indexWhere((e) => e.path == selectedPath.path);
                if (entityIndex != -1 && _renamingPath == null) {
                  _startRename(_contents[entityIndex]);
                  return KeyEventResult.handled;
                }
              }
            }
            return KeyEventResult.ignored;
          },
          child: Card(
            padding: const EdgeInsets.all(12),
            borderRadius: BorderRadius.circular(8),
            backgroundColor: nothingSelected ? Manager.accentColor.lighter.withOpacity(0.1) : Colors.transparent,
            borderColor: nothingSelected ? Manager.accentColor.lighter : FluentTheme.of(context).resources.controlStrokeColorDefault,
            child: Column(
              children: [
                // Navigation bar
                SizedBox(
                  height: 36,
                  child: Row(
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
                      if (widget.options.allowCreateFolder)
                        Tooltip(
                          message: 'Create Folder',
                          useMousePosition: false,
                          child: IconButton(
                            icon: const Icon(FluentIcons.add),
                            onPressed: _createFolder,
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(),
                // File/folder list
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: KeyboardState.ctrlPressedNotifier,
                    builder: (context, isCtrlPressed, _) {
                      final itemCount = _contents.length + (widget.options.allowCurrentFolder ? 1 : 0);
                      return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onSecondaryTapDown: (_) {
                          if (_itemSecondaryTapHandled) {
                            _itemSecondaryTapHandled = false;
                            return;
                          }
                          _showBackgroundContextMenu();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: ListView.builder(
                            physics: isCtrlPressed ? const NeverScrollableScrollPhysics() : null,
                            itemCount: itemCount,
                            itemBuilder: (context, index) {
                              if (widget.options.allowCurrentFolder && index == 0) return _buildCurrentFolderTile();

                              final entityIndex = widget.options.allowCurrentFolder ? index - 1 : index;
                              return _buildEntityTile(_contents[entityIndex]);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEntityTile(FileSystemEntity entity) {
    final isDir = entity is Directory;
    final fileName = p.basename(entity.path);
    final entityPath = PathString(entity.path);
    final isSelected = _selection.contains(entityPath);
    final isRenaming = _renamingPath == entity.path;

    final Widget titleWidget = isRenaming
        ? TextBox(
            controller: _renameController!,
            focusNode: _renameFocusNode!,
            onSubmitted: (_) => _submitRename(entity),
          )
        : Text(fileName, style: isSelected ? const TextStyle(fontWeight: FontWeight.bold) : null);

    Widget? trailing;
    if (!isRenaming && (widget.options.allowRename || widget.options.allowDelete)) {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.options.allowRename)
            Tooltip(
              message: 'Rename',
              useMousePosition: false,
              child: IconButton(
                icon: const Icon(FluentIcons.rename),
                onPressed: () => _startRename(entity),
              ),
            ),
          if (widget.options.allowDelete)
            Tooltip(
              message: 'Delete',
              useMousePosition: false,
              child: IconButton(
                icon: const Icon(FluentIcons.delete),
                style: ButtonStyle(foregroundColor: ButtonState.all(Colors.red)),
                onPressed: () => _deleteEntity(entity),
              ),
            ),
        ],
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (_) {
        _itemSecondaryTapHandled = true;
        if (!isRenaming) _showItemContextMenu(entity);
      },
      child: _SelectableTile(
        title: titleWidget,
        icon: _fileEntityIcon(context, isDir, isSelected),
        isSelected: isSelected,
        trailing: trailing,
        onTap: isRenaming
            ? null
            : () {
                if (isDir) {
                  setState(() {
                    _currentDirectory = entityPath;
                    _loadContents();
                  });
                  if (widget.options.autoSelectFolder) _select(entityPath);
                } else if (widget.options.allowFiles) {
                  _select(entityPath);
                }
              },
        onDoubleTap: !isRenaming && !isDir && widget.options.allowFiles
            ? () {
                _select(entityPath);
                widget.onFileDoubleTap?.call(entityPath);
              }
            : null,
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
  final Widget? trailing;

  const _SelectableTile({
    required this.title,
    required this.icon,
    this.isSelected = false,
    this.onTap,
    this.onDoubleTap,
    this.trailing,
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
          trailing: trailing,
          onPressed: onTap,
        ),
      ),
    );
  }
}
