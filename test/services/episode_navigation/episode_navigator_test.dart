import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/services/episode_navigation/episode_navigator.dart';
import 'package:miruryoiki/models/series.dart';
import 'package:miruryoiki/models/season.dart';
import 'package:miruryoiki/models/episode.dart';
import 'package:miruryoiki/utils/path.dart';
import 'package:flutter_anitomy/flutter_anitomy.dart';

class FakeParsedAnime extends Fake implements ParsedAnime {
  @override
  final String? episode;
  
  @override
  final String? episodeTitle;

  FakeParsedAnime({this.episode, this.episodeTitle});
}

void main() {
  late EpisodeNavigator navigator;
  late Series testSeries;
  late Season testSeason;
  late Episode testEpisode1;
  late Episode testEpisode2;

  setUp(() {
    navigator = EpisodeNavigator.instance;

    final path1 = PathString(r"M:\Videos\Series\Happy Sugar Life\S01\[HorribleSubs] Happy Sugar Life - 01 [1080p].mkv");
    testEpisode1 = Episode(
      id: 1,
      path: path1,
      name: 'Episode 1',
      episodeNumber: 1,
      parsedAnime: FakeParsedAnime(episode: '1'),
    );

    final path2 = PathString(r"M:\Videos\Series\Happy Sugar Life\S01\[HorribleSubs] Happy Sugar Life - 02 [1080p].mkv");
    testEpisode2 = Episode(
      id: 2,
      path: path2,
      name: 'Episode 2',
      episodeNumber: 2,
      parsedAnime: FakeParsedAnime(episode: '2'),
    );

    testSeason = Season(
      id: 1,
      name: 'Season 1',
      path: PathString(r"M:\Videos\Series\Happy Sugar Life\S01"),
      episodes: [testEpisode1, testEpisode2],
    );

    testSeries = Series(
      id: 1,
      name: 'Test Series',
      path: PathString(r"M:\Videos\Series\Happy Sugar Life"),
      seasons: [testSeason],
    );
  });

  group('EpisodeNavigator', () {
    test('findSeriesForEpisode finds correct series by ID', () {
      final result = navigator.findSeriesForEpisode(testEpisode1, [testSeries]);
      expect(result, equals(testSeries));
    });

    test('findSeriesForEpisode returns null if not found', () {
      final otherEpisode = Episode(
        id: 99,
        path: PathString('path/to/other.mkv'),
        name: 'Other',
        parsedAnime: FakeParsedAnime(episode: '1'),
      );
      final result = navigator.findSeriesForEpisode(otherEpisode, [testSeries]);
      expect(result, isNull);
    });

    test('getEpisodeById finds correct episode', () {
      final result = navigator.getEpisodeById(1, [testSeries]);
      expect(result, equals(testEpisode1));
    });

    test('findSeasonForEpisode finds correct season', () {
      final result = navigator.findSeasonForEpisode(testEpisode1, testSeries);
      expect(result, equals(testSeason));
    });
  });
}
