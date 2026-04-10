import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart' hide Colors, FilledButton, ButtonStyle;
import 'package:flutter/material.dart' hide Card, Divider, Tooltip, ListTile, IconButton, showDialog;
import 'package:miruryoiki/enums.dart';
import 'package:miruryoiki/widgets/tooltip_wrapper.dart';
import '../manager.dart';
import '../services/downloads/download_controller.dart';
import '../services/downloads/torrent_client.dart';
import '../services/downloads/torrent_manager.dart';
import '../services/navigation/navigation.dart';
import '../services/navigation/show_info.dart';
import '../services/sonarr/sonarr_service.dart';
import '../utils/logging.dart';
import '../utils/time.dart';
import '../utils/units.dart';
import '../utils/screen.dart';
import '../widgets/buttons/button.dart';
import '../widgets/page/page_template.dart';
import '../widgets/context_menu/controller.dart';
import '../widgets/context_menu/torrent.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/infobar.dart';
import '../widgets/buttons/category_tile_button.dart';

// Fixed widths for the metadata row columns so values line up across rows
const double _kPctColumnWidth = 37; // "100.0%"
const double _kSizeColumnWidth = 72; // "1023.99 GB"
const double _kAddedColumnWidth = 86; // "Added 99mo ago"
const double _kSeedLeechColumnWidth = 100; // "S: 9999  L: 9999"

