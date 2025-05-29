// ignore_for_file: invalid_use_of_protected_member

import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:miruryoiki/utils/time_utils.dart';
import 'package:miruryoiki/widgets/series_image.dart';

import '../../main.dart';
import '../../manager.dart';
import '../../models/anilist/mapping.dart';
import '../../models/series.dart';
import '../../services/anilist/linking.dart';
import '../../services/cache.dart';
import '../../services/navigation/dialogs.dart';
import '../../services/navigation/shortcuts.dart';
import '../../services/navigation/show_info.dart';
import '../../utils/color_utils.dart';
import '../buttons/loading_button.dart';
import '../buttons/wrapper.dart';
import 'search_panel.dart';

final GlobalKey<AnilistLinkMultiContentState> linkMultiDialogKey = GlobalKey<AnilistLinkMultiContentState>();

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
    super.constraints = const BoxConstraints(maxWidth: 1400, maxHeight: 700),
  }) : super(
          contentBuilder: (context, constraints) => _AnilistLinkMultiContent(
            key: linkMultiDialogKey,
            series: series,
            linkService: linkService,
            onLink: onLink,
            constraints: constraints,
            onSave: (mappings) {
              onDialogComplete?.call(true, mappings);

              if (mappings.isEmpty) {
                homeKey.currentState?.setState(() {});
                return;
              }
              homeKey.currentState?.setState(() {});
            },
            onCancel: () => onDialogComplete?.call(null, <AnilistMapping>[]),
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
    super.key,
    required this.series,
    required this.linkService,
    this.onLink,
    required this.constraints,
    required this.onSave,
    required this.onCancel,
  });

  @override
  AnilistLinkMultiContentState createState() => AnilistLinkMultiContentState();
}

class AnilistLinkMultiContentState extends State<_AnilistLinkMultiContent> {
  late List<AnilistMapping> mappings;
  late List<AnilistMapping> oldMappings;
  String mode = 'view';
  String? selectedLocalPath;
  int? selectedAnilistId;
  String? selectedTitle;

  // For duplicate checking
  bool _isExactDuplicate = false;
  bool _hasDuplicateWarning = false;
  AnilistMapping? _existingPathMapping;
  AnilistMapping? _existingIdMapping;

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

  void _checkForDuplicates() {
    if (selectedLocalPath == null || selectedAnilistId == null) {
      setState(() {
        _isExactDuplicate = false;
        _hasDuplicateWarning = false;
        _existingPathMapping = null;
        _existingIdMapping = null;
      });
      return;
    }

    // Check for exact duplicates
    bool exactDuplicate = mappings.any((m) => m.localPath == selectedLocalPath && m.anilistId == selectedAnilistId);

    // Check if this path is already linked to a different Anilist entry
    final pathMapping = mappings.firstWhere(
      (m) => m.localPath == selectedLocalPath && m.anilistId != selectedAnilistId,
      orElse: () => AnilistMapping(localPath: '', anilistId: -1),
    );

    // Check if this Anilist ID is already linked to a different path
    final idMapping = mappings.firstWhere(
      (m) => m.anilistId == selectedAnilistId && m.localPath != selectedLocalPath,
      orElse: () => AnilistMapping(localPath: '', anilistId: -1),
    );

    final hasPathWarning = pathMapping.anilistId != -1;
    final hasIdWarning = idMapping.anilistId != -1;

    setState(() {
      _isExactDuplicate = exactDuplicate;
      _hasDuplicateWarning = hasPathWarning || hasIdWarning;
      _existingPathMapping = hasPathWarning ? pathMapping : null;
      _existingIdMapping = hasIdWarning ? idMapping : null;
    });
  }

  bool _isNewlyAddedMapping(AnilistMapping mapping) {
    return !oldMappings.any((m) => m.anilistId == mapping.anilistId && m.localPath == mapping.localPath);
  }

