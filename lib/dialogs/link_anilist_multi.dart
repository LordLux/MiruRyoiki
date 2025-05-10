// ignore_for_file: invalid_use_of_protected_member

import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';

import '../main.dart';
import '../manager.dart';
import '../models/anilist/mapping.dart';
import '../models/series.dart';
import '../services/anilist/linking.dart';
import '../services/navigation/dialogs.dart';
import '../services/navigation/show_info.dart';
import 'search_panel.dart';

class AnilistLinkMultiDialog extends ManagedDialog {
  final Series series;
  final SeriesLinkService linkService;
  final Function(int, String)? onLink;
  final Function(bool? success, List<AnilistMapping> mappings)? onDialogComplete;

  AnilistLinkMultiDialog({
    super.key,
    required this.series,
    required this.linkService,
    this.onLink,
    required super.popContext,
    this.onDialogComplete,
    super.title = const Text('Link Local entry to Anilist entry'),
    super.constraints = const BoxConstraints(maxWidth: 1000, maxHeight: 600),
  }) : super(
          contentBuilder: (context, constraints) => _AnilistLinkMultiContent(
            series: series,
            linkService: linkService,
            onLink: onLink,
            constraints: constraints,
            onSave: (mappings) {
              // Call the callback if provided
              onDialogComplete?.call(true, mappings);

              if (mappings.isEmpty) {
                closeDialog(popContext, result: (true, <AnilistMapping>[]));
                closeDialog(popContext, result: (true, <AnilistMapping>[]));
                homeKey.currentState?.setState(() {});
                return;
              }
              closeDialog(popContext, result: (true, mappings));
              closeDialog(popContext, result: (true, mappings));
              homeKey.currentState?.setState(() {});
            },
            onCancel: () {
              // Call the callback if provided
              onDialogComplete?.call(null, <AnilistMapping>[]);

              closeDialog(popContext, result: (null, <AnilistMapping>[]));
              closeDialog(popContext, result: (null, <AnilistMapping>[]));
            },
          ),
          actions: (_) => [],
        );
}

class _AnilistLinkMultiContent extends StatefulWidget {
  final Series series;
  final SeriesLinkService linkService;
  final Function(int, String)? onLink;
  final BoxConstraints constraints;
  final Function(List<AnilistMapping> mappings) onSave;
  final VoidCallback onCancel;

  const _AnilistLinkMultiContent({
    required this.series,
    required this.linkService,
    this.onLink,
    required this.constraints,
    required this.onSave,
    required this.onCancel,
  });

  @override
  _AnilistLinkMultiContentState createState() => _AnilistLinkMultiContentState();
}

class _AnilistLinkMultiContentState extends State<_AnilistLinkMultiContent> {
  late List<AnilistMapping> mappings;
  late List<AnilistMapping> oldMappings;
  String mode = 'view';
  String? selectedLocalPath;
  int? selectedAnilistId;
  String? selectedTitle;

  // For folder/file browser
  List<FileSystemEntity> folderContents = [];
  String? currentDirectory;

