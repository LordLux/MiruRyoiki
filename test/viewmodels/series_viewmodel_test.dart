import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/enums.dart';
import 'package:miruryoiki/models/anilist/mapping.dart';
import 'package:miruryoiki/models/episode.dart';
import 'package:miruryoiki/models/season.dart';
import 'package:miruryoiki/models/series.dart';
import 'package:miruryoiki/models/sonarr/sonarr_episode.dart';
import 'package:miruryoiki/utils/path.dart';
import 'package:miruryoiki/viewmodels/series_viewmodel.dart';

/// Pure-logic tests for [SeriesViewModel]: location/one-time-init lifecycle,
/// view-type intent, series-derived getters, and Sonarr target-filter safety.
/// Data loading (AniList / Sonarr network) is not exercised here.

const _root = r'M:\Series\Test';
const _seasonPath = r'M:\Series\Test\S01';
const _folderPath = r'M:\Series\Test\Extras';

Series _makeSeries({List<AnilistMapping> mappings = const []}) => Series(
      name: 'Test Series',
      path: PathString(_root),
      collections: const [],
      anilistMappings: mappings,
    );

/// A series with a numbered [Season] and a plain [Folder], both directly under
/// the root, for exercising node-target-dependent getters.
Series _makeSeriesWithCollections() => Series(
      name: 'Test Series',
      path: PathString(_root),
      collections: [
        Season(name: 'Season 1', path: PathString(_seasonPath), episodes: const <Episode>[], seasonNumber: 1),
        Folder(name: 'Extras', path: PathString(_folderPath), episodes: const <Episode>[]),
      ],
    );

AnilistMapping _mapping(int id) => AnilistMapping(
      localPath: PathString(_root),
      anilistId: id,
      title: 'Mapping $id',
    );

SonarrEpisode _sonarr(int id, int season, int episode) => SonarrEpisode(
      id: id,
      episodeNumber: episode,
      seasonNumber: season,
      title: 'S${season}E$episode',
      hasFile: false,
      monitored: true,
    );

