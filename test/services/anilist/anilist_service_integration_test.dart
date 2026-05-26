/// Integration tests for the read-only parts of [AnilistService]: browse,
/// search, and anime-details queries against the live AniList API.
///
/// These tests are order-independent (all read-only) and require no account
/// mutations.
///
/// Run with:  powershell -File test/launch_scripts/real_anilist.ps1
@Timeout(Duration(minutes: 10))
@Tags(['real-api'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/models/anilist/anime_card.dart';
import 'package:miruryoiki/services/anilist/queries/anilist_service.dart';

import 'support/anilist_test_harness.dart';

void main() {
  late RealAnilistContext ctx;

  setUpAll(() async {
    final result = await RealAnilist.setUp();
    if (result == null) {
      markTestSkipped('No ACCESS_TOKEN in test/.env');
      return;
    }
    ctx = result;
  });

  group('AnilistService Integration Tests (Real API)', () {
    test('getTrendingNow returns a list of anime', () async {
      final result = await ctx.service.getTrendingNow(page: 1, perPage: 5);

      expect(result, isNotNull);
      expect(result!.results, isNotEmpty);
      expect(result.results.length, 5);
      expect(result.results.first, isA<AnimeCard>());
      expect(result.results.first.title.userPreferred, isNotEmpty);
    });

    test('getPopularThisSeason returns anime', () async {
      final result = await ctx.service.getPopularThisSeason(page: 1, perPage: 5);

      expect(result, isNotNull);
      expect(result!.results, isNotEmpty);
      expect(result.results.first, isA<AnimeCard>());
    });

    test('getUpcomingNextSeason returns anime', () async {
      final result = await ctx.service.getUpcomingNextSeason(page: 1, perPage: 5);

      expect(result, isNotNull);
      expect(result!.results, isNotEmpty);
    });

    test('getAllTimePopular returns anime', () async {
      final result = await ctx.service.getAllTimePopular(page: 1, perPage: 5);

      expect(result, isNotNull);
      expect(result!.results, isNotEmpty);
    });

    test('getTop100Anime returns anime', () async {
      final result = await ctx.service.getTop100Anime(page: 1, perPage: 5);

      expect(result, isNotNull);
      expect(result!.results, isNotEmpty);
    });

    test('searchAnime returns results for "Naruto"', () async {
      final result = await ctx.service.searchAnime(page: 1, perPage: 5, search: 'Naruto');

      expect(result, isNotNull);
      expect(result!.results, isNotEmpty);
      final hasNaruto = result.results.any((anime) {
        final title = anime.title;
        return (title.userPreferred?.contains('Naruto') ?? false) ||
            (title.english?.contains('Naruto') ?? false) ||
            (title.romaji?.contains('Naruto') ?? false);
      });
      expect(hasNaruto, isTrue);
    });

    test('getAnimeDetails returns correct anime (Cowboy Bebop)', () async {
      final result = await ctx.service.getAnimeDetails(1);

      expect(result, isNotNull);
      expect(result!.id, 1);
      expect(result.title.english, 'Cowboy Bebop');
    });

    test('getDetailedAnimeDetails returns correct anime (Cowboy Bebop)', () async {
      final result = await ctx.service.getDetailedAnimeDetails(1);

      expect(result, isNotNull);
      expect(result!.id, 1);
      expect(result.title.english, 'Cowboy Bebop');
    });

    test('getGenres returns a list of genres', () async {
      final result = await ctx.service.getGenres(forceRefresh: true);

      expect(result, isNotEmpty);
      expect(result, contains('Action'));
      expect(result, contains('Adventure'));
    });

    test('searchAnimeMatch returns matches', () async {
      final result = await ctx.service.searchAnimeMatch('One Piece', limit: 5);

      expect(result, isNotEmpty);
      final first = result.first;
      final title = first.title;
      final hasOnePiece = (title.userPreferred?.toLowerCase().contains('one piece') ?? false) ||
          (title.english?.toLowerCase().contains('one piece') ?? false) ||
          (title.romaji?.toLowerCase().contains('one piece') ?? false);
      expect(hasOnePiece, isTrue);
    });

    test('getEpisodeTitles returns titles for One Piece (id: ${TestMedia.onePiece})', () async {
      final result = await ctx.service.getEpisodeTitles(TestMedia.onePiece);

      expect(result, isA<Map<int, String>>());
      if (result.isNotEmpty) {
        expect(result.keys, isNotEmpty);
      }
    });

    test('getUpcomingEpisodes returns data for airing anime', () async {
      final trending = await ctx.service.getTrendingNow(page: 1, perPage: 5);
      final airingAnime = trending?.results.firstWhere(
        (a) => a.status == 'RELEASING',
        orElse: () => trending.results.first,
      );

      if (airingAnime != null) {
        final result = await ctx.service.getUpcomingEpisodes([airingAnime.id]);
        expect(result, isA<Map<int, dynamic>>());
      }
    });
  });
}
