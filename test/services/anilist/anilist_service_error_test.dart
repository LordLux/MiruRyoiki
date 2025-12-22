import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:miruryoiki/services/anilist/queries/anilist_service.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/settings.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Fake Client that returns errors
class ErrorGraphQLClient extends GraphQLClient {
  ErrorGraphQLClient() 
      : super(
          link: Link.function((request, [forward]) => const Stream.empty()), 
          cache: GraphQLCache()
        );

  @override
  Future<QueryResult<T>> query<T>(QueryOptions<T> options) async {
    return QueryResult(
      options: options,
      source: QueryResultSource.network,
      exception: OperationException(
        graphqlErrors: [
          const GraphQLError(message: 'Not Found'),
        ],
      ),
    );
  }
}

void main() {
  late AnilistService service;

  setUpAll(() async {
    dotenv.testLoad(fileInput: '''
ANILIST_CLIENT_ID=dummy_id
ANILIST_CLIENT_SECRET=dummy_secret
''');
  });

  setUp(() {
    service = AnilistService();
    service.client = ErrorGraphQLClient();
    Manager.mockSettings = SettingsManager();
  });

  test('getAnimeDetails handles API errors gracefully', () async {
    final result = await service.getAnimeDetails(99999);
    expect(result, isNull);
  });

  test('searchAnimeMatch handles API errors gracefully', () async {
    final result = await service.searchAnimeMatch('Invalid');
    expect(result, isEmpty);
  });
}
