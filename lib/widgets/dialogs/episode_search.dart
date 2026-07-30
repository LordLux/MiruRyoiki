import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;

import '../../manager.dart';
import '../../models/torrent_release.dart';
import '../../services/sonarr/sonarr_service.dart';
import '../../services/navigation/dialog_functions.dart';
import '../../services/navigation/navigation.dart';
import '../../utils/units.dart';
import '../buttons/button.dart';
import '../smooth_scroll.dart';

class EpisodeSearchDialog extends StatefulWidget {
  final int? episodeId; // For single episode search
  final int? seriesId; // For season/batch search
  final bool isSeasonSearch;
  final SonarrRepository sonarrRepo;

  const EpisodeSearchDialog({
    super.key,
    this.episodeId,
    this.seriesId,
    this.isSeasonSearch = false,
    required this.sonarrRepo,
  });

  @override
  State<EpisodeSearchDialog> createState() => _EpisodeSearchDialogState();
}

class _EpisodeSearchDialogState extends State<EpisodeSearchDialog> {
  late Future<List<SonarrRelease>> _searchFuture;

  @override
  void initState() {
    super.initState();
    _startSearch();
  }

  void _startSearch() {
    if (widget.isSeasonSearch && widget.seriesId != null) {
      // Logic for batch search (Assuming Season 1 for this snippet, can be expanded)
      _searchFuture = widget.sonarrRepo.searchReleases(sonarrSeriesId: widget.seriesId!, seasonNumber: 1);
    } else if (widget.episodeId != null) {
      // Logic for single episode search
      _searchFuture = widget.sonarrRepo.searchEpisodeReleases(widget.episodeId!);
    } else {
      _searchFuture = Future.error("Invalid parameters for search");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(widget.isSeasonSearch ? "Season Search" : "Episode Search"),
      constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
      content: FutureBuilder<List<SonarrRelease>>(
        future: _searchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [ProgressRing(), SizedBox(height: 16), Text("Searching Indexers (this takes a few seconds)...")],
            ));
          }
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.red)));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No releases found via Sonarr/Prowlarr."));

          // Sort results: Rejections to bottom, then by seeds
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
                shrinkWrap: true,
                itemCount: releases.length,
                itemBuilder: (context, index) {
                  return _SonarrReleaseTile(release: releases[index], sonarrRepo: widget.sonarrRepo);
                },
              );
            },
          );
        },
      ),
      actions: [
        Button(
          child: const Text("Close"),
          onPressed: () => closeDialog(),
        ),
      ],
    );
  }
}

class _SonarrReleaseTile extends StatefulWidget {
  final SonarrRelease release;
  final SonarrRepository sonarrRepo;

  const _SonarrReleaseTile({required this.release, required this.sonarrRepo});

  @override
  State<_SonarrReleaseTile> createState() => _SonarrReleaseTileState();
}

class _SonarrReleaseTileState extends State<_SonarrReleaseTile> {
  bool _isDownloading = false;
  bool _downloaded = false;

  Future<void> _handleDownload() async {
    if (_isDownloading || _downloaded) return;
    setState(() {
      _isDownloading = true;
    });

    try {
      await widget.sonarrRepo.grabRelease(widget.release.guid, widget.release.indexerId);
      if (mounted) {
        setState(() {
          _downloaded = true;
        });
      }
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
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return mat.Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: widget.release.rejected ? mat.Colors.red.withOpacity(0.1) : null,
      child: mat.ListTile(
        title: Text(widget.release.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Quality: ${widget.release.quality} | Size: ${fileSize(widget.release.size)} | Seeders: ${widget.release.seeders}"),
            if (widget.release.rejected)
              Text("Rejected: ${widget.release.rejections.join(', ')}", style: const TextStyle(color: mat.Colors.red)),
          ],
        ),
        trailing: _downloaded
            ? const Icon(mat.Icons.check_circle, color: mat.Colors.green)
            : _isDownloading
                ? const ProgressRing()
                : StandardButton.icon(
                    icon: const Icon(mat.Icons.download),
                    onPressed: widget.release.rejected ? null : _handleDownload, // Disable button if rejected
                  ),
      ),
    );
  }
}
