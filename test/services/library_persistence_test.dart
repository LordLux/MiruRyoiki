// ignore_for_file: avoid_print

import 'package:drift/native.dart';
import 'package:flutter_anitomy/flutter_anitomy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/database/database.dart';
import 'package:miruryoiki/database/daos/series_dao.dart';
import 'package:miruryoiki/models/anilist/mapping.dart';
import 'package:miruryoiki/models/episode.dart';
import 'package:miruryoiki/models/metadata.dart';
import 'package:miruryoiki/models/mkv_metadata.dart';
import 'package:miruryoiki/models/season.dart';
import 'package:miruryoiki/models/series.dart';
import 'package:miruryoiki/utils/path.dart';

/// Creates a fresh in-memory database for each test.
AppDatabase _createTestDb() => AppDatabase(NativeDatabase.memory());

// ---------------------------------------------------------------------------
// Test data factories
// ---------------------------------------------------------------------------

/// A dummy ParsedAnime to bypass the native FFI call in Episode constructor
ParsedAnime _dummyParsedAnime() => ParsedAnime();

/// Parses episode number from name like 'Episode 01' -> 1
int? _parseEpNumber(String name) => int.tryParse(RegExp(r'(\d+)').firstMatch(name)?.group(1) ?? '');

Episode _ep(String name, {bool watched = false, double progress = 0.0, Metadata? metadata, MkvMetadata? mkvMetadata, String? anilistTitle}) {
  return Episode(
    path: PathString('M:\\Series\\TestSeries\\Season 1\\$name.mkv'),
    name: '$name.mkv',
    episodeNumber: _parseEpNumber(name),
    watched: watched,
    progress: progress,
    metadata: metadata,
    mkvMetadata: mkvMetadata,
    anilistTitle: anilistTitle,
    parsedAnime: _dummyParsedAnime(),
  );
}

Season _season(String name, List<Episode> episodes, {int seasonNumber = 1}) {
  return Season(
    name: name,
    path: PathString('M:\\Series\\TestSeries\\$name'),
    episodes: episodes,
    seasonNumber: seasonNumber,
  );
}

Series _series({
  String name = 'TestSeries',
  String path = 'M:\\Series\\TestSeries',
  List<Season>? seasons,
  List<AnilistMapping>? anilistMappings,
}) {
  return Series(
    name: name,
    path: PathString(path),
    collections: seasons ?? [],
    anilistMappings: anilistMappings ?? [],
  );
}

