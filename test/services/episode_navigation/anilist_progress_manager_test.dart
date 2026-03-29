import 'package:flutter_anitomy/flutter_anitomy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/services/episode_navigation/anilist_progress_manager.dart';
import 'package:miruryoiki/models/series.dart';
import 'package:miruryoiki/models/season.dart';
import 'package:miruryoiki/models/episode.dart';
import 'package:miruryoiki/models/anilist/mapping.dart';
import 'package:miruryoiki/models/anilist/anime.dart';
import 'package:miruryoiki/models/anilist/user_list.dart';
import 'package:miruryoiki/services/anilist/provider/anilist_provider.dart';
import 'package:miruryoiki/utils/path.dart';
import 'package:mockito/mockito.dart';

// Mock AnilistProvider
class MockAnilistProvider extends Mock implements AnilistProvider {
  final Map<String, AnilistUserList> _lists;

  MockAnilistProvider(this._lists);

  @override
  Map<String, AnilistUserList> get userLists => _lists;
}

Episode _makeEpisode({required int episodeNumber, required String path, double progress = 0, bool watched = false}) {
  return Episode(
    name: 'Episode $episodeNumber',
    path: PathString(path),
    episodeNumber: episodeNumber,
    progress: progress,
    watched: watched,
    parsedAnime: ParsedAnime(),
  );
}

