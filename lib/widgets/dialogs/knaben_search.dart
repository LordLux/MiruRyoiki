import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:miruryoiki/utils/logging.dart';

import '../../models/series.dart';
import '../../models/torrent_release.dart';
import '../../services/downloads/download_controller.dart';
import '../../services/downloads/torrent_manager.dart';
import '../../services/knaben/knaben_service.dart';
import '../../services/navigation/dialogs.dart';
import '../../services/navigation/dialogs2.dart';
import 'package:provider/provider.dart';
import '../../services/navigation/navigation.dart';
import '../../services/navigation/show_info.dart';
import '../../settings.dart';
import '../../manager.dart';
import '../../utils/magnet.dart';
import '../../utils/quality.dart';
import '../../utils/units.dart';
import '../../utils/screen.dart';
import '../buttons/button.dart';
import '../smooth_scroll.dart';

enum _SearchProvider { knaben, sonarr }

enum _Step { search, confirm }

/// Dialog that searches Knaben or Sonarr for releases and lets the user download them
class KnabenSearchDialog extends StatefulWidget {
  final DownloadController controller;
  final List<String> seriesTitles;
  final int? season;
  final int? episode;
  final bool isSeasonSearch;

  /// For specials/movies: search by title instead of season+episode number
  final String? episodeTitle;

  /// Sonarr episode ID (for single-episode Sonarr search)
  final int? sonarrEpisodeId;

  /// Sonarr series ID (for season Sonarr search)
  final int? sonarrSeriesId;

  /// Local series for the episode being downloaded
  ///
  /// Used to derive the default destination folder (series path + season subfolder)
  ///
  /// May be null when the series is not yet in the local library
  final Series? series;

  final DialogNavigationItem? item;

  const KnabenSearchDialog({
    super.key,
    required this.controller,
    required this.seriesTitles,
    this.season,
    this.episode,
    this.isSeasonSearch = false,
    this.episodeTitle,
    this.sonarrEpisodeId,
    this.sonarrSeriesId,
    this.series,
    this.item,
  });

  @override
  State<KnabenSearchDialog> createState() => KnabenSearchDialogState();
}

class KnabenSearchDialogState extends State<KnabenSearchDialog> with DialogController {
  @override
  bool get canPop => _step == _Step.search;

  @override
  bool onBackRequested() {
    backToSearch();
    return true;
  }

  late TextEditingController _searchController;
  bool _isCustomSearch = false;

  // Search provider state
  _SearchProvider _provider = _SearchProvider.knaben;
  bool _sonarrAvailable = false;

  // Knaben state
  Future<List<KnabenRelease>>? _knabenFuture;
  late bool _liveSearch;

  // Sonarr state
  Future<List<SonarrRelease>>? _sonarrFuture;

  _Step _step = _Step.search;
  TorrentRelease? _selectedRelease;
  bool _isDownloading = false;
  bool _grabbed = false;
  late final TextEditingController _destFolderController;

  /// Identifiers of releases the user has grabbed during this dialog session
  final Set<String> _sentIdentifiers = {};

  /// qBittorrent torrent hashes loaded once on dialog open. Used to mark
  /// Knaben results that are already in the client. Empty until the async
  /// load completes, then setState rebuilds the tiles
  Set<String> _qbitHashes = {};

  String _initialDestFolder() {
    final series = widget.series;
    if (series == null) return '';
    return widget.controller.seriesSeasonSavePath(series, widget.season) ?? '';
  }

  void _goToConfirm(TorrentRelease release) {
    context.resizeManagedDialog(constraints: const BoxConstraints(maxWidth: 700, maxHeight: 520));
    setState(() {
      _step = _Step.confirm;
      _selectedRelease = release;
    });
  }

