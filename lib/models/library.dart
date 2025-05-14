import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/enums.dart';
import 'package:miruryoiki/utils/logging.dart';
import 'package:path_provider/path_provider.dart';

import '../services/anilist/linking.dart';
import '../services/cache.dart';
import '../services/file_scanner.dart';
import '../services/player_trackers/mpchc.dart';
import '../services/navigation/show_info.dart';
import '../utils/path_utils.dart';
import '../utils/time_utils.dart';
import 'anilist/anime.dart';
import 'anilist/mapping.dart';
import 'series.dart';
import 'episode.dart';

class Library with ChangeNotifier {
  List<Series> _series = [];
  String? _libraryPath;
  bool _isLoading = false;
  bool _isDirty = false;
  late FileScanner _fileScanner;
  late MPCHCTracker _mpcTracker;

  bool _initialized = false;
  bool get initialized => _initialized;

  Timer? _autoSaveTimer;
  Timer? _saveDebouncer;

  List<Series> get series => List.unmodifiable(_series);
  String? get libraryPath => _libraryPath;
  bool get isLoading => _isLoading;

  Library() {
    _fileScanner = FileScanner();
    _mpcTracker = MPCHCTracker()..addListener(_onMpcTrackerUpdate);
    _initAutoSave();
  }

  Future<void> initialize() async {
    if (!_initialized) {
      await _loadLibrary();
      _initialized = true;

      // async cache validation
      nextFrame(() => cacheValidation());
    }
  }

  Future<void> cacheValidation() async {
    if (!_initialized) {
      final imageCache = ImageCacheService();
      await imageCache.init();

      // Validate cache for all series with Anilist data
      for (final series in _series) {
        if (series.anilistData?.posterImage != null) {
          // Verify and reconnect poster image
          final cachedPosterPath = await imageCache.getCachedImagePath(series.anilistData!.posterImage!);
          if (cachedPosterPath == null && series.anilistData!.posterImage != null) {
            // If not in cache but URL exists, cache it
            imageCache.cacheImage(series.anilistData!.posterImage!);
            logDebug('Re-caching poster for: ${series.name}');
          }

          // Verify and reconnect banner image
          if (series.anilistData?.bannerImage != null) {
            final cachedBannerPath = await imageCache.getCachedImagePath(series.anilistData!.bannerImage!);
            if (cachedBannerPath == null) {
              // If not in cache but URL exists, cache it
              imageCache.cacheImage(series.anilistData!.bannerImage!);
              logDebug('Re-caching banner for: ${series.name}');
            }
          }
        }
      }

      _initialized = true;
    }
  }

