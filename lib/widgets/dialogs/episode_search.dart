import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;

import '../../screens/downloads_screen.dart';
import '../../models/sonarr/sonarr_release.dart';
import '../../services/sonarr/sonarr_service.dart';
import '../../manager.dart';
import '../buttons/button.dart';

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
    return mat.Dialog(
      // Use a constraint to prevent the dialog from taking up the whole screen
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.isSeasonSearch ? "Season Search" : "Episode Search", style: Manager.subtitleStyle),
                  StandardButton.icon(
                    icon: const Icon(mat.Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
              const mat.Divider(),

              // Results List
              Expanded(
                child: FutureBuilder<List<SonarrRelease>>(
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

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: releases.length,
                      itemBuilder: (context, index) {
                        return ReleaseTile(release: releases[index], sonarrRepo: widget.sonarrRepo);
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