  @override
  void initState() {
    super.initState();
    Manager.canPopDialog = true;
    mappings = List.from(widget.series.anilistMappings);
    oldMappings = List.from(mappings);
    currentDirectory = widget.series.path;
    _loadFolderContents();

    nextFrame(() {
      if (mode == 'view') switchToViewMode();
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

  void switchToViewMode() {
    context.resizeManagedDialog(
      constraints: BoxConstraints(
        maxWidth: 700, // Smaller width for view mode
        maxHeight: 500,
      ),
    );

    setState(() {
      mode = 'view';
      Manager.canPopDialog = true; // Allow dialog to be popped in view mode
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
        maxWidth: 1300, // Full width for add mode
        maxHeight: 700,
      ),
    );

    setState(() {
      mode = 'add';
      Manager.canPopDialog = false; // Prevent popping in add mode
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

  // View mode
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
              : ValueListenableBuilder(
                  valueListenable: KeyboardState.ctrlPressedNotifier,
                  builder: (context, isCtrlPressed, _) {
                    return ListView.builder(
                      physics: isCtrlPressed ? const NeverScrollableScrollPhysics() : null,
                      itemCount: mappings.length,
                      itemBuilder: (context, index) => _buildMappingItem(mappings[index]),
                    );
                  }),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ManagedDialogButton(
              text: 'Cancel',
              popContext: context,
              onPressed: () => widget.onCancel.call(),
            ),
            Row(
              children: [
                MouseButtonWrapper(
                  child: (_) => Button(
                    onPressed: _switchToAddMode,
                    child: Text('Add New Link'),
                  ),
                ),
                SizedBox(width: 8),
                ManagedDialogButton(
                  text: mappings.isEmpty && oldMappings.isNotEmpty //
                      ? 'Remove All Links'
                      : 'Save Changes',
                  isPrimary: true,
                  popContext: context,
                  onPressed: _mappingsChanged ? () => widget.onSave(mappings) : null,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMappingItem(AnilistMapping mapping) {
    return UnselectableTile(
      color: _isNewlyAddedMapping(mapping) ? null : widget.series.dominantColor,
      // use the series effective poster if available
      icon: _isNewlyAddedMapping(mapping)
          ? Icon(FluentIcons.add_link, color: Manager.accentColor)
          : mapping.anilistData?.posterImage != null
              ? SeriesImageBuilder(
                  imageProviderFuture: ImageCacheService().getImageProvider(mapping.anilistData!.posterImage!),
                  width: 40,
                  fit: BoxFit.cover,
                )
              : Icon(FluentIcons.document, color: Colors.white),
      title: Text(mapping.title ?? 'Anilist ID: ${mapping.anilistId}'),
      subtitle: Text('Linked to: ${_getDisplayPath(mapping.localPath)}'),
      trailing: MouseButtonWrapper(
        tooltip: 'Remove this link',
        child: (_) => IconButton(
          icon: Transform.translate(
            offset: const Offset(1, -1),
            child: Icon(
              FluentIcons.blocked12,
              size: 18,
              color: _isNewlyAddedMapping(mapping) ? Manager.accentColor : widget.series.dominantColor,
            ),
          ),
          onPressed: () {
            setState(() {
              mappings.remove(mapping);
            });
          },
        ),
      ),
    );
  }

  // Add Links
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
              onPressed: switchToViewMode,
              child: Text('Back'),
            ),
            SizedBox(width: 8),
            MouseButtonWrapper(
              isButtonDisabled: selectedLocalPath == null || selectedAnilistId == null || _isExactDuplicate,
              tooltip: _isExactDuplicate
                  ? 'This exact mapping already exists! You cannot add it again.'
                  : _hasDuplicateWarning
                      ? 'This link may cause conflicts with existing mappings.'
                      : 'Add this link',
              child: (_) => FilledButton(
                style: _isExactDuplicate
                    ? ButtonStyle(
                        backgroundColor: ButtonState.all(darken(Colors.red, .4)),
                        foregroundColor: ButtonState.all(darken(Colors.white, .3)),
                      )
                    : _hasDuplicateWarning
                        ? ButtonStyle(
                            backgroundColor: ButtonState.all(Colors.orange),
                            foregroundColor: ButtonState.all(Colors.white),
                          )
                        : null,
                onPressed: (selectedLocalPath != null && selectedAnilistId != null && !_isExactDuplicate)
                    ? () {
                        if (_isExactDuplicate) {
                          snackBar('This exact mapping already exists', severity: InfoBarSeverity.warning);
                          return;
                        }

                        if (_hasDuplicateWarning) {
                          // Show warning dialog
                          showManagedDialog(
                            context: context,
                            id: 'linkWarning',
                            title: 'Warning: Potential Duplicate Link',
                            builder: (context) => ManagedDialog(
                              popContext: context,
                              title: Text('Warning: Potential Duplicate Link'),
                              contentBuilder: (context, _) => Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_existingPathMapping != null)
                                    Text(
                                      'The selected file/folder is already linked to another Anilist entry (ID: ${_existingPathMapping!.anilistId}).',
                                      style: FluentTheme.of(context).typography.body,
                                    ),
                                  if (_existingPathMapping != null) SizedBox(height: 8),
                                  if (_existingIdMapping != null)
                                    Text(
                                      'The selected Anilist entry is already linked to another file/folder.',
                                      style: FluentTheme.of(context).typography.body,
                                    ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Creating this link may lead to unexpected behavior. Do you want to continue?',
                                    style: FluentTheme.of(context).typography.body,
                                  ),
                                ],
                              ),
                              actions: (context) => <ManagedDialogButton>[
                                ManagedDialogButton(
                                  popContext: context,
                                  text: 'Cancel',
                                ),
                                ManagedDialogButton(
                                  popContext: context,
                                  text: 'Create Link Anyway',
                                  isPrimary: true,
                                  onPressed: () {
                                    setState(() {
                                      mappings.add(AnilistMapping(
                                        localPath: selectedLocalPath!,
                                        anilistId: selectedAnilistId!,
                                        title: selectedTitle,
                                      ));
                                      switchToViewMode();
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        } else {
                          // No conflicts, add the mapping directly
                          setState(() {
                            mappings.add(AnilistMapping(
                              localPath: selectedLocalPath!,
                              anilistId: selectedAnilistId!,
                              title: selectedTitle,
                            ));
                            switchToViewMode();
                          });
                        }
                      }
                    : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Add Link'),
                    if (_hasDuplicateWarning)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(FluentIcons.warning, size: 16),
                      ),
                    if (_isExactDuplicate)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.block, size: 16),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
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

  Widget _buildPathSelector() {
    final isSelected = selectedLocalPath == null;
    return Card(
      padding: EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(8),
      backgroundColor: isSelected ? Manager.accentColor.lighter.withOpacity(0.1) : Colors.transparent,
      borderColor: isSelected ? Manager.accentColor.lighter : FluentTheme.of(context).resources.controlStrokeColorDefault,
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
            child: ValueListenableBuilder(
                valueListenable: KeyboardState.ctrlPressedNotifier,
                builder: (context, isCtrlPressed, _) {
                  return ListView.builder(
                    physics: isCtrlPressed ? const NeverScrollableScrollPhysics() : null,
                    itemCount: folderContents.length + 1, // +1 for current folder option
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Option to select the current directory itself
                        final isSelected = selectedLocalPath == currentDirectory;
                        // Option to select the current directory itself
                        return SelectableTile(
                          icon: FileEntityIcon(context, true, isSelected),
                          isSelected: isSelected,
                          title: Text('(This Folder)', style: isSelected ? TextStyle(fontWeight: FontWeight.bold) : null),
                          onTap: () {
                            setState(() {
                              selectedLocalPath = currentDirectory;
                            });
                            _checkForDuplicates();
                          },
                        );
                      }

                      final entity = folderContents[index - 1];
                      final isDir = entity is Directory;
                      final fileName = entity.path.split(Platform.pathSeparator).last;
                      final isSelected = selectedLocalPath == entity.path;

                      return SelectableTile(
                        title: Text(fileName, style: isSelected ? TextStyle(fontWeight: FontWeight.bold) : null),
                        icon: FileEntityIcon(context, isDir, isSelected),
                        isSelected: isSelected,
                        onTap: () {
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
                          _checkForDuplicates();
                        },
                      );
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget _buildAnilistSearch() {
    final isSelected = selectedLocalPath != null && selectedTitle == null;
    return AnimatedOpacity(
      duration: shortStickyHeaderDuration,
      opacity: selectedLocalPath != null ? 1 : 0.5,
      child: Card(
        padding: EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: isSelected ? Manager.accentColor.lighter.withOpacity(0.1) : Colors.transparent,
        borderColor: isSelected ? Manager.accentColor.lighter : FluentTheme.of(context).resources.controlStrokeColorDefault,
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
            _checkForDuplicates();
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

class SelectableTile extends StatefulWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showTick;
  final Widget? trailing;

  const SelectableTile({
    super.key,
    required this.title,
    required this.icon,
    this.isSelected = false,
    this.onTap,
    this.subtitle,
    this.showTick = false,
    this.trailing,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SelectableTileState createState() => _SelectableTileState();
}

class _SelectableTileState extends State<SelectableTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(8),
      backgroundColor: widget.isSelected ? FluentTheme.of(context).accentColor.darkest.withOpacity(0.2) : Colors.transparent,
      child: ListTile(
        cursor: SystemMouseCursors.click,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.icon,
            if (widget.isSelected && widget.showTick)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(FluentIcons.check_mark, size: 12, color: FluentTheme.of(context).accentColor.lightest),
              ),
          ],
        ),
        trailing: widget.trailing,
        title: widget.title,
        subtitle: widget.subtitle,
        onPressed: widget.onTap,
      ),
    );
  }
}

class UnselectableTile extends StatefulWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  final MouseCursor? cursor;
  final Color? color;

  const UnselectableTile({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.subtitle,
    this.trailing,
    this.cursor,
    this.color,
  });

  @override
  // ignore: library_private_types_in_public_api
  _UnselectableTileState createState() => _UnselectableTileState();
}

class _UnselectableTileState extends State<UnselectableTile> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.color ?? FluentTheme.of(context).accentColor.darkest;
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Card(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(8),
        backgroundColor: backgroundColor.withOpacity(isHovered ? 0.1 : 0.05),
        child: ListTile(
          cursor: widget.cursor,
          leading: widget.icon,
          trailing: widget.trailing,
          title: widget.title,
          subtitle: widget.subtitle,
          onPressed: widget.onTap,
        ),
      ),
    );
  }
}

Widget FileEntityIcon(BuildContext context, bool isDir, bool isSelected) {
  return Icon(
    isDir ? FluentIcons.folder : FluentIcons.document,
    color: isSelected ? FluentTheme.of(context).accentColor : null,
  );
}
