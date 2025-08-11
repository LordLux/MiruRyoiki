part of 'library_provider.dart';

extension LibraryInitialization on Library {
  Future<void> initialize(BuildContext context) async {
    if (!_initialized) {
      await _loadLibrary(); // Fast DB load
      _initialized = true;
    }

    // Asynchronously start the full loading process after the UI is built
    nextFrame(() {
      final appTheme = Provider.of<AppTheme>(context, listen: false);
      appTheme.setEffect(appTheme.windowEffect, rootNavigatorKey.currentContext!);
      startBackgroundLoading(context);
    });
  }

  /// The main, long-running initialization sequence, now non-blocking.
  Future<void> startBackgroundLoading(BuildContext context) async {
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);

    // 1. Scan Local Library (this now reports progress and manages its own state)
    await scanLocalLibrary();

    // 2. Initialize Anilist online features (only runs after scan is complete)
    await anilistProvider.initializeOnlineFeatures();

    // Initialize MPC Tracker
    if (!Manager.skipRegistryIndexing && !kDebugMode) await _mpcTracker.ensureInitialized();

    // 3. Validate Cache
    await ensureCacheValidated();

    // 4. Load posters for library
    await loadAnilistPostersForLibrary(onProgress: (loaded, total) {
      if (loaded % 2 == 0 || loaded == total) {
        // UI can be notified of progress here if needed
      }
    });
    logTrace('Full library initialization complete.');
  }

  // DISPOSE IN MAIN

  Future<void> reloadLibrary({bool force = false}) async {
    if (_libraryPath == null) return;
    if (!force && _isScanning) return;
    logDebug('Reloading Library...');

    snackBar('Reloading Library...', severity: InfoBarSeverity.info);
    await scanLocalLibrary();

    await _mpcTracker.ensureInitialized();

    await ensureCacheValidated();

    await loadAnilistPostersForLibrary(onProgress: (loaded, total) {
      if (loaded % 2 == 0 || loaded == total) {
        // Force UI refresh every 2 items or on completion
        Manager.setState();
      }
    });

    logDebug('Finished Reloading Library');
    snackBar('Library Reloaded', severity: InfoBarSeverity.success);
    notifyListeners();
    Manager.setState();
  }

  Future<void> cacheValidation() async {
    if (!_cacheValidated) {
      logDebug('\n4 | Ensuring cache validation...', splitLines: true);
      final imageCache = ImageCacheService();
      await imageCache.init();

      // Validate cache for all series with Anilist data
      for (final series in _series) {
        // First check the series' primary data (what's shown in UI)
        if (series.anilistData?.posterImage != null) {
          final cachedPosterPath = await imageCache.getCachedImagePath(series.anilistData!.posterImage!);
          if (cachedPosterPath == null) {
            imageCache.cacheImage(series.anilistData!.posterImage!);
            logTrace('4 | Re-caching poster for: ${series.name}');
          }
        }

        if (series.anilistData?.bannerImage != null) {
          final cachedBannerPath = await imageCache.getCachedImagePath(series.anilistData!.bannerImage!);
          if (cachedBannerPath == null) {
            imageCache.cacheImage(series.anilistData!.bannerImage!);
            logTrace('4 | Re-caching banner for: ${series.name}');
          }
        }

        // Then check each mapping's anilist data as a fallback
        for (final mapping in series.anilistMappings) {
          if (mapping.anilistData?.posterImage != null && mapping.anilistData?.posterImage != series.anilistData?.posterImage) {
            final cachedPath = await imageCache.getCachedImagePath(mapping.anilistData!.posterImage!);
            if (cachedPath == null) {
              imageCache.cacheImage(mapping.anilistData!.posterImage!);
              logTrace('4 | Re-caching mapping poster for: ${series.name}');
            }
          }

          if (mapping.anilistData?.bannerImage != null && mapping.anilistData?.bannerImage != series.anilistData?.bannerImage) {
            final cachedPath = await imageCache.getCachedImagePath(mapping.anilistData!.bannerImage!);
            if (cachedPath == null) {
              imageCache.cacheImage(mapping.anilistData!.bannerImage!);
              logTrace('4 | Re-caching mapping banner for: ${series.name}');
            }
          }
        }
      }

      _cacheValidated = true;
      logDebug('4 | Cache validation complete');
      notifyListeners();
    }
  }

  Future<void> ensureCacheValidated() async {
    if (!_cacheValidated) await cacheValidation();
  }

  void _updateWatchedStatusAndResetThumbnailFetchFailedAttemptsCount() {
    if (!_mpcTracker.isInitialized) return;
    logTrace('3 | Getting watched status for all series and resetting thumbnail fetch attempts');

    for (final series in _series) {
      // Update seasons/episodes
      final seriesIndex = _series.indexOf(series);
      for (final season in series.seasons) {
        final seasonIndex = series.seasons.indexOf(season);
        for (final episode in season.episodes) {
          final episodeIndex = season.episodes.indexOf(episode);
          // Update watch percentages from tracker
          final trackerPercentage = _mpcTracker.getWatchPercentage(episode.path);
          if (trackerPercentage > 0.0) {
            _series[seriesIndex].seasons[seasonIndex].episodes[episodeIndex].watchedPercentage = trackerPercentage;
            _series[seriesIndex].seasons[seasonIndex].episodes[episodeIndex].watched = _mpcTracker.isWatched(episode.path);
          }
          _series[seriesIndex].seasons[seasonIndex].episodes[episodeIndex].resetThumbnailStatus();
        }
      }

      // Update related media
      for (final episode in series.relatedMedia) {
        final episodeIndex = series.relatedMedia.indexOf(episode);
        final trackerPercentage = _mpcTracker.getWatchPercentage(episode.path);
        if (trackerPercentage > 0.0) {
          _series[seriesIndex].relatedMedia[episodeIndex].watchedPercentage = trackerPercentage;
          _series[seriesIndex].relatedMedia[episodeIndex].watched = _mpcTracker.isWatched(episode.path);
        }
        _series[seriesIndex].relatedMedia[episodeIndex].resetThumbnailStatus();
      }
    }

    Episode.resetAllFailedAttempts();
  }
}
