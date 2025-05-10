import 'dart:io';
import 'dart:math';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:provider/provider.dart';

import '../enums.dart';
import '../main.dart';
import '../manager.dart';
import '../models/series.dart';
import '../models/library.dart';
import '../screens/series.dart';
import '../services/navigation/dialogs.dart';
import '../services/navigation/show_info.dart';
import '../services/cache.dart';
import '../utils/image_utils.dart';
import '../utils/screen_utils.dart';
import '../widgets/transparency_shadow_image.dart';

class PosterSelectionDialog extends ManagedDialog {
  final Series series;

  PosterSelectionDialog({
    super.key,
    required this.series,
    required super.popContext,
    super.title = const Text('Select Poster Image'),
    super.constraints = const BoxConstraints(maxWidth: 1000, maxHeight: 700),
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
  // ignore: unused_field
  ImageProvider? _localPosterProvider;
  ImageProvider? _anilistPosterProvider;

  List<File> _localImageFiles = [];
  int _selectedLocalImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedSource = widget.series.preferredPosterSource ?? Manager.defaultPosterSource;
    _loadImages();
  }

  Future<void> _findLocalImages() async {
    final directory = Directory(widget.series.path);

    final List<FileSystemEntity> entities = await directory.list().toList();

    // Filter for image files
    _localImageFiles = entities.whereType<File>().where((file) {
      final extension = file.path.toLowerCase().split('.').last;
      return ['jpg', 'jpeg', 'png', 'ico', 'webp'].contains(extension);
    }).toList();

    // Set selected index to current poster if it exists
    if (widget.series.folderImagePath != null) {
      final index = _localImageFiles.indexWhere((f) => f.path == widget.series.folderImagePath);
      if (index >= 0) _selectedLocalImageIndex = index;
    }

    if (_localImageFiles.isNotEmpty) {
      _loadSelectedLocalImage();
    }
  }

  Future<void> _loadImages() async {
    setState(() {
      _localImageLoading = true;
      _anilistImageLoading = widget.series.anilistData?.posterImage != null;
    });

    await _findLocalImages();

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

  void _loadSelectedLocalImage() {
    if (_localImageFiles.isNotEmpty && _selectedLocalImageIndex < _localImageFiles.length) {
      _localPosterProvider = FileImage(_localImageFiles[_selectedLocalImageIndex]);
      if (mounted) setState(() => _localImageLoading = false);
    } else {
      _localPosterProvider = null;
      if (mounted) setState(() => _localImageLoading = false);
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
                child: _localImageFiles.isEmpty
                    ? _buildPosterOption(
                        title: 'Local Folder Images',
                        isAvailable: false,
                        isLoading: _localImageLoading,
                        posterProvider: null,
                        source: PosterSource.local,
                        unavailableMessage: 'No local images available,\nPlease add images to the folder',
                      )
                    : _buildLocalImagesOption(),
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
                  linkToAnilistAction: () {
                    linkWithAnilist(
                      context,
                      widget.series,
                      (id) => seriesScreenKey.currentState!.loadAnilistData(id),
                      (_) => seriesScreenKey.currentState?.setState(() {}),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),
        // Status message
        Text(
          'Current preference: ${_getSourceDisplayName(widget.series.preferredPosterSource ?? Manager.defaultPosterSource)}',
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
      case PosterSource.autoLocal:
        return 'Automatic (Local if available, otherwise Anilist)';
      case PosterSource.autoAnilist:
        return 'Automatic (Anilist if available, otherwise Local)';
    }
  }

  Widget _buildPosterOption({
    required String title,
    required bool isAvailable,
    required bool isLoading,
    required ImageProvider? posterProvider,
    required PosterSource source,
    required String unavailableMessage,
    VoidCallback? linkToAnilistAction,
  }) {
    final isSelected = _selectedSource == source;
    final needsAnilistLink = source == PosterSource.anilist && widget.series.primaryAnilistId == null;

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
        backgroundColor: isSelected ? Manager.accentColor.lighter.withOpacity(0.1) : Colors.transparent,
        borderColor: isSelected ? Manager.accentColor.lighter : FluentTheme.of(context).resources.controlStrokeColorDefault,
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
                          Icon(FluentIcons.error, size: 32, color: Manager.accentColor.lightest),
                          SizedBox(height: 8),
                          Text(unavailableMessage, textAlign: TextAlign.center),
                          if (needsAnilistLink && linkToAnilistAction != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: FilledButton(
                                onPressed: linkToAnilistAction,
                                child: Text('Link to Anilist'),
                              ),
                            ),
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

  Widget _buildLocalImagesOption() {
    final isSelected = _selectedSource == PosterSource.local;
    // Track hovered image for filename display
    String? hoveredImageName;

    return StatefulBuilder(builder: (context, setStateLocal) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedSource = PosterSource.local;
          });
        },
        child: Card(
          padding: EdgeInsets.all(12),
          borderRadius: BorderRadius.circular(8),
          backgroundColor: isSelected ? Manager.accentColor.lighter.withOpacity(0.1) : Colors.transparent,
          borderColor: isSelected ? Manager.accentColor.lighter : FluentTheme.of(context).resources.controlStrokeColorDefault,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Local Folder Images (${_localImageFiles.length})',
                style: FluentTheme.of(context).typography.bodyStrong,
              ),
              SizedBox(height: 12),
              Expanded(
                child: _localImageLoading
                    ? Center(child: ProgressRing())
                    : Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 1,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _localImageFiles.length,
                              itemBuilder: (context, index) {
                                final file = _localImageFiles[index];
                                final fileName = file.path.split(Platform.pathSeparator).last;

                                return TooltipTheme(
                                  data: TooltipThemeData(
                                    decoration: BoxDecoration(color: Colors.transparent),
                                    waitDuration: const Duration(milliseconds: 500),
                                  ),
                                  child: Tooltip(
                                    enableFeedback: true,
                                    richMessage: WidgetSpan(
                                      child: LayoutBuilder(builder: (context, c) {
                                        print(ScreenUtils.width);
                                        final maxWidth = ScreenUtils.width * 0.5;
                                        final maxHeight = ScreenUtils.height * 0.7;
                                        return FutureBuilder(
                                            future: getImageDimensions(FileImage(file)),
                                            builder: (context, data) {
                                              if (!data.hasData) return SizedBox.shrink();

                                              final imageAspectRatio = data.data!.aspectRatio;
                                              double width, height;

                                              if (imageAspectRatio > 1) {
                                                // Wider than tall
                                                width = min(min(maxWidth, imageAspectRatio * maxHeight), data.data!.width);
                                                height = width / imageAspectRatio;
                                              } else {
                                                // Taller than wide or square
                                                height = min(min(maxHeight, maxWidth / imageAspectRatio), data.data!.height);
                                                width = height * imageAspectRatio;
                                              }

                                              final String dimensions = "${width.toInt()}x${height.toInt()}";
                                              final int dimensionsLength = dimensions.length;

                                              return SizedBox(
                                                width: width,
                                                height: height,
                                                child: Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Positioned.fill(
                                                      child: Transform.scale(
                                                        scale: 18,
                                                        child: Container(
                                                          color: Colors.black.withOpacity(.5),
                                                        ),
                                                      ),
                                                    ),
                                                    Acrylic(
                                                      blurAmount: 5,
                                                      elevation: 0.5,
                                                      tintAlpha: 0.5,
                                                      luminosityAlpha: 0.4,
                                                      child: ShadowedImage(imageProvider: FileImage(file)),
                                                    ),
                                                    Positioned(
                                                      bottom: 0,
                                                      child: Container(
                                                        height: 24,
                                                        width: width,
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            colors: [
                                                              Colors.black.withOpacity(0.5),
                                                              Colors.transparent,
                                                            ],
                                                            begin: Alignment.bottomCenter,
                                                            end: Alignment.topCenter,
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 6.0),
                                                          child: Text(
                                                            fileName,
                                                            style: FluentTheme.of(context).typography.body,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 0,
                                                      right: 0,
                                                      child: Container(
                                                        height: 40,
                                                        width: width,
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            colors: [
                                                              Colors.transparent,
                                                              Colors.black.withOpacity(0.5),
                                                            ],
                                                            begin: Alignment.bottomCenter,
                                                            end: Alignment.topCenter,
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(right: 6.0),
                                                          child: Text(
                                                            dimensions,
                                                            style: FluentTheme.of(context).typography.body,
                                                            maxLines: 1,
                                                            textAlign: TextAlign.end,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            });
                                      }),
                                    ),
                                    child: SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: MouseRegion(
                                        onEnter: (_) => setStateLocal(() => hoveredImageName = fileName),
                                        onExit: (_) => setStateLocal(() => hoveredImageName = null),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedLocalImageIndex = index;
                                              _loadSelectedLocalImage();
                                              _selectedSource = PosterSource.local;
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: index == _selectedLocalImageIndex ? Border.all(color: Manager.accentColor.light, width: 3) : null,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: FadeInImage(
                                                placeholder: MemoryImage(kTransparentImage),
                                                image: FileImage(file),
                                                fit: BoxFit.contain,
                                                fadeInDuration: const Duration(milliseconds: 300),
                                                fadeInCurve: Curves.easeIn,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Show filename of hovered image
                          Container(
                            height: 24,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              hoveredImageName ?? '',
                              style: FluentTheme.of(context).typography.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  RadioButton(
                    checked: _selectedSource == PosterSource.local,
                    onChanged: (_) {
                      setState(() {
                        _selectedSource = PosterSource.local;
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  Text('Use ${_localImageFiles.isEmpty ? "selected local image" : _localImageFiles[_selectedLocalImageIndex].path.split(Platform.pathSeparator).last}'),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
