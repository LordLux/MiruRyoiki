import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:miruryoiki/database/database.dart';
import 'package:miruryoiki/database/daos/series_dao.dart';
import 'package:miruryoiki/models/series.dart';
import 'package:miruryoiki/models/episode.dart';
import 'package:miruryoiki/services/library/library_provider.dart';
import 'package:miruryoiki/settings.dart';
import 'package:miruryoiki/utils/path_utils.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeMiruRyoiokiSaveDirectory();
  late AppDatabase db;
  late SeriesDao dao;

  setUp(() {
    // in-memory for fast, isolated tests
    db = AppDatabase(NativeDatabase.memory());
    dao = SeriesDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('basic insert + load series', () async {
    final eps = [
      Episode(path: PathString('/tmp/s1/e1.mkv'), name: 'Episode 1'),
      Episode(path: PathString('/tmp/s1/e2.mkv'), name: 'Episode 2'),
    ];
    final series = Series(
      name: 'My Show',
      path: PathString('/tmp'),
      seasons: [
        Season(name: 'Season 1', path: PathString('/tmp/s1'), episodes: eps),
      ],
      relatedMedia: [],
      anilistMappings: [],
    );

    await dao.syncSeries(series);
    final id = await dao.getIdByPath(series.path);
    final loaded = await dao.loadFullSeries(id);

    expect(loaded, isNotNull);
    expect(loaded!.name, 'My Show');
    expect(loaded.seasons, hasLength(1));
    expect(loaded.seasons.first.episodes.map((e) => e.name), ['Episode 1', 'Episode 2']);
  });

  test('migrateFromJson does not crash on missing file', () async {
    // create a real Library object pointing at an empty temp dir
    final lib = Library(SettingsManager());
    // ... ensure no library.json present in your test dir ...
    await lib.migrateFromJson(); // should simply return, not throw
  });
}
