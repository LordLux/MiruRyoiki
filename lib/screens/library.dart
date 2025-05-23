import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter_custom_cursor/flutter_custom_cursor.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/widgets/cursors.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../models/anilist/anime.dart';
import '../models/library.dart';
import '../models/series.dart';
import '../services/anilist/provider.dart';
import '../settings.dart';
import '../utils/logging.dart';
import '../utils/screen_utils.dart';
import '../utils/time_utils.dart';
import '../widgets/flyout_content.dart';
import '../widgets/gradient_mask.dart';
import '../widgets/simple_flyout.dart' hide ToggleableFlyoutContent;
import '../widgets/reverse_animation_flyout.dart' show ToggleableFlyoutConfig, ToggleableFlyoutContent, ToggleableFlyoutContentState;
import '../widgets/series_card.dart';

enum LibraryView { all, linked }

enum SortOrder {
  alphabetical,
  score,
  progress,
  lastModified,
  dateAdded,
  startDate,
  completedDate,
  averageScore,
  releaseDate,
  popularity,
}

enum GroupBy { none, anilistLists }

final GlobalKey<ToggleableFlyoutContentState> reverseAnimationPaletteKey = GlobalKey<ToggleableFlyoutContentState>();

class LibraryScreen extends StatefulWidget {
  final ScrollController scrollController;
  final Function(String) onSeriesSelected;
  final int? fixedColumnCount;

  const LibraryScreen({
    super.key,
    required this.onSeriesSelected,
    required this.scrollController,
    this.fixedColumnCount,
  });

  @override
  State<LibraryScreen> createState() => LibraryScreenState();
}

class LibraryScreenState extends State<LibraryScreen> {
  LibraryView _currentView = LibraryView.all;
  SortOrder _sortOrder = SortOrder.alphabetical;
  GroupBy _groupBy = GroupBy.anilistLists;
  final SimpleFlyoutController filterFlyoutController = SimpleFlyoutController();

  bool _showGrouped = false;
  bool showFilters = false;
  bool _sortDescending = false;
  bool _filterHintShowing = false;

  List<String> _customListOrder = [];
  // ignore: prefer_final_fields
  Map<String, List<Series>> _sortedGroupedSeries = {};
  List<Series> _sortedUngroupedSeries = [];
  bool _hasAppliedSorting = false;

  bool _isProcessing = false;
  Future<void>? _currentSortOperation;
  SortOrder? _lastAppliedSortOrder;
  bool? _lastAppliedSortDescending;
  bool _needsSort = true;

  double _savedScrollPosition = 0.0;
  bool _isReordering = false;

