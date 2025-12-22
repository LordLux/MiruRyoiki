import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:miruryoiki/services/anilist/queries/anilist_service.dart';
import 'package:miruryoiki/models/anilist/anime.dart';
import 'package:miruryoiki/services/connectivity/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/settings.dart';

// Mock strategy to force online
class MockConnectivityStrategy implements ConnectivityStrategy {
  @override
  bool get isOffline => false;
  
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => Stream.value([ConnectivityResult.wifi]);

  @override
  Future<bool> hasInternetAccess() async => true;
}

void main() {
  group('AnilistService Integration Tests (Real API)', () {
    late AnilistService service;

    setUpAll(() async {
      // Load dummy env vars for AnilistAuthService
      dotenv.testLoad(fileInput: '''
        ANILIST_CLIENT_ID=dummy_id
        ANILIST_CLIENT_SECRET=dummy_secret
      ''');

      // Setup Manager mock settings
      Manager.mockSettings = SettingsManager();

      // Force online
      ConnectivityService().setStrategy(MockConnectivityStrategy());
      
      service = AnilistService();
      
      // Setup real client
      final httpLink = HttpLink('https://graphql.anilist.co');
      final client = GraphQLClient(
        cache: GraphQLCache(),
        link: httpLink,
      );
      
      service.client = client;
    });

    test('getTrendingNow returns a list of anime', () async {
      final result = await service.getTrendingNow(page: 1, perPage: 5);
      
      expect(result, isNotNull);
      expect(result!.results, isNotEmpty);
      expect(result.results.length, 5);
      expect(result.results.first, isA<AnilistAnime>());
      expect(result.results.first.title.userPreferred, isNotEmpty);
      
      print('Trending: ${result.results.first.title.userPreferred}');
    });

    test('getPopularThisSeason returns anime', () async {
      final result = await service.getPopularThisSeason(page: 1, perPage: 5);
      
      expect(result, isNotNull);
      expect(result!.results, isNotEmpty);
      expect(result.results.first, isA<AnilistAnime>());
      
      print('Popular This Season: ${result.results.first.title.userPreferred}');
    });

    test('getUpcomingNextSeason returns anime', () async {
      final result = await service.getUpcomingNextSeason(page: 1, perPage: 5);
      
      expect(result, isNotNull);
      expect(result!.results, isNotEmpty);
      
      print('Upcoming Next Season: ${result.results.first.title.userPreferred}');
    });

    test('getAllTimePopular returns anime', () async {
      final result = await service.getAllTimePopular(page: 1, perPage: 5);
      
      expect(result, isNotNull);
      expect(result!.results, isNotEmpty);
      
      print('All Time Popular: ${result.results.first.title.userPreferred}');
    });

    test('getTop100Anime returns anime', () async {
      final result = await service.getTop100Anime(page: 1, perPage: 5);
      
      expect(result, isNotNull);
      expect(result!.results, isNotEmpty);
      
      print('Top 100: ${result.results.first.title.userPreferred}');
    });

    test('searchAnime returns results for "Naruto"', () async {
      final result = await service.searchAnime(page: 1, perPage: 5, search: 'Naruto');
      
      expect(result, isNotNull);
      expect(result!.results, isNotEmpty);
      final hasNaruto = result.results.any((anime) {
        final title = anime.title;
        return (title.userPreferred?.contains('Naruto') ?? false) ||
               (title.english?.contains('Naruto') ?? false) ||
               (title.romaji?.contains('Naruto') ?? false);
      });
      expect(hasNaruto, isTrue);
      
      print('Search "Naruto": ${result.results.first.title.userPreferred ?? result.results.first.title.english}');
    });

    test('getAnimeDetails returns correct anime (Cowboy Bebop)', () async {
      final result = await service.getAnimeDetails(1);
      
      expect(result, isNotNull);
      expect(result!.id, 1);
      expect(result.title.english, 'Cowboy Bebop');
    });

    test('getDetailedAnimeDetails returns correct anime (Cowboy Bebop)', () async {
      final result = await service.getDetailedAnimeDetails(1);
      
      expect(result, isNotNull);
      expect(result!.id, 1);
      expect(result.title.english, 'Cowboy Bebop');
      // Check for detailed fields if possible, e.g. characters or staff if they are in the model
    });

    test('getMultipleAnimesDetails returns multiple anime', () async {
      final ids = [1, 5]; // Cowboy Bebop, Cowboy Bebop: Knockin' on Heaven's Door
      final result = await service.getMultipleAnimesDetails(ids);
      
      expect(result, isNotEmpty);
      expect(result.length, 2);
      expect(result[1]?.title.english, 'Cowboy Bebop');
    });

    test('getGenres returns a list of genres', () async {
      final result = await service.getGenres(forceRefresh: true);
      
      expect(result, isNotEmpty);
      expect(result, contains('Action'));
      expect(result, contains('Adventure'));
    });

    test('searchAnimeMatch returns matches', () async {
      final result = await service.searchAnimeMatch('One Piece', limit: 5);
      
      expect(result, isNotEmpty);
      final first = result.first;
      final title = first.title;
      print('Search Match First Result: ${title.userPreferred} / ${title.english} / ${title.romaji}');
      
      final hasOnePiece = (title.userPreferred?.toLowerCase().contains('one piece') ?? false) ||
                          (title.english?.toLowerCase().contains('one piece') ?? false) ||
                          (title.romaji?.toLowerCase().contains('one piece') ?? false);
      expect(hasOnePiece, isTrue);
    });
    
    test('getEpisodeTitles returns titles for One Piece (id: 21)', () async {
      // One Piece usually has streaming episodes
      final result = await service.getEpisodeTitles(21);
      
      expect(result, isA<Map<int, String>>());
      if (result.isNotEmpty) {
        print('Episode Titles Keys: ${result.keys.take(5).toList()}');
        expect(result.keys, isNotEmpty);
      } else {
        print('No episode titles found for One Piece (might be region locked or missing data)');
      }
    });

    test('getUpcomingEpisodes returns data for airing anime', () async {
      // We need an ID of a currently airing anime. 
      // We can fetch "Trending" first to find one.
      final trending = await service.getTrendingNow(page: 1, perPage: 5);
      final airingAnime = trending?.results.firstWhere((a) => a.status == 'RELEASING', orElse: () => trending!.results.first);
      
      if (airingAnime != null) {
        final result = await service.getUpcomingEpisodes([airingAnime.id]);
        expect(result, isA<Map<int, dynamic>>());
        // It might be null if no next episode is scheduled
      }
    });
  });
}
