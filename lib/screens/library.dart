import 'dart:convert';
import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as mat;
import 'package:material_symbols_icons/symbols.dart';
import 'package:miruryoiki/manager.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../main.dart';
import '../enums.dart';
import '../models/anilist/user_data.dart';
import '../models/anilist/user_list.dart';
import '../services/anilist/queries/anilist_service.dart';
import '../services/library/library_provider.dart';
import '../models/series.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../services/navigation/shortcuts.dart';
import '../utils/logging.dart';
import '../utils/path.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import '../widgets/acrylic_header.dart';
import '../widgets/animated_order_tile.dart';
import '../widgets/buttons/button.dart';
import '../widgets/buttons/wrapper.dart';
import '../widgets/dialogs/splash/progress.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/infobar.dart';
import '../widgets/page/page.dart';
import '../widgets/series_card.dart';
import '../widgets/series_list_tile.dart';
import '../widgets/tooltip_wrapper.dart';

// Cache parameters to track when cache needs invalidation
class _CacheParameters {
  final LibraryView currentView;
  final SortOrder? sortOrder;
  final GroupBy groupBy;
  final bool sortDescending;
  final bool showGrouped;
  final bool showHiddenSeries;
  final bool showAnilistHiddenSeries;
  final List<String> customListOrder;
  final Set<String> hiddenLists;

  _CacheParameters({
    required this.currentView,
    required this.sortOrder,
    required this.groupBy,
    required this.sortDescending,
    required this.showGrouped,
    required this.showHiddenSeries,
    required this.showAnilistHiddenSeries,
    required this.customListOrder,
    required this.hiddenLists,
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
          _listEquals(customListOrder, other.customListOrder) &&
          _setEquals(hiddenLists, other.hiddenLists);

  @override
  int get hashCode =>
      currentView.hashCode ^ //
      sortOrder.hashCode ^
      groupBy.hashCode ^
      sortDescending.hashCode ^
      showGrouped.hashCode ^
      showHiddenSeries.hashCode ^
      showAnilistHiddenSeries.hashCode ^
      customListOrder.hashCode ^
      hiddenLists.hashCode;

  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null) return false;
    if (a.length != b.length) return false;
    for (int index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  static bool _setEquals<T>(Set<T>? a, Set<T>? b) {
    if (a == null) return b == null;
    if (b == null) return false;
    if (a.length != b.length) return false;
    return a.containsAll(b);
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

class LibraryScreenState extends State<LibraryScreen> with AutomaticKeepAliveClientMixin {
  LibraryView _currentView = LibraryView.all;
  ViewType _viewType = ViewType.grid;
  SortOrder? _sortOrder;
  GroupBy _groupBy = GroupBy.anilistLists;

  @override
  bool get wantKeepAlive => true;

  bool _sortDescending = false;
  bool _showGrouped = false;

  bool _editListsEnabled = false;
  List<String> _previousCustomListOrder = [];

  final GlobalKey firstCardKey = GlobalKey();
  bool _isSelectingFolder = false;
  bool _isReordering = false;

  // Global keys for each group to enable scrolling
  final Map<String, GlobalKey> _groupKeys = {};

  List<String> _customListOrder = [];
  Set<String> _hiddenLists = {}; // API names of hidden lists
  List<Series> displayedSeries = [];

  // Cache system
  List<Series>? _sortedSeriesCache;
  Map<String, List<Series>>? _groupedDataCache;
  _CacheParameters? _cacheParameters;

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

  /// Create a styled scrollbar with consistent theming and right padding
  Widget _buildStyledScrollbar(Widget child) {
    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      style: ScrollbarThemeData(
        thickness: 3,
        hoveringThickness: 4.5,
        radius: const Radius.circular(4),
        backgroundColor: Colors.transparent,
        scrollbarPressingColor: Manager.accentColor.lightest.withOpacity(.7),
        contractDelay: const Duration(milliseconds: 200),
        scrollbarColor: Manager.accentColor.lightest.withOpacity(.4),
        trackBorderColor: Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: ScrollConfiguration(
          behavior: ScrollBehavior().copyWith(overscroll: false, scrollbars: false, physics: const ClampingScrollPhysics()),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(ScreenUtils.kStatCardBorderRadius)),
            child: child,
          ),
        ),
      ),
    );
  }

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
      hiddenLists: Set.from(_hiddenLists),
    );