  /// Return from the confirm step to the result list
  void backToSearch() {
    if (_step != _Step.confirm) return;
    context.resizeManagedDialog(constraints: const BoxConstraints(maxWidth: 900, maxHeight: 900));
    setState(() {
      _step = _Step.search;
      _selectedRelease = null;
      _grabbed = false;
    });
  }

  Future<void> _doDownload() async {
    if (_isDownloading) return;
    final r = _selectedRelease;
    if (r == null) return;

    setState(() => _isDownloading = true);
    try {
      switch (r) {
        case KnabenRelease():
          final dest = _destFolderController.text.trim();
          final ok = await widget.controller.grabMagnet(r.magnetUrl, savePath: dest.isNotEmpty ? dest : null);
          if (!mounted) return;

          if (ok) {
            final hash = extractBtih(r.magnetUrl);
            if (hash != null) _sentIdentifiers.add(hash);
            _grabbed = true;
            _onGrabSucceeded('Sent to qBittorrent');
          } else {
            snackBar('qBittorrent rejected the magnet', severity: InfoBarSeverity.error);
          }
        case SonarrRelease():
          await TorrentManager.sonarrRepository!.grabRelease(r.guid, r.indexerId);
          if (!mounted) return;

          _sentIdentifiers.add(r.guid);
          _grabbed = true;
          _onGrabSucceeded('Sent to Sonarr');
      }
    } catch (e) {
      if (mounted) snackBar('Download failed: $e', severity: InfoBarSeverity.error);
    } finally {
      if (mounted && !_grabbed) setState(() => _isDownloading = false);
    }
  }

  void _onGrabSucceeded(String message) {
    snackBar(message,
        severity: InfoBarSeverity.success,
        action: Button(
          child: const Text('View Downloads'),
          onPressed: () {
            closeDialog();
            context.read<NavigationManager>().pushPane(NavigationManager.TorrentPane);
          },
        ));

    if (widget.isSeasonSearch) {
      backToSearch();
    } else {
      closeDialog();
    }
  }

  @override
  void initState() {
    super.initState();
    widget.item?.controller = this;
    _destFolderController = TextEditingController(text: _initialDestFolder());
    _liveSearch = SettingsManager().knabenLiveSearch;
    _sonarrAvailable = TorrentManager.sonarrRepository != null && (widget.sonarrEpisodeId != null || widget.sonarrSeriesId != null);

    final name = widget.seriesTitles.isNotEmpty ? widget.seriesTitles.first : "Unknown";
    final tag = _searchTag();
    _searchController = TextEditingController(text: tag != null ? '$name $tag' : name);
    _isCustomSearch = widget.episodeTitle != null;
    _startSearch();
    _loadQbitTorrents();
  }

  /// Snapshot qBittorrent's current torrent list to mark already-downloading results in the UI
  Future<void> _loadQbitTorrents() async {
    final client = TorrentManager.torrentClient;
    if (client == null) return;
    try {
      final torrents = await client.listTorrents();
      if (!mounted) return;

      setState(() => _qbitHashes = torrents.map((t) => t.hash.toLowerCase()).toSet());
    } catch (e) {
      logErr('[KnabenSearch] Failed to load qBittorrent torrent list', e);
    }
  }

  @override
  void dispose() {
    widget.item?.controller = null;
    _searchController.dispose();
    _destFolderController.dispose();
    super.dispose();
  }

  KnabenSearchMode get _knabenMode => _liveSearch ? KnabenSearchMode.live : KnabenSearchMode.fast;

  void _startSearch() {
    setState(() {
      if (_provider == _SearchProvider.sonarr) {
        _startSonarrSearch();
      } else {
        _startKnabenSearch();
      }
    });
  }

