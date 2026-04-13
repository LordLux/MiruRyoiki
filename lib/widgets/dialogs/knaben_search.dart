import 'package:fluent_ui/fluent_ui.dart' hide Colors, FilledButton, ButtonStyle;
import 'package:flutter/material.dart' hide Card, Divider, Tooltip, ListTile, IconButton, showDialog;
import 'package:miruryoiki/utils/logging.dart';

import '../../models/knaben/knaben_release.dart';
import '../../models/sonarr/sonarr_release.dart';
import '../../services/downloads/download_controller.dart';
import '../../services/downloads/torrent_manager.dart';
import '../../services/knaben/knaben_service.dart';
import '../../services/navigation/dialogs.dart';
import '../../services/navigation/navigation.dart';
import '../../services/navigation/show_info.dart';
import '../../settings.dart';
import '../../manager.dart';
import '../../utils/units.dart';
import '../../utils/screen.dart';
import '../buttons/button.dart';

enum _SearchProvider { knaben, sonarr }

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
  });

  @override
  State<KnabenSearchDialog> createState() => _KnabenSearchDialogState();
}

class _KnabenSearchDialogState extends State<KnabenSearchDialog> {
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

  @override
  void initState() {
    super.initState();
    _liveSearch = SettingsManager().knabenLiveSearch;
    _sonarrAvailable = TorrentManager.sonarrRepository != null &&
        (widget.sonarrEpisodeId != null || widget.sonarrSeriesId != null);

    String initial = widget.seriesTitles.isNotEmpty ? widget.seriesTitles.first : "Unknown";
    if (widget.episodeTitle != null) {
      initial += ' ${widget.episodeTitle}';
    } else if (widget.isSeasonSearch && widget.season != null) {
      initial += ' S${widget.season.toString().padLeft(2, '0')}';
    } else if (widget.season != null && widget.episode != null) {
      initial += ' - ${widget.episode}';
    }
    _searchController = TextEditingController(text: initial);
    _isCustomSearch = widget.episodeTitle != null;
    _startSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
    setState(() {
      _provider = provider;
    });
    _startSearch();
  }

  void _onLiveSearchToggled(bool value) {
    setState(() {
      _liveSearch = value;
    });
    SettingsManager().knabenLiveSearch = value;
    _startSearch();
  }

