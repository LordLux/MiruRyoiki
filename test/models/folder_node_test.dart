import 'package:flutter_anitomy/flutter_anitomy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/models/anilist/mapping.dart';
import 'package:miruryoiki/models/episode.dart';
import 'package:miruryoiki/models/folder_node.dart';
import 'package:miruryoiki/models/season.dart';
import 'package:miruryoiki/models/series.dart';
import 'package:miruryoiki/services/di/dependency_injection.dart';
import 'package:miruryoiki/settings.dart';
import 'package:miruryoiki/utils/path.dart';

const _root = r'M:\Series\Test';

Episode _ep(String path, {bool watched = false, int? number = 1}) => Episode(
      name: path.split(r'\').last,
      path: PathString(path),
      episodeNumber: number,
      watched: watched,
      parsedAnime: ParsedAnime(),
    );

Season _season(String path, int number, List<Episode> eps) => Season(
      name: 'Season $number',
      path: PathString(path),
      episodes: eps,
      seasonNumber: number,
    );

Folder _folder(String name, String path, List<Episode> eps) => Folder(
      name: name,
      path: PathString(path),
      episodes: eps,
    );

Series _series(List<EpisodeCollection> collections, {List<AnilistMapping> mappings = const []}) => Series(
      name: 'Test',
      path: PathString(_root),
      collections: collections,
      anilistMappings: mappings,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    ServiceLocator.configureForTest();
    Manager.mockSettings = SettingsManager();
  });

  tearDownAll(() => ServiceLocator.reset());

  group('buildFolderTree', () {
    test('flat seasons become ordered root children with no direct episodes', () {
      final s = _series([
        _season(r'M:\Series\Test\S02', 2, [_ep(r'M:\Series\Test\S02\E01.mkv')]),
        _season(r'M:\Series\Test\S01', 1, [_ep(r'M:\Series\Test\S01\E01.mkv'), _ep(r'M:\Series\Test\S01\E02.mkv')]),
      ]);

      final root = buildFolderTree(s);

      expect(root.isRoot, isTrue);
      expect(root.directEpisodes, isEmpty);
      expect(root.children.map((c) => c.seasonNumber), [1, 2]); // sorted ascending
      expect(root.totalCount, 3); // 2 + 1 across the subtree
    });

    test('uncategorized folder at root becomes root direct episodes, not a child', () {
      final s = _series([
        _season(r'M:\Series\Test\S01', 1, [_ep(r'M:\Series\Test\S01\E01.mkv')]),
        _folder(Folder.uncategorizedName, _root, [_ep(r'M:\Series\Test\loose.mkv')]),
      ]);

      final root = buildFolderTree(s);

      expect(root.directEpisodes.length, 1);
      expect(root.directEpisodes.first.name, 'loose.mkv');
      // only the season is a child; uncategorized is folded into the root
      expect(root.children.length, 1);
      expect(root.children.single.isSeason, isTrue);
    });

    test('synthesizes intermediate container nodes with no collection', () {
      // Only a deep collection exists; Extras has no collection of its own.
      final s = _series([
        _folder('BD', r'M:\Series\Test\Extras\BD', [_ep(r'M:\Series\Test\Extras\BD\ep.mkv')]),
      ]);

      final root = buildFolderTree(s);

      expect(root.children.length, 1);
      final extras = root.children.single;
      expect(extras.displayName, 'Extras');
      expect(extras.collection, isNull); // synthetic intermediate
      expect(extras.directEpisodes, isEmpty);
      expect(extras.children.single.displayName, 'BD');
      expect(extras.subtreeEpisodes.length, 1); // recursive
    });

    test('recursive progress aggregates the whole subtree', () {
      final s = _series([
        _folder('BD', r'M:\Series\Test\Extras\BD', [
          _ep(r'M:\Series\Test\Extras\BD\e1.mkv', watched: true),
          _ep(r'M:\Series\Test\Extras\BD\e2.mkv', watched: true),
        ]),
        _folder('CD', r'M:\Series\Test\Extras\CD', [
          _ep(r'M:\Series\Test\Extras\CD\e3.mkv'),
          _ep(r'M:\Series\Test\Extras\CD\e4.mkv'),
        ]),
      ]);

      final extras = buildFolderTree(s).children.single;
      expect(extras.displayName, 'Extras');
      expect(extras.watchedCount, 2);
      expect(extras.totalCount, 4);
      expect(extras.watchedPercentage, 0.5);
    });

    test('mapping attaches to the matching folder node', () {
      final s = _series(
        [_season(r'M:\Series\Test\S01', 1, [_ep(r'M:\Series\Test\S01\E01.mkv')])],
        mappings: [
          AnilistMapping(localPath: PathString(r'M:\Series\Test\S01'), anilistId: 42, title: 'S1'),
        ],
      );

      final season = buildFolderTree(s).children.single;
      expect(season.isLinked, isTrue);
      expect(season.mapping!.anilistId, 42);
    });
  });

  group('resolveNode', () {
    test('resolves a deeply nested node by path', () {
      final s = _series([
        _folder('BD', r'M:\Series\Test\Extras\BD', [_ep(r'M:\Series\Test\Extras\BD\ep.mkv')]),
      ]);

      final node = resolveNode(s, PathString(r'M:\Series\Test\Extras\BD'));
      expect(node, isNotNull);
      expect(node!.displayName, 'BD');

      final intermediate = resolveNode(s, PathString(r'M:\Series\Test\Extras'));
      expect(intermediate, isNotNull);
      expect(intermediate!.collection, isNull);

      expect(resolveNode(s, PathString(r'M:\Series\Test\DoesNotExist')), isNull);
    });
  });
}