  void _startKnabenSearch() {
    try {
      if (_isCustomSearch) {
        _knabenFuture = widget.controller.searchKnaben(_searchController.text, modeOverride: _knabenMode);
        return;
      }

      if (widget.seriesTitles.isEmpty) throw Exception("No titles provided for search");

      if (widget.isSeasonSearch && widget.season != null) {
        _knabenFuture = widget.controller.searchSeason(titles: widget.seriesTitles, season: widget.season!, modeOverride: _knabenMode);
      } else if (widget.season != null && widget.episode != null) {
        _knabenFuture = widget.controller.searchEpisode(
          titles: widget.seriesTitles,
          season: widget.season!,
          episode: widget.episode!,
          modeOverride: _knabenMode,
        );
      } else {
        _knabenFuture = widget.controller.searchKnaben(widget.seriesTitles.first, modeOverride: _knabenMode);
      }
    } catch (e) {
      _knabenFuture = Future.error(e);
      logErr('Failed to start Knaben search', e);
    }
  }

  void _startSonarrSearch() {
    final sonarr = TorrentManager.sonarrRepository;
    if (sonarr == null) {
      _sonarrFuture = Future.error("Sonarr is not configured");
      return;
    }

    try {
      if (widget.isSeasonSearch && widget.sonarrSeriesId != null) {
        _sonarrFuture = sonarr.searchReleases(sonarrSeriesId: widget.sonarrSeriesId!, seasonNumber: widget.season ?? 1);
      } else if (widget.sonarrEpisodeId != null) {
        _sonarrFuture = sonarr.searchEpisodeReleases(widget.sonarrEpisodeId!);
      } else {
        _sonarrFuture = Future.error("No Sonarr episode or series ID available for search");
      }
    } catch (e) {
      _sonarrFuture = Future.error(e);
      logErr('Failed to start Sonarr search', e);
    }
  }

  void _onProviderChanged(_SearchProvider provider) {
    if (provider == _provider) return;

    setState(() => _provider = provider);
    _startSearch();
  }

  /// Run the user's typed query for Knaben searches
  void _runCustomSearch() {
    _isCustomSearch = true;
    _startSearch();
  }

  void _onLiveSearchToggled(bool value) {
    setState(() => _liveSearch = value);
    SettingsManager().knabenLiveSearch = value;
    _startSearch();
  }

  /// Short label for the current search target
  ///
  /// `S01E03` for an episode, `S01` for a season pack, original title for specials/movies
  String? _searchTag() {
    if (widget.episodeTitle != null && widget.episodeTitle!.isNotEmpty) return widget.episodeTitle;
    if (widget.isSeasonSearch && widget.season != null) return 'S${widget.season.toString().padLeft(2, '0')}';
    if (widget.season != null && widget.episode != null) return 'S${widget.season.toString().padLeft(2, '0')}E${widget.episode.toString().padLeft(2, '0')}';
    return null;
  }

