import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/manager.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../models/library.dart';
import '../models/series.dart';
import '../services/anilist/provider.dart';
import '../utils/logging.dart';
import '../utils/screen_utils.dart';
import '../utils/time_utils.dart';
import '../widgets/flyout_content.dart';
import '../widgets/gradient_mask.dart';
import '../widgets/simple_flyout.dart' hide ToggleableFlyoutContent;
import '../widgets/reverse_animation_flyout.dart' show ToggleableFlyoutConfig, ToggleableFlyoutContent, ToggleableFlyoutContentState;
import '../widgets/series_card.dart';

enum LibraryView { all, linked }

enum SortOrder { alphabetical, dateAdded, lastModified, custom }

enum GroupBy { none, anilistLists }

final GlobalKey<ToggleableFlyoutContentState> reverseAnimationPaletteKey = GlobalKey<ToggleableFlyoutContentState>();

class LibraryScreen extends StatefulWidget {
  final ScrollController? scrollController;
  final Function(String) onSeriesSelected;
  final int? fixedColumnCount;

  const LibraryScreen({
    super.key,
    required this.onSeriesSelected,
    this.scrollController,
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

  bool showFilters = false;
  bool _sortDescending = false;
  bool _filterHintShowing = false;
  List<String> _customListOrder = [];

  Widget get filterIcon {
    IconData icon;
    if (showFilters)
      icon = FluentIcons.filter_solid;
    else
      icon = FluentIcons.filter;

    return AnimatedRotation(
      duration: getDuration(shortStickyHeaderDuration),
      turns: _sortDescending ? 0.5 : 0,
      child: Icon(icon, size: 16),
    );
  }

  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    final set1 = Set.from(list1);
    final set2 = Set.from(list2);
    return set1.difference(set2).isEmpty;
  }

  void closeFlyout() {
    log('Closing filter flyout');
    Manager.navigation.popDialog();
    Manager.canPopDialog = true;

    reverseAnimationPaletteKey.currentState?.reverseAnimation().then((value) {
      filterFlyoutController.close(true);
    });
  }

  void _showFilterFlyout() {
    Manager.navigation.pushDialog('filterFlyout', 'filterFlyout');

    filterFlyoutController.showFlyout(
      barrierDismissible: true,
      dismissWithEsc: true,
      barrierMargin: EdgeInsets.only(top: Manager.titleBarHeight),
      dismissOnPointerMoveAway: false,
      position: Offset(ScreenUtils.width - 107, 287),
      barrierBlocking: false,
      closingDuration: Duration(milliseconds: 150),
      transitionDuration: Duration(milliseconds: 100),
      onBarrierDismiss: () => closeFlyout(),
      margin: 0,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: Manager.titleBarHeight + 8),
          child: StatefulBuilder(builder: (context, setState2) {
            return ToggleableFlyoutContent(
              key: reverseAnimationPaletteKey,
              config: const ToggleableFlyoutConfig(
                scaleBegin: 0.98,
                scaleEnd: 1.0,
                opacityBegin: 0.5,
                opacityEnd: 1.0,
                positionBegin: Offset(0.0, -0.5),
                positionEnd: Offset.zero,
              ),
              duration: const Duration(milliseconds: 100),
              child: SimpleFlyoutContent(
                shadowColor: Colors.transparent,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ToggleSwitch(
                        checked: _currentView == LibraryView.linked,
                        content: Text(_currentView == LibraryView.linked ? 'Linked Series' : 'All Series'),
                        onChanged: (value) {
                          setState2(() {
                            _currentView = value ? LibraryView.linked : LibraryView.all;
                          });
                          nextFrame(() => setState(() {}), delay: 10);
                        },
                      ),
                      const SizedBox(height: 8),
                      ComboBox<SortOrder>(
                        value: _sortOrder,
                        items: SortOrder.values
                            .map((order) => ComboBoxItem(
                                  value: order,
                                  child: Text(_getSortText(order)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState2(() => _sortOrder = value);
                            nextFrame(() => setState(() {}), delay: 10);
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      ComboBox<GroupBy>(
                        value: _groupBy,
                        items: GroupBy.values
                            .map((group) => ComboBoxItem(
                                  value: group,
                                  child: Text(_getGroupText(group)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState2(() => _groupBy = value);
                            nextFrame(() => setState(() {}), delay: 10);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  void _toggleFiltersSidebar() {
    setState(() {
      showFilters = !showFilters;
      _filterHintShowing = false;
    });
  }

  // Save preferences
  void _saveUserPreferences() {
    final settings = Provider.of<SettingsManager>(context, listen: false);

    settings.set('librarySortOrder', _sortOrder.toString());
    settings.set('librarySortDescending', _sortDescending.toString());
    settings.set('libraryGroupBy', _groupBy.toString());

    // Save the custom list order as JSON
    if (_customListOrder.isNotEmpty) {
      settings.set('libraryListOrder', jsonEncode(_customListOrder));
    }
  }

  // Load preferences
  Future<void> _loadUserPreferences() async {
    final settings = Provider.of<SettingsManager>(context, listen: false);

    // Load sort order
    final savedSortOrder = settings.get('librarySortOrder');
    if (savedSortOrder != null) {
      setState(() {
        _sortOrder = SortOrder.values.firstWhere(
          (order) => order.toString() == savedSortOrder,
          orElse: () => SortOrder.alphabetical,
        );
      });
    }

    // Load sort direction
    final savedSortDescending = settings.get('librarySortDescending');
    if (savedSortDescending != null) {
      setState(() {
        _sortDescending = savedSortDescending == 'true';
      });
    }

    // Load grouping
    final savedGroupBy = settings.get('libraryGroupBy');
    if (savedGroupBy != null) {
      setState(() {
        _groupBy = GroupBy.values.firstWhere(
          (group) => group.toString() == savedGroupBy,
          orElse: () => GroupBy.anilistLists,
        );
      });
    }

    // Load custom list order
    final savedListOrder = settings.get('libraryListOrder');
    if (savedListOrder != null) {
      try {
        final decoded = jsonDecode(savedListOrder) as List<dynamic>;
        setState(() {
          _customListOrder = decoded.map((e) => e.toString()).toList();
        });
      } catch (e) {
        logErr('Error loading list order', e);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  @override
  void dispose() {
    filterFlyoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<Library>();

    if (library.isLoading) return const Center(child: ProgressRing());

    if (library.libraryPath == null) return _buildLibrarySelector();

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
            const Text('No series found in your library'),
            const SizedBox(height: 16),
            Button(
              onPressed: _selectLibraryFolder,
              child: const Text('Change Library Folder'),
            ),
          ],
        ),
      );

    const double filterAngle = -0.01;
    const double width = 350;

    return Padding(
      padding: const EdgeInsets.only(bottom: 0, top: 16.0, left: 6.0),
      child: Column(
        children: [
          _buildHeader(library),
          // const SizedBox(height: 8),
          Expanded(
            child: Stack(
              children: [
                // Library entries
                Positioned.fill(
                  child: GestureDetector(
                    onTapDown: (_) => showFilters ? _toggleFiltersSidebar() : null,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: _buildLibraryView(library),
                    ),
                  ),
                ),

                // Library filters sidebar
                AnimatedPositioned(
                  duration: getDuration(shortStickyHeaderDuration),
                  top: 0,
                  right: showFilters
                      ? -0
                      : _filterHintShowing
                          ? -(width - 20)
                          : -width,
                  child: AnimatedRotation(
                    duration: getDuration(shortStickyHeaderDuration),
                    turns: _filterHintShowing ? filterAngle : 0,
                    child: GestureDetector(
                      onTapDown: (_) => _filterHintShowing ? _toggleFiltersSidebar() : null,
                      child: SizedBox(
                        height: 2000,
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
                      ))
              ],
            ),
          ),
        ],
      ),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sort order selector with ascending/descending toggle
                  Row(
                    children: [
                      Expanded(
                        child: ComboBox<SortOrder>(
                          value: _sortOrder,
                          items: SortOrder.values.map((order) => ComboBoxItem(value: order, child: Text(_getSortText(order)))).toList(),
                          onChanged: (value) {
                            if (value != null) setState(() => _sortOrder = value);
                            _saveUserPreferences();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(_sortDescending ? FluentIcons.sort_down : FluentIcons.sort_up),
                        onPressed: () {
                          setState(() => _sortDescending = !_sortDescending);
                          _saveUserPreferences();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Grouping selector
                  ComboBox<SortOrder>(
                    value: _sortOrder,
                    items: SortOrder.values.map((order) => ComboBoxItem(value: order, child: Text(_getSortText(order)))).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _sortOrder = value);
                      _saveUserPreferences();
                    },
                  ),
                  const SizedBox(height: 8),

                  // List order section (only show when grouping by Anilist lists)
                  if (_groupBy == GroupBy.anilistLists) ...[
                    const SizedBox(height: 16),
                    Text(
                      'List Order',
                      style: FluentTheme.of(context).typography.subtitle,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 300,
                      child: _buildListOrderUI(),
                    ),
                  ],
                ],
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
    if (_customListOrder.isEmpty || !_areListsEqual(_customListOrder, allLists)) {
      _customListOrder = List.from(allLists);
    }

    return ReorderableListView.builder(
      itemCount: _customListOrder.length,
      buildDefaultDragHandles: false,
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
      itemBuilder: (context, index) {
        final listName = _customListOrder[index];
        final displayName = listName == '__unlinked' ? 'Unlinked' : _formatListName(listName);

        return ListTile(
          key: ValueKey(listName),
          title: Text(displayName),
          leading: Icon(FluentIcons.drag_object),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
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
                        const Text('Filter'),
                      ],
                    ),
                    onPressed: () => _toggleFiltersSidebar(),
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
    final displayedSeries = _currentView == LibraryView.all //
        ? library.series.toList()
        : library.series.where((s) => s.isLinked).toList();

    _sortSeries(displayedSeries);

    return LayoutBuilder(builder: (context, constraints) {
      return FadingEdgeScrollView(
        fadeEdges: const EdgeInsets.symmetric(vertical: 10),
        child: _buildSeriesGrid(displayedSeries, constraints),
      );
    });
  }

  Widget _buildSeriesGrid(List<Series> series, BoxConstraints constraints) {
    // if the currently dispalyed library is empty
    if (series.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(FluentIcons.warning, size: 48, color: Colors.warningPrimaryColor),
            const SizedBox(height: 16),
            Text(_currentView == LibraryView.linked ? 'No linked series found. Link your series with Anilist first.' : 'No series found in your library'),
          ],
        ),
      );
    }

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

  void _sortSeries(List<Series> series) {
    Comparator<Series> comparator;

    switch (_sortOrder) {
      case SortOrder.dateAdded:
      // comparator = (a, b) => (a.dateAdded ?? DateTime.now()).compareTo(b.dateAdded ?? DateTime.now());
      case SortOrder.lastModified:
      // comparator = (a, b) => (a.lastModified ?? DateTime.now()).compareTo(b.lastModified ?? DateTime.now());
      case SortOrder.custom:
      // TODO For now, just use alphabetical order as fallback
      // comparator = (a, b) => a.name.compareTo(b.name);
      case SortOrder.alphabetical:
        comparator = (a, b) => a.name.compareTo(b.name);
    }

    // Apply the sorting direction
    if (_sortDescending)
      series.sort((a, b) => comparator(b, a)); // Reverse the comparison
    else
      series.sort(comparator);
  }

  // Convenience method to sort series within a group
  void _sortSeriesInGroup(List<Series> series) {
    _sortSeries(series);
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
      groups[listName == '__unlinked' ? 'Unlinked' : _formatListName(listName)] = [];
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
              groups[_formatListName(listName)]?.add(series);
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
            final seriesInGroup = groups[groupName]!;

            // Sort the series within each group
            _sortSeriesInGroup(seriesInGroup);

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
  String _formatListName(String listName) {
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
          if (_formatListName(customList) == displayName) {
            return customList;
          }
        }
        return displayName;
    }
  }

  String _getSortText(SortOrder order) {
    switch (order) {
      case SortOrder.alphabetical:
        return 'A-Z';
      case SortOrder.dateAdded:
        return 'Date Added';
      case SortOrder.lastModified:
        return 'Last Modified';
      case SortOrder.custom:
        return 'Custom Order';
    }
  }

  String _getGroupText(GroupBy group) {
    switch (group) {
      case GroupBy.none:
        return 'No Grouping';
      case GroupBy.anilistLists:
        return 'Anilist Lists';
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
