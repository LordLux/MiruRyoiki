import 'dart:async';
import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:miruryoiki/widgets/acrylic_header.dart';
import 'package:provider/provider.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/anilist/anime.dart';
import '../services/connectivity/connectivity_service.dart';
import '../services/library/library_provider.dart';
import '../services/lock_manager.dart';
import '../services/navigation/show_info.dart';
import '../utils/color.dart';
import '../utils/text.dart';
import '../widgets/buttons/back_button.dart';
import '../widgets/buttons/button.dart';
import '../widgets/dialogs/link_anilist.dart';
import '../enums.dart';
import '../manager.dart';
import '../models/series.dart';
import '../services/anilist/linking.dart';
import '../services/navigation/dialogs.dart';
import '../utils/logging.dart';
import '../utils/error_handling.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/infobar.dart';
import '../widgets/page/page_template.dart';
import '../widgets/shrinker.dart';
import '../widgets/simple_html_parser.dart';
import '../widgets/transparency_shadow_image.dart';
import 'package:recase/recase.dart';
import 'dart:io';
import '../services/file_system/cache.dart';
import 'anilist_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Duration for which AniList data is considered fresh and doesn't need refetching
const Duration kAnilistCacheDuration = Duration(days: 1);

Widget _kIdentityWrapper({required Widget child}) => child;

class SearchedSeriesScreen extends StatefulWidget {
  final String anilistUrl;
  final VoidCallback onBack;

  const SearchedSeriesScreen({
    super.key,
    required this.anilistUrl,
    required this.onBack,
  });

  @override
  SearchedSeriesScreenState createState() => SearchedSeriesScreenState();
}

class SearchedSeriesScreenState extends State<SearchedSeriesScreen> {
  late final SimpleHtmlParser parser;

  final ShrinkerController _descriptionController = ShrinkerController();

  bool isReloadingSeries = false;
  DeferredPointerHandlerLink? deferredPointerLink;

  /// Cached reference to the current series, updated via Selector in build()
  AnilistAnime? _cachedSeries;

  late Color _textColor;
  late Color _selectedTextColor;

  // Widget: whether to allocate a full row or divide it in 2 columns [true = full row, false = 2 columns]
  Map<InfoLabel, bool> getInfos(AnilistAnime? series) {
    return {
      if (series?.episodes != null)
        InfoLabel(
          label: 'Episodes',
          labelStyle: Manager.bodyStrongStyle,
          child: Text('${_cachedSeries!.episodes}'),
        ): false,
      if (series?.status != null)
        InfoLabel(
          label: 'Status',
          labelStyle: Manager.bodyStrongStyle,
          child: Text(series!.status!.toAnimeStatus()?.name_ ?? series!.status!),
        ): false,
      if (series?.format != null)
        InfoLabel(
          label: 'Format',
          labelStyle: Manager.bodyStrongStyle,
          child: Text(series!.format!),
        ): false,
      if (series?.seasonYear != null)
        InfoLabel(
          label: 'Year',
          labelStyle: Manager.bodyStrongStyle,
          child: Text('${series!.seasonYear}'),
        ): false,
      if (series?.season != null)
        InfoLabel(
          label: 'Season',
          labelStyle: Manager.bodyStrongStyle,
          child: Text(series!.season!.toLowerCase().titleCase),
        ): false,
      if (series?.averageScore != null)
        InfoLabel(
          label: 'Rating',
          labelStyle: Manager.bodyStrongStyle,
          child: Text('${series!.averageScore! / 10}/10'),
        ): false,
      if (series?.meanScore != null)
        InfoLabel(
          label: 'Mean Score',
          labelStyle: Manager.bodyStrongStyle,
          child: Text('${series!.meanScore! / 10}/10'),
        ): false,
      if (series?.popularity != null)
        InfoLabel(
          label: 'Popularity',
          labelStyle: Manager.bodyStrongStyle,
          child: Text('#${series!.popularity}'),
        ): false,
      if (series?.favourites != null)
        InfoLabel(
          label: 'Favourites',
          labelStyle: Manager.bodyStrongStyle,
          child: Text('${series!.favourites}'),
        ): false,
    };
  }

