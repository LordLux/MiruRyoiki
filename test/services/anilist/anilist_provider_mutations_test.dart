import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/models/anilist/user_list.dart';
import 'package:miruryoiki/services/anilist/provider/anilist_provider.dart';
import 'package:miruryoiki/services/anilist/queries/anilist_service.dart';
import 'package:miruryoiki/settings.dart';

class FakeGraphQLClient extends GraphQLClient {
  FakeGraphQLClient()
      : super(
          link: Link.function((request, [forward]) => const Stream.empty()),
          cache: GraphQLCache(),
        );

  Future<QueryResult<T>> Function<T>(MutationOptions<T>)? mutationHandler;

  @override
  Future<QueryResult<T>> mutate<T>(MutationOptions<T> options) async {
    if (mutationHandler != null) return mutationHandler!(options);
    return QueryResult(options: options, source: QueryResultSource.network, data: {});
  }
}

Map<String, dynamic> _saveMediaListEntryResponse({
  required int entryId,
  required int mediaId,
  required String status,
  required String title,
}) {
  return {
    '__typename': 'Mutation',
    'SaveMediaListEntry': {
      '__typename': 'MediaList',
      'id': entryId,
      'mediaId': mediaId,
      'status': status,
      'score': null,
      'progress': null,
      'repeat': null,
      'priority': null,
      'private': false,
      'notes': null,
      'hiddenFromStatusLists': false,
      'customLists': null,
      'startedAt': null,
      'completedAt': null,
      'updatedAt': null,
      'createdAt': null,
      'media': {
        '__typename': 'Media',
        'id': mediaId,
        'title': {
          '__typename': 'MediaTitle',
          'userPreferred': title,
          'romaji': title,
          'english': null,
          'native': null,
        },
        'coverImage': {
          '__typename': 'MediaCoverImage',
          'extraLarge': null,
          'large': null,
          'color': null,
        },
        'type': 'ANIME',
        'format': null,
        'status': null,
        'episodes': null,
        'seasonYear': null,
        'season': null,
        'averageScore': null,
        'meanScore': null,
        'popularity': null,
        'isAdult': false,
        'isFavourite': false,
        'nextAiringEpisode': null,
        'startDate': null,
        'genres': <String>[],
        'siteUrl': null,
        'mediaListEntry': {
          '__typename': 'MediaList',
          'id': entryId,
        },
      },
    },
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    dotenv.testLoad(fileInput: '''
ANILIST_CLIENT_ID=dummy_id
ANILIST_CLIENT_SECRET=dummy_secret
''');
    Manager.mockSettings = SettingsManager();
  });

  group('AnilistProvider saveEntry merge behavior', () {
    test('creates missing target list when moving an existing entry to a new status', () async {
      final movingMediaId = 42;
      final initialEntry = AnilistMediaListEntry.fromJson({
        'id': 1,
        'mediaId': movingMediaId,
        'status': 'CURRENT',
        'media': {
          'id': movingMediaId,
          'title': {'userPreferred': 'Initial Anime'},
          'isFavourite': false,
        },
      });

      final client = FakeGraphQLClient();
      client.mutationHandler = <T>(options) async {
        return QueryResult(
          options: options,
          source: QueryResultSource.network,
          data: _saveMediaListEntryResponse(
            entryId: 1,
            mediaId: movingMediaId,
            status: 'COMPLETED',
            title: 'Initial Anime',
          ),
        );
      };

      final service = AnilistService()..client = client;
      final provider = AnilistProvider(anilistService: service);
      addTearDown(provider.dispose);

      provider.userLists[AnilistListApiStatus.CURRENT.name_] = AnilistUserList(
        entries: [initialEntry],
        name: AnilistListApiStatus.CURRENT.name_,
        status: AnilistListApiStatus.CURRENT,
      );

      final saved = await provider.saveEntry(
        mediaId: movingMediaId,
        status: AnilistListApiStatus.COMPLETED,
      );

      expect(saved, isTrue);
      expect(provider.userLists.containsKey(AnilistListApiStatus.COMPLETED.name_), isTrue);
      expect(
        provider.userLists[AnilistListApiStatus.COMPLETED.name_]!.entries.where((entry) => entry.mediaId == movingMediaId),
        isNotEmpty,
      );
      expect(
        provider.userLists[AnilistListApiStatus.CURRENT.name_]!.entries.where((entry) => entry.mediaId == movingMediaId),
        isEmpty,
      );
    });

    test('creates missing target list when merging a brand-new entry', () async {
      final newMediaId = 99;
      final client = FakeGraphQLClient();
      client.mutationHandler = <T>(options) async {
        return QueryResult(
          options: options,
          source: QueryResultSource.network,
          data: _saveMediaListEntryResponse(
            entryId: 2,
            mediaId: newMediaId,
            status: 'DROPPED',
            title: 'New Anime',
          ),
        );
      };

      final service = AnilistService()..client = client;
      final provider = AnilistProvider(anilistService: service);
      addTearDown(provider.dispose);

      expect(provider.userLists.containsKey(AnilistListApiStatus.DROPPED.name_), isFalse);

      final saved = await provider.saveEntry(
        mediaId: newMediaId,
        status: AnilistListApiStatus.DROPPED,
      );

      expect(saved, isTrue);
      expect(provider.userLists.containsKey(AnilistListApiStatus.DROPPED.name_), isTrue);
      expect(
        provider.userLists[AnilistListApiStatus.DROPPED.name_]!.entries.where((entry) => entry.mediaId == newMediaId),
        isNotEmpty,
      );
    });
  });
}
