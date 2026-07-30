import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/viewmodels/search_viewmodel.dart';
import 'package:miruryoiki/services/anilist/queries/anilist_service.dart';

import 'package:miruryoiki/models/anilist/page_info.dart';
import 'package:miruryoiki/models/anilist/anime_card.dart';

class FakeAnilistService implements AnilistService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  
  Future<AnilistSearchPage<AnimeCard>> getTrendingNow({required int perPage, int page = 1}) async => AnilistSearchPage(pageInfo: AnilistPageInfo(total: 0, perPage: 0, currentPage: 0, lastPage: 0, hasNextPage: false), results: []);
  
  Future<AnilistSearchPage<AnimeCard>> getPopularThisSeason({required int perPage, int page = 1}) async => AnilistSearchPage(pageInfo: AnilistPageInfo(total: 0, perPage: 0, currentPage: 0, lastPage: 0, hasNextPage: false), results: []);
  
  Future<AnilistSearchPage<AnimeCard>> getUpcomingNextSeason({required int perPage, int page = 1}) async => AnilistSearchPage(pageInfo: AnilistPageInfo(total: 0, perPage: 0, currentPage: 0, lastPage: 0, hasNextPage: false), results: []);
  
  Future<AnilistSearchPage<AnimeCard>> getTop100Anime({required int perPage, int page = 1}) async => AnilistSearchPage(pageInfo: AnilistPageInfo(total: 0, perPage: 0, currentPage: 0, lastPage: 0, hasNextPage: false), results: []);
  
  Future<AnilistSearchPage<AnimeCard>?> searchAnime({int page = 1, int perPage = 50, String? search, List<String>? sort, List<String>? genres, List<String>? tags, List<String>? format, String? status}) async => AnilistSearchPage(pageInfo: AnilistPageInfo(total: 0, perPage: 0, currentPage: 0, lastPage: 0, hasNextPage: false), results: []);
}

void main() {
  group('SearchViewModel', () {
    late SearchViewModel vm;

    setUp(() {
      vm = SearchViewModel(anilistService: FakeAnilistService());
    });

    test('initializes with default sections', () {
      expect(vm.sectionManagers.length, 4);
      expect(vm.sectionManagers[1]?.type, 'trending');
      expect(vm.sectionManagers[2]?.type, 'popular');
      expect(vm.sectionManagers[3]?.type, 'upcoming');
      expect(vm.sectionManagers[4]?.type, 'top100');
    });

    test('clearTextSearch resets text search state', () {
      // Simulate state
      vm.performTextSearch('Attack on Titan', filters: {'genres': ['Action']});
      
      expect(vm.resultsQuery, 'Attack on Titan');
      expect(vm.resultsFilters, isNotNull);
      expect(vm.resultsIsLoading, isTrue); // because fetch is triggered
      
      // Clear
      vm.clearTextSearch();

      expect(vm.resultsQuery, isNull);
      expect(vm.resultsFilters, isNull);
      expect(vm.resultsList, isEmpty);
      expect(vm.resultsCurrentPage, 1);
      expect(vm.resultsHasNextPage, isTrue);
      expect(vm.resultsIsLoading, isFalse);
      expect(vm.resultsErrorMessage, isNull);
    });
  });
}