  Widget get filterIcon {
    IconData icon;
    if (showFilters)
      icon = FluentIcons.filter_solid;
    else
      icon = FluentIcons.filter;

    return Icon(icon, size: 16);
  }

  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    final set1 = Set.from(list1);
    final set2 = Set.from(list2);
    return set1.difference(set2).isEmpty;
  }

  void toggleFiltersSidebar({bool? value}) {
    setState(() {
      showFilters = value ?? !showFilters;
      _filterHintShowing = false;
    });
  }

  // Save preferences
  void _saveUserPreferences() {
    final manager = Manager.settings;
    manager.set('library_view', _currentView.toString());
    manager.set('library_sort_order', _sortOrder.toString());
    manager.set('library_sort_descending', _sortDescending);
    manager.set('library_group_by', _groupBy.toString());
    manager.set('library_show_grouped', _showGrouped);
    manager.set('library_list_order', json.encode(_customListOrder));
  }

  // Load preferences
  void _loadUserPreferences() {
    final manager = Manager.settings;
    setState(() {
      // Load view
      final viewString = manager.get('library_view', defaultValue: LibraryView.all.toString());
      _currentView = viewString == LibraryView.linked.toString() ? LibraryView.linked : LibraryView.all;

      // Load sort order
      final sortOrderString = manager.get('library_sort_order', defaultValue: SortOrder.alphabetical.toString());
      for (final order in SortOrder.values) {
        if (order.toString() == sortOrderString) {
          _sortOrder = order;
          break;
        }
      }

      // Load other settings - FIX HERE: convert string to boolean
      final sortDescendingString = manager.get('library_sort_descending', defaultValue: 'false');
      _sortDescending = sortDescendingString.toString() == 'true';

      final groupByString = manager.get('library_group_by', defaultValue: GroupBy.none.toString());
      for (final group in GroupBy.values) {
        if (group.toString() == groupByString) {
          _groupBy = group;
          break;
        }
      }

      final showGroupedString = manager.get('library_show_grouped', defaultValue: 'false');
      _showGrouped = showGroupedString.toString() == 'true';

      // Load list order
      final listOrderString = manager.get('library_list_order', defaultValue: '[]');
      try {
        final decoded = json.decode(listOrderString);
        if (decoded is List) {
          _customListOrder = List<String>.from(decoded);
        }
      } catch (_) {
        _customListOrder = [];
      }
    });
  }

  bool _sortingNeeded(List<Series> series) {
    if (_needsSort || _lastAppliedSortOrder != _sortOrder || _lastAppliedSortDescending != _sortDescending) //
      return true;
    return false;
  }

  void _onViewChanged(LibraryView? value) {
    if (value != null && value != _currentView) {
      setState(() {
        _currentView = value;
        _needsSort = true;
        _hasAppliedSorting = false;
        _sortedGroupedSeries.clear();
        _sortedUngroupedSeries.clear();
      });
      _saveUserPreferences();
    }
  }

  void _onSortOrderChanged(SortOrder? value) {
    if (value != null && value != _sortOrder) {
      setState(() {
        _sortOrder = value;
        _needsSort = true;
        _hasAppliedSorting = false;
        _sortedGroupedSeries.clear();
        _sortedUngroupedSeries.clear();
      });
      _saveUserPreferences();
    }
  }

  void _onSortDirectionChanged() {
    setState(() {
      _sortDescending = !_sortDescending;
      _needsSort = true;
      _hasAppliedSorting = false;
      _sortedGroupedSeries.clear();
      _sortedUngroupedSeries.clear();
    });
    _saveUserPreferences();
  }

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    _lastAppliedSortOrder = _sortOrder;
    _lastAppliedSortDescending = _sortDescending;
  }

  @override
  void dispose() {
    filterFlyoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<Library>();

    if (library.libraryPath == null) return _buildLibrarySelector();

    const double filterAngle = -0.01;
    const double width = 350;
    const double headerHeight = 63;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                top: 0,
                child: GestureDetector(
                  onTap: () => toggleFiltersSidebar(value: false),
                  behavior: HitTestBehavior.translucent,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 6.0),
                    child: SizedBox(height: headerHeight, child: _buildHeader(library)),
                  ),
                ),
              ),
              // Library entries
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => toggleFiltersSidebar(value: false),
                  behavior: HitTestBehavior.deferToChild,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6.0, top: headerHeight + 16.0, left: 6.0),
                    child: _buildLibraryView(library),
                  ),
                ),
              ),

              // Library filters sidebar
              AnimatedPositioned(
                duration: getDuration(shortStickyHeaderDuration),
                top: headerHeight + 16,
                right: showFilters
                    ? -0
                    : _filterHintShowing
                        ? -(width - 20)
                        : -width,
                child: AnimatedRotation(
                  duration: getDuration(shortStickyHeaderDuration),
                  turns: _filterHintShowing ? filterAngle : 0,
                  child: GestureDetector(
                    onTapDown: (_) => _filterHintShowing ? toggleFiltersSidebar() : null,
                    child: SizedBox(
                      height: ScreenUtils.height - headerHeight - 16 - Manager.titleBarHeight,
                      width: width,
                      child: Acrylic(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))),
                        blurAmount: 7,
                        elevation: 0,
                        luminosityAlpha: .4,
                        shadowColor: Manager.accentColor,
                        child: _buildFiltersSidebar(),
                      ),
                    ),
                  ),
                ),
              ),
              // Mouse detection
              if (!showFilters)
                Positioned(
                  right: -95,
                  child: AnimatedRotation(
                    duration: getDuration(shortStickyHeaderDuration),
                    turns: _filterHintShowing ? filterAngle : 0,
                    child: SizedBox(
                      width: 100,
                      height: 2000,
                      child: MouseRegion(
                        onEnter: (event) => setState(() => _filterHintShowing = true),
                        onExit: (event) => setState(() => _filterHintShowing = false),
                        hitTestBehavior: HitTestBehavior.translucent,
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

  Widget _buildFiltersSidebar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          AbsorbPointer(
            absorbing: _filterHintShowing,
            child: AnimatedOpacity(
              opacity: _filterHintShowing ? 0.0 : 1.0,
              duration: getDuration(shortStickyHeaderDuration),
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Display Options',
                        style: FluentTheme.of(context).typography.subtitle,
                      ),
                      const SizedBox(height: 16),

                      // Library View Switch
                      InfoLabel(
                        label: 'View',
                        child: ComboBox<LibraryView>(
                          value: _currentView,
                          items: [
                            ComboBoxItem(value: LibraryView.all, child: Text('All Series')),
                            ComboBoxItem(value: LibraryView.linked, child: Text('Linked Series Only')),
                          ],
                          onChanged: _onViewChanged,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Grouping Toggle
                      ToggleSwitch(
                        checked: _showGrouped,
                        content: Text('Group by AniList Lists'),
                        onChanged: (value) {
                          setState(() {
                            _showGrouped = value;
                            _groupBy = value ? GroupBy.anilistLists : GroupBy.none;
                            _saveUserPreferences();
                          });
                        },
                      ),

                      const SizedBox(height: 24),
                      Text(
                        'Sort Options',
                        style: FluentTheme.of(context).typography.subtitle,
                      ),
                      const SizedBox(height: 16),

                      // Sort Order
                      InfoLabel(
                        label: 'Sort by',
                        child: Row(
                          children: [
                            ComboBox<SortOrder>(
                              value: _sortOrder,
                              items: SortOrder.values.map((order) => ComboBoxItem(value: order, child: Text(_getSortText(order)))).toList(),
                              onChanged: _onSortOrderChanged,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: AnimatedRotation(
                                duration: getDuration(shortStickyHeaderDuration),
                                turns: _sortDescending ? 0 : 1,
                                child: Icon(_sortDescending ? FluentIcons.sort_lines : FluentIcons.sort_lines_ascending),
                              ),
                              onPressed: _onSortDirectionChanged,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Only show list order UI when grouping is enabled
                      if (_showGrouped) ...[
                        const SizedBox(height: 24),
                        Text(
                          'List Order',
                          style: FluentTheme.of(context).typography.subtitle,
                        ),
                        const SizedBox(height: 16),
                        _buildListOrderUI(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _filterHintShowing ? 1.0 : 0.0,
            duration: getDuration(shortStickyHeaderDuration),
            child: RotatedBox(quarterTurns: 1, child: Text('Filters', style: FluentTheme.of(context).typography.title)),
          ),
        ],
      ),
    );
  }

  Widget _buildListOrderUI() {
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);

    // Get all list names including standard and custom lists
    final allLists = <String>[];

    // Add standard lists in default order
    for (final listName in ['CURRENT', 'PLANNING', 'PAUSED', 'COMPLETED', 'DROPPED', 'REPEATING']) {
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
    allLists.add('__unlinked');

    // If _customListOrder is empty or outdated, initialize with default order
    if (_customListOrder.isEmpty || !_areListsEqual(_customListOrder, allLists)) //
      _customListOrder = List.from(allLists);

    final double childHeight = 45;

    Widget buildTile(String listName, String displayName, int index, bool selected, {Animation<double>? animation}) {
      return ReorderableDragStartListener(
        key: ValueKey(listName),
        index: index,
        child: MouseRegion(
          cursor: FlutterCustomMemoryImageCursor(key: _isReordering ? systemMouseCursorGrabbing : systemMouseCursorGrab),
          child: Builder(
            builder: (context) {
              Color animatedColor = (selected ? Color.lerp(Colors.white.withOpacity(.15), Manager.accentColor, .75)! : Colors.white.withOpacity(.05));

              Widget wrapper(Widget Function(BuildContext, Color) child) {
                if (selected && animation != null) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      animatedColor = Color.lerp(
                        Colors.white.withOpacity(.05),
                        Color.lerp(Colors.white.withOpacity(.15), Manager.accentColor, .75)!,
                        animation.value,
                      )!;
                      return child!;
                    },
                    child: child(context, animatedColor),
                  );
                }
                return child(context, animatedColor);
              }

              return wrapper(
                (context, color) => ListTile(
                  tileColor: WidgetStatePropertyAll(color),
                  title: Text(displayName),
                  leading: Icon(!selected ? Icons.drag_handle : FluentIcons.drag_object),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return SizedBox(
      height: _customListOrder.length * childHeight,
      child: ReorderableListView.builder(
        itemCount: _customListOrder.length,
        buildDefaultDragHandles: false,
        clipBehavior: Clip.none,
        proxyDecorator: (child, index, animation) {
          _isReordering = true;
          final name = _customListOrder[index];
          return buildTile(name, _fromApiListName(name), index, true);
        },
        onReorderStart: (_) => setState(() => _isReordering = true),
        onReorderEnd: (_) => setState(() => _isReordering = false),
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = _customListOrder.removeAt(oldIndex);
            _customListOrder.insert(newIndex, item);
            _saveUserPreferences();
          });
        },
        prototypeItem: SizedBox(height: childHeight),
        itemBuilder: (context, index) {
          final listName = _customListOrder[index];
          final displayName = listName == '__unlinked' ? 'Unlinked' : _fromApiListName(listName);

          return buildTile(listName, displayName, index, false);
        },
      ),
    );
  }

  Widget _buildHeader(Library library) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Media Library', style: FluentTheme.of(context).typography.title),
              Text('Path: ${library.libraryPath}', style: FluentTheme.of(context).typography.caption),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0, top: 8.0),
          child: Row(
            children: [
              Button(
                child: const Text('Refresh'),
                onPressed: () => library.reloadLibrary(),
              ),
              SizedBox(width: 8),
              SimpleFlyoutTarget(
                controller: filterFlyoutController,
                child: FluentTheme(
                  data: FluentTheme.of(context).copyWith(
                    buttonTheme: ButtonThemeData(
                      filledButtonStyle: FluentTheme.of(context).buttonTheme.filledButtonStyle?.copyWith(
                            backgroundColor: WidgetStatePropertyAll(showFilters ? Manager.accentColor.light : Manager.accentColor.lighter),
                          ),
                    ),
                  ),
                  child: FilledButton(
                    child: Row(
                      children: [
                        filterIcon,
                        const SizedBox(width: 4),
                        const Text('Filter & Display'),
                      ],
                    ),
                    onPressed: () => toggleFiltersSidebar(),
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
          const SizedBox(height: 16),
          const Text('Select your media library folder to get started', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          Button(
            style: ButtonStyle(padding: ButtonState.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 8))),
            onPressed: _selectLibraryFolder,
            child: const Text('Select Library Folder'),
          ),
        ],
      ),
    );
  }
  // double singleChildHeight(int count) =>

  static const double maxCardWidth = 200;
  static const double cardPadding = 16;

  int crossAxisCount(BoxConstraints constraints) => widget.fixedColumnCount != null ? widget.fixedColumnCount! : (constraints.maxWidth ~/ maxCardWidth).clamp(1, 10);

  double cardWidth(BoxConstraints constraints) => (constraints.maxWidth / (crossAxisCount(constraints) + cardPadding * (crossAxisCount(constraints) - 1))).clamp(0, maxCardWidth);

  double cardHeight(BoxConstraints constraints) => ((cardWidth(constraints) / 0.71) + cardPadding) * 8.15; // based on the aspect ratio of the series card

  Widget _buildLibraryView(Library library) {
    List<Series> displayedSeries = _currentView == LibraryView.all //
        ? library.series.toList()
        : library.series.where((s) => s.isLinked).toList();

    if (library.isLoading) return const Center(child: ProgressRing());

    if (library.series.isEmpty)
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              FluentIcons.folder_open,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(_currentView == LibraryView.linked ? 'No linked series found. Link your series with Anilist first.' : 'No series found in your library'),
            const SizedBox(height: 16),
            Button(
              onPressed: _selectLibraryFolder,
              child: const Text('Change Library Folder'),
            ),
          ],
        ),
      );

    if (_sortingNeeded(displayedSeries) && !_isProcessing && _currentSortOperation == null) {
      _needsSort = false;
      _applySortingAsync(displayedSeries);
      log('Sorting series in library view: ${_sortDescending ? 'descending' : 'ascending'}');
    } else if (_hasAppliedSorting) {
      // Use the already sorted list
      displayedSeries = _sortedUngroupedSeries;
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          Opacity(
            opacity: _isProcessing ? 0 : 1,
            child: FadingEdgeScrollView(
              fadeEdges: const EdgeInsets.symmetric(vertical: 10),
              child: _buildSeriesGrid(displayedSeries, constraints),
            ),
          ),
          if (_isProcessing)
            Positioned.fill(
              child: const Center(child: ProgressRing()),
            ),
        ],
      );
    });
  }

  Widget _buildSeriesGrid(List<Series> series, BoxConstraints constraints) {
    Widget episodesGrid(List<Series> list, ScrollController controller, ScrollPhysics physics, bool includePadding) => GridView.builder(
          padding: includePadding ? const EdgeInsets.only(top: 16, bottom: 8, right: 12) : EdgeInsets.zero,
          cacheExtent: cardHeight(constraints) * 2,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount(constraints),
            childAspectRatio: 0.71,
            crossAxisSpacing: cardPadding,
            mainAxisSpacing: cardPadding,
          ),
          controller: controller,
          physics: physics,
          itemCount: list.length,
          itemBuilder: (context, index) {
            final Series series_ = list[index % list.length]; // just to ensure we don't run out of bounds

            return SeriesCard(
              key: ValueKey('${series_.path}:${series_.effectivePosterPath ?? 'none'}'),
              series: series_,
              onTap: () => _navigateToSeries(series_),
            );
          },
        );

    // If grouping is enabled, show grouped view
    if (_groupBy != GroupBy.none) return _buildGroupedView(series, constraints, episodesGrid);

    return DynMouseScroll(
      enableSmoothScroll: Manager.animationsEnabled,
      scrollAmount: cardHeight(constraints),
      controller: widget.scrollController,
      durationMS: 300,
      animationCurve: Curves.ease,
      builder: (context, controller, physics) => episodesGrid(series, controller, physics, true),
    );
  }

  void _applySortingAsync(List<Series> series, {String? groupName}) {
    if (_currentSortOperation != null) return;

    if (widget.scrollController.hasClients == true) {
      _savedScrollPosition = widget.scrollController.offset;
    }

    _isProcessing = true;
    nextFrame(() => setState(() {}));

    final sortData = <int, Map<String, dynamic>>{};

    // Pre-fetch any provider-dependent data
    for (final series in series) {
      sortData[series.hashCode] = {
        'updatedAt': series.latestUpdatedAt, //        updatedAt    - list updated timestamp
        'createdAt': series.earliestCreatedAt, //      createdAt    - added to list timestamp
        'startedAt': series.earliestStartedAt, //      startedAt    - user started entry timestamp
        'completedAt': series.latestCompletionDate, // completedAt  - user completion date
        'averageScore': series.highestUserScore, //    averageScore - user score
        'startDate': series.earliestReleaseDate, //    startDate    - release date
        'popularity': series.highestPopularity, //     popularity   - popularity
      };
    }

    _currentSortOperation = Future.microtask(() async {
      try {
        final sortedSeries = await compute(_sortSeriesInBackground, {
          'series': series,
          'sortOrder': _sortOrder.index,
          'sortDescending': _sortDescending,
          'sortData': sortData,
        });

        if (mounted) {
          if (groupName != null) {
            _sortedGroupedSeries[groupName] = sortedSeries;
          } else {
            _sortedUngroupedSeries = sortedSeries;
          }
          setState(() {
            _lastAppliedSortOrder = _sortOrder;
            _lastAppliedSortDescending = _sortDescending;
            _hasAppliedSorting = true;
          });
          // Finally, after scroll position is restored, hide loading indicator
          nextFrame(() {
            if (widget.scrollController.hasClients == true) {
              final maxScroll = widget.scrollController.position.maxScrollExtent;
              final scrollTo = _savedScrollPosition.clamp(0.0, maxScroll);
              widget.scrollController.jumpTo(scrollTo);

              setState(() {
                _isProcessing = false;
              });
            }
          });
        }
      } finally {
        _currentSortOperation = null;
      }
    });
  }

  static List<Series> _sortSeriesInBackground(Map<String, dynamic> params) {
    final series = params['series'] as List<Series>;
    final sortOrderIndex = params['sortOrder'] as int;
    final sortDescending = params['sortDescending'] as bool;
    final sortData = params['sortData'] as Map<int, Map<String, dynamic>>;
    final sortOrder = SortOrder.values[sortOrderIndex];

    final List<Series> seriesCopy = List.from(series);

    Comparator<Series> comparator;

    switch (sortOrder) {
      // Alphabetical order by title
      case SortOrder.alphabetical:
        comparator = (a, b) => a.name.compareTo(b.name);

      // Median score from Anilist
      case SortOrder.score:
        comparator = (a, b) {
          final aScore = a.meanScore ?? 0;
          final bScore = b.meanScore ?? 0;
          return aScore.compareTo(bScore);
        };

      // Progress percentage from Local TODO prefer anilist
      case SortOrder.progress:
        comparator = (a, b) => a.watchedPercentage.compareTo(b.watchedPercentage);

      // Date the List Entry was last modified
      case SortOrder.lastModified:
        // Use timestamp from Anilist's updatedAt field
        comparator = (a, b) {
          final aUpdated = a.currentAnilistData?.updatedAt ?? 0;
          final bUpdated = b.currentAnilistData?.updatedAt ?? 0;
          return aUpdated.compareTo(bUpdated);
        };

      // Date the user added the series to their list
      case SortOrder.dateAdded:
        // Use timestamp from when the user added the series to their list
        comparator = (a, b) {
          final aCreated = sortData[a.hashCode]?['createdAt'] ?? 0;
          final bCreated = sortData[b.hashCode]?['createdAt'] ?? 0;
          return aCreated.compareTo(bCreated);
        };

      // Date the user started watching the series
      case SortOrder.startDate:
        comparator = (a, b) {
          final aStarted = sortData[a.hashCode]?['startedAt'];
          final bStarted = sortData[b.hashCode]?['startedAt'];

          final aDate = aStarted != null ? DateValue.fromJson(aStarted).toDateTime() : null;
          final bDate = bStarted != null ? DateValue.fromJson(bStarted).toDateTime() : null;

          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;

          return aDate.compareTo(bDate);
        };

      // Date the user completed watching the series
      case SortOrder.completedDate:
        comparator = (a, b) {
          final aCompleted = sortData[a.hashCode]?['completedAt'];
          final bCompleted = sortData[b.hashCode]?['completedAt'];

          final aDate = aCompleted != null ? DateValue.fromJson(aCompleted).toDateTime() : null;
          final bDate = bCompleted != null ? DateValue.fromJson(bCompleted).toDateTime() : null;

          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;

          return aDate.compareTo(bDate);
        };

      // Average score from Anilist
      case SortOrder.averageScore:
        comparator = (a, b) {
          final aScore = a.currentAnilistData?.averageScore ?? 0;
          final bScore = b.currentAnilistData?.averageScore ?? 0;
          return aScore.compareTo(bScore);
        };

      // Release date from Anilist
      case SortOrder.releaseDate:
        comparator = (a, b) {
          // Try to get release date from Anilist data
          final aDate = a.currentAnilistData?.startDate?.toDateTime();
          final bDate = b.currentAnilistData?.startDate?.toDateTime();

          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;

          return aDate.compareTo(bDate);
        };

      // Popularity from Anilist
      case SortOrder.popularity:
        comparator = (a, b) {
          final aPopularity = a.currentAnilistData?.popularity ?? 0;
          final bPopularity = b.currentAnilistData?.popularity ?? 0;
          return aPopularity.compareTo(bPopularity);
        };
    }

    // Apply the sorting direction
    if (sortDescending)
      seriesCopy.sort((a, b) => comparator(b, a)); // Reverse the comparison
    else
      seriesCopy.sort(comparator);

    return seriesCopy;
  }

  Widget _buildGroupedView(
    List<Series> allSeries,
    BoxConstraints constraints,
    Widget Function(List<Series>, ScrollController, ScrollPhysics, bool) episodesGrid,
  ) {
    // Create the groupings based on selected grouping type
    Map<String, List<Series>> groups = {};

    // Get all Anilist lists
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);

    // sort them to have CURRENT, PLAN TO WATCH, ON HOLD, COMPLETED, DROPPED
    for (final listName in _customListOrder) {
      groups[listName == '__unlinked' ? 'Unlinked' : _fromApiListName(listName)] = [];
    }

    // Sort series into groups
    for (final series in allSeries) {
      if (series.isLinked) {
        bool foundInList = false;

        // Check each Anilist mapping against each list
        for (final mapping in series.anilistMappings) {
          // Try to match with lists by mediaId
          for (final entry in anilistProvider.userLists.entries) {
            final listName = entry.key;
            final list = entry.value;

            if (list.entries.any((listEntry) => listEntry.mediaId == mapping.anilistId)) {
              groups[_fromApiListName(listName)]?.add(series);
              foundInList = true;
              break;
            }
          }
          if (foundInList) break;
        }

        // If not found in any list, add to "Not in List"
        if (!foundInList) {
          // Find first group that's either "Unlinked" or a fallback
          final unlinkedKey = groups.keys.firstWhere(
            (k) => k == 'Unlinked',
            orElse: () => groups.keys.first,
          );
          groups[unlinkedKey]?.add(series);
        }
      } else {
        // Unlinked series go to "Unlinked" group
        groups['Unlinked']?.add(series);
      }
    }

    // Remove empty groups
    groups.removeWhere((_, series) => series.isEmpty);

    // Build the grouped ListView
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: DynMouseScroll(
        enableSmoothScroll: Manager.animationsEnabled,
        scrollAmount: cardHeight(constraints),
        controller: widget.scrollController,
        durationMS: 300,
        animationCurve: Curves.ease,
        builder: (context, controller, physics) => ListView.builder(
          padding: EdgeInsets.only(right: 16),
          controller: controller,
          physics: physics,
          itemCount: groups.length,
          itemBuilder: (context, groupIndex) {
            // Use the _customListOrder to determine display order
            final displayOrder = groups.keys.toList();
            displayOrder.sort((a, b) {
              // Get the original position in _customListOrder
              final aIndex = _customListOrder.indexOf(a == 'Unlinked' ? '__unlinked' : _toApiListName(a));
              final bIndex = _customListOrder.indexOf(b == 'Unlinked' ? '__unlinked' : _toApiListName(b));

              // If one is not found, put it at the end
              if (aIndex == -1) return 1;
              if (bIndex == -1) return -1;

              // Otherwise use the custom order
              return aIndex.compareTo(bIndex);
            });

            final groupName = displayOrder[groupIndex];
            List<Series> seriesInGroup = groups[groupName]!;

            if (_sortedGroupedSeries.containsKey(groupName)) {
              seriesInGroup = _sortedGroupedSeries[groupName]!;
            }

            // Sort the series within each group
            if (_sortingNeeded(seriesInGroup) && !_isProcessing && _currentSortOperation == null) {
              _needsSort = false;
              _applySortingAsync(seriesInGroup, groupName: groupName);
              log('Sorting series in group: $groupName');
            }

            return Expander(
              initiallyExpanded: true,
              headerBackgroundColor: WidgetStatePropertyAll(FluentTheme.of(context).resources.cardBackgroundFillColorDefault.withOpacity(0.025)),
              contentBackgroundColor: FluentTheme.of(context).resources.cardBackgroundFillColorSecondary.withOpacity(0),
              header: Text(groupName, style: FluentTheme.of(context).typography.subtitle),
              trailing: Text('${seriesInGroup.length} series'),
              content: SizedBox(
                height: cardHeight(constraints) * (seriesInGroup.length / crossAxisCount(constraints)).ceil() * 0.95,
                child: episodesGrid(seriesInGroup, ScrollController(), NeverScrollableScrollPhysics(), false),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper method to format list names for display
  String _fromApiListName(String listName) {
    // Handle the standard Anilist list names which are in uppercase
    switch (listName) {
      case 'CURRENT':
        return 'Watching';
      case 'COMPLETED':
        return 'Completed';
      case 'PLANNING':
        return 'Plan to Watch';
      case 'DROPPED':
        return 'Dropped';
      case 'PAUSED':
        return 'On Hold';
      case 'REPEATING':
        return 'Rewatching';
      default:
        // Custom lists already have proper formatting
        if (listName.startsWith('custom_')) //
          return listName.substring(7); // Remove 'custom_' prefix
        return listName;
    }
  }

  String _toApiListName(String displayName) {
    switch (displayName) {
      case 'Watching':
        return 'CURRENT';
      case 'Completed':
        return 'COMPLETED';
      case 'Plan to Watch':
        return 'PLANNING';
      case 'Dropped':
        return 'DROPPED';
      case 'On Hold':
        return 'PAUSED';
      case 'Rewatching':
        return 'REPEATING';
      case 'Unlinked':
        return '__unlinked';
      default:
        // Check if it might be a custom list
        final customLists = Provider.of<AnilistProvider>(context, listen: false).userLists.keys.where((k) => k.startsWith('custom_'));

        for (final customList in customLists) {
          if (_fromApiListName(customList) == displayName) {
            return customList;
          }
        }
        return displayName;
    }
  }

  String _getSortText(SortOrder order) {
    switch (order) {
      case SortOrder.alphabetical:
        return 'Title (A-Z)';
      case SortOrder.score:
        return 'Score';
      case SortOrder.progress:
        return 'Progress';
      case SortOrder.lastModified:
        return 'Last Updated';
      case SortOrder.dateAdded:
        return 'Date Added';
      case SortOrder.startDate:
        return 'Start Date';
      case SortOrder.completedDate:
        return 'Completed Date';
      case SortOrder.averageScore:
        return 'Average Score';
      case SortOrder.releaseDate:
        return 'Release Date';
      case SortOrder.popularity:
        return 'Popularity';
    }
  }

  void _selectLibraryFolder() async {
    final String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Media Library Folder',
    );

    if (selectedDirectory != null) {
      // ignore: use_build_context_synchronously
      final library = context.read<Library>();
      await library.setLibraryPath(selectedDirectory);
    }
  }

  void _navigateToSeries(Series series) => widget.onSeriesSelected(series.path);
}