void main() {
  group('drill-down node stack', () {
    test('a fresh VM needs node init exactly once', () {
      final vm = SeriesViewModel();

      // First consume runs; subsequent consumes are no-ops until re-armed.
      expect(vm.consumeNodeInit(), isTrue);
      expect(vm.consumeNodeInit(), isFalse);
      expect(vm.nodeInitialized, isTrue);
    });

    test('openSeries starts at the root with an empty stack', () {
      final vm = SeriesViewModel();
      vm.openSeries(PathString(r'M:\Series\Test'));
      expect(vm.seriesPath, PathString(r'M:\Series\Test'));
      expect(vm.isAtRoot, isTrue);
      expect(vm.canPopNode, isFalse);
      expect(vm.currentNodePath, isNull);
    });

    test('openSeries clears view-type and Sonarr state from the previous series', () {
      final vm = SeriesViewModel();
      // Leftover state from a previously opened series.
      vm.onViewTypeChanged(ViewType.detailedList);
      vm.debugSetSonarrEpisodes([_sonarr(1, 1, 1)]);
      expect(vm.currentViewType, ViewType.detailedList);
      expect(vm.sonarrEpisodes, isNotNull);

      vm.openSeries(PathString(r'M:\Series\Other'));

      expect(vm.currentViewType, ViewType.grid);
      expect(vm.sonarrEpisodes, isNull);
      expect(vm.isAtRoot, isTrue);
    });

    test('openSeries can restore a saved drill-down stack', () {
      final vm = SeriesViewModel();
      vm.openSeries(PathString(r'M:\A'), initialStack: [PathString(r'M:\A\S01')]);
      expect(vm.currentNodePath, PathString(r'M:\A\S01'));
      expect(vm.canPopNode, isTrue);
    });

    test('pushNode drills in, re-arms node init, and notifies', () {
      final vm = SeriesViewModel();
      vm.openSeries(PathString(r'M:\A'));
      expect(vm.consumeNodeInit(), isTrue); // arm consumed at root

      var notified = 0;
      vm.addListener(() => notified++);

      vm.pushNode(PathString(r'M:\A\S01'));

      expect(vm.currentNodePath, PathString(r'M:\A\S01'));
      expect(vm.isAtRoot, isFalse);
      expect(notified, 1);
      expect(vm.consumeNodeInit(), isTrue); // re-armed by the drill-down
    });

    test('popNode walks back up one level, then reports root', () {
      final vm = SeriesViewModel();
      vm.openSeries(PathString(r'M:\A'));
      vm.pushNode(PathString(r'M:\A\S01'));
      vm.pushNode(PathString(r'M:\A\S01\Extras'));

      expect(vm.popNode(), isTrue);
      expect(vm.currentNodePath, PathString(r'M:\A\S01'));

      expect(vm.popNode(), isTrue);
      expect(vm.isAtRoot, isTrue);

      // Already at root → nothing to pop.
      expect(vm.popNode(), isFalse);
    });

    test('nodeStack reflects the drill-down path', () {
      final vm = SeriesViewModel();
      vm.openSeries(PathString(r'M:\A'));
      vm.pushNode(PathString(r'M:\A\S01'));
      vm.pushNode(PathString(r'M:\A\S01\Extras'));
      expect(vm.nodeStack.map((p) => p.path).toList(), [
        PathString(r'M:\A\S01').path,
        PathString(r'M:\A\S01\Extras').path,
      ]);
    });

    test('restoreNodeStack replaces the stack and is a no-op when unchanged', () {
      final vm = SeriesViewModel();
      vm.openSeries(PathString(r'M:\A'));

      var notified = 0;
      vm.addListener(() => notified++);

      vm.restoreNodeStack([PathString(r'M:\A\S01')]);
      expect(vm.currentNodePath, PathString(r'M:\A\S01'));
      expect(notified, 1);

      // Same stack again → no notification.
      vm.restoreNodeStack([PathString(r'M:\A\S01')]);
      expect(notified, 1);
    });
  });

  group('view type', () {
    test('defaults to grid', () {
      expect(SeriesViewModel().currentViewType, ViewType.grid);
    });

    test('onViewTypeChanged updates the type and notifies', () {
      final vm = SeriesViewModel();
      var notified = 0;
      vm.addListener(() => notified++);

      vm.onViewTypeChanged(ViewType.detailedList);

      expect(vm.currentViewType, ViewType.detailedList);
      expect(notified, 1);
    });
  });

  group('series-derived getters', () {
    test('anilistIDs dedups and preserves order', () {
      final vm = SeriesViewModel();
      vm.syncSeries(_makeSeries(mappings: [_mapping(1), _mapping(1), _mapping(2)]));
      expect(vm.anilistIDs, [1, 2]);
    });

    test('anilistIDs is empty when no series is synced', () {
      expect(SeriesViewModel().anilistIDs, isEmpty);
    });

    test('syncSeries exposes the current series', () {
      final vm = SeriesViewModel();
      final series = _makeSeries();
      vm.syncSeries(series);
      expect(vm.cachedSeries, same(series));
    });
  });

  group('node-dependent getters with no resolved node', () {
    test('isMappingMode is false and mapping/target are null at the root', () {
      final vm = SeriesViewModel();
      expect(vm.isMappingMode, isFalse);
      expect(vm.cachedMapping, isNull);
      expect(vm.cachedTarget, isNull);
    });

    test('gridEpisodes and file mappings are empty', () {
      final vm = SeriesViewModel();
      expect(vm.gridEpisodes, isEmpty);
      expect(vm.fileMappingsAtNode, isEmpty);
    });

    test('sonarrEpisodesForTarget is null without a target', () {
      final vm = SeriesViewModel();
      expect(vm.sonarrEpisodes, isNull);
      expect(vm.sonarrEpisodesForTarget, isNull);
    });
  });

  group('sonarrEpisodesForTarget — season scoping', () {
    test('a season node filters episodes to that season only', () {
      final vm = SeriesViewModel();
      final series = _makeSeriesWithCollections();
      vm.syncSeries(series);
      vm.openSeries(PathString(_root), initialStack: [PathString(_seasonPath)]);
      vm.resolveNode(series); // resolves _resolvedNode to the S01 season node

      vm.debugSetSonarrEpisodes([_sonarr(1, 1, 1), _sonarr(2, 1, 2), _sonarr(3, 2, 1)]);

      final filtered = vm.sonarrEpisodesForTarget;
      expect(filtered, isNotNull);
      expect(filtered!.map((e) => e.id), [1, 2]); // season 2 (id 3) excluded
    });

    test('a non-season folder node returns all episodes', () {
      final vm = SeriesViewModel();
      final series = _makeSeriesWithCollections();
      vm.syncSeries(series);
      vm.openSeries(PathString(_root), initialStack: [PathString(_folderPath)]);
      vm.resolveNode(series);

      vm.debugSetSonarrEpisodes([_sonarr(1, 1, 1), _sonarr(3, 2, 1)]);

      expect(vm.sonarrEpisodesForTarget!.map((e) => e.id), [1, 3]);
    });

    test('the series root (no collection target) returns null even when set', () {
      final vm = SeriesViewModel();
      final series = _makeSeriesWithCollections();
      vm.syncSeries(series);
      vm.openSeries(PathString(_root));
      vm.resolveNode(series);

      vm.debugSetSonarrEpisodes([_sonarr(1, 1, 1)]);

      expect(vm.sonarrEpisodesForTarget, isNull);
    });
  });
}
