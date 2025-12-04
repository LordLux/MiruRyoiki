// ignore_for_file: invalid_use_of_protected_member

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:glossy/glossy.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../enums.dart';
import '../../manager.dart';
import '../../models/anilist/user_data.dart';
import '../../models/series.dart';
import '../../services/anilist/provider/anilist_provider.dart';
import '../../services/anilist/queries/anilist_service.dart';
import '../../services/navigation/dialogs.dart';
import '../../services/navigation/shortcuts.dart';
import '../../utils/screen.dart';
import '../../utils/time.dart';
import '../animated_order_tile.dart';
import '../buttons/wrapper.dart';
import '../frosted_noise.dart';
import '../tooltip_wrapper.dart';

final GlobalKey<ListsContentState> listsContentKey = GlobalKey<ListsContentState>();

class ListsDialog extends ManagedDialog {
  final Offset? anchorPosition;
  final Size? anchorSize;

  ListsDialog({
    super.key,
    required super.popContext,
    required LibraryView currentView,
    required List<String> customListOrder,
    required Set<String> hiddenLists,
    required Map<String, List<Series>>? groupedDataCache,
    required Function(String) onScrollToList,
    required VoidCallback onInvalidateSortCache,
    required VoidCallback onSaveUserPreferences,
    required Function(Set<String>) onHiddenListsChanged,
    required Function(List<String>) onCustomListOrderChanged,
    this.anchorPosition,
    this.anchorSize,
  }) : super(
          title: null, // Remove the static title
          constraints: BoxConstraints(
            maxWidth: 250,
            maxHeight: Manager.settings.listsDialogHeight,
          ),
          contentBuilder: (context, constraints) => _ListsContent(
            key: listsContentKey,
            constraints: constraints,
            currentView: currentView,
            customListOrder: customListOrder,
            hiddenLists: hiddenLists,
            groupedDataCache: groupedDataCache,
            onScrollToList: onScrollToList,
            onInvalidateSortCache: onInvalidateSortCache,
            onSaveUserPreferences: onSaveUserPreferences,
            onHiddenListsChanged: onHiddenListsChanged,
            onCustomListOrderChanged: onCustomListOrderChanged,
          ),
          alignment: Alignment.topRight,
        );

  @override
  State<ManagedDialog> createState() => _ListsDialogState();
}

class _ListsDialogState extends ListsManagedDialogState {
  @override
  void initState() {
    super.initState();
    Manager.canPopDialog = true;
  }
}

class _ListsContent extends StatefulWidget {
  final BoxConstraints constraints;
  final LibraryView currentView;
  final List<String> customListOrder;
  final Set<String> hiddenLists;
  final Map<String, List<Series>>? groupedDataCache;
  final Function(String) onScrollToList;
  final VoidCallback onInvalidateSortCache;
  final VoidCallback onSaveUserPreferences;
  final Function(Set<String>) onHiddenListsChanged;
  final Function(List<String>) onCustomListOrderChanged;

  const _ListsContent({
    super.key,
    required this.constraints,
    required this.currentView,
    required this.customListOrder,
    required this.hiddenLists,
    required this.groupedDataCache,
    required this.onScrollToList,
    required this.onInvalidateSortCache,
    required this.onSaveUserPreferences,
    required this.onHiddenListsChanged,
    required this.onCustomListOrderChanged,
  });

  @override
  ListsContentState createState() => ListsContentState();
}

