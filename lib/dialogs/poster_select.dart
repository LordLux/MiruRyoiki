import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:transparent_image/transparent_image.dart';
import 'package:provider/provider.dart';

import '../enums.dart';
import '../models/series.dart';
import '../models/library.dart';
import '../services/navigation/dialogs.dart';
import '../services/navigation/show_info.dart';
import '../services/cache.dart';

class PosterSelectionDialog extends ManagedDialog {
  final Series series;

  PosterSelectionDialog({
    super.key,
    required this.series,
    required super.popContext,
    super.title = const Text('Select Poster Image'),
    super.constraints = const BoxConstraints(maxWidth: 600, maxHeight: 500),
  }) : super(
          contentBuilder: (context, constraints) => _PosterSelectionContent(
            series: series,
            constraints: constraints,
            onSave: (source) {
              // Save the selection
              final library = Provider.of<Library>(popContext, listen: false);
              series.preferredPosterSource = source;
              library.saveSeries(series);

              // Close dialog
              closeDialog(popContext, result: source);

              // Show confirmation
              snackBar(
                'Poster preference saved',
                severity: InfoBarSeverity.success,
              );
            },
            onCancel: () {
              closeDialog(popContext);
            },
          ),
          actions: (_) => [],
        );
}

class _PosterSelectionContent extends StatefulWidget {
  final Series series;
  final BoxConstraints constraints;
  final Function(PosterSource) onSave;
  final VoidCallback onCancel;

  const _PosterSelectionContent({
    required this.series,
    required this.constraints,
    required this.onSave,
    required this.onCancel,
  });

  @override
  _PosterSelectionContentState createState() => _PosterSelectionContentState();
}

class _PosterSelectionContentState extends State<_PosterSelectionContent> {
  late PosterSource _selectedSource;
  bool _localImageLoading = false;
  bool _anilistImageLoading = false;
  ImageProvider? _localPosterProvider;
  ImageProvider? _anilistPosterProvider;

  @override
  void initState() {
    super.initState();
    _selectedSource = widget.series.preferredPosterSource;
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() {
      _localImageLoading = widget.series.folderImagePath != null;
      _anilistImageLoading = widget.series.anilistData?.posterImage != null;
    });

    // Load local image
    if (widget.series.folderImagePath != null) {
      _localPosterProvider = FileImage(File(widget.series.folderImagePath!));
      if (mounted) setState(() => _localImageLoading = false);
    }

    // Load Anilist image
    if (widget.series.anilistData?.posterImage != null) {
      final imageCache = ImageCacheService();
      final cachedFile = await imageCache.getCachedImageFile(widget.series.anilistData!.posterImage!);

      if (cachedFile != null) {
        _anilistPosterProvider = FileImage(cachedFile);
      } else {
        _anilistPosterProvider = NetworkImage(widget.series.anilistData!.posterImage!);
        // Start caching in background
        imageCache.cacheImage(widget.series.anilistData!.posterImage!);
      }

      if (mounted) setState(() => _anilistImageLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose the poster image source for "${widget.series.name}"',
          style: FluentTheme.of(context).typography.bodyLarge,
        ),
        SizedBox(height: 20),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Local poster option
              Expanded(
                child: _buildPosterOption(
                  title: 'Local Folder Image',
                  isAvailable: widget.series.folderImagePath != null,
                  isLoading: _localImageLoading,
                  posterProvider: _localPosterProvider,
                  source: PosterSource.local,
                  unavailableMessage: 'No local image available',
                ),
              ),
              SizedBox(width: 16),
              // Anilist poster option
              Expanded(
                child: _buildPosterOption(
                  title: 'Anilist Image',
                  isAvailable: widget.series.anilistData?.posterImage != null,
                  isLoading: _anilistImageLoading,
                  posterProvider: _anilistPosterProvider,
                  source: PosterSource.anilist,
                  unavailableMessage: 'No Anilist image available',
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),
        // Status message
        Text(
          'Current preference: ${_getSourceDisplayName(widget.series.preferredPosterSource)}',
          style: FluentTheme.of(context).typography.bodyStrong,
        ),
        SizedBox(height: 20),
        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Button(
              onPressed: widget.onCancel,
              child: Text('Cancel'),
            ),
            SizedBox(width: 8),
            FilledButton(
              child: Text('Save Preference'),
              onPressed: () {
                widget.onSave(_selectedSource);
              },
            ),
          ],
        ),
      ],
    );
  }

  String _getSourceDisplayName(PosterSource source) {
    switch (source) {
      case PosterSource.local:
        return 'Local Image';
      case PosterSource.anilist:
        return 'Anilist Image';
      case PosterSource.unspecified:
        return 'Automatic (Local if available, otherwise Anilist)';
    }
  }

  Widget _buildPosterOption({
    required String title,
    required bool isAvailable,
    required bool isLoading,
    required ImageProvider? posterProvider,
    required PosterSource source,
    required String unavailableMessage,
  }) {
    final isSelected = _selectedSource == source;

    return GestureDetector(
      onTap: isAvailable
          ? () {
              setState(() {
                _selectedSource = source;
              });
            }
          : null,
      child: Card(
        padding: EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: isSelected ? FluentTheme.of(context).accentColor.withOpacity(0.1) : Colors.transparent,
        borderColor: isSelected ? FluentTheme.of(context).accentColor : FluentTheme.of(context).resources.controlStrokeColorDefault,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
            SizedBox(height: 12),
            Expanded(
              child: isAvailable
                  ? isLoading
                      ? Center(child: ProgressRing())
                      : posterProvider != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: FadeInImage(
                                placeholder: MemoryImage(kTransparentImage),
                                image: posterProvider,
                                fit: BoxFit.contain,
                                fadeInDuration: const Duration(milliseconds: 300),
                                fadeInCurve: Curves.easeIn,
                              ),
                            )
                          : Center(child: Text('Error loading image'))
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FluentIcons.error, size: 32, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(unavailableMessage),
                        ],
                      ),
                    ),
            ),
            SizedBox(height: 12),
            if (isAvailable)
              Row(
                children: [
                  RadioButton(
                    checked: _selectedSource == source,
                    onChanged: (_) {
                      setState(() {
                        _selectedSource = source;
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  Text('Use this image'),
                ],
              ),
            if (!isAvailable)
              Text(
                'Not available',
                style: FluentTheme.of(context).typography.caption,
              ),
          ],
        ),
      ),
    );
  }
}
