// ignore_for_file: invalid_use_of_protected_member

import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:miruryoiki/utils/time.dart';
import 'package:miruryoiki/widgets/series_image.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../viewmodels/library_screen_viewmodel.dart';
import '../../manager.dart';
import '../../models/anilist/mapping.dart';
import '../../models/series.dart';
import '../../services/anilist/linking.dart';
import '../../services/file_system/cache.dart';
import '../../services/library/library_provider.dart';
import '../../services/library/scanner/scanner_service.dart';
import '../../services/lock_manager.dart';
import '../../services/anilist/anilist_availability.dart';
import '../../services/connectivity/connectivity_service.dart';
import '../../services/navigation/dialogs.dart';
import '../../services/navigation/dialogs2.dart';
import '../../services/navigation/navigation.dart';
import '../../services/navigation/show_info.dart';
import '../../utils/color.dart';
import '../../utils/logging.dart';
import '../../utils/path.dart';
import '../../utils/shell.dart';
import '../buttons/button.dart';
import '../file_explorer.dart';
import '../service_unavailable_banner.dart';
import '../buttons/hyperlink.dart';
import '../buttons/wrapper.dart';
import '../tooltip_wrapper.dart';
import 'search_panel.dart';
import 'show_dialog.dart';

class AnilistLinkMultiDialog extends StatelessWidget {
  final Series series;
  final SeriesLinkService linkService;
  final Function(int, String)? onLink;
  final Function(bool? success, List<AnilistMapping> mappings)? onDialogComplete;
  final BoxConstraints constraints;
  final bool requireLocalFirst;
  final PathString? initialLocalPath;
  final int? initialAnilistId;
  final bool lockLocal;
  final bool lockAnilist;
  final bool startInAddMode;
  final FileExplorerOptions explorerOptions;
  final DialogNavigationItem? item;

  const AnilistLinkMultiDialog({
    super.key,
    required this.series,
    required this.linkService,
    required this.onLink,
    required this.onDialogComplete,
    required this.constraints,
    this.requireLocalFirst = true,
    this.initialLocalPath,
    this.initialAnilistId,
    this.lockLocal = false,
    this.lockAnilist = false,
    this.startInAddMode = false,
    this.explorerOptions = const FileExplorerOptions(allowFiles: true, allowCurrentFolder: true, autoSelectFolder: true),
    this.item,
  });

  @override
  Widget build(BuildContext context) {
    return AnilistLinkMultiContent(
      item: item,
      series: series,
      linkService: linkService,
      onLink: onLink,
      constraints: constraints,
      requireLocalFirst: requireLocalFirst,
      initialLocalPath: initialLocalPath,
      initialAnilistId: initialAnilistId,
      lockLocal: lockLocal,
      lockAnilist: lockAnilist,
      startInAddMode: startInAddMode,
      explorerOptions: explorerOptions,
      onSave: (mappings) {
        onDialogComplete?.call(true, mappings);
        homeKey.currentState?.setState(() {});
      },
      onCancel: () => onDialogComplete?.call(null, <AnilistMapping>[]),
    );
  }
}

class AnilistLinkMultiContent extends StatefulWidget {
  final Series series;
  final SeriesLinkService linkService;
  final Function(int, String)? onLink;
  final BoxConstraints constraints;
  final Function(List<AnilistMapping> mappings) onSave;
  final VoidCallback onCancel;
  final bool requireLocalFirst;
  final PathString? initialLocalPath;
  final int? initialAnilistId;
  final bool lockLocal;
  final bool lockAnilist;
  final bool startInAddMode;
  final FileExplorerOptions explorerOptions;
  final DialogNavigationItem? item;

  const AnilistLinkMultiContent({
    super.key,
    required this.series,
    required this.linkService,
    this.onLink,
    required this.constraints,
    required this.onSave,
    required this.onCancel,
    this.requireLocalFirst = true,
    this.initialLocalPath,
    this.initialAnilistId,
    this.lockLocal = false,
    this.lockAnilist = false,
    this.startInAddMode = false,
    this.explorerOptions = const FileExplorerOptions(allowFiles: true, allowCurrentFolder: true, autoSelectFolder: true),
    this.item,
  });

  @override
  AnilistLinkMultiContentState createState() => AnilistLinkMultiContentState();
}

class AnilistLinkMultiContentState extends State<AnilistLinkMultiContent> with DialogController {
  @override
  bool get canPop => mode == 'view';

  @override
  bool onBackRequested() {
    switchToViewMode();
    return true;
  }

