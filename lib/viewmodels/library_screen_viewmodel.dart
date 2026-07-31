import 'dart:convert';

import '../enums.dart';
import '../manager.dart';
import '../models/anilist/user_data.dart';
import '../models/anilist/user_list.dart';
import '../models/series.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../services/anilist/queries/anilist_service.dart';
import '../services/episode_navigation/anilist_progress_manager.dart';
import '../services/library/library_provider.dart';
import '../services/library/search_service.dart';
import '../utils/logging.dart';
import '../utils/time.dart';
import 'disposable_view_model.dart';

/// Cache parameters to track when the sorted/grouped cache needs invalidation
class _CacheParameters {
  final LibraryView currentView;
  final SortOrder? sortOrder;
  final GroupBy groupBy;
  final bool sortDescending;
  final bool showGrouped;
  final bool showHiddenSeries;
  final bool showPrivateSeries;
  final List<String> customListOrder;
  final Set<String> hiddenLists;
  final List<String> selectedGenres;
  final int dataVersion;
  final int listsRevision;

  _CacheParameters({
    required this.currentView,
    required this.sortOrder,
    required this.groupBy,
    required this.sortDescending,
    required this.showGrouped,
    required this.showHiddenSeries,
    required this.showPrivateSeries,
    required this.customListOrder,
    required this.hiddenLists,
    required this.selectedGenres,
    required this.dataVersion,
    required this.listsRevision,
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
          showPrivateSeries == other.showPrivateSeries &&
          _listEquals(customListOrder, other.customListOrder) &&
          _setEquals(hiddenLists, other.hiddenLists) &&
          _listEquals(selectedGenres, other.selectedGenres) &&
          dataVersion == other.dataVersion &&
          listsRevision == other.listsRevision;

  @override
  int get hashCode =>
      currentView.hashCode ^ //
      sortOrder.hashCode ^
      groupBy.hashCode ^
      sortDescending.hashCode ^
      showGrouped.hashCode ^
      showHiddenSeries.hashCode ^
      showPrivateSeries.hashCode ^
      customListOrder.hashCode ^
      hiddenLists.hashCode ^
      selectedGenres.hashCode ^
      dataVersion.hashCode ^
      listsRevision.hashCode;

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

/// ViewModel for the Library screen.
///
/// Owns all library-view state (view/sort/group/filters/search/reorder), the sorted+grouped series
/// cache with parameter-based invalidation, custom per-group ordering, and preference persistence.
///
/// Registered app-wide via `ChangeNotifierProxyProvider2<Library, AnilistProvider, LibraryScreenViewModel>` in `main.dart`,
/// so dialogs and services can share it instead of reaching into the screen through `libraryScreenKey`.
class LibraryScreenViewModel extends DisposableViewModel {
  late Library _library;
  late AnilistProvider _anilist;
  int _lastListsRevision = 0;

  /// Called by the ChangeNotifierProxyProvider2 whenever [Library] or [AnilistProvider] notify
  void update(Library library, AnilistProvider anilist) {
    _library = library;
    _anilist = anilist;

    // The library screen watches this VM and [Library] directly.
    // Emit a notification when the revision changes.
    if (anilist.listsRevision != _lastListsRevision) {
      _lastListsRevision = anilist.listsRevision;
      nextFrame(() => notifySafe());
    }
  }

  // State

  LibraryView _currentView = LibraryView.all;
  ViewType _viewType = ViewType.grid;
  SortOrder? _sortOrder;
  GroupBy _groupBy = GroupBy.anilistLists;
  bool _sortDescending = false;
  bool _showGrouped = false;
  bool _isReorderMode = false;
  String _searchQuery = '';

  List<String> customListOrder = [];
  Set<String> hiddenLists = {}; // API names of hidden lists
  List<String> selectedGenres = [];
  List<Series> displayedSeries = [];

  /// Custom series order per userlist group (list API name -> ordered series paths)
  Map<String, List<String>> _customSeriesOrder = {};

  // Cache system
  List<Series>? _sortedSeriesCache;
  Map<String, List<Series>>? _groupedDataCache;
  _CacheParameters? _cacheParameters;

  LibraryView get currentView => _currentView;
  ViewType get viewType => _viewType;
  SortOrder get sortOrder => _sortOrder ?? SortOrder.alphabetical;
  SortOrder? get rawSortOrder => _sortOrder;
  GroupBy get groupBy => _groupBy;
  bool get sortDescending => _sortDescending;
  bool get showGrouped => _showGrouped;
  bool get isReorderMode => _isReorderMode;
  bool get isCustomSort => _sortOrder == SortOrder.custom;
  String get searchQuery => _searchQuery;
  Map<String, List<Series>>? get groupedDataCache => _groupedDataCache;

  bool get isGettingFiltered =>
      _searchQuery.isNotEmpty || //
      selectedGenres.isNotEmpty;

  // UI intents

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    notifySafe();
  }

  void clearSearch() => setSearchQuery('');

  void setViewType(ViewType viewType) {
    _viewType = viewType;
    saveUserPreferences();
    notifySafe();
  }

  void onViewChanged(LibraryView? value) {
    if (value != null && value != _currentView) {
      invalidateSortCache();
      _currentView = value;
      saveUserPreferences();
      notifySafe();
    }
  }

  void onShowGroupedChanged(bool value) {
    _showGrouped = value;
    _groupBy = value ? GroupBy.anilistLists : GroupBy.none;
    saveUserPreferences();
    invalidateSortCache();
    notifySafe();
  }

  void onSortOrderChanged(SortOrder? value) {
    if (value != null && value != _sortOrder) {
      invalidateSortCache();
      _sortOrder = value;
      // Exit reorder mode when switching away from custom sort
      if (value != SortOrder.custom) _isReorderMode = false;
      // Enable grouping when using custom sort (order is per-group)
      if (value == SortOrder.custom && !_showGrouped) {
        _showGrouped = true;
        _groupBy = GroupBy.anilistLists;
      }
      saveUserPreferences();
      notifySafe();
    }
  }

  void onSortDirectionChanged() {
    invalidateSortCache();
    _sortDescending = !_sortDescending;
    saveUserPreferences();
    notifySafe();
  }

  void addGenre(String genre) {
    if (!selectedGenres.contains(genre)) {
      selectedGenres.add(genre);
      _sortedSeriesCache = null; // Invalidate cache
      notifySafe();
    }
  }

  void removeGenre(String genre) {
    if (selectedGenres.contains(genre)) {
      selectedGenres.remove(genre);
      _sortedSeriesCache = null; // Invalidate cache
      notifySafe();
    }
  }

  void clearGenres() {
    if (selectedGenres.isNotEmpty) {
      selectedGenres.clear();
      _sortedSeriesCache = null; // Invalidate cache
      notifySafe();
    }
  }

  void setHiddenLists(Set<String> newHiddenLists) {
    hiddenLists = newHiddenLists;
    notifySafe();
  }

  void setCustomListOrder(List<String> newOrder) {
    customListOrder = newOrder;
    notifySafe();
  }

  // Reordering

  void toggleReorderMode() {
    _isReorderMode = !_isReorderMode;
    if (_isReorderMode) _initCustomOrderForGroups();
    notifySafe();
  }

  /// Initialize custom order for each group from the current grouped display
  void _initCustomOrderForGroups() {
    if (_groupedDataCache == null) return;

    for (final entry in _groupedDataCache!.entries) {
      final groupApiName = StatusStatistic.getApiName(entry.key);
      // Only initialize if this group doesn't have a custom order yet
      if (!_customSeriesOrder.containsKey(groupApiName) || _customSeriesOrder[groupApiName]!.isEmpty) //
        _customSeriesOrder[groupApiName] = entry.value.map((s) => s.path.path).toList();
    }

    invalidateSortCache();
    saveUserPreferences();
  }

  /// Reorder a series within a specific group
  void reorderSeriesInGroup(String groupDisplayName, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final groupApiName = StatusStatistic.getApiName(groupDisplayName);
    final groupSeries = _groupedDataCache?[groupDisplayName];
    if (groupSeries == null) return;

    // Ensure we have a custom order for this group
    if (!_customSeriesOrder.containsKey(groupApiName)) //
      _customSeriesOrder[groupApiName] = groupSeries.map((s) => s.path.path).toList();

    final order = _customSeriesOrder[groupApiName]!;
    final path = groupSeries[oldIndex].path.path;

    order.remove(path);
    if (newIndex < groupSeries.length) {
      final targetPath = groupSeries[newIndex].path.path;
      final targetIdx = order.indexOf(targetPath);
      if (targetIdx != -1)
        order.insert(oldIndex < newIndex ? targetIdx + 1 : targetIdx, path);
      else
        order.add(path);
    } else {
      order.add(path);
    }

    invalidateSortCache();
    saveUserPreferences();
    notifySafe();
  }

  // ─── Cache ───────────────────────────────────────────────────────────────

  void invalidateSortCache() {
    _sortedSeriesCache = null;
    _groupedDataCache = null;
    _cacheParameters = null;
    notifySafe();
  }

  _CacheParameters _currentCacheParameters() => _CacheParameters(
        currentView: _currentView,
        sortOrder: _sortOrder,
        groupBy: _groupBy,
        sortDescending: _sortDescending,
        showGrouped: _showGrouped,
        showHiddenSeries: Manager.settings.showHiddenSeries,
        showPrivateSeries: Manager.settings.showPrivateSeries,
        customListOrder: List.from(customListOrder),
        hiddenLists: Set.from(hiddenLists),
        selectedGenres: List.from(selectedGenres),
        dataVersion: _library.dataVersion,
        listsRevision: _anilist.listsRevision, // Invalidates the cache when AniList user lists change
      );

  /// Check if the current cache is valid by comparing parameters
  bool _isCacheValid() {
    if (_cacheParameters == null) return false;
    return _cacheParameters == _currentCacheParameters();
  }

  /// The series (and grouped data, when grouping) the screen should display,
  /// rebuilding the cache when parameters changed and applying the search filter on top.
  /// Also updates [displayedSeries].
  (List<Series>, Map<String, List<Series>>?) displayData() {
    List<Series> seriesToDisplay;
    Map<String, List<Series>>? groupedData;

    if (_isCacheValid() && _sortedSeriesCache != null) {
      seriesToDisplay = _sortedSeriesCache!;
      groupedData = _groupedDataCache;
    } else {
      _buildCache();
      seriesToDisplay = _sortedSeriesCache!;
      groupedData = _groupedDataCache;
    }

    // Apply search filter if there's a query
    if (_searchQuery.isNotEmpty) {
      seriesToDisplay = LibrarySearchService.search(_searchQuery, seriesToDisplay);

      // If grouped, rebuild groups with filtered series
      if (_showGrouped && _groupBy != GroupBy.none) {
        groupedData = _buildGroupedData(seriesToDisplay);
      } else {
        groupedData = null;
      }
    }

    displayedSeries = seriesToDisplay;
    return (seriesToDisplay, groupedData);
  }

  /// Build or refresh the cache with current parameters
  void _buildCache() {
    final progressManager = AnilistProgressManager.instance;
    final rawSeries = _library.series;
    final filteredSeries = _filterSeries(rawSeries);
    final sortedSeries = _sortSeries(filteredSeries, progressManager);

    // Cache the sorted series
    _sortedSeriesCache = sortedSeries;

    // Build grouped cache if needed
    if (_showGrouped && _groupBy != GroupBy.none) {
      _groupedDataCache = _buildGroupedData(sortedSeries);

      // Apply per-group custom ordering when using custom sort
      if (_sortOrder == SortOrder.custom && _groupedDataCache != null) {
        _applyCustomGroupOrdering();
      }
    } else {
      _groupedDataCache = null;
    }

    // Store current parameters
    _cacheParameters = _currentCacheParameters();
  }

  /// Filter the series in Hidden, Linked, Genres
  List<Series> _filterSeries(List<Series> series) {
    final bool showHidden = Manager.settings.showHiddenSeries;
    final bool showPrivate = Manager.settings.showPrivateSeries;
    final bool onlyLinked = _currentView == LibraryView.linked;

    return series.where((s) {
      if (!showHidden && s.isForcedHidden) return false;
      if (!showPrivate && _anilist.isAnilistPrivate(s)) return false;
      if (onlyLinked && !s.isLinked) return false;

      // Filter by genres
      if (selectedGenres.isNotEmpty) {
        final seriesGenres = s.currentAnilistData?.genres ?? [];
        // Check if series has ALL selected genres
        for (final genre in selectedGenres) {
          if (!seriesGenres.contains(genre)) return false;
        }
      }

      return true;
    }).toList();
  }

  /// Sort series using the same logic as isolate_manager.dart but in main thread
  List<Series> _sortSeries(List<Series> series, AnilistProgressManager progressManager) {
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
          final aProgress = progressManager.getSeriesProgress(a, _anilist);
          final bProgress = progressManager.getSeriesProgress(b, _anilist);
          return aProgress.compareTo(bProgress);
        };

      // Date the user's List Entry was last modified (progress update, status change)
      case SortOrder.lastModified:
        comparator = (a, b) {
          final aUpdated = _anilist.getLatestUpdatedAt(a) ?? 0;
          final bUpdated = _anilist.getLatestUpdatedAt(b) ?? 0;
          return aUpdated.compareTo(bUpdated);
        };

      // Date the user added the series to their list
      case SortOrder.dateAdded:
        comparator = (a, b) {
          final aCreated = _anilist.getEarliestCreatedAt(a) ?? 0;
          final bCreated = _anilist.getEarliestCreatedAt(b) ?? 0;
          return aCreated.compareTo(bCreated);
        };

      // Date the user started watching the series (earliest across all mappings)
      case SortOrder.startDate:
        comparator = (a, b) {
          final aDate = _anilist.getEarliestStartedAt(a);
          final bDate = _anilist.getEarliestStartedAt(b);

          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;

          return _sortDescending ? bDate.compareTo(aDate) : aDate.compareTo(bDate);
        };

      // Date the user completed watching the series (latest across all mappings)
      case SortOrder.completedDate:
        comparator = (a, b) {
          final aDate = _anilist.getLatestCompletionDate(a);
          final bDate = _anilist.getLatestCompletionDate(b);

          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;

          return _sortDescending ? bDate.compareTo(aDate) : aDate.compareTo(bDate);
        };

      // Average score from Anilist
      case SortOrder.averageScore:
        comparator = (a, b) {
          final aScore = a.currentAnilistData?.averageScore ?? 0;
          final bScore = b.currentAnilistData?.averageScore ?? 0;
          return aScore.compareTo(bScore);
        };

      // Release date from Anilist (earliest across all mappings)
      case SortOrder.releaseDate:
        comparator = (a, b) {
          final aDate = _anilist.getEarliestReleaseDate(a);
          final bDate = _anilist.getEarliestReleaseDate(b);

          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;

          return _sortDescending ? bDate.compareTo(aDate) : aDate.compareTo(bDate);
        };

      // Popularity from Anilist (highest across all mappings)
      case SortOrder.popularity:
        comparator = (a, b) {
          final aPopularity = _anilist.getHighestPopularity(a) ?? 0;
          final bPopularity = _anilist.getHighestPopularity(b) ?? 0;
          return aPopularity.compareTo(bPopularity);
        };

      // Custom user-defined order (per-group ordering applied after grouping in _buildCache)
      case SortOrder.custom:
        comparator = (a, b) => a.name.compareTo(b.name);
    }

    // Apply the sorting direction
    const selfDirectionAware = {SortOrder.startDate, SortOrder.completedDate, SortOrder.releaseDate};
    if (_sortDescending && !selfDirectionAware.contains(_sortOrder)) {
      seriesCopy.sort((a, b) => comparator(b, a)); // Reverse the comparison
    } else {
      seriesCopy.sort(comparator);
    }

    return seriesCopy;
  }

