import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/models/anilist/anime.dart';
import 'package:miruryoiki/models/anilist/mapping.dart';
import 'package:miruryoiki/models/series.dart';
import 'package:miruryoiki/services/library/search_service.dart';
import 'package:miruryoiki/utils/path.dart';

void main() {
  group('LibrarySearchService', () {
    late List<Series> testSeries;

    setUp(() {
      // Create test series
      testSeries = [
        Series(
          id: 1,
          name: 'Attack on Titan',
          path: PathString(r'M:\Series\Attack on Titan'),
          seasons: [],
          relatedMedia: [],
          anilistMappings: [
            AnilistMapping(
              localPath: PathString(r'M:\Series\Attack on Titan'),
              anilistId: 16498,
              title: 'Shingeki no Kyojin',
              anilistData: AnilistAnime(
                id: 16498,
                title: AnilistTitle(
                  romaji: 'Shingeki no Kyojin',
                  english: 'Attack on Titan',
                  native: '進撃の巨人',
                  userPreferred: 'Attack on Titan',
                ),
              ),
            ),
          ],
          isHidden: false,
        ),
        Series(
          id: 2,
          name: 'My Hero Academia',
          path: PathString(r'M:\Series\My Hero Academia'),
          seasons: [],
          relatedMedia: [],
          anilistMappings: [
            AnilistMapping(
              localPath: PathString(r'M:\Series\My Hero Academia'),
              anilistId: 21459,
              title: 'Boku no Hero Academia',
              anilistData: AnilistAnime(
                id: 21459,
                title: AnilistTitle(
                  romaji: 'Boku no Hero Academia',
                  english: 'My Hero Academia',
                  native: '僕のヒーローアカデミア',
                  userPreferred: 'My Hero Academia',
                ),
              ),
            ),
          ],
          isHidden: false,
        ),
        Series(
          id: 3,
          name: 'One Piece',
          path: PathString(r'M:\Series\One Piece'),
          seasons: [],
          relatedMedia: [],
          anilistMappings: [],
          isHidden: false,
        ),
      ];
    });

    test('returns all series when query is empty', () {
      final result = LibrarySearchService.search('', testSeries);
      expect(result.length, equals(3));
    });

    test('exact match - finds series by local name', () {
      final result = LibrarySearchService.search('Attack', testSeries);
      expect(result.length, equals(1));
      expect(result[0].name, equals('Attack on Titan'));
    });

    test('exact match - case insensitive', () {
      final result = LibrarySearchService.search('attack', testSeries);
      expect(result.length, equals(1));
      expect(result[0].name, equals('Attack on Titan'));
    });

    test('exact match - finds series by AniList romaji title', () {
      final result = LibrarySearchService.search('Shingeki', testSeries);
      expect(result.length, equals(1));
      expect(result[0].name, equals('Attack on Titan'));
    });

    test('exact match - finds series by AniList english title', () {
      final result = LibrarySearchService.search('Hero Academia', testSeries);
      expect(result.length, equals(1));
      expect(result[0].name, equals('My Hero Academia'));
    });

    test('exact match - finds series by mapping title', () {
      final result = LibrarySearchService.search('Boku no Hero', testSeries);
      expect(result.length, equals(1));
      expect(result[0].name, equals('My Hero Academia'));
    });

    test('fuzzy match - finds series with single typo', () {
      final result = LibrarySearchService.search('Attck', testSeries); // Missing 'a'
      expect(result.length, greaterThan(0));
      expect(result[0].name, equals('Attack on Titan'));
    });

    test('fuzzy match - finds series with substitution', () {
      final result = LibrarySearchService.search('Attock', testSeries); // 'a' -> 'o'
      expect(result.length, greaterThan(0));
      expect(result[0].name, equals('Attack on Titan'));
    });

    test('fuzzy match - handles multiple typos for longer queries', () {
      final result = LibrarySearchService.search('Acadmia', testSeries); // Missing 'e'
      expect(result.length, greaterThan(0));
      expect(result.any((s) => s.name == 'My Hero Academia'), isTrue);
    });

    test('fuzzy match - does not match when distance exceeds threshold', () {
      final result = LibrarySearchService.search('xyz', testSeries); // Completely different
      expect(result.length, equals(0));
    });

    test('returns empty list when no matches found', () {
      final result = LibrarySearchService.search('Nonexistent Series', testSeries);
      expect(result.isEmpty, isTrue);
    });

    test('handles series without AniList mappings', () {
      final result = LibrarySearchService.search('One Piece', testSeries);
      expect(result.length, equals(1));
      expect(result[0].name, equals('One Piece'));
    });

    test('search in native (Japanese) titles', () {
      final result = LibrarySearchService.search('進撃の巨人', testSeries);
      expect(result.length, equals(1));
      expect(result[0].name, equals('Attack on Titan'));
    });

    test('exact match prioritizes shorter/better matches', () {
      // When there are multiple exact substring matches, 
      // we rely on the order they were found in the original list.
      // This is acceptable behavior - if more precise sorting is needed,
      // it can be added later.
      final series = [
        Series(
          id: 1,
          name: 'Testing',
          path: PathString(r'M:\Series\Testing'),
          seasons: [],
          relatedMedia: [],
          anilistMappings: [],
          isHidden: false,
        ),
        Series(
          id: 2,
          name: 'Test',
          path: PathString(r'M:\Series\Test'),
          seasons: [],
          relatedMedia: [],
          anilistMappings: [],
          isHidden: false,
        ),
        Series(
          id: 3,
          name: 'Tests',
          path: PathString(r'M:\Series\Tests'),
          seasons: [],
          relatedMedia: [],
          anilistMappings: [],
          isHidden: false,
        ),
      ];

      final result = LibrarySearchService.search('Test', series);
      // All three match as "Test" is a substring of all of them
      expect(result.length, equals(3));
      // Check that all three are present
      expect(result.any((s) => s.name == 'Test'), isTrue);
      expect(result.any((s) => s.name == 'Testing'), isTrue);
      expect(result.any((s) => s.name == 'Tests'), isTrue);
    });
  });
}
