/// Tests for [AnilistProvider.saveEntry] merge behavior against the real API.
///
/// The underlying [AnilistService] performs real mutations so that the
/// merge logic is exercised end-to-end.  Assertions inspect the provider's
/// in-memory [userLists] state after each save — exactly as before, but now
/// backed by a live API response rather than a fake client.
///
/// Run with:  powershell -File test/run_real_anilist.ps1
@Timeout(Duration(minutes: 10))
@Tags(['real-api'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/models/anilist/user_list.dart';
import 'package:miruryoiki/services/anilist/provider/anilist_provider.dart';
import 'package:miruryoiki/services/anilist/queries/anilist_service.dart';

import 'support/anilist_test_harness.dart';

void main() {
  late RealAnilistContext ctx;
  const movingMediaId = TestMedia.naruto;

  setUpAll(() async {
    final result = await RealAnilist.setUp();
    if (result == null) {
      markTestSkipped('No ACCESS_TOKEN in test/.env');
      return;
    }
    ctx = result;
  });

  group('AnilistProvider saveEntry merge behavior', () {
    test('creates missing target list when moving an existing entry to a new status', () async {
      // 1. Seed the account: put the entry in CURRENT status.
      await ctx.reset.ensureEntryWithStatus(movingMediaId, AnilistListApiStatus.CURRENT);

      // 2. Fetch the real entry so we have the correct AniList entry ID.
      final entryJson = await ctx.service.getMediaListEntry(movingMediaId, ctx.userId);
      expect(entryJson, isNotNull, reason: 'Entry must exist on account before this test');
      final initialEntry = AnilistMediaListEntry.fromJson(entryJson!);

      // 3. Build a provider with the real-backed service singleton and pre-seed
      //    its in-memory userLists to match the account state.
      final provider = AnilistProvider(anilistService: ctx.service);
      addTearDown(provider.dispose);

      provider.userLists[AnilistListApiStatus.CURRENT.name_] = AnilistUserList(
        entries: [initialEntry],
        name: AnilistListApiStatus.CURRENT.name_,
        status: AnilistListApiStatus.CURRENT,
      );

      // 4. Move the entry to COMPLETED — real mutation fires.
      final saved = await provider.saveEntry(
        mediaId: movingMediaId,
        status: AnilistListApiStatus.COMPLETED,
      );

      expect(saved, isTrue);
      expect(
        provider.userLists.containsKey(AnilistListApiStatus.COMPLETED.name_),
        isTrue,
        reason: 'COMPLETED list should be created when entry is moved there',
      );
      expect(
        provider.userLists[AnilistListApiStatus.COMPLETED.name_]!.entries
            .where((e) => e.mediaId == movingMediaId),
        isNotEmpty,
        reason: 'Entry should appear in COMPLETED list after save',
      );
      expect(
        provider.userLists[AnilistListApiStatus.CURRENT.name_]!.entries
            .where((e) => e.mediaId == movingMediaId),
        isEmpty,
        reason: 'Entry should be removed from CURRENT list after move',
      );
    });

    test('creates missing target list when merging a brand-new entry', () async {
      // 1. Ensure no entry for this media ID so saveEntry creates one fresh.
      await ctx.reset.ensureEntryAbsent(movingMediaId);

      // 2. Build a provider with no pre-seeded userLists.
      final provider = AnilistProvider(anilistService: ctx.service);
      addTearDown(provider.dispose);

      expect(
        provider.userLists.containsKey(AnilistListApiStatus.DROPPED.name_),
        isFalse,
      );

      // 3. Save a brand-new entry into DROPPED — real mutation fires.
      final saved = await provider.saveEntry(
        mediaId: movingMediaId,
        status: AnilistListApiStatus.DROPPED,
      );

      expect(saved, isTrue);
      expect(
        provider.userLists.containsKey(AnilistListApiStatus.DROPPED.name_),
        isTrue,
        reason: 'DROPPED list should be created for a brand-new entry',
      );
      expect(
        provider.userLists[AnilistListApiStatus.DROPPED.name_]!.entries
            .where((e) => e.mediaId == movingMediaId),
        isNotEmpty,
        reason: 'Brand-new entry should appear in DROPPED list',
      );
    });
  });
}