AnilistMapping _mapping(int anilistId, {String? localPath, String? title}) {
  return AnilistMapping(
    localPath: PathString(localPath ?? 'M:\\Series\\TestSeries'),
    anilistId: anilistId,
    title: title,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // =========================================================================
  // GROUP 1: DAO change detection helpers
  // =========================================================================
  group('SeriesDao change detection', () {
    late AppDatabase db;
    late SeriesDao dao;

    setUp(() {
      db = _createTestDb();
      dao = db.seriesDao;
    });

    tearDown(() async {
      await db.close();
    });

    test('syncSeries inserts a new series and all children', () async {
      print('[TEST] Inserting a brand-new series with 1 season + 2 episodes...');

      final series = _series(
        seasons: [
          _season('Season 1', [_ep('Episode 01'), _ep('Episode 02')]),
        ],
        anilistMappings: [_mapping(12345, title: 'Test Anime')],
      );

      await dao.syncSeries(series);

      final rows = await dao.getAllSeriesRows();
      expect(rows, hasLength(1), reason: 'Exactly one series row should exist');
      expect(rows.first.name, 'TestSeries');

      final loaded = await dao.loadFullSeries(rows.first.id);
      expect(loaded, isNotNull);
      expect(loaded!.seasons, hasLength(1));
      expect(loaded.seasons.first.episodes, hasLength(2));
      expect(loaded.anilistMappings, hasLength(1));
      expect(loaded.anilistMappings.first.anilistId, 12345);

      print('[PASS] Series with children inserted correctly.');
    });

    test('syncSeries skips write when nothing changed', () async {
      print('[TEST] Syncing identical series twice should produce no DB writes on second sync...');

      final series = _series(
        seasons: [_season('Season 1', [_ep('Episode 01')])],
      );

      await dao.syncSeries(series);
      final rowsAfterFirst = await dao.getAllSeriesRows();
      final updatedAtFirst = rowsAfterFirst.first.updatedAt;

      // Wait a moment so updatedAt would differ if a write occurred
      await Future.delayed(const Duration(milliseconds: 50));

      await dao.syncSeries(series);
      final rowsAfterSecond = await dao.getAllSeriesRows();
      final updatedAtSecond = rowsAfterSecond.first.updatedAt;

      // updatedAt should NOT change because _hasSeriesChanged returned false
      expect(updatedAtSecond, equals(updatedAtFirst), reason: 'updatedAt should remain the same when nothing changed');

      print('[PASS] No unnecessary DB write on identical sync.');
    });

    test('syncSeries detects episode field change', () async {
      print('[TEST] Changing episode watched state should produce a DB write...');

      final ep = _ep('Episode 01');
      final series = _series(seasons: [_season('Season 1', [ep])]);

      await dao.syncSeries(series);

      // Mutate the episode
      ep.watched = true;
      ep.progress = 0.95;

      await dao.syncSeries(series);

      final loaded = await dao.loadFullSeries((await dao.getAllSeriesRows()).first.id);
      expect(loaded!.seasons.first.episodes.first.watched, isTrue, reason: 'Episode should be marked watched');
      expect(loaded.seasons.first.episodes.first.progress, closeTo(0.95, 0.001));

      print('[PASS] Episode change detected and persisted.');
    });

    test('syncSeries detects episode metadata change', () async {
      print('[TEST] Changing episode metadata should trigger a write...');

      final meta1 = Metadata(size: 1000, duration: const Duration(minutes: 24));
      final ep = _ep('Episode 01', metadata: meta1);
      final series = _series(seasons: [_season('Season 1', [ep])]);

      await dao.syncSeries(series);

      // Change metadata
      ep.metadata = Metadata(size: 2000, duration: const Duration(minutes: 24));

      await dao.syncSeries(series);

      final loaded = await dao.loadFullSeries((await dao.getAllSeriesRows()).first.id);
      expect(loaded!.seasons.first.episodes.first.metadata!.size, 2000);

      print('[PASS] Metadata change detected.');
    });

    test('syncSeries detects mapping change', () async {
      print('[TEST] Changing mapping title should trigger a DB write...');

      final mapping = _mapping(99999, title: 'Original Title');
      final series = _series(anilistMappings: [mapping]);

      await dao.syncSeries(series);

      // Mutate mapping title
      mapping.title = 'Updated Title';

      await dao.syncSeries(series);

      final loaded = await dao.loadFullSeries((await dao.getAllSeriesRows()).first.id);
      expect(loaded!.anilistMappings.first.title, 'Updated Title');

      print('[PASS] Mapping change detected and persisted.');
    });

    test('syncSeries deletes removed seasons and episodes', () async {
      print('[TEST] Removing a season should cascade-delete its episodes...');

      final series = _series(
        seasons: [
          _season('Season 1', [_ep('Episode 01')]),
          _season('Season 2', [_ep('Episode 01')], seasonNumber: 2),
        ],
      );

      await dao.syncSeries(series);

      // Remove Season 2
      series.collections.removeAt(1);
      await dao.syncSeries(series);

      final loaded = await dao.loadFullSeries((await dao.getAllSeriesRows()).first.id);
      expect(loaded!.seasons, hasLength(1));
      expect(loaded.seasons.first.name, 'Season 1');

      print('[PASS] Season removal cascaded correctly.');
    });
  });

  // =========================================================================
  // GROUP 2: Batch sync
  // =========================================================================
  group('SeriesDao syncSeriesBatch', () {
    late AppDatabase db;
    late SeriesDao dao;

    setUp(() {
      db = _createTestDb();
      dao = db.seriesDao;
    });

    tearDown(() async => await db.close());

    test('batch sync inserts multiple series in one transaction', () async {
      print('[TEST] Inserting 3 series via syncSeriesBatch...');

      final seriesList = List.generate(3, (i) {
        return _series(
          name: 'Series $i',
          path: 'M:\\Series\\Series$i',
          seasons: [
            _season('Season 1', [_ep('Episode 01'), _ep('Episode 02')]),
          ],
        );
      });

      await dao.syncSeriesBatch(seriesList);

      final rows = await dao.getAllSeriesRows();
      expect(rows, hasLength(3));

      for (int i = 0; i < 3; i++) {
        final loaded = await dao.loadFullSeries(rows[i].id);
        expect(loaded, isNotNull);
        expect(loaded!.seasons, hasLength(1));
        expect(loaded.seasons.first.episodes, hasLength(2));
      }

      print('[PASS] Batch insert of 3 series succeeded.');
    });

    test('batch sync with empty list is a no-op', () async {
      print('[TEST] syncSeriesBatch with empty list should not throw...');
      await dao.syncSeriesBatch([]);
      final rows = await dao.getAllSeriesRows();
      expect(rows, isEmpty);
      print('[PASS] Empty batch handled gracefully.');
    });
  });

  // =========================================================================
  // GROUP 3: loadAllSeries bulk loading
  // =========================================================================
  group('SeriesDao loadAllSeries', () {
    late AppDatabase db;
    late SeriesDao dao;

    setUp(() {
      db = _createTestDb();
      dao = db.seriesDao;
    });

    tearDown(() async => await db.close());

    test('loadAllSeries returns empty list for empty DB', () async {
      print('[TEST] loadAllSeries on empty DB...');
      final result = await dao.loadAllSeries();
      expect(result, isEmpty);
      print('[PASS] Empty DB returns empty list.');
    });

    test('loadAllSeries matches loadFullSeries results', () async {
      print('[TEST] loadAllSeries should produce the same data as per-series loadFullSeries...');

      // Create varied test data
      final seriesList = [
        _series(
          name: 'Series A',
          path: 'M:\\Series\\SeriesA',
          seasons: [
            _season('Season 1', [
              _ep('Episode 01', watched: true, progress: 1.0),
              _ep('Episode 02'),
            ]),
            _season('Season 2', [
              _ep('Episode 01', anilistTitle: 'The Beginning'),
            ], seasonNumber: 2),
          ],
          anilistMappings: [_mapping(111, title: 'Anime A')],
        ),
        _series(
          name: 'Series B',
          path: 'M:\\Series\\SeriesB',
          seasons: [
            _season('Season 1', [
              _ep('Episode 01', metadata: Metadata(size: 500, duration: const Duration(minutes: 24))),
            ]),
          ],
          anilistMappings: [
            _mapping(222, title: 'Anime B1'),
            _mapping(333, title: 'Anime B2'),
          ],
        ),
        _series(
          name: 'Series C',
          path: 'M:\\Series\\SeriesC',
          seasons: [],
          anilistMappings: [],
        ),
      ];

      await dao.syncSeriesBatch(seriesList);

      // Load via both methods
      final allRows = await dao.getAllSeriesRows();
      final perSeries = <Series>[];
      for (final row in allRows) {
        final s = await dao.loadFullSeries(row.id);
        if (s != null) perSeries.add(s);
      }

      final bulk = await dao.loadAllSeries();

      // Compare counts
      expect(bulk.length, equals(perSeries.length), reason: 'Same number of series');

      // Sort both by name for stable comparison
      perSeries.sort((a, b) => a.name.compareTo(b.name));
      bulk.sort((a, b) => a.name.compareTo(b.name));

      for (int i = 0; i < bulk.length; i++) {
        final b = bulk[i];
        final p = perSeries[i];

        expect(b.name, equals(p.name), reason: 'Series name mismatch at index $i');
        expect(b.path, equals(p.path), reason: 'Series path mismatch at index $i');
        expect(b.seasons.length, equals(p.seasons.length), reason: 'Season count mismatch for ${b.name}');
        expect(b.anilistMappings.length, equals(p.anilistMappings.length), reason: 'Mapping count mismatch for ${b.name}');

        for (int j = 0; j < b.seasons.length; j++) {
          expect(b.seasons[j].name, equals(p.seasons[j].name), reason: 'Season name mismatch for ${b.name} season $j');
          expect(b.seasons[j].episodes.length, equals(p.seasons[j].episodes.length), reason: 'Episode count mismatch for ${b.name} season $j');

          for (int k = 0; k < b.seasons[j].episodes.length; k++) {
            final be = b.seasons[j].episodes[k];
            final pe = p.seasons[j].episodes[k];
            expect(be.name, equals(pe.name), reason: 'Episode name mismatch');
            expect(be.watched, equals(pe.watched), reason: 'Episode watched mismatch');
            expect(be.progress, closeTo(pe.progress, 0.001), reason: 'Episode progress mismatch');
            expect(be.anilistTitle, equals(pe.anilistTitle), reason: 'Episode anilistTitle mismatch');
            expect(be.metadata, equals(pe.metadata), reason: 'Episode metadata mismatch');
          }
        }

        for (int j = 0; j < b.anilistMappings.length; j++) {
          expect(b.anilistMappings[j].anilistId, equals(p.anilistMappings[j].anilistId), reason: 'Mapping anilistId mismatch');
          expect(b.anilistMappings[j].title, equals(p.anilistMappings[j].title), reason: 'Mapping title mismatch');
        }
      }

      print('[PASS] loadAllSeries matches per-series loading for all fields.');
    });

    test('loadAllSeries preserves episode ordering within seasons', () async {
      print('[TEST] Episodes should be sorted by episode number...');

      // Insert episodes in reverse order — they should come back sorted
      final series = _series(
        name: 'Ordered',
        path: 'M:\\Series\\Ordered',
        seasons: [
          _season('Season 1', [
            _ep('Episode 03'),
            _ep('Episode 01'),
            _ep('Episode 02'),
          ]),
        ],
      );

      await dao.syncSeries(series);

      final bulk = await dao.loadAllSeries();
      final eps = bulk.first.seasons.first.episodes;

      // DB should return them sorted. Episode numbers parsed from "Episode 0X"
      // After sort: 01, 02, 03
      final numbers = eps.map((e) => e.episodeNumber).toList();
      expect(numbers, equals([1, 2, 3]), reason: 'Episodes should be sorted by number');

      print('[PASS] Episode ordering preserved.');
    });
  });

  // =========================================================================
  // GROUP 4: Metadata / MkvMetadata equality
  // =========================================================================
  group('Model equality', () {
    test('Metadata equality works for identical values', () {
      print('[TEST] Metadata == with same fields...');
      final t = DateTime(2025, 1, 1);
      final a = Metadata(size: 100, duration: const Duration(seconds: 60), creationTime: t, lastModified: t, lastAccessed: t);
      final b = Metadata(size: 100, duration: const Duration(seconds: 60), creationTime: t, lastModified: t, lastAccessed: t);
      expect(a, equals(b));
      print('[PASS]');
    });

    test('Metadata inequality for different size', () {
      print('[TEST] Metadata != with different size...');
      final a = Metadata(size: 100);
      final b = Metadata(size: 200);
      expect(a, isNot(equals(b)));
      print('[PASS]');
    });

    test('Metadata inequality for different duration', () {
      print('[TEST] Metadata != with different duration...');
      final a = Metadata(duration: const Duration(minutes: 24));
      final b = Metadata(duration: const Duration(minutes: 25));
      expect(a, isNot(equals(b)));
      print('[PASS]');
    });

    test('MkvMetadata equality works for identical values', () {
      print('[TEST] MkvMetadata == with same fields...');
      const a = MkvMetadata(format: 'Matroska', bitrate: 5000000);
      const b = MkvMetadata(format: 'Matroska', bitrate: 5000000);
      expect(a, equals(b));
      print('[PASS]');
    });

    test('MkvMetadata inequality for different bitrate', () {
      print('[TEST] MkvMetadata != with different bitrate...');
      const a = MkvMetadata(format: 'Matroska', bitrate: 5000000);
      const b = MkvMetadata(format: 'Matroska', bitrate: 3000000);
      expect(a, isNot(equals(b)));
      print('[PASS]');
    });

    test('MkvMetadata inequality for different streams', () {
      print('[TEST] MkvMetadata != with different audioStreams...');
      const a = MkvMetadata(audioStreams: [AudioStream(language: 'jpn')]);
      const b = MkvMetadata(audioStreams: [AudioStream(language: 'eng')]);
      expect(a, isNot(equals(b)));
      print('[PASS]');
    });
  });

  // =========================================================================
  // GROUP 5: Round-trip consistency (sync then load)
  // =========================================================================
  group('Round-trip sync-then-load', () {
    late AppDatabase db;
    late SeriesDao dao;

    setUp(() {
      db = _createTestDb();
      dao = db.seriesDao;
    });

    tearDown(() async => await db.close());

    test('episode metadata survives a round-trip through the database', () async {
      print('[TEST] Metadata round-trip (sync -> load -> compare)...');

      final meta = Metadata(
        size: 1500000000,
        duration: const Duration(minutes: 24, seconds: 30),
        creationTime: DateTime(2025, 6, 15),
        lastModified: DateTime(2025, 6, 16),
        lastAccessed: DateTime(2025, 6, 17),
      );

      final mkv = const MkvMetadata(
        format: 'Matroska',
        bitrate: 8000000,
        videoStreams: [VideoStream(format: 'HEVC', size: Pair(width: 1920, height: 1080))],
        audioStreams: [AudioStream(format: 'FLAC', language: 'jpn', channels: 2)],
        textStreams: [TextStream(format: 'ASS', language: 'eng', title: 'English')],
      );

      final series = _series(
        seasons: [
          _season('Season 1', [_ep('Episode 01', metadata: meta, mkvMetadata: mkv)]),
        ],
      );

      await dao.syncSeries(series);

      final loaded = (await dao.loadAllSeries()).first;
      final loadedEp = loaded.seasons.first.episodes.first;

      expect(loadedEp.metadata, equals(meta), reason: 'Metadata should survive round-trip');
      expect(loadedEp.mkvMetadata, equals(mkv), reason: 'MkvMetadata should survive round-trip');

      print('[PASS] All metadata fields preserved through DB round-trip.');
    });

    test('multiple syncs of same series are idempotent', () async {
      print('[TEST] Syncing the same series 5 times should produce identical DB state...');

      final series = _series(
        seasons: [
          _season('Season 1', [_ep('Episode 01', watched: true, progress: 0.85)]),
        ],
        anilistMappings: [_mapping(42, title: 'The Answer')],
      );

      for (int i = 0; i < 5; i++) {
        await dao.syncSeries(series);
      }

      final rows = await dao.getAllSeriesRows();
      expect(rows, hasLength(1), reason: 'Should still be exactly 1 series after 5 syncs');

      final loaded = (await dao.loadAllSeries()).first;
      expect(loaded.seasons.first.episodes.first.watched, isTrue);
      expect(loaded.seasons.first.episodes.first.progress, closeTo(0.85, 0.001));
      expect(loaded.anilistMappings.first.title, 'The Answer');

      print('[PASS] Repeated syncs are idempotent.');
    });

    test('concurrent batch sync does not duplicate data', () async {
      print('[TEST] Two sequential batch syncs with overlapping data should not duplicate...');

      final seriesA = _series(name: 'A', path: 'M:\\Series\\A', seasons: [_season('S1', [_ep('E01')])]);
      final seriesB = _series(name: 'B', path: 'M:\\Series\\B', seasons: [_season('S1', [_ep('E01')])]);

      await dao.syncSeriesBatch([seriesA, seriesB]);
      await dao.syncSeriesBatch([seriesA, seriesB]);

      final rows = await dao.getAllSeriesRows();
      expect(rows, hasLength(2), reason: 'Should not duplicate series on re-sync');

      print('[PASS] No duplication on re-sync.');
    });
  });

  // =========================================================================
  // GROUP 6: Deletion handling
  // =========================================================================
  group('Deletion handling', () {
    late AppDatabase db;
    late SeriesDao dao;

    setUp(() {
      db = _createTestDb();
      dao = db.seriesDao;
    });

    tearDown(() async => await db.close());

    test('deleteSeriesRow removes the series and cascades', () async {
      print('[TEST] Deleting a series row should cascade to seasons, episodes, and mappings...');

      final series = _series(
        seasons: [_season('Season 1', [_ep('Episode 01'), _ep('Episode 02')])],
        anilistMappings: [_mapping(777)],
      );

      await dao.syncSeries(series);
      final rows = await dao.getAllSeriesRows();
      expect(rows, hasLength(1));

      await dao.deleteSeriesRow(rows.first.id);

      final afterDelete = await dao.getAllSeriesRows();
      expect(afterDelete, isEmpty, reason: 'Series should be deleted');

      final loaded = await dao.loadAllSeries();
      expect(loaded, isEmpty, reason: 'loadAllSeries should return nothing');

      print('[PASS] Series deletion cascades to all children.');
    });

    test('removing an episode from a season deletes it from DB', () async {
      print('[TEST] Removing an episode from the model and re-syncing should delete it from DB...');

      final ep1 = _ep('Episode 01');
      final ep2 = _ep('Episode 02');
      final season = _season('Season 1', [ep1, ep2]);
      final series = _series(seasons: [season]);

      await dao.syncSeries(series);

      // Remove episode 2
      season.episodes.remove(ep2);
      await dao.syncSeries(series);

      final loaded = (await dao.loadAllSeries()).first;
      expect(loaded.seasons.first.episodes, hasLength(1));
      expect(loaded.seasons.first.episodes.first.name, contains('Episode 01'));

      print('[PASS] Removed episode deleted from DB.');
    });

    test('removing a mapping from a series deletes it from DB', () async {
      print('[TEST] Removing a mapping and re-syncing should delete it...');

      final m1 = _mapping(100, title: 'Keep');
      final m2 = _mapping(200, title: 'Remove');
      final series = _series(anilistMappings: [m1, m2]);

      await dao.syncSeries(series);
      series.anilistMappings.remove(m2);
      await dao.syncSeries(series);

      final loaded = (await dao.loadAllSeries()).first;
      expect(loaded.anilistMappings, hasLength(1));
      expect(loaded.anilistMappings.first.anilistId, 100);
      expect(loaded.anilistMappings.first.title, 'Keep');

      print('[PASS] Removed mapping deleted from DB.');
    });
  });

  // =========================================================================
  // GROUP 7: Edge cases
  // =========================================================================
  group('Edge cases', () {
    late AppDatabase db;
    late SeriesDao dao;

    setUp(() {
      db = _createTestDb();
      dao = db.seriesDao;
    });

    tearDown(() async => await db.close());

    test('series with no seasons and no mappings', () async {
      print('[TEST] Bare series with no children...');

      final series = _series(name: 'Empty', path: 'M:\\Series\\Empty');
      await dao.syncSeries(series);

      final loaded = (await dao.loadAllSeries()).first;
      expect(loaded.name, 'Empty');
      expect(loaded.seasons, isEmpty);
      expect(loaded.anilistMappings, isEmpty);

      print('[PASS] Bare series handled.');
    });

    test('series with empty season (no episodes)', () async {
      print('[TEST] Season with zero episodes...');

      final series = _series(
        seasons: [_season('Season 1', [])],
      );
      await dao.syncSeries(series);

      final loaded = (await dao.loadAllSeries()).first;
      expect(loaded.seasons, hasLength(1));
      expect(loaded.seasons.first.episodes, isEmpty);

      print('[PASS] Empty season handled.');
    });

    test('large batch sync (50 series)', () async {
      print('[TEST] Syncing 50 series in one batch...');

      final seriesList = List.generate(50, (i) {
        return _series(
          name: 'Series $i',
          path: 'M:\\Series\\Series$i',
          seasons: [
            _season('Season 1', [_ep('Episode 01'), _ep('Episode 02')]),
          ],
          anilistMappings: [_mapping(1000 + i, title: 'Anime $i')],
        );
      });

      await dao.syncSeriesBatch(seriesList);

      final loaded = await dao.loadAllSeries();
      expect(loaded, hasLength(50));

      // Spot-check a few
      final s0 = loaded.firstWhere((s) => s.name == 'Series 0');
      expect(s0.seasons, hasLength(1));
      expect(s0.anilistMappings.first.anilistId, 1000);

      final s49 = loaded.firstWhere((s) => s.name == 'Series 49');
      expect(s49.anilistMappings.first.title, 'Anime 49');

      print('[PASS] 50-series batch sync completed.');
    });
  });
}