  String get _dialogTitle {
    final type = widget.isSeasonSearch ? "Season" : "Episode";
    final base = "$type Search";
    if (widget.seriesTitles.isEmpty) return base;
    final name = widget.seriesTitles.first;
    final tag = _searchTag();
    return tag != null ? '$base — $name $tag' : '$base — $name';
  }

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      _Step.search => _buildSearchDialog(),
      _Step.confirm => _buildConfirmDialog(),
    };
  }

  Widget _buildSearchDialog() {
    return ContentDialog(
      title: Text(_dialogTitle, style: Manager.subtitleStyle),
      constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
      content: Column(
        children: [
          // Search bar row for Knaben
          if (_provider == _SearchProvider.knaben)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextBox(
                      controller: _searchController,
                      placeholder: "Modify search query...",
                      style: Manager.bodyStyle,
                      onSubmitted: (_) => _runCustomSearch(),
                      suffix: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: StandardButton.icon(
                          icon: const Icon(Icons.search, size: 16),
                          onPressed: _runCustomSearch,
                          tooltip: 'Search',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Settings row
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              children: [
                // Provider selector
                ComboBox<_SearchProvider>(
                  value: _provider,
                  items: [
                    ComboBoxItem(
                      value: _SearchProvider.knaben,
                      child: const Text('Knaben'),
                    ),
                    if (_sonarrAvailable)
                      ComboBoxItem(
                        value: _SearchProvider.sonarr,
                        child: const Text('Sonarr'),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null) _onProviderChanged(v);
                  },
                ),

                // Fast / Live toggle (Knaben only)
                if (_provider == _SearchProvider.knaben) ...[
                  const SizedBox(width: 16),
                  ToggleSwitch(
                    checked: _liveSearch,
                    onChanged: _onLiveSearchToggled,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _liveSearch ? 'Live' : 'Fast',
                    style: Manager.captionStyle.copyWith(
                      color: _liveSearch ? const Color(0xFFFF9800) : Colors.white.withValues(alpha: .6),
                      fontWeight: _liveSearch ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Tooltip(
                    message: _liveSearch //
                        ? 'Live: queries all indexers in real-time (slower, more results)'
                        : 'Fast: searches local cache only (faster, fewer results)',
                    child: Icon(Icons.info_outline, size: 13, color: Colors.white.withValues(alpha: .3)),
                  ),
                ],

                const Spacer(),

                // Result count
                _buildResultCount(),
              ],
            ),
          ),

          const Divider(),
          const SizedBox(height: 4),

          // Results
          Expanded(
            child: _provider == _SearchProvider.knaben ? _buildKnabenResults() : _buildSonarrResults(),
          ),
        ],
      ),
      actions: [
        Button(
          child: const Text("Close"),
          onPressed: () => closeDialog(),
        ),
      ],
    );
  }

  Widget _buildConfirmDialog() {
    final r = _selectedRelease;
    if (r == null) return const SizedBox.shrink();

    final accentColor = Manager.currentDominantColor ?? Manager.accentColor;
    final isKnaben = r is KnabenRelease;

    return ContentDialog(
      title: Text('Confirm Download', style: Manager.subtitleStyle),
      constraints: const BoxConstraints(maxWidth: 700, maxHeight: 520),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Release summary card
          Card(
            borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.title, style: Manager.bodyStyle.copyWith(fontWeight: FontWeight.w600), maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                DefaultTextStyle(
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: .6)),
                  child: Row(
                    children: [
                      _Badge(label: r.quality, color: qualityBadgeColor(r.quality)),
                      const SizedBox(width: 6),
                      Text(fileSize(r.bytes)),
                      _dot(),
                      Text(r.tracker, style: const TextStyle(fontStyle: FontStyle.italic)),
                      const Spacer(),
                      Icon(Icons.arrow_upward, size: 12, color: const Color(0xFF4CAF50)),
                      const SizedBox(width: 2),
                      Text('${r.seeders}', style: const TextStyle(color: Color(0xFF4CAF50))),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_downward, size: 12, color: Colors.red),
                      const SizedBox(width: 2),
                      Text('${r.peers}', style: TextStyle(color: Colors.red.withValues(alpha: .8))),
                    ],
                  ),
                ),
                if (r.isLikelyBatch) ...[
                  const SizedBox(height: 4),
                  _Badge(label: 'BATCH', color: accentColor),
                ],
                if (r is KnabenRelease && r.virusDetection > 0.5) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 13, color: const Color(0xFFFF9800)),
                      const SizedBox(width: 4),
                      Text('Virus detection score: ${r.virusDetection}', style: const TextStyle(fontSize: 11, color: Color(0xFFFF9800))),
                    ],
                  ),
                ],
                if (r is SonarrRelease && r.rejected && r.rejections.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.block, size: 13, color: Colors.red.withValues(alpha: .7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(r.rejections.join(', '), style: TextStyle(fontSize: 11, color: Colors.red.withValues(alpha: .7)), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text('Destination folder', style: Manager.bodyStrongStyle),
          const SizedBox(height: 6),
          if (isKnaben)
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _destFolderController,
              builder: (_, __, ___) => TextBox(
                controller: _destFolderController,
                placeholder: 'e.g. M:\\Videos\\Series\\Series Name\\Season 01',
              ),
            )
          else
            Text(
              'Sonarr will place this in its configured series folder.',
              style: Manager.captionStyle.copyWith(color: Colors.white.withValues(alpha: .5)),
            ),
        ],
      ),
      actions: [
        Button(
          onPressed: _isDownloading ? null : backToSearch,
          child: const Text('Back'),
        ),
        if (isKnaben)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _destFolderController,
            builder: (_, v, __) => FilledButton(
              onPressed: (_isDownloading || v.text.trim().isEmpty) ? null : _doDownload,
              child: _isDownloading ? const SizedBox(width: 16, height: 16, child: RepaintBoundary(child: ProgressRing(strokeWidth: 2))) : const Text('Download'),
            ),
          )
        else
          FilledButton(
            onPressed: _isDownloading ? null : _doDownload,
            child: _isDownloading ? const SizedBox(width: 16, height: 16, child: RepaintBoundary(child: ProgressRing(strokeWidth: 2))) : const Text('Grab via Sonarr'),
          ),
      ],
    );
  }

  Widget _dot() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text('\u00B7', style: TextStyle(color: Colors.white.withValues(alpha: .3))),
      );

  Widget _buildResultCount() {
    if (_provider == _SearchProvider.knaben && _knabenFuture != null) {
      return FutureBuilder<List<KnabenRelease>>(
        future: _knabenFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(
              '${snapshot.data!.length} results',
              style: Manager.miniBodyStyle.copyWith(color: Colors.white.withValues(alpha: .5)),
            );
          }
          return const SizedBox.shrink();
        },
      );
    } else if (_provider == _SearchProvider.sonarr && _sonarrFuture != null) {
      return FutureBuilder<List<SonarrRelease>>(
        future: _sonarrFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(
              '${snapshot.data!.length} results',
              style: Manager.miniBodyStyle.copyWith(color: Colors.white.withValues(alpha: .5)),
            );
          }
          return const SizedBox.shrink();
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildKnabenResults() {
    if (_knabenFuture == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 48, color: Colors.white.withValues(alpha: .3)),
            const SizedBox(height: 12),
            Text('Press Search to begin', style: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: .5))),
          ],
        ),
      );
    }

    return FutureBuilder<List<KnabenRelease>>(
      future: _knabenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ProgressRing(),
                const SizedBox(height: 16),
                Text(
                  _liveSearch ? "Querying indexers..." : "Searching cache...",
                  style: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: .5)),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text('Search failed', style: Manager.bodyStrongStyle),
                const SizedBox(height: 4),
                Text(
                  '${snapshot.error}',
                  style: Manager.miniBodyStyle.copyWith(color: Colors.white.withValues(alpha: .5)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                StandardButton.label(label: 'Retry', onPressed: _startSearch),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.white.withValues(alpha: .3)),
                const SizedBox(height: 12),
                Text('No releases found', style: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: .5))),
              ],
            ),
          );
        }

        final releases = snapshot.data!;
        releases.sort((a, b) => b.seeders.compareTo(a.seeders));

        return SmoothScroll(
          enableSmoothScroll: Manager.animationsEnabled,
          builder: (context, controller, physics) {
            return ListView.builder(
              controller: controller,
              physics: physics,
              padding: const EdgeInsets.only(top: 4),
              itemCount: releases.length,
              itemBuilder: (context, index) {
                final release = releases[index];
                final hash = extractBtih(release.magnetUrl);
                final isSent = hash != null && _sentIdentifiers.contains(hash);
                final isAlreadyDownloading = hash != null && _qbitHashes.contains(hash);

                return _KnabenReleaseTile(
                  release: release,
                  onSelected: () => _goToConfirm(release),
                  isSent: isSent,
                  isAlreadyDownloading: isAlreadyDownloading,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSonarrResults() {
    if (_sonarrFuture == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: Colors.white.withValues(alpha: .3)),
            const SizedBox(height: 12),
            Text('No Sonarr search available', style: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: .5))),
          ],
        ),
      );
    }

    return FutureBuilder<List<SonarrRelease>>(
      future: _sonarrFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ProgressRing(),
                const SizedBox(height: 16),
                Text(
                  "Querying indexers...",
                  style: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: .5)),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text('Search failed', style: Manager.bodyStrongStyle),
                const SizedBox(height: 4),
                Text(
                  '${snapshot.error}',
                  style: Manager.miniBodyStyle.copyWith(color: Colors.white.withValues(alpha: .5)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.white.withValues(alpha: .3)),
                const SizedBox(height: 12),
                Text('No releases found', style: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: .5))),
              ],
            ),
          );
        }

        final releases = snapshot.data!;
        releases.sort((a, b) {
          if (a.rejected && !b.rejected) return 1;
          if (!a.rejected && b.rejected) return -1;
          return b.seeders.compareTo(a.seeders);
        });

        return SmoothScroll(
          enableSmoothScroll: Manager.animationsEnabled,
          builder: (context, controller, physics) {
            return ListView.builder(
              controller: controller,
              physics: physics,
              padding: const EdgeInsets.only(top: 4),
              itemCount: releases.length,
              itemBuilder: (context, index) {
                final release = releases[index];

                return _SonarrReleaseTile(
                  release: release,
                  onSelected: () => _goToConfirm(release),
                  isSent: _sentIdentifiers.contains(release.guid),
                );
              },
            );
          },
        );
      },
    );
  }
}