  /// Build the grouped data structure
  Map<String, List<Series>> _buildGroupedData(List<Series> allSeries) {
    final groups = <String, List<Series>>{};

    // Initialize groups based on custom list order (excluding hidden lists)
    for (final listName in customListOrder) {
      if (!hiddenLists.contains(listName)) {
        groups[StatusStatistic.getDisplayName(listName)] = [];
      }
    }

    // Sort series into groups (using existing grouping logic)
    for (final series in allSeries) {
      if (series.isLinked) {
        if (series.anilistMappings.isNotEmpty) {
          bool allCompleted = true;
          final completedList = _anilist.userLists[AnilistListApiStatus.COMPLETED.name_];

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
            for (final entry in _anilist.userLists.entries) {
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
            for (final entry in _anilist.userLists.entries) {
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
          } else if (groups.containsKey('Unlinked')) {
            // A linked series' groups map never actually seeds an 'Unlinked'
            // key (that's only for unlinked series below), so in practice
            // this branch is unreachable for a linked series - it's a guard,
            // not a real fallback. Previously this fell back to
            // `groups.keys.first` when no 'Unlinked' key existed, which
            // dumped the series into an arbitrary, unrelated group.
            groups['Unlinked']?.add(series);
          }
        }
      } else {
        // Unlinked series - use custom list name if specified and exists, otherwise use 'Unlinked'
        final availableListNames = _anilist.userLists.keys.toList()..add(AnilistService.statusListNameUnlinked);
        final effectiveListName = series.getEffectiveListName(availableListNames);
        final targetListName = StatusStatistic.getDisplayName(effectiveListName);

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

  /// Apply per-group custom ordering from _customSeriesOrder map
  void _applyCustomGroupOrdering() {
    if (_groupedDataCache == null) return;

    for (final entry in _groupedDataCache!.entries) {
      final groupName = entry.key;
      final groupApiName = StatusStatistic.getApiName(groupName);
      final customOrder = _customSeriesOrder[groupApiName];

      if (customOrder != null && customOrder.isNotEmpty) {
        final seriesList = entry.value;
        seriesList.sort((a, b) {
          final aIndex = customOrder.indexOf(a.path.path);
          final bIndex = customOrder.indexOf(b.path.path);
          // Series not in custom order go to the end, sorted alphabetically
          if (aIndex == -1 && bIndex == -1) return a.name.compareTo(b.name);
          if (aIndex == -1) return 1;
          if (bIndex == -1) return -1;
          return aIndex.compareTo(bIndex);
        });
      }
    }
  }

  /// The display order of group names, sorted by [customListOrder]
  List<String> groupDisplayOrder(Map<String, List<Series>> groupedData) {
    final displayOrder = groupedData.keys.toList();
    displayOrder.sort((a, b) {
      final aIndex = customListOrder.indexOf(StatusStatistic.getApiName(a));
      final bIndex = customListOrder.indexOf(StatusStatistic.getApiName(b));
      if (aIndex == -1) return 1;
      if (bIndex == -1) return -1;
      return aIndex.compareTo(bIndex);
    });
    return displayOrder;
  }

  // Cache

  /// Refresh dominant colors in the cached series from the live library
  void updateColorsInSortCache() {
    if (_sortedSeriesCache == null) return;

    final liveSeries = _library.series;

    // Create a lookup map for efficient series matching by path
    final liveSeriesMap = <String, Series>{};
    for (final series in liveSeries) {
      liveSeriesMap[series.path.path] = series;
    }

    // Update dominant colors in the sorted cache
    for (int i = 0; i < _sortedSeriesCache!.length; i++) {
      final cachedSeries = _sortedSeriesCache![i];
      final live = liveSeriesMap[cachedSeries.path.path];

      if (live != null && live.localPosterColor != cachedSeries.localPosterColor) {
        // Update the cached series with the new dominant color
        _sortedSeriesCache![i] = cachedSeries.copyWith(posterColor: live.localPosterColor);
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
          final live = liveSeriesMap[cachedSeries.path.path];

          if (live != null) {
            // Update the cached series with the new dominant color
            groupSeriesList[i] = cachedSeries.copyWith(posterColor: live.localPosterColor);
          } else {
            logTrace('No live series found for path: ${cachedSeries.path.path}');
          }
        }
      }
    } else {
      logTrace('Grouped data cache is null, skipping grouped update.');
    }

    notifySafe();
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
    _sortedSeriesCache = _sortSeries(_sortedSeriesCache!, AnilistProgressManager.instance);

    // If grouped cache exists, rebuild it
    if (_groupedDataCache != null && _showGrouped && _groupBy != GroupBy.none) {
      _groupedDataCache = _buildGroupedData(_sortedSeriesCache!);
    }

    notifySafe();
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

    notifySafe();
  }

  // Preferences

  /// Save preferences
  void saveUserPreferences() {
    final settings = Manager.settings;
    settings.set('library_view', _currentView.toString());
    settings.set('library_view_type', _viewType.toString());
    settings.set('library_sort_order', _sortOrder.toString());
    settings.set('library_sort_descending', _sortDescending);
    settings.set('library_group_by', _groupBy.toString());
    settings.set('library_show_grouped', _showGrouped);
    settings.set('library_list_order', json.encode(customListOrder));
    settings.set('library_hidden_lists', json.encode(hiddenLists.toList()));
    settings.set('library_custom_series_order', json.encode(_customSeriesOrder.map((k, v) => MapEntry(k, v))));
  }

  /// Load preferences
  void loadUserPreferences() {
    final manager = Manager.settings;

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

    // Load other settings (stored as strings)
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
      if (decoded is List) customListOrder = List<String>.from(decoded);
    } catch (_) {
      customListOrder = [];
    }

    // Load hidden lists
    final hiddenListsString = manager.get('library_hidden_lists', defaultValue: '[]');
    try {
      final decoded = json.decode(hiddenListsString);
      if (decoded is List) hiddenLists = Set<String>.from(decoded);
    } catch (_) {
      hiddenLists = {};
    }

    // Load custom series order (per-group map)
    final customSeriesOrderString = manager.get('library_custom_series_order', defaultValue: '{}');
    try {
      final decoded = json.decode(customSeriesOrderString);
      if (decoded is Map) {
        _customSeriesOrder = (decoded as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, List<String>.from(v as List)),
        );
      }
    } catch (_) {
      _customSeriesOrder = {};
    }

    notifySafe();
  }

  // Display helpers

  static String getSortText(SortOrder? order) {
    return switch (order) {
      null => 'Sort by',
      SortOrder.alphabetical => 'Title (A-Z)',
      SortOrder.score => 'Score',
      SortOrder.progress => 'Progress',
      SortOrder.lastModified => 'Last Modified',
      SortOrder.dateAdded => 'Date Added',
      SortOrder.startDate => 'Start Date',
      SortOrder.completedDate => 'Completed Date',
      SortOrder.averageScore => 'Average Score',
      SortOrder.releaseDate => 'Release Date',
      SortOrder.popularity => 'Popularity',
      SortOrder.custom => 'Custom Order'
    };
  }
}
