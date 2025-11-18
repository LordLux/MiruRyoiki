import '../../models/series.dart';
import '../../utils/logging.dart';

/// Service for searching through the library with fuzzy matching support.
///
/// Provides efficient search functionality with two phases
/// - Exact matching
/// - Fuzzy matching (for typo tolerance) only if exact matching yields no results
class LibrarySearchService {
  /// Search through a list of series based on a query string.
  ///
  /// Searches through:
  /// - Series display name
  /// - All AniList mapping titles
  ///
  /// Returns a list of matching series sorted by relevance (exact matches first)
  static List<Series> search(String query, List<Series> allSeries) {
    if (query.isEmpty) return allSeries;

    final normalizedQuery = query.toLowerCase().trim();
    if (normalizedQuery.isEmpty) return allSeries;

    // Exact substring matching
    final exactMatches = _exactMatch(normalizedQuery, allSeries);

    if (exactMatches.isNotEmpty) return exactMatches;

    // Fuzzy matching only if exact matching found nothing
    logTrace('No exact matches for "$query", attempting fuzzy search');
    return _fuzzyMatch(normalizedQuery, allSeries);
  }

  /// Exact substring matching
  static List<Series> _exactMatch(String normalizedQuery, List<Series> allSeries) {
    final matches = <Series>[];

    for (final series in allSeries) {
      // Check series display name
      if (series.name.toLowerCase().contains(normalizedQuery)) {
        matches.add(series);
        continue;
      }

      // Check all AniList mapping titles
      bool foundInMapping = false;
      for (final mapping in series.anilistMappings) {
        // Check title from mapping object
        if (mapping.title != null && mapping.title!.toLowerCase().contains(normalizedQuery)) {
          foundInMapping = true;
          break;
        }

        // Check titles from AniList data if available
        final anilistData = mapping.anilistData;
        if (anilistData != null) {
          // Check romaji title
          if (anilistData.title.romaji?.toLowerCase().contains(normalizedQuery) ?? false) {
            foundInMapping = true;
            break;
          }
          // Check english title
          if (anilistData.title.english?.toLowerCase().contains(normalizedQuery) ?? false) {
            foundInMapping = true;
            break;
          }
          // Check native title
          if (anilistData.title.native?.toLowerCase().contains(normalizedQuery) ?? false) {
            foundInMapping = true;
            break;
          }
          // Check user preferred title
          if (anilistData.title.userPreferred?.toLowerCase().contains(normalizedQuery) ?? false) {
            foundInMapping = true;
            break;
          }
        }

        if (foundInMapping) break;
      }

      if (foundInMapping) matches.add(series);
    }

    return matches;
  }

