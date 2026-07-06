import 'package:drift/native.dart';
import 'package:flutter_anitomy/flutter_anitomy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/database/database.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/models/episode.dart';
import 'package:miruryoiki/models/season.dart';
import 'package:miruryoiki/models/series.dart';
import 'package:miruryoiki/services/di/dependency_injection.dart';
import 'package:miruryoiki/services/library/library_provider.dart';
import 'package:miruryoiki/settings.dart';
import 'package:miruryoiki/utils/path.dart';

Episode _ep(String name, {int? number, bool watched = false}) => Episode(
      name: name,
      path: PathString('M:/S/Test/S01/$name'),
      episodeNumber: number,
      watched: watched,
      parsedAnime: ParsedAnime(),
    );

Series _seriesWith(List<Episode> eps) => Series(
      name: 'Test',
      path: PathString('M:/S/Test'),
      collections: [
        Season(name: 'Season 1', path: PathString('M:/S/Test/S01'), episodes: eps, seasonNumber: 1),
      ],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Library library;

  setUp(() {
    ServiceLocator.configureForTest();
    Manager.mockSettings = SettingsManager();
    db = AppDatabase(NativeDatabase.memory());
    library = Library(SettingsManager(), db);
  });

  tearDown(() async {
    ServiceLocator.reset();
    await db.close();
  });

  group('setProgressUpToEpisode', () {
    test('marks 1..N watched and N+1..end unwatched within the collection', () async {
      final eps = [
        _ep('e1.mkv', number: 1, watched: false),
        _ep('e2.mkv', number: 2, watched: false),
        _ep('e3.mkv', number: 3, watched: true), // pre-existing, should stay watched
        _ep('e4.mkv', number: 4, watched: true), // after pivot -> should be cleared
        _ep('e5.mkv', number: 5, watched: true),
      ];
      final series = _seriesWith(eps);
      await library.addSeries(series);

      library.setProgressUpToEpisode(eps[2], series); // pivot = e3

      expect(eps.map((e) => e.watched).toList(), [true, true, true, false, false]);
      expect(eps[0].progress, 1.0);
      expect(eps[3].progress, 0.0); // overrideProgress cleared the tail
    });

    test('orders by episodeNumber even when the list is shuffled', () async {
      final e1 = _ep('e1.mkv', number: 1);
      final e2 = _ep('e2.mkv', number: 2);
      final e3 = _ep('e3.mkv', number: 3);
      final series = _seriesWith([e3, e1, e2]); // out of order in the list

      await library.addSeries(series);
      library.setProgressUpToEpisode(e2, series); // up to episode 2

      expect(e1.watched, isTrue);
      expect(e2.watched, isTrue);
      expect(e3.watched, isFalse);
    });

    test('falls back to list order when episode numbers are null', () async {
      final a = _ep('a.mkv', number: null);
      final b = _ep('b.mkv', number: null);
      final c = _ep('c.mkv', number: null);
      final d = _ep('d.mkv', number: null);
      final series = _seriesWith([a, b, c, d]);

      await library.addSeries(series);
      library.setProgressUpToEpisode(c, series);

      expect([a.watched, b.watched, c.watched, d.watched], [true, true, true, false]);
    });
  });
}
