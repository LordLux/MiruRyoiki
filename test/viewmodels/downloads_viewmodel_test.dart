import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/services/downloads/torrent_client.dart';
import 'package:miruryoiki/viewmodels/downloads_viewmodel.dart';

/// Pure-logic tests for [DownloadsViewModel.filterAndSort]
TorrentInfo _t(
  String name, {
  TorrentState state = TorrentState.downloading,
  double progress = 0.5,
  int size = 1000,
  DateTime? addedOn,
}) =>
    TorrentInfo(hash: name, name: name, state: state, progress: progress, size: size, addedOn: addedOn);

void main() {
  final torrents = [
    _t('b-seeding', state: TorrentState.seeding, addedOn: DateTime(2024, 1, 2)),
    _t('a-downloading', state: TorrentState.downloading, addedOn: DateTime(2024, 1, 1)),
    _t('c-paused', state: TorrentState.paused, progress: 0.2, size: 500),
    _t('d-error', state: TorrentState.error, progress: 0.9, size: 2000),
  ];

  group('filtering', () {
    test('all keeps everything', () {
      expect(DownloadsViewModel.filterAndSort(torrents, DownloadFilter.all, DownloadSortMode.name, true).length, 4);
    });

    test('running keeps downloading + seeding', () {
      final result = DownloadsViewModel.filterAndSort(torrents, DownloadFilter.running, DownloadSortMode.name, true);
      expect(result.map((t) => t.name).toList(), ['a-downloading', 'b-seeding']);
    });

    test('stopped keeps paused only', () {
      final result = DownloadsViewModel.filterAndSort(torrents, DownloadFilter.stopped, DownloadSortMode.name, true);
      expect(result.map((t) => t.name).toList(), ['c-paused']);
    });
  });

  group('sorting', () {
    test('status sort follows priority (downloading < seeding < error < paused)', () {
      final result = DownloadsViewModel.filterAndSort(torrents, DownloadFilter.all, DownloadSortMode.status, true);
      expect(result.map((t) => t.name).toList(), ['a-downloading', 'b-seeding', 'd-error', 'c-paused']);
    });

    test('descending inverts the comparison', () {
      final asc = DownloadsViewModel.filterAndSort(torrents, DownloadFilter.all, DownloadSortMode.name, true);
      final desc = DownloadsViewModel.filterAndSort(torrents, DownloadFilter.all, DownloadSortMode.name, false);
      expect(desc, asc.reversed.toList());
    });

    test('size sorts largest first when ascending (matches original behavior)', () {
      final result = DownloadsViewModel.filterAndSort(torrents, DownloadFilter.all, DownloadSortMode.size, true);
      expect(result.first.name, 'd-error'); // 2000 bytes
      expect(result.last.name, 'c-paused'); // 500 bytes
    });

    test('does not mutate the input list', () {
      final input = List.of(torrents);
      DownloadsViewModel.filterAndSort(input, DownloadFilter.all, DownloadSortMode.name, true);
      expect(input.map((t) => t.name).toList(), torrents.map((t) => t.name).toList());
    });
  });
}
