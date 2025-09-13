import 'dart:convert';
import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
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
import '../utils/path_utils.dart';
import '../utils/screen_utils.dart';
import '../utils/time_utils.dart';
import '../widgets/animated_order_tile.dart';
import '../widgets/buttons/button.dart';
import '../widgets/buttons/wrapper.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/infobar.dart';
import '../widgets/page/page.dart';
import '../widgets/series_card.dart';
import '../widgets/series_list_tile.dart';

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
  ViewType _viewType = ViewType.grid;
  SortOrder? _sortOrder;
  GroupBy _groupBy = GroupBy.anilistLists;

  bool _sortDescending = false;
  bool _showGrouped = false;

  bool _editListsEnabled = false;
  List<String> _previousCustomListOrder = [];

  final GlobalKey firstCardKey = GlobalKey();
  bool _isSelectingFolder = false;
  bool _isReordering = false;

  List<String> _customListOrder = [];
  List<Series> displayedSeries = [];

  // Cache system
  List<Series>? _sortedSeriesCache;
  Map<String, List<Series>>? _groupedDataCache;
  _CacheParameters? _cacheParameters;

  /// Create a styled scrollbar with consistent theming and right padding
  Widget _buildStyledScrollbar(Widget child) {
    return Scrollbar(
      controller: widget.scrollController,
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

        if (liveSeries != null && liveSeries.dominantColor != cachedSeries.dominantColor) {
          // Update the cached series with the new dominant color
          _sortedSeriesCache![i] = cachedSeries.copyWith(dominantColor: liveSeries.dominantColor);
        } else {
          log('No live series found for path: ${cachedSeries.path.path}');
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
              groupSeriesList[i] = cachedSeries.copyWith(dominantColor: liveSeries.dominantColor);
            } else {
              log('No live series found for path: ${cachedSeries.path.path}');
            }
          }
        }
      } else {
        log('Grouped data cache is null, skipping grouped update.');
      }
    }); // Trigger UI update
    Manager.setState(() {});
    log('called setState from updateColorsInSortCache');
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
              labelStyle: Manager.smallSubtitleStyle.copyWith(color: Manager.pastelDominantColor),
              child: _buildViewTypePills(),
            ),

            VDiv(24),

            // Sort Order
            InfoLabel(
              label: 'Sort by',
              labelStyle: Manager.smallSubtitleStyle.copyWith(color: Manager.pastelDominantColor),
              child: Row(
                children: [
                  Expanded(
                    child: MouseButtonWrapper(
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
                        tooltip: 'Sort results ${!_sortDescending ? "Ascendingly" : "Descendingly"}',
                        tooltipWaitDuration: Duration(milliseconds: 150),
                        padding: EdgeInsets.zero,
                        label: Center(
                          child: AnimatedRotation(
                            duration: shortStickyHeaderDuration,
                            turns: _sortDescending ? 0 : 1,
                            child: Icon(_sortDescending ? FluentIcons.sort_lines : FluentIcons.sort_lines_ascending, color: Manager.pastelDominantColor),
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
                    style: Manager.smallSubtitleStyle.copyWith(color: Manager.pastelDominantColor),
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
                          icon: Icon(_editListsEnabled ? FluentIcons.check_mark : FluentIcons.edit, size: 11 * Manager.fontSizeMultiplier, color: Manager.pastelDominantColor),
                          onPressed: () {
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
                            icon: Icon(Symbols.rotate_left, size: 11, color: Manager.pastelDominantColor),
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
      // Ensure all current lists are present in _customListOrder, add missing ones at the end
      for (final listName in allLists) {
        if (!_customListOrder.contains(listName)) {
          _customListOrder.add(listName);
        }
      }
      // Remove any lists that no longer exist
      _customListOrder.removeWhere((listName) => !allLists.contains(listName));
    }

    final double childHeight = 40;

    return SizedBox(
      height: _customListOrder.length * childHeight,
      child: ValueListenableBuilder(
        valueListenable: KeyboardState.ctrlPressedNotifier,
        builder: (context, isCtrlPressed, _) {
          // Non-reorderable view when editing is disabled
          if (!_editListsEnabled) {
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _customListOrder.length,
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
                  isReordering: false,
                  reorderable: false,
                );
              },
            );
          }

          // Reorderable view when editing is enabled
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
                reorderable: true,
              );
            },
            onReorderStart: (_) => setState(() => _isReordering = true),
            onReorderEnd: (_) => setState(() => _isReordering = false),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) newIndex -= 1;

                final item = _customListOrder.removeAt(oldIndex);
                _customListOrder.insert(newIndex, item);
                invalidateSortCache();
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
                    color: isSelected ? Manager.accentColor.lightest : Colors.white.withOpacity(0.2),
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
          // LOADING
          if (hideLibrary) ...[
            Positioned.fill(child: _buildSeriesGrid(displayedSeries, constraints.maxWidth, groupedData: groupedData, shimmer: true)),
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ProgressRing(), // TODO use actual line loading indicator from statusbar and hide statusbar while on library screen while indexing
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
    final Widget content = (_viewType == ViewType.grid)
        // Grid view
        ? _buildGridView(series, maxWidth, groupedData: groupedData, shimmer: shimmer)
        // List view
        : Container(child: _buildListView(series, maxWidth, groupedData: groupedData, shimmer: shimmer));

    return content;
  }

  Widget _buildGridView(List<Series> series, double maxWidth, {Map<String, List<Series>>? groupedData, bool shimmer = false}) {
    Widget episodesGrid(List<Series> list, ScrollController? controller, ScrollPhysics? physics, bool includePadding, {bool allowMeasurement = false, bool shimmer = false}) {
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

            final Series series_ = list[index % list.length];

            return SeriesCard(
              key: (index == 0 && allowMeasurement) ? firstCardKey : ValueKey('${series_.path}:${series_.effectivePosterPath ?? 'none'}'),
              series: series_,
              onTap: () => _navigateToSeries(series_),
            );
          });

          return GridView(
            padding: includePadding ? const EdgeInsets.only(bottom: 8) : EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns ?? ScreenUtils.crossAxisCount(maxWidth),
              childAspectRatio: ScreenUtils.kDefaultAspectRatio,
              crossAxisSpacing: ScreenUtils.cardPadding,
              mainAxisSpacing: ScreenUtils.cardPadding,
            ),
            controller: controller,
            physics: shimmer ? NeverScrollableScrollPhysics() : physics,
            children: children,
          );
        },
      );
    }

    // Shimmer view (loading)
    if (shimmer) //
      return LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          height: math.min(constraints.maxHeight, ScreenUtils.height - ScreenUtils.kMinHeaderHeight - ScreenUtils.kTitleBarHeight - 32),
          child: Shimmer.fromColors(
            baseColor: Colors.white.withOpacity(0.15),
            highlightColor: Colors.white,
            child: episodesGrid(series, null, null, true, allowMeasurement: false, shimmer: true),
          ),
        );
      });

    // Grouped View
    if (_groupBy != GroupBy.none && groupedData != null && _showGrouped) //
      return _buildGroupedViewFromCache(groupedData, maxWidth, episodesGrid);

    // Ungrouped view
    final scrollContent = ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(overscroll: false, platform: TargetPlatform.windows, scrollbars: false),
      child: DynMouseScroll(
        controller: shimmer ? null : widget.scrollController,
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
      ),
    );

    // Add Scrollbar for non-shimmer content
    if (shimmer) return scrollContent;

    return _buildStyledScrollbar(scrollContent);
  }

  Widget _buildListView(List<Series> series, double maxWidth, {Map<String, List<Series>>? groupedData, bool shimmer = false}) {
    Widget buildListContent(List<Series> list, ScrollController? controller, ScrollPhysics? physics, bool includePadding) {
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
                      final series = list[index];
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

    final scrollContent = ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(overscroll: false, platform: TargetPlatform.windows, scrollbars: false), // show only when not shimmer
      child: DynMouseScroll(
        controller: shimmer ? null : widget.scrollController,
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
                  physics: physics,
                  padding: EdgeInsets.zero,
                  itemCount: displayOrder.length,
                  itemBuilder: (context, index) {
                    final groupName = displayOrder[index];
                    final seriesList = groupedData[groupName] ?? [];
                    final isFirstGroup = index == 0;

                    if (seriesList.isEmpty) return const SizedBox.shrink();

                    return Padding(
                      padding: EdgeInsets.only(top: isFirstGroup ? 0 : 8.0),
                      child: StickyHeader(
                        header: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(ScreenUtils.kStatCardBorderRadius)),
                          child: Acrylic(
                            luminosityAlpha: 1,
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 50.0),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(ScreenUtils.kStatCardBorderRadius),
                                  topRight: Radius.circular(ScreenUtils.kStatCardBorderRadius),
                                ),
                                color: Colors.white.withOpacity(0.05),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                          ),
                        ),
                        content: Column(
                          children: [
                            const SizedBox(height: 8),

                            // Group content with headers and list
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Manager.genericGray.withOpacity(0.2)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SizedBox(
                                height: 53.5 * seriesList.length + 33 + 2, // +33 for header
                                child: buildListContent(seriesList, null, const NeverScrollableScrollPhysics(), false),
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
      ),
    );

    // Add Scrollbar for non-shimmer content
    if (shimmer) return scrollContent;

    return _buildStyledScrollbar(scrollContent);
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
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
    );
  }

  /// Build grouped view using cached grouped data with sticky headers
  Widget _buildGroupedViewFromCache(
    Map<String, List<Series>> groupedData,
    double maxWidth,
    Widget Function(List<Series>, ScrollController, ScrollPhysics, bool, {bool allowMeasurement}) episodesGrid,
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

    final scrollContent = ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(overscroll: false, platform: TargetPlatform.windows, scrollbars: false),
      child: DynMouseScroll(
        controller: widget.scrollController,
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
                  final isFirstGroup = index == 0;

                  return ClipRRect(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: const BorderRadius.all(Radius.circular(ScreenUtils.kStatCardBorderRadius)),
                    child: Padding(
                      padding: EdgeInsets.only(top: isFirstGroup ? 0 : 8.0),
                      child: StickyHeader(
                        header: Transform.translate(
                          offset: const Offset(0, -1),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(ScreenUtils.kStatCardBorderRadius)),
                            child: Acrylic(
                              luminosityAlpha: 1,
                              child: Container(
                                constraints: const BoxConstraints(minHeight: 50.0),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(ScreenUtils.kStatCardBorderRadius),
                                    topRight: Radius.circular(ScreenUtils.kStatCardBorderRadius),
                                  ),
                                  color: Colors.white.withOpacity(0.05),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(groupName, style: Manager.subtitleStyle),
                                    Text('${seriesInGroup.length} Series', style: Manager.captionStyle),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        content: ClipRRect(
                          borderRadius: BorderRadius.only(topRight: Radius.circular(ScreenUtils.kStatCardBorderRadius)),
                          child: ValueListenableBuilder(
                            valueListenable: previousGridColumnCount,
                            builder: (context, columns, __) {
                              final crossAxisCount = columns ?? ScreenUtils.crossAxisCount(maxWidth);

                              return GridView.builder(
                                padding: const EdgeInsets.only(bottom: 8.0, left: 0.3, right: 0.3, top: 8.0),
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: ScreenUtils.kDefaultAspectRatio,
                                  crossAxisSpacing: ScreenUtils.cardPadding,
                                  mainAxisSpacing: ScreenUtils.cardPadding,
                                ),
                                itemCount: seriesInGroup.length,
                                itemBuilder: (context, seriesIndex) {
                                  final series = seriesInGroup[seriesIndex];

                                  // Add measurement capability for first card
                                  Widget seriesCard = SeriesCard(
                                    key: (seriesIndex == 0 && isFirstGroup) ? firstCardKey : ValueKey('${series.path}:${series.effectivePosterPath ?? 'none'}'),
                                    series: series,
                                    onTap: () => _navigateToSeries(series),
                                  );

                                  return seriesCard;
                                },
                              );
                            },
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
      ),
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
