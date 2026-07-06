import 'package:flutter_anitomy/flutter_anitomy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/models/anilist/anime.dart';
import 'package:miruryoiki/models/anilist/mapping.dart';
import 'package:miruryoiki/models/episode.dart';
import 'package:miruryoiki/models/series.dart';
import 'package:miruryoiki/utils/path.dart';
import 'package:miruryoiki/viewmodels/home_viewmodel.dart';

/// Pure-logic tests for [HomeViewModel]'s static helpers: watching-list
/// filtering/sorting, Continue Watching vs Next Up split, and upcoming-episode
/// selection/sorting. No providers or database involved.

Series _series(String name, {List<int> anilistIds = const []}) => Series(
      name: name,
      path: PathString('M:/S/$name'),
      collections: const [],
      anilistMappings: [
        for (final id in anilistIds)
          AnilistMapping(
            localPath: PathString('M:/S/$name'),
            anilistId: id,
          ),
      ],
    );

Episode _episode(String name, {double progress = 0.0, bool watched = false}) => Episode(
      name: name,
      path: PathString('M:/S/x/$name'),
      progress: progress,
      watched: watched,
      parsedAnime: ParsedAnime(),
    );

void main() {
  group('filterWatching', () {
    test('keeps only linked, non-hidden series with a mapping in the watching list', () {
      final inList = _series('A', anilistIds: [1]);
      final notInList = _series('B', anilistIds: [2]);
      final unlinked = _series('C');
      final hidden = _series('D', anilistIds: [3]);

      final result = HomeViewModel.filterWatching(
        librarySeries: [inList, notInList, unlinked, hidden],
        watchingIds: {1, 3},
        isHidden: (s) => s.name == 'D',
      );

      expect(result, [inList]);
    });
  });

  group('sortByRecentlyUpdated', () {
    test('most recently updated first', () {
      final a = _series('A', anilistIds: [1]);
      final b = _series('B', anilistIds: [2]);
      final c = _series('C', anilistIds: [3]);
      final updatedAt = {'A': 100, 'B': 300, 'C': 200};

      final list = [a, b, c];
      HomeViewModel.sortByRecentlyUpdated(list, (s) => updatedAt[s.name]);

      expect(list.map((s) => s.name).toList(), ['B', 'C', 'A']);
    });

    test('null updatedAt sorts last', () {
      final a = _series('A', anilistIds: [1]);
      final b = _series('B', anilistIds: [2]);
      final updatedAt = {'B': 300};

      final list = [a, b];
      HomeViewModel.sortByRecentlyUpdated(list, (s) => updatedAt[s.name]);

      expect(list.map((s) => s.name).toList(), ['B', 'A']);
    });
  });

  group('splitByStarted', () {
    test('partially-watched next episode goes to started, untouched to notStarted', () {
      final started = _series('Started', anilistIds: [1]);
      final fresh = _series('Fresh', anilistIds: [2]);
      final noNext = _series('Done', anilistIds: [3]);

      final nextByName = {
        'Started': _episode('e1', progress: 0.4),
        'Fresh': _episode('e2', progress: 0.0),
        // 'Done' has no next episode
      };

      final (startedList, notStartedList) = HomeViewModel.splitByStarted(
        [started, fresh, noNext],
        (s) => nextByName[s.name],
        0.95,
      );

      expect(startedList, [started]);
      expect(notStartedList, [fresh]);
    });

    test('progress past the threshold or already watched counts as notStarted', () {
      final overThreshold = _series('Over', anilistIds: [1]);
      final watched = _series('Watched', anilistIds: [2]);

      final nextByName = {
        'Over': _episode('e1', progress: 0.97),
        'Watched': _episode('e2', progress: 0.5, watched: true),
      };

      final (startedList, notStartedList) = HomeViewModel.splitByStarted(
        [overThreshold, watched],
        (s) => nextByName[s.name],
        0.95,
      );

      expect(startedList, isEmpty);
      expect(notStartedList, [overThreshold, watched]);
    });
  });

  group('earliestAiring', () {
    test('picks the earliest airing episode among the series mappings', () {
      final s = _series('A', anilistIds: [1, 2, 3]);
      final map = <int, AiringEpisode?>{
        1: AiringEpisode(airingAt: 300, episode: 5),
        2: AiringEpisode(airingAt: 100, episode: 2),
        3: null,
      };

      final result = HomeViewModel.earliestAiring(s, map);
      expect(result, isNotNull);
      expect(result!.$1.airingAt, 100);
      expect(result.$2, 2);
    });

    test('null when no mapping has a scheduled episode', () {
      final s = _series('A', anilistIds: [1]);
      expect(HomeViewModel.earliestAiring(s, {1: AiringEpisode(airingAt: null)}), isNull);
      expect(HomeViewModel.earliestAiring(s, {}), isNull);
    });
  });

  group('sortByNearestAiring', () {
    test('earliest airing first', () {
      final a = _series('A', anilistIds: [1]);
      final b = _series('B', anilistIds: [2]);
      final c = _series('C', anilistIds: [3]);
      final map = <int, AiringEpisode?>{
        1: AiringEpisode(airingAt: 500),
        2: AiringEpisode(airingAt: 100),
        3: AiringEpisode(airingAt: 300),
      };

      final list = [a, b, c];
      HomeViewModel.sortByNearestAiring(list, map);

      expect(list.map((s) => s.name).toList(), ['B', 'C', 'A']);
    });
  });
}
