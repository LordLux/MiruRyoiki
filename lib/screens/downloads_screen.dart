import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors, FilledButton, ButtonStyle;
import 'package:flutter/material.dart' hide Card, Divider, Tooltip, ListTile, IconButton, showDialog;
import 'package:miruryoiki/enums.dart';
import 'package:miruryoiki/widgets/tooltip_wrapper.dart';
import '../manager.dart';
import '../services/downloads/download_controller.dart';
import '../services/downloads/torrent_client.dart';
import '../services/downloads/torrent_manager.dart';
import '../services/navigation/navigation.dart';
import '../services/sonarr/sonarr_service.dart';
import '../settings.dart';
import '../utils/time.dart';
import '../utils/units.dart';
import '../utils/screen.dart';
import '../viewmodels/downloads_viewmodel.dart';
import '../widgets/buttons/button.dart';
import '../widgets/page/page_template.dart';
import '../widgets/context_menu/controller.dart';
import '../widgets/context_menu/torrent.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/infobar.dart';
import '../widgets/buttons/category_tile_button.dart';
import '../widgets/speed_graph.dart';

// Fixed widths for the metadata row columns so values line up across rows
const double _kPctColumnWidth = 37; // "100.0%"
const double _kSizeColumnWidth = 72; // "1023.99 GB"
const double _kAddedColumnWidth = 86; // "Added 99mo ago"
const double _kSeedLeechColumnWidth = 100; // "S: 9999  L: 9999"

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
  bool _graphExpanded = true;

  late final DownloadsViewModel _vm;

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
    _vm = context.read<DownloadsViewModel>();
    _vm.startPolling();
  }

  @override
  void dispose() {
    _vm.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<DownloadsViewModel>(); // rebuild on torrent/filter/sort changes

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

    return LayoutBuilder(builder: (context, constraints) {
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
                  if (_vm.torrents.isNotEmpty) ...[
                    Text(
                      '${_vm.downloadingCount} downloading, '
                      '${_vm.seedingCount} seeding',
                      style: Manager.miniBodyStyle.copyWith(color: Colors.white.withValues(alpha: .5)),
                    ),
                    const SizedBox(width: 16),
                    Text('Sort by', style: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: .7))),
                    const SizedBox(width: 8),
                    ComboBox<DownloadSortMode>(
                      value: _vm.sortMode,
                      items: const [
                        ComboBoxItem(value: DownloadSortMode.status, child: Text('Status')),
                        ComboBoxItem(value: DownloadSortMode.name, child: Text('Name')),
                        ComboBoxItem(value: DownloadSortMode.addedOn, child: Text('Added')),
                        ComboBoxItem(value: DownloadSortMode.progress, child: Text('Progress')),
                        ComboBoxItem(value: DownloadSortMode.size, child: Text('Size')),
                      ],
                      onChanged: (v) {
                        if (v != null) _vm.setSortMode(v);
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(_vm.sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                      onPressed: () => _vm.toggleSortDirection(),
                    ),
                    const SizedBox(width: 16),
                  ],
                  SizedBox(
                    width: ScreenUtils.kDefaultButtonSize,
                    height: ScreenUtils.kDefaultButtonSize,
                    child: StandardButton.icon(
                      icon: _vm.isLoading ? const SizedBox(width: 14, height: 14, child: RepaintBoundary(child: CircularProgressIndicator(strokeWidth: 2))) : const Icon(Icons.refresh, size: 18),
                      onPressed: _vm.isLoading ? null : () => _vm.fetchTorrents(),
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
                  isSelected: _vm.filter == DownloadFilter.all,
                  onPressed: () => _vm.setFilter(DownloadFilter.all),
                ),
                CategoryTileButton(
                  title: 'Downloading',
                  icon: Icons.arrow_downward,
                  color: const Color(0xFF4CAF50),
                  isSelected: _vm.filter == DownloadFilter.downloading,
                  onPressed: () => _vm.setFilter(DownloadFilter.downloading),
                ),
                CategoryTileButton(
                  title: 'Seeding',
                  icon: Icons.arrow_upward,
                  color: const Color(0xFF2196F3),
                  isSelected: _vm.filter == DownloadFilter.seeding,
                  onPressed: () => _vm.setFilter(DownloadFilter.seeding),
                ),
                CategoryTileButton(
                  title: 'Completed',
                  icon: Icons.check_circle,
                  color: const Color(0xFF9C27B0),
                  isSelected: _vm.filter == DownloadFilter.completed,
                  onPressed: () => _vm.setFilter(DownloadFilter.completed),
                ),
                CategoryTileButton(
                  title: 'Running',
                  icon: Icons.play_arrow,
                  color: const Color(0xFF03A9F4),
                  isSelected: _vm.filter == DownloadFilter.running,
                  onPressed: () => _vm.setFilter(DownloadFilter.running),
                ),
                CategoryTileButton(
                  title: 'Stopped',
                  icon: Icons.pause,
                  color: const Color(0xFF9E9E9E),
                  isSelected: _vm.filter == DownloadFilter.stopped,
                  onPressed: () => _vm.setFilter(DownloadFilter.stopped),
                ),
                CategoryTileButton(
                  title: 'Stalled',
                  icon: Icons.hourglass_empty,
                  color: const Color(0xFFFF9800),
                  isSelected: _vm.filter == DownloadFilter.stalled,
                  onPressed: () => _vm.setFilter(DownloadFilter.stalled),
                ),
                CategoryTileButton(
                  title: 'Errored',
                  icon: Icons.error,
                  color: const Color(0xFFF44336),
                  isSelected: _vm.filter == DownloadFilter.errored,
                  onPressed: () => _vm.setFilter(DownloadFilter.errored),
                ),
              ],
            ),
          ),
        ),
        content: _buildContent(constraints),
        hideInfoBar: false,
        scrollController: widget.scrollController,
        scrollableContent: true,
        headerMinHeight: 130,
        headerMaxHeight: 190,
        noHeaderBanner: true,
        wrapContentWithCard: true,
        cardPadding: const EdgeInsets.all(8.0),
      );
    });
  }

  static const _kGraphExpandedHeight = 264.0;
  static const _kGraphCollapsedHeight = 50.0;

  Widget _buildGraphSection() {
    final service = TorrentManager.speedGraphService;
    if (service == null) return const SizedBox.shrink();
    final settings = SettingsManager();
    service.setDisplayTimeframeMinutes(settings.graphTimeframeMinutes);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SpeedGraphWidget(
          service: service,
          enabledMetricNames: settings.graphMetrics,
          expanded: _graphExpanded,
          onExpandedChanged: (v) => setState(() => _graphExpanded = v),
        ),
        const SizedBox(height: 16),
        Divider(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildContent(BoxConstraints constraints) {
    if (_vm.isLoading && _vm.torrents.isEmpty) return const Center(child: ProgressRing());

    final hasGraph = TorrentManager.speedGraphService != null;
    final graphReservedHeight = hasGraph ? (_graphExpanded ? _kGraphExpandedHeight : _kGraphCollapsedHeight) + 40 : 0.0;
    final availableHeight = math.max(120.0, constraints.maxHeight - ScreenUtils.kTitleBarHeight - 166 - graphReservedHeight);

    if (_vm.error != null && _vm.torrents.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasGraph) _buildGraphSection(),
          SizedBox(
            height: availableHeight,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Failed to connect to ${TorrentManager.torrentClient?.clientName ?? "torrent client"}', style: Manager.bodyStrongStyle),
                  const SizedBox(height: 8),
                  Text(_vm.error!, style: Manager.miniBodyStyle.copyWith(color: Colors.white.withValues(alpha: .5))),
                  const SizedBox(height: 16),
                  StandardButton.label(
                    label: 'Retry',
                    onPressed: () => _vm.fetchTorrents(),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_vm.torrents.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasGraph) _buildGraphSection(),
          SizedBox(
            height: availableHeight,
            child: Center(
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
            ),
          ),
        ],
      );
    }

    final sorted = _vm.sortedTorrents;

    if (sorted.isEmpty) {
      String title = '';
      String subtitle = '';
      IconData icon = Icons.filter_list_off;
      Color color = Colors.white;

      switch (_vm.filter) {
        case DownloadFilter.downloading:
          title = 'No downloading torrents';
          subtitle = 'Torrents will appear here when they are actively downloading data.';
          icon = Icons.arrow_downward;
          color = const Color(0xFF4CAF50);
        case DownloadFilter.seeding:
          title = 'No seeding torrents';
          subtitle = 'Torrents will appear here when they have finished downloading and are uploading data.';
          icon = Icons.arrow_upward;
          color = const Color(0xFF2196F3);
        case DownloadFilter.completed:
          title = 'No completed torrents';
          subtitle = 'Torrents will appear here once they reach their seed ratio or are fully complete.';
          icon = Icons.check_circle;
          color = const Color(0xFF9C27B0);
        case DownloadFilter.running:
          title = 'No running torrents';
          subtitle = 'Torrents will appear here when they are downloading or seeding.';
          icon = Icons.play_arrow;
          color = const Color(0xFF03A9F4);
        case DownloadFilter.stopped:
          title = 'No stopped torrents';
          subtitle = 'Torrents will appear here if you pause them or if they are stopped.';
          icon = Icons.pause;
          color = const Color(0xFF9E9E9E);
        case DownloadFilter.stalled:
          title = 'No stalled torrents';
          subtitle = 'Torrents will appear here if they are trying to download but have no active connections.';
          icon = Icons.hourglass_empty;
          color = const Color(0xFFFF9800);
        case DownloadFilter.errored:
          title = 'No errored torrents';
          subtitle = 'Torrents will appear here if the client encounters an error with them.';
          icon = Icons.error;
          color = const Color(0xFFF44336);
        case DownloadFilter.all:
          break; // Handled by the torrents.isEmpty catch above
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasGraph) _buildGraphSection(),
          SizedBox(
            height: availableHeight,
            child: Align(
              alignment: Alignment.center,
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
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasGraph) _buildGraphSection(),
        ...sorted
            .mapIndexed((int index, TorrentInfo torrent) => _TorrentTile(
                  isLast: index == sorted.length - 1,
                  torrent: torrent,
                  onPause: _vm.pauseTorrent,
                  onResume: _vm.resumeTorrent,
                  onChanged: () => _vm.fetchTorrents(silent: true),
                )),
      ],
    );
  }
}