  void _initAutoSave() {
    _autoSaveTimer?.cancel();
    // Auto-save every 2 minutes
    _autoSaveTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (_isDirty) {
        logDebug('Auto-saving library...');
        _saveLibrary();
      }
    });
  }

  @override
  void dispose() {
    _mpcTracker.removeListener(_onMpcTrackerUpdate);
    _mpcTracker.dispose();
    _autoSaveTimer?.cancel();
    _saveDebouncer?.cancel();
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
      if (series.folderPosterPath == null && series.anilistMappings.isNotEmpty) {
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

    logDebug('Loading Anilist posters for ${needPosters.length} series');

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
      } else if (series.folderPosterPath == null && series.anilistMappings.isNotEmpty) {
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
      final oldSeries = _series[index];

      // Check if images changed
      bool posterChanged = oldSeries.folderPosterPath != series.folderPosterPath;
      bool bannerChanged = oldSeries.folderBannerPath != series.folderBannerPath;
      bool anilistChanged = oldSeries.primaryAnilistId != series.primaryAnilistId;
      bool preferenceChanged = oldSeries.preferredPosterSource != series.preferredPosterSource || oldSeries.preferredBannerSource != series.preferredBannerSource;

      // Update the series
      _series[index] = series;

      // Recalculate dominant color if relevant changes occurred
      if (posterChanged || bannerChanged || anilistChanged || preferenceChanged) {
        logDebug('Image source changed for ${series.name} - updating dominant color');
        await series.calculateDominantColor(forceRecalculate: true);
      }

      log('Series updated: ${series.name}, ${PathUtils.getFileName(series.effectivePosterPath ?? '')}, ${PathUtils.getFileName(series.effectiveBannerPath ?? '')}');
      _isDirty = true;
      await _saveLibrary();
      notifyListeners();
    }
  }

  // Add this method if it doesn't exist, or replace it if it does
  Future<void> forceImmediateSave() async {
    logDebug('Force immediate save requested');
    try {
      // Cancel any pending save operations
      _saveDebouncer?.cancel();
      _saveDebouncer = null;

      // Perform save directly and wait for it to complete
      await _saveLibrary();
      logDebug('Force immediate save completed');
    } catch (e) {
      logDebug('Error during force save: $e');
      // Try one more time after a short delay
      await Future.delayed(const Duration(milliseconds: 100));
      await _saveLibrary();
    }
  }

  void _onMpcTrackerUpdate() async {
    final watchedFiles = await _mpcTracker.checkForUpdates();
    bool updated = false;

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
      _isDirty = true;
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
    if (_libraryPath == null) {
      logDebug('Skipping scan, library path is null');
      return;
    }
    if (_isLoading) return;
    logDebug('Scanning library at $_libraryPath');

    _isLoading = true;
    notifyListeners();

    try {
      // Create a map of existing series for quick lookup
      final existingSeriesMap = {for (var s in _series) s.path: s};

      // Track current series count to identify new ones
      final previousSeriesCount = _series.length;
      final previousSeriesPaths = _series.map((s) => s.path).toSet();

      _series = await _fileScanner.scanLibrary(_libraryPath!, existingSeriesMap);

      // Identify new series
      final newSeries = _series.where((s) => !previousSeriesPaths.contains(s.path)).toList();

      // Update watched status from tracker
      _updateWatchedStatus();

      if (newSeries.isNotEmpty) {
        logDebug('Calculating dominant colors for ${newSeries.length} new series');
        for (final series in newSeries) {
          await series.calculateDominantColor();
        }
      }

      _isDirty = true;
      _saveLibrary().then((_) => notifyListeners());
    } catch (e) {
      logErr('Error scanning library', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateWatchedStatus() {
    if (!_mpcTracker.isInitialized) return;
    logTrace('Getting watched status for all series');

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
    logTrace('Finished getting watched status for all series');
  }

  Future<Directory> get miruRyoiokiSaveDirectory async {
    final dir = await getApplicationSupportDirectory();
    final miruRyoiokiDir = Directory('${dir.path}/miruRyoioki');
    if (!await miruRyoiokiDir.exists()) await miruRyoiokiDir.create(recursive: true);
    return miruRyoiokiDir;
  }

  static const String settingsFileName = 'settings';
  static const String miruryoikiLibrary = 'library';

  // SETTINGS
  Future<void> _loadSettings() async {
    try {
      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/$settingsFileName.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content);
        _libraryPath = data['libraryPath'];
        logInfo('Loaded settings: $_libraryPath');
      }
    } catch (e) {
      logDebug('Error loading settings: $e');
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
      logDebug('Error saving settings: $e');
    }
  }

  // LIBRARY
  Future<void> _loadLibrary() async {
    try {
      await _loadSettings();

      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/$miruryoikiLibrary.json');
      final backupFile = File('${dir.path}/$miruryoikiLibrary.backup.json');

      if (await file.exists()) {
        try {
          final content = await file.readAsString();
          final data = jsonDecode(content) as List;
          _series = data.map((s) => Series.fromJson(s)).toList();

          // Validate that we loaded series properly
          if (_series.isNotEmpty) {
            // Success - create a backup
            await file.copy(backupFile.path);
            logDebug('Library loaded successfully (${_series.length} series)');
          } else {
            throw Exception('Loaded library contains no series');
          }
        } catch (e) {
          logDebug('Error loading library file, trying backup: $e');
          // If main file load fails, try the backup
          if (await backupFile.exists()) {
            final backupContent = await backupFile.readAsString();
            final backupData = jsonDecode(backupContent) as List;
            _series = backupData.map((s) => Series.fromJson(s)).toList();
            logDebug('Loaded library from backup (${_series.length} series)');

            // Restore from backup
            await backupFile.copy(file.path);
          } else {
            logDebug('No backup file found, starting with an empty library');
            _series = [];
          }
        }
      }

      // Update watched status
      _updateWatchedStatus();
    } catch (e) {
      logDebug('Error loading library: $e');
    }
    notifyListeners();
  }

  Future<void> _saveLibrary() async {
    try {
      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/$miruryoikiLibrary.json');
      final tempFile = File('${dir.path}/$miruryoikiLibrary.temp.json');

      // Write to temporary file first
      final data = _series.map((s) => s.toJson()).toList();
      await tempFile.writeAsString(jsonEncode(data));

      // If successful, rename temp file to replace the actual file (atomic operation)
      if (await tempFile.exists()) {
        // Create backup of existing file if it exists
        if (await file.exists()) {
          final backupFile = File('${dir.path}/$miruryoikiLibrary.backup.json');
          await file.copy(backupFile.path);
        }

        // Replace original with new file
        await tempFile.rename(file.path);
        logDebug('Library saved successfully');
        _isDirty = false;
        return;
      }
    } catch (e) {
      logDebug('Error saving library: $e');
    }
  }

  void _saveWithDebounce() {
    _isDirty = true;
    _saveDebouncer?.cancel();
    _saveDebouncer = Timer(const Duration(milliseconds: 500), () {
      _saveLibrary();
    });
  }

  // EPISODES
  Future<void> refreshEpisode(Episode episode) async {
    episode.watchedPercentage = _mpcTracker.getWatchPercentage(episode.path);
    episode.watched = _mpcTracker.isWatched(episode.path);
    await _saveLibrary();
    notifyListeners();
  }

  void markEpisodeWatched(Episode episode, {bool watched = true, bool save = true}) {
    episode.watched = watched;
    episode.watchedPercentage = watched ? 1.0 : 0.0;

    if (save) {
      _isDirty = true;
      _saveWithDebounce();
      notifyListeners();
    }
  }

  void markSeasonWatched(Season season, {bool watched = true, bool save = true}) {
    for (final episode in season.episodes) //
      markEpisodeWatched(episode, watched: watched, save: false);

    if (save) {
      _isDirty = true;
      _saveWithDebounce();
      notifyListeners();
    }
  }

  void markSeriesWatched(Series series, {bool watched = true}) {
    for (final season in series.seasons) //
      markSeasonWatched(season, watched: watched, save: false);

    for (final episode in series.relatedMedia) {
      markEpisodeWatched(episode, watched: watched, save: false);
    }

    _isDirty = true;
    _saveWithDebounce();
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
    bool isNewLink = true;

    // Check if this path already has a mapping
    for (int i = 0; i < series.anilistMappings.length; i++) {
      if (series.anilistMappings[i].localPath == path) {
        // Update existing mapping
        series.anilistMappings[i] = AnilistMapping(
          localPath: path,
          anilistId: anilistId,
          title: title ?? series.anilistMappings[i].title,
          lastSynced: DateTime.now(),
        );
        isNewLink = true;
        break;
      }
    }

    // Add new mapping if not updated
    if (isNewLink) {
      series.anilistMappings.add(AnilistMapping(
        localPath: path,
        anilistId: anilistId,
        title: title,
        lastSynced: DateTime.now(),
      ));
    }

    if (series.primaryAnilistId == null) {
      series.primaryAnilistId = anilistId;

      // When first linked, update dominant color according to effective source
      await series.calculateDominantColor(forceRecalculate: true);
    }

    _isDirty = true;
    await _saveLibrary();
    notifyListeners();
  }

  /// Update Anilist mappings for a series
  Future<bool> updateSeriesMappings(Series series, List<AnilistMapping> mappings) async {
    series.anilistMappings = mappings;
    _isDirty = true;

    if (mappings.isEmpty) {
      series.anilistData = null;
      series.primaryAnilistId = null; // This will use the setter
    }

    if (series.primaryAnilistId == null && mappings.isNotEmpty) {
      series.primaryAnilistId = mappings.first.anilistId;
    }

    await _saveLibrary();
    notifyListeners();

    try {
      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/$miruryoikiLibrary.json');
      final backupFile = File('${dir.path}/$miruryoikiLibrary.mappings.json');
      if (await file.exists()) {
        await file.copy(backupFile.path);
        logDebug('Created backup after updating mappings');
      }
    } catch (e) {
      logDebug('Error creating mapping backup: $e');
    }
    return true;
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

  /// Calculate dominant colors only for series that need it
  Future<void> calculateDominantColors({bool forceRecalculate = false}) async {
    // Determine which series need processing
    final seriesToProcess = forceRecalculate ? _series : _series.where((s) => s.dominantColor == null).toList();

    if (seriesToProcess.isEmpty) {
      logTrace('No series need dominant color calculation');
      return;
    }

    logTrace('Calculating dominant colors for ${seriesToProcess.length} series');
    int processed = 0;
    bool anyChanged = false;

    // Process one series at a time to avoid UI freezes
    for (final series in seriesToProcess) {
      try {
        final oldColor = series.dominantColor;
        await series.calculateDominantColor(forceRecalculate: forceRecalculate);
        processed++;

        // Check if color actually changed
        if (oldColor != series.dominantColor) {
          anyChanged = true;
        }

        // Update UI periodically
        if (processed % 3 == 0 || processed == seriesToProcess.length) {
          _isDirty = true;
          notifyListeners();

          // Save more frequently to preserve progress
          if (processed % 10 == 0) {
            logTrace('Saving library after processing $processed series');
            await _saveLibrary();
          }
        }
      } catch (e) {
        logErr('Error calculating dominant color for ${series.name}', e);
      }

      // Delay to avoid overwhelming the UI
      await Future.delayed(const Duration(milliseconds: 15));
    }

    // Save and notify when done
    if (anyChanged || forceRecalculate) {
      _isDirty = true;
      await _saveLibrary();
      notifyListeners();
      logTrace('Finished calculating dominant colors for $processed series');
      snackBar(
        'Finished calculating dominant colors for $processed series',
        severity: InfoBarSeverity.success,
      );
    }
  }
}
