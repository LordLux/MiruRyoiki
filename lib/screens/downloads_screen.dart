import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart' hide Colors, FilledButton, ButtonStyle;
import 'package:flutter/material.dart' hide Card, Divider, Tooltip, ListTile, IconButton, showDialog;
import '../manager.dart';
import '../services/downloads/download_controller.dart';
import '../services/downloads/torrent_client.dart';
import '../services/downloads/torrent_manager.dart';
import '../services/navigation/navigation.dart';
import '../services/navigation/show_info.dart';
import '../services/sonarr/sonarr_service.dart';
import '../utils/logging.dart';
import '../utils/units.dart';
import '../utils/screen.dart';
import '../widgets/buttons/button.dart';

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

class DownloadsScreenState extends State<DownloadsScreen> {
  List<TorrentInfo> _torrents = [];
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;

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

    if (!silent) setState(() { _isLoading = true; _error = null; });

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

  Future<void> _deleteTorrent(TorrentInfo torrent, {bool deleteFiles = false}) async {
    final client = TorrentManager.torrentClient;
    if (client == null) return;
    try {
      await client.deleteTorrent(torrent.hash, deleteFiles: deleteFiles);
      _fetchTorrents(silent: true);
      snackBar('Removed: ${torrent.name}', severity: InfoBarSeverity.success);
    } catch (e) {
      snackBar('Failed to delete: $e', severity: InfoBarSeverity.error);
    }
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

    return Column(
      children: [
        // Header bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Text('Active Torrents', style: Manager.subtitleStyle),
              const Spacer(),
              if (_torrents.isNotEmpty)
                Text(
                  '${_torrents.where((t) => t.state == TorrentState.downloading).length} downloading, '
                  '${_torrents.where((t) => t.state == TorrentState.seeding).length} seeding',
                  style: Manager.miniBodyStyle.copyWith(color: Colors.white.withValues(alpha: .5)),
                ),
              const SizedBox(width: 12),
              SizedBox(
                width: ScreenUtils.kDefaultButtonSize,
                height: ScreenUtils.kDefaultButtonSize,
                child: StandardButton.icon(
                  icon: _isLoading
                      ? const SizedBox(width: 14, height: 14, child: RepaintBoundary(child: CircularProgressIndicator(strokeWidth: 2)))
                      : const Icon(Icons.refresh, size: 18),
                  onPressed: _isLoading ? null : () => _fetchTorrents(),
                ),
              ),
            ],
          ),
        ),

        const Divider(),

        // Content
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading && _torrents.isEmpty) {
      return const Center(child: ProgressRing());
    }

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
            Text('No active torrents', style: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: .5))),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: _torrents.length,
      itemBuilder: (context, index) => _TorrentTile(
        torrent: _torrents[index],
        onPause: _pauseTorrent,
        onResume: _resumeTorrent,
        onDelete: _deleteTorrent,
      ),
    );
  }
}

class _TorrentTile extends StatefulWidget {
  final TorrentInfo torrent;
  final Future<void> Function(TorrentInfo) onPause;
  final Future<void> Function(TorrentInfo) onResume;
  final Future<void> Function(TorrentInfo, {bool deleteFiles}) onDelete;

  const _TorrentTile({
    required this.torrent,
    required this.onPause,
    required this.onResume,
    required this.onDelete,
  });

  @override
  State<_TorrentTile> createState() => _TorrentTileState();
}

class _TorrentTileState extends State<_TorrentTile> {
  bool _isHovering = false;

  Color _stateColor(TorrentState state) {
    return switch (state) {
      TorrentState.downloading => const Color(0xFF2196F3), // blue
      TorrentState.seeding => const Color(0xFF4CAF50), // green
      TorrentState.paused => const Color(0xFFFF9800), // orange
      TorrentState.queued => const Color(0xFF9E9E9E), // grey
      TorrentState.checking => const Color(0xFF9C27B0), // purple
      TorrentState.stalled => const Color(0xFFFF9800), // orange
      TorrentState.completed => const Color(0xFF4CAF50), // green
      TorrentState.error => const Color(0xFFF44336), // red
      TorrentState.unknown => const Color(0xFF9E9E9E), // grey
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

  @override
  Widget build(BuildContext context) {
    final t = widget.torrent;
    final color = _stateColor(t.state);
    final progressPercent = (t.progress * 100).toStringAsFixed(1);
    final bool isPaused = t.state == TorrentState.paused;
    final bool isActive = t.state == TorrentState.downloading || t.state == TorrentState.seeding;

    return MouseRegion(
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
                        const SizedBox(width: 4),
                        _ActionButton(
                          icon: Icons.delete_outline,
                          tooltip: 'Remove torrent',
                          onPressed: () async {
                            final deleteFiles = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => ContentDialog(
                                title: const Text('Remove Torrent'),
                                content: Text('Remove "${t.name}"?\n\nCheck the box to also delete downloaded files.'),
                                actions: [
                                  Button(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop(null)),
                                  Button(child: const Text('Remove'), onPressed: () => Navigator.of(ctx).pop(false)),
                                  FilledButton(
                                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red)),
                                    child: const Text('Remove + Delete Files'),
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                  ),
                                ],
                              ),
                            );
                            if (deleteFiles != null) widget.onDelete(t, deleteFiles: deleteFiles);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Row 2: Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: t.progress,
                  minHeight: 4,
                  backgroundColor: Colors.white.withValues(alpha: .1),
                  color: color,
                ),
              ),

              const SizedBox(height: 8),

              // Row 3: Metadata
              DefaultTextStyle(
                style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: .6)),
                child: Row(
                  children: [
                    Text('$progressPercent%'),
                    _dot(),
                    Text(fileSize(t.size)),
                    if (isActive) ...[
                      _dot(),
                      Icon(Icons.arrow_downward, size: 11, color: const Color(0xFF2196F3)),
                      const SizedBox(width: 2),
                      Text(fileTransferRate(t.downloadSpeed)),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_upward, size: 11, color: const Color(0xFF4CAF50)),
                      const SizedBox(width: 2),
                      Text(fileTransferRate(t.uploadSpeed)),
                    ],
                    if (t.eta != null && isActive) ...[
                      _dot(),
                      Text('ETA ${t.eta}'),
                    ],
                    _dot(),
                    Text(_stateLabel(t.state), style: TextStyle(color: color, fontSize: 11)),
                    const Spacer(),
                    Text('S: ${t.seeders}  L: ${t.leechers}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