  bool get _mappingsChanged {
    if (oldMappings.length != mappings.length) return true;

    // Compare each mapping by ID and path
    for (int i = 0; i < mappings.length; i++) {
      if (mappings[i].anilistId != oldMappings[i].anilistId || mappings[i].localPath != oldMappings[i].localPath || mappings[i].title != oldMappings[i].title) {
        return true;
      }
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
    mappings = List.from(widget.series.anilistMappings);
    oldMappings = List.from(mappings);
    currentDirectory = widget.series.path;
    _loadFolderContents();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mode == 'view') _switchToViewMode();
    });
  }

  void _loadFolderContents() {
    if (currentDirectory == null) return;

    try {
      final dir = Directory(currentDirectory!);
      folderContents = dir.listSync()
        ..sort((a, b) {
          // Folders first, then files
          bool aIsDir = a is Directory;
          bool bIsDir = b is Directory;
          if (aIsDir && !bIsDir) return -1;
          if (!aIsDir && bIsDir) return 1;
          return a.path.compareTo(b.path);
        });
      setState(() {});
    } catch (e) {
      snackBar('Error loading folder contents: $e', severity: InfoBarSeverity.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }

  void _switchToViewMode() {
    context.resizeManagedDialog(
      constraints: BoxConstraints(
        maxWidth: 700, // Smaller width for view mode
        maxHeight: 500,
      ),
    );

    setState(() {
      mode = 'view';
      selectedLocalPath = null;
      selectedAnilistId = null;
      selectedTitle = null;

      currentDirectory = widget.series.path;
      _loadFolderContents();
    });
  }

  // Switch to add mode with appropriate sizing
  void _switchToAddMode() {
    context.resizeManagedDialog(
      constraints: BoxConstraints(
        maxWidth: 1000, // Full width for add mode
        maxHeight: 600,
      ),
    );

    setState(() {
      mode = 'add';
      selectedLocalPath = null;
      selectedAnilistId = null;
      selectedTitle = null;

      currentDirectory = widget.series.path;
      _loadFolderContents(); // Reload folder contents for the reset path
    });
  }

  Widget _buildContent() {
    switch (mode) {
      case 'add':
        return _buildAddForm();
      case 'view':
      default:
        return _buildMappingsList();
    }
  }

  Widget _buildMappingsList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Current Anilist Links:'),
        SizedBox(height: 10),
        Expanded(
          child: mappings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FluentIcons.remove_link, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'No links configured.',
                        style: FluentTheme.of(context).typography.bodyLarge,
                      ),
                      if (oldMappings.isNotEmpty)
                        Text(
                          'All links have been removed.',
                          style: TextStyle(color: Colors.orange),
                        ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: mappings.length,
                  itemBuilder: (context, index) => _buildMappingItem(mappings[index]),
                ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Button(
              onPressed: widget.onCancel,
              child: Text('Cancel'),
            ),
            Row(
              children: [
                Button(
                  onPressed: _switchToAddMode,
                  child: Text('Add New Link'),
                ),
                SizedBox(width: 8),
                FilledButton(
                  onPressed: _mappingsChanged ? () => widget.onSave(mappings) : null,
                  child: Text(
                    mappings.isEmpty && oldMappings.isNotEmpty
                        ? //
                        'Remove All Links'
                        : 'Save Changes',
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMappingItem(AnilistMapping mapping) {
    final isRootMapping = mapping.localPath == widget.series.path;
    return Card(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(4),
      child: ListTile(
        leading: Icon(
          isRootMapping ? FluentIcons.archive : FluentIcons.link,
          color: FluentTheme.of(context).accentColor,
        ),
        title: Text(mapping.title ?? 'Anilist ID: ${mapping.anilistId}'),
        subtitle: Text('Linked to: ${_getDisplayPath(mapping.localPath)}'),
        trailing: IconButton(
          icon: Icon(FluentIcons.delete),
          onPressed: () {
            setState(() {
              mappings.remove(mapping);
            });
          },
        ),
      ),
    );
  }

  String _getDisplayPath(String path) {
    final seriesPath = widget.series.path;
    if (path == seriesPath) return '(Main Series Folder)';
    if (path.startsWith(seriesPath)) {
      return path.substring(seriesPath.length + 1);
    }
    return path;
  }

  Widget _buildAddForm() {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left panel: file/folder browser
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select the local Folder or File:'),
                    SizedBox(height: 8),
                    Expanded(child: _buildPathSelector()),
                    if (selectedLocalPath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Selected: ${_getDisplayPath(selectedLocalPath!)}',
                          style: FluentTheme.of(context).typography.bodyStrong,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              // Right panel: Anilist search
              Expanded(
                flex: 1,
                child: MouseRegion(
                  cursor: selectedLocalPath == null ? SystemMouseCursors.forbidden : MouseCursor.defer,
                  opaque: selectedLocalPath == null,
                  hitTestBehavior: selectedLocalPath != null ? HitTestBehavior.opaque : HitTestBehavior.translucent,
                  child: AbsorbPointer(
                    absorbing: selectedLocalPath == null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Search for the Anilist entry:'),
                        SizedBox(height: 8),
                        Expanded(
                          child: _buildAnilistSearch(),
                        ),
                        if (selectedAnilistId != null && selectedTitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Selected: $selectedTitle',
                              style: FluentTheme.of(context).typography.bodyStrong,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Status indicators
            Expanded(
              child: Row(
                children: [
                  Circle(selectedLocalPath),
                  SizedBox(width: 4),
                  Text('Local path'),
                  SizedBox(width: 12),
                  Circle(selectedAnilistId),
                  SizedBox(width: 4),
                  Text('Anilist entry'),
                ],
              ),
            ),

            // Buttons
            Button(
              onPressed: _switchToViewMode,
              child: Text('Back'),
            ),
            SizedBox(width: 8),
            FilledButton(
              onPressed: selectedLocalPath != null && selectedAnilistId != null
                  ? () {
                      setState(() {
                        mappings.add(AnilistMapping(
                          localPath: selectedLocalPath!,
                          anilistId: selectedAnilistId!,
                          title: selectedTitle,
                        ));
                        _switchToViewMode();
                      });
                    }
                  : null,
              child: Text('Add Link'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPathSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: selectedLocalPath == null ? accent(.5) : Colors.transparent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Path navigation bar
          Row(
            children: [
              Button(
                onPressed: currentDirectory == widget.series.path
                    ? null
                    : () {
                        setState(() {
                          currentDirectory = Directory(currentDirectory!).parent.path;
                          _loadFolderContents();
                        });
                      },
                child: Icon(FluentIcons.back),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getDisplayPath(currentDirectory ?? ''),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Divider(),
          // File/folder list
          Expanded(
            child: ListView.builder(
              itemCount: folderContents.length + 1, // +1 for current folder option
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Option to select the current directory itself
                  final isSelected = selectedLocalPath == currentDirectory;
                  // Option to select the current directory itself
                  return Card(
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(8),
                    backgroundColor: isSelected ? FluentTheme.of(context).accentColor.withOpacity(0.1) : Colors.transparent,
                    child: ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FluentIcons.folder, color: isSelected ? FluentTheme.of(context).accentColor : null),
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(FluentIcons.check_mark, size: 12, color: FluentTheme.of(context).accentColor),
                            ),
                        ],
                      ),
                      title: Text('(This Folder)', style: isSelected ? TextStyle(fontWeight: FontWeight.bold) : null),
                      onPressed: () {
                        setState(() {
                          selectedLocalPath = currentDirectory;
                        });
                      },
                    ),
                  );
                }

                final entity = folderContents[index - 1];
                final isDir = entity is Directory;
                final fileName = entity.path.split(Platform.pathSeparator).last;
                final isSelected = selectedLocalPath == entity.path;

                return Card(
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(8),
                  backgroundColor: isSelected ? FluentTheme.of(context).accentColor.withOpacity(0.1) : Colors.transparent,
                  child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDir ? FluentIcons.folder : FluentIcons.document,
                          color: isSelected ? FluentTheme.of(context).accentColor : null,
                        ),
                        if (isSelected)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(FluentIcons.check_mark, size: 12, color: FluentTheme.of(context).accentColor),
                          ),
                      ],
                    ),
                    title: Text(fileName, style: isSelected ? TextStyle(fontWeight: FontWeight.bold) : null),
                    onPressed: () {
                      if (isDir) {
                        setState(() {
                          // Both select and navigate to the folder
                          selectedLocalPath = entity.path;
                          currentDirectory = entity.path;
                          _loadFolderContents();
                        });
                      } else {
                        setState(() {
                          selectedLocalPath = entity.path;
                        });
                      }
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

  Widget _buildAnilistSearch() {
    return Opacity(
      opacity: selectedLocalPath != null ? 1 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: selectedLocalPath != null ? accent(.5) : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
        child: AnilistSearchPanel(
          initialSearch: widget.series.name,
          linkService: widget.linkService,
          series: widget.series,
          constraints: widget.constraints,
          skipAutoClose: true,
          enabled: selectedLocalPath != null,
          onLink: (id, name) async {
            setState(() {
              selectedAnilistId = id;
              selectedTitle = name;
            });
          },
        ),
      ),
    );
  }

  Color accent(double value) {
    return Colors.grey.lerpWith(Manager.accentColor, value);
  }

  Widget Circle(dynamic value) {
    return Container(
      decoration: BoxDecoration(
        color: accent(.05),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: accent(.25),
        ),
      ),
      child: Icon(
        value != null ? FluentIcons.check_mark : FluentIcons.circle_ring,
        size: 20,
        color: value != null ? Colors.green : Colors.transparent,
      ),
    );
  }
}
