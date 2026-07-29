import 'package:flutter_anitomy/flutter_anitomy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/models/episode.dart';
import 'package:miruryoiki/models/sonarr/sonarr_episode.dart';
import 'package:miruryoiki/models/ui_episode.dart';
import 'package:miruryoiki/settings.dart';
import 'package:miruryoiki/utils/path.dart';

/// Tests the [UIEpisode.displayTitle] source priority:
///   1. Sonarr title  2. AniList title (if enabled)  3. Anitomy-parsed name  4. cleaned filename.
/// Parsed filenames can be wrong, so trusted sources must win.

/// A local episode with an explicit parsed/AniList title, bypassing real Anitomy
/// parsing by supplying an (empty) [ParsedAnime].
Episode _localEp({String? parsedTitle, String? anilistTitle, String name = 'Show S01E05.mkv'}) => Episode(
      path: PathString('M:\\Series\\Show\\$name'),
      name: name,
      episodeNumber: 5,
      parsedTitle: parsedTitle,
      anilistTitle: anilistTitle,
      parsedAnime: ParsedAnime(),
    );

SonarrEpisode _sonarr(String title) => SonarrEpisode(
      id: 1,
      episodeNumber: 5,
      seasonNumber: 1,
      title: title,
      hasFile: true,
      monitored: true,
    );

UIEpisode _ui({Episode? local, SonarrEpisode? sonarr, String? anilistTitle}) => UIEpisode(
      episodeNumber: 5,
      localEpisode: local,
      sonarrEpisode: sonarr,
      anilistTitle: anilistTitle,
      state: EpisodeState.downloaded,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsManager settings;
  setUp(() {
    settings = SettingsManager();
    // SettingsManager is a singleton, so reset the flag to a known baseline each
    // test (otherwise the "enabled" test's value leaks into later tests).
    settings.enableAnilistEpisodeTitles = false;
    Manager.mockSettings = settings; // setter-only; keep our own ref to mutate it
  });
  tearDown(() => Manager.mockSettings = null);

  group('UIEpisode.displayTitle priority', () {
    test('Sonarr title wins over a (possibly mis-parsed) filename', () {
      final ep = _ui(local: _localEp(parsedTitle: 'Wrongly Parsed Name'), sonarr: _sonarr('The Real Title'));
      expect(ep.displayTitle, 'The Real Title');
    });

    test('AniList title is used when enabled and there is no Sonarr title', () {
      settings.enableAnilistEpisodeTitles = true;
      final ep = _ui(local: _localEp(parsedTitle: 'Parsed Name'), anilistTitle: 'AniList Name');
      expect(ep.displayTitle, 'AniList Name');
    });

    test('AniList title is ignored when the setting is disabled', () {
      // enableAnilistEpisodeTitles defaults to false.
      final ep = _ui(local: _localEp(parsedTitle: 'Parsed Name'), anilistTitle: 'AniList Name');
      expect(ep.displayTitle, 'Parsed Name');
    });

    test('Anitomy-parsed name is used when there is no Sonarr/AniList title', () {
      final ep = _ui(local: _localEp(parsedTitle: 'Parsed Name'));
      expect(ep.displayTitle, 'Parsed Name');
    });

    test('cleaned filename is the last resort when nothing else parsed a name', () {
      final local = _localEp(parsedTitle: null, name: 'Show S01E05.mkv');
      final ep = _ui(local: local);
      expect(ep.displayTitle, local.cleanedName);
    });

    test('falls back to "Episode N" when there is no local file', () {
      final ep = _ui(); // released/future episode, no localEpisode
      expect(ep.displayTitle, 'Episode 5');
    });
  });
}