// Knaben release tile

class _KnabenReleaseTile extends StatefulWidget {
  final KnabenRelease release;
  final VoidCallback onSelected;
  final bool isSent;
  final bool isAlreadyDownloading;

  const _KnabenReleaseTile({
    required this.release,
    required this.onSelected,
    this.isSent = false,
    this.isAlreadyDownloading = false,
  });

  @override
  State<_KnabenReleaseTile> createState() => _KnabenReleaseTileState();
}

class _KnabenReleaseTileState extends State<_KnabenReleaseTile> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.release;
    final hasVirus = r.virusDetection > 0.5;
    final accentColor = Manager.currentDominantColor ?? Manager.accentColor;
    // isSent wins over isAlreadyDownloading: a release the user just grabbed
    // takes the "Sent" label even if it was already in qBittorrent before
    final disabled = widget.isSent || widget.isAlreadyDownloading;
    final disabledOpacity = hasVirus ? 0.45 : (disabled ? 0.6 : 1.0);

    return Opacity(
      opacity: disabledOpacity,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
            color: _isHovering && !disabled ? Colors.white.withValues(alpha: .03) : Colors.transparent,
          ),
          child: Card(
            borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Title + download button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        r.title,
                        style: Manager.bodyStyle.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (widget.isSent)
                      StandardButton.iconLabel(
                        icon: const Icon(Icons.check_circle, size: 16, color: Color(0xFF4CAF50)),
                        label: const Text('Sent'),
                        onPressed: null,
                        isSmall: true,
                      )
                    else if (widget.isAlreadyDownloading)
                      StandardButton.iconLabel(
                        icon: const Icon(Icons.downloading, size: 16),
                        label: const Text('Already downloading'),
                        onPressed: null,
                        isSmall: true,
                      )
                    else
                      StandardButton.iconLabel(
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Download'),
                        onPressed: widget.onSelected,
                        isFilled: true,
                        isSmall: true,
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Row 2: Metadata badges + seeder/peer info
                DefaultTextStyle(
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: .6)),
                  child: Row(
                    children: [
                      _Badge(label: r.quality, color: qualityBadgeColor(r.quality)),
                      const SizedBox(width: 6),
                      Text(fileSize(r.bytes)),
                      _dot(),
                      Text(r.tracker, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                      if (r.isLikelyBatch) ...[
                        const SizedBox(width: 6),
                        _Badge(label: 'BATCH', color: accentColor),
                      ],
                      const Spacer(),
                      Icon(Icons.arrow_upward, size: 12, color: const Color(0xFF4CAF50)),
                      const SizedBox(width: 2),
                      Text('${r.seeders}', style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 11)),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_downward, size: 12, color: Colors.red.withValues(alpha: .8)),
                      const SizedBox(width: 2),
                      Text('${r.peers}', style: TextStyle(color: Colors.red.withValues(alpha: .8), fontSize: 11)),
                    ],
                  ),
                ),

                if (hasVirus) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 13, color: const Color(0xFFFF9800)),
                      const SizedBox(width: 4),
                      Text(
                        'Virus detection score: ${r.virusDetection}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFFF9800)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dot() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text('\u00B7', style: TextStyle(color: Colors.white.withValues(alpha: .3))),
      );
}

