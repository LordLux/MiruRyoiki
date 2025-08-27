import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/manager.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../main.dart';
import '../enums.dart';
import '../models/anilist/user_data.dart';
import '../models/anilist/user_list.dart';
import '../services/anilist/queries/anilist_service.dart';
import '../services/library/library_provider.dart';
import '../models/series.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../services/navigation/shortcuts.dart';
import '../utils/color_utils.dart';
import '../utils/path_utils.dart';
import '../utils/screen_utils.dart';
import '../utils/time_utils.dart';
import '../widgets/animated_order_tile.dart';
import '../widgets/buttons/button.dart';
import '../widgets/buttons/switch_button.dart';
import '../widgets/buttons/wrapper.dart';
import '../widgets/gradient_mask.dart';
import '../widgets/series_card.dart';

// Cache parameters to track when cache needs invalidation
class _CacheParameters {
  final LibraryView currentView;
  final SortOrder sortOrder;
  final GroupBy groupBy;
  final bool sortDescending;
  final bool showGrouped;
  final bool showHiddenSeries;
  final bool showAnilistHiddenSeries;
  final List<String> customListOrder;

  _CacheParameters({
    required this.currentView,
    required this.sortOrder,
    required this.groupBy,
    required this.sortDescending,
    required this.showGrouped,
    required this.showHiddenSeries,
    required this.showAnilistHiddenSeries,
    required this.customListOrder,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || //
      other is _CacheParameters && //
          runtimeType == other.runtimeType &&
          currentView == other.currentView &&
          sortOrder == other.sortOrder &&
          groupBy == other.groupBy &&
          sortDescending == other.sortDescending &&
          showGrouped == other.showGrouped &&
          showHiddenSeries == other.showHiddenSeries &&
          showAnilistHiddenSeries == other.showAnilistHiddenSeries &&
          _listEquals(customListOrder, other.customListOrder);

  @override
  int get hashCode =>
      currentView.hashCode ^ //
      sortOrder.hashCode ^
      groupBy.hashCode ^
      sortDescending.hashCode ^
      showGrouped.hashCode ^
      showHiddenSeries.hashCode ^
      showAnilistHiddenSeries.hashCode ^
      customListOrder.hashCode;

  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null) return false;
    if (a.length != b.length) return false;
    for (int index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

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

class LibraryScreenState extends State<LibraryScreen> {
  LibraryView _currentView = LibraryView.all;
  SortOrder _sortOrder = SortOrder.alphabetical;
  GroupBy _groupBy = GroupBy.anilistLists;

  bool _sortDescending = false;
  bool _showGrouped = false;
  bool _showFilters = false;

  bool _filterHintShowing = false;
  final GlobalKey firstCardKey = GlobalKey();
  bool _isSelectingFolder = false;
  bool _isReordering = false;

  List<String> _customListOrder = [];
  List<Series> displayedSeries = [];

  // Cache system
  List<Series>? _sortedSeriesCache;
  Map<String, List<Series>>? _groupedDataCache;
  _CacheParameters? _cacheParameters;

  /// Check if the current cache is valid by comparing parameters
  bool _isCacheValid() {
    if (_cacheParameters == null) return false;

    final currentParams = _CacheParameters(
      currentView: _currentView,
      sortOrder: _sortOrder,
      groupBy: _groupBy,
      sortDescending: _sortDescending,
      showGrouped: _showGrouped,
      showHiddenSeries: Manager.settings.showHiddenSeries,
      showAnilistHiddenSeries: Manager.settings.showAnilistHiddenSeries,
      customListOrder: List.from(_customListOrder),
    );

    return _cacheParameters == currentParams;
  }

  /// Sort series using the same logic as isolate_manager.dart but in main thread
  List<Series> _sortSeries(List<Series> series, Library library) {
    final List<Series> seriesCopy = List.from(series);

    Comparator<Series> comparator;

    switch (_sortOrder) {
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

      // Progress percentage
      case SortOrder.progress:
        comparator = (a, b) {
          // Use the Series watchedPercentage getter
          final aProgress = a.watchedPercentage;
          final bProgress = b.watchedPercentage;
          return aProgress.compareTo(bProgress);
        };

      // Date the List Entry was last modified
      case SortOrder.lastModified:
        comparator = (a, b) {
          final aUpdated = a.currentAnilistData?.updatedAt ?? 0;
          final bUpdated = b.currentAnilistData?.updatedAt ?? 0;
          return aUpdated.compareTo(bUpdated);
        };

      // Date the user added the series to their list
      case SortOrder.dateAdded:
        comparator = (a, b) {
          // For this we'd need the user list entry creation time, which isn't readily available
          // Fall back to alphabetical for now
          return a.name.compareTo(b.name);
        };

      // Date the user started watching the series
      case SortOrder.startDate:
        comparator = (a, b) {
          final aStarted = a.currentAnilistData?.startedAt;
          final bStarted = b.currentAnilistData?.startedAt;

          final aDate = aStarted?.toDateTime();
          final bDate = bStarted?.toDateTime();

          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;

          return aDate.compareTo(bDate);
        };

      // Date the user completed watching the series
      case SortOrder.completedDate:
        comparator = (a, b) {
          final aCompleted = a.currentAnilistData?.completedAt;
          final bCompleted = b.currentAnilistData?.completedAt;

          final aDate = aCompleted?.toDateTime();
          final bDate = bCompleted?.toDateTime();

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
    if (_sortDescending) {
      seriesCopy.sort((a, b) => comparator(b, a)); // Reverse the comparison
    } else {
      seriesCopy.sort(comparator);
    }

    return seriesCopy;
  }

  /// Build or refresh the cache with current parameters
  void _buildCache(Library library) {
    final rawSeries = library.series;
    final filteredSeries = _filterSeries(rawSeries);
    final sortedSeries = _sortSeries(filteredSeries, library);

    // Cache the sorted series
    _sortedSeriesCache = sortedSeries;

    // Build grouped cache if needed
    if (_showGrouped && _groupBy != GroupBy.none) {
      _groupedDataCache = _buildGroupedData(sortedSeries);
    } else {
      _groupedDataCache = null;
    }

    // Store current parameters
    _cacheParameters = _CacheParameters(
      currentView: _currentView,
      sortOrder: _sortOrder,
      groupBy: _groupBy,
      sortDescending: _sortDescending,
      showGrouped: _showGrouped,
      showHiddenSeries: Manager.settings.showHiddenSeries,
      showAnilistHiddenSeries: Manager.settings.showAnilistHiddenSeries,
      customListOrder: List.from(_customListOrder),
    );
  }

  /// Build the grouped data structure
  Map<String, List<Series>> _buildGroupedData(List<Series> allSeries) {
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
    final groups = <String, List<Series>>{};

    // Initialize groups based on custom list order
    for (final listName in _customListOrder) {
      groups[_getDisplayName(listName)] = [];
    }

    // Sort series into groups (using existing grouping logic)
    for (final series in allSeries) {
      if (series.isLinked) {
        if (series.anilistMappings.isNotEmpty) {
          bool allCompleted = true;
          final completedList = anilistProvider.userLists[AnilistListApiStatus.COMPLETED.name_];

          if (completedList != null) {
            for (final mapping in series.anilistMappings) {
              final isCompleted = completedList.entries.any((entry) => entry.media.id == mapping.anilistId);
              if (!isCompleted) {
                allCompleted = false;
                break;
              }
            }

            if (allCompleted) {
              final completedKey = StatusStatistic.statusNameToPretty(AnilistListApiStatus.COMPLETED.name_);
              if (groups.containsKey(completedKey)) {
                groups[completedKey]?.add(series);
                continue;
              }
            }
          }

          // Priority order for lists
          final listPriority = [
            AnilistListApiStatus.CURRENT.name_,
            AnilistListApiStatus.REPEATING.name_,
            AnilistListApiStatus.PAUSED.name_,
            AnilistListApiStatus.PLANNING.name_,
            AnilistListApiStatus.DROPPED.name_,
            AnilistListApiStatus.COMPLETED.name_,
          ];

          final seriesLists = <String>{};

          for (final mapping in series.anilistMappings) {
            for (final entry in anilistProvider.userLists.entries) {
              final listName = entry.key;
              if (listName.startsWith('custom_')) continue;

              final list = entry.value;
              final isInList = list.entries.any((listEntry) => listEntry.media.id == mapping.anilistId);

              if (isInList) {
                seriesLists.add(listName);
                break;
              }
            }
          }

          String? highestPriorityList;
          for (final listName in listPriority) {
            if (seriesLists.contains(listName)) {
              highestPriorityList = listName;
              break;
            }
          }

          if (highestPriorityList != null) {
            final displayName = StatusStatistic.statusNameToPretty(highestPriorityList);
            if (groups.containsKey(displayName)) {
              groups[displayName]?.add(series);
              continue;
            }
          }

          // Check custom lists
          bool foundInCustomList = false;
          for (final mapping in series.anilistMappings) {
            for (final entry in anilistProvider.userLists.entries) {
              final listName = entry.key;
              if (!listName.startsWith('custom_')) continue;

              final list = entry.value;
              if (list.entries.any((listEntry) => listEntry.media.id == mapping.anilistId)) {
                groups[StatusStatistic.statusNameToPretty(listName)]?.add(series);
                foundInCustomList = true;
                break;
              }
            }
            if (foundInCustomList) break;
          }

          if (foundInCustomList) continue;

          // Add to Unlinked if not found
          final unlinkedKey = groups.keys.firstWhere(
            (k) => k == 'Unlinked',
            orElse: () => groups.keys.first,
          );
          groups[unlinkedKey]?.add(series);
        }
      } else {
        // Unlinked series - use custom list name if specified and exists, otherwise use 'Unlinked'
        final availableListNames = anilistProvider.userLists.keys.toList()..add(AnilistService.statusListNameUnlinked);
        final effectiveListName = series.getEffectiveListName(availableListNames);
        final targetListName = _getDisplayName(effectiveListName);

        // Ensure the target group exists
        if (!groups.containsKey(targetListName)) //
          groups[targetListName] = [];

        groups[targetListName]?.add(series);
      }
    }

    // Remove empty groups
    groups.removeWhere((_, series) => series.isEmpty);
    return groups;
  }

  Widget get filterIcon {
    IconData icon;
    if (_showFilters)
      icon = FluentIcons.filter_solid;
    else
      icon = FluentIcons.filter;

    return Icon(icon);
  }

  double getHeight(int itemCount, double maxWidth) {
    // Use the stored column count if available, otherwise calculate based on width
    final int columns = previousGridColumnCount.value ?? ScreenUtils.crossAxisCount(maxWidth);

    // Calculate how many rows we need based on the fixed column count
    final int rowCount = (itemCount / columns).ceil();

    // Calculate the card width based on the fixed column count
    final double effectiveCardWidth = (maxWidth - ((columns - 1) * ScreenUtils.cardPadding)) / columns;

    // Calculate card height using the aspect ratio (ScreenUtils.kDefaultAspectRatio)
    final double effectiveCardHeight = effectiveCardWidth / ScreenUtils.kDefaultAspectRatio;

    // Total height includes cards plus padding between rows (but not at the bottom)
    final double totalHeight = (effectiveCardHeight * rowCount) + (rowCount > 1 ? (rowCount - 1) * ScreenUtils.cardPadding : 0);

    return totalHeight;
  }

  /// Filter the series in Hidden, Linked
  List<Series> _filterSeries(List<Series> series) {
    // Start with basic filtering (existing code)
    List<Series> filteredSeries = series;

    // Add filter for hidden series
    final bool showHidden = Manager.settings.showHiddenSeries;
    final bool showAnilistHidden = Manager.settings.showAnilistHiddenSeries;
    final bool onlyLinked = _currentView == LibraryView.linked;

    filteredSeries = filteredSeries.where((s) {
      if (!showHidden && s.isForcedHidden) return false;
      if (!showAnilistHidden && s.isAnilistHidden) return false;
      if (onlyLinked && !s.isLinked) return false;
      return true;
    }).toList();

    return filteredSeries;
  }

  String _getDisplayName(String listName) => listName == '__unlinked' ? 'Unlinked' : StatusStatistic.statusNameToPretty(listName);
  String _getApiName(String listName) => listName == 'Unlinked' ? '__unlinked' : StatusStatistic.statusNameToApi(listName);

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  void _selectLibraryFolder() async {
    setState(() => _isSelectingFolder = true);

    final String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Media Library Folder',
    );

    setState(() => _isSelectingFolder = false);

    if (selectedDirectory != null) {
      // ignore: use_build_context_synchronously
      final library = context.read<Library>();
      await library.setLibraryPath(selectedDirectory);
    }
  }

  void _navigateToSeries(Series series) {
    widget.onSeriesSelected(series.path);
  }

  /// Save preferences
  void _saveUserPreferences() {
    final settings = Manager.settings;
    settings.set('library_view', _currentView.toString());
    settings.set('library_sort_order', _sortOrder.toString());
    settings.set('library_sort_descending', _sortDescending);
    settings.set('library_group_by', _groupBy.toString());
    settings.set('library_show_grouped', _showGrouped);
    settings.set('library_list_order', json.encode(_customListOrder));
  }

  /// Load preferences
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
        if (decoded is List) _customListOrder = List<String>.from(decoded);
      } catch (_) {
        _customListOrder = [];
      }
    });
  }

