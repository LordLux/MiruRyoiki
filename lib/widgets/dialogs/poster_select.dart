import 'dart:io';
import 'dart:math' show min;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import '../../enums.dart';
import '../../main.dart';
import '../../manager.dart';
import '../../models/series.dart';
import '../../services/library/library_provider.dart';
import '../../screens/series.dart';
import '../../services/navigation/dialogs.dart';
import '../../services/navigation/show_info.dart';
import '../../utils/image_utils.dart';
import '../../utils/logging.dart';
import '../../utils/path_utils.dart';
import '../../utils/screen_utils.dart';
import '../series_image.dart';
import '../transparency_shadow_image.dart';

class ImageSelectionDialog extends ManagedDialog {
  final Series series;

  ImageSelectionDialog({
    super.key,
    required this.series,
    required super.popContext,
    required isBanner,
    String? title,
    super.constraints = const BoxConstraints(maxWidth: 1000, maxHeight: 700),
  }) : super(
          title: Text(title ?? (isBanner ? 'Select Banner Image' : 'Select Poster Image')),
          contentBuilder: (context, constraints) => _ImageSelectionContent(
            series: series,
            constraints: constraints,
            isBanner: isBanner,
            onSave: (source, path) async {
              // Save the selection
              final library = Provider.of<Library>(popContext, listen: false);

              final Series updatedSeries = series.copyWith(
                folderPosterPath: isBanner ? series.folderPosterPath : (source == ImageSource.local ? path : series.folderPosterPath),
                folderBannerPath: isBanner ? (source == ImageSource.local ? path : series.folderBannerPath) : series.folderBannerPath,
                preferredPosterSource: isBanner ? series.preferredPosterSource : source,
                preferredBannerSource: isBanner ? source : series.preferredBannerSource,
              );

              logTrace('Saving ${isBanner ? 'banner' : 'poster'} preference: $source, path: ${PathUtils.getFileName(path)}');

              // Explicitly save the entire series and show confirmation
              library.updateSeries(updatedSeries).then((_) {
                snackBar(
                  isBanner ? 'Banner preference saved' : 'Poster preference saved',
                  severity: InfoBarSeverity.success,
                );
                Manager.setState();
              });
            },
          ),
        );
}

class _ImageSelectionContent extends StatefulWidget {
  final Series series;
  final BoxConstraints constraints;
  final Function(ImageSource, String) onSave;
  final VoidCallback? onCancel;
  final bool isBanner;

  const _ImageSelectionContent({
    required this.series,
    required this.constraints,
    required this.onSave,
    // ignore: unused_element_parameter
    this.onCancel,
    required this.isBanner,
  });

  @override
  _ImageSelectionContentState createState() => _ImageSelectionContentState();
}

class _ImageSelectionContentState extends State<_ImageSelectionContent> {
  late ImageSource _selectedSource;
  bool _localImageLoading = false;
  bool _anilistImageLoading = false;
  // ignore: unused_field
  ImageProvider? _localImageProvider;
  ImageProvider? _anilistImageProvider;

  List<File> _localImageFiles = [];
  int? _selectedLocalImageIndex;

  @override
  void initState() {
    super.initState();
    _selectedSource = widget.isBanner //
        ? widget.series.preferredBannerSource ?? Manager.defaultPosterSource
        : widget.series.preferredPosterSource ?? Manager.defaultPosterSource;

    // Don't start with any selection if using auto sources
    if (_selectedSource != ImageSource.local) {
      logTrace('Starting with no local image selected');
      _selectedLocalImageIndex = null;
    }

    _loadImages();
  }

  void _selectAnilistImage() {
    setState(() {
      _selectedSource = ImageSource.anilist;
      _selectedLocalImageIndex = null; // Deselect any local image
    });
  }