void main() {
  late AnilistProgressManager manager;
  late AnilistMapping mapping1;
  late AnilistMapping mapping2;

  setUp(() {
    manager = AnilistProgressManager.instance;

    // Create dummy mappings with cached data
    mapping1 = AnilistMapping(
      localPath: PathString('path/1'),
      anilistId: 100,
      anilistData: AnilistAnime(
        id: 100,
        title: AnilistTitle(romaji: 'Anime 1'),
        episodes: 12,
      ),
    );

    mapping2 = AnilistMapping(
      localPath: PathString('path/2'),
      anilistId: 200,
      anilistData: AnilistAnime(
        id: 200,
        title: AnilistTitle(romaji: 'Anime 2'),
        episodes: 24,
      ),
    );
  });

  group('AnilistProgressManager', () {
    late Series testSeries;
    late MockAnilistProvider mockProvider;

    setUp(() {
      testSeries = Series(
        id: 1,
        name: 'Test Series',
        path: PathString('path/to/series'),
        seasons: [],
        anilistMappings: [mapping1, mapping2],
      );

      // Setup mock provider with user lists
      final listEntry1 = AnilistMediaListEntry(
        id: 1,
        mediaId: 100,
        status: AnilistListApiStatus.CURRENT,
        progress: 5,
        score: 80,
        media: mapping1.anilistData!,
      );

      final listEntry2 = AnilistMediaListEntry(
        id: 2,
        mediaId: 200,
        status: AnilistListApiStatus.CURRENT,
        progress: 10,
        score: 90,
        media: mapping2.anilistData!,
      );

      final userList = AnilistUserList(
        name: 'Watching',
        entries: [listEntry1, listEntry2],
      );

      mockProvider = MockAnilistProvider({'Watching': userList});
    });

    test('getTotalEpisodesFromAnilist sums episodes from all mappings', () {
      // 12 + 24 = 36
      final total = manager.getTotalEpisodesFromAnilist(testSeries);
      expect(total, 36);
    });

    test('getWatchedEpisodesFromAnilist sums progress from all mappings', () {
      // 5 + 10 = 15
      final watched = manager.getWatchedEpisodesFromAnilist(testSeries, mockProvider);
      expect(watched, 15);
    });

    test('getSeriesProgress calculates correct percentage', () {
      // 15 / 36 = 0.4166...
      final progress = manager.getSeriesProgress(testSeries, mockProvider);
      expect(progress, closeTo(0.416, 0.001));
    });

    test('getTotalEpisodesFromAnilist returns 0 for unlinked series', () {
      final unlinkedSeries = Series(
        id: 2,
        name: 'Unlinked',
        path: PathString('path'),
        seasons: [],
        anilistMappings: [],
      );
      expect(manager.getTotalEpisodesFromAnilist(unlinkedSeries), 0);
    });
  });

  group('Cross-season navigation', () {
    test('getNextEpisodeToWatch transitions from completed season to next', () {
      // Season 1: 12 episodes, all watched (progress=12)
      // Season 2: 12 episodes, none watched (progress=0)
      final season1Episodes = List.generate(
          12,
          (i) => _makeEpisode(
                episodeNumber: i + 1,
                path: 'path/1/ep${i + 1}.mkv',
                watched: true,
              ));
      final season2Episodes = List.generate(
          12,
          (i) => _makeEpisode(
                episodeNumber: i + 1,
                path: 'path/2/ep${i + 1}.mkv',
              ));

      final season1 = Season(name: 'Season 1', path: PathString('path/1'), episodes: season1Episodes);
      final season2 = Season(name: 'Season 2', path: PathString('path/2'), episodes: season2Episodes);

      final s1Mapping = AnilistMapping(
        localPath: PathString('path/1'),
        anilistId: 100,
        anilistData: AnilistAnime(id: 100, title: AnilistTitle(romaji: 'S1'), episodes: 12),
      );
      final s2Mapping = AnilistMapping(
        localPath: PathString('path/2'),
        anilistId: 200,
        anilistData: AnilistAnime(id: 200, title: AnilistTitle(romaji: 'S2'), episodes: 12),
      );

      final series = Series(
        id: 1,
        name: 'Multi-Season',
        path: PathString('path/to/series'),
        seasons: [season1, season2],
        anilistMappings: [s1Mapping, s2Mapping],
      );

      final entry1 = AnilistMediaListEntry(
        id: 1,
        mediaId: 100,
        status: AnilistListApiStatus.COMPLETED,
        progress: 12,
        media: s1Mapping.anilistData!,
      );
      final entry2 = AnilistMediaListEntry(
        id: 2,
        mediaId: 200,
        status: AnilistListApiStatus.CURRENT,
        progress: 0,
        media: s2Mapping.anilistData!,
      );

      final provider = MockAnilistProvider({
        'Completed': AnilistUserList(name: 'Completed', entries: [entry1]),
        'Watching': AnilistUserList(name: 'Watching', entries: [entry2]),
      });

      final nextEp = manager.getNextEpisodeToWatch(series, provider);
      expect(nextEp, isNotNull);
      expect(nextEp!.episodeNumber, 1);
      expect(nextEp.path.path, contains('ep1.mkv')); // Season 2 Episode 1
    });

    test('getNextEpisodeToWatch handles absolute numbering fallback', () {
      // Season 2 uses absolute numbering: episodes 13-24
      final season1Episodes = List.generate(
          12,
          (i) => _makeEpisode(
                episodeNumber: i + 1,
                path: 'path/1/ep${i + 1}.mkv',
                watched: true,
              ));
      final season2Episodes = List.generate(
          12,
          (i) => _makeEpisode(
                episodeNumber: 13 + i, // absolute numbering
                path: 'path/2/ep${13 + i}.mkv',
              ));

      final season1 = Season(name: 'Season 1', path: PathString('path/1'), episodes: season1Episodes);
      final season2 = Season(name: 'Season 2', path: PathString('path/2'), episodes: season2Episodes);

      final s1Mapping = AnilistMapping(
        localPath: PathString('path/1'),
        anilistId: 100,
        anilistData: AnilistAnime(id: 100, title: AnilistTitle(romaji: 'S1'), episodes: 12),
      );
      final s2Mapping = AnilistMapping(
        localPath: PathString('path/2'),
        anilistId: 200,
        anilistData: AnilistAnime(id: 200, title: AnilistTitle(romaji: 'S2'), episodes: 12),
      );

      final series = Series(
        id: 1,
        name: 'Absolute Numbering',
        path: PathString('path/to/series'),
        seasons: [season1, season2],
        anilistMappings: [s1Mapping, s2Mapping],
      );

      final entry1 = AnilistMediaListEntry(
        id: 1,
        mediaId: 100,
        status: AnilistListApiStatus.COMPLETED,
        progress: 12,
        media: s1Mapping.anilistData!,
      );
      final entry2 = AnilistMediaListEntry(
        id: 2,
        mediaId: 200,
        status: AnilistListApiStatus.CURRENT,
        progress: 0,
        media: s2Mapping.anilistData!,
      );

      final provider = MockAnilistProvider({
        'Completed': AnilistUserList(name: 'Completed', entries: [entry1]),
        'Watching': AnilistUserList(name: 'Watching', entries: [entry2]),
      });

      final nextEp = manager.getNextEpisodeToWatch(series, provider);
      expect(nextEp, isNotNull);
      expect(nextEp!.episodeNumber, 13); // absolute: 12 + 1
      expect(nextEp.path.path, contains('ep13.mkv'));
    });

    test('getNextEpisodeToWatch returns episode within same season', () {
      // Season 1: 12 episodes, progress=7
      final season1Episodes = List.generate(
          12,
          (i) => _makeEpisode(
                episodeNumber: i + 1,
                path: 'path/1/ep${i + 1}.mkv',
                watched: i < 7,
              ));

      final season1 = Season(name: 'Season 1', path: PathString('path/1'), episodes: season1Episodes);

      final s1Mapping = AnilistMapping(
        localPath: PathString('path/1'),
        anilistId: 100,
        anilistData: AnilistAnime(id: 100, title: AnilistTitle(romaji: 'S1'), episodes: 12),
      );

      final series = Series(
        id: 1,
        name: 'Single Season',
        path: PathString('path/to/series'),
        seasons: [season1],
        anilistMappings: [s1Mapping],
      );

      final entry1 = AnilistMediaListEntry(
        id: 1,
        mediaId: 100,
        status: AnilistListApiStatus.CURRENT,
        progress: 7,
        media: s1Mapping.anilistData!,
      );

      final provider = MockAnilistProvider({
        'Watching': AnilistUserList(name: 'Watching', entries: [entry1]),
      });

      final nextEp = manager.getNextEpisodeToWatch(series, provider);
      expect(nextEp, isNotNull);
      expect(nextEp!.episodeNumber, 8);
    });

    test('getNextEpisodeToWatch returns null when all seasons complete', () {
      final season1Episodes = List.generate(
          12,
          (i) => _makeEpisode(
                episodeNumber: i + 1,
                path: 'path/1/ep${i + 1}.mkv',
                watched: true,
              ));

      final season1 = Season(name: 'Season 1', path: PathString('path/1'), episodes: season1Episodes);

      final s1Mapping = AnilistMapping(
        localPath: PathString('path/1'),
        anilistId: 100,
        anilistData: AnilistAnime(id: 100, title: AnilistTitle(romaji: 'S1'), episodes: 12),
      );

      final series = Series(
        id: 1,
        name: 'Completed',
        path: PathString('path/to/series'),
        seasons: [season1],
        anilistMappings: [s1Mapping],
      );

      final entry1 = AnilistMediaListEntry(
        id: 1,
        mediaId: 100,
        status: AnilistListApiStatus.COMPLETED,
        progress: 12,
        media: s1Mapping.anilistData!,
      );

      final provider = MockAnilistProvider({
        'Completed': AnilistUserList(name: 'Completed', entries: [entry1]),
      });

      final nextEp = manager.getNextEpisodeToWatch(series, provider);
      expect(nextEp, isNull);
    });

    test('getNextEpisodeToWatch returns episode with incomplete local progress', () {
      // Season 1: progress=5 on anilist, but episode 5 is only half-watched locally
      final season1Episodes = List.generate(
          12,
          (i) => _makeEpisode(
                episodeNumber: i + 1,
                path: 'path/1/ep${i + 1}.mkv',
                watched: i < 4,
                progress: i == 4 ? 0.5 : (i < 4 ? 1.0 : 0.0), // ep5 is half-watched
              ));

      final season1 = Season(name: 'Season 1', path: PathString('path/1'), episodes: season1Episodes);

      final s1Mapping = AnilistMapping(
        localPath: PathString('path/1'),
        anilistId: 100,
        anilistData: AnilistAnime(id: 100, title: AnilistTitle(romaji: 'S1'), episodes: 12),
      );

      final series = Series(
        id: 1,
        name: 'In Progress',
        path: PathString('path/to/series'),
        seasons: [season1],
        anilistMappings: [s1Mapping],
      );

      final entry1 = AnilistMediaListEntry(
        id: 1,
        mediaId: 100,
        status: AnilistListApiStatus.CURRENT,
        progress: 5,
        media: s1Mapping.anilistData!,
      );

      final provider = MockAnilistProvider({
        'Watching': AnilistUserList(name: 'Watching', entries: [entry1]),
      });

      final nextEp = manager.getNextEpisodeToWatch(series, provider);
      expect(nextEp, isNotNull);
      expect(nextEp!.episodeNumber, 5); // resume episode 5
      expect(nextEp.progress, 0.5);
    });

    test('getNextEpisodeToWatch returns null when next episode not available locally', () {
      // Season 1 complete, but Season 2 has no local episodes
      final season1Episodes = List.generate(
          12,
          (i) => _makeEpisode(
                episodeNumber: i + 1,
                path: 'path/1/ep${i + 1}.mkv',
                watched: true,
              ));

      final season1 = Season(name: 'Season 1', path: PathString('path/1'), episodes: season1Episodes);
      final season2 = Season(name: 'Season 2', path: PathString('path/2'), episodes: []); // empty

      final s1Mapping = AnilistMapping(
        localPath: PathString('path/1'),
        anilistId: 100,
        anilistData: AnilistAnime(id: 100, title: AnilistTitle(romaji: 'S1'), episodes: 12),
      );
      final s2Mapping = AnilistMapping(
        localPath: PathString('path/2'),
        anilistId: 200,
        anilistData: AnilistAnime(id: 200, title: AnilistTitle(romaji: 'S2'), episodes: 12),
      );

      final series = Series(
        id: 1,
        name: 'Missing S2',
        path: PathString('path/to/series'),
        seasons: [season1, season2],
        anilistMappings: [s1Mapping, s2Mapping],
      );

      final entry1 = AnilistMediaListEntry(
        id: 1,
        mediaId: 100,
        status: AnilistListApiStatus.COMPLETED,
        progress: 12,
        media: s1Mapping.anilistData!,
      );
      final entry2 = AnilistMediaListEntry(
        id: 2,
        mediaId: 200,
        status: AnilistListApiStatus.CURRENT,
        progress: 0,
        media: s2Mapping.anilistData!,
      );

      final provider = MockAnilistProvider({
        'Completed': AnilistUserList(name: 'Completed', entries: [entry1]),
        'Watching': AnilistUserList(name: 'Watching', entries: [entry2]),
      });

      final nextEp = manager.getNextEpisodeToWatch(series, provider);
      expect(nextEp, isNull); // no local episodes in Season 2
    });

    test('getWatchedEpisodesFromAnilist sums progress correctly for multi-season', () {
      final s1Mapping = AnilistMapping(
        localPath: PathString('path/1'),
        anilistId: 100,
        anilistData: AnilistAnime(id: 100, title: AnilistTitle(romaji: 'S1'), episodes: 12),
      );
      final s2Mapping = AnilistMapping(
        localPath: PathString('path/2'),
        anilistId: 200,
        anilistData: AnilistAnime(id: 200, title: AnilistTitle(romaji: 'S2'), episodes: 12),
      );

      final series = Series(
        id: 1,
        name: 'Multi-Season',
        path: PathString('path/to/series'),
        seasons: [],
        anilistMappings: [s1Mapping, s2Mapping],
      );

      final entry1 = AnilistMediaListEntry(
        id: 1,
        mediaId: 100,
        status: AnilistListApiStatus.COMPLETED,
        progress: 12,
        media: s1Mapping.anilistData!,
      );
      final entry2 = AnilistMediaListEntry(
        id: 2,
        mediaId: 200,
        status: AnilistListApiStatus.CURRENT,
        progress: 3,
        media: s2Mapping.anilistData!,
      );

      final provider = MockAnilistProvider({
        'Completed': AnilistUserList(name: 'Completed', entries: [entry1]),
        'Watching': AnilistUserList(name: 'Watching', entries: [entry2]),
      });

      // Should be 12 + 3 = 15 (SUM, not MAX)
      expect(manager.getWatchedEpisodesFromAnilist(series, provider), 15);
      // Total is 12 + 12 = 24
      expect(manager.getTotalEpisodesFromAnilist(series), 24);
      // Progress: 15/24 = 0.625
      expect(manager.getSeriesProgress(series, provider), closeTo(0.625, 0.001));
    });
  });
}
