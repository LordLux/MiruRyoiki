import 'dart:io';
import 'dart:math' show min;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/widgets/tooltip_wrapper.dart';
import 'package:provider/provider.dart';

import '../../enums.dart';
import '../../main.dart';
import '../../manager.dart';
import '../../models/series.dart';
import '../../services/library/library_provider.dart';
import '../../screens/series.dart';
import '../../services/navigation/dialogs.dart';
import '../../services/navigation/show_info.dart';
import '../../utils/image.dart';
import '../../utils/logging.dart';
import '../../utils/path.dart';
import '../../utils/screen.dart';
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

              final bool isLocalSource = source == ImageSource.local;
              Color? newLocalPosterColor;
              Color? newLocalBannerColor;
              PathString? newFolderPosterPath;
              PathString? newFolderBannerPath;

              if (!isBanner) {
                // Poster
                if (isLocalSource) {
                  // Set local poster path and keep local color
                  newFolderPosterPath = PathString(path);
                  newLocalPosterColor = series.localPosterColor; // Will recalculate below
                } else {
                  // Switching to Anilist
                  newFolderPosterPath = series.localPosterPath;
                  newLocalPosterColor = null; // Clear local color
                }
                newFolderBannerPath = series.localBannerPath;
                newLocalBannerColor = series.localBannerColor;
              } else {
                // Banner
                if (isLocalSource) {
                  // Set local banner path and keep local color
                  newFolderBannerPath = PathString(path);
                  newLocalBannerColor = series.localBannerColor; // Will recalculate below
                } else {
                  // Switching to Anilist
                  newFolderBannerPath = series.localBannerPath;
                  newLocalBannerColor = null; // Clear local color
                }
                newFolderPosterPath = series.localPosterPath;
                newLocalPosterColor = series.localPosterColor;
              }

              final Series updatedSeries = series.copyWith(
                folderPosterPath: newFolderPosterPath,
                folderBannerPath: newFolderBannerPath,
                posterColor: newLocalPosterColor,
                bannerColor: newLocalBannerColor,
                preferredPosterSource: isBanner ? series.preferredPosterSource : source,
                preferredBannerSource: isBanner ? source : series.preferredBannerSource,
              );

              final seriesScreenState = getActiveSeriesScreenContainerState();
              if (seriesScreenState != null && seriesScreenState is SeriesScreenState) {
                // log('Disabling poster/banner change buttons');
                seriesScreenState.posterChangeDisabled = !isBanner;
                seriesScreenState.bannerChangeDisabled = isBanner;
              }

              if (libraryScreenKey.currentState != null) libraryScreenKey.currentState!.updateSeriesInSortCache(updatedSeries);
              logTrace('Saving ${isBanner ? 'banner' : 'poster'} preference: $source, path: ${PathUtils.getFileName(path)}');
              snackBar(
                'Saving preference...',
                severity: InfoBarSeverity.info,
              );

              // Calculate dominant color for local images
              if (isLocalSource) {
                if (!isBanner) {
                  await updatedSeries.calculateLocalPosterDominantColor(forceRecalculate: true);
                } else {
                  await updatedSeries.calculateLocalBannerDominantColor(forceRecalculate: true);
                }
              }

              Manager.setState(() => Manager.currentDominantColor = updatedSeries.effectivePrimaryColorSync());

              // Explicitly save the entire series and show confirmation
              library.updateSeries(updatedSeries, invalidateCache: false).then((_) {
                snackBar(
                  isBanner ? 'Banner preference saved' : 'Poster preference saved',
                  severity: InfoBarSeverity.success,
                );
                final seriesScreenState = getActiveSeriesScreenContainerState();
                if (seriesScreenState != null && seriesScreenState is SeriesScreenState) {
                  // log('Enabling poster/banner change buttons');
                  seriesScreenState.posterChangeDisabled = false;
                  seriesScreenState.bannerChangeDisabled = false;
                }
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
    final directory = Directory(widget.series.path.path);

    final List<FileSystemEntity> entities = await directory.list().toList();

    // Filter for image files
    _localImageFiles = entities.whereType<File>().where((file) {
      final extension = file.path.toLowerCase().split('.').last;
      return ['jpg', 'jpeg', 'png', 'ico', 'webp'].contains(extension);
    }).toList();

    // Set selected index to current poster if it exists
    if (_selectedSource == ImageSource.local && widget.isBanner && widget.series.localBannerPath != null) {
      final index = _localImageFiles.indexWhere((f) => PathString(f.path) == widget.series.localBannerPath);
      if (index >= 0) _selectedLocalImageIndex = index;
      // Set selected index to current bannerif it exists
    } else if (_selectedSource == ImageSource.local && !widget.isBanner && widget.series.localPosterPath != null) {
      final index = _localImageFiles.indexWhere((f) => PathString(f.path) == widget.series.localPosterPath);
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
      if (widget.series.isAnilistBannerBeingUsed) {
        final anilistImageProvider = await widget.series.getBannerImage();
        _anilistImageProvider = anilistImageProvider ?? (widget.series.effectiveBannerPath != null ? CachedNetworkImageProvider(widget.series.effectiveBannerPath!) : null);
      } else {
        final url = widget.series.anilistData?.bannerImage;
        if (url != null) _anilistImageProvider = CachedNetworkImageProvider(url);
      }
    } else {
      if (widget.series.isAnilistPosterBeingUsed) {
        final anilistImageProvider = await widget.series.getPosterImage();
        _anilistImageProvider = anilistImageProvider ?? (widget.series.effectivePosterPath != null ? CachedNetworkImageProvider(widget.series.effectivePosterPath!) : null);
      } else {
        final url = widget.series.anilistData?.posterImage;
        if (url != null) _anilistImageProvider = CachedNetworkImageProvider(url);
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
    final s = widget.series;
    final bool isAvailable;

    if (widget.isBanner)
      isAvailable = s.isAnilistBannerBeingUsed ? s.effectiveBannerPath != null : false; // Only available if linked to Anilist and actually has a banner on Anilist
    else
      isAvailable = s.isAnilistPosterBeingUsed ? s.effectivePosterPath != null : false; // Only available if linked to Anilist and actually has a poster on Anilist

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose the ${widget.isBanner ? 'banner' : 'poster'} image source for "${widget.series.name}"',
          style: Manager.bodyStyle,
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
                  isAvailable: isAvailable,
                  isLoading: _anilistImageLoading,
                  posterProvider: _anilistImageProvider,
                  source: ImageSource.anilist,
                  unavailableMessage: 'No Anilist image available',
                  linkToAnilistAction: () {
                    linkWithAnilist(
                      context,
                      widget.series,
                      (ids) => (getActiveSeriesScreenContainerState() as SeriesScreenState).loadAnilistData(ids),
                      (_) => getActiveSeriesScreenContainerState()?.setState(() {}),
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
                    style: Manager.bodyStrongStyle,
                  ),
                  TextSpan(
                    text: _getSourceDisplayName(_selectedSource),
                    style: Manager.bodyStrongStyle.copyWith(color: Manager.accentColor.lighter),
                  ),
                ]),
              )
            : Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: 'Current preference: ',
                    style: Manager.bodyStrongStyle,
                  ),
                  TextSpan(
                    text: widget.isBanner ? _getSourceDisplayName(widget.series.preferredBannerSource ?? Manager.defaultPosterSource) : _getSourceDisplayName(widget.series.preferredPosterSource ?? Manager.defaultPosterSource),
                    style: Manager.bodyStrongStyle,
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
              child: TooltipWrapper(
                tooltip: 'Reset to ${_getSourceDisplayName(Manager.defaultPosterSource)}\nThis setting can be changed in settings',
                child: (_) => ManagedDialogButton(
                  popContext: context,
                  onPressed: () {
                    _deselectEverything();
                    widget.onSave(
                      _selectedSource,
                      widget.isBanner
                          ? Manager.defaultBannerSource == ImageSource.local || Manager.defaultPosterSource == ImageSource.autoLocal
                              ? _localImageFiles[_selectedLocalImageIndex!].path
                              : widget.series.anilistData?.bannerImage ?? ''
                          : Manager.defaultPosterSource == ImageSource.local || Manager.defaultPosterSource == ImageSource.autoLocal
                              ? _localImageFiles[_selectedLocalImageIndex!].path
                              : widget.series.anilistData?.posterImage ?? '',
                    );
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
                TooltipWrapper(
                  tooltip: _canSavePreference() ? 'Save the selected image preference' : 'Select an image first',
                  child: (_) => ManagedDialogButton(
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
    Future<ImageProvider?>? posterProviderFuture,
    required ImageSource source,
    required String unavailableMessage,
    VoidCallback? linkToAnilistAction,
  }) {
    final needsAnilistLink = source == ImageSource.anilist && widget.series.primaryAnilistId == null;
    final isSelected = _selectedSource == source;
    // log("${unavailableMessage.toLowerCase().contains("anilist") ? 'Anilist:' : 'Local: '} posterProvider: ${posterProvider == null}, isAvailable: $isAvailable");

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
            Text(title, style: Manager.bodyStrongStyle),
            SizedBox(height: 12),
            Expanded(
              child: isAvailable
                  ? !isLoading
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SeriesImageBuilder(
                            imageProviderFuture: posterProviderFuture ?? Future.value(posterProvider),
                            fit: BoxFit.contain,
                            fadeInDuration: const Duration(milliseconds: 300),
                            fadeInCurve: Curves.easeIn,
                            errorWidget: Text('Failed to load image', style: Manager.bodyStyle),
                            skipLoadingIndicator: true,
                          ),
                        )
                      : Center(child: Text('No image available', style: Manager.bodyStyle))
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FluentIcons.error, size: 32, color: Manager.accentColor.lightest),
                          SizedBox(height: 8),
                          Text(unavailableMessage, textAlign: TextAlign.center, style: Manager.bodyStyle),
                          if (needsAnilistLink && linkToAnilistAction != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: FilledButton(
                                onPressed: linkToAnilistAction,
                                child: Text('Link to Anilist', style: Manager.bodyStyle),
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
                  Text('Use Anilist image', style: Manager.bodyStyle),
                ],
              ),
            if (!isAvailable)
              Text(
                'Not available',
                style: Manager.captionStyle,
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
        onTap: () => setState(() => _selectedSource = ImageSource.local),
        child: Card(
          padding: EdgeInsets.all(12),
          borderRadius: BorderRadius.circular(8),
          backgroundColor: isSelected ? Manager.accentColor.lighter.withOpacity(0.1) : Colors.transparent,
          borderColor: isSelected ? Manager.accentColor.lighter : FluentTheme.of(context).resources.controlStrokeColorDefault,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Local Folder Images (${_localImageFiles.length})', style: Manager.bodyStrongStyle),
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
                                  child: TooltipWrapper(
                                    tooltip: LayoutBuilder(
                                      builder: (context, c) {
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
                                                          style: Manager.bodyStyle,
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
                                                          style: Manager.bodyStyle,
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
                                          },
                                        );
                                      },
                                    ),
                                    child: (_) => SizedBox(
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
                              style: Manager.captionStyle,
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
                    onChanged: (_) => setState(() => _selectedSource = ImageSource.local),
                  ),
                  SizedBox(width: 8),
                  Text(
                      'Use ${_localImageFiles.isEmpty ? "selected local image" : _selectedLocalImageIndex != null ? _localImageFiles[_selectedLocalImageIndex!].path.split(Platform.pathSeparator).last : "Local Image"}',
                      style: Manager.bodyStyle),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
