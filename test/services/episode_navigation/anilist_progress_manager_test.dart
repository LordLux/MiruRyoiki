import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/services/episode_navigation/anilist_progress_manager.dart';
import 'package:miruryoiki/models/series.dart';
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

void main() {
  late AnilistProgressManager manager;
  late Series testSeries;
  late AnilistMapping mapping1;
  late AnilistMapping mapping2;
  late MockAnilistProvider mockProvider;

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

  group('AnilistProgressManager', () {
    test('getTotalEpisodesFromAnilist sums episodes from all mappings', () {
      // 12 + 24 = 36
      final total = manager.getTotalEpisodesFromAnilist(testSeries);
      expect(total, 36);
    });

    test('getWatchedEpisodesFromAnilist returns max progress', () {
      // Max of 5 and 10 is 10
      final watched = manager.getWatchedEpisodesFromAnilist(testSeries, mockProvider);
      expect(watched, 10);
    });

    test('getSeriesProgress calculates correct percentage', () {
      // 10 / 36 = 0.2777...
      final progress = manager.getSeriesProgress(testSeries, mockProvider);
      expect(progress, closeTo(0.277, 0.001));
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
}
