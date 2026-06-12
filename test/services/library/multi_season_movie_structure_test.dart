// Reproduces the exact folder structure that crashed the app when scanning
// "Love, Chunibyo & Other Delusions" (multi-season + movies torrent):
//
//   Love, Chunibyo & Other Delusions/
//     [Judas] Chuunibyou - Extras/                          -> files
//     [Judas] Chuunibyou - Movies/                          -> files + nested "Movie NN Extras" subfolders
//     [Judas] Chuunibyou demo Koi ga Shitai! - S1/          -> files ("!" in folder name)
//     [Judas] Chuunibyou demo Koi ga Shitai! - S2 - Ren/    -> files ("!" in folder name)
//
// Natives (anitomy FFI, video_data_utils) are mocked via ServiceLocator, so
// this exercises the full Dart pipeline: discovery -> collection organization
// -> rescan diff -> DB persistence -> DB reload.
// If this suite passes but the real app crashes on the same structure, the
// crash is in native code (metadata/thumbnail/anitomy DLLs), not Dart.

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:miruryoiki/database/database.dart';
import 'package:miruryoiki/main.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/models/season.dart';
import 'package:miruryoiki/services/di/dependency_injection.dart';
import 'package:miruryoiki/services/library/library_provider.dart';
import 'package:miruryoiki/services/library/scanner/scanner_service.dart';
import 'package:miruryoiki/settings.dart';
import 'package:miruryoiki/utils/logging.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SettingsManager settings;
  late Library library;
  late LibraryScannerService scanner;
  late Directory baseTempDir;
  late Directory seriesDir;

  setUp(() {
    ServiceLocator.configureForTest();
    rootIsolateToken ??= ServicesBinding.rootIsolateToken;
    LoggingConfig.usePrintForLogging = true;
    Manager.skipScan = false;
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsManager();
    library = Library(settings, db);

    baseTempDir = Directory.systemTemp.createTempSync('miru_chuuni_test_');
    library.libraryPath = baseTempDir.path;

    seriesDir = Directory('${baseTempDir.path}\\Love, Chunibyo & Other Delusions')..createSync();

    final extras = Directory('${seriesDir.path}\\[Judas] Chuunibyou - Extras')..createSync();
    File('${extras.path}\\[Judas] Chuunibyou S1 - NCOP1.mkv').createSync();
    File('${extras.path}\\[Judas] Chuunibyou S1 - NCED1.mkv').createSync();
    File('${extras.path}\\[Judas] Chuunibyou S2 - NCOP1.mkv').createSync();

    final movies = Directory('${seriesDir.path}\\[Judas] Chuunibyou - Movies')..createSync();
    File('${movies.path}\\[Judas] Chuunibyou Movie 01.mkv').createSync();
    File('${movies.path}\\[Judas] Chuunibyou Movie 02.mkv').createSync();
    final movie1Extras = Directory('${movies.path}\\Movie 01 Extras')..createSync();
    File('${movie1Extras.path}\\[Judas] Chuunibyou Movie 01 - Making Of.mkv').createSync();
    final movie2Extras = Directory('${movies.path}\\Movie 02 Extras')..createSync();
    File('${movie2Extras.path}\\[Judas] Chuunibyou Movie 02 - Making Of.mkv').createSync();

    final s1 = Directory('${seriesDir.path}\\[Judas] Chuunibyou demo Koi ga Shitai! - S1')..createSync();
    for (var i = 1; i <= 3; i++) {
      File('${s1.path}\\[Judas] Chuunibyou S1 - 0$i.mkv').createSync();
    }

    final s2 = Directory('${seriesDir.path}\\[Judas] Chuunibyou demo Koi ga Shitai! - S2 - Ren')..createSync();
    for (var i = 1; i <= 3; i++) {
      File('${s2.path}\\[Judas] Chuunibyou S2 - 0$i.mkv').createSync();
    }

    scanner = LibraryScannerService(settings);
    scanner.update(library);
  });

  tearDown(() async {
    ServiceLocator.reset();
    if (baseTempDir.existsSync()) baseTempDir.deleteSync(recursive: true);
    await db.close();
  });

  group('Multi-season + movies torrent structure (Chuunibyou)', () {
    test('initial scan discovers the series with all nested collections', () async {
      await scanner.scanLocalLibrary();

      expect(library.series, hasLength(1));
      final series = library.series.single;
      expect(series.name, 'Love, Chunibyo & Other Delusions');

      // None of the subfolder names match the anchored season regex
      // ("...! - S1" is NOT a season name), so all collections are Folders
      expect(series.collections.whereType<Season>(), isEmpty);

      final names = series.collections.map((c) => c.name).toSet();
      expect(
        names,
        equals({
          '[Judas] Chuunibyou - Extras',
          '[Judas] Chuunibyou - Movies',
          'Movie 01 Extras',
          'Movie 02 Extras',
          '[Judas] Chuunibyou demo Koi ga Shitai! - S1',
          '[Judas] Chuunibyou demo Koi ga Shitai! - S2 - Ren',
        }),
      );

      final totalEpisodes = series.collections.expand((c) => c.episodes).length;
      expect(totalEpisodes, 13, reason: '3 extras + 2 movies + 1 + 1 movie extras + 3 + 3 episodes');
    });

    test('rescan of the unchanged structure is idempotent and does not throw', () async {
      await scanner.scanLocalLibrary();
      final before = library.series.single.collections.expand((c) => c.episodes).length;

      // Second scan goes through the existing-series diff path
      await scanner.scanLocalLibrary();

      expect(library.series, hasLength(1));
      final after = library.series.single.collections.expand((c) => c.episodes).length;
      expect(after, before);
    });

    test('series with this structure survives a DB round trip', () async {
      await scanner.scanLocalLibrary();

      final loaded = await db.seriesDao.loadAllSeries();
      expect(loaded, hasLength(1));

      final series = loaded.single;
      expect(series.collections, hasLength(6));
      expect(series.collections.expand((c) => c.episodes).length, 13);

      // Round-tripped collections must still all be Folders (name-based reconstruction)
      expect(series.collections.whereType<Season>(), isEmpty);
    });

    test('files sharing a metadata key are never silently dropped on rename', () async {
      // Two files with identical size+duration (here: both empty/mocked) used to
      // collapse in the rename-detection maps, dropping adds/deletes and leaving
      // phantom episodes pointing at dead paths
      final pairDir = Directory('${baseTempDir.path}\\Pair Series')..createSync();
      File('${pairDir.path}\\Pair - 01.mkv').createSync();
      File('${pairDir.path}\\Pair - 02.mkv').createSync();

      await scanner.scanLocalLibrary();
      final pair = library.series.firstWhere((s) => s.name == 'Pair Series');
      expect(pair.collections.expand((c) => c.episodes).length, 2);

      // Rename both files at once
      File('${pairDir.path}\\Pair - 01.mkv').renameSync('${pairDir.path}\\Pair Renamed - 01.mkv');
      File('${pairDir.path}\\Pair - 02.mkv').renameSync('${pairDir.path}\\Pair Renamed - 02.mkv');

      await scanner.scanLocalLibrary();

      final rescanned = library.series.firstWhere((s) => s.name == 'Pair Series');
      final episodes = rescanned.collections.expand((c) => c.episodes).toList();
      expect(episodes, hasLength(2), reason: 'no episode may be dropped or duplicated');
      for (final ep in episodes) {
        expect(File(ep.path.path).existsSync(), isTrue, reason: 'no phantom episodes pointing at dead paths (${ep.path.path})');
      }
    });

    test('renamed folders (the user workaround) also scan cleanly', () async {
      await scanner.scanLocalLibrary();

      // Simulate the user's fix: strip the "!"-bearing names down to plain ones
      Directory('${seriesDir.path}\\[Judas] Chuunibyou demo Koi ga Shitai! - S1') //
          .renameSync('${seriesDir.path}\\Season 1');
      Directory('${seriesDir.path}\\[Judas] Chuunibyou demo Koi ga Shitai! - S2 - Ren') //
          .renameSync('${seriesDir.path}\\Season 2');

      await scanner.scanLocalLibrary();

      final series = library.series.single;
      final seasons = series.collections.whereType<Season>().toList();
      expect(seasons, hasLength(2), reason: 'renamed folders now match the season pattern');
      expect(seasons.map((s) => s.seasonNumber).toSet(), {1, 2});
    });
  });
}