  void _deselectEverything() {
    setState(() {
      if (widget.isBanner) {
        widget.series.preferredBannerSource = null;
        _selectedSource = Manager.defaultPosterSource;
      } else {
        widget.series.preferredPosterSource = null;
        _selectedSource = Manager.defaultPosterSource;
      }
      _selectedLocalImageIndex = null; // Deselect any local image
    });
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
    if (_selectedSource == ImageSource.local && widget.isBanner && widget.series.folderBannerPath != null) {
      final index = _localImageFiles.indexWhere((f) => f.path == widget.series.folderBannerPath);
      if (index >= 0) _selectedLocalImageIndex = index;
      // Set selected index to current bannerif it exists
    } else if (_selectedSource == ImageSource.local && !widget.isBanner && widget.series.folderPosterPath != null) {
      final index = _localImageFiles.indexWhere((f) => f.path == widget.series.folderPosterPath);
      if (index >= 0) _selectedLocalImageIndex = index;
    }

    if (_localImageFiles.isNotEmpty) {
      _loadSelectedLocalImage();
    }
  }

  Future<void> _loadImages() async {
    setState(() {
      _localImageLoading = true;

      // Check for the correct image type based on what we're selecting
      final String? anilistImageUrl = widget.isBanner
          ? widget.series.anilistData?.bannerImage // banner URL
          : widget.series.anilistData?.posterImage; // poster URL

      _anilistImageLoading = anilistImageUrl != null;
    });

    await _findLocalImages();

    // Load Anilist image using the centralized method
    if (widget.isBanner) {
      if (widget.series.isAnilistBanner) {
        final anilistImageProvider = await widget.series.getBannerImage();
        if (anilistImageProvider != null) //
          _anilistImageProvider = anilistImageProvider;
      }
    } else {
      if (widget.series.isAnilistPoster) {
        final anilistImageProvider = await widget.series.getPosterImage();
        if (anilistImageProvider != null) //
          _anilistImageProvider = anilistImageProvider;
      }
    }

    if (mounted) setState(() => _anilistImageLoading = false);
  }

