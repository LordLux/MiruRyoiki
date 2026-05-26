/// Integration tests that mutate the real AniList debug account and verify the
/// changes round-trip correctly through the API.
///
/// Each test's [setUp] resets the Cowboy Bebop list entry to a blank slate so
/// tests are order-independent regardless of which subset is run.
///
/// Run with:  powershell -File test/launch_scripts/real_anilist.ps1
@Timeout(Duration(minutes: 10))
@Tags(['real-api'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:miruryoiki/models/anilist/anime.dart';
import 'package:miruryoiki/models/anilist/user_list.dart';
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
    print('Test account: ${ctx.username} (ID: ${ctx.userId})');
  });

  setUp(() async {
    // Blank slate: ensure any previous state on the test media ID is cleared.
    await ctx.reset.ensureEntryAbsent(TestMedia.cowboyBebop);
  });

  const testMediaId = TestMedia.cowboyBebop;

  group('SaveMediaListEntry integration', () {
    test('save with notes — verify notes reach AniList', () async {
      final testNotes = 'Test note ${DateTime.now().millisecondsSinceEpoch}';

      final result = await ctx.service.saveMediaListEntry(
        mediaId: testMediaId,
        status: AnilistListApiStatus.PLANNING,
        notes: testNotes,
      );

      expect(result, isNotNull, reason: 'Mutation returned null');

      final entryJson = await ctx.service.getMediaListEntry(testMediaId, ctx.userId);
      expect(entryJson?['notes'], testNotes, reason: 'Notes not saved to AniList');
    });

    test('save with dates — verify dates reach AniList', () async {
      final startDate = DateValue(year: 2025, month: 6, day: 15);
      final endDate = DateValue(year: 2025, month: 7, day: 20);

      final result = await ctx.service.saveMediaListEntry(
        mediaId: testMediaId,
        startedAt: startDate,
        completedAt: endDate,
      );

      expect(result, isNotNull, reason: 'Mutation returned null');

      final entryJson = await ctx.service.getMediaListEntry(testMediaId, ctx.userId);
      expect(entryJson?['startedAt']?['year'], 2025, reason: 'startedAt year not saved');
      expect(entryJson?['startedAt']?['month'], 6, reason: 'startedAt month not saved');
      expect(entryJson?['startedAt']?['day'], 15, reason: 'startedAt day not saved');
      expect(entryJson?['completedAt']?['year'], 2025, reason: 'completedAt year not saved');
      expect(entryJson?['completedAt']?['month'], 7, reason: 'completedAt month not saved');
      expect(entryJson?['completedAt']?['day'], 20, reason: 'completedAt day not saved');
    });

    test('save all fields at once (mimicking dialog _save)', () async {
      final testNotes = 'Full save test ${DateTime.now().millisecondsSinceEpoch}';
      final startDate = DateValue(year: 2025, month: 1, day: 5);
      final endDate = DateValue(year: 2025, month: 2, day: 10);

      final result = await ctx.service.saveMediaListEntry(
        mediaId: testMediaId,
        status: AnilistListApiStatus.PLANNING,
        scoreRaw: 70,
        progress: 0,
        repeat: 0,
        priority: null,
        private: false,
        notes: testNotes,
        hiddenFromStatusLists: false,
        customLists: [],
        startedAt: startDate,
        completedAt: endDate,
      );

      expect(result, isNotNull, reason: 'Full save mutation returned null');

      final entryJson = await ctx.service.getMediaListEntry(testMediaId, ctx.userId);
      expect(entryJson?['notes'], testNotes, reason: 'Notes not saved in full save');
      expect(entryJson?['startedAt']?['year'], 2025, reason: 'startedAt not saved in full save');
      expect(entryJson?['completedAt']?['year'], 2025, reason: 'completedAt not saved in full save');
      expect(entryJson?['score'], 70, reason: 'Score not saved in full save');
    });

    test('clear notes by sending empty string', () async {
      // First set a note (entry is absent after setUp — create it)
      await ctx.service.saveMediaListEntry(mediaId: testMediaId, notes: 'will be cleared');
      var entryJson = await ctx.service.getMediaListEntry(testMediaId, ctx.userId);
      expect(entryJson?['notes'], 'will be cleared');

      // Now clear it with empty string
      await ctx.service.saveMediaListEntry(mediaId: testMediaId, notes: '');
      entryJson = await ctx.service.getMediaListEntry(testMediaId, ctx.userId);
      expect(
        entryJson?['notes'] == null || entryJson?['notes'] == '',
        true,
        reason: 'Notes not cleared: "${entryJson?['notes']}"',
      );
    });

    test('clear dates by sending empty FuzzyDateInput', () async {
      // First set dates
      await ctx.service.saveMediaListEntry(
        mediaId: testMediaId,
        startedAt: DateValue(year: 2025, month: 3, day: 1),
      );
      var entryJson = await ctx.service.getMediaListEntry(testMediaId, ctx.userId);
      expect(entryJson?['startedAt']?['year'], 2025);

      // Now clear by sending DateValue with all null fields
      await ctx.service.saveMediaListEntry(
        mediaId: testMediaId,
        startedAt: DateValue(),
      );
      entryJson = await ctx.service.getMediaListEntry(testMediaId, ctx.userId);
      expect(entryJson?['startedAt']?['year'], null, reason: 'startedAt year not cleared');
    });

    test('raw GraphQL mutation with notes and dates (bypass wrapper)', () async {
      final rawResult = await ctx.client.mutate(MutationOptions(
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

      expect(rawResult.hasException, false, reason: 'Raw mutation had errors: ${rawResult.exception}');
      expect(rawResult.data?['SaveMediaListEntry']?['notes'], 'raw direct note');
      expect(rawResult.data?['SaveMediaListEntry']?['startedAt']?['year'], 2025);
    });

    test('getScoreFormat returns valid format', () async {
      final format = await ctx.service.getScoreFormat();
      expect(format, isNotNull, reason: 'getScoreFormat returned null');
      expect(
        ['POINT_100', 'POINT_10_DECIMAL', 'POINT_10', 'POINT_5', 'POINT_3'].contains(format),
        true,
        reason: 'Unexpected score format: $format',
      );
    });

    test('score round-trip: save scoreRaw, fetch back as POINT_100', () async {
      const scoreRaw = 85;
      final result = await ctx.service.saveMediaListEntry(
        mediaId: testMediaId,
        scoreRaw: scoreRaw,
      );
      expect(result, isNotNull, reason: 'saveMediaListEntry returned null');

      final entryJson = await ctx.service.getMediaListEntry(testMediaId, ctx.userId);
      final returnedScore = entryJson?['score'];

      expect(
        (returnedScore as num?)?.round(),
        scoreRaw,
        reason: 'Score round-trip failed: saved $scoreRaw, got $returnedScore',
      );

      final entry = AnilistMediaListEntry.fromJson(entryJson!);
      expect(entry.score, scoreRaw, reason: 'AnilistMediaListEntry.score should be POINT_100');
    });
  });
}
