import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:miruryoiki/utils/logging.dart';

import '../../models/knaben/knaben_release.dart';
import '../../services/downloads/download_controller.dart';
import '../../services/navigation/show_info.dart';
import '../../manager.dart';
import '../../utils/units.dart';
import '../buttons/button.dart';

/// Dialog that searches Knaben for releases and lets the user send a magnet link to qBittorrent with a single tap
class KnabenSearchDialog extends StatefulWidget {
  final DownloadController controller;
  final List<String> seriesTitles;
  final int? season;
  final int? episode;
  final bool isSeasonSearch;

  const KnabenSearchDialog({
    super.key,
    required this.controller,
    required this.seriesTitles,
    this.season,
    this.episode,
    this.isSeasonSearch = false,
  });

  @override
  State<KnabenSearchDialog> createState() => _KnabenSearchDialogState();
}

class _KnabenSearchDialogState extends State<KnabenSearchDialog> {
  late Future<List<KnabenRelease>> _searchFuture;
  late TextEditingController _searchController;
  bool _isCustomSearch = false;

  @override
  void initState() {
    super.initState();
    String initial = widget.seriesTitles.isNotEmpty ? widget.seriesTitles.first : "Unknown";
    if (widget.isSeasonSearch && widget.season != null) {
      initial += ' S${widget.season.toString().padLeft(2, '0')}';
    } else if (widget.season != null && widget.episode != null) {
      initial += ' - ${widget.episode}';
    }
    _searchController = TextEditingController(text: initial);
    _startSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      try {
        if (_isCustomSearch) {
          _searchFuture = widget.controller.searchKnaben(_searchController.text);
          return;
        }

        if (widget.seriesTitles.isEmpty) throw Exception("No titles provided for search");

        if (widget.isSeasonSearch && widget.season != null) {
          _searchFuture = widget.controller.searchSeason(titles: widget.seriesTitles, season: widget.season!);
        } else if (widget.season != null && widget.episode != null) {
          _searchFuture = widget.controller.searchEpisode(
            titles: widget.seriesTitles,
            season: widget.season!,
            episode: widget.episode!,
          );
        } else {
          // Fallback: free-text search
          _searchFuture = widget.controller.searchKnaben(widget.seriesTitles.first);
        }
      } catch (e) {
        _searchFuture = Future.error(e);
        logErr('Failed to start Knaben search', e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return mat.Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850, maxHeight: 650),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.isSeasonSearch ? "Season Search (Knaben)" : "Episode Search (Knaben)",
                      style: Manager.subtitleStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StandardButton.icon(
                    icon: const Icon(mat.Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const mat.Divider(),

              // Custom Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextBox(
                        controller: _searchController,
                        placeholder: "Modify search query...",
                        onSubmitted: (_) {
                          _isCustomSearch = true;
                          _startSearch();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    StandardButton(
                      label: const Text('Search'),
                      onPressed: () {
                        _isCustomSearch = true;
                        _startSearch();
                      },
                    ),
                  ],
                ),
              ),

              // Results
              Expanded(
                child: FutureBuilder<List<KnabenRelease>>(
                  future: _searchFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ProgressRing(),
                            SizedBox(height: 16),
                            Text("Searching Knaben..."),
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.red)),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No releases found on Knaben."));
                    }

                    final releases = snapshot.data!;
                    // Sort by seeders descending
                    releases.sort((a, b) => b.seeders.compareTo(a.seeders));

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: releases.length,
                      itemBuilder: (context, index) {
                        return _KnabenReleaseTile(
                          release: releases[index],
                          controller: widget.controller,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KnabenReleaseTile extends StatefulWidget {
  final KnabenRelease release;
  final DownloadController controller;

  const _KnabenReleaseTile({required this.release, required this.controller});

  @override
  State<_KnabenReleaseTile> createState() => _KnabenReleaseTileState();
}

class _KnabenReleaseTileState extends State<_KnabenReleaseTile> {
  bool _isGrabbing = false;

  Future<void> _handleGrab() async {
    setState(() => _isGrabbing = true);
    try {
      final ok = await widget.controller.grabMagnet(
        widget.release.magnetUrl,
        savePath: widget.controller.sonarrSavePath,
      );
      if (mounted) {
        if (ok) {
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

  @override
  Widget build(BuildContext context) {
    final r = widget.release;
    final theme = mat.Theme.of(context);
    final hasVirus = r.virusDetection > 0.5;

    return Opacity(
      opacity: hasVirus ? 0.5 : 1.0,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(r.title, style: theme.textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              // Metadata
              Row(
                children: [
                  // Quality badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(r.quality, style: theme.textTheme.bodySmall),
                  ),
                  const SizedBox(width: 8),
                  // Size
                  Text(fileSize(r.bytes), style: theme.textTheme.bodySmall),
                  const SizedBox(width: 8),
                  // Tracker
                  Text(r.tracker, style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                  const Spacer(),
                  // Seeders / peers
                  Icon(mat.Icons.arrow_upward, size: 14, color: mat.Colors.green[700]),
                  Text('${r.seeders}', style: theme.textTheme.bodySmall?.copyWith(color: mat.Colors.green[700])),
                  const SizedBox(width: 4),
                  Icon(mat.Icons.arrow_downward, size: 14, color: mat.Colors.red[700]),
                  Text('${r.peers}', style: theme.textTheme.bodySmall?.copyWith(color: mat.Colors.red[700])),
                ],
              ),
              if (hasVirus) ...[
                const SizedBox(height: 2),
                Text('⚠ virus detection score: ${r.virusDetection}', style: theme.textTheme.bodySmall?.copyWith(color: mat.Colors.orange)),
              ],
              const mat.Divider(),
              // Action row
              Row(
                children: [
                  if (r.isLikelyBatch)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: (Manager.currentDominantColor ?? mat.Colors.deepPurpleAccent).withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                        child: Text('BATCH', style: theme.textTheme.bodySmall?.copyWith(color: (Manager.currentDominantColor ?? mat.Colors.deepPurpleAccent))),
                      ),
                    ),
                  const Spacer(),
                  mat.ElevatedButton.icon(
                    onPressed: _isGrabbing ? null : _handleGrab,
                    icon: _isGrabbing ? const SizedBox(width: 16, height: 16, child: RepaintBoundary(child: mat.CircularProgressIndicator(strokeWidth: 2))) : const Icon(mat.Icons.download),
                    label: Text(_isGrabbing ? 'Sending...' : 'Download'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