  void toggleFiltersSidebar({bool? value}) {
    setState(() {
      _showFilters = value ?? !_showFilters;
      _filterHintShowing = false;
    });
  }

  void _onViewChanged(LibraryView? value) {
    if (value != null && value != _currentView) {
      invalidateSortCache(); // Invalidate cache when view changes
      setState(() => _currentView = value);
      _saveUserPreferences();
    }
  }

  void _onSortOrderChanged(SortOrder? value) {
    if (value != null && value != _sortOrder) {
      invalidateSortCache(); // Invalidate cache when sort order changes
      setState(() => _sortOrder = value);
      _saveUserPreferences();
    }
  }

  void _onSortDirectionChanged() {
    invalidateSortCache(); // Invalidate cache when sort direction changes
    setState(() => _sortDescending = !_sortDescending);
    _saveUserPreferences();
  }

  void _measureFirstCard() {
    if (!(firstCardKey.currentContext?.mounted ?? true)) return;

    final RenderBox? renderBox = firstCardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      final Size actualSize = renderBox.size;

      if (ScreenUtils.cardSize == null || ScreenUtils.cardSize!.width != actualSize.width || ScreenUtils.cardSize!.height != actualSize.height) {
        setState(() {
          ScreenUtils.cardSize = actualSize;
        });
      }
    }
  }

  void invalidateSortCache() {
    _sortedSeriesCache = null;
    _groupedDataCache = null;
    _cacheParameters = null;
  }

  /// Update or add a series to the sort cache
  void updateSeriesInSortCache(Series series) {
    if (_sortedSeriesCache == null) {
      // Cache doesn't exist, nothing to update
      return;
    }

    // Remove existing series with same path if it exists
    _sortedSeriesCache!.removeWhere((s) => s.path == series.path);

    // Add the updated series
    _sortedSeriesCache!.add(series);

    // Re-sort the cache since we added a new item
    final library = Provider.of<Library>(context, listen: false);
    _sortedSeriesCache = _sortSeries(_sortedSeriesCache!, library);

    // If grouped cache exists, rebuild it
    if (_groupedDataCache != null && _showGrouped && _groupBy != GroupBy.none) {
      _groupedDataCache = _buildGroupedData(_sortedSeriesCache!);
    }
  }

  /// Remove a hidden series from the cache without invalidating the entire cache
  void removeHiddenSeriesWithoutInvalidatingCache(Series series) {
    if (Manager.settings.showHiddenSeries) return; // No need to remove if hidden series are shown
    if (_sortedSeriesCache == null) return;

    // Remove from sorted cache
    _sortedSeriesCache!.removeWhere((s) => s.path == series.path);

    // Remove from grouped cache if it exists
    if (_groupedDataCache != null) {
      for (final entry in _groupedDataCache!.entries) {
        entry.value.removeWhere((s) => s.path == series.path);
      }
      // Remove empty groups
      _groupedDataCache!.removeWhere((_, seriesList) => seriesList.isEmpty);
    }
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<Library>();

    if (library.libraryPath == null) return _buildLibrarySelector();

    const double filterAngle = -0.01;
    const double width = 350;
    final double headerHeight = 63 * Manager.fontSizeMultiplier;

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
                    padding: EdgeInsets.only(right: 6.0, top: headerHeight + 16.0, left: 6.0),
                    child: _buildLibraryView(library),
                  ),
                ),
              ),

              // Library filters sidebar
              AnimatedPositioned(
                duration: shortStickyHeaderDuration,
                top: headerHeight + 16,
                right: _showFilters
                    ? -0
                    : _filterHintShowing
                        ? -(width - 50)
                        : -width,
                child: AnimatedRotation(
                  duration: shortStickyHeaderDuration,
                  turns: _filterHintShowing ? filterAngle : 0,
                  child: GestureDetector(
                    onTapDown: (_) => _filterHintShowing ? toggleFiltersSidebar() : null,
                    child: SizedBox(
                      height: ScreenUtils.height - headerHeight - 16 - ScreenUtils.kTitleBarHeight,
                      width: width,
                      child: Acrylic(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))),
                        blurAmount: 12,
                        elevation: 0,
                        luminosityAlpha: .4,
                        tint: darken(Manager.accentColor.lightest, .95),
                        child: _buildFiltersSidebar(),
                      ),
                    ),
                  ),
                ),
              ),
              // Mouse detection
              if (!_showFilters)
                AnimatedPositioned(
                  duration: shortStickyHeaderDuration,
                  right: _filterHintShowing ? -84 : -95,
                  child: AnimatedRotation(
                    duration: shortStickyHeaderDuration,
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
    return MouseRegion(
      cursor: _filterHintShowing ? SystemMouseCursors.click : MouseCursor.defer,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          AbsorbPointer(
            absorbing: _filterHintShowing,
            child: AnimatedOpacity(
              opacity: _filterHintShowing || !_showFilters ? 0.0 : 1.0,
              duration: shortStickyHeaderDuration,
              child: Padding(
                padding: const EdgeInsets.only(left: 32.0, right: 16.0, top: 32.0, bottom: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Display Options',
                        style: FluentTheme.of(context).typography.subtitle,
                      ),
                      VDiv(16),

                      // Library View Switch
                      InfoLabel(
                        label: 'View',
                        child: MouseButtonWrapper(
                          child: (_) => ComboBox<LibraryView>(
                            value: _currentView,
                            items: [
                              ComboBoxItem(value: LibraryView.all, child: Text('All Series')),
                              ComboBoxItem(value: LibraryView.linked, child: Text('Linked Series Only')),
                            ],
                            onChanged: _onViewChanged,
                          ),
                        ),
                      ),
                      VDiv(16),

                      // Grouping Toggle
                      MouseButtonWrapper(
                        child: (_) => ToggleSwitch(
                          checked: _showGrouped,
                          content: Text('Group by AniList Lists'),
                          onChanged: (value) {
                            setState(() {
                              _showGrouped = value;
                              _groupBy = value ? GroupBy.anilistLists : GroupBy.none;
                              invalidateSortCache(); // Invalidate cache when grouping changes
                              _saveUserPreferences();
                            });
                          },
                        ),
                      ),

                      VDiv(24),
                      Text(
                        'Sort Options',
                        style: FluentTheme.of(context).typography.subtitle,
                      ),
                      VDiv(16),

                      // Sort Order
                      InfoLabel(
                        label: 'Sort by',
                        child: Row(
                          children: [
                            MouseButtonWrapper(
                              child: (_) => ComboBox<SortOrder>(
                                value: _sortOrder,
                                items: SortOrder.values.map((order) => ComboBoxItem(value: order, child: Text(_getSortText(order)))).toList(),
                                onChanged: _onSortOrderChanged,
                              ),
                            ),
                            const SizedBox(width: 8),
                            MouseButtonWrapper(
                              child: (_) => IconButton(
                                icon: AnimatedRotation(
                                  duration: shortStickyHeaderDuration,
                                  turns: _sortDescending ? 0 : 1,
                                  child: Icon(_sortDescending ? FluentIcons.sort_lines : FluentIcons.sort_lines_ascending),
                                ),
                                onPressed: _onSortDirectionChanged,
                              ),
                            ),
                          ],
                        ),
                      ),
                      VDiv(12),

                      // Only show list order UI when grouping is enabled
                      if (_showGrouped) ...[
                        VDiv(24),
                        Text(
                          'List Order',
                          style: FluentTheme.of(context).typography.subtitle,
                        ),
                        VDiv(16),
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
            duration: shortStickyHeaderDuration,
            child: RotatedBox(
              quarterTurns: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Filters', style: FluentTheme.of(context).typography.title),
              ),
            ),
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
    if (_currentView == LibraryView.all) allLists.add('__unlinked');

    // If _customListOrder is empty or outdated, initialize with default order
    if (_customListOrder.isEmpty || _customListOrder.equals(allLists)) //
      _customListOrder = List.from(allLists);

    final double childHeight = 45;

    return SizedBox(
      height: _customListOrder.length * childHeight,
      child: ValueListenableBuilder(
          valueListenable: KeyboardState.ctrlPressedNotifier,
          builder: (context, isCtrlPressed, _) {
            return ReorderableListView.builder(
              physics: isCtrlPressed ? const NeverScrollableScrollPhysics() : null,
              itemCount: _customListOrder.length,
              buildDefaultDragHandles: false,
              clipBehavior: Clip.none,
              proxyDecorator: (child, index, animation) {
                final listName = _customListOrder[index];
                final displayName = _getDisplayName(listName);

                return AnimatedReorderableTile(
                  key: ValueKey('${listName}_dragging'),
                  listName: listName,
                  displayName: displayName,
                  index: index,
                  selected: true,
                  initialAnimation: true,
                  isReordering: true,
                );
              },
              onReorderStart: (_) => setState(() => _isReordering = true),
              onReorderEnd: (_) => setState(() => _isReordering = false),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;

                  final item = _customListOrder.removeAt(oldIndex);
                  _customListOrder.insert(newIndex, item);
                  invalidateSortCache(); // Invalidate cache when list order changes
                  _saveUserPreferences();
                });
              },
              prototypeItem: SizedBox(height: childHeight),
              itemBuilder: (context, index) {
                final listName = _customListOrder[index];
                final displayName = _getDisplayName(listName);

                return AnimatedReorderableTile(
                  key: ValueKey(listName),
                  listName: listName,
                  displayName: displayName,
                  index: index,
                  selected: false,
                  isReordering: _isReordering,
                );
              },
            );
          }),
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
              NormalButton(
                tooltip: 'Refresh the library',
                label: 'Refresh',
                onPressed: () => library.reloadLibrary(force: true),
              ),
              SizedBox(width: 8),
              SwitchButton(
                labelWidget: (textStyle) => Row(
                  children: [
                    filterIcon,
                    HDivPx(4),
                    Text('Filter & Display', style: textStyle),
                  ],
                ),
                isPressed: _showFilters,
                isFilled: true,
                onPressed: () => toggleFiltersSidebar(),
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

  Widget _buildLibraryView(Library library) {
    // Check if cache is valid and exists
    List<Series> seriesToDisplay;
    Map<String, List<Series>>? groupedData;

    if (_isCacheValid() && _sortedSeriesCache != null) {
      // Use cached data
      seriesToDisplay = _sortedSeriesCache!;
      groupedData = _groupedDataCache;
    } else {
      // Build cache
      _buildCache(library);
      seriesToDisplay = _sortedSeriesCache!;
      groupedData = _groupedDataCache;
    }

    displayedSeries = seriesToDisplay;

    if (displayedSeries.isEmpty)
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              FluentIcons.folder_open,
              size: 48,
              color: Colors.grey,
            ),
            VDiv(16),
            Text(_currentView == LibraryView.linked ? 'No linked series found. Link your series with Anilist first.' : 'No series found in your library'),
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

    return LayoutBuilder(builder: (context, constraints) {
      final bool hideLibrary = library.isIndexing;

      return Stack(
        children: [
          IgnorePointer(
            ignoring: hideLibrary,
            child: Opacity(
              opacity: hideLibrary ? 0 : 1,
              child: FadingEdgeScrollView(
                fadeEdges: const EdgeInsets.symmetric(vertical: 10),
                child: _buildSeriesGrid(displayedSeries, constraints.maxWidth, groupedData: groupedData, shimmer: false),
              ),
            ),
          ),
          if (hideLibrary) ...[
            Positioned.fill(
              child: _buildSeriesGrid(displayedSeries, constraints.maxWidth, groupedData: groupedData, shimmer: true),
            ),
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ProgressRing(),
                    VDiv(16),
                    Text('Please wait while the Library is being indexed...'),
                    // VDiv(16),
                    // TODO maybe image
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
    Widget episodesGrid(List<Series> list, ScrollController? controller, ScrollPhysics? physics, bool includePadding, {bool allowMeasurement = false, bool shimmer = false}) {
      assert(shimmer || (controller != null && physics != null));
      return ValueListenableBuilder(
        valueListenable: previousGridColumnCount,
        builder: (context, columns, __) {
          final List<Widget> children = List.generate(list.length, (index) {
            if (shimmer) return Shimmer(child: Container());

            final Series series_ = list[index % list.length];

            return SeriesCard(
              key: (index == 0 && allowMeasurement) ? firstCardKey : ValueKey('${series_.path}:${series_.effectivePosterPath ?? 'none'}'),
              series: series_,
              onTap: () => _navigateToSeries(series_),
            );
          });

          if (!shimmer && list.isNotEmpty && allowMeasurement) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _measureFirstCard();
            });
          }

          return GridView(
            padding: includePadding ? const EdgeInsets.only(top: 16, bottom: 8, right: 12) : EdgeInsets.zero,
            cacheExtent: (ScreenUtils.cardHeight ?? 200) * 5,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns ?? ScreenUtils.crossAxisCount(maxWidth),
              childAspectRatio: ScreenUtils.kDefaultAspectRatio,
              crossAxisSpacing: ScreenUtils.cardPadding,
              mainAxisSpacing: ScreenUtils.cardPadding,
            ),
            controller: controller,
            physics: physics,
            children: children,
          );
        },
      );
    }

    if (shimmer) return episodesGrid(series, null, null, true, allowMeasurement: false, shimmer: true);

    // If grouping is enabled and we have grouped data, show grouped view
    if (_groupBy != GroupBy.none && groupedData != null && _showGrouped) {
      return _buildGroupedViewFromCache(groupedData, maxWidth, episodesGrid);
    }

    return DynMouseScroll(
      stopScroll: KeyboardState.ctrlPressedNotifier,
      enableSmoothScroll: Manager.animationsEnabled,
      scrollAmount: ScreenUtils.paddedCardHeight,
      controller: widget.scrollController,
      durationMS: 300,
      animationCurve: Curves.ease,
      builder: (context, controller, physics) => episodesGrid(series, controller, physics, true, allowMeasurement: true),
    );
  }

  /// Build grouped view using cached grouped data
  Widget _buildGroupedViewFromCache(
    Map<String, List<Series>> groupedData,
    double maxWidth,
    Widget Function(List<Series>, ScrollController, ScrollPhysics, bool, {bool allowMeasurement}) episodesGrid,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: DynMouseScroll(
        stopScroll: KeyboardState.ctrlPressedNotifier,
        enableSmoothScroll: Manager.animationsEnabled,
        scrollAmount: ScreenUtils.paddedCardHeight,
        controller: widget.scrollController,
        durationMS: 300,
        animationCurve: Curves.ease,
        builder: (context, controller, physics) {
          // Pre-build all group widgets
          final List<Widget> groupWidgets = [];

          // Use the _customListOrder to determine display order
          final displayOrder = groupedData.keys.toList();
          displayOrder.sort((a, b) {
            // Get the original position in _customListOrder
            final aIndex = _customListOrder.indexOf(_getApiName(a));
            final bIndex = _customListOrder.indexOf(_getApiName(b));

            // If one is not found, put it at the end
            if (aIndex == -1) return 1;
            if (bIndex == -1) return -1;

            // Otherwise use the custom order
            return aIndex.compareTo(bIndex);
          });

          for (final groupName in displayOrder) {
            List<Series> seriesInGroup = groupedData[groupName]!;

            groupWidgets.add(Expander(
              initiallyExpanded: true,
              headerBackgroundColor: WidgetStatePropertyAll(FluentTheme.of(context).resources.cardBackgroundFillColorDefault.withOpacity(0.025)),
              contentBackgroundColor: FluentTheme.of(context).resources.cardBackgroundFillColorSecondary.withOpacity(0),
              header: Text(groupName, style: FluentTheme.of(context).typography.subtitle),
              trailing: Text('${seriesInGroup.length} series'),
              content: SizedBox(
                height: getHeight(seriesInGroup.length, maxWidth),
                child: episodesGrid(
                  seriesInGroup,
                  ScrollController(),
                  NeverScrollableScrollPhysics(),
                  false,
                  allowMeasurement: groupName == displayOrder.first, // Only measure the first group for card size
                ),
              ),
            ));
          }

          return ListView(
            padding: EdgeInsets.only(right: 16),
            controller: controller,
            physics: physics,
            children: groupWidgets,
          );
        },
      ),
    );
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
}