  /// Fuzzy matching with Levenshtein distance
  ///
  /// Allows typos based on query length:
  /// - 1-4 chars: max 1 typo
  /// - 5-8 chars: max 2 typos
  /// - 9+ chars: max 3 typos
  ///
  /// Matches against individual words and full strings
  static List<Series> _fuzzyMatch(String normalizedQuery, List<Series> allSeries) {
    final maxDistance = _calculateMaxDistance(normalizedQuery.length);
    final matchesWithScore = <({Series series, int distance, String matchedText})>[];

    for (final series in allSeries) {
      int? bestDistance;
      String? bestMatchedText;

      // Check series display name
      final seriesNameDistance = _fuzzyCheckString(normalizedQuery, series.name.toLowerCase(), maxDistance);
      if (seriesNameDistance != null && seriesNameDistance <= maxDistance) {
        bestDistance = seriesNameDistance;
        bestMatchedText = series.name;
      }

      // Check all AniList mapping titles
      for (final mapping in series.anilistMappings) {
        // Check title from mapping object
        if (mapping.title != null) {
          final distance = _fuzzyCheckString(normalizedQuery, mapping.title!.toLowerCase(), maxDistance);
          if (distance != null && distance <= maxDistance && (bestDistance == null || distance < bestDistance)) {
            bestDistance = distance;
            bestMatchedText = mapping.title;
          }
        }

        // Check titles from AniList data if available
        final anilistData = mapping.anilistData;
        if (anilistData != null) {
          // Check romaji title
          if (anilistData.title.romaji != null) {
            final distance = _fuzzyCheckString(normalizedQuery, anilistData.title.romaji!.toLowerCase(), maxDistance);
            if (distance != null && distance <= maxDistance && (bestDistance == null || distance < bestDistance)) {
              bestDistance = distance;
              bestMatchedText = anilistData.title.romaji;
            }
          }

          // Check english title
          if (anilistData.title.english != null) {
            final distance = _fuzzyCheckString(normalizedQuery, anilistData.title.english!.toLowerCase(), maxDistance);
            if (distance != null && distance <= maxDistance && (bestDistance == null || distance < bestDistance)) {
              bestDistance = distance;
              bestMatchedText = anilistData.title.english;
            }
          }

          // Check native title
          if (anilistData.title.native != null) {
            final distance = _fuzzyCheckString(normalizedQuery, anilistData.title.native!.toLowerCase(), maxDistance);
            if (distance != null && distance <= maxDistance && (bestDistance == null || distance < bestDistance)) {
              bestDistance = distance;
              bestMatchedText = anilistData.title.native;
            }
          }

          // Check user preferred title
          if (anilistData.title.userPreferred != null) {
            final distance = _fuzzyCheckString(normalizedQuery, anilistData.title.userPreferred!.toLowerCase(), maxDistance);
            if (distance != null && distance <= maxDistance && (bestDistance == null || distance < bestDistance)) {
              bestDistance = distance;
              bestMatchedText = anilistData.title.userPreferred;
            }
          }
        }
      }

      if (bestDistance != null) //
        matchesWithScore.add((series: series, distance: bestDistance, matchedText: bestMatchedText ?? series.name));
    }

    matchesWithScore.sort((a, b) => a.distance.compareTo(b.distance));

    // if (matchesWithScore.isNotEmpty) {
    //   logTrace('Found ${matchesWithScore.length} fuzzy matches:');
    //   for (final match in matchesWithScore.take(5)) {
    //     logTrace('  - ${match.series.name} (matched: "${match.matchedText}", distance: ${match.distance})');
    //   }
    // }

    return matchesWithScore.map((m) => m.series).toList();
  }

  /// Check a string for fuzzy match by comparing against the full string and individual words
  /// Returns the lowest distance found, or null if no match
  static int? _fuzzyCheckString(String query, String target, int maxDistance) {
    // Check full string
    final fullDistance = _levenshteinDistance(query, target);
    if (fullDistance <= maxDistance) return fullDistance;

    // Check individual words
    final words = target.split(RegExp(r'[\s\-_]+'));
    int? bestWordDistance;

    for (final word in words) {
      if (word.isEmpty) continue;

      final wordDistance = _levenshteinDistance(query, word);
      if (wordDistance <= maxDistance) {
        if (bestWordDistance == null || wordDistance < bestWordDistance) //
          bestWordDistance = wordDistance;
      }
    }

    return bestWordDistance;
  }

  /// Maximum allowed Levenshtein distance based on query length
  static int _calculateMaxDistance(int queryLength) {
    if (queryLength <= 4) return 1;
    if (queryLength <= 8) return 2;
    return 3;
  }

  /// Calculate Levenshtein distance between two strings
  /// (only two rows instead of full matrix)
  static int _levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final len1 = s1.length;
    final len2 = s2.length;

    // Use two rows instead of full matrix for space optimization
    List<int> previousRow = List.generate(len2 + 1, (i) => i);
    List<int> currentRow = List.filled(len2 + 1, 0);

    for (int i = 1; i <= len1; i++) {
      currentRow[0] = i;

      for (int j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;

        currentRow[j] = [
          previousRow[j] + 1, // deletion
          currentRow[j - 1] + 1, // insertion
          previousRow[j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }

      // Swap rows
      final temp = previousRow;
      previousRow = currentRow;
      currentRow = temp;
    }

    return previousRow[len2];
  }
}