    return _cacheParameters == currentParams;
  }

  /// Sort series using the same logic as isolate_manager.dart but in main thread
  List<Series> _sortSeries(List<Series> series, Library library) {
    final List<Series> seriesCopy = List.from(series);

    Comparator<Series> comparator;

    switch (_sortOrder) {
      // Alphabetical order by title
      case null:
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

    // Clean up group keys after building cache
    _cleanupGroupKeys();

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
      hiddenLists: Set.from(_hiddenLists),
    );
  }

  /// Build the grouped data structure
  Map<String, List<Series>> _buildGroupedData(List<Series> allSeries) {
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
    final groups = <String, List<Series>>{};

    // Initialize groups based on custom list order (excluding hidden lists)
    for (final listName in _customListOrder) {
      if (!_hiddenLists.contains(listName)) {
        groups[_getDisplayName(listName)] = [];
      }
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

          // Check custom lists first (these are non-exclusive, so series can be in multiple lists)
          // Track which custom lists this series has been added to (to prevent duplicates)
          final addedToCustomLists = <String>{};

          for (final mapping in series.anilistMappings) {
            for (final entry in anilistProvider.userLists.entries) {
              final listName = entry.key;
              if (!listName.startsWith('custom_')) continue;

              final list = entry.value;
              if (list.entries.any((listEntry) => listEntry.media.id == mapping.anilistId)) {
                final prettyListName = StatusStatistic.statusNameToPretty(listName);
                // Only add if we haven't already added this series to this custom list
                if (groups.containsKey(prettyListName) && !addedToCustomLists.contains(prettyListName)) {
                  groups[prettyListName]?.add(series);
                  addedToCustomLists.add(prettyListName);
                }
              }
            }
          }

          // Add to standard list (or Unlinked if not found)
          if (highestPriorityList != null) {
            final displayName = StatusStatistic.statusNameToPretty(highestPriorityList);
            if (groups.containsKey(displayName)) {
              groups[displayName]?.add(series);
            }
          } else {
            // Add to Unlinked if not found in any standard list
            final unlinkedKey = groups.keys.firstWhere(
              (k) => k == 'Unlinked',
              orElse: () => groups.keys.first,
            );
            groups[unlinkedKey]?.add(series);
          }
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
    settings.set('library_view_type', _viewType.toString());
    settings.set('library_sort_order', _sortOrder.toString());
    settings.set('library_sort_descending', _sortDescending);
    settings.set('library_group_by', _groupBy.toString());
    settings.set('library_show_grouped', _showGrouped);
    settings.set('library_list_order', json.encode(_customListOrder));
    settings.set('library_hidden_lists', json.encode(_hiddenLists.toList()));
  }

  /// Load preferences
  void _loadUserPreferences() {
    final manager = Manager.settings;
    setState(() {
      // Load view
      final viewString = manager.get('library_view', defaultValue: LibraryView.all.toString());
      _currentView = viewString == LibraryView.linked.toString() ? LibraryView.linked : LibraryView.all;

      // Load view type
      final viewTypeString = manager.get('library_view_type', defaultValue: ViewType.grid.toString());
      for (final viewType in ViewType.values) {
        if (viewType.toString() == viewTypeString) {
          _viewType = viewType;
          break;
        }
      }

      // Load sort order
      final sortOrderString = manager.get('library_sort_order', defaultValue: SortOrder.alphabetical.toString());
      for (final order in SortOrder.values) {
        if (order.toString() == sortOrderString && order.toString() != SortOrder.alphabetical.name) {
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

      // Load hidden lists
      final hiddenListsString = manager.get('library_hidden_lists', defaultValue: '[]');

      try {
        final decoded = json.decode(hiddenListsString);
        if (decoded is List) _hiddenLists = Set<String>.from(decoded);
      } catch (_) {
        _hiddenLists = {};
      }
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

  void invalidateSortCache() {
    _sortedSeriesCache = null;
    _groupedDataCache = null;
    _cacheParameters = null;
  }

  void _cleanupGroupKeys() {
    if (_groupedDataCache == null) {
      _groupKeys.clear();
      return;
    }

    // Remove keys for groups that no longer exist
    final currentGroups = _groupedDataCache!.keys.toSet();
    _groupKeys.removeWhere((groupName, key) => !currentGroups.contains(groupName));
  }

  void _scrollToList(String targetListName) {
    if (_groupedDataCache == null) return;

    // Find the index of the target list in the sorted display order
    final displayOrder = _groupedDataCache!.keys.toList();
    displayOrder.sort((a, b) {
      final aIndex = _customListOrder.indexOf(_getApiName(a));
      final bIndex = _customListOrder.indexOf(_getApiName(b));
      if (aIndex == -1) return 1;
      if (bIndex == -1) return -1;
      return aIndex.compareTo(bIndex);
    });

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

    if (_groupedDataCache != null) {
      final displayOrder = _groupedDataCache!.keys.toList();

      for (int i = 0; i < targetIndex && i < displayOrder.length; i++) {
        final groupName = displayOrder[i];
        final seriesInGroup = _groupedDataCache![groupName] ?? [];

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

  void updateColorsInSortCache() {
    if (_sortedSeriesCache == null) return;

    final library = Provider.of<Library>(context, listen: false);
    final liveSeries = library.series;

    // Create a lookup map for efficient series matching by path
    final liveSeriesMap = <String, Series>{};
    for (final series in liveSeries) {
      liveSeriesMap[series.path.path] = series;
    }

    setState(() {
      // Update dominant colors in the sorted cache
      for (int i = 0; i < _sortedSeriesCache!.length; i++) {
        final cachedSeries = _sortedSeriesCache![i];
        final liveSeries = liveSeriesMap[cachedSeries.path.path];

        if (liveSeries != null && liveSeries.localPosterColor != cachedSeries.localPosterColor) {
          // Update the cached series with the new dominant color
          _sortedSeriesCache![i] = cachedSeries.copyWith(posterColor: liveSeries.localPosterColor);
        } else {
          logTrace('No live series found for path: ${cachedSeries.path.path}');
        }
      }

      // Update grouped cache if it exists
      if (_groupedDataCache != null) {
        for (final groupEntry in _groupedDataCache!.entries) {
          final groupSeriesList = groupEntry.value;

          for (int i = 0; i < groupSeriesList.length; i++) {
            final cachedSeries = groupSeriesList[i];
            final liveSeries = liveSeriesMap[cachedSeries.path.path];

            if (liveSeries != null) {
              // Update the cached series with the new dominant color
              groupSeriesList[i] = cachedSeries.copyWith(posterColor: liveSeries.localPosterColor);
            } else {
              logTrace('No live series found for path: ${cachedSeries.path.path}');
            }
          }
        }
      } else {
        logTrace('Grouped data cache is null, skipping grouped update.');
      }
    }); // Trigger UI update
    Manager.setState(() {});
    logTrace('called setState from updateColorsInSortCache');
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
    super.build(context); // for AutomaticKeepAliveClientMixin

    final library = context.watch<Library>();

    if (library.libraryPath == null) return _buildLibrarySelector();

    return MiruRyoikiTemplatePage(
      headerWidget: _buildHeader(library),
      content: _buildLibraryView(library),
      infobar: (_) => _buildFiltersSidebar(),
      headerMaxHeight: ScreenUtils.kMinHeaderHeight,
      headerMinHeight: ScreenUtils.kMinHeaderHeight,
      noHeaderBanner: true,
      scrollableContent: false,
      contentExtraHeaderPadding: true,
    );
  }

  MiruRyoikiInfobar _buildFiltersSidebar() {
    final bool isResetDisabled = _listEquals(_customListOrder, _previousCustomListOrder);

    return MiruRyoikiInfobar(
      content: ValueListenableBuilder(
        valueListenable: KeyboardState.zoomReleaseNotifier,
        builder: (context, _, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Library View Switch
            InfoLabel(
              label: 'View',
              labelStyle: Manager.smallSubtitleStyle.copyWith(color: Manager.pastelDominantColor),
              child: MouseButtonWrapper(
                tooltip: _currentView == LibraryView.all ? 'Show all series' : 'Show only series linked to AniList',
                child: (_) => ComboBox<LibraryView>(
                  isExpanded: true,
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
              tooltip: _showGrouped ? 'Display series grouped by AniList lists' : 'Display series in a flat list',
              child: (_) => ToggleSwitch(
                checked: _showGrouped,
                content: Expanded(child: Text('Group by AniList Lists', style: Manager.bodyStyle, maxLines: 2, overflow: TextOverflow.ellipsis)),
                onChanged: (value) {
                  setState(() {
                    _showGrouped = value;
                    _groupBy = value ? GroupBy.anilistLists : GroupBy.none;
                    _saveUserPreferences();
                    invalidateSortCache(); // Invalidate cache when grouping changes
                  });
                },
              ),
            ),
            VDiv(24),

            // View Type Selector
            InfoLabel(
              label: 'Display',
              labelStyle: Manager.smallSubtitleStyle.copyWith(color: Manager.pastelAccentColor),
              child: _buildViewTypePills(),
            ),

            VDiv(24),

            // Sort Order
            InfoLabel(
              label: 'Sort by',
              labelStyle: Manager.smallSubtitleStyle.copyWith(color: Manager.pastelAccentColor),
              child: Row(
                children: [
                  Expanded(
                    child: MouseButtonWrapper(
                    tooltip: _sortOrder?.name_,
                      child: (_) => ComboBox<SortOrder>(
                        isExpanded: true,
                        value: _sortOrder,
                        placeholder: const Text('Sort By'),
                        items: SortOrder.values.map((order) => ComboBoxItem(value: order, child: Text(_getSortText(order)))).toList(),
                        onChanged: _onSortOrderChanged,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                      height: 34,
                      width: 34,
                      child: StandardButton(
                        tooltip: 'Sort results in ${!_sortDescending ? "Ascending" : "Descending"} order',
                        tooltipWaitDuration: Duration(milliseconds: 150),
                        padding: EdgeInsets.zero,
                        label: Center(
                          child: AnimatedRotation(
                            duration: shortStickyHeaderDuration,
                            turns: _sortDescending ? 0 : 1,
                            child: Icon(_sortDescending ? FluentIcons.sort_lines : FluentIcons.sort_lines_ascending, color: Manager.pastelAccentColor),
                          ),
                        ),
                        onPressed: _onSortDirectionChanged,
                      )),
                ],
              ),
            ),

            // Only show list order UI when grouping is enabled
            if (_showGrouped) ...[
              VDiv(24),
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
                        tooltip: _editListsEnabled ? 'Save Changes' : 'Edit List Order',
                        child: (_) => IconButton(
                          icon: Icon(_editListsEnabled ? FluentIcons.check_mark : FluentIcons.edit, size: 11 * Manager.fontSizeMultiplier, color: Manager.pastelAccentColor),
                          onPressed:() {
                                  setState(() => _editListsEnabled = !_editListsEnabled);
                                  if (_editListsEnabled) _previousCustomListOrder = List.from(_customListOrder);
                                },
                        ),
                      ),
                    ),
                  ),
                  if (_editListsEnabled && !isResetDisabled) ...[
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
                            onPressed: isResetDisabled
                                ? null
                                : () {
                                    setState(() {
                                      _customListOrder = List.from(_previousCustomListOrder);
                                      // _editListsEnabled = false;
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
          ],
        ),
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

    // If _customListOrder is empty, initialize with default order
    if (_customListOrder.isEmpty) {
      _customListOrder = List.from(allLists);
    } else {
      // Ensure all current lists are present in _customListOrder
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
        }
      }
      // Remove any lists that no longer exist
      _customListOrder.removeWhere((listName) => !allLists.contains(listName));
    }

    // Filter out hidden lists when not in edit mode for display purposes
    final displayListOrder = _editListsEnabled ? _customListOrder : _customListOrder.where((listName) => !_hiddenLists.contains(listName)).toList();

    final double childHeight = 40;

    return SizedBox(
      height: displayListOrder.length * childHeight,
      child: ValueListenableBuilder(
        valueListenable: KeyboardState.ctrlPressedNotifier,
        builder: (context, isCtrlPressed, _) {
          // Non-reorderable view when editing is disabled
          if (!_editListsEnabled) {
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayListOrder.length,
              prototypeItem: SizedBox(height: childHeight),
              itemBuilder: (context, index) {
                final listName = displayListOrder[index];
                final displayName = _getDisplayName(listName);

                // Check if list is empty by checking grouped data cache
                final isEmpty = _groupedDataCache != null && (_groupedDataCache![displayName]?.isEmpty ?? true);

                return AnimatedReorderableTile(
                  key: ValueKey(listName),
                  listName: listName,
                  displayName: displayName,
                  onPressed: (i) => _scrollToList(displayName),
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
              final displayName = _getDisplayName(listName);
              final isHidden = _hiddenLists.contains(listName);
              final isEmpty = _groupedDataCache != null && (_groupedDataCache![displayName]?.isEmpty ?? true);

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
                if (oldIndex < newIndex) newIndex -= 1;

                // Get the items being reordered
                final item = displayListOrder[oldIndex];

                // Find their positions in the full _customListOrder
                final actualOldIndex = _customListOrder.indexOf(item);

                // Calculate actual new index in _customListOrder
                int actualNewIndex;
                if (newIndex >= displayListOrder.length - 1) {
                  // Moving to the end: find the last visible item's position and place after it
                  final lastVisibleItem = displayListOrder.last;
                  actualNewIndex = _customListOrder.indexOf(lastVisibleItem);
                  if (actualOldIndex < actualNewIndex) {
                    actualNewIndex--; // Adjust for removal
                  }
                } else {
                  // Moving to a specific position: find the target item in _customListOrder
                  final targetItem = displayListOrder[newIndex];
                  actualNewIndex = _customListOrder.indexOf(targetItem);
                  if (actualOldIndex < actualNewIndex) {
                    actualNewIndex--; // Adjust for removal
                  }
                }

                _customListOrder.removeAt(actualOldIndex);
                _customListOrder.insert(actualNewIndex, item);
                invalidateSortCache();
                _saveUserPreferences();
              });
            },
            prototypeItem: SizedBox(height: childHeight),
            itemBuilder: (context, index) {
              final listName = displayListOrder[index];
              final displayName = _getDisplayName(listName);
              final isHidden = _hiddenLists.contains(listName);
              final isEmpty = _groupedDataCache != null && (_groupedDataCache![displayName]?.isEmpty ?? true);

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
                                            _hiddenLists.remove(listName);
                                          else
                                            _hiddenLists.add(listName);
                                        });
                  
                                        _saveUserPreferences();
                                        nextFrame(() {
                                          invalidateSortCache();
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

  Widget _buildViewTypePills() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ViewType.values.map((viewType) {
        final isSelected = _viewType == viewType;

        return Padding(
          padding: EdgeInsets.only(
            right: viewType == ViewType.values.last ? 0 : 6,
          ),
          child: MouseButtonWrapper(
            tooltip: _getViewTypeTooltip(viewType),
            tooltipWaitDuration: const Duration(milliseconds: 350),
            child: (_) => GestureDetector(
              onTap: () => _onViewTypeChanged(viewType),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? Manager.accentColor.light : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? Manager.accentColor.dark : Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getViewTypeIcon(viewType),
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getViewTypeLabel(viewType),
                      style: Manager.captionStyle.copyWith(
                        color: Colors.white,
                        fontSize: 11 * Manager.fontSizeMultiplier,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _onViewTypeChanged(ViewType viewType) {
    setState(() {
      _viewType = viewType;
    });
    _saveUserPreferences();
  }

  String _getViewTypeLabel(ViewType viewType) {
    switch (viewType) {
      case ViewType.grid:
        return 'Grid';
      case ViewType.detailedList:
        return 'List';
    }
  }

  IconData _getViewTypeIcon(ViewType viewType) {
    switch (viewType) {
      case ViewType.grid:
        return FluentIcons.grid_view_medium;
      case ViewType.detailedList:
        return FluentIcons.list;
    }
  }

  String _getViewTypeTooltip(ViewType viewType) {
    switch (viewType) {
      case ViewType.grid:
        return 'Display series as cards in a grid';
      case ViewType.detailedList:
        return 'Display series in a list';
    }
  }

  HeaderWidget _buildHeader(Library library) {
    return HeaderWidget(
      title: (_, __) => ValueListenableBuilder(
        valueListenable: KeyboardState.zoomReleaseNotifier,
        builder: (context, _, __) => Text(
          'Your Media Library',
          style: Manager.titleLargeStyle.copyWith(
            fontSize: 32 * Manager.fontSizeMultiplier,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      titleLeftAligned: true,
      children: <Widget>[
        ValueListenableBuilder(
          valueListenable: KeyboardState.zoomReleaseNotifier,
          builder: (context, _, __) => Text('Path: ${library.libraryPath}',
              style: Manager.bodyStyle.copyWith(
                fontSize: 14 * Manager.fontSizeMultiplier,
                color: Colors.white.withOpacity(.5),
              )),
        )
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
            Icon(
              FluentIcons.folder_open,
              size: 48,
              color: Manager.accentColor,
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
      // Only hide library content if it's an initial scan (first time or new path)
      // For normal scans show the library with disabled actions
      final bool hideLibrary = library.isIndexing && library.isInitialScan;
      if (homeKey.currentState?.isStartedTransitioning == false) {
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
              child: _buildSeriesGrid(displayedSeries, constraints.maxWidth, groupedData: groupedData, shimmer: false),
            ),
          ),
          // Shimmer only on initial scan
          if (hideLibrary) ...[
            Positioned.fill(child: _buildSeriesGrid(displayedSeries, constraints.maxWidth, groupedData: groupedData, shimmer: true)),
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
    final Widget content = (_viewType == ViewType.grid)
        // Grid view
        ? _buildGridView(series, maxWidth, groupedData: groupedData, shimmer: shimmer)
        // List view
        : Container(child: _buildListView(series, maxWidth, groupedData: groupedData, shimmer: shimmer));

    return content;
  }

  Widget _buildGridView(List<Series> series, double maxWidth, {Map<String, List<Series>>? groupedData, bool shimmer = false}) {
    Widget episodesGrid(List list, ScrollController? controller, ScrollPhysics? physics, bool includePadding, {bool allowMeasurement = false, bool shimmer = false, bool isNestedInScrollable = false}) {
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

            if (index == 0) {
              // Measure the first card to determine the number of columns
              measureCardSize();
            }
            return SeriesCard(
              key: (index == 0 && allowMeasurement) ? firstCardKey : ValueKey('${series_.path}:${series_.effectivePosterPath ?? 'none'}'),
              series: series_,
              onTap: () => _navigateToSeries(series_),
            );
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
    if (_groupBy != GroupBy.none && groupedData != null && _showGrouped) //
      return _buildGroupedViewFromCache(groupedData, maxWidth, episodesGrid);

    // Ungrouped view
    final scrollContent = DynMouseScroll(
      controller: shimmer ? null : _controller,
      stopScroll: KeyboardState.ctrlPressedNotifier,
      scrollSpeed: 1.0,
      enableSmoothScroll: Manager.animationsEnabled,
      durationMS: 350,
      animationCurve: Curves.easeOutQuint,
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
                    Widget seriesCard = SeriesCard(
                      key: (index == 0) ? firstCardKey : ValueKey('${serieItem.path}:${serieItem.effectivePosterPath ?? 'none'}'),
                      series: serieItem,
                      onTap: () => _navigateToSeries(serieItem),
                    );

                    return seriesCard;
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

    return _buildStyledScrollbar(scrollContent);
  }

  Widget _buildListView(List<Series> series, double maxWidth, {Map<String, List<Series>>? groupedData, bool shimmer = false}) {
    Widget buildListContent(List list, ScrollController? controller, ScrollPhysics? physics, bool includePadding) {
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
                ? _buildShimmerList()
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

    final scrollContent = DynMouseScroll(
      controller: shimmer ? null : _controller,
      stopScroll: KeyboardState.zoomReleaseNotifier,
      scrollSpeed: 1.0,
      enableSmoothScroll: Manager.animationsEnabled,
      durationMS: 350,
      animationCurve: Curves.easeOutQuint,
      builder: (context, controller, physics) {
        return ValueListenableBuilder(
          valueListenable: KeyboardState.zoomReleaseNotifier,
          builder: (context, _, __) {
            // Grouped View with Sticky Headers
            if (groupedData != null && _showGrouped) {
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
                                child: buildListContent(seriesList, null, const NeverScrollableScrollPhysics(), false),
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

    return _buildStyledScrollbar(scrollContent);
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
    Widget Function(List<Series>, ScrollController, ScrollPhysics, bool, {bool allowMeasurement, bool isNestedInScrollable}) episodesGrid,
  ) {
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

    final scrollContent = DynMouseScroll(
      controller: _controller,
      stopScroll: KeyboardState.zoomReleaseNotifier,
      scrollSpeed: 1.0,
      enableSmoothScroll: Manager.animationsEnabled,
      durationMS: 350,
      animationCurve: Curves.easeOutQuint,
      builder: (context, controller, physics) {
        return ValueListenableBuilder(
          valueListenable: KeyboardState.zoomReleaseNotifier,
          builder: (context, _, __) {
            return ListView.builder(
              controller: controller,
              padding: EdgeInsets.zero,
              cacheExtent: kDebugMode ? null : 1000,
              physics: physics,
              itemCount: displayOrder.length,
              itemBuilder: (context, index) {
                final groupName = displayOrder[index];
                final seriesInGroup = groupedData[groupName]!;
                final isLastGroup = index == displayOrder.length - 1;

                // Ensure we have a key for this group
                if (!_groupKeys.containsKey(groupName)) _groupKeys[groupName] = GlobalKey();

                return Container(
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
                          child: episodesGrid(seriesInGroup, controller, physics, false, allowMeasurement: index == 0, isNestedInScrollable: true),
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

    return _buildStyledScrollbar(scrollContent);
  }

  String _getSortText(SortOrder? order) {
    switch (order) {
      case null:
        return 'Sort by';
      case SortOrder.alphabetical:
        return 'Title (A-Z)';
      case SortOrder.score:
        return 'Score';
      case SortOrder.progress:
        return 'Progress';
      case SortOrder.lastModified:
        return 'Last Modified';
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

  bool _listEquals(List<String> customListOrder, List<String> previousCustomListOrder) {
    if (customListOrder.length != previousCustomListOrder.length) return false;
    for (int i = 0; i < customListOrder.length; i++) if (customListOrder[i] != previousCustomListOrder[i]) return false;
    return true;
  }
}
