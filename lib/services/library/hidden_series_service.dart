import 'package:flutter/foundation.dart';
import '../../models/series.dart';
import '../../manager.dart';

/// Service to manage cached AniList IDs of hidden series
/// This helps efficiently filter hidden series across the app without recalculating each time
class HiddenSeriesService extends ChangeNotifier {
  static final HiddenSeriesService _instance = HiddenSeriesService._internal();
  factory HiddenSeriesService() => _instance;
  HiddenSeriesService._internal();

  /// Set of AniList IDs for series that are currently hidden 
  /// Includes ALL AniList IDs from mappings of hidden series (both forced and AniList hidden)
  final Set<int> _hiddenAnilistIds = <int>{};

  /// Get a copy of the hidden AniList IDs set
  Set<int> get hiddenAnilistIds => Set<int>.from(_hiddenAnilistIds);

  /// Check if an AniList ID should be filtered out based on current settings
  bool shouldFilterAnilistId(int? anilistId) {
    if (anilistId == null) return false;
    return !Manager.settings.showHiddenSeries && _hiddenAnilistIds.contains(anilistId);
  }

  /// Check if a series should be filtered out based on current settings
  bool shouldFilterSeries(Series series) {
    // Check forced hidden status
    if (!Manager.settings.showHiddenSeries && series.isForcedHidden) return true;

    // Check AniList hidden status
    if (!Manager.settings.showAnilistHiddenSeries && series.isAnilistHidden) return true;

    // Check if any of the series' AniList IDs are in our hidden cache
    for (final mapping in series.anilistMappings) {
      if (shouldFilterAnilistId(mapping.anilistId)) return true;
    }

    return false;
  }

  /// Rebuild the cache from the current series list
  void rebuildCache(List<Series> allSeries) {
    _hiddenAnilistIds.clear();

    for (final series in allSeries) {
      // Add ALL AniList IDs for locally hidden series
      if (series.isForcedHidden) {
        for (final mapping in series.anilistMappings) {
          _hiddenAnilistIds.add(mapping.anilistId);
        }
      }

      // Add ALL AniList IDs for AniList hidden series
      if (series.isAnilistHidden) {
        for (final mapping in series.anilistMappings) {
          _hiddenAnilistIds.add(mapping.anilistId);
        }
      }
    }

    notifyListeners();
  }

  /// Add a series to the hidden cache when it becomes hidden
  void addHiddenSeries(Series series) {
    bool wasModified = false;
    for (final mapping in series.anilistMappings) {
      bool wasAdded = _hiddenAnilistIds.add(mapping.anilistId);
      if (wasAdded) wasModified = true;
    }
    if (wasModified) notifyListeners();
  }

  /// Remove a series from the hidden cache when it's no longer hidden
  void removeHiddenSeries(Series series) {
    bool wasModified = false;
    for (final mapping in series.anilistMappings) {
      bool wasRemoved = _hiddenAnilistIds.remove(mapping.anilistId);
      if (wasRemoved) wasModified = true;
    }
    if (wasModified) notifyListeners();
  }

  /// Update the cache when a series' hidden status changes
  void updateSeriesHiddenStatus(Series series) {
    if (series.anilistMappings.isEmpty) return;

    bool shouldBeHidden = series.isForcedHidden || series.isAnilistHidden;
    bool wasModified = false;

    for (final mapping in series.anilistMappings) {
      bool isCurrentlyInCache = _hiddenAnilistIds.contains(mapping.anilistId);
      
      if (shouldBeHidden && !isCurrentlyInCache) {
        _hiddenAnilistIds.add(mapping.anilistId);
        wasModified = true;
      } else if (!shouldBeHidden && isCurrentlyInCache) {
        _hiddenAnilistIds.remove(mapping.anilistId);
        wasModified = true;
      }
    }

    if (wasModified) notifyListeners();
  }

  /// Clear the cache
  void clearCache() {
    _hiddenAnilistIds.clear();
    notifyListeners();
  }

  /// Get debug information about the cache
  String getDebugInfo() {
    return 'Hidden AniList IDs Cache: ${_hiddenAnilistIds.length} entries\n'
        'IDs: ${_hiddenAnilistIds.toList()}\n'
        'Show Hidden Series: ${Manager.settings.showHiddenSeries}\n'
        'Show AniList Hidden Series: ${Manager.settings.showAnilistHiddenSeries}';
  }
}
