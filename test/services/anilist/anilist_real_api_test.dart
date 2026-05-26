/// Smoke tests that exercise the real AniList public API through the
/// [AnilistQueryExecutor] mixin directly (no service wrapper).
///
/// These are read-only, require no authentication, and exist to verify that
/// the executor correctly handles network-only fetches against the live API.
///
/// Run with:  powershell -File test/launch_scripts/real_anilist.ps1
@Timeout(Duration(minutes: 10))
@Tags(['real-api'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:miruryoiki/services/anilist/queries/anilist_query_executor.dart';
import 'package:miruryoiki/models/anilist/anime.dart';

import 'support/anilist_test_harness.dart';

/// Thin concrete class that wires an external client into the executor mixin.
class _RealApiExecutor with AnilistQueryExecutor {
  final GraphQLClient _client;
  _RealApiExecutor(this._client);

  @override
  GraphQLClient? get client => _client;
}

void main() {
  late _RealApiExecutor executor;

  setUpAll(() async {
    final ctx = await RealAnilist.setUp();
    if (ctx == null) {
      markTestSkipped('No ACCESS_TOKEN in test/.env');
      return;
    }
    executor = _RealApiExecutor(ctx.client);
  });

  group('Real AniList API Integration', () {
    test('Fetch Public Anime Data (Cowboy Bebop)', () async {
      const query = r'''
        query {
          Media(id: 1, type: ANIME) {
            id
            title {
              romaji
              english
            }
            episodes
            status
          }
        }
      ''';

      final result = await executor.executeQuery<AnilistAnime>(
        options: QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
        operationName: 'RealApiTest_CowboyBebop',
        parser: (data) => AnilistAnime.fromJson(data['Media']),
      );

      expect(result, isNotNull);
      expect(result!.id, 1);
      expect(result.title.english, 'Cowboy Bebop');
      expect(result.episodes, 26);
      expect(result.status, 'FINISHED');
    });

    test('Search for "Naruto"', () async {
      const query = r'''
        query($search: String) {
          Page(perPage: 5) {
            media(search: $search, type: ANIME) {
              id
              title {
                english
              }
            }
          }
        }
      ''';

      final result = await executor.executeQuery<List<AnilistAnime>>(
        options: QueryOptions(
          document: gql(query),
          variables: {'search': 'Naruto'},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
        operationName: 'RealApiTest_SearchNaruto',
        parser: (data) {
          final List<dynamic> media = data['Page']['media'];
          return media.map((json) => AnilistAnime.fromJson(json)).toList();
        },
      );

      expect(result, isNotNull);
      expect(result!.isNotEmpty, true);
      final hasNaruto = result.any(
        (anime) => (anime.title.english)?.contains('Naruto') ?? false,
      );
      expect(hasNaruto, true);
    });
  });
}