class _TorrentTile extends StatefulWidget {
  final TorrentInfo torrent;
  final Future<void> Function(TorrentInfo) onPause;
  final Future<void> Function(TorrentInfo) onResume;
  final VoidCallback onChanged;
  final bool isLast;

  const _TorrentTile({
    required this.torrent,
    required this.onPause,
    required this.onResume,
    required this.onChanged,
    required this.isLast,
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
    final progressPercent = getPercent(t);
    final bool isPaused = t.state == TorrentState.paused;
    final bool isActive = t.state == TorrentState.downloading || t.state == TorrentState.seeding;

    return TorrentContextMenu(
        torrent: t,
        controller: _contextMenuController,
        onChanged: widget.onChanged,
        child: Padding(
          padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 6.0),
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovering = true),
            onExit: (_) => setState(() => _isHovering = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
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
                            child: t.size <= 0
                                ? Shimmer.fromColors(
                                    baseColor: Colors.white.withValues(alpha: 0.12),
                                    highlightColor: Colors.white.withValues(alpha: 0.28),
                                    child: Container(
                                      width: 48,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  )
                                : Text(fileSize(t.size), overflow: TextOverflow.visible, maxLines: 1),
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
          ),
        ));
  }

  String getPercent(TorrentInfo t) {
    if (t.progress < 0 || t.progress > 1) return '?';
    if (t.progress == 0) return '0';
    if (t.progress == 1) return '100';
    return (t.progress * 100).toStringAsFixed(1);
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