// Sonarr release tile

class _SonarrReleaseTile extends StatefulWidget {
  final SonarrRelease release;
  final VoidCallback onSelected;
  final bool isSent;

  const _SonarrReleaseTile({
    required this.release,
    required this.onSelected,
    this.isSent = false,
  });

  @override
  State<_SonarrReleaseTile> createState() => _SonarrReleaseTileState();
}

class _SonarrReleaseTileState extends State<_SonarrReleaseTile> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.release;
    final accentColor = Manager.currentDominantColor ?? Manager.accentColor;
    final tileOpacity = r.rejected ? 0.5 : (widget.isSent ? 0.6 : 1.0);
    final disabled = r.rejected || widget.isSent;

    return Opacity(
      opacity: tileOpacity,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
            color: _isHovering && !disabled ? Colors.white.withValues(alpha: .03) : Colors.transparent,
          ),
          child: Card(
            borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
            padding: const EdgeInsets.all(12.0),
            backgroundColor: r.rejected ? Colors.red.withValues(alpha: .04) : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        r.title,
                        style: Manager.bodyStyle.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (widget.isSent)
                      StandardButton.iconLabel(
                        icon: const Icon(Icons.check_circle, size: 16, color: Color(0xFF4CAF50)),
                        label: const Text('Sent'),
                        onPressed: null,
                        isSmall: true,
                      )
                    else
                      StandardButton.iconLabel(
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Grab'),
                        onPressed: r.rejected ? null : widget.onSelected,
                        isFilled: !r.rejected,
                        isSmall: true,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                DefaultTextStyle(
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: .6)),
                  child: Row(
                    children: [
                      _Badge(label: r.quality, color: qualityBadgeColor(r.quality)),
                      const SizedBox(width: 6),
                      Text(fileSize(r.size)),
                      _dot(),
                      Text(r.indexer, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                      if (r.isLikelyBatch) ...[
                        const SizedBox(width: 6),
                        _Badge(label: 'BATCH', color: accentColor),
                      ],
                      const Spacer(),
                      Icon(Icons.arrow_upward, size: 12, color: const Color(0xFF4CAF50)),
                      const SizedBox(width: 2),
                      Text('${r.seeders}', style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 11)),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_downward, size: 12, color: Colors.red.withValues(alpha: .8)),
                      const SizedBox(width: 2),
                      Text('${r.leechers}', style: TextStyle(color: Colors.red.withValues(alpha: .8), fontSize: 11)),
                    ],
                  ),
                ),
                if (r.rejected && r.rejections.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.block, size: 13, color: Colors.red.withValues(alpha: .7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          r.rejections.join(', '),
                          style: TextStyle(fontSize: 11, color: Colors.red.withValues(alpha: .7)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dot() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text('\u00B7', style: TextStyle(color: Colors.white.withValues(alpha: .3))),
      );
}

// Shared badge widget

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
