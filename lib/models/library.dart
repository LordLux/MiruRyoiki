import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../functions.dart';
import '../services/anilist/linking.dart';
import '../services/cache.dart';
import '../services/file_scanner.dart';
import '../services/player_trackers/mpchc.dart';
import '../services/navigation/show_info.dart';
import 'anilist/anime.dart';
import 'anilist/mapping.dart';
import 'series.dart';
import 'episode.dart';

class Library with ChangeNotifier {
  List<Series> _series = [];
  String? _libraryPath;
  bool _isLoading = false;
  late FileScanner _fileScanner;
  late MPCHCTracker _mpcTracker;

  List<Series> get series => List.unmodifiable(_series);
  String? get libraryPath => _libraryPath;
  bool get isLoading => _isLoading;

  Library() {
    _fileScanner = FileScanner();
    _mpcTracker = MPCHCTracker()..addListener(_onMpcTrackerUpdate);
    _loadLibrary();
  }

  @override
  void dispose() {
    _mpcTracker.removeListener(_onMpcTrackerUpdate);
    _mpcTracker.dispose();
    super.dispose();
  }

  /// Load Anilist posters for series that have links but no local images
  Future<void> loadAnilistPostersForLibrary({Function(int loaded, int total)? onProgress}) async {
    final linkService = SeriesLinkService();
    final imageCache = ImageCacheService();
    await imageCache.init(); // Ensure the cache is initialized

    final needPosters = <Series>[];
    final alreadyCached = <Series, String>{};

    // Find series that need Anilist posters
    for (final series in _series) {
      if (series.folderImagePath == null && series.anilistMappings.isNotEmpty) {
        // Check if we can find the poster URL without fetching
        final mapping = series.anilistMappings.firstWhere(
          (m) => m.anilistId == (series.primaryAnilistId ?? series.anilistMappings.first.anilistId),
          orElse: () => series.anilistMappings.first,
        );

        // If we have anilistData with a poster URL check if it's cached
        if (mapping.anilistData?.posterImage != null) {
          final cached = await imageCache.getCachedImagePath(mapping.anilistData!.posterImage!);
          if (cached != null) {
            // Already cached -> save the path
            alreadyCached[series] = cached;

            // Make sure series.anilistData is set correctly
            if (series.primaryAnilistId == mapping.anilistId || series.primaryAnilistId == null) //
              series.anilistData = mapping.anilistData;
          } else {
            // Not cached -> need to fetch
            needPosters.add(series);
          }
        } else {
          // No anilistData or no posterImage -> need to fetch
          needPosters.add(series);
        }
      }
    }

    if (alreadyCached.isNotEmpty) {
      notifyListeners();
      onProgress?.call(alreadyCached.length, alreadyCached.length + needPosters.length);
    }

    if (needPosters.isEmpty) return;

    print('Loading Anilist posters for ${needPosters.length} series');

    // Fetch posters in batches
    int loaded = alreadyCached.length;
    final total = alreadyCached.length + needPosters.length;

    // Fetch posters in batches to avoid overwhelming the API
    for (int i = 0; i < needPosters.length; i += 5) {
      final batch = needPosters.sublist(i, i + 5 > needPosters.length ? needPosters.length : i + 5);

      await Future.wait(batch.map((series) async {
        final anilistId = series.primaryAnilistId ?? series.anilistMappings.first.anilistId;
        final anime = await linkService.fetchAnimeDetails(anilistId);

        if (anime != null) {
          // Pre-cache the image if URL exists
          if (anime.posterImage != null) {
            // Poster
            imageCache.cacheImage(anime.posterImage!);

            // also Banner
            if (anime.bannerImage != null) //
              imageCache.cacheImage(anime.bannerImage!);
          }

          // Find the mapping with this ID
          for (var j = 0; j < series.anilistMappings.length; j++) {
            if (series.anilistMappings[j].anilistId == anilistId) {
              series.anilistMappings[j] = AnilistMapping(
                localPath: series.anilistMappings[j].localPath,
                anilistId: anilistId,
                title: series.anilistMappings[j].title,
                lastSynced: DateTime.now(),
                anilistData: anime,
              );
            }
          }

          // Update the series' Anilist data if this is the primary ID
          if (series.primaryAnilistId == anilistId || series.primaryAnilistId == null) {
            series.anilistData = anime;
          }
        }
        loaded++;
      }));

      // Notify after each batch so UI updates incrementally
      notifyListeners();
      onProgress?.call(loaded, total);

      // Add a small delay between batches to be nice to the API
      if (i + 5 < needPosters.length) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    // Notify listeners after all fetches are complete
    notifyListeners();
  }

  /// Reload all Anilist posters, optionally forcing even if they already have images
  Future<void> refreshAnilistPosters({bool forceAll = false}) async {
    final linkService = SeriesLinkService();
    final refreshSeries = <Series>[];

    // Identify series that need refreshing
    for (final series in _series) {
      if (forceAll) {
        if (series.anilistMappings.isNotEmpty) {
          refreshSeries.add(series);
        }
      } else if (series.folderImagePath == null && series.anilistMappings.isNotEmpty) {
        refreshSeries.add(series);
      }
    }

    if (refreshSeries.isEmpty) return;

    // print('Refreshing Anilist posters for ${refreshSeries.length} series');

    for (int i = 0; i < refreshSeries.length; i += 5) {
      final batch = refreshSeries.sublist(i, i + 5 > refreshSeries.length ? refreshSeries.length : i + 5);

      await Future.wait(batch.map((series) async {
        final anilistId = series.primaryAnilistId ?? series.anilistMappings.first.anilistId;
        final anime = await linkService.fetchAnimeDetails(anilistId);

        if (anime != null) {
          // Find the mapping with this ID
          for (var j = 0; j < series.anilistMappings.length; j++) {
            if (series.anilistMappings[j].anilistId == anilistId) {
              series.anilistMappings[j] = AnilistMapping(
                localPath: series.anilistMappings[j].localPath,
                anilistId: anilistId,
                title: series.anilistMappings[j].title,
                lastSynced: DateTime.now(),
                anilistData: anime,
              );
            }
          }

          // Update the series' Anilist data if this is the primary ID
          if (series.primaryAnilistId == anilistId || series.primaryAnilistId == null) {
            series.anilistData = anime;
          }
        }
      }));

      // Add a small delay between batches to be nice to the API
      if (i + 5 < refreshSeries.length) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    notifyListeners();
  }

  /// Save a single series with updated properties
  Future<void> saveSeries(Series series) async {
    final index = _series.indexWhere((s) => s.path == series.path);
    if (index >= 0) {
      _series[index] = series;
      await _saveLibrary();
      notifyListeners();
    }
  }

  void _onMpcTrackerUpdate() async {
    final watchedFiles = await _mpcTracker.checkForUpdates();
    var updated = false;

    // Update watched status for any files that were detected as watched
    for (final filePath in watchedFiles) {
      for (final series in _series) {
        // Check in seasons
        for (final season in series.seasons) {
          for (final episode in season.episodes) {
            if (episode.path == filePath && !episode.watched) {
              episode.watched = true;
              episode.watchedPercentage = 1.0;
              updated = true;
            }
          }
        }

        // Check in related media
        for (final episode in series.relatedMedia) {
          if (episode.path == filePath && !episode.watched) {
            episode.watched = true;
            episode.watchedPercentage = 1.0;
            updated = true;
          }
        }
      }
    }

    if (updated) {
      _saveLibrary();
      notifyListeners();
    }
  }

  Future<void> setLibraryPath(String path) async {
    _libraryPath = path;
    await _saveSettings();
    await scanLibrary();
  }

  void reloadLibrary() {
    if (_libraryPath == null || _isLoading) return;

    snackBar('Reloading library...', severity: InfoBarSeverity.info);

    scanLibrary()
        .then(
          (_) => snackBar('Library reloaded', severity: InfoBarSeverity.success),
        )
        .catchError(
          (error) => snackBar('Error reloading library: $error', severity: InfoBarSeverity.error, hasError: true),
        );
  }

  Future<void> scanLibrary() async {
    if (_libraryPath == null || _isLoading) return;
    print('Scanning library at $_libraryPath');

    _isLoading = true;
    notifyListeners();

    try {
      _series = await _fileScanner.scanLibrary(_libraryPath!);

      // Update watched status from tracker
      _updateWatchedStatus();

      await calculateDominantColors();
      await _saveLibrary();
    } catch (e) {
      debugPrint('Error scanning library: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateWatchedStatus() {
    if (!_mpcTracker.isInitialized) return;

    for (final series in _series) {
      // Update seasons/episodes
      for (final season in series.seasons) {
        for (final episode in season.episodes) {
          episode.watchedPercentage = _mpcTracker.getWatchPercentage(episode.path);
          episode.watched = _mpcTracker.isWatched(episode.path);
        }
      }

      // Update related media
      for (final episode in series.relatedMedia) {
        episode.watchedPercentage = _mpcTracker.getWatchPercentage(episode.path);
        episode.watched = _mpcTracker.isWatched(episode.path);
      }
    }
  }

  Future<Directory> get miruRyoiokiSaveDirectory async {
    final dir = await getApplicationSupportDirectory();
    final miruRyoiokiDir = Directory('${dir.path}/miruRyoioki');
    if (!await miruRyoiokiDir.exists()) await miruRyoiokiDir.create(recursive: true);
    return miruRyoiokiDir;
  }

  static const String settingsFileName = 'settings';
  static const String miruryoikiLibrary = 'library.json';

  Future<void> _loadSettings() async {
    try {
      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/$settingsFileName.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content);
        _libraryPath = data['libraryPath'];
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/$settingsFileName.json');

      final data = {
        'libraryPath': _libraryPath,
      };

      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  Future<void> _loadLibrary() async {
    try {
      await _loadSettings();

      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/$miruryoikiLibrary.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content) as List;
        _series = data.map((s) => Series.fromJson(s)).toList();
      }

      // Update watched status
      _updateWatchedStatus();
    } catch (e) {
      debugPrint('Error loading library: $e');
    }
    notifyListeners();
  }

  Future<void> _saveLibrary() async {
    try {
      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/$miruryoikiLibrary.json');

      final data = _series.map((s) => s.toJson()).toList();
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving library: $e');
    }
  }

  Future<void> refreshEpisode(Episode episode) async {
    episode.watchedPercentage = _mpcTracker.getWatchPercentage(episode.path);
    episode.watched = _mpcTracker.isWatched(episode.path);
    await _saveLibrary();
    notifyListeners();
  }

  void markEpisodeWatched(Episode episode, {bool watched = true}) {
    episode.watched = watched;
    episode.watchedPercentage = watched ? 1.0 : 0.0;
    _saveLibrary();
    notifyListeners();
  }

  void markSeasonWatched(Season season, {bool watched = true}) {
    for (final episode in season.episodes) {
      episode.watched = watched;
      episode.watchedPercentage = watched ? 1.0 : 0.0;
    }
    _saveLibrary();
    notifyListeners();
  }

  void markSeriesWatched(Series series, {bool watched = true}) {
    for (final season in series.seasons) {
      for (final episode in season.episodes) {
        episode.watched = watched;
        episode.watchedPercentage = watched ? 1.0 : 0.0;
      }
    }

    for (final episode in series.relatedMedia) {
      episode.watched = watched;
      episode.watchedPercentage = watched ? 1.0 : 0.0;
    }

    _saveLibrary();
    notifyListeners();
  }

  Series? getSeriesByPath(String seriesPath) {
    for (final series in _series) {
      if (series.path == seriesPath) //
        return series;
    }
    return null;
  }

  /// Link a series with Anilist
  Future<void> linkSeriesWithAnilist(Series series, int anilistId, {String? localPath, String? title}) async {
    final path = localPath ?? series.path;

    // Check if this path already has a mapping
    bool updated = false;
    for (int i = 0; i < series.anilistMappings.length; i++) {
      if (series.anilistMappings[i].localPath == path) {
        // Update existing mapping
        series.anilistMappings[i] = AnilistMapping(
          localPath: path,
          anilistId: anilistId,
          title: title ?? series.anilistMappings[i].title,
          lastSynced: DateTime.now(),
        );
        updated = true;
        break;
      }
    }

    // Add new mapping if not updated
    if (!updated) {
      series.anilistMappings.add(AnilistMapping(
        localPath: path,
        anilistId: anilistId,
        title: title,
        lastSynced: DateTime.now(),
      ));
    }

    await _saveLibrary();
    notifyListeners();
  }

  /// Update Anilist mappings for a series
  Future<void> updateSeriesMappings(Series series, List<AnilistMapping> mappings) async {
    series.anilistMappings = mappings;

    if (mappings.isEmpty) {
      series.anilistData = null;
      series.primaryAnilistId = null; // This will use the setter
    }

    await _saveLibrary();
    notifyListeners();
  }

  /// Refresh metadata for all series
  Future<void> refreshAllMetadata() async {
    final seriesLinkService = SeriesLinkService();

    for (final series in _series) {
      if (series.anilistId != null) {
        await seriesLinkService.refreshMetadata(series);
      }
    }

    await _saveLibrary();
    notifyListeners();
  }

  /// Get Anilist series suggestion
  Future<List<AnilistAnime>> getSeriesSuggestions(Series series) async {
    final seriesLinkService = SeriesLinkService();
    return seriesLinkService.findMatchesByName(series);
  }

  /// Calculate dominant colors for all series
  Future<void> calculateDominantColors() async {
    for (final series in _series) {
      if (series.dominantColor == null && series.folderImagePath != null) //
        await series.calculateDominantColor();
    }
    // Save library after calculating all colors
    await _saveLibrary();
  }
}
