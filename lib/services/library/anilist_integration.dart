part of 'library_provider.dart';

extension LibraryAnilistIntegration on Library {
  /// Load Anilist posters for series that have links but no local images
  Future<void> loadAnilistPostersForLibrary({void Function(int loaded, int total)? onProgress}) async {
    final linkService = SeriesLinkService();
    final imageCache = ImageCacheService();
    await imageCache.init();

    final needPosters = <Series>[];
    final alreadyCached = <Series>[];
    final recalculateColor = <Series>[];
    int linked = 0;

    logDebug('\n5 | Loading Anilist posters for library...', splitLines: true);
    // Find series that need Anilist posters
    for (final Series series in _series) {
      // For all linked series, check if they need to use Anilist posters based on preferences
      if (series.isLinked) {
        linked++;
        final effectiveSource = series.preferredPosterSource ?? Manager.defaultPosterSource;
        final shouldUseAnilist = effectiveSource == ImageSource.anilist || effectiveSource == ImageSource.autoAnilist;

        // First check if the series itself has poster data
        if (series.anilistPosterUrl != null) {
          final String? cachedUrl = await imageCache.getCachedImagePath(series.anilistPosterUrl!);
          if (cachedUrl != null) {
            // WE KNOW THE POSTER URL ALREADY
            logTrace('   5 | Poster URL for ${substringSafe(series.name, 0, 20, '"').padRight(22, " ")} is saved in LOCAL: ${substringSafe(series.anilistPosterUrl!, series.anilistPosterUrl!.length - 31, series.anilistPosterUrl!.length)}');

            alreadyCached.add(series);
            recalculateColor.add(series);

            continue; // Skip checking mappings if series already has data
          }
        }

        // WE DON'T KNOW THE POSTER URL YET
        // Check if we can find the poster URL without fetching
        final AnilistMapping mapping = series.anilistMappings.firstWhere(
          (m) => m.anilistId == (series.primaryAnilistId ?? series.anilistMappings.first.anilistId),
          orElse: () => series.anilistMappings.first,
        );

        // If we have anilistData with a poster URL check if it's cached
        // logTrace("series: $series\nprimaryAnilistId: ${series.primaryAnilistId}, primaryID from first mapping:${series.anilistMappings.firstOrNull?.anilistId}\nmapping: ${mapping.anilistData?.id}");
        if (series.anilistPosterUrl != null) {
          final String? cached = await imageCache.getCachedImagePath(series.anilistPosterUrl!);
          if (cached != null) {
            logTrace('5 | Poster for ${substringSafe(series.name, 0, 20, '"')} is already cached in ANILIST: ${series.anilistPosterUrl!}');
            // Already cached -> make sure series data is properly updated
            alreadyCached.add(series);

            // Make sure series.anilistData is set correctly
            if (series.primaryAnilistId == mapping.anilistId || series.primaryAnilistId == null) {
              series.anilistData = mapping.anilistData;
              // Need to recalculate the dominant color for this series
              recalculateColor.add(series);
            }
          } else if (shouldUseAnilist || series.folderPosterPath == null) {
            logTrace('5 | Poster for ${substringSafe(series.name, 0, 20, '"')} is not cached, needs fetching: ${series.anilistPosterUrl}');
            // Not cached -> need to fetch if we should use Anilist or have no local poster
            needPosters.add(series);
          }
        } else if (shouldUseAnilist || series.folderPosterPath == null) {
          logTrace('5 | No poster image for ${substringSafe(series.name, 0, 20, '"')}, needs fetching from Anilist\npath: "${series.folderPosterPath}", shouldUseAnilist: $shouldUseAnilist');
          // No anilistData or no posterImage -> need to fetch
          needPosters.add(series);
        } else {
          logTrace('5 | Skipping ${substringSafe(series.name, 0, 20, '"')}, no Anilist poster needed based on preferences');
        }
      }
      // else
      //     series not linked series, skip
    }
    logDebug('5 | Found $linked linked series, ${needPosters.length} need posters, ${alreadyCached.length} already cached', splitLines: true);

    // Recalculate dominant colors for already cached series, in case their poster was updated
    // if (recalculateColor.isNotEmpty) {
    //   logTrace('\n5 | OPTIONAL RECALCULATE: Recalculating dominant colors for ${recalculateColor.length} already cached url posters', splitLines: true);
    //   for (final series in recalculateColor) {
    //     await series.calculateDominantColor();
    //   }
    //   logTrace('5 | OPTIONAL RECALCULATE ----------------------------------------------------------');
    // }

    if (alreadyCached.isNotEmpty) {
      notifyListeners();
      onProgress?.call(alreadyCached.length, alreadyCached.length + needPosters.length);
    }

    if (needPosters.isEmpty) return;

    logDebug('\n5 | FETCHING Anilist posters for ${needPosters.length} series', splitLines: true);

    // Fetch posters in batches
    int loaded = alreadyCached.length;
    final total = alreadyCached.length + needPosters.length;

    // Fetch posters in batches to avoid overwhelming the API
    for (int i = 0; i < needPosters.length; i += 5) {
      final batch = needPosters.sublist(i, i + 5 > needPosters.length ? needPosters.length : i + 5);

      await Future.wait(batch.map((series) async {
        final int anilistId = series.primaryAnilistId ?? series.anilistMappings.first.anilistId;
        final AnilistAnime? anime = await linkService.fetchAnimeDetails(anilistId);

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
                lastSynced: now,
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

    notifyListeners();
  }

  /// Reload all Anilist posters, optionally forcing even if they already have images
  Future<void> refreshAnilistPosters({bool forceAll = false}) async {
    final linkService = SeriesLinkService();
    final refreshSeries = <Series>[];

    // Identify series that need refreshing
    for (final series in _series) {
      if (forceAll) {
        if (series.isLinked) {
          refreshSeries.add(series);
        }
      } else if (series.folderPosterPath == null && series.isLinked) {
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
                lastSynced: now,
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

  /// Link a series with an Anilist anime
  Future<void> linkSeriesWithAnilist(Series series, int anilistId, {PathString? localPath, String? title}) async {
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
          lastSynced: now,
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
        lastSynced: now,
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

  /// Unlink a series from Anilist
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

    await _backupMappings();

    await _saveLibrary();
    notifyListeners();

    try {
      final dir = miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/${Library.miruryoikiLibrary}.json');
      final backupFile = File('${dir.path}/${Library.miruryoikiLibrary}.mappings.json');
      if (await file.exists()) {
        await file.copy(backupFile.path);
        logDebug('Created backup after updating mappings');
      }
    } catch (e, st) {
      logErr('Error creating mapping backup', e, st);
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
}
