import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_anitomy/flutter_anitomy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/database/database.dart';
import 'package:miruryoiki/models/episode.dart';
import 'package:miruryoiki/services/di/dependency_injection.dart';
import 'package:miruryoiki/utils/path.dart';

void main() {
  late AppDatabase db;
  late int seasonId;

  setUp(() async {
    ServiceLocator.configureForTest();
    db = AppDatabase(NativeDatabase.memory());
    // EpisodesTable requires a valid seasonId FK, which itself requires a series.
    final seriesId = await db.into(db.seriesTable).insert(
          SeriesTableCompanion.insert(name: 'Test Series', path: PathString(r'M:\Series\Test')),
        );
    seasonId = await db.into(db.seasonsTable).insert(
          SeasonsTableCompanion.insert(seriesId: seriesId, name: 'Season 1', path: PathString(r'M:\Series\Test\S1')),
        );
  });

  tearDown(() async {
    await db.close();
    ServiceLocator.reset();
  });

  test('insertEpisode then getEpisodeByPath returns the inserted row', () async {
    await db.episodesDao.insertEpisode(EpisodesTableCompanion.insert(
      seasonId: seasonId,
      name: 'Episode 01.mkv',
      path: PathString(r'M:\Series\Test\S1\Episode 01.mkv'),
    ));

    final row = await db.episodesDao.getEpisodeByPath(PathString(r'M:\Series\Test\S1\Episode 01.mkv'));

    expect(row, isNotNull);
    expect(row!.name, 'Episode 01.mkv');
    expect(row.seasonId, seasonId);
  });

  test('getEpisodeByPath returns null for a path that was never inserted', () async {
    expect(await db.episodesDao.getEpisodeByPath(PathString(r'M:\Series\Test\S1\Nope.mkv')), isNull);
  });

  test('getEpisodesForSeason returns only episodes for that season', () async {
    final otherSeasonId = await db.into(db.seasonsTable).insert(
          SeasonsTableCompanion.insert(seriesId: 1, name: 'Season 2', path: PathString(r'M:\Series\Test\S2')),
        );
    await db.episodesDao.insertEpisode(EpisodesTableCompanion.insert(
      seasonId: seasonId,
      name: 'Episode 01.mkv',
      path: PathString(r'M:\Series\Test\S1\Episode 01.mkv'),
    ));
    await db.episodesDao.insertEpisode(EpisodesTableCompanion.insert(
      seasonId: otherSeasonId,
      name: 'Episode 01.mkv',
      path: PathString(r'M:\Series\Test\S2\Episode 01.mkv'),
    ));

    final episodes = await db.episodesDao.getEpisodesForSeason(seasonId);

    expect(episodes, hasLength(1));
    expect(episodes.single.seasonId, seasonId);
  });

  test('updateEpisode writes the given companion fields', () async {
    final id = await db.episodesDao.insertEpisode(EpisodesTableCompanion.insert(
      seasonId: seasonId,
      name: 'Episode 01.mkv',
      path: PathString(r'M:\Series\Test\S1\Episode 01.mkv'),
    ));

    final ok = await db.episodesDao.updateEpisode(id, const EpisodesTableCompanion(watched: Value(true), watchedPercentage: Value(1.0)));

    expect(ok, isTrue);
    final row = await db.episodesDao.getEpisodeByPath(PathString(r'M:\Series\Test\S1\Episode 01.mkv'));
    expect(row!.watched, isTrue);
    expect(row.watchedPercentage, 1.0);
  });

  test('updateEpisode returns false when no row matches the id', () async {
    expect(await db.episodesDao.updateEpisode(99999, const EpisodesTableCompanion(watched: Value(true))), isFalse);
  });

  test('deleteEpisode removes the row', () async {
    final id = await db.episodesDao.insertEpisode(EpisodesTableCompanion.insert(
      seasonId: seasonId,
      name: 'Episode 01.mkv',
      path: PathString(r'M:\Series\Test\S1\Episode 01.mkv'),
    ));

    final deleted = await db.episodesDao.deleteEpisode(id);

    expect(deleted, 1);
    expect(await db.episodesDao.getEpisodeByPath(PathString(r'M:\Series\Test\S1\Episode 01.mkv')), isNull);
  });

  test('fromRow/toCompanion round-trip an Episode model through watched/progress', () async {
    final episode = Episode(
      path: PathString(r'M:\Series\Test\S1\Episode 05.mkv'),
      name: 'Episode 05.mkv',
      episodeNumber: 5,
      watched: true,
      progress: 0.75,
      parsedAnime: ParsedAnime(),
    );

    final id = await db.episodesDao.insertEpisode(db.episodesDao.toCompanion(episode, seasonId));
    final row = await db.episodesDao.getEpisodeByPath(PathString(r'M:\Series\Test\S1\Episode 05.mkv'));
    final roundTripped = db.episodesDao.fromRow(row!);

    expect(row.id, id);
    expect(roundTripped.watched, isTrue);
    expect(roundTripped.progress, 0.75);
    expect(roundTripped.name, 'Episode 05.mkv');
  });
}
