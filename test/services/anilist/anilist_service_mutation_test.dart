/// Tests for [AnilistService] mutations against the real AniList API.
///
/// Each mutation test verifies that the field actually reaches AniList by
/// reading the entry back after the write (mutate-then-read round-trip).
///
/// The pure-unit [AnilistMediaListEntry.fromJson] test requires no network
/// and is grouped separately.
///
/// Run with:  powershell -File test/run_real_anilist.ps1
@Timeout(Duration(minutes: 10))
@Tags(['real-api'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/models/anilist/user_list.dart';
import 'package:miruryoiki/services/anilist/queries/anilist_service.dart';

import 'support/anilist_test_harness.dart';

void main() {
  group('AnilistMediaListEntry.fromJson (unit)', () {
    test('parses POINT_100 score correctly', () {
      final json = {
        'id': 1,
        'mediaId': 100,
        'status': 'CURRENT',
        'progress': 5,
        'score': 85.0,
        'repeat': 0,
        'notes': null,
        'private': false,
        'customLists': null,
        'hiddenFromStatusLists': false,
        'priority': null,
        'startedAt': null,
        'completedAt': null,
        'createdAt': null,
        'updatedAt': null,
        'media': {
          'id': 100,
          'isFavourite': false,
          'title': {'userPreferred': 'Test Anime'},
        },
      };

      final entry = AnilistMediaListEntry.fromJson(json);
      expect(entry.score, 85);
    });
  });

  group('AnilistService Mutations (real API round-trips)', () {
    late RealAnilistContext ctx;
    const mediaId = TestMedia.fullmetalAlchemist;

    setUpAll(() async {
      final result = await RealAnilist.setUp();
      if (result == null) {
        markTestSkipped('No ACCESS_TOKEN in test/.env');
        return;
      }
      ctx = result;
    });

    setUp(() async {
      // Blank slate: ensure the test entry exists in a known neutral status
      // so update calls modify an existing entry (progress/status/score require
      // an entry to already exist on some AniList implementations).
      await ctx.reset.ensureEntryWithStatus(mediaId, AnilistListApiStatus.CURRENT);
    });

    test('updateProgress reaches AniList (progress = 5)', () async {
      final ok = await ctx.service.updateProgress(mediaId, 5);
      expect(ok, isTrue);

      final entryJson = await ctx.service.getMediaListEntry(mediaId, ctx.userId);
      expect(entryJson?['progress'], 5, reason: 'progress not persisted to AniList');
    });

    test('updateStatus reaches AniList (status = CURRENT)', () async {
      // Pre-condition: entry is CURRENT from setUp.
      // Move to PLANNING then back to CURRENT so we actually observe a change.
      await ctx.service.updateStatus(mediaId, AnilistListApiStatus.PLANNING);
      final ok = await ctx.service.updateStatus(mediaId, AnilistListApiStatus.CURRENT);
      expect(ok, isTrue);

      final entryJson = await ctx.service.getMediaListEntry(mediaId, ctx.userId);
      expect(entryJson?['status'], 'CURRENT', reason: 'status not persisted to AniList');
    });

    test('updateScore reaches AniList (scoreRaw = 80, POINT_100)', () async {
      final ok = await ctx.service.updateScore(mediaId, 80);
      expect(ok, isTrue);

      final entryJson = await ctx.service.getMediaListEntry(mediaId, ctx.userId);
      expect(
        (entryJson?['score'] as num?)?.round(),
        80,
        reason: 'score not persisted to AniList',
      );
    });

    test('updateScore preserves decimal precision (scoreRaw = 85)', () async {
      final ok = await ctx.service.updateScore(mediaId, 85);
      expect(ok, isTrue);

      final entryJson = await ctx.service.getMediaListEntry(mediaId, ctx.userId);
      expect(
        (entryJson?['score'] as num?)?.round(),
        85,
        reason: 'score decimal precision not persisted to AniList',
      );
    });
  });

  group('getUserAnimeLists (real API)', () {
    late RealAnilistContext ctx;
    const mediaId = TestMedia.fullmetalAlchemist;

    setUpAll(() async {
      final result = await RealAnilist.setUp();
      if (result == null) {
        markTestSkipped('No ACCESS_TOKEN in test/.env');
        return;
      }
      ctx = result;
    });

    test('parses user lists and groups entries by status', () async {
      // Ensure there is at least one COMPLETED entry for our test media ID.
      await ctx.reset.ensureEntryWithStatus(mediaId, AnilistListApiStatus.COMPLETED);

      final result = await ctx.service.getUserAnimeLists(userName: ctx.username);
      expect(result, isNotEmpty);
      expect(result.keys, contains('COMPLETED'));

      final completedList = result['COMPLETED']!;
      expect(
        completedList.entries.any((e) => e.mediaId == mediaId),
        isTrue,
        reason: 'Expected mediaId $mediaId in COMPLETED list',
      );
    });
  });
}
