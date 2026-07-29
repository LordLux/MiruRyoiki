import 'package:drift/native.dart';
import 'package:flutter_anitomy/flutter_anitomy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/database/database.dart';
import 'package:miruryoiki/database/daos/series_dao.dart';
import 'package:miruryoiki/models/anilist/mapping.dart';
import 'package:miruryoiki/models/episode.dart';
import 'package:miruryoiki/models/season.dart';
import 'package:miruryoiki/models/series.dart';
import 'package:miruryoiki/utils/path.dart';

// Every fixture passes an explicit (empty) parsedAnime to skip Episode's
// native anitomy FFI parse — DAO behavior under test doesn't depend on it,
// and hitting real FFI from a plain `flutter test` run is unnecessary here.
final _emptyParsed = ParsedAnime();

Episode _makeEpisode({
  int? id,
  String name = 'Episode 01.mkv',
  String path = r'M:\Series\Test\S1\Episode 01.mkv',
  int? episodeNumber = 1,
  bool watched = false,
  double progress = 0.0,
}) {
  return Episode(
    id: id,
    path: PathString(path),
    name: name,
    episodeNumber: episodeNumber,
    watched: watched,
    progress: progress,
    parsedAnime: _emptyParsed,
  );
}

Season _makeSeason({
  String name = 'Season 1',
  String path = r'M:\Series\Test\S1',
  List<Episode>? episodes,
  int seasonNumber = 1,
}) {
  return Season(
    name: name,
    path: PathString(path),
    episodes: episodes ?? [_makeEpisode()],
    seasonNumber: seasonNumber,
  );
}

AnilistMapping _makeMapping({
  int anilistId = 100,
  String? title,
  String localPath = r'M:\Series\Test',
}) {
  return AnilistMapping(
    localPath: PathString(localPath),
    anilistId: anilistId,
    title: title ?? 'Mapping $anilistId',
  );
}

Series _makeSeries({
  String name = 'Test Series',
  String path = r'M:\Series\Test',
  List<EpisodeCollection>? collections,
  List<AnilistMapping>? anilistMappings,
}) {
  return Series(
    name: name,
    path: PathString(path),
    collections: collections ?? [_makeSeason()],
    anilistMappings: anilistMappings ?? const [],
  );
}