  //

  void _loadColors() {
    _textColor = Colors.white;
    _selectedTextColor = getTextColor(Manager.currentDominantColor ?? Manager.accentColor);
  }

  @override
  void initState() {
    super.initState();
    deferredPointerLink = DeferredPointerHandlerLink();
    nextFrame(() => _loadAnilistData());
    parser = SimpleHtmlParser(context);
  }

  @override
  didUpdateWidget(covariant SearchedSeriesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.anilistUrl != oldWidget.anilistUrl) {
      // Series changed, load new data
      deferredPointerLink ??= DeferredPointerHandlerLink();
      nextFrame(() => _loadAnilistData());
    }
  }

  @override
  void dispose() {
    deferredPointerLink?.dispose();
    super.dispose();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    // If series changes while dependencies change, reload Anilist data
    if (_cachedSeries != null && _cachedSeries!.id.toString() != widget.anilistUrl.split('/').last) {
      nextFrame(() => _loadAnilistData());
    }
  }

  ColorFilter get colorFilter => ColorFilter.matrix([
        // Scale down RGB channels (darken)
        0.7, 0, 0, 0, 0,
        0, 0.7, 0, 0, 0,
        0, 0, 0.7, 0, 0,
        0, 0, 0, 1, 0,
      ]);

  Future<ImageProvider?> _getAnilistImage({required bool banner}) async {
    final series = _cachedSeries;
    if (series == null) return null;

    final imageUrl = banner ? series.bannerImage : series.posterImage;
    if (imageUrl == null) return null;

    final imageCache = ImageCacheService();
    final File? cachedFile = await imageCache.getCachedImageFile(imageUrl);
    if (cachedFile != null) return FileImage(cachedFile);

    // Start caching in background but return network image for immediate display
    imageCache.cacheImage(imageUrl); // no await
    return CachedNetworkImageProvider(imageUrl, errorListener: (error) => logWarn('Failed to load image from network: $error'));
  }

  Future<void> _loadAnilistData() async {
    try {
      final anilistId = int.parse(widget.anilistUrl.split('/').last);
      logTrace('Fetching AniList data for ID $anilistId');

      final AnilistAnime? anilistAnime = await SeriesLinkService().fetchAnimeDetails(anilistId);
      if (!mounted) return;

      if (anilistAnime == null) {
        if (ConnectivityService().isOffline)
          logWarn('Failed to fetch AniList details for ID $anilistId: device is offline');
        else
          logErr('Failed to load Anilist data for ID: $anilistId');
        return;
      }

      Manager.currentDominantColor = anilistAnime.dominantColor?.fromHex();

      _cachedSeries = anilistAnime;

      // Finalize UI
      _loadColors();
      Manager.setState();
    } catch (e) {
      if (!isExpectedOfflineError(e)) logErr('Failed to load Anilist data', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MiruRyoikiTemplatePage(
      headerWidget: _buildHeader(context, _cachedSeries),
      infobar: (_) => _buildInfoBar(context, _cachedSeries),
      content: _buildContentGrid(context, _cachedSeries),
      backgroundColor: Manager.currentDominantColor,
      onHeaderCollapse: () => _descriptionController.collapse(),
      scrollableContent: false,
    );
  }

  HeaderWidget _buildHeader(BuildContext context, AnilistAnime? series) {
    final title = series?.title.userPreferred ?? '';
    final description = series?.description;
    final imageFuture = _getAnilistImage(banner: true);

    return HeaderWidget(
      image_widget: FutureBuilder(
        future: imageFuture,
        builder: (context, snapshot) {
          return Stack(
            children: [
              // Banner
              Container(
                height: ScreenUtils.kMaxHeaderHeight,
                width: double.infinity,
                // Background image
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (Manager.currentDominantColor ?? Manager.accentColor).withOpacity(0.27),
                      Colors.transparent,
                    ],
                  ),
                  image: _getBannerDecoration(snapshot.data),
                ),
                padding: const EdgeInsets.only(bottom: 16.0),
                alignment: Alignment.bottomLeft,
              ),
              // Back button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackButton(
                    onTap: widget.onBack,
                    label: 'Back to Library',
                    child: const Icon(FluentIcons.back),
                  ),
                ],
              )
            ],
          );
        },
      ),
      colorFilter: null,
      titleLeftAligned: false,
      title: (style, constraints) => Text(title, style: style),
      children: [
        // Add description if available
        if (description != null) ...[
          VDiv(8),
          Shrinker(
            maxHeight: 150,
            minHeight: 45,
            controller: _descriptionController,
            child: parser.parse(description, selectable: true, selectionColor: Manager.currentDominantColor),
          ),
          VDiv(8),
        ],
      ],
    );
  }

  // Get the decoration image based on the banner image
  DecorationImage? _getBannerDecoration(imageProvider) {
    if (imageProvider == null) return null;

    return DecorationImage(
      alignment: Alignment.topCenter,
      image: imageProvider,
      fit: BoxFit.cover,
      isAntiAlias: true,
      colorFilter: colorFilter,
    );
  }

  MiruRyoikiInfobar _buildInfoBar(BuildContext context, AnilistAnime? series) {
    final posterImage = _getAnilistImage(banner: false);

    return MiruRyoikiInfobar(
      getPosterImage: posterImage,
      isProfilePicture: false,
      contentPadding: (posterExtraVertical) => EdgeInsets.only(left: 24.0, right: 24.0, bottom: 16.0, top: 16.0 + posterExtraVertical),
      setStateCallback: () {
        if (mounted) setState(() {});
      },
      content: _buildInfoBarContent(series),
      footerPadding: EdgeInsets.all(6.0),
      footer: [
        // Add to Library Button
        Builder(builder: (context) {
          final animeId = series?.id;
          return StandardButton(
            label: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(mat.Icons.library_add_outlined),
                HDiv(4),
                Text(
                  'Add to Library',
                  style: getStyleBasedOnAccent(false),
                ),
              ],
            ),
            expand: true,
            tooltip: 'Add the series to your library',
            onPressed: animeId == null
                ? null
                : () {
                    logTrace('Opening Anilist List Editor Dialog');
                    snackBar('Feature not implemented yet', severity: InfoBarSeverity.warning);
                  },
          );
        }),
        SizedBox(height: 6.0),
        // Open in Anilist Button
        Builder(builder: (context) {
          final animeId = series?.id;
          return StandardButton(
            label: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(mat.Icons.open_in_new),
                HDiv(4),
                Text(
                  'Open in Anilist',
                  style: getStyleBasedOnAccent(false),
                ),
              ],
            ),
            expand: true,
            tooltip: 'Open the series in Anilist.co',
            onPressed: animeId == null
                ? null
                : () {
                    final url = 'https://anilist.co/anime/$animeId';
                    logTrace('Opening anime in browser: $url');
                    launchUrl(Uri.parse(url));
                  },
          );
        }),
      ],
      poster: ({required imageProvider, required width, required height, required squareness, required offset}) {
        return SizedBox(
          height: height - offset,
          width: width,
          child: AnimatedContainer(
            duration: shortStickyHeaderDuration,
            width: width,
            height: height,
            child: Builder(builder: (context) {
              if (imageProvider != null)
                // Image available -> show it
                return Center(
                  child: ShadowedImage(
                    imageProvider: imageProvider,
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0), BlendMode.darken),
                    blurSigma: 0,
                    shadowColorOpacity: 0,
                  ),
                );

              // No image -> image icon
              return Center(child: Icon(FluentIcons.picture, size: 48, color: Colors.white));
            }),
          ),
        );
      },
    );
  }

  Widget _buildInfoBarContent(AnilistAnime? series) {
    final infos_ = getInfos(series);
    final genres = series?.genres ?? [];

    return SizedBox(
      width: double.infinity, // template takes care of constraints
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...() {
            final List<Widget> columnChildren = [];
            final entries = infos_.entries.toList();

            for (int i = 0; i < entries.length; i++) {
              final currentEntry = entries[i];
              final InfoLabel currentInfo = currentEntry.key;
              final bool isFullRow = currentEntry.value;

              if (isFullRow) {
                // Full width widget
                columnChildren.add(Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: currentInfo,
                ));
              } else {
                // Check if next widget also wants to share space
                if (i + 1 < entries.length && !entries[i + 1].value) {
                  // Both current and next are false, put them in a row
                  final InfoLabel nextInfo = entries[i + 1].key;
                  columnChildren.add(Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(child: currentInfo),
                        const SizedBox(width: 16.0),
                        Expanded(child: nextInfo),
                      ],
                    ),
                  ));
                  i++; // Skip the next item since we've already processed it
                } else {
                  // Current is false but next is true or doesn't exist, show as full width
                  columnChildren.add(Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: currentInfo,
                  ));
                }
              }
            }

            return columnChildren;
          }(),

          // Genre tags
          if (genres.isNotEmpty) ...[
            VDiv(16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: genres.map((genre) => Chip(text: (color) => Text(genre, style: Manager.bodyStyle.copyWith(color: color)))).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContentGrid(BuildContext context, AnilistAnime? series) {
    final headerHeight = 45.0;
    final borderRadius = ScreenUtils.kEpisodeCardBorderRadius;
    final pages = [
      "Overview",
      null,
      "Watch",
      null,
      "Staff",
      null,
      "Reviews",
      null,
      "Stats",
      null,
      "Social",
    ];

    final visibleHeader = Container(
      height: headerHeight,
      margin: EdgeInsets.all(.5),
      constraints: BoxConstraints(maxHeight: headerHeight),
      child: AcrylicHeader(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(borderRadius),
          topLeft: Radius.circular(borderRadius),
        ),
        useFrostedNoise: false,
        useAcrylic: false,
        padding: EdgeInsets.all(3),
        child: LayoutBuilder(builder: (context, constraints) {
          final threshold = 500.0;
          final sepMargin = 2.0;
          Widget tab(bool isFirst, bool isLast, double extra, String page, Widget Function({required Widget child})? wrapper) {
            wrapper ??= _kIdentityWrapper;
            return wrapper(
              child: SizedBox(
                width: ((threshold - 18) - (isFirst || isLast ? (extra * 2) : 0) - (sepMargin * (pages.whereNot((p) => p == null).length - 1))) / pages.whereNot((p) => p == null).length + extra,
                height: headerHeight,
                child: mat.InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    logTrace('Clicked on tab: $page');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!isFirst) SizedBox.shrink() else SizedBox(width: extra),
                      Text(page, style: Manager.captionStyle, textAlign: TextAlign.center),
                      if (!isLast) SizedBox.shrink() else SizedBox(width: extra),
                    ],
                  ),
                ),
              ),
            );
          }

          Widget builder(Widget Function({required Widget child})? wrapper) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: pages.map((page) {
                final isFirst = pages.indexOf(page) == 0;
                final isSeparator = page == null;
                final isLast = pages.indexOf(page) == pages.length - 1;
                final extra = 0.0;

                // Separator
                if (isSeparator) return Container(width: 1, height: 24, margin: EdgeInsets.symmetric(horizontal: sepMargin), color: Colors.white.withOpacity(0.2));

                // Normal tab
                return tab(isFirst, isLast, extra, page, wrapper);
              }).toList(),
            );
          }

          // Decide layout based on available width
          if (constraints.maxWidth >= threshold)
            // Full row when enough width
            return builder(({required Widget child}) => Expanded(child: child));
          else
            // Scrollable list when width is limited
            return SingleChildScrollView(scrollDirection: Axis.horizontal, child: builder(null));
        }),
      ),
    );

    return Column(
      children: [
        visibleHeader,
        SizedBox(height: 4),
        Expanded(
          child: Card(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(borderRadius),
              bottomRight: Radius.circular(borderRadius),
            ),
            padding: EdgeInsets.only(top: 16, left: 16, bottom: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(borderRadius),
                bottomRight: Radius.circular(borderRadius),
              ),
              child: Padding(
                padding: EdgeInsets.only(right: 2),
                child: Container(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void linkWithAnilist(BuildContext context, Series? series, Future<void> Function(List<int>) loadData, void Function(VoidCallback) setState) async {
  if (series == null) {
    snackBar('Series not found', severity: InfoBarSeverity.error);
    return;
  }

  // Show the dialog
  await showManagedDialog(
    context: context,
    id: 'linkAnilist:${series.path}',
    title: 'Link to Anilist',
    data: series.path,
    barrierColor: Manager.currentDominantColor?.withOpacity(0.5),
    canUserPopDialog: true,
    closeExistingDialogs: true, // Close existing dialogs, important
    dialogDoPopCheck: () => Manager.canPopDialog, // Allow popping only when in view mode
    builder: (context) => AnilistLinkMultiDialog(
      constraints: const BoxConstraints(
        maxWidth: 1300,
        maxHeight: 600,
      ),
      series: series,
      popContext: context,
      linkService: SeriesLinkService(),
      onLink: (_, __) {},
      onDialogComplete: (success, mappings) async {
        // if the dialog was closed without a result, do nothing
        if (success == null)
          // logDebug('Dialog closed without result');
          return;

        // if the dialog was closed with a result, check if it was successful
        if (!success) {
          logErr('Linking failed');
          snackBar('Failed to link with Anilist', severity: InfoBarSeverity.error);
          return;
        }

        // if dialog was closed with a result, and it was successful, update the series mappings
        final library = Provider.of<Library>(context, listen: false);

        // Check if the action should be disabled during indexing
        if (library.lockManager.shouldDisableAction(UserAction.anilistOperations)) {
          snackBar(
            library.lockManager.getDisabledReason(UserAction.anilistOperations),
            severity: InfoBarSeverity.warning,
          );
          return;
        }

        // Calculate the number of new mappings
        final oldMappings = series.anilistMappings;
        List<int> anilistIdsToLoad = [];

        for (final mapping in mappings) {
          bool isNew = !oldMappings.any((m) => m.anilistId == mapping.anilistId && m.localPath == mapping.localPath);
          if (isNew) anilistIdsToLoad.add(mapping.anilistId);
        }

        // Ensure the library gets saved
        await library.updateSeriesMappings(series, mappings);

        // If links were added
        if (anilistIdsToLoad.isNotEmpty) {
          snackBar(
            'Successfully linked ${anilistIdsToLoad.length} ${anilistIdsToLoad.length == 1 ? 'new item' : 'new items'} with Anilist',
            severity: InfoBarSeverity.success,
          );
        } else if (mappings.length < oldMappings.length) {
          // If links were removed
          final removedCount = oldMappings.length - mappings.length;
          snackBar(
            'Removed $removedCount ${removedCount == 1 ? 'link' : 'links'} from Anilist',
            severity: InfoBarSeverity.success,
          );
        } else {
          // No changes in link count but mappings might have been updated
          snackBar(
            'Anilist links updated successfully',
            severity: InfoBarSeverity.success,
          );
        }

        closeDialog(context);

        // Load Anilist data
        if (anilistIdsToLoad.isNotEmpty) await loadData(anilistIdsToLoad);

        // Update the series with the new mappings
        final newColor = await series.effectivePrimaryColor();
        Manager.currentDominantColor = newColor;
        Manager.seriesDominantColor = newColor;
        Manager.setState();
      },
    ),
  );
}