String _stateLabel(TorrentState state) {
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

class DownloadsScreen extends StatefulWidget {
  final DownloadController? controller;
  final SonarrRepository? sonarrRepo;
  final ScrollController scrollController;

  const DownloadsScreen({
    super.key,
    this.controller,
    this.sonarrRepo,
    required this.scrollController,
  });

  @override
  State<DownloadsScreen> createState() => DownloadsScreenState();
}

enum _SortMode { status, name, addedOn, progress, size }

enum _DownloadFilter { all, downloading, seeding, completed, running, stopped, stalled, errored }

class DownloadsScreenState extends State<DownloadsScreen> {
  List<TorrentInfo> _torrents = [];
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;
  _SortMode _sortMode = _SortMode.status;
  bool _sortAscending = true;
  _DownloadFilter _filterState = _DownloadFilter.all;

  @override
  void activate() {
    super.activate();
    NavigationManager.registerActiveScrollController('torrent', widget.scrollController);
    NavigationManager.restoreScrollOffset('torrent', widget.scrollController);
  }

  @override
  void initState() {
    super.initState();
    NavigationManager.registerActiveScrollController('torrent', widget.scrollController);
    NavigationManager.restoreScrollOffset('torrent', widget.scrollController);
    _fetchTorrents();
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) => _fetchTorrents(silent: true));
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchTorrents({bool silent = false}) async {
    final client = TorrentManager.torrentClient;
    if (client == null) return;

    if (!silent)
      setState(() {
        _isLoading = true;
        _error = null;
      });

    try {
      final list = await client.listTorrents();
      if (mounted) {
        setState(() {
          _torrents = list;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (!silent) _error = e.toString();
        });
        if (!silent) logDebug('Failed to fetch torrents: $e');
      }
    }
  }

  Future<void> _pauseTorrent(TorrentInfo torrent) async {
    final client = TorrentManager.torrentClient;
    if (client == null) return;
    try {
      await client.pauseTorrent(torrent.hash);
      _fetchTorrents(silent: true);
    } catch (e) {
      snackBar('Failed to pause: $e', severity: InfoBarSeverity.error);
    }
  }

  Future<void> _resumeTorrent(TorrentInfo torrent) async {
    final client = TorrentManager.torrentClient;
    if (client == null) return;
    try {
      await client.resumeTorrent(torrent.hash);
      _fetchTorrents(silent: true);
    } catch (e) {
      snackBar('Failed to resume: $e', severity: InfoBarSeverity.error);
    }
  }

  static const _statusPriority = {
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

  List<TorrentInfo> get _sortedTorrents {
    var list = switch (_filterState) {
      _DownloadFilter.all => List.of(_torrents),
      _DownloadFilter.downloading => _torrents.where((t) => t.state == TorrentState.downloading).toList(),
      _DownloadFilter.seeding => _torrents.where((t) => t.state == TorrentState.seeding).toList(),
      _DownloadFilter.completed => _torrents.where((t) => t.state == TorrentState.completed).toList(),
      _DownloadFilter.running => _torrents.where((t) => t.state == TorrentState.downloading || t.state == TorrentState.seeding).toList(),
      _DownloadFilter.stopped => _torrents.where((t) => t.state == TorrentState.paused).toList(),
      _DownloadFilter.stalled => _torrents.where((t) => t.state == TorrentState.stalled).toList(),
      _DownloadFilter.errored => _torrents.where((t) => t.state == TorrentState.error).toList(),
    };

    list.sort((a, b) {
      int cmp;
      switch (_sortMode) {
        case _SortMode.status:
          cmp = (_statusPriority[a.state] ?? 9).compareTo(_statusPriority[b.state] ?? 9);
          if (cmp == 0) cmp = (b.addedOn ?? DateTime(0)).compareTo(a.addedOn ?? DateTime(0));
        case _SortMode.name:
          cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case _SortMode.addedOn:
          cmp = (b.addedOn ?? DateTime(0)).compareTo(a.addedOn ?? DateTime(0));
        case _SortMode.progress:
          cmp = b.progress.compareTo(a.progress);
        case _SortMode.size:
          cmp = b.size.compareTo(a.size);
      }
      return _sortAscending ? cmp : -cmp;
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (!TorrentManager.isEnabled) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Downloads not configured', style: Manager.bodyStrongStyle),
            const SizedBox(height: 8),
            Text('Set up Sonarr and a torrent client in Settings to get started.', style: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: .5))),
          ],
        ),
      );
    }

    return MiruRyoikiTemplatePage(
      scrollRestorationId: 'torrent',
      headerWidget: HeaderWidget(
        titleLeftAligned: true,
        title: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text('Active Torrents', style: Manager.titleLargeStyle),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_torrents.isNotEmpty) ...[
                  Text(
                    '${_torrents.where((t) => t.state == TorrentState.downloading).length} downloading, '
                    '${_torrents.where((t) => t.state == TorrentState.seeding).length} seeding',
                    style: Manager.miniBodyStyle.copyWith(color: Colors.white.withValues(alpha: .5)),
                  ),
                  const SizedBox(width: 16),
                  Text('Sort by', style: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: .7))),
                  const SizedBox(width: 8),
                  ComboBox<_SortMode>(
                    value: _sortMode,
                    items: const [
                      ComboBoxItem(value: _SortMode.status, child: Text('Status')),
                      ComboBoxItem(value: _SortMode.name, child: Text('Name')),
                      ComboBoxItem(value: _SortMode.addedOn, child: Text('Added')),
                      ComboBoxItem(value: _SortMode.progress, child: Text('Progress')),
                      ComboBoxItem(value: _SortMode.size, child: Text('Size')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _sortMode = v);
                    },
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                    onPressed: () => setState(() => _sortAscending = !_sortAscending),
                  ),
                  const SizedBox(width: 16),
                ],
                SizedBox(
                  width: ScreenUtils.kDefaultButtonSize,
                  height: ScreenUtils.kDefaultButtonSize,
                  child: StandardButton.icon(
                    icon: _isLoading ? const SizedBox(width: 14, height: 14, child: RepaintBoundary(child: CircularProgressIndicator(strokeWidth: 2))) : const Icon(Icons.refresh, size: 18),
                    onPressed: _isLoading ? null : () => _fetchTorrents(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      infobar: (noHeaderBanner) => MiruRyoikiInfobar(
        noHeaderBanner: noHeaderBanner,
        contentPadding: (_) => const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        content: SizedBox(
          width: ScreenUtils.kInfoBarWidth,
          child: Column(
            children: [
              CategoryTileButton(
                title: 'All',
                icon: Icons.all_inclusive,
                color: Colors.white,
                isSelected: _filterState == _DownloadFilter.all,
                onPressed: () => setState(() => _filterState = _DownloadFilter.all),
              ),
              CategoryTileButton(
                title: 'Downloading',
                icon: Icons.arrow_downward,
                color: const Color(0xFF4CAF50),
                isSelected: _filterState == _DownloadFilter.downloading,
                onPressed: () => setState(() => _filterState = _DownloadFilter.downloading),
              ),
              CategoryTileButton(
                title: 'Seeding',
                icon: Icons.arrow_upward,
                color: const Color(0xFF2196F3),
                isSelected: _filterState == _DownloadFilter.seeding,
                onPressed: () => setState(() => _filterState = _DownloadFilter.seeding),
              ),
              CategoryTileButton(
                title: 'Completed',
                icon: Icons.check_circle,
                color: const Color(0xFF9C27B0),
                isSelected: _filterState == _DownloadFilter.completed,
                onPressed: () => setState(() => _filterState = _DownloadFilter.completed),
              ),
              CategoryTileButton(
                title: 'Running',
                icon: Icons.play_arrow,
                color: const Color(0xFF03A9F4),
                isSelected: _filterState == _DownloadFilter.running,
                onPressed: () => setState(() => _filterState = _DownloadFilter.running),
              ),
              CategoryTileButton(
                title: 'Stopped',
                icon: Icons.pause,
                color: const Color(0xFF9E9E9E),
                isSelected: _filterState == _DownloadFilter.stopped,
                onPressed: () => setState(() => _filterState = _DownloadFilter.stopped),
              ),
              CategoryTileButton(
                title: 'Stalled',
                icon: Icons.hourglass_empty,
                color: const Color(0xFFFF9800),
                isSelected: _filterState == _DownloadFilter.stalled,
                onPressed: () => setState(() => _filterState = _DownloadFilter.stalled),
              ),
              CategoryTileButton(
                title: 'Errored',
                icon: Icons.error,
                color: const Color(0xFFF44336),
                isSelected: _filterState == _DownloadFilter.errored,
                onPressed: () => setState(() => _filterState = _DownloadFilter.errored),
              ),
            ],
          ),
        ),
      ),
      content: _buildContent(),
      hideInfoBar: false,
      scrollController: widget.scrollController,
      scrollableContent: true,
      headerMinHeight: 130,
      headerMaxHeight: 190,
      noHeaderBanner: true,
      wrapContentWithCard: true,
      cardPadding: const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _torrents.isEmpty) return const Center(child: ProgressRing());

    if (_error != null && _torrents.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text('Failed to connect to ${TorrentManager.torrentClient?.clientName ?? "torrent client"}', style: Manager.bodyStrongStyle),
            const SizedBox(height: 8),
            Text(_error!, style: Manager.miniBodyStyle.copyWith(color: Colors.white.withValues(alpha: .5))),
            const SizedBox(height: 16),
            StandardButton.label(
              label: 'Retry',
              onPressed: () => _fetchTorrents(),
            ),
          ],
        ),
      );
    }

    if (_torrents.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download_done, size: 48, color: Colors.white.withValues(alpha: .3)),
            const SizedBox(height: 12),
            Text('No active torrents', style: Manager.bodyStrongStyle),
            const SizedBox(height: 8),
            Text('You need to add a torrent to see them here.', style: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: .5))),
          ],
        ),
      );
    }

    final sorted = _sortedTorrents;

    if (sorted.isEmpty) {
      String title = '';
      String subtitle = '';
      IconData icon = Icons.filter_list_off;
      Color color = Colors.white;

      switch (_filterState) {
        case _DownloadFilter.downloading:
          title = 'No downloading torrents';
          subtitle = 'Torrents will appear here when they are actively downloading data.';
          icon = Icons.arrow_downward;
          color = const Color(0xFF4CAF50);
        case _DownloadFilter.seeding:
          title = 'No seeding torrents';
          subtitle = 'Torrents will appear here when they have finished downloading and are uploading data.';
          icon = Icons.arrow_upward;
          color = const Color(0xFF2196F3);
        case _DownloadFilter.completed:
          title = 'No completed torrents';
          subtitle = 'Torrents will appear here once they reach their seed ratio or are fully complete.';
          icon = Icons.check_circle;
          color = const Color(0xFF9C27B0);
        case _DownloadFilter.running:
          title = 'No running torrents';
          subtitle = 'Torrents will appear here when they are downloading or seeding.';
          icon = Icons.play_arrow;
          color = const Color(0xFF03A9F4);
        case _DownloadFilter.stopped:
          title = 'No stopped torrents';
          subtitle = 'Torrents will appear here if you pause them or if they are stopped.';
          icon = Icons.pause;
          color = const Color(0xFF9E9E9E);
        case _DownloadFilter.stalled:
          title = 'No stalled torrents';
          subtitle = 'Torrents will appear here if they are trying to download but have no active connections.';
          icon = Icons.hourglass_empty;
          color = const Color(0xFFFF9800);
        case _DownloadFilter.errored:
          title = 'No errored torrents';
          subtitle = 'Torrents will appear here if the client encounters an error with them.';
          icon = Icons.error;
          color = const Color(0xFFF44336);
        case _DownloadFilter.all:
          break; // Handled by _torrents.isEmpty catch above
      }

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color.withValues(alpha: .5)),
            const SizedBox(height: 12),
            Text(title, style: Manager.bodyStrongStyle),
            const SizedBox(height: 8),
            Text(subtitle, style: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: .5))),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0).copyWith(right: 4.0),
      child: Column(
        children: sorted
            .map((torrent) => _TorrentTile(
                  torrent: torrent,
                  onPause: _pauseTorrent,
                  onResume: _resumeTorrent,
                  onChanged: () => _fetchTorrents(silent: true),
                ))
            .toList(),
      ),
    );
  }
}