  String get _dialogTitle {
    final type = widget.isSeasonSearch ? "Season" : "Episode";
    return "$type Search";
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(_dialogTitle, style: Manager.subtitleStyle),
      constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
      content: Column(
        children: [
          // Search bar row
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextBox(
                    controller: _searchController,
                    placeholder: "Modify search query...",
                    enabled: _provider == _SearchProvider.knaben,
                    style: Manager.bodyStyle,
                    onSubmitted: (_) {
                      _isCustomSearch = true;
                      _startSearch();
                    },
                    suffix: _provider == _SearchProvider.knaben
                        ? Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: StandardButton.icon(
                              icon: const Icon(Icons.search, size: 16),
                              onPressed: () {
                                _isCustomSearch = true;
                                _startSearch();
                              },
                              tooltip: 'Search',
                            ),
                          )
                        : null,
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
                    message: _liveSearch
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

        return ListView.builder(
          padding: const EdgeInsets.only(top: 4),
          itemCount: releases.length,
          itemBuilder: (context, index) {
            return _KnabenReleaseTile(
              release: releases[index],
              controller: widget.controller,
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

        return ListView.builder(
          padding: const EdgeInsets.only(top: 4),
          itemCount: releases.length,
          itemBuilder: (context, index) {
            return _SonarrReleaseTile(release: releases[index]);
          },
        );
      },
    );
  }
}


// Knaben release tile

class _KnabenReleaseTile extends StatefulWidget {
  final KnabenRelease release;
  final DownloadController controller;

  const _KnabenReleaseTile({required this.release, required this.controller});

  @override
  State<_KnabenReleaseTile> createState() => _KnabenReleaseTileState();
}

class _KnabenReleaseTileState extends State<_KnabenReleaseTile> {
  bool _isGrabbing = false;
  bool _grabbed = false;
  bool _isHovering = false;

  Future<void> _handleGrab() async {
    if (_isGrabbing || _grabbed) return;
    setState(() => _isGrabbing = true);
    try {
      final ok = await widget.controller.grabMagnet(
        widget.release.magnetUrl,
        savePath: widget.controller.sonarrSavePath,
      );
      if (mounted) {
        if (ok) {
          setState(() => _grabbed = true);
          snackBar('Sent to qBittorrent: ${widget.release.title}', severity: InfoBarSeverity.success);
        } else {
          snackBar('qBittorrent rejected the magnet', severity: InfoBarSeverity.error);
        }
      }
    } catch (e) {
      if (mounted) {
        snackBar('Failed to send to qBittorrent: $e', severity: InfoBarSeverity.error);
      }
    } finally {
      if (mounted) setState(() => _isGrabbing = false);
    }
  }

  Color get _qualityColor {
    switch (widget.release.quality) {
      case '2160p':
        return const Color(0xFFFFD700); // gold
      case '1080p':
        return const Color(0xFF4CAF50); // green
      case '720p':
        return const Color(0xFF2196F3); // blue
      case '480p':
        return const Color(0xFFFF9800); // orange
      default:
        return Colors.grey[120] ?? Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.release;
    final hasVirus = r.virusDetection > 0.5;
    final accentColor = Manager.currentDominantColor ?? Manager.accentColor;

    return Opacity(
      opacity: hasVirus ? 0.45 : 1.0,
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
                    _grabbed
                        ? Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(Icons.check_circle, size: 20, color: const Color(0xFF4CAF50)),
                          )
                        : StandardButton.iconLabel(
                            icon: _isGrabbing
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: RepaintBoundary(child: CircularProgressIndicator(strokeWidth: 2)),
                                  )
                                : const Icon(Icons.download, size: 16),
                            label: Text(_isGrabbing ? 'Sending...' : 'Download'),
                            onPressed: _isGrabbing ? null : _handleGrab,
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
                      // Quality badge
                      _Badge(label: r.quality, color: _qualityColor),
                      const SizedBox(width: 6),

                      // Size
                      Text(fileSize(r.bytes)),
                      _dot(),

                      // Tracker
                      Text(r.tracker, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),

                      // Batch badge
                      if (r.isLikelyBatch) ...[
                        const SizedBox(width: 6),
                        _Badge(label: 'BATCH', color: accentColor),
                      ],

                      const Spacer(),

                      // Seeders
                      Icon(Icons.arrow_upward, size: 12, color: const Color(0xFF4CAF50)),
                      const SizedBox(width: 2),
                      Text('${r.seeders}', style: TextStyle(color: const Color(0xFF4CAF50), fontSize: 11)),
                      const SizedBox(width: 8),

                      // Peers
                      Icon(Icons.arrow_downward, size: 12, color: Colors.red.withValues(alpha: .8)),
                      const SizedBox(width: 2),
                      Text('${r.peers}', style: TextStyle(color: Colors.red.withValues(alpha: .8), fontSize: 11)),
                    ],
                  ),
                ),

                // Virus warning
                if (hasVirus) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 13, color: const Color(0xFFFF9800)),
                      const SizedBox(width: 4),
                      Text(
                        'Virus detection score: ${r.virusDetection}',
                        style: TextStyle(fontSize: 11, color: const Color(0xFFFF9800)),
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

  const _SonarrReleaseTile({required this.release});

  @override
  State<_SonarrReleaseTile> createState() => _SonarrReleaseTileState();
}

class _SonarrReleaseTileState extends State<_SonarrReleaseTile> {
  bool _isDownloading = false;
  bool _downloaded = false;
  bool _isHovering = false;

  Future<void> _handleDownload() async {
    if (_isDownloading || _downloaded) return;
    setState(() => _isDownloading = true);

    try {
      await TorrentManager.sonarrRepository!.grabRelease(widget.release.guid, widget.release.indexerId);
      if (mounted) setState(() => _downloaded = true);
    } catch (e) {
      if (mounted) {
        showSimpleOneButtonManagedDialog(
          context,
          id: 'sonarr:download-error',
          title: 'Download Error',
          body: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.release;

    return Opacity(
      opacity: r.rejected ? 0.5 : 1.0,
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
            backgroundColor: r.rejected ? Colors.red.withValues(alpha: .04) : null,
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
                    _downloaded
                        ? Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(Icons.check_circle, size: 20, color: const Color(0xFF4CAF50)),
                          )
                        : _isDownloading
                            ? const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: SizedBox(width: 20, height: 20, child: RepaintBoundary(child: ProgressRing(strokeWidth: 2))),
                              )
                            : StandardButton.iconLabel(
                                icon: const Icon(Icons.download, size: 16),
                                label: const Text('Grab'),
                                onPressed: r.rejected ? null : _handleDownload,
                                isFilled: !r.rejected,
                                isSmall: true,
                              ),
                  ],
                ),

                const SizedBox(height: 8),

                // Row 2: Metadata
                DefaultTextStyle(
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: .6)),
                  child: Row(
                    children: [
                      // Quality badge
                      _Badge(label: r.quality, color: _qualityColorFor(r.quality)),
                      const SizedBox(width: 6),

                      // Size
                      Text(fileSize(r.size)),
                      _dot(),

                      // Indexer
                      Text(r.indexer, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),

                      // Batch badge
                      if (r.isLikelyBatch) ...[
                        const SizedBox(width: 6),
                        _Badge(label: 'BATCH', color: Manager.currentDominantColor ?? Manager.accentColor),
                      ],

                      const Spacer(),

                      // Seeders
                      Icon(Icons.arrow_upward, size: 12, color: const Color(0xFF4CAF50)),
                      const SizedBox(width: 2),
                      Text('${r.seeders}', style: TextStyle(color: const Color(0xFF4CAF50), fontSize: 11)),
                      const SizedBox(width: 8),

                      // Leechers
                      Icon(Icons.arrow_downward, size: 12, color: Colors.red.withValues(alpha: .8)),
                      const SizedBox(width: 2),
                      Text('${r.leechers}', style: TextStyle(color: Colors.red.withValues(alpha: .8), fontSize: 11)),
                    ],
                  ),
                ),

                // Rejections
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

  Color _qualityColorFor(String quality) {
    final lower = quality.toLowerCase();
    if (lower.contains('2160') || lower.contains('4k')) return const Color(0xFFFFD700);
    if (lower.contains('1080')) return const Color(0xFF4CAF50);
    if (lower.contains('720')) return const Color(0xFF2196F3);
    if (lower.contains('480')) return const Color(0xFFFF9800);
    return Colors.grey[120] ?? Colors.grey;
  }
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