  void _loadSelectedLocalImage() {
    if (_localImageFiles.isNotEmpty && //
        _selectedLocalImageIndex != null &&
        _selectedLocalImageIndex! < _localImageFiles.length &&
        _selectedLocalImageIndex! >= 0)
      _localImageProvider = FileImage(_localImageFiles[_selectedLocalImageIndex!]);
    else
      _localImageProvider = null;

    if (mounted) setState(() => _localImageLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose the ${widget.isBanner ? 'banner' : 'poster'} image source for "${widget.series.name}"',
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
                        source: ImageSource.local,
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
                  posterProvider: _anilistImageProvider,
                  source: ImageSource.anilist,
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
        _canSavePreference()
            ? Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: 'New preference: ',
                    style: FluentTheme.of(context).typography.bodyStrong,
                  ),
                  TextSpan(
                    text: _getSourceDisplayName(_selectedSource),
                    style: FluentTheme.of(context).typography.bodyStrong!.copyWith(color: Manager.accentColor.lighter),
                  ),
                ]),
              )
            : Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: 'Current preference: ',
                    style: FluentTheme.of(context).typography.bodyStrong,
                  ),
                  TextSpan(
                    text: widget.isBanner ? _getSourceDisplayName(widget.series.preferredBannerSource ?? Manager.defaultPosterSource) : _getSourceDisplayName(widget.series.preferredPosterSource ?? Manager.defaultPosterSource),
                    style: FluentTheme.of(context).typography.bodyStrong,
                  ),
                ]),
              ),
        SizedBox(height: 20),
        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TooltipTheme(
              data: TooltipThemeData(
                waitDuration: const Duration(milliseconds: 100),
              ),
              child: Tooltip(
                message: 'Reset to ${_getSourceDisplayName(Manager.defaultPosterSource)}\nThis setting can be changed in settings',
                child: ManagedDialogButton(
                  popContext: context,
                  onPressed: () {
                    _deselectEverything();
                    Manager.setState();
                  },
                  text: 'Reset to Auto',
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ManagedDialogButton(
                  text: 'Cancel',
                  popContext: context,
                  onPressed: () => widget.onCancel?.call(),
                ),
                SizedBox(width: 8),
                Tooltip(
                  message: _canSavePreference() ? 'Save the selected image preference' : 'Select an image first',
                  child: ManagedDialogButton(
                    popContext: context,
                    isPrimary: true,
                    text: 'Save Preference',
                    onPressed: _canSavePreference()
                        ? () {
                            widget.onSave(
                                _selectedSource,
                                widget.isBanner
                                    ? _selectedSource == ImageSource.local
                                        ? _localImageFiles[_selectedLocalImageIndex!].path
                                        : widget.series.anilistData?.bannerImage ?? ''
                                    : _selectedSource == ImageSource.local
                                        ? _localImageFiles[_selectedLocalImageIndex!].path
                                        : widget.series.anilistData?.posterImage ?? '');
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  bool _canSavePreference() {
    if (_selectedSource == ImageSource.local) {
      return _selectedLocalImageIndex != null;
    } else if (_selectedSource == ImageSource.anilist) {
      final String? anilistImageUrl = widget.isBanner ? widget.series.anilistData?.bannerImage : widget.series.anilistData?.posterImage;
      return anilistImageUrl != null;
    }
    return false;
  }

  String _getSourceDisplayName(ImageSource source) {
    switch (source) {
      case ImageSource.local:
        return 'Local Image';
      case ImageSource.anilist:
        return 'Anilist Image';
      case ImageSource.autoLocal:
        return 'Automatic (Local if available, otherwise Anilist)';
      case ImageSource.autoAnilist:
        return 'Automatic (Anilist if available, otherwise Local)';
    }
  }

  Widget _buildPosterOption({
    required String title,
    required bool isAvailable,
    required bool isLoading,
    required ImageProvider? posterProvider,
    required ImageSource source,
    required String unavailableMessage,
    VoidCallback? linkToAnilistAction,
  }) {
    final needsAnilistLink = source == ImageSource.anilist && widget.series.primaryAnilistId == null;
    final isSelected = _selectedSource == source;

    return GestureDetector(
      onTap: posterProvider != null && isAvailable
          ? () {
              if (source == ImageSource.anilist) {
                _selectAnilistImage();
              } else {
                setState(() {
                  _selectedSource = source;
                });
              }
            }
          : null,
      child: Card(
        padding: EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: posterProvider != null && isSelected ? Manager.accentColor.lighter.withOpacity(0.1) : Colors.transparent,
        borderColor: posterProvider != null && isSelected ? Manager.accentColor.lighter : FluentTheme.of(context).resources.controlStrokeColorDefault,
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
                  ? !isLoading
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SeriesImageBuilder(
                            imageProviderFuture: Future.value(posterProvider),
                            fit: BoxFit.contain,
                            fadeInDuration: const Duration(milliseconds: 300),
                            fadeInCurve: Curves.easeIn,
                            skipLoadingIndicator: true,
                          ),
                        )
                      : Center(child: Text('No image available', style: FluentTheme.of(context).typography.body))
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
            if (posterProvider != null && isAvailable)
              Row(
                children: [
                  RadioButton(
                    checked: _selectedSource == source,
                    onChanged: (_) {
                      if (source == ImageSource.anilist) {
                        _selectAnilistImage();
                      } else {
                        setState(() {
                          _selectedSource = source;
                        });
                      }
                    },
                  ),
                  SizedBox(width: 8),
                  Text('Use Anilist image'),
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
    final isSelected = _selectedSource == ImageSource.local;
    // Track hovered image for filename display
    String? hoveredImageName;

    return StatefulBuilder(builder: (context, setStateLocal) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedSource = ImageSource.local;
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
                                    waitDuration: const Duration(milliseconds: 1500),
                                  ),
                                  child: Tooltip(
                                    enableFeedback: true,
                                    richMessage: WidgetSpan(
                                      child: LayoutBuilder(builder: (context, c) {
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
                                              _selectedSource = ImageSource.local;
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: index == _selectedLocalImageIndex ? Border.all(color: Manager.accentColor.light, width: 3) : null,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: SeriesImageBuilder(
                                                imageProviderFuture: Future.value(FileImage(file)),
                                                fit: BoxFit.contain,
                                                fadeInDuration: const Duration(milliseconds: 300),
                                                fadeInCurve: Curves.easeIn,
                                                skipLoadingIndicator: true,
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
                    checked: _selectedSource == ImageSource.local,
                    onChanged: (_) {
                      setState(() {
                        _selectedSource = ImageSource.local;
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  Text('Use ${_localImageFiles.isEmpty ? "selected local image" : _selectedLocalImageIndex != null ? _localImageFiles[_selectedLocalImageIndex!].path.split(Platform.pathSeparator).last : "Local Image"}'),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
