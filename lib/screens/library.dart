// ignore_for_file: use_build_context_synchronously

import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as mat;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/screens/settings.dart';
import 'package:miruryoiki/utils/color.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sticky_headers/sticky_headers.dart';
import '../widgets/smooth_scroll.dart';

import '../main.dart';
import '../enums.dart';
import '../services/library/library_provider.dart';
import '../services/library/scanner/scanner_service.dart';
import '../models/series.dart';
import '../services/navigation/dialogs2.dart';
import '../services/navigation/navigation.dart';
import '../services/navigation/intents.dart';
import '../services/navigation/shortcuts.dart';
import '../utils/logging.dart';
import '../utils/path.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import '../viewmodels/library_screen_viewmodel.dart';
import '../widgets/acrylic_header.dart';
import '../widgets/buttons/button.dart';
import '../widgets/buttons/wrapper.dart';
import '../widgets/dialogs/genres_filter.dart';
import '../widgets/dialogs/show_dialog.dart';
import '../widgets/dialogs/splash/progress.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/page_template.dart';
import '../widgets/cards/series_card.dart';
import '../widgets/series_list_tile.dart';
import '../widgets/styled_scrollbar.dart';
import '../widgets/dialogs/lists.dart';
import '../widgets/viewtype_switcher.dart';

class LibraryScreen extends StatefulWidget {
  final ScrollController scrollController;
  final Function(PathString) onSeriesSelected;

  const LibraryScreen({
    super.key,
    required this.onSeriesSelected,
    required this.scrollController,
  });

  @override
  State<LibraryScreen> createState() => LibraryScreenState();
}

