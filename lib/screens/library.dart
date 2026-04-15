// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
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
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../main.dart';
import '../enums.dart';
import '../models/anilist/user_data.dart';
import '../models/anilist/user_list.dart';
import '../services/anilist/queries/anilist_service.dart';
import '../services/library/library_provider.dart';
import '../services/library/search_service.dart';
import '../models/series.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../services/episode_navigation/anilist_progress_manager.dart';
import '../services/navigation/dialogs2.dart';
import '../services/navigation/navigation.dart';
import '../services/navigation/shortcuts.dart';
import '../utils/logging.dart';
import '../utils/path.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
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
  final List<String> selectedGenres;
  final int dataVersion;

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
    required this.selectedGenres,
    required this.dataVersion,
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
          _setEquals(hiddenLists, other.hiddenLists) &&
          _listEquals(selectedGenres, other.selectedGenres) &&
          dataVersion == other.dataVersion;

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
      hiddenLists.hashCode ^
      selectedGenres.hashCode ^
      dataVersion.hashCode;

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

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  bool get wantKeepAlive => true;

  bool _sortDescending = false;
  bool _showGrouped = false;

  final GlobalKey firstCardKey = GlobalKey();
  final GlobalKey _filterButtonKey = GlobalKey();
  final GlobalKey _listButtonKey = GlobalKey();
  bool _isSelectingFolder = false;

  // Global keys for each group to enable scrolling
  final Map<String, GlobalKey> _groupKeys = {};

  List<String> customListOrder = [];
  Set<String> hiddenLists = {}; // API names of hidden lists
  List<String> selectedGenres = [];
  List<Series> displayedSeries = [];

  // Cache system
  List<Series>? _sortedSeriesCache;
  Map<String, List<Series>>? _groupedDataCache;
  _CacheParameters? _cacheParameters;

  bool _filtersOpen = false;
  bool _listsOpen = false;

  // Custom series order per userlist group (list API name -> ordered series paths)
  Map<String, List<String>> _customSeriesOrder = {};
  bool _isReorderMode = false;

  LibraryView get currentView => _currentView;
  bool get showGrouped => _showGrouped;
  bool get isCustomSort => _sortOrder == SortOrder.custom;

  bool get _isGettingFiltered =>
      // _filtersOpen || //
      _searchQuery.isNotEmpty || //
      selectedGenres.isNotEmpty // TODO ||
      // Manager.settings.showHiddenSeries == false ||
      // Manager.settings.showAnilistHiddenSeries == false
      ;

  SortOrder get sortOrder => _sortOrder ?? SortOrder.alphabetical;

  bool get sortDescending => _sortDescending;

  late Color _textColor;
  late Color _selectedTextColor;

  void _loadColors() {
    _textColor = Colors.white;
    _selectedTextColor = getTextColor(Manager.currentDominantColor ?? Manager.accentColor);
  }

  Color getViewTypeColor(bool isSelected) => isSelected ? _selectedTextColor : _textColor;

  void addGenre(String genre) {
    if (!selectedGenres.contains(genre)) {
      setState(() {
        selectedGenres.add(genre);
        _sortedSeriesCache = null; // Invalidate cache
      });
    }
  }

  void removeGenre(String genre) {
    if (selectedGenres.contains(genre)) {
      setState(() {
        selectedGenres.remove(genre);
        _sortedSeriesCache = null; // Invalidate cache
      });
    }
  }

  void clearGenres() {
    if (selectedGenres.isNotEmpty) {
      setState(() {
        selectedGenres.clear();
        _sortedSeriesCache = null; // Invalidate cache
      });
    }
  }

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

  /// Check if the current cache is valid by comparing parameters
  bool _isCacheValid(Library library) {
    if (_cacheParameters == null) return false;

    final currentParams = _CacheParameters(
      currentView: _currentView,
      sortOrder: _sortOrder,
      groupBy: _groupBy,
      sortDescending: _sortDescending,
      showGrouped: _showGrouped,
      showHiddenSeries: Manager.settings.showHiddenSeries,
      showAnilistHiddenSeries: Manager.settings.showAnilistHiddenSeries,
      customListOrder: List.from(customListOrder),
      hiddenLists: Set.from(hiddenLists),
      selectedGenres: List.from(selectedGenres),
      dataVersion: library.dataVersion,
    );

    return _cacheParameters == currentParams;
  }

  /// Sort series using the same logic as isolate_manager.dart but in main thread
  List<Series> _sortSeries(List<Series> series, Library library, AnilistProvider anilistProvider, AnilistProgressManager progressManager) {
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
          final aProgress = progressManager.getSeriesProgress(a, anilistProvider);
          final bProgress = progressManager.getSeriesProgress(b, anilistProvider);
          return aProgress.compareTo(bProgress);
        };

      // Date the user's List Entry was last modified (progress update, status change)
      case SortOrder.lastModified:
        comparator = (a, b) {
          final aUpdated = anilistProvider.getLatestUpdatedAt(a) ?? 0;
          final bUpdated = anilistProvider.getLatestUpdatedAt(b) ?? 0;
          return aUpdated.compareTo(bUpdated);
        };

      // Date the user added the series to their list
      case SortOrder.dateAdded:
        comparator = (a, b) {
          final aCreated = anilistProvider.getEarliestCreatedAt(a) ?? 0;
          final bCreated = anilistProvider.getEarliestCreatedAt(b) ?? 0;
          return aCreated.compareTo(bCreated);
        };

      // Date the user started watching the series (earliest across all mappings)
      case SortOrder.startDate:
        comparator = (a, b) {
          final aDate = anilistProvider.getEarliestStartedAt(a);
          final bDate = anilistProvider.getEarliestStartedAt(b);

          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;

          return aDate.compareTo(bDate);
        };

      // Date the user completed watching the series (latest across all mappings)
      case SortOrder.completedDate:
        comparator = (a, b) {
          final aDate = anilistProvider.getLatestCompletionDate(a);
          final bDate = anilistProvider.getLatestCompletionDate(b);

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

      // Release date from Anilist (earliest across all mappings)
      case SortOrder.releaseDate:
        comparator = (a, b) {
          final aDate = anilistProvider.getEarliestReleaseDate(a);
          final bDate = anilistProvider.getEarliestReleaseDate(b);

          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;

          return aDate.compareTo(bDate);
        };

      // Popularity from Anilist (highest across all mappings)
      case SortOrder.popularity:
        comparator = (a, b) {
          final aPopularity = anilistProvider.getHighestPopularity(a) ?? 0;
          final bPopularity = anilistProvider.getHighestPopularity(b) ?? 0;
          return aPopularity.compareTo(bPopularity);
        };

      // Custom user-defined order (per-group ordering applied after grouping in _buildCache)
      case SortOrder.custom:
        comparator = (a, b) => a.name.compareTo(b.name);
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
    if (!mounted) return;
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
    final progressManager = AnilistProgressManager.instance;
    final rawSeries = library.series;
    final filteredSeries = _filterSeries(rawSeries);
    final sortedSeries = _sortSeries(filteredSeries, library, anilistProvider, progressManager);

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
      customListOrder: List.from(customListOrder),
      hiddenLists: Set.from(hiddenLists),
      selectedGenres: List.from(selectedGenres),
      dataVersion: library.dataVersion,
    );
  }

  /// Build the grouped data structure
  Map<String, List<Series>> _buildGroupedData(List<Series> allSeries) {
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
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
          if (bIndex == -1) return 1;
          return aIndex.compareTo(bIndex);
        });
      }
    }
  }

  /// Filter the series in Hidden, Linked
  List<Series> _filterSeries(List<Series> series) {
    if (!mounted) return series;
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);

    // Start with basic filtering (existing code)
    List<Series> filteredSeries = series;

    // Add filter for hidden series
    final bool showHidden = Manager.settings.showHiddenSeries;
    final bool showAnilistHidden = Manager.settings.showAnilistHiddenSeries;
    final bool onlyLinked = _currentView == LibraryView.linked;

    filteredSeries = filteredSeries.where((s) {
      if (!showHidden && s.isForcedHidden) return false;
      if (!showAnilistHidden && anilistProvider.isAnilistHidden(s)) return false;
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

    return filteredSeries;
  }

  void focusSearchBar() {
    _searchFocusNode.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    _loadColors();
    NavigationManager.registerActiveScrollController('library', _controller);
    NavigationManager.restoreScrollOffset('library', _controller);

    _searchFocusNode.onKeyEvent = (node, event) {
      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
        if (_searchQuery.isNotEmpty) {
          setState(() {
            _searchQuery = '';
            _searchController.clear();
          });
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

    Manager.navigation.pushPaneIndex(NavigationManager.SettingsIndex);

    await SettingsScreenState.setLibraryPath(context);

    setState(() => _isSelectingFolder = false);
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
    settings.set('library_list_order', json.encode(customListOrder));
    settings.set('library_hidden_lists', json.encode(hiddenLists.toList()));
    settings.set('library_custom_series_order', json.encode(_customSeriesOrder.map((k, v) => MapEntry(k, v))));
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
    });
  }

  void onViewChanged(LibraryView? value) {
    if (value != null && value != _currentView) {
      invalidateSortCache(); // Invalidate cache when view changes
      setState(() => _currentView = value);
      _saveUserPreferences();
    }
  }

  void onShowGroupedChanged(bool value) {
    setState(() {
      _showGrouped = value;
      _groupBy = value ? GroupBy.anilistLists : GroupBy.none;
      _saveUserPreferences();
      invalidateSortCache(); // Invalidate cache when grouping changes
    });
  }

  void onSortOrderChanged(SortOrder? value) {
    if (value != null && value != _sortOrder) {
      invalidateSortCache(); // Invalidate cache when sort order changes
      setState(() {
        _sortOrder = value;
        // Exit reorder mode when switching away from custom sort
        if (value != SortOrder.custom) _isReorderMode = false;
        // Enable grouping when using custom sort (order is per-group)
        if (value == SortOrder.custom && !_showGrouped) {
          _showGrouped = true;
          _groupBy = GroupBy.anilistLists;
        }
      });
      _saveUserPreferences();
    }
  }

  void onSortDirectionChanged() {
    invalidateSortCache(); // Invalidate cache when sort direction changes
    setState(() => _sortDescending = !_sortDescending);
    _saveUserPreferences();
  }

  void _toggleReorderMode() {
    setState(() {
      _isReorderMode = !_isReorderMode;
      if (_isReorderMode) _initCustomOrderForGroups();
    });
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
    _saveUserPreferences();
  }

  /// Reorder a series within a specific group
  void _reorderSeriesInGroup(String groupDisplayName, int oldIndex, int newIndex) {
    setState(() {
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
      _saveUserPreferences();
    });
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
      final aIndex = customListOrder.indexOf(StatusStatistic.getApiName(a));
      final bIndex = customListOrder.indexOf(StatusStatistic.getApiName(b));
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
    _sortedSeriesCache = _sortSeries(_sortedSeriesCache!, library, Provider.of<AnilistProvider>(context, listen: false), AnilistProgressManager.instance);

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

    final library = Provider.of<Library>(context);

    if (library.libraryPath == null) return _buildLibrarySelector();

    return MiruRyoikiTemplatePage(
      headerWidget: _buildHeader(library),
      content: _buildLibraryView(library),
      headerMaxHeight: ScreenUtils.kMinHeaderHeight,
      headerMinHeight: ScreenUtils.kMinHeaderHeight,
      noHeaderBanner: true,
      scrollableContent: false,
      enableContentExtraHeaderPadding: true,
      contentRightPadding: 4.0,
      contentExtraHeaderPadding: 8.0,
      hideInfoBar: true,
    );
  }

  void _onViewTypeChanged(ViewType viewType) {
    setState(() => _viewType = viewType);
    _saveUserPreferences();
  }

  HeaderWidget _buildHeader(Library library) {
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
                    currentViewType: _viewType,
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
                      isFilled: _isGettingFiltered,
                      backgroundColor: _isGettingFiltered ? (Manager.currentDominantAccentColor ?? Manager.accentColor).light : Colors.white.withOpacity(0.1),
                      key: _filterButtonKey,
                      icon: Icon(_filtersOpen ? mat.Icons.filter_alt : mat.Icons.filter_alt_outlined, size: 16, color: getViewTypeColor(_isGettingFiltered)),
                      onPressed: _filtersOpen ? null : _showFilterDialog,
                    ),
                  ),
                  HDiv(8),
                  SizedBox(
                    height: ScreenUtils.kDefaultButtonSize + 1,
                    child: StandardButton.iconLabel(
                      tooltip: 'Manage Lists',
                      label: Text("Lists", style: Manager.subtitleStyle.copyWith(fontSize: 12)),
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
                        tooltip: _isReorderMode ? 'Exit Reorder Mode' : 'Reorder Series',
                        label: Text(_isReorderMode ? "Done" : "Reorder", style: Manager.subtitleStyle.copyWith(fontSize: 12)),
                        isFilled: _isReorderMode,
                        backgroundColor: _isReorderMode ? (Manager.currentDominantAccentColor ?? Manager.accentColor).light : Colors.white.withOpacity(0.1),
                        icon: Icon(
                          _isReorderMode ? mat.Icons.check : mat.Icons.swap_vert,
                          size: 16,
                          color: getViewTypeColor(_isReorderMode),
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
                      suffix: _searchQuery.isNotEmpty
                          ? Padding(
                              padding: EdgeInsets.all(3).copyWith(right: 2.3),
                              child: MouseButtonWrapper(
                                tooltip: 'Clear search',
                                child: (_) => SizedBox(
                                  height: 30,
                                  child: StandardButton.icon(
                                    icon: Icon(mat.Icons.clear, size: 16),
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = '';
                                        _searchController.clear();
                                      });
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
                      onChanged: (value) => setState(() => _searchQuery = value),
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

  Widget _buildLibraryView(Library library) {
    // Check if cache is valid and exists
    List<Series> seriesToDisplay;
    Map<String, List<Series>>? groupedData;

    if (_isCacheValid(library) && _sortedSeriesCache != null) {
      // Use cached data
      seriesToDisplay = _sortedSeriesCache!;
      groupedData = _groupedDataCache;
    } else {
      // Build cache
      _buildCache(library);
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

    if (displayedSeries.isEmpty) {
      // Different messages for search vs. no series
      if (_searchQuery.isNotEmpty) {
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
              Text('No series found matching "$_searchQuery"', style: Manager.bodyStyle),
              VDiv(8),
              Text('Try adjusting your search terms', style: Manager.bodyStyle.copyWith(color: Colors.white.withOpacity(0.6))),
              VDiv(16),
              MouseButtonWrapper(
                child: (_) => Button(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
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
    }

    return LayoutBuilder(builder: (context, constraints) {
      // Only hide library content if it's an initial scan (first time or new path)
      // For normal scans show the library with disabled actions
      final bool hideLibrary = library.isIndexing && library.isInitialScan;

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

            if (_isReorderMode && groupName != null) card = _buildDraggableGridItem(card, index, list, groupName);

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
        _reorderSeriesInGroup(groupName, oldIndex, oldIndex < index ? index + 1 : index);
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
                : (_isReorderMode && groupName != null)
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
                        onReorder: (oldIndex, newIndex) => _reorderSeriesInGroup(groupName, oldIndex, newIndex),
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
                final aIndex = customListOrder.indexOf(StatusStatistic.getApiName(a));
                final bIndex = customListOrder.indexOf(StatusStatistic.getApiName(b));

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
    // Use the _customListOrder to determine display order
    final displayOrder = groupedData.keys.toList();
    displayOrder.sort((a, b) {
      // Get the original position in _customListOrder
      final aIndex = customListOrder.indexOf(StatusStatistic.getApiName(a));
      final bIndex = customListOrder.indexOf(StatusStatistic.getApiName(b));

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

  String getSortText(SortOrder? order) {
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
      case SortOrder.custom:
        return 'Custom Order';
    }
  }

  void _showFilterDialog() async {
    if (Manager.navigation.hasDialog && Manager.navigation.currentView?.id == "library:lists") {
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
      anchorPosition = renderBox.localToGlobal(Offset(-140, -33));
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
        dialogDoPopCheck: () => Manager.canPopDialog,
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
          maxWidth: 250,
          // TODO do the same as listsDialogHeight
          maxHeight: Manager.settings.listsDialogHeight, //just temporarily initialize with this value
        ),
        navigationItem: item,
        barrierOptions: options,
        alignment: Position.fromAlignment(alignment),
        content: GenresFilterContent(),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          alignment: alignment,
          scale: CurvedAnimation(
            parent: Tween<double>(
              begin: 0,
              end: 1,
            ).animate(animation),
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
    );
  }

  void _showListDialog() async {
    if (Manager.navigation.hasDialog && Manager.navigation.currentView?.id == "library:filters") {
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
      anchorPosition = renderBox.localToGlobal(Offset(-140, -33));
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
        dialogDoPopCheck: () => Manager.canPopDialog,
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
        final constraints = BoxConstraints(maxWidth: 250, maxHeight: Manager.settings.listsDialogHeight);

        return PaddedDialog.frosted(
          constraints: constraints,
          navigationItem: item,
          barrierOptions: options,
          alignment: Position.fromAlignment(alignment),
          content: ListsContent(
            constraints: constraints,
            currentView: _currentView,
            customListOrder: customListOrder,
            hiddenLists: hiddenLists,
            groupedDataCache: _groupedDataCache,
            onScrollToList: _scrollToList,
            onInvalidateSortCache: invalidateSortCache,
            onSaveUserPreferences: _saveUserPreferences,
            onHiddenListsChanged: (newHiddenLists) {
              setState(() {
                hiddenLists = newHiddenLists;
              });
            },
            onCustomListOrderChanged: (newOrder) {
              setState(() {
                customListOrder = newOrder;
              });
            },
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          alignment: alignment,
          scale: CurvedAnimation(
            parent: Tween<double>(
              begin: 0,
              end: 1,
            ).animate(animation),
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
    );
  }
}