void main() {
  late AppDatabase db;
  late SeriesDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = db.seriesDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('syncSeries — insert path', () {
    test('inserts a new series with its season and episode', () async {
      final series = _makeSeries();

      await dao.syncSeries(series);

      final loaded = await dao.loadAllSeries();
      expect(loaded, hasLength(1));
      expect(loaded.single.name, 'Test Series');
      expect(loaded.single.collections, hasLength(1));
      expect(loaded.single.collections.single.episodes, hasLength(1));
      expect(loaded.single.collections.single.episodes.single.name, 'Episode 01.mkv');
    });

    test('inserts anilist mappings alongside the series', () async {
      final series = _makeSeries(anilistMappings: [_makeMapping(anilistId: 42, title: 'Attack on Titan')]);

      await dao.syncSeries(series);

      final loaded = await dao.loadAllSeries();
      expect(loaded.single.anilistMappings, hasLength(1));
      expect(loaded.single.anilistMappings.single.anilistId, 42);
      expect(loaded.single.anilistMappings.single.title, 'Attack on Titan');
    });

    test('getIdByPath resolves the row id for the path just inserted', () async {
      final series = _makeSeries(path: r'M:\Series\Unique');
      await dao.syncSeries(series);

      final id = await dao.getIdByPath(PathString(r'M:\Series\Unique'));

      expect(id, isNot(-1));
    });

    test('getIdByPath returns -1 for a path that was never inserted', () async {
      final id = await dao.getIdByPath(PathString(r'M:\Series\Nonexistent'));
      expect(id, -1);
    });
  });

  group('syncSeries — update path (re-sync is idempotent and non-destructive)', () {
    test('re-syncing the same series does not duplicate the row', () async {
      final series = _makeSeries();
      await dao.syncSeries(series);
      await dao.syncSeries(series);

      final loaded = await dao.loadAllSeries();
      expect(loaded, hasLength(1));
    });

    test('re-syncing with an added episode adds it without touching existing episodes', () async {
      final series = _makeSeries(
        collections: [
          _makeSeason(episodes: [_makeEpisode(name: 'Episode 01.mkv', path: r'M:\Series\Test\S1\Episode 01.mkv')])
        ],
      );
      await dao.syncSeries(series);

      final updated = _makeSeries(
        collections: [
          _makeSeason(episodes: [
            _makeEpisode(name: 'Episode 01.mkv', path: r'M:\Series\Test\S1\Episode 01.mkv'),
            _makeEpisode(name: 'Episode 02.mkv', path: r'M:\Series\Test\S1\Episode 02.mkv', episodeNumber: 2),
          ])
        ],
      );
      await dao.syncSeries(updated);

      final loaded = await dao.loadAllSeries();
      expect(loaded.single.collections.single.episodes, hasLength(2));
    });

    test('re-syncing without a previously-present episode deletes it (matches by path)', () async {
      final series = _makeSeries(
        collections: [
          _makeSeason(episodes: [
            _makeEpisode(name: 'Episode 01.mkv', path: r'M:\Series\Test\S1\Episode 01.mkv'),
            _makeEpisode(name: 'Episode 02.mkv', path: r'M:\Series\Test\S1\Episode 02.mkv', episodeNumber: 2),
          ])
        ],
      );
      await dao.syncSeries(series);

      final shrunk = _makeSeries(
        collections: [
          _makeSeason(episodes: [_makeEpisode(name: 'Episode 01.mkv', path: r'M:\Series\Test\S1\Episode 01.mkv')])
        ],
      );
      await dao.syncSeries(shrunk);

      final loaded = await dao.loadAllSeries();
      expect(loaded.single.collections.single.episodes, hasLength(1));
      expect(loaded.single.collections.single.episodes.single.name, 'Episode 01.mkv');
    });

    test('re-syncing without a previously-present season deletes it and its episodes', () async {
      final series = _makeSeries(collections: [_makeSeason(name: 'Season 1', path: r'M:\Series\Test\S1')]);
      await dao.syncSeries(series);

      final withoutSeason = _makeSeries(collections: const []);
      await dao.syncSeries(withoutSeason);

      final loaded = await dao.loadAllSeries();
      expect(loaded.single.collections, isEmpty);
    });

    test('re-syncing without a previously-present mapping removes it', () async {
      final series = _makeSeries(anilistMappings: [_makeMapping(anilistId: 1), _makeMapping(anilistId: 2)]);
      await dao.syncSeries(series);

      final withoutOne = _makeSeries(anilistMappings: [_makeMapping(anilistId: 2)]);
      await dao.syncSeries(withoutOne);

      final loaded = await dao.loadAllSeries();
      expect(loaded.single.anilistMappings.map((m) => m.anilistId), [2]);
    });

    test('updating watched/progress on an existing episode persists via re-sync', () async {
      final series = _makeSeries(
        collections: [
          _makeSeason(episodes: [_makeEpisode(name: 'Episode 01.mkv', path: r'M:\Series\Test\S1\Episode 01.mkv', watched: false, progress: 0.0)])
        ],
      );
      await dao.syncSeries(series);

      final watched = _makeSeries(
        collections: [
          _makeSeason(episodes: [_makeEpisode(name: 'Episode 01.mkv', path: r'M:\Series\Test\S1\Episode 01.mkv', watched: true, progress: 1.0)])
        ],
      );
      await dao.syncSeries(watched);

      final loaded = await dao.loadAllSeries();
      final ep = loaded.single.collections.single.episodes.single;
      expect(ep.watched, isTrue);
      expect(ep.progress, 1.0);
    });
  });

  group('syncSeriesBatch', () {
    test('syncs multiple series in a single transaction', () async {
      final a = _makeSeries(name: 'Series A', path: r'M:\Series\A');
      final b = _makeSeries(name: 'Series B', path: r'M:\Series\B');

      await dao.syncSeriesBatch([a, b]);

      final loaded = await dao.loadAllSeries();
      expect(loaded.map((s) => s.name), containsAll(['Series A', 'Series B']));
    });

    test('an empty batch is a no-op', () async {
      await dao.syncSeriesBatch([]);
      expect(await dao.loadAllSeries(), isEmpty);
    });
  });

  group('deleteSeriesRow', () {
    test('cascades to delete seasons, episodes, and mappings (ON DELETE CASCADE)', () async {
      final series = _makeSeries(anilistMappings: [_makeMapping(anilistId: 7)]);
      await dao.syncSeries(series);
      final id = await dao.getIdByPath(PathString(r'M:\Series\Test'));

      await dao.deleteSeriesRow(id);

      final loaded = await dao.loadAllSeries();
      expect(loaded, isEmpty);
    });
  });

  group('loadFullSeries vs loadAllSeries — bulk-load parity', () {
    test('loadAllSeries produces the same shape as loadFullSeries for a single series', () async {
      final series = _makeSeries(anilistMappings: [_makeMapping(anilistId: 9)]);
      await dao.syncSeries(series);
      final id = await dao.getIdByPath(PathString(r'M:\Series\Test'));

      final single = await dao.loadFullSeries(id);
      final bulk = await dao.loadAllSeries();

      expect(single, isNotNull);
      expect(bulk.single.name, single!.name);
      expect(bulk.single.collections.single.episodes.length, single.collections.single.episodes.length);
      expect(bulk.single.anilistMappings.single.anilistId, single.anilistMappings.single.anilistId);
    });

    test('loadFullSeries returns null for an id that does not exist', () async {
      expect(await dao.loadFullSeries(99999), isNull);
    });
  });

  group('updateEpisodeProgress', () {
    test('updates progress and watched status by episode id directly', () async {
      final series = _makeSeries();
      await dao.syncSeries(series);
      final loaded = await dao.loadAllSeries();
      final episodeId = loaded.single.collections.single.episodes.single.id!;

      await dao.updateEpisodeProgress(episodeId, progress: 0.5, watched: false);

      final reloaded = await dao.loadAllSeries();
      final ep = reloaded.single.collections.single.episodes.single;
      expect(ep.progress, 0.5);
      expect(ep.watched, isFalse);
    });
  });
}