class LibraryScreenState extends State<LibraryScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  bool get wantKeepAlive => true;

  final GlobalKey firstCardKey = GlobalKey();
  final GlobalKey _filterButtonKey = GlobalKey();
  final GlobalKey _listButtonKey = GlobalKey();
  bool _isSelectingFolder = false;

  // Global keys for each group to enable scrolling
  final Map<String, GlobalKey> _groupKeys = {};

  bool _filtersOpen = false;
  bool _listsOpen = false;

  LibraryScreenViewModel get _vm => context.read<LibraryScreenViewModel>();

  bool get isCustomSort => _vm.isCustomSort;

  late Color _textColor;
  late Color _selectedTextColor;

  void _loadColors() {
    _textColor = Colors.white;
    _selectedTextColor = getTextColor(Manager.currentDominantColor ?? Manager.accentColor);
  }

  Color getViewTypeColor(bool isSelected) => isSelected ? _selectedTextColor : _textColor;

  final ScrollController _controller = ScrollController(
    debugLabel: 'LibraryScreen Scroll Controller',
    keepScrollOffset: true,
  );

  void measureCardSize() {
    nextFrame(() {
      final RenderBox? box = firstCardKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        ScreenUtils.libraryCardSize = Size(box.size.width, box.size.width / ScreenUtils.kDefaultAspectRatio);
      }
    });
  }

  /// Clean up group scroll keys for groups that no longer exist in [groupedData]
  void _syncGroupKeys(Map<String, List<Series>>? groupedData) {
    if (groupedData == null) {
      _groupKeys.clear();
      return;
    }

    final currentGroups = groupedData.keys.toSet();
    _groupKeys.removeWhere((groupName, key) => !currentGroups.contains(groupName));
  }

  void focusSearchBar() {
    _searchFocusNode.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    _loadColors();
    NavigationManager.registerActiveScrollController('library', _controller);
    NavigationManager.restoreScrollOffset('library', _controller);

    // Sync the search field with any query persisting in the app-scoped VM
    nextFrame(() => _searchController.text = _vm.searchQuery);

    _searchFocusNode.onKeyEvent = (node, event) {
      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
        if (_vm.searchQuery.isNotEmpty) {
          _searchController.clear();
          _vm.clearSearch();
          return KeyEventResult.handled;
        } else {
          _searchFocusNode.unfocus();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    };
  }

  @override
  void activate() {
    super.activate();
    // Reregister and restore on GlobalKey reparent
    NavigationManager.registerActiveScrollController('library', _controller);
    NavigationManager.restoreScrollOffset('library', _controller);
  }

  void _selectLibraryFolder() async {
    setState(() => _isSelectingFolder = true);

    context.read<NavigationManager>().pushPane(NavigationManager.SettingsPane);

    await SettingsScreenState.setLibraryPath(context);

    setState(() => _isSelectingFolder = false);
  }

  void _navigateToSeries(Series series) {
    widget.onSeriesSelected(series.path);
  }

  void _toggleReorderMode() => _vm.toggleReorderMode();

  void _scrollToList(String targetListName) {
    final groupedDataCache = _vm.groupedDataCache;
    if (groupedDataCache == null) return;

    // Find the index of the target list in the sorted display order
    final displayOrder = _vm.groupDisplayOrder(groupedDataCache);

    // Find the index of the target list in the display order
    final targetIndex = displayOrder.indexOf(targetListName);
    if (targetIndex == -1) {
      logTrace('Target list $targetListName not found in grouped data');
      return;
    }

    // Try to use the group key first (for already-rendered widgets)
    final groupKey = _groupKeys[targetListName];
    if (groupKey?.currentContext != null) {
      Scrollable.ensureVisible(
        groupKey!.currentContext!,
        duration: shortDuration,
        curve: Curves.easeInOut,
      );
      logTrace('Scrolling to list $targetListName using GlobalKey');
    } else {
      // Fallback: two-step approach for better accuracy
      _scrollToListWithRendering(targetIndex, targetListName);
    }
  }

  void _scrollToListWithRendering(int targetIndex, String targetListName) async {
    // Step 1: Scroll to approximate position to trigger rendering
    final duration = await _scrollToListByIndex(targetIndex);
    if (duration != null) {
      // Step 2: Wait a bit for rendering, then try precise scrolling
      await Future.delayed(Duration(milliseconds: duration));
    }

    // Check if the widget is now rendered
    final groupKey = _groupKeys[targetListName];
    if (groupKey?.currentContext != null) {
      Scrollable.ensureVisible(
        groupKey!.currentContext!,
        duration: Duration(milliseconds: duration ?? 200), // Shorter duration for fine adjustment
        curve: Curves.easeInOut,
      );
      logTrace('Fine-tuned scroll to $targetListName using GlobalKey after rendering');
    } else {
      logTrace('Widget still not rendered for $targetListName, using index calculation only');
    }
  }

  Future<int?> _scrollToListByIndex(int targetIndex) async {
    final scrollController = _controller;
    if (!scrollController.hasClients) return null;

    final currentPosition = scrollController.position.pixels;

    // Estimate the height of each group section
    // This is an approximation - you may need to adjust based on your actual content
    const double estimatedHeaderHeight = 53.0; // Height of sticky header
    const double estimatedGroupSpacing = ScreenUtils.kLibraryHeaderHeaderSeparatorHeight; // Spacing between groups

    // Calculate estimated position
    double estimatedOffset = 0.0;

    final groupedDataCache = _vm.groupedDataCache;
    if (groupedDataCache != null) {
      final displayOrder = groupedDataCache.keys.toList();

      for (int i = 0; i < targetIndex && i < displayOrder.length; i++) {
        final groupName = displayOrder[i];
        final seriesInGroup = groupedDataCache[groupName] ?? [];

        // Add header height
        estimatedOffset += estimatedHeaderHeight;

        // Add content height (estimate based on number of series and grid layout)
        if (seriesInGroup.isNotEmpty) {
          final rows = ScreenUtils.mainAxisCount(seriesInGroup.length);
          final cardHeight = ScreenUtils.libraryCardSize.height;
          final contentHeight = rows * cardHeight + (rows + 1) * 8.0 + ScreenUtils.kLibraryHeaderContentSeparatorHeight;
          estimatedOffset += contentHeight;
        }

        // Add spacing between groups (add spacing after each group except the last one we're calculating)
        if (i < targetIndex - 1) {
          estimatedOffset += estimatedGroupSpacing;
        }
      }
    }

    final differenceInPosition = (estimatedOffset - currentPosition).abs();
    final duration = Duration(milliseconds: 10 * math.min(differenceInPosition ~/ 10, 20));

    // Animate to the estimated position
    scrollController.animateTo(
      estimatedOffset.clamp(0.0, scrollController.position.maxScrollExtent),
      duration: duration, // Cap duration for large jumps
      curve: Curves.easeInOut,
    );

    return duration.inMilliseconds;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // for AutomaticKeepAliveClientMixin

    context.watch<LibraryScreenViewModel>(); // rebuild on view/sort/filter/cache changes
    final library = Provider.of<Library>(context);
    final scannerService = Provider.of<LibraryScannerService>(context);

    final child = library.libraryPath == null
        ? _buildLibrarySelector()
        : MiruRyoikiTemplatePage(
            headerWidget: _buildHeader(library, scannerService),
            content: _buildLibraryView(library, scannerService),
            headerMaxHeight: ScreenUtils.kMinHeaderHeight,
            headerMinHeight: ScreenUtils.kMinHeaderHeight,
            noHeaderBanner: true,
            scrollableContent: false,
            enableContentExtraHeaderPadding: true,
            contentRightPadding: 4.0,
            contentExtraHeaderPadding: 8.0,
            hideInfoBar: true,
          );

    // Add keyboard shortcut for focusing search bar (Ctrl+F)
    return Actions(
      actions: {
        OpenSearchIntent: CallbackAction<OpenSearchIntent>(
          onInvoke: (_) {
            focusSearchBar();
            return null;
          },
        ),
      },
      child: child,
    );
  }

  void _onViewTypeChanged(ViewType viewType) {
    _vm.setViewType(viewType);
  }

  HeaderWidget _buildHeader(Library library, LibraryScannerService scannerService) {
    return HeaderWidget(
      contentRightPadding: -4,
      title: (_, __) => ValueListenableBuilder(
        valueListenable: KeyboardState.zoomReleaseNotifier,
        builder: (context, _, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Media Library',
              style: Manager.titleLargeStyle.copyWith(
                fontSize: 32 * Manager.fontSizeMultiplier,
                fontWeight: FontWeight.bold,
              ),
            ),
            SelectableRegion(
              selectionControls: mat.DesktopTextSelectionControls(),
              child: MouseButtonWrapper(
                cursor: SystemMouseCursors.click,
                child: (_) => GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Path: ${library.libraryPath}',
                    style: Manager.bodyStyle.copyWith(
                      fontSize: 14 * Manager.fontSizeMultiplier,
                      color: Colors.white.withOpacity(.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      titleLeftAligned: true,
      headerPadding: EdgeInsets.zero,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ViewTypeSwitcher(
                    currentViewType: _vm.viewType,
                    textColor: _textColor,
                    selectedTextColor: _selectedTextColor,
                    onViewTypeChanged: _onViewTypeChanged,
                  ),
                  HDiv(8),
                  SizedBox(
                    height: ScreenUtils.kDefaultButtonSize + 1,
                    child: StandardButton.iconLabel(
                      tooltip: 'Filter and Sort Options',
                      label: Text("Filter", style: Manager.subtitleStyle.copyWith(fontSize: 12)),
                      isFilled: _vm.isGettingFiltered,
                      backgroundColor: _vm.isGettingFiltered ? (Manager.currentDominantAccentColor ?? Manager.accentColor).light : Colors.white.withOpacity(0.1),
                      key: _filterButtonKey,
                      icon: Icon(_filtersOpen ? mat.Icons.filter_alt : mat.Icons.filter_alt_outlined, size: 16, color: getViewTypeColor(_vm.isGettingFiltered)),
                      onPressed: _filtersOpen ? null : _showFilterDialog,
                    ),
                  ),
                  HDiv(8),
                  SizedBox(
                    height: ScreenUtils.kDefaultButtonSize + 1,
                    child: StandardButton.iconLabel(
                      tooltip: 'Manage Lists',
                      label: Text("Lists", style: Manager.subtitleStyle.copyWith(fontSize: 12)),
                      backgroundColor: Colors.white.withOpacity(0.1),
                      key: _listButtonKey,
                      icon: Icon(mat.Icons.list, size: 16, color: getViewTypeColor(_listsOpen)),
                      onPressed: _listsOpen ? null : _showListDialog,
                    ),
                  ),
                  if (isCustomSort) ...[
                    HDiv(8),
                    SizedBox(
                      height: ScreenUtils.kDefaultButtonSize + 1,
                      child: StandardButton.iconLabel(
                        tooltip: _vm.isReorderMode ? 'Exit Reorder Mode' : 'Reorder Series',
                        label: Text(_vm.isReorderMode ? "Done" : "Reorder", style: Manager.subtitleStyle.copyWith(fontSize: 12)),
                        isFilled: _vm.isReorderMode,
                        backgroundColor: _vm.isReorderMode ? (Manager.currentDominantAccentColor ?? Manager.accentColor).light : Colors.white.withOpacity(0.1),
                        icon: Icon(
                          _vm.isReorderMode ? mat.Icons.check : mat.Icons.swap_vert,
                          size: 16,
                          color: getViewTypeColor(_vm.isReorderMode),
                        ),
                        onPressed: _toggleReorderMode,
                      ),
                    ),
                  ],
                ],
              ),
              Flexible(
                child: SizedBox(
                  width: 300,
                  height: ScreenUtils.kDefaultButtonSize + 1,
                  child: mat.Theme(
                    data: mat.Theme.of(context).copyWith(
                      textSelectionTheme: TextSelectionThemeData(
                        selectionColor: (Manager.currentDominantColor ?? Manager.accentColor).withOpacity(0.3),
                        selectionHandleColor: Manager.currentDominantColor ?? Manager.accentColor,
                      ),
                    ),
                    child: TextBox(
                      controller: _searchController,
                      cursorOpacityAnimates: true,
                      cursorColor: Manager.pastelAccentColor,
                      padding: EdgeInsetsDirectional.fromSTEB(10, 0, 6, 0),
                      style: Manager.bodyStyle.copyWith(height: 0),
                      placeholder: 'Search in your library...',
                      focusNode: _searchFocusNode,
                      enableInteractiveSelection: true,
                      prefix: Padding(
                        padding: EdgeInsets.only(left: 9, top: 9, bottom: 9),
                        child: MouseButtonWrapper(
                          child: (_) => Transform.translate(offset: Offset(0, 1), child: Icon(mat.Icons.search, size: 16)),
                        ),
                      ),
                      suffix: _vm.searchQuery.isNotEmpty
                          ? Padding(
                              padding: EdgeInsets.all(3).copyWith(right: 2.3),
                              child: MouseButtonWrapper(
                                tooltip: 'Clear search',
                                child: (_) => SizedBox(
                                  height: 30,
                                  child: StandardButton.icon(
                                    icon: Icon(mat.Icons.clear, size: 16),
                                    onPressed: () {
                                      _searchController.clear();
                                      _vm.clearSearch();
                                    },
                                  ),
                                ),
                              ),
                            )
                          : null,
                      decoration: ButtonState.all(
                        BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _searchController.text.isNotEmpty //
                                ? (Manager.currentDominantAccentColor ?? Manager.accentColor).light
                                : Colors.white.withOpacity(0.1),
                            width: _searchController.text.isNotEmpty ? 1.5 : 1,
                          ),
                        ),
                      ),
                      highlightColor: Colors.transparent,
                      unfocusedColor: Colors.transparent,
                      onChanged: (value) => _vm.setSearchQuery(value),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLibrarySelector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FluentIcons.folder_open, size: 48, color: Colors.purple),
          VDiv(16),
          const Text('Select your media library folder to get started', style: TextStyle(fontSize: 16)),
          VDiv(24),
          MouseButtonWrapper(
            isLoading: _isSelectingFolder,
            child: (_) => Button(
              style: ButtonStyle(padding: ButtonState.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 8))),
              onPressed: _selectLibraryFolder,
              child: const Text('Select Library Folder'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryView(Library library, LibraryScannerService scannerService) {
    // All cache/filter/sort/search logic lives in the ViewModel
    final (seriesToDisplay, groupedData) = _vm.displayData();

    // Clean up group scroll keys for groups that no longer exist
    _syncGroupKeys(groupedData);

    if (seriesToDisplay.isEmpty) {
      // Different messages for search vs. no series
      if (_vm.searchQuery.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                mat.Icons.search_off,
                size: 48,
                color: Manager.accentColor,
              ),
              VDiv(16),
              Text('No series found matching "${_vm.searchQuery}"', style: Manager.bodyStyle),
              VDiv(8),
              Text('Try adjusting your search terms', style: Manager.bodyStyle.copyWith(color: Colors.white.withOpacity(0.6))),
              VDiv(16),
              MouseButtonWrapper(
                child: (_) => Button(
                  onPressed: () {
                    _searchController.clear();
                    _vm.clearSearch();
                    _searchFocusNode.requestFocus();
                  },
                  child: const Text('Clear Search'),
                ),
              ),
            ],
          ),
        );
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FluentIcons.folder_open,
              size: 48,
              color: Manager.accentColor,
            ),
            VDiv(16),
            Text(_vm.currentView == LibraryView.linked ? 'No linked series found. Link your series with Anilist first.' : 'No series found in your library'),
            VDiv(16),
            MouseButtonWrapper(
              isLoading: _isSelectingFolder,
              child: (_) => Button(
                onPressed: _selectLibraryFolder,
                child: const Text('Change Library Folder'),
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      // Only hide library content if it's an initial scan (first time or new path)
      // For normal scans show the library with disabled actions
      final bool hideLibrary = scannerService.isIndexing && scannerService.isInitialScan;

      // We use previousGridColumnCount to detect if we are transitioning
      if (previousGridColumnCount.value == null) {
        ScreenUtils.libraryContentWidthWithoutPadding = constraints.maxWidth; // account for right padding
        // log('updated contentWidth: ${ScreenUtils.libraryContentWidthWithoutPadding}');
      }

      return Stack(
        children: [
          // CONTENT
          IgnorePointer(
            ignoring: hideLibrary,
            child: Opacity(
              opacity: hideLibrary ? 0 : 1,
              child: _buildSeriesGrid(seriesToDisplay, constraints.maxWidth, groupedData: groupedData, shimmer: false),
            ),
          ),
          // Shimmer only on initial scan
          if (hideLibrary) ...[
            Positioned.fill(child: _buildSeriesGrid(seriesToDisplay, constraints.maxWidth, groupedData: groupedData, shimmer: true)),
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Please wait while the Library is being indexed...'),
                    VDiv(16),
                    LibraryScanProgressIndicator(showText: false),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildSeriesGrid(List<Series> series, double maxWidth, {Map<String, List<Series>>? groupedData, bool shimmer = false}) {
    final Widget content = (_vm.viewType == ViewType.grid)
        // Grid view
        ? _buildGridView(series, maxWidth, groupedData: groupedData, shimmer: shimmer)
        // List view
        : Container(child: _buildListView(series, maxWidth, groupedData: groupedData, shimmer: shimmer));

    return content;
  }

  Widget _buildGridView(List<Series> series, double maxWidth, {Map<String, List<Series>>? groupedData, bool shimmer = false}) {
    Widget episodesGrid(List list, ScrollController? controller, ScrollPhysics? physics, bool includePadding, {bool allowMeasurement = false, bool shimmer = false, bool isNestedInScrollable = false, String? groupName}) {
      assert(shimmer || (controller != null && physics != null));
      return ValueListenableBuilder(
        valueListenable: previousGridColumnCount,
        builder: (context, columns, __) {
          final List<Widget> children = List.generate(list.length, (index) {
            if (shimmer)
              return ClipRRect(
                borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              );

            final Series series_ = (list as List<Series>)[index % list.length];

            // Measure the first card to determine the number of columns
            if (index == 0) measureCardSize();

            Widget card = SeriesCard(
              key: (index == 0 && allowMeasurement) ? firstCardKey : ValueKey('${series_.path}:${series_.effectivePosterPath ?? 'none'}'),
              series: series_,
              onTap: () => _navigateToSeries(series_),
            );

            if (_vm.isReorderMode && groupName != null) card = _buildDraggableGridItem(card, index, list, groupName);

            return card;
          });

          return ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(overscroll: false, scrollbars: false),
            child: GridView(
              padding: includePadding ? EdgeInsets.only(bottom: 8) : EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns ?? ScreenUtils.crossAxisCount(maxWidth),
                childAspectRatio: ScreenUtils.kDefaultAspectRatio,
                crossAxisSpacing: ScreenUtils.cardPadding,
                mainAxisSpacing: ScreenUtils.cardPadding,
              ),
              controller: isNestedInScrollable ? null : controller,
              physics: (isNestedInScrollable || shimmer) ? const NeverScrollableScrollPhysics() : physics,
              shrinkWrap: isNestedInScrollable, // Only shrinkWrap when nested
              children: children,
            ),
          );
        },
      );
    }

    // Shimmer view (loading)
    if (shimmer) //
      return LayoutBuilder(builder: (context, constraints) {
        final mockList = List.generate(50, (index) => index);
        return SizedBox(
          height: math.min(constraints.maxHeight, ScreenUtils.height - ScreenUtils.kMinHeaderHeight - ScreenUtils.kTitleBarHeight - 32),
          child: Shimmer.fromColors(
            baseColor: Colors.white.withOpacity(0.15),
            highlightColor: Colors.white,
            child: episodesGrid(mockList, null, null, true, allowMeasurement: false, shimmer: true),
          ),
        );
      });

    // Grouped View
    if (_vm.groupBy != GroupBy.none && groupedData != null && _vm.showGrouped) //
      return _buildGroupedViewFromCache(groupedData, maxWidth, episodesGrid);

    // Ungrouped view
    final scrollContent = SmoothScroll(
      controller: shimmer ? null : _controller,
      stopScroll: KeyboardState.ctrlPressedNotifier,
      enableSmoothScroll: Manager.animationsEnabled,
      builder: (context, controller, physics) {
        return ValueListenableBuilder(
          valueListenable: KeyboardState.ctrlPressedNotifier,
          builder: (context, isCtrlPressed, _) {
            return ValueListenableBuilder(
              valueListenable: previousGridColumnCount,
              builder: (context, columns, __) {
                return GridView.builder(
                  controller: controller,
                  physics: physics,
                  padding: const EdgeInsets.only(bottom: 8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns ?? ScreenUtils.crossAxisCount(maxWidth),
                    childAspectRatio: ScreenUtils.kDefaultAspectRatio,
                    crossAxisSpacing: ScreenUtils.cardPadding,
                    mainAxisSpacing: ScreenUtils.cardPadding,
                  ),
                  itemCount: series.length,
                  itemBuilder: (context, index) {
                    final serieItem = series[index];
                    return SeriesCard(
                      key: (index == 0) ? firstCardKey : ValueKey('${serieItem.path}:${serieItem.effectivePosterPath ?? 'none'}'),
                      series: serieItem,
                      onTap: () => _navigateToSeries(serieItem),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );

    // Add Scrollbar for non-shimmer content
    if (shimmer) return scrollContent;

    return buildStyledScrollbar(scrollContent, _controller);
  }

  int? _dragFromIndex;
  int? _dragOverIndex;
  String? _dragFromGroup;

  /// Defers setState to avoid mutations during layout (drag lifecycle callbacks can fire during layout)
  void _deferSetState(VoidCallback fn) {
    nextFrame(() {
      if (mounted) setState(fn);
    });
  }

  Widget _buildDraggableGridItem(Widget child, int index, List<Series> seriesList, String groupName) {
    final series = seriesList[index];

    // Build a separate card for the feedback overlay to avoid duplicate GlobalKey errors
    final feedbackCard = SeriesCard(
      key: ValueKey('feedback_${series.path}'),
      series: series,
      onTap: () {},
    );

    return DragTarget<(int, String)>(
      onWillAcceptWithDetails: (details) {
        // Only accept drops from the same group
        if (details.data.$2 != groupName) return false;
        if (details.data.$1 != index) _deferSetState(() => _dragOverIndex = index);

        return details.data.$1 != index;
      },
      onLeave: (_) {
        if (_dragOverIndex == index) _deferSetState(() => _dragOverIndex = null);
      },
      onAcceptWithDetails: (details) {
        final oldIndex = details.data.$1;
        _deferSetState(() {
          _dragOverIndex = null;
          _dragFromIndex = null;
          _dragFromGroup = null;
        });
        _vm.reorderSeriesInGroup(groupName, oldIndex, oldIndex < index ? index + 1 : index);
      },
      builder: (context, candidateData, rejectedData) {
        final isOver = _dragOverIndex == index && _dragFromIndex != index && _dragFromGroup == groupName;
        final isDragging = _dragFromIndex != null && _dragFromGroup != null;
        return Draggable<(int, String)>(
          data: (index, groupName),
          onDragStarted: () => _deferSetState(() {
            _dragFromIndex = index;
            _dragFromGroup = groupName;
          }),
          onDragEnd: (_) => _deferSetState(() {
            _dragFromIndex = null;
            _dragOverIndex = null;
            _dragFromGroup = null;
          }),
          onDraggableCanceled: (_, __) => _deferSetState(() {
            _dragFromIndex = null;
            _dragOverIndex = null;
            _dragFromGroup = null;
          }),
          // The item being dragged — uses a separate SeriesCard to avoid duplicate GlobalKey
          feedback: mat.Material(
            color: Colors.transparent,
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: isDragging ? 0.02 : 0,
              child: SizedBox(
                width: ScreenUtils.libraryCardSize.width - 20,
                height: ScreenUtils.libraryCardSize.height - 20,
                child: Transform.translate(
                  offset: const Offset(10, 10),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: isDragging ? 0.5 : 1,
                    child: feedbackCard,
                  ),
                ),
              ),
            ),
          ),
          // Original position of the dragged item
          childWhenDragging: IgnorePointer(child: Opacity(opacity: 0.25, child: child)),
          // The rest of the items, with visual feedback when another item is dragged over one of them
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
              border: isOver ? Border.all(color: (Manager.currentDominantAccentColor ?? Manager.accentColor).light, width: 2) : null,
            ),
            child: Stack(
              children: [
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: isOver ? 0.01 : 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isOver ? 0.5 : 1,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      scale: isOver ? 0.95 : 1,
                      child: child,
                    ),
                  ),
                ),
                // Reorder index badge
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView(List<Series> series, double maxWidth, {Map<String, List<Series>>? groupedData, bool shimmer = false}) {
    Widget buildListContent(List list, ScrollController? controller, ScrollPhysics? physics, bool includePadding, {String? groupName}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column headers
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Manager.genericGray.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: Manager.genericGray.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 44), // Space for image

                Expanded(
                  child: Text(
                    'Name',
                    style: Manager.bodyStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Manager.bodyStyle.color?.withOpacity(0.8),
                    ),
                  ),
                ),

                SizedBox(
                  width: 100,
                  child: Text(
                    'Progress',
                    style: Manager.bodyStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Manager.bodyStyle.color?.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          // Series list
          Expanded(
            child: shimmer
                // Show shimmer placeholders while loading
                ? _buildShimmerList()
                : (_vm.isReorderMode && groupName != null)
                    // Allow reordering within groups in list view
                    ? mat.ReorderableListView.builder(
                        scrollController: controller,
                        padding: includePadding ? const EdgeInsets.all(12) : EdgeInsets.zero,
                        itemCount: list.length,
                        buildDefaultDragHandles: false,
                        proxyDecorator: (child, index, animation) {
                          return mat.Material(
                            color: Colors.transparent,
                            elevation: 4,
                            child: child,
                          );
                        },
                        onReorder: (oldIndex, newIndex) => _vm.reorderSeriesInGroup(groupName, oldIndex, newIndex),
                        itemBuilder: (context, index) {
                          final series = (list as List<Series>)[index];
                          return Padding(
                            key: ValueKey(series.path.path),
                            padding: EdgeInsets.only(bottom: 2.5, top: index == 0 ? 2.5 : 0),
                            child: Row(
                              children: [
                                mat.ReorderableDragStartListener(
                                  index: index,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.grab,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Icon(mat.Icons.drag_handle, size: 18, color: Colors.white.withOpacity(0.5)),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SeriesListTile(
                                    series: series,
                                    onTap: () => _navigateToSeries(series),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        controller: controller,
                        physics: physics,
                        padding: includePadding ? const EdgeInsets.all(12) : EdgeInsets.zero,
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final series = (list as List<Series>)[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 2.5, top: index == 0 ? 2.5 : 0),
                            child: SeriesListTile(
                              series: series,
                              onTap: () => _navigateToSeries(series),
                            ),
                          );
                        },
                      ),
          ),
        ],
      );
    }

    final scrollContent = SmoothScroll(
      controller: shimmer ? null : _controller,
      stopScroll: KeyboardState.zoomReleaseNotifier,
      enableSmoothScroll: Manager.animationsEnabled,
      builder: (context, controller, physics) {
        return ValueListenableBuilder(
          valueListenable: KeyboardState.zoomReleaseNotifier,
          builder: (context, _, __) {
            // Grouped View with Sticky Headers
            if (groupedData != null && _vm.showGrouped) {
              // Use the custom list order to determine display order
              final displayOrder = _vm.groupDisplayOrder(groupedData);

              return ListView.builder(
                controller: controller,
                physics: shimmer ? const NeverScrollableScrollPhysics() : physics,
                padding: EdgeInsets.zero,
                itemCount: displayOrder.length,
                itemBuilder: (context, index) {
                  final groupName = displayOrder[index];
                  final seriesList = groupedData[groupName] ?? [];
                  final isLastGroup = index == displayOrder.length - 1;

                  if (seriesList.isEmpty) return const SizedBox.shrink();

                  return Padding(
                    padding: EdgeInsets.only(bottom: isLastGroup ? 0 : ScreenUtils.kLibraryHeaderHeaderSeparatorHeight),
                    child: ExpandingStickyHeaderBuilder(
                      useInkWell: false,
                      contentBackgroundColor: Colors.transparent,
                      builder: (BuildContext context, {double stuckAmount = 0.0, bool isHovering = false, bool isExpanded = false}) => AcrylicHeader(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (shimmer) ...[
                              Expanded(
                                child: Container(
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                height: 12,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ],
                            if (!shimmer) ...[
                              Text(groupName, style: Manager.subtitleStyle),
                              Text('${seriesList.length} Series', style: Manager.captionStyle),
                            ],
                          ],
                        ),
                      ),
                      content: Column(
                        children: [
                          // Group content with headers and list
                          Padding(
                            padding: const EdgeInsets.only(top: ScreenUtils.kLibraryHeaderContentSeparatorHeight),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Manager.genericGray.withOpacity(0.2)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SizedBox(
                                height: ScreenUtils.kDefaultListViewItemHeight * seriesList.length + 33 + 2, // +33 for header
                                child: buildListContent(seriesList, null, const NeverScrollableScrollPhysics(), false, groupName: groupName),
                              ),
                            ),
                          ),

                          // Spacing between groups
                          if (index != displayOrder.length - 1) const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            // Ungrouped list view
            return buildListContent(series, controller, physics, true);
          },
        );
      },
    );

    // Add Scrollbar for non-shimmer content
    if (shimmer) return scrollContent;

    return buildStyledScrollbar(scrollContent, _controller);
  }

  Widget _buildShimmerList() {
    return ScrollConfiguration(
      behavior: ScrollBehavior().copyWith(overscroll: false, scrollbars: false, physics: const NeverScrollableScrollPhysics(), dragDevices: {}),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 12,
        itemBuilder: (context, index) {
          return Container(
            height: 53.7,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Manager.genericGray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Manager.genericGray.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 80,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Manager.genericGray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build grouped view using cached grouped data with sticky headers
  Widget _buildGroupedViewFromCache(
    Map<String, List<Series>> groupedData,
    double maxWidth,
    Widget Function(List<Series>, ScrollController, ScrollPhysics, bool, {bool allowMeasurement, bool isNestedInScrollable, String? groupName}) episodesGrid,
  ) {
    // Use the custom list order to determine display order
    final displayOrder = _vm.groupDisplayOrder(groupedData);

    final scrollContent = SmoothScroll(
      controller: _controller,
      stopScroll: KeyboardState.zoomReleaseNotifier,
      enableSmoothScroll: Manager.animationsEnabled,
      builder: (context, controller, physics) {
        return ValueListenableBuilder(
          valueListenable: KeyboardState.zoomReleaseNotifier,
          builder: (context, _, __) {
            return ListView.builder(
              controller: controller,
              padding: EdgeInsets.zero,
              cacheExtent: kDebugMode ? 1000 : 1000,
              physics: physics,
              itemCount: displayOrder.length,
              itemBuilder: (context, index) {
                final groupName = displayOrder[index];
                final seriesInGroup = groupedData[groupName]!;
                final isLastGroup = index == displayOrder.length - 1;

                // Ensure we have a key for this group
                if (!_groupKeys.containsKey(groupName)) _groupKeys[groupName] = GlobalKey();

                return RepaintBoundary(
                  child: Container(
                    key: _groupKeys[groupName],
                    child: ClipRRect(
                      clipBehavior: Clip.antiAlias,
                      borderRadius: const BorderRadius.all(Radius.circular(ScreenUtils.kStatCardBorderRadius)),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLastGroup ? 0 : ScreenUtils.kLibraryHeaderHeaderSeparatorHeight),
                        child: ExpandingStickyHeaderBuilder(
                          contentBackgroundColor: Colors.transparent,
                          contentShape: (open) => RoundedRectangleBorder(),
                          useInkWell: false,
                          builder: (BuildContext context, {double stuckAmount = 0.0, bool isHovering = false, bool isExpanded = false}) => Transform.translate(
                            offset: const Offset(0, -1),
                            child: AcrylicHeader(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(groupName, style: Manager.subtitleStyle),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Transform.translate(offset: const Offset(0, -1.5), child: Text('${seriesInGroup.length} Series', style: Manager.captionStyle)),
                                      const SizedBox(width: 8),
                                      AnimatedRotation(turns: isExpanded ? 0 : .5, duration: shortDuration, child: const Icon(mat.Icons.expand_more)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          content: Padding(
                            padding: const EdgeInsets.only(top: ScreenUtils.kLibraryHeaderContentSeparatorHeight),
                            child: episodesGrid(seriesInGroup, controller, physics, false, allowMeasurement: index == 0, isNestedInScrollable: true, groupName: groupName),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );

    return buildStyledScrollbar(scrollContent, _controller);
  }


  void _showFilterDialog() async {
    if (context.read<NavigationManager>().hasDialog && context.read<NavigationManager>().currentView?.id == "library:lists") {
      closeDialog();
      log('Lists dialog open, closing it and opening filters dialog');
      await Future.delayed(const Duration(milliseconds: 50));
    }

    if (mounted) setState(() => _filtersOpen = true);

    if (!context.mounted) return;

    Offset? anchorPosition;
    Size? anchorSize;

    if (_filterButtonKey.currentContext != null) {
      final RenderBox renderBox = _filterButtonKey.currentContext!.findRenderObject() as RenderBox;
      anchorPosition = renderBox.localToGlobal(Offset(-35, 100));
      anchorSize = renderBox.size;
    }

    Alignment alignment = Alignment.center;
    if (anchorPosition != null && anchorSize != null) {
      // Calculate center of the button
      final double buttonCenterX = anchorPosition.dx + anchorSize.width / 2;
      final double buttonCenterY = anchorPosition.dy + anchorSize.height / 2;

      // Convert to Alignment coordinates (-1.0 to 1.0)
      final double alignmentX = (buttonCenterX / ScreenUtils.width) * 2 - 1;
      final double alignmentY = (buttonCenterY / ScreenUtils.height) * 2 - 1;

      alignment = Alignment(alignmentX, alignmentY);
    }

    showPaddedDialog(
      context,
      navigationItem: DialogNavigationItem(
        id: 'library:filters',
        title: 'Filters',
        data: {"darkenTitleBar": false},
        onDismiss: () async {
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) setState(() => _filtersOpen = false);
        },
      ),
      barrierOptions: PaddedBarrierOptions(
        exactColor: true,
        transluscentBarrier: true,
        barrierColor: Colors.transparent,
      ),
      closeExistingDialogs: true,
      builder: (ctx, item, options) => PaddedDialog.frosted(
        constraints: BoxConstraints(
          minWidth: 250, maxWidth: 400,
          // TODO do the same as listsDialogHeight
          maxHeight: Manager.settings.listsDialogHeight, //just temporarily initialize with this value
        ),
        navigationItem: item,
        barrierOptions: options,
        alignment: alignment,
        transition: DialogTransition.scaleFromAbove(alignment: alignment, offset: 90),
        content: GenresFilterContent(),
      ),
    );
  }

  void _showListDialog() async {
    if (context.read<NavigationManager>().hasDialog && context.read<NavigationManager>().currentView?.id == "library:filters") {
      closeDialog();
      log('Filters dialog open, closing it and opening lists dialog');
      await Future.delayed(const Duration(milliseconds: 50));
    }

    if (mounted) setState(() => _listsOpen = true);

    if (!context.mounted) return;

    Offset? anchorPosition;
    Size? anchorSize;

    if (_listButtonKey.currentContext != null) {
      final RenderBox renderBox = _listButtonKey.currentContext!.findRenderObject() as RenderBox;
      anchorPosition = renderBox.localToGlobal(Offset(-20, 86));
      anchorSize = renderBox.size;
    }

    Alignment alignment = Alignment.center;
    if (anchorPosition != null && anchorSize != null) {
      // Calculate center of the button
      final double buttonCenterX = anchorPosition.dx + anchorSize.width / 2;
      final double buttonCenterY = anchorPosition.dy + anchorSize.height / 2;

      // Convert to Alignment coordinates (-1.0 to 1.0)
      final double alignmentX = (buttonCenterX / ScreenUtils.width) * 2 - 1;
      final double alignmentY = (buttonCenterY / ScreenUtils.height) * 2 - 1;

      alignment = Alignment(alignmentX, alignmentY);
    }

    showPaddedDialog(
      context,
      navigationItem: DialogNavigationItem(
        id: 'library:lists',
        title: 'Lists',
        data: {"darkenTitleBar": false},
        onDismiss: () async {
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) setState(() => _listsOpen = false);
        },
      ),
      barrierOptions: PaddedBarrierOptions(
        exactColor: true,
        transluscentBarrier: true,
        barrierColor: Colors.transparent,
      ),
      closeExistingDialogs: true,
      builder: (ctx, item, options) {
        final constraints = BoxConstraints(minWidth: 250, maxWidth: 400, maxHeight: Manager.settings.listsDialogHeight);

        return PaddedDialog.frosted(
          constraints: constraints,
          navigationItem: item,
          barrierOptions: options,
          alignment: alignment,
          transition: DialogTransition.scaleFromAbove(alignment: alignment, offset: 70),
          content: ListsContent(
            item: item,
            constraints: constraints,
            currentView: _vm.currentView,
            customListOrder: _vm.customListOrder,
            hiddenLists: _vm.hiddenLists,
            groupedDataCache: _vm.groupedDataCache,
            onScrollToList: _scrollToList,
            onInvalidateSortCache: _vm.invalidateSortCache,
            onSaveUserPreferences: _vm.saveUserPreferences,
            onHiddenListsChanged: _vm.setHiddenLists,
            onCustomListOrderChanged: _vm.setCustomListOrder,
          ),
        );
      },
    );
  }
}