class ListsContentState extends State<_ListsContent> {
  bool editListsEnabled = false;
  List<String> _previousCustomListOrder = [];
  late List<String> _customListOrder;
  bool _isReordering = false;
  final GlobalKey _columnKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _customListOrder = List.from(widget.customListOrder);
    _updateHeight();
  }

  @override
  void didUpdateWidget(_ListsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hiddenLists != oldWidget.hiddenLists) {
      _updateHeight();
    }
  }

  void _updateHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final renderBox = _columnKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final height = renderBox.size.height;
          context.findAncestorStateOfType<ListsManagedDialogState>()?.resizeDialog(height: height + 40);
        }
      }
    });
  }

  bool _listEquals(List<String> customListOrder, List<String> previousCustomListOrder) {
    if (customListOrder.length != previousCustomListOrder.length) return false;
    for (int i = 0; i < customListOrder.length; i++) if (customListOrder[i] != previousCustomListOrder[i]) return false;
    return true;
  }

  Widget _buildListOrderUI() {
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);

    // Get all list names including standard and custom lists
    final allLists = <String>[];

    // Add standard lists in default order
    for (final listName in AnilistService.statusListNamesApi) {
      if (anilistProvider.userLists.containsKey(listName)) {
        allLists.add(listName);
      }
    }

    // Add custom lists
    for (final entry in anilistProvider.userLists.entries) {
      if (!allLists.contains(entry.key) && entry.key.startsWith('custom_')) {
        allLists.add(entry.key);
      }
    }

    // Add "Unlinked" pseudo-list
    if (widget.currentView == LibraryView.all) allLists.add('__unlinked');

    // If _customListOrder is empty, initialize with default order
    if (_customListOrder.isEmpty) {
      _customListOrder = List.from(allLists);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onCustomListOrderChanged(_customListOrder);
        widget.onSaveUserPreferences();
      });
    } else {
      // Ensure all current lists are present in _customListOrder
      bool changed = false;
      // Add missing lists at their position from allLists (not at the end)
      for (int i = 0; i < allLists.length; i++) {
        final listName = allLists[i];
        if (!_customListOrder.contains(listName)) {
          // Find the best insertion position
          // Look for adjacent lists that exist in _customListOrder
          int insertIndex = _customListOrder.length; // default to end

          // Look backwards in allLists to find a list that exists in _customListOrder
          for (int j = i - 1; j >= 0; j--) {
            final prevListName = allLists[j];
            final prevIndex = _customListOrder.indexOf(prevListName);
            if (prevIndex != -1) {
              // Insert after this list
              insertIndex = prevIndex + 1;
              break;
            }
          }

          _customListOrder.insert(insertIndex, listName);
          changed = true;
        }
      }
      // Remove any lists that no longer exist
      final initialLength = _customListOrder.length;
      _customListOrder.removeWhere((listName) => !allLists.contains(listName));
      if (_customListOrder.length != initialLength) changed = true;

      if (changed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onCustomListOrderChanged(_customListOrder);
          widget.onSaveUserPreferences();
        });
      }
    }

    // Filter out hidden lists when not in edit mode for display purposes
    final displayListOrder = editListsEnabled ? _customListOrder : _customListOrder.where((listName) => !widget.hiddenLists.contains(listName)).toList();

    final double childHeight = 40;

    return SizedBox(
      height: displayListOrder.length * childHeight,
      child: ValueListenableBuilder(
        valueListenable: KeyboardState.ctrlPressedNotifier,
        builder: (context, isCtrlPressed, _) {
          // Non-reorderable view when editing is disabled
          if (!editListsEnabled) {
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayListOrder.length,
              prototypeItem: SizedBox(height: childHeight),
              itemBuilder: (context, index) {
                final listName = displayListOrder[index];
                final displayName = StatusStatistic.getDisplayName(listName);

                // Check if list is empty by checking grouped data cache
                final isEmpty = widget.groupedDataCache != null && (widget.groupedDataCache![displayName]?.isEmpty ?? true);

                return AnimatedReorderableTile(
                  key: ValueKey(listName),
                  listName: listName,
                  displayName: displayName,
                  onPressed: (i) => widget.onScrollToList(displayName),
                  index: index,
                  selected: false,
                  isReordering: false,
                  reorderable: false,
                  isEmpty: isEmpty,
                );
              },
            );
          }

          // Reorderable view when editing is enabled
          return ReorderableListView.builder(
            physics: isCtrlPressed ? const NeverScrollableScrollPhysics() : null,
            itemCount: displayListOrder.length,
            buildDefaultDragHandles: false,
            clipBehavior: Clip.none,
            proxyDecorator: (child, index, animation) {
              final listName = displayListOrder[index];
              final displayName = StatusStatistic.getDisplayName(listName);
              final isHidden = widget.hiddenLists.contains(listName);
              final isEmpty = widget.groupedDataCache != null && (widget.groupedDataCache![displayName]?.isEmpty ?? true);

              return AnimatedReorderableTile(
                key: ValueKey('${listName}_dragging'),
                listName: listName,
                displayName: displayName,
                index: index,
                selected: true,
                initialAnimation: true,
                isHidden: isHidden,
                isEmpty: isEmpty,
                isReordering: true,
                reorderable: true,
              );
            },
            onReorderStart: (_) => setState(() => _isReordering = true),
            onReorderEnd: (_) => setState(() => _isReordering = false),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                // Get the item being reordered
                final item = displayListOrder[oldIndex];
                final actualOldIndex = _customListOrder.indexOf(item);

                int actualNewIndex;

                // If moving to the very end of the list
                if (newIndex >= displayListOrder.length) {
                  final lastVisibleItem = displayListOrder.last;
                  final lastVisibleIndex = _customListOrder.indexOf(lastVisibleItem);

                  // We want to place it AFTER the last visible item
                  actualNewIndex = lastVisibleIndex + 1;

                  // If the item was before the insertion point, we need to adjust because
                  // removing it will shift indices down
                  if (actualOldIndex < actualNewIndex) {
                    actualNewIndex -= 1;
                  }
                } else {
                  // Moving to a specific position (before an item)
                  final targetItem = displayListOrder[newIndex];
                  final targetIndex = _customListOrder.indexOf(targetItem);

                  // We want to place it BEFORE the target item
                  actualNewIndex = targetIndex;

                  // If the item was before the insertion point, we need to adjust
                  if (actualOldIndex < actualNewIndex) {
                    actualNewIndex -= 1;
                  }
                }

                _customListOrder.removeAt(actualOldIndex);
                _customListOrder.insert(actualNewIndex, item);
                widget.onCustomListOrderChanged(_customListOrder);
                widget.onInvalidateSortCache();
                widget.onSaveUserPreferences();
                _updateHeight();
              });
            },
            prototypeItem: SizedBox(height: childHeight),
            itemBuilder: (context, index) {
              final listName = displayListOrder[index];
              final displayName = StatusStatistic.getDisplayName(listName);
              final isHidden = widget.hiddenLists.contains(listName);
              final isEmpty = widget.groupedDataCache != null && (widget.groupedDataCache![displayName]?.isEmpty ?? true);

              return AnimatedReorderableTile(
                key: ValueKey(listName),
                listName: listName,
                displayName: displayName,
                isHidden: isHidden,
                isEmpty: isEmpty,
                trailing: (isHovering) {
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedSwitcher(
                      duration: shortDuration / 2,
                      child: isHovering || isHidden
                          ? TooltipWrapper(
                              tooltip: isHidden ? 'Unhide List' : 'Hide List',
                              child: (_) => IconButton(
                                style: ButtonStyle(
                                  padding: ButtonState.all(EdgeInsets.zero),
                                ),
                                icon: Icon(
                                  isHidden ? mat.Icons.visibility_off : mat.Icons.visibility,
                                  size: 16,
                                  color: isHidden ? Colors.red.withOpacity(.6) : Colors.white.withOpacity(.5),
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (isHidden)
                                      widget.hiddenLists.remove(listName);
                                    else
                                      widget.hiddenLists.add(listName);

                                    widget.onHiddenListsChanged(widget.hiddenLists);
                                  });

                                  widget.onSaveUserPreferences();
                                  nextFrame(() {
                                    widget.onInvalidateSortCache();
                                  });
                                },
                              ),
                            )
                          : null,
                    ),
                  );
                },
                index: index,
                selected: false,
                isReordering: _isReordering,
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isResetDisabled = _listEquals(_customListOrder, _previousCustomListOrder);
    return Align(
      alignment: Alignment.topCenter,
      child: OverflowBox(
        minHeight: 0,
        maxHeight: double.infinity,
        alignment: Alignment.topCenter,
        child: Column(
          key: _columnKey,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
          Row(
            children: [
              Text(
                'Lists',
                style: Manager.smallSubtitleStyle.copyWith(color: Manager.pastelAccentColor),
              ),
              const SizedBox(width: 4),
              Transform.translate(
                offset: const Offset(0, 1.5),
                child: SizedBox(
                  height: 22,
                  width: 22,
                  child: MouseButtonWrapper(
                    tooltipWaitDuration: const Duration(milliseconds: 250),
                    tooltip: editListsEnabled ? 'Save Changes' : 'Edit List Order',
                    child: (_) => IconButton(
                      icon: Icon(editListsEnabled ? FluentIcons.check_mark : FluentIcons.edit, size: 11 * Manager.fontSizeMultiplier, color: Manager.pastelAccentColor),
                      onPressed: () {
                        setState(() {
                          editListsEnabled = !editListsEnabled;
                          if (editListsEnabled) _previousCustomListOrder = List.from(_customListOrder);
                          _updateHeight();
                        });
                      },
                    ),
                  ),
                ),
              ),
              if (editListsEnabled && !isResetDisabled) ...[
                const SizedBox(width: 4),
                Transform.translate(
                  offset: const Offset(0, 1.5),
                  child: SizedBox(
                    height: 22,
                    width: 22,
                    child: MouseButtonWrapper(
                      isButtonDisabled: isResetDisabled,
                      tooltipWaitDuration: const Duration(milliseconds: 250),
                      tooltip: 'Cancel Changes',
                      child: (_) => IconButton(
                        icon: Icon(Symbols.rotate_left, size: 11, color: Manager.pastelAccentColor),
                        onPressed: isResetDisabled //
                            ? null
                            : () {
                                setState(() {
                                  _customListOrder = List.from(_previousCustomListOrder);
                                  widget.onCustomListOrderChanged(_customListOrder);
                                  _updateHeight();
                                });
                              },
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
          VDiv(3),
          _buildListOrderUI(),
        ],
      ),
    ));
  }
}

class ListsManagedDialogState extends State<ManagedDialog> {
  late BoxConstraints _currentConstraints;
  late Alignment alignment;

  @override
  void initState() {
    super.initState();
    _currentConstraints = widget.constraints;
    alignment = widget.alignment;
  }

  // Method to resize the dialog
  void resizeDialog({double? width, double? height, BoxConstraints? constraints}) {
    setState(() {
      if (constraints != null) {
        _currentConstraints = constraints;
      } else {
        _currentConstraints = BoxConstraints(
          minWidth: width ?? _currentConstraints.minWidth,
          maxWidth: width ?? _currentConstraints.maxWidth,
          minHeight: height ?? _currentConstraints.minHeight,
          maxHeight: height ?? _currentConstraints.maxHeight,
        );
      }
    });

    if (height != null) Manager.settings.listsDialogHeight = height;
  }

  /// Position the dialog on screen
  void positionDialog(Alignment alignment) => setState(() => this.alignment = alignment);

  @override
  Widget build(BuildContext context) {
    double? top;
    double? left;

    if (widget is ListsDialog) {
      final dialog = widget as ListsDialog;
      if (dialog.anchorPosition != null && dialog.anchorSize != null) {
        top = dialog.anchorPosition!.dy + dialog.anchorSize!.height - 50;
        left = dialog.anchorPosition!.dx + (dialog.anchorSize!.width / 2) - (_currentConstraints.maxWidth / 2);
      }
    }

    return Stack(
      alignment: alignment,
      children: [
        Positioned(
          top: top ?? 142,
          left: left,
          right: left == null ? 450 : null,
          child: Padding(
            padding: const EdgeInsets.only(top: ScreenUtils.kTitleBarHeight + 16, right: 16, bottom: 16),
            child: GlossyContainer(
              width: _currentConstraints.maxWidth,
              height: _currentConstraints.maxHeight,
              color: Colors.black,
              opacity: 0.1,
              strengthX: 20,
              strengthY: 20,
              blendMode: BlendMode.src,
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  FrostedNoise(
                    intensity: 0.7,
                    child: ContentDialog(
                      style: ContentDialogThemeData(decoration: BoxDecoration(color: Colors.transparent)),
                      title: widget.title,
                      content: mat.Material(
                        color: Colors.transparent,
                        child: Container(
                          constraints: _currentConstraints,
                          child: widget.contentBuilder != null ? widget.contentBuilder!(context, _currentConstraints) : null,
                        ),
                      ),
                      // ignore: prefer_null_aware_operators
                      actions: widget.actions != null ? widget.actions!.call(widget.popContext) : null,
                      constraints: _currentConstraints,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void popDialog() => closeDialog(widget.popContext);
}