class _TorrentTile extends StatefulWidget {
  final TorrentInfo torrent;
  final Future<void> Function(TorrentInfo) onPause;
  final Future<void> Function(TorrentInfo) onResume;
  final VoidCallback onChanged;

  const _TorrentTile({
    required this.torrent,
    required this.onPause,
    required this.onResume,
    required this.onChanged,
  });

  @override
  State<_TorrentTile> createState() => _TorrentTileState();
}

class _TorrentTileState extends State<_TorrentTile> {
  final DesktopContextMenuController _contextMenuController = DesktopContextMenuController();
  bool _isHovering = false;

  Color _stateColor(TorrentState state) {
    return switch (state) {
      TorrentState.downloading => const Color(0xFF4CAF50), // green
      TorrentState.seeding => const Color(0xFF2196F3), // blue
      TorrentState.paused => const Color(0xFF9E9E9E), // gray
      TorrentState.queued => const Color(0xFF9E9E9E), // gray
      TorrentState.checking => const Color(0xFFFF9800), // orange
      TorrentState.stalled => const Color(0xFFFF9800), // orange
      TorrentState.completed => const Color(0xFF9C27B0), // purple
      TorrentState.error => const Color(0xFFF44336), // red
      TorrentState.unknown => const Color(0xFF9E9E9E), // gray
    };
  }