  late List<AnilistMapping> mappings;
  late List<AnilistMapping> oldMappings;
  String mode = 'view';
  PathString? selectedLocalPath;
  int? selectedAnilistId;
  String? selectedTitle;

  bool _isFakeLoading = false;

  // For duplicate checking
  bool _isExactDuplicate = false;
  bool _hasDuplicateWarning = false;
  AnilistMapping? _existingPathMapping;
  AnilistMapping? _existingIdMapping;

  // For folder/file browser
  List<FileSystemEntity> folderContents = [];
  PathString? currentDirectory;

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
      orElse: () => AnilistMapping(localPath: PathString(''), anilistId: -1),
    );

    // Check if this Anilist ID is already linked to a different path
    final idMapping = mappings.firstWhere(
      (m) => m.anilistId == selectedAnilistId && m.localPath != selectedLocalPath,
      orElse: () => AnilistMapping(localPath: PathString(''), anilistId: -1),
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

  bool _isNewlyAddedMapping(AnilistMapping mapping) => //
      !oldMappings.any((m) => m.anilistId == mapping.anilistId && m.localPath == mapping.localPath);

  @override
  void initState() {
    super.initState();
    widget.item?.controller = this;
    mappings = List.from(widget.series.anilistMappings);
    oldMappings = List.from(mappings);
    currentDirectory = widget.series.path;
    _loadFolderContents();

    nextFrame(() {
      if (widget.startInAddMode) {
        _switchToAddMode();
      } else if (mode == 'view') {
        switchToViewMode();
      }
    });
  }

  @override
  void dispose() {
    widget.item?.controller = null;
    super.dispose();
  }

  void _loadFolderContents() {
    if (currentDirectory == null) return;

    try {
      final dir = Directory(currentDirectory!.path);
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
    } catch (e, stackTrace) {
      snackBar(
        'Error loading folder contents: $e',
        severity: InfoBarSeverity.error,
        exception: e,
        stackTrace: stackTrace,
      );
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
      selectedLocalPath = widget.initialLocalPath;
      selectedAnilistId = widget.initialAnilistId;
      selectedTitle = null; // Will be set by AnilistSimpleSearchPanel when it loads the initial title

      currentDirectory = selectedLocalPath ?? widget.series.path;
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
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Current Anilist Links:'),
          ],
        ),
        SizedBox(height: 10),
        Expanded(
          //TODO remove a bit of left padding for the image + add borderradius to poster
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
            TooltipWrapper(
              tooltip: _mappingsChanged ? 'Cancel and close Dialog' : 'Close Dialog',
              child: (_) => PaddedDialogButton(
                text: _mappingsChanged ? 'Cancel' : 'Close',
                onPressed: () => widget.onCancel.call(),
              ),
            ),
            if (widget.series.anilistMappings.length > 1) ...[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: FluentTheme(
                    data: FluentTheme.of(context).copyWith(accentColor: Manager.dominantOrAccentColor),
                    child: TooltipWrapper(
                      tooltip: Provider.of<LibraryScannerService>(context).isIndexing ? 'The Library is indexing. Please wait...' : 'Select primary Anilist source',
                      waitDuration: mediumDuration,
                      useMousePosition: false,
                      child: (_) => MouseButtonWrapper(
                        isLoading: Provider.of<LibraryScannerService>(context).isIndexing,
                        isButtonDisabled: Provider.of<LibraryScannerService>(context).isIndexing,
                        child: (_) => ComboBox<int>(
                          isExpanded: true,
                          placeholder: const Text('Select Anilist source'),
                          disabledPlaceholder: const Text('No Anilist mappings available'),
                          style: Manager.bodyStyle,
                          items: widget.series.anilistMappings.map((mapping) {
                            final title = mapping.title ?? 'Anilist ID: ${mapping.anilistId}';
                            return ComboBoxItem<int>(
                              value: mapping.anilistId,
                              child: Center(
                                child: TooltipWrapper(
                                  tooltip: title,
                                  child: (txt) => Text(
                                    txt,
                                    style: Manager.captionStyle.copyWith(fontSize: 11),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          value: widget.series.primaryAnilistId,
                          onChanged: (value) async {
                            if (value != null) {
                              if (mounted) setState(() => widget.series.primaryAnilistId = value);

                              context.read<LibraryScreenViewModel>().updateSeriesInSortCache(widget.series);

                              // Fetch and load Anilist data for the selected mapping
                              await seriesScreenKey.currentState!.changePrimaryId(value);
                              if (mounted) setState(() {});
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            Row(
              children: [
                TooltipWrapper(
                  tooltip: 'Add a new Anilist link',
                  child: (_) => MouseButtonWrapper(
                    child: (_) => StandardButton(
                      onPressed: _switchToAddMode,
                      isFilled: !_mappingsChanged,
                      backgroundColor: Manager.dominantOrAccentColor,
                      hoverColor: Manager.dominantOrAccentColor.light,
                      label: Text('Add New Link', style: Manager.bodyStyle.copyWith(color: getTextColor(!_mappingsChanged ? Manager.dominantOrAccentColor : Colors.black))),
                    ),
                  ),
                ),
                if (_mappingsChanged) ...[
                  SizedBox(width: 8),
                  Builder(builder: (context) {
                    final scannerService = Provider.of<LibraryScannerService>(context);
                    final bool indexing = scannerService.isIndexing;
                    return TooltipWrapper(
                        tooltip: indexing ? 'Please wait for indexing to complete before saving changes.' : 'Save changes',
                        child: (_) => PaddedDialogButton(
                              text: mappings.isEmpty && oldMappings.isNotEmpty //
                                  ? 'Remove All Links'
                                  : 'Save Changes',
                              isPrimary: true,
                              isLoading: indexing,
                              isDisabled: indexing,
                              onPressed: _mappingsChanged ? () => widget.onSave(mappings) : null,
                            ));
                  }),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMappingItem(AnilistMapping mapping) {
    final isNewlyAddedMapping = _isNewlyAddedMapping(mapping);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: UnselectableTile(
        color: isNewlyAddedMapping ? Colors.white.withOpacity(0.05) : Manager.dominantOrAccentColor,
        // use the series effective poster if available
        icon: isNewlyAddedMapping
            ? SizedBox(width: 30, child: Icon(FluentIcons.add_link, color: Colors.white))
            : mapping.anilistData?.posterImage != null
                ? Transform.translate(
                    offset: const Offset(-6, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SeriesImageBuilder(
                        imageProviderFuture: ImageCacheService().getImageProvider(mapping.anilistData!.posterImage!),
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Icon(FluentIcons.document, color: Colors.white),

        title: Transform.translate(
          offset: isNewlyAddedMapping ? const Offset(0, 0) : const Offset(-10, 0),
          child: WrappedHyperlinkButton(
            tooltip: 'Open Anilist page for ${mapping.title ?? 'Anilist ID: ${mapping.anilistId}'}',
            url: "https://anilist.co/anime/${mapping.anilistId}",
            hoverColor: isNewlyAddedMapping ? Colors.white : Manager.dominantOrAccentColor,
            text: mapping.title ?? 'Anilist ID: ${mapping.anilistId}',
            style: Manager.bodyStyle,
            iconColor: isNewlyAddedMapping ? Colors.white : Manager.dominantOrAccentColor,
            icon: Icon(
              Icons.open_in_new,
              color: isNewlyAddedMapping ? Colors.white : Manager.dominantOrAccentColor,
            ),
          ),
        ),
        subtitle: Transform.translate(
          offset: isNewlyAddedMapping ? const Offset(0, 0) : const Offset(-10, 0),
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Linked to: ',
                    style: Manager.bodyStyle.copyWith(color: Colors.white.withOpacity(0.5)),
                  ),
                  WidgetSpan(
                    child: Transform.translate(
                      offset: const Offset(0, 2),
                      child: StandardButton(
                        isSmall: true,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        isLoading: _isFakeLoading,
                        forcedHeight: 18,
                        tooltip: 'Open this path in Explorer',
                        onPressed: () {
                          setState(() => _isFakeLoading = true);
                          ShellUtils.openFileExplorerAndSelect(mapping.localPath);
                          Future.delayed(Duration(milliseconds: 1200)).then((_) {
                            if (mounted) setState(() => _isFakeLoading = false);
                          });
                        },
                        label: Transform.translate(
                          offset: const Offset(0, -0.75),
                          child: Text(
                            '$ps${_getDisplayPath(mapping.localPath)}',
                            style: Manager.bodyStyle.copyWith(
                              // fontStyle: FontStyle.italic,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        trailing: MouseButtonWrapper(
          tooltip: 'Remove this link',
          child: (_) => IconButton(
            icon: Icon(
              Icons.link_off_outlined,
              size: 18,
              color: isNewlyAddedMapping ? Colors.white : Manager.dominantOrAccentColor,
            ),
            onPressed: () => setState(() => mappings.remove(mapping)),
          ),
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
                    Expanded(
                      child: FileExplorer(
                        rootPath: widget.series.path,
                        initialDirectory: widget.initialLocalPath ?? currentDirectory,
                        options: widget.explorerOptions,
                        enabled: !widget.lockLocal,
                        initialSelection: selectedLocalPath != null ? {selectedLocalPath!} : null,
                        onSelectionChanged: (sel) {
                          setState(() {
                            selectedLocalPath = sel.firstOrNull;
                            if (sel.isNotEmpty) {
                              // Update currentDirectory for display
                              final selected = sel.first;
                              if (Directory(selected.path).existsSync()) {
                                currentDirectory = selected;
                              }
                            }
                          });
                          _checkForDuplicates();
                        },
                      ),
                    ),
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
                child: Builder(
                  builder: (context) {
                    final bool isAnilistLocked = widget.lockAnilist || (widget.requireLocalFirst && selectedLocalPath == null);
                    return MouseRegion(
                      cursor: isAnilistLocked ? SystemMouseCursors.forbidden : MouseCursor.defer,
                      opaque: isAnilistLocked,
                      hitTestBehavior: !isAnilistLocked ? HitTestBehavior.opaque : HitTestBehavior.translucent,
                      child: AbsorbPointer(
                        absorbing: isAnilistLocked,
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
                    );
                  },
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
            if (!widget.startInAddMode) ...[
              Button(
                onPressed: switchToViewMode,
                child: Text('Back'),
              ),
              SizedBox(width: 8),
            ] else ...[
              Button(
                onPressed: widget.onCancel,
                child: Text('Cancel'),
              ),
              SizedBox(width: 8),
            ],
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
                        : ButtonStyle(
                            backgroundColor: ButtonState.all(Manager.dominantOrAccentColor),
                            foregroundColor: ButtonState.all(getTextColor(Manager.dominantOrAccentColor)),
                          ),
                onPressed: (selectedLocalPath != null && selectedAnilistId != null && !_isExactDuplicate)
                    ? () {
                        if (_isExactDuplicate) {
                          snackBar('This exact mapping already exists', severity: InfoBarSeverity.warning);
                          return;
                        }

                        if (_hasDuplicateWarning) {
                          // Show warning dialog
                          showSimpleManagedDialog(
                            context,
                            id: 'anilist:link-warning',
                            title: 'Warning: Potential Duplicate Link',
                            builder: (context) => Column(
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
                            negativeButtonText: 'Cancel',
                            positiveButtonText: 'Create Link Anyway',
                            isPositiveButtonPrimary: true,
                            onPositive: () {
                              setState(() {
                                mappings.add(AnilistMapping(
                                  localPath: selectedLocalPath!,
                                  anilistId: selectedAnilistId!,
                                  title: selectedTitle,
                                ));
                                switchToViewMode();
                              });
                            },
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
                    Text('Add Link', style: Manager.bodyStyle),
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

  String _getDisplayPath(PathString path) {
    final seriesPath = widget.series.path;
    if (path == seriesPath) return '(Main Series Folder)';
    if (path.path.startsWith(seriesPath.path)) return path.path.substring(seriesPath.path.length + 1);
    return path.path;
  }

  Widget _buildAnilistSearch() {
    final bool isAnilistLocked = widget.lockAnilist || (widget.requireLocalFirst && selectedLocalPath == null);
    final isSelected = !isAnilistLocked && selectedTitle == null;
    return AnimatedOpacity(
      duration: shortStickyHeaderDuration,
      opacity: !isAnilistLocked ? 1 : 0.5,
      child: Card(
        padding: EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: isSelected ? Manager.dominantOrAccentColor.withOpacity(0.1) : Colors.transparent,
        borderColor: isSelected ? Manager.dominantOrAccentColor.lighter : FluentTheme.of(context).resources.controlStrokeColorDefault,
        child: ValueListenableBuilder<bool>(
          valueListenable: ConnectivityService().isOnlineNotifier,
          builder: (context, isOnline, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: AnilistAvailabilityService().unavailableNotifier,
              builder: (context, isUnavailable, _) {
                if (!isOnline || isUnavailable) return ServiceUnavailableBanner();

                return AnilistSimpleSearchPanel(
                  initialSearch: widget.series.name,
                  initialAnilistId: widget.initialAnilistId,
                  linkService: widget.linkService,
                  series: widget.series,
                  constraints: widget.constraints,
                  skipAutoClose: true,
                  enabled: !isAnilistLocked,
                  onLink: (id, name) async {
                    setState(() {
                      selectedAnilistId = id;
                      selectedTitle = name;
                    });
                    _checkForDuplicates();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color accent(double value) => Colors.grey.lerpWith(Manager.dominantOrAccentColor, value);

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
          margin: EdgeInsets.zero,
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

void linkWithAnilist(
  BuildContext context,
  Series? series,
  Future<void> Function(List<int>) loadData,
  void Function(VoidCallback) setState, {
  bool requireLocalFirst = true,
  PathString? initialLocalPath,
  int? initialAnilistId,
  bool lockLocal = false,
  bool lockAnilist = false,
  bool startInAddMode = false,
  FileExplorerOptions explorerOptions = const FileExplorerOptions(allowFiles: true, allowCurrentFolder: true),
}) async {
  if (series == null) {
    snackBar('Series not found', severity: InfoBarSeverity.error);
    return;
  }

  // Show the dialog
  await showPaddedDialog(
    context,
    navigationItem: DialogNavigationItem(
      id: 'anilist:link-series:${series.path}',
      title: 'Link to Anilist',
      data: series.path,
    ),
    barrierOptions: PaddedBarrierOptions(
      barrierColor: Manager.dominantOrAccentColor.withOpacity(0.5),
      userDismissable: true,
    ),
    closeExistingDialogs: true,
    builder: (ctx, item, options) {
      const boxConstraints = BoxConstraints(maxWidth: 1300, maxHeight: 600);

      return PaddedDialog.simple(
        navigationItem: item,
        barrierOptions: options,
        title: Text('Anilist Links for ${series.displayTitle}', overflow: TextOverflow.ellipsis),
        constraints: boxConstraints,
        content: AnilistLinkMultiDialog(
          item: item,
          series: series,
          linkService: SeriesLinkService(),
          onLink: (_, __) {},
          constraints: boxConstraints,
          requireLocalFirst: requireLocalFirst,
          initialLocalPath: initialLocalPath,
          initialAnilistId: initialAnilistId,
          lockLocal: lockLocal,
          lockAnilist: lockAnilist,
          startInAddMode: startInAddMode,
          explorerOptions: explorerOptions,
          onDialogComplete: (success, mappings) async {
            // if the dialog was closed without a result, do nothing
            if (success == null) {
              // logDebug('Dialog closed without result');
              return;
            }

            // if the dialog was closed with a result, check if it was successful
            if (!success) {
              logErr('Linking failed');
              snackBar('Failed to link with Anilist', severity: InfoBarSeverity.error);
              return;
            }

            // if dialog was closed with a result, and it was successful, update the series mappings
            final library = Provider.of<Library>(context, listen: false);

            // Check if the action should be disabled during indexing
            if (library.lockManager.shouldDisableAction(UserAction.anilistOperations)) {
              snackBar(
                library.lockManager.getDisabledReason(UserAction.anilistOperations),
                severity: InfoBarSeverity.warning,
              );
              return;
            }

            // Calculate the number of new mappings
            final oldMappings = series.anilistMappings;
            List<int> anilistIdsToLoad = [];

            for (final mapping in mappings) {
              bool isNew = !oldMappings.any((m) => m.anilistId == mapping.anilistId && m.localPath == mapping.localPath);
              if (isNew) anilistIdsToLoad.add(mapping.anilistId);
            }

            // Ensure the library gets saved
            await library.updateSeriesMappings(series, mappings);

            // If links were added
            if (anilistIdsToLoad.isNotEmpty) {
              snackBar(
                'Successfully linked ${anilistIdsToLoad.length} ${anilistIdsToLoad.length == 1 ? 'new item' : 'new items'} with Anilist',
                severity: InfoBarSeverity.success,
              );
            } else if (mappings.length < oldMappings.length) {
              // If links were removed
              final removedCount = oldMappings.length - mappings.length;
              snackBar(
                'Removed $removedCount ${removedCount == 1 ? 'link' : 'links'} from Anilist',
                severity: InfoBarSeverity.success,
              );
            } else {
              // No changes in link count but mappings might have been updated
              snackBar(
                'Anilist links updated successfully',
                severity: InfoBarSeverity.success,
              );
            }

            closeDialog();

            // Adding a mapping can introduce folder-only targets (for example, with 0 episodes)
            // Force a scan reload so collections are rebuilt immediately
            if (anilistIdsToLoad.isNotEmpty) await library.reloadLibrary(force: true, showSnackBar: false);

            // Load Anilist data
            if (anilistIdsToLoad.isNotEmpty) await loadData(anilistIdsToLoad);

            // Update the series with the new mappings
            final newColor = await series.effectivePrimaryColor();
            Manager.currentDominantColor = newColor;
            Manager.seriesDominantColor = newColor;
            Manager.setState();
          },
        ),
      );
    },
  );
}
