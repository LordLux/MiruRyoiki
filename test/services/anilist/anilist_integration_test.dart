/// Integration test that hits the real AniList API using the test account
/// credentials from test/.env.
///
/// These tests are NOT meant to run in CI — they require a valid access token.
/// Run manually with:
///   fvm flutter test test/services/anilist/anilist_integration_test.dart

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:miruryoiki/services/anilist/queries/anilist_service.dart';
import 'package:miruryoiki/models/anilist/user_list.dart';
import 'package:miruryoiki/models/anilist/anime.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:miruryoiki/services/connectivity/connectivity_service.dart';

class MockConnectivityStrategy implements ConnectivityStrategy {
  final StreamController<List<ConnectivityResult>> _controller = StreamController<List<ConnectivityResult>>.broadcast();
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _controller.stream;
  @override
  Future<bool> hasInternetAccess() async => true;
}

void main() {
  late GraphQLClient client;
  late AnilistService service;
  late String username;
  late int userId;

  setUpAll(() async {
    // Load test .env
    final envFile = File('test/.env');
    if (!envFile.existsSync()) {
      fail('test/.env not found — create it with ACCESS_TOKEN and USERNAME');
    }

    // Include dummy client ID/secret so AnilistAuthService doesn't crash
    final envContent = envFile.readAsStringSync();
    dotenv.testLoad(fileInput: '''
ANILIST_CLIENT_ID=dummy_id
ANILIST_CLIENT_SECRET=dummy_secret
$envContent
''');

    Manager.mockSettings = SettingsManager();
    ConnectivityService().setStrategy(MockConnectivityStrategy());

    final token = dotenv.env['ACCESS_TOKEN']!;
    username = dotenv.env['USERNAME']!;

    // Create a real GraphQL client
    final httpLink = HttpLink(
      'https://graphql.anilist.co',
      defaultHeaders: {'Authorization': 'Bearer $token'},
    );
    client = GraphQLClient(link: httpLink, cache: GraphQLCache());

    service = AnilistService();
    service.client = client;

    // Get user ID
    final viewerResult = await client.query(QueryOptions(
      document: gql('query { Viewer { id } }'),
    ));
    userId = viewerResult.data!['Viewer']['id'] as int;
    print('Test user: $username (ID: $userId)');
  });

  // Use Cowboy Bebop (mediaId: 1) for testing
  const testMediaId = 1;

  group('SaveMediaListEntry integration', () {
    test('save with notes — verify notes reach AniList', () async {
      final testNotes = 'Test note ${DateTime.now().millisecondsSinceEpoch}';

      final result = await service.saveMediaListEntry(
        mediaId: testMediaId,
        status: AnilistListApiStatus.PLANNING,
        notes: testNotes,
      );

      print('saveMediaListEntry result type: ${result.runtimeType}');
      print('saveMediaListEntry notes from response: ${result}');
      expect(result, isNotNull, reason: 'Mutation returned null');

      // Fetch back to verify
      final entryJson = await service.getMediaListEntry(testMediaId, userId);
      print('Fetched entry notes: ${entryJson?['notes']}');
      expect(entryJson?['notes'], testNotes, reason: 'Notes not saved to AniList');
    });

    test('save with dates — verify dates reach AniList', () async {
      final startDate = DateValue(year: 2025, month: 6, day: 15);
      final endDate = DateValue(year: 2025, month: 7, day: 20);

      final result = await service.saveMediaListEntry(
        mediaId: testMediaId,
        startedAt: startDate,
        completedAt: endDate,
      );

      expect(result, isNotNull, reason: 'Mutation returned null');

      // Fetch back to verify
      final entryJson = await service.getMediaListEntry(testMediaId, userId);
      print('Fetched startedAt: ${entryJson?['startedAt']}');
      print('Fetched completedAt: ${entryJson?['completedAt']}');

      expect(entryJson?['startedAt']?['year'], 2025, reason: 'startedAt year not saved');
      expect(entryJson?['startedAt']?['month'], 6, reason: 'startedAt month not saved');
      expect(entryJson?['startedAt']?['day'], 15, reason: 'startedAt day not saved');
      expect(entryJson?['completedAt']?['year'], 2025, reason: 'completedAt year not saved');
      expect(entryJson?['completedAt']?['month'], 7, reason: 'completedAt month not saved');
      expect(entryJson?['completedAt']?['day'], 20, reason: 'completedAt day not saved');
    });

    test('save all fields at once (mimicking dialog _save)', () async {
      // This mimics exactly what the entry editor dialog sends
      final testNotes = 'Full save test ${DateTime.now().millisecondsSinceEpoch}';
      final startDate = DateValue(year: 2025, month: 1, day: 5);
      final endDate = DateValue(year: 2025, month: 2, day: 10);

      final result = await service.saveMediaListEntry(
        mediaId: testMediaId,
        status: AnilistListApiStatus.PLANNING,
        scoreRaw: 70,        // POINT_100: 70 = 7.0 in POINT_10 scale
        progress: 0,
        repeat: 0,
        priority: null,
        private: false,
        notes: testNotes,
        hiddenFromStatusLists: false,
        customLists: [],      // empty custom lists
        startedAt: startDate,
        completedAt: endDate,
      );

      expect(result, isNotNull, reason: 'Full save mutation returned null');

      // Fetch back
      final entryJson = await service.getMediaListEntry(testMediaId, userId);
      print('Full save - notes: ${entryJson?['notes']}');
      print('Full save - startedAt: ${entryJson?['startedAt']}');
      print('Full save - completedAt: ${entryJson?['completedAt']}');
      print('Full save - score: ${entryJson?['score']} (expect 70.0 in POINT_100)');

      expect(entryJson?['notes'], testNotes, reason: 'Notes not saved in full save');
      expect(entryJson?['startedAt']?['year'], 2025, reason: 'startedAt not saved in full save');
      expect(entryJson?['completedAt']?['year'], 2025, reason: 'completedAt not saved in full save');
      // score is now returned as POINT_100 (70 = 7.0 on 10-point scale)
      expect(entryJson?['score'], 70, reason: 'Score not saved in full save');
    });

    test('clear notes by sending empty string', () async {
      // First set a note
      await service.saveMediaListEntry(mediaId: testMediaId, notes: 'will be cleared');
      var entryJson = await service.getMediaListEntry(testMediaId, userId);
      expect(entryJson?['notes'], 'will be cleared');

      // Now clear it with empty string
      await service.saveMediaListEntry(mediaId: testMediaId, notes: '');
      entryJson = await service.getMediaListEntry(testMediaId, userId);
      print('Notes after clear: "${entryJson?['notes']}"');
      // AniList should return null or empty
      expect(entryJson?['notes'] == null || entryJson?['notes'] == '', true,
          reason: 'Notes not cleared: "${entryJson?['notes']}"');
    });

    test('clear dates by sending empty FuzzyDateInput', () async {
      // First set dates
      await service.saveMediaListEntry(
        mediaId: testMediaId,
        startedAt: DateValue(year: 2025, month: 3, day: 1),
      );
      var entryJson = await service.getMediaListEntry(testMediaId, userId);
      expect(entryJson?['startedAt']?['year'], 2025);

      // Now clear by sending DateValue with all null fields
      await service.saveMediaListEntry(
        mediaId: testMediaId,
        startedAt: DateValue(), // year, month, day all null
      );
      entryJson = await service.getMediaListEntry(testMediaId, userId);
      print('startedAt after clear: ${entryJson?['startedAt']}');
      expect(entryJson?['startedAt']?['year'], null, reason: 'startedAt year not cleared');
    });

    test('raw GraphQL mutation with notes and dates (bypass wrapper)', () async {
      final rawResult = await client.mutate(MutationOptions(
        document: gql(r'''
          mutation($mediaId: Int, $notes: String, $startedAt: FuzzyDateInput) {
            SaveMediaListEntry(mediaId: $mediaId, notes: $notes, startedAt: $startedAt) {
              id
              notes
              startedAt { year month day }
            }
          }
        '''),
        variables: {
          'mediaId': testMediaId,
          'notes': 'raw direct note',
          'startedAt': {'year': 2025, 'month': 8, 'day': 1},
        },
      ));

      print('Raw mutation errors: ${rawResult.exception}');
      print('Raw mutation data: ${rawResult.data}');

      expect(rawResult.hasException, false, reason: 'Raw mutation had errors');
      expect(rawResult.data?['SaveMediaListEntry']?['notes'], 'raw direct note');
      expect(rawResult.data?['SaveMediaListEntry']?['startedAt']?['year'], 2025);
    });

    test('getScoreFormat returns valid format', () async {
      // Wait to avoid rate limiting from previous tests
      await Future.delayed(const Duration(seconds: 3));
      final format = await service.getScoreFormat();
      print('Score format: $format');
      expect(format, isNotNull, reason: 'getScoreFormat returned null');
      expect(
        ['POINT_100', 'POINT_10_DECIMAL', 'POINT_10', 'POINT_5', 'POINT_3'].contains(format),
        true,
        reason: 'Unexpected score format: $format',
      );
    });

    test('score round-trip: save scoreRaw, fetch back as POINT_100', () async {
      await Future.delayed(const Duration(seconds: 2));

      // Save a score of 85 (= 8.5 in POINT_10_DECIMAL, = 8 in POINT_10)
      const scoreRaw = 85;
      final result = await service.saveMediaListEntry(
        mediaId: testMediaId,
        scoreRaw: scoreRaw,
      );
      expect(result, isNotNull, reason: 'saveMediaListEntry returned null');

      // Fetch back — query now uses score(format: POINT_100)
      final entryJson = await service.getMediaListEntry(testMediaId, userId);
      final returnedScore = entryJson?['score'];
      print('Saved scoreRaw=$scoreRaw, fetched score=$returnedScore (expect $scoreRaw in POINT_100)');

      // The returned score should be the POINT_100 value we saved
      expect(
        (returnedScore as num?)?.round(),
        scoreRaw,
        reason: 'Score round-trip failed: saved $scoreRaw, got $returnedScore',
      );

      // Verify it also parses correctly into AnilistMediaListEntry
      final entry = AnilistMediaListEntry.fromJson(entryJson!);
      expect(entry.score, scoreRaw, reason: 'AnilistMediaListEntry.score should be POINT_100');
    });

    test('cleanup: reset test entry', () async {
      await service.saveMediaListEntry(
        mediaId: testMediaId,
        status: AnilistListApiStatus.PLANNING,
        notes: '',
        scoreRaw: 0,
      );
      // Clear dates with raw mutation since passing null DateValue won't send the field
      await client.mutate(MutationOptions(
        document: gql(r'''
          mutation($mediaId: Int, $startedAt: FuzzyDateInput, $completedAt: FuzzyDateInput) {
            SaveMediaListEntry(mediaId: $mediaId, startedAt: $startedAt, completedAt: $completedAt) { id }
          }
        '''),
        variables: {
          'mediaId': testMediaId,
          'startedAt': {'year': null, 'month': null, 'day': null},
          'completedAt': {'year': null, 'month': null, 'day': null},
        },
      ));
    });
  });
}
