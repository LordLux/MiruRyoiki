part of 'library_provider.dart';

extension LibraryInitialization on Library {
  Future<void> initialize(BuildContext context) async {
    if (!_initialized) {
      await _loadLibrary();
      _initialized = true;
    }
    final BuildContext ctx;
    if (context.mounted)
      ctx = context;
    else
      ctx = Manager.context;
    // ignore: use_build_context_synchronously
    nextFrame(() {
      final appTheme = Provider.of<AppTheme>(ctx, listen: false);
      appTheme.setEffect(appTheme.windowEffect, rootNavigatorKey.currentContext!);
    });
    await loadLibraryFirstTime(ctx);
  }

  // DISPOSE IN MAIN

  Future<void> loadLibraryFirstTime(BuildContext context) async {
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);

    // 2. Initialize Anilist API
    await anilistProvider.initialize();

    // if (!anilistProvider.isOffline && anilistProvider.isLoggedIn) {
    //   // This will load the latest data and update the cache
    //   await anilistProvider.refreshUserLists();
    // }

    // 3. Scan Library
    await scanLocalLibrary();

    // Initialize MPC Tracker
    if (!Manager.skipRegistryIndexing && !kDebugMode) await _mpcTracker.ensureInitialized();

    // Update watched status and force refresh
    await _updateWatchedStatusAndForceRefresh();

    // Save library
    await _saveLibrary();

    // 4. Validate Cache
    await ensureCacheValidated();

    // 5. Load posters for library
    await loadAnilistPostersForLibrary(onProgress: (loaded, total) {
      if (loaded % 2 == 0 || loaded == total) {
        // Force UI refresh every 5 items or on completion
        // if (context.mounted) Manager.setState();
      }
    });
    logTrace('Library initialized successfully');
  }

  Future<void> reloadLibrary({bool force = false}) async {
    if (_libraryPath == null) return;
    if (!force && _isLoading) return;
    logDebug('Reloading Library...');

    snackBar('Reloading Library...', severity: InfoBarSeverity.info);
    await scanLocalLibrary();

    await _mpcTracker.ensureInitialized();

    await _updateWatchedStatusAndForceRefresh();

    await _saveLibrary();

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

  Future<void> _updateWatchedStatusAndForceRefresh() async {
    _updateWatchedStatusAndResetThumbnailFetchFailedAttemptsCount();
    // Force immediate save and UI refresh
    // _isDirty = true;
    await forceImmediateSave();
    notifyListeners();
  }

  void _updateWatchedStatusAndResetThumbnailFetchFailedAttemptsCount() {
    if (!_mpcTracker.isInitialized) return;
    logTrace('3 | Getting watched status for all series and resetting thumbnail fetch attempts');

    for (final series in _series) {
      // Update seasons/episodes
      for (final season in series.seasons) {
        for (final episode in season.episodes) {
          // Update watch percentages from tracker
          final trackerPercentage = _mpcTracker.getWatchPercentage(episode.path);
          if (trackerPercentage > 0.0) {
            episode.watchedPercentage = trackerPercentage;
            episode.watched = _mpcTracker.isWatched(episode.path);
          }
          episode.resetThumbnailStatus();
        }
      }

      // Update related media
      for (final episode in series.relatedMedia) {
        final trackerPercentage = _mpcTracker.getWatchPercentage(episode.path);
        if (trackerPercentage > 0.0) {
          episode.watchedPercentage = trackerPercentage;
          episode.watched = _mpcTracker.isWatched(episode.path);
        }
        episode.resetThumbnailStatus();
      }
    }

    Episode.resetAllFailedAttempts();
  }
}
