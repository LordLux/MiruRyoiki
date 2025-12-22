import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:miruryoiki/services/anilist/queries/anilist_service.dart';
import 'package:miruryoiki/models/anilist/anime.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/settings.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Fake GraphQLClient to capture requests
class CapturingGraphQLClient extends GraphQLClient {
  final List<QueryOptions> capturedQueries = [];

  CapturingGraphQLClient() 
      : super(
          link: Link.function((request, [forward]) => const Stream.empty()), 
          cache: GraphQLCache()
        );

  @override
  Future<QueryResult<T>> query<T>(QueryOptions<T> options) async {
    capturedQueries.add(options);
    // Return empty successful result to avoid crashes
    return QueryResult(
      options: options, 
      source: QueryResultSource.network, 
      data: {'Page': {'media': []}}
    );
  }
}

void main() {
  late CapturingGraphQLClient mockClient;
  late AnilistService service;

  setUpAll(() async {
    dotenv.testLoad(fileInput: '''
      ANILIST_CLIENT_ID=dummy_id
      ANILIST_CLIENT_SECRET=dummy_secret
    ''');
  });

  setUp(() {
    mockClient = CapturingGraphQLClient();
    service = AnilistService();
    service.client = mockClient;
    Manager.mockSettings = SettingsManager();
  });

  test('getMultipleAnimesDetails chunks requests when > 50 IDs provided', () async {
    // Generate 60 IDs
    final ids = List.generate(60, (index) => index + 1);

    await service.getMultipleAnimesDetails(ids);

    // Should have made 2 requests (50 + 10)
    expect(mockClient.capturedQueries.length, 2);
    
    // Verify first chunk
    final firstQueryVariables = mockClient.capturedQueries[0].variables;
    expect((firstQueryVariables['ids'] as List).length, 50);

    // Verify second chunk
    final secondQueryVariables = mockClient.capturedQueries[1].variables;
    expect((secondQueryVariables['ids'] as List).length, 10);
  });
}
