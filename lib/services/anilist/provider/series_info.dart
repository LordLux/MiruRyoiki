part of 'anilist_provider.dart';

extension AnilistProviderSeriesInfo on AnilistProvider {
  /// Get media list entries for the series
  Map<int, AnilistMediaListEntry?> getMediaListEntries(Series series) {
    if (!series.isLinked) return {};

    final Map<int, AnilistMediaListEntry?> mediaListEntries = {};

    for (final mapping in series.anilistMappings) {
      bool found = false;
      for (final list in userLists.values) {
        for (final listEntry in list.entries) {
          if (listEntry.mediaId == mapping.anilistId) {
            // If the mapping is found in the list, add it to the map
            mediaListEntries[mapping.anilistId] = listEntry;
            found = true;
            break;
          }
        }
        if (found) break;
      }

      // If not found in any list, add null
      if (!found) mediaListEntries[mapping.anilistId] = null;
    }

    return mediaListEntries;
  }

  /// Get the best entry values from all user's list entries for this series
  (AnilistMediaListEntry?, int?, int?, DateTime?, DateTime?, int?, DateTime?, DateTime?, int?)? getSeriesInfoFromMediaListEntry(Series series) {
    if (!series.isLinked) return null;

    // Make sure media list entries are populated
    final entries = getMediaListEntries(series);
    if (entries.isEmpty) return null;

    // Values to collect from all mappings
    AnilistMediaListEntry? bestEntry;

    int? latestUpdatedAt; //            updatedAt    - list updated timestamp
    int? earliestCreatedAt; //          createdAt    - added to list timestamp
    DateTime? earliestStartedAt; //     startedAt    - user started entry timestamp
    DateTime? latestCompletionDate; //  completedAt  - user completion date
    int? averageUserScore; //           averageScore - user score
    DateTime? earliestReleaseDate; //   startDate    - official release date
    DateTime? latestEndDate; //         endDate      - official end date
    int? averagePopularity; //          popularity   - popularity

    // Variables for calculating averages
    int totalUserScore = 0;
    int userScoreCount = 0;
    int totalPopularity = 0;
    int popularityCount = 0;

    // Process each mapping's media list entry
    for (final anilistId in entries.keys) {
      final entry = entries[anilistId];

      if (entry != null) {
        // List updated timestamp - take the most recent
        if (entry.updatedAt != null && (latestUpdatedAt == null || entry.updatedAt! > latestUpdatedAt)) {
          latestUpdatedAt = entry.updatedAt;
        }

        // Added to list timestamp - take the earliest
        if (entry.createdAt != null && (earliestCreatedAt == null || entry.createdAt! < earliestCreatedAt)) {
          earliestCreatedAt = entry.createdAt;
        }

        // User started entry timestamp - take the earliest
        final startedDate = entry.startedAt?.toDateTime();
        if (startedDate != null && (earliestStartedAt == null || startedDate.isBefore(earliestStartedAt))) {
          earliestStartedAt = startedDate;
        }

        // User completion date - take the latest
        final completedDate = entry.completedAt?.toDateTime();
        if (completedDate != null && (latestCompletionDate == null || completedDate.isAfter(latestCompletionDate))) {
          latestCompletionDate = completedDate;
          // Track the entry with the latest completion date as the "best" entry
          bestEntry = entry;
        }

        // User score - collect for average calculation
        if (entry.score != null) {
          totalUserScore += entry.score!;
          userScoreCount++;
        }
      }

      // Get release date from the anime data for this mapping
      final mapping = series.anilistMappings.where((m) => m.anilistId == anilistId).firstOrNull;
      final animeData = mapping?.anilistData;
      if (animeData != null) {
        // Release date - take the earliest
        final releaseDate = animeData.startDate?.toDateTime();
        if (releaseDate != null && (earliestReleaseDate == null || releaseDate.isBefore(earliestReleaseDate))) {
          earliestReleaseDate = releaseDate;
        }

        final endDate = animeData.endDate?.toDateTime();
        if (endDate != null && (latestEndDate == null || endDate.isAfter(latestEndDate))) {
          latestEndDate = endDate;
        }

        // Popularity - collect for average calculation
        if (animeData.popularity != null) {
          totalPopularity += animeData.popularity!;
          popularityCount++;
        }
      }
    }

    // Calculate averages
    if (userScoreCount > 0) averageUserScore = (totalUserScore / userScoreCount).round();

    if (popularityCount > 0) averagePopularity = (totalPopularity / popularityCount).round();

    return (
      bestEntry, //$1
      latestUpdatedAt, //$2
      earliestCreatedAt, //$3
      earliestStartedAt, //$4
      latestCompletionDate, //$5
      averageUserScore, //$6
      earliestReleaseDate, //$7
      latestEndDate, //$8
      averagePopularity, //$9
    );
  }

  /// When the user last updated this series in their list
  int? getLatestUpdatedAt(Series series) => getSeriesInfoFromMediaListEntry(series)?.$2;

  /// When the user added this series to their list
  int? getEarliestCreatedAt(Series series) => getSeriesInfoFromMediaListEntry(series)?.$3;

  /// When the user started watching this series
  DateTime? getEarliestStartedAt(Series series) => getSeriesInfoFromMediaListEntry(series)?.$4;

  /// When the user completed watching this series
  DateTime? getLatestCompletionDate(Series series) => getSeriesInfoFromMediaListEntry(series)?.$5;

  /// The highest user score for this series
  int? getHighestUserScore(Series series) => getSeriesInfoFromMediaListEntry(series)?.$6;

  /// The earliest release date for this series
  DateTime? getEarliestReleaseDate(Series series) => getSeriesInfoFromMediaListEntry(series)?.$7;

  /// The latest end date for this series
  DateTime? getLatestEndDate(Series series) => getSeriesInfoFromMediaListEntry(series)?.$8;

  /// The highest popularity for this series
  int? getHighestPopularity(Series series) => getSeriesInfoFromMediaListEntry(series)?.$9;

  // Helper method to get specific media list entry for a given path
  AnilistMediaListEntry? getMediaListEntry(Series series) {
    if (!series.isLinked) return null;

    // Make sure entries are populated
    final entries = getMediaListEntries(series);

    // Use the primary mapping's entry if available
    if (series.primaryAnilistId != null && entries.containsKey(series.primaryAnilistId)) {
      return entries[series.primaryAnilistId];
    }

    // Otherwise return the first non-null entry
    for (final entry in entries.values) {
      if (entry != null) return entry;
    }

    return null;
  }

  bool isAnilistHidden(Series series) => series.isLinked && getMediaListEntries(series).values.any((entry) => entry?.hiddenFromStatusLists == true);
}