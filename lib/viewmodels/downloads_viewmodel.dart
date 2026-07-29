import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';

import '../services/downloads/torrent_client.dart';
import '../services/downloads/torrent_manager.dart';
import '../services/navigation/show_info.dart';
import '../utils/logging.dart';
import 'disposable_view_model.dart';

enum DownloadSortMode { status, name, addedOn, progress, size }

enum DownloadFilter { all, downloading, seeding, completed, running, stopped, stalled, errored }

/// ViewModel for the Downloads screen.
///
/// Owns the torrent list, polling, filter/sort state, and pause/resume actions against [TorrentManager]'s torrent client.
///
/// Registered app-wide via `ChangeNotifierProvider` in `main.dart`.
class DownloadsViewModel extends DisposableViewModel {
  List<TorrentInfo> _torrents = [];
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;

  DownloadSortMode _sortMode = DownloadSortMode.status;
  bool _sortAscending = true;
  DownloadFilter _filter = DownloadFilter.all;

  List<TorrentInfo> get torrents => _torrents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DownloadSortMode get sortMode => _sortMode;
  bool get sortAscending => _sortAscending;
  DownloadFilter get filter => _filter;

  int get downloadingCount => _torrents.where((t) => t.state == TorrentState.downloading).length;
  int get seedingCount => _torrents.where((t) => t.state == TorrentState.seeding).length;

  /// The torrents as the list should display them (filtered + sorted)
  List<TorrentInfo> get sortedTorrents => filterAndSort(_torrents, _filter, _sortMode, _sortAscending);

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Polling

  /// Starts the initial fetch + 3s refresh poll.
  ///
  /// Called from the screen's initState; Idempotent.
  void startPolling() {
    fetchTorrents();
    _refreshTimer ??= Timer.periodic(const Duration(seconds: 3), (_) => fetchTorrents(silent: true));
  }

  /// Stops the refresh poll
  void stopPolling() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // Data access / actions

  Future<void> fetchTorrents({bool silent = false}) async {
    final client = TorrentManager.torrentClient;
    if (client == null) return;

    if (!silent) {
      _isLoading = true;
      _error = null;
      notifySafe();
    }

    try {
      final list = await client.listTorrents();
      _torrents = list;
      _isLoading = false;
      _error = null;
      notifySafe();
    } catch (e) {
      _isLoading = false;
      if (!silent) {
        _error = e.toString();
        logDebug('Failed to fetch torrents: $e');
      }
      notifySafe();
    }
  }

  Future<void> pauseTorrent(TorrentInfo torrent) async {
    final client = TorrentManager.torrentClient;
    if (client == null) return;
    try {
      await client.pauseTorrent(torrent.hash);
      fetchTorrents(silent: true);
    } catch (e) {
      snackBar('Failed to pause: $e', severity: InfoBarSeverity.error);
    }
  }

  Future<void> resumeTorrent(TorrentInfo torrent) async {
    final client = TorrentManager.torrentClient;
    if (client == null) return;
    try {
      await client.resumeTorrent(torrent.hash);
      fetchTorrents(silent: true);
    } catch (e) {
      snackBar('Failed to resume: $e', severity: InfoBarSeverity.error);
    }
  }

  // UI intents

  void setSortMode(DownloadSortMode mode) {
    if (_sortMode == mode) return;
    _sortMode = mode;
    notifySafe();
  }

  void toggleSortDirection() {
    _sortAscending = !_sortAscending;
    notifySafe();
  }

  void setFilter(DownloadFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifySafe();
  }

  // Pure helpers

  static const statusPriority = {
    TorrentState.downloading: 0,
    TorrentState.seeding: 1,
    TorrentState.stalled: 2,
    TorrentState.error: 3,
    TorrentState.paused: 4,
    TorrentState.queued: 5,
    TorrentState.checking: 6,
    TorrentState.completed: 7,
    TorrentState.unknown: 8,
  };

  /// Filters by [filter], then sorts by [mode]/[ascending].
  ///
  /// Status sort uses [statusPriority] with most-recently-added as tiebreak.
  static List<TorrentInfo> filterAndSort(
    List<TorrentInfo> torrents,
    DownloadFilter filter,
    DownloadSortMode mode,
    bool ascending,
  ) {
    final list = switch (filter) {
      DownloadFilter.all         => List.of(torrents),
      DownloadFilter.downloading => torrents.where((t) => t.state == TorrentState.downloading).toList(),
      DownloadFilter.seeding     => torrents.where((t) => t.state == TorrentState.seeding).toList(),
      DownloadFilter.completed   => torrents.where((t) => t.state == TorrentState.completed).toList(),
      DownloadFilter.running     => torrents.where((t) => t.state == TorrentState.downloading || t.state == TorrentState.seeding).toList(),
      DownloadFilter.stopped     => torrents.where((t) => t.state == TorrentState.paused).toList(),
      DownloadFilter.stalled     => torrents.where((t) => t.state == TorrentState.stalled).toList(),
      DownloadFilter.errored     => torrents.where((t) => t.state == TorrentState.error).toList(),
    };

    list.sort((a, b) {
      int cmp;
      switch (mode) {
        // Sort by status priority, then most-recently-added as tiebreak
        case DownloadSortMode.status:
          cmp = (statusPriority[a.state] ?? 9).compareTo(statusPriority[b.state] ?? 9);
          if (cmp == 0) cmp = (b.addedOn ?? DateTime(0)).compareTo(a.addedOn ?? DateTime(0));

        // Sort by name, case-insensitive
        case DownloadSortMode.name:
          cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());

        // Sort by addedOn, newest first
        case DownloadSortMode.addedOn:
          cmp = (b.addedOn ?? DateTime(0)).compareTo(a.addedOn ?? DateTime(0));

        // Sort by progress, highest first
        case DownloadSortMode.progress:
          cmp = b.progress.compareTo(a.progress);

        // Sort by size, largest first
        case DownloadSortMode.size:
          cmp = b.size.compareTo(a.size);
      }
      return ascending ? cmp : -cmp;
    });

    return list;
  }

  static String stateLabel(TorrentState state) {
    return switch (state) {
      TorrentState.downloading => 'Downloading',
      TorrentState.seeding => 'Seeding',
      TorrentState.paused => 'Paused',
      TorrentState.queued => 'Queued',
      TorrentState.checking => 'Checking',
      TorrentState.stalled => 'Stalled',
      TorrentState.completed => 'Completed',
      TorrentState.error => 'Error',
      TorrentState.unknown => 'Unknown',
    };
  }
}