  IconData _stateIcon(TorrentState state) {
    return switch (state) {
      TorrentState.downloading => Icons.arrow_downward,
      TorrentState.seeding => Icons.arrow_upward,
      TorrentState.paused => Icons.pause,
      TorrentState.queued => Icons.schedule,
      TorrentState.checking => Icons.fact_check,
      TorrentState.stalled => Icons.hourglass_empty,
      TorrentState.completed => Icons.check_circle,
      TorrentState.error => Icons.error,
      TorrentState.unknown => Icons.help_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.torrent;
    final color = _stateColor(t.state);
    final progressPercent = t.progress == 1 ? "100" : (t.progress * 100).toStringAsFixed(1);
    final bool isPaused = t.state == TorrentState.paused;
    final bool isActive = t.state == TorrentState.downloading || t.state == TorrentState.seeding;

    return TorrentContextMenu(
        torrent: t,
        controller: _contextMenuController,
        onChanged: widget.onChanged,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
              color: _isHovering ? Colors.white.withValues(alpha: .03) : Colors.transparent,
            ),
            child: Card(
              borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Name + actions
                  Row(
                    children: [
                      Icon(_stateIcon(t.state), size: 18, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.name,
                          style: Manager.bodyStyle.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Action buttons (visible on hover or always for mobile)
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: _isHovering ? 1.0 : 0.0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isPaused)
                              _ActionButton(
                                icon: Icons.play_arrow,
                                tooltip: 'Resume',
                                onPressed: () => widget.onResume(t),
                              )
                            else if (isActive)
                              _ActionButton(
                                icon: Icons.pause,
                                tooltip: 'Pause',
                                onPressed: () => widget.onPause(t),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Row 2: Progress bar
                  Row(
                    children: [
                      SizedBox(
                        width: _kPctColumnWidth,
                        child: Text('$progressPercent%', overflow: TextOverflow.visible, maxLines: 1),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: SizedBox(
                            height: 4,
                            child: LinearProgressIndicator(
                              value: t.progress,
                              minHeight: 4,
                              backgroundColor: Colors.white.withValues(alpha: .1),
                              color: color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: _kSizeColumnWidth,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(fileSize(t.size), overflow: TextOverflow.visible, maxLines: 1),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Row 3: Metadata
                  DefaultTextStyle(
                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: .6)),
                    child: Row(
                      children: [
                        // Added — fits "Added 99mo ago"
                        SizedBox(
                          width: _kAddedColumnWidth,
                          child: t.addedOn != null
                              ? TooltipWrapper(
                                  tooltip: t.addedOn!.pretty(forceYear: true, time: true, seconds: true),
                                  child: (_) => Text('Added ${formatRelativeTime(t.addedOn!)}', overflow: TextOverflow.ellipsis),
                                )
                              : const SizedBox.shrink(),
                        ),
                        // Variable middle: speeds + ETA when active
                        if (isActive) ...[
                          _dot(),
                          Icon(Icons.arrow_downward, size: 11, color: const Color(0xFF4CAF50)),
                          const SizedBox(width: 2),
                          Text(fileTransferRate(t.downloadSpeed)),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_upward, size: 11, color: const Color(0xFF2196F3)),
                          const SizedBox(width: 2),
                          Text(fileTransferRate(t.uploadSpeed)),
                        ],
                        if (t.eta != null && isActive) ...[
                          _dot(),
                          Text('ETA ${t.eta}'),
                        ],
                        const Spacer(),
                        // Seeders / Leechers — fits "S: 9999  L: 9999"
                        SizedBox(
                          width: _kSeedLeechColumnWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _SeedLeechBadge(
                                label: 'S',
                                value: t.seeders,
                                backgroundColor: const Color(0xFF4CAF50),
                                labelColor: const Color(0xFF2E7D32),
                              ),
                              const SizedBox(width: 6),
                              _SeedLeechBadge(
                                label: 'L',
                                value: t.leechers,
                                backgroundColor: const Color(0xFF2196F3),
                                labelColor: const Color(0xFF1565C0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _dot() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text('·', style: TextStyle(color: Colors.white.withValues(alpha: .3))),
      );
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ActionButton({required this.icon, required this.tooltip, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 28,
        height: 28,
        child: IconButton(
          icon: Icon(icon, size: 16),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _SeedLeechBadge extends StatelessWidget {
  final String label;
  final int value;
  final Color backgroundColor;
  final Color labelColor;

  const _SeedLeechBadge({
    required this.label,
    required this.value,
    required this.backgroundColor,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 15, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
