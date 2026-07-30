import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:miruryoiki/widgets/acrylic_header.dart';
import 'package:miruryoiki/widgets/file_explorer.dart';
import 'package:provider/provider.dart';

import '../viewmodels/library_screen_viewmodel.dart';
import '../viewmodels/series_viewmodel.dart';
import 'package:defer_pointer/defer_pointer.dart';

import '../main.dart';
import '../models/anilist/anime.dart';
import '../services/downloads/torrent_manager.dart';
import '../services/library/library_provider.dart';
import '../services/lock_manager.dart';
import '../services/navigation/dialog_framework.dart';
import '../services/episode_navigation/anilist_progress_manager.dart';
import '../services/navigation/show_info.dart';
import '../services/navigation/statusbar.dart';
import '../utils/color.dart';
import '../utils/path.dart';
import '../utils/shell.dart';
import '../utils/text.dart';
import '../widgets/animated_color_wrapper.dart';
import '../widgets/animated_switcher_layouts.dart';
import '../widgets/buttons/back_button.dart';
import '../widgets/buttons/button.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../widgets/dialogs/link_anilist.dart';
import '../widgets/dialogs/image_select.dart';
import '../enums.dart';
import '../manager.dart';
import '../models/anilist/mapping.dart';
import '../utils/searched_series_actions.dart';
import '../widgets/score_widget.dart';
import '../models/series.dart';
import '../services/navigation/navigation.dart';
import '../services/navigation/shortcuts.dart';
import '../utils/logging.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import '../widgets/dialogs/show_dialog.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/infobar.dart';
import '../widgets/page/page_template.dart';
import '../widgets/cards/mapping_card.dart';
import '../widgets/cards/folder_card.dart';
import '../widgets/smooth_scroll.dart';
import '../models/folder_node.dart';
import '../widgets/shift_clickable_hover.dart';
import '../widgets/shrinker.dart';
import '../widgets/simple_html_parser.dart';
import '../widgets/transparency_shadow_image.dart';
import '../models/mapping_target.dart';
import 'package:recase/recase.dart';
import '../widgets/viewtype_switcher.dart';
import 'anilist_settings.dart';
import '../models/episode.dart';
import '../models/ui_episode.dart';
import '../models/sonarr/sonarr_episode.dart';
import '../widgets/dialogs/knaben_search.dart';
import '../widgets/episode_grid.dart';
import '../widgets/dialogs/manage_episodes_dialog.dart';
import '../widgets/dialogs/sonarr_manual_link_dialog.dart';


class SeriesScreen extends StatefulWidget {
  final PathString? seriesPath;
  final VoidCallback onBack;

  const SeriesScreen({
    super.key,
    required this.seriesPath,
    required this.onBack,
  });

  @override
  SeriesScreenState createState() => SeriesScreenState();
}

class SeriesScreenState extends State<SeriesScreen> {
  late final SimpleHtmlParser parser;

  final ShrinkerController _descriptionController = ShrinkerController();

  bool posterChangeDisabled = false;
  bool bannerChangeDisabled = false;

  bool isReloadingSeries = false;

  /// The screen's state + data access live in [SeriesViewModel] (registered
  /// app-wide in `main.dart`). The thin accessors throughout this class keep the
  /// widget-building code — and external GlobalKey callers — in their original
  /// shape while the underlying state now lives in the VM.
  ///
  /// Captured once in [initState] so [dispose] can release the VM without reading from an already-defunct `context`.
  late final SeriesViewModel _vm;

  List<SonarrEpisode>? get _sonarrEpisodes => _vm.sonarrEpisodes;
  int? get _sonarrSeriesId => _vm.sonarrSeriesId;

  bool _isPosterHovering = false;
  bool _isBannerHovering = false;
  DeferredPointerHandlerLink? deferredPointerLink;

  late final NavigationManager _navManager;

  Series? get _cachedSeries => _vm.cachedSeries;
  FolderNode? get _resolvedNode => _vm.resolvedNode;
  AnilistMapping? get _cachedMapping => _vm.cachedMapping;
  List<(AnilistMapping, MappingTarget)> get _fileMappingsAtNode => _vm.fileMappingsAtNode;
  List<UIEpisode> get _mergedEpisodes => _vm.mergedEpisodes;
  ViewType get _currentViewType => _vm.currentViewType;
  bool get isMappingMode => _vm.isMappingMode;

  /// Drill into a child folder/mapping node. Intra-page navigation:
  /// the screen stays alive and crossfades, recording the level in history (via [pushTabState]) so Back/Forward
  /// walk the folder stack without route churn.
  void navigateToNode(FolderNode node) {
    if (!mounted) return;

    _vm.pushNode(node.path);
    // Title the entry with the node name, so drilled-in levels are distinguishable from the series root.
    _navManager.pushTabState({seriesNodeStackNamespace: {'nodeStack': _encodeNodeStack()}}, title: node.displayName);
  }

  /// Serialize the VM's drill-down stack for storage in navigation viewState.
  List<String> _encodeNodeStack() => _vm.nodeStack.map((p) => p.path).toList();

  /// Read a drill-down stack back out of this page's namespaced viewState section.
  /// Decodes defensively so corrupted/legacy history state can't crash the screen, but
  /// logs when the shape doesn't match what we wrote so drift doesn't fail silently.
  List<PathString> _decodeNodeStack(Map<String, dynamic>? section) {
    final raw = section?['nodeStack'];
    if (raw == null) return const [];
    if (raw is! List) {
      logWarn('[SeriesScreen] Ignoring nodeStack viewState with unexpected shape (${raw.runtimeType}): $raw');
      return const [];
    }
    final decoded = raw.whereType<String>().map(PathString.new).toList();
    if (decoded.length != raw.length) //
      logWarn('[SeriesScreen] Dropped ${raw.length - decoded.length} non-string nodeStack entries: $raw');
    return decoded;
  }

  /// Back intent: pop one drill-down level if inside a folder/mapping (walking
  /// the intra-page history so Forward still works), otherwise leave to Library.
  void _handleBack() {
    if (_vm.canPopNode)
      _navManager.goBack();
    else
      widget.onBack();
  }

  /// Restore the drill-down stack when the user navigates Back/Forward within
  /// this page, or re-enters it from history.
  void _onRestoreFromHistory() {
    if (!mounted) return;
    final currentView = _navManager.currentView;
    if (currentView == null || !currentView.id.startsWith('/series:')) return;
    _vm.restoreNodeStack(_decodeNodeStack(currentView.viewStateSection(seriesNodeStackNamespace)));
    _applySeriesColorIfAtRoot();
  }

  /// Returning to the series root restores the series-level dominant color so it
  /// doesn't linger on the folder/mapping node we just left. Deeper nodes get
  /// their color from the VM's [SeriesViewModel.initNodeData].
  void _applySeriesColorIfAtRoot() {
    if (_vm.isAtRoot) //
      Manager.setState(() => Manager.currentDominantColor = Manager.seriesDominantColor ?? Manager.accentColor);
  }

  /// Render [fullPath] relative to the library root (e.g. `Witch Hat Atelier\S01`)
  /// instead of the full absolute path. Falls back to the full path when the
  /// library root is unknown or the path lies outside it.
  String _libraryRelativePath(String fullPath) => //
      PathUtils.relativeToRootOrFull(fullPath, context.read<Library>().libraryPath);

  // Widget: whether to allocate a full row or divide it in 2 columns [true = full row, false = 2 columns]
  Map<InfoLabel, bool> infos(Series series) {
    if (!mounted) return {};
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
    final progressManager = AnilistProgressManager.instance;

    if (isMappingMode && _resolvedNode != null) {
      final nodeMeta = _resolvedNode!.collection?.metadata;
      return {
        InfoLabel(
          label: 'Episodes',
          labelStyle: Manager.bodyStrongStyle,
          child: Text('${_resolvedNode!.totalCount}'),
        ): false,
        if (_cachedMapping?.anilistData?.status != null)
          InfoLabel(
            label: 'Status',
            labelStyle: Manager.bodyStrongStyle,
            child: Text(_cachedMapping!.anilistData!.status!.toAnimeStatus()?.name_ ?? _cachedMapping!.anilistData!.status!),
          ): false,
        if (_cachedMapping?.anilistData?.format != null)
          InfoLabel(
            label: 'Format',
            labelStyle: Manager.bodyStrongStyle,
            child: Text(_cachedMapping!.anilistData!.format!),
          ): false,
        if (_cachedMapping?.anilistData?.seasonYear != null)
          InfoLabel(
            label: 'Year',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('${_cachedMapping!.anilistData!.seasonYear}'),
          ): false,
        if (_cachedMapping?.anilistData?.season != null)
          InfoLabel(
            label: 'Season',
            labelStyle: Manager.bodyStrongStyle,
            child: Text(_cachedMapping!.anilistData!.season!.toLowerCase().titleCase),
          ): false,
        if (_cachedMapping?.anilistData?.averageScore != null)
          InfoLabel(
            label: 'Rating',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('${_cachedMapping!.anilistData!.averageScore! / 10}/10'),
          ): false,
        if (_cachedMapping?.anilistData?.meanScore != null)
          InfoLabel(
            label: 'Mean Score',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('${_cachedMapping!.anilistData!.meanScore! / 10}/10'),
          ): false,
        if (_cachedMapping?.anilistData?.popularity != null)
          InfoLabel(
            label: 'Popularity',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('#${_cachedMapping!.anilistData!.popularity}'),
          ): false,
        if (_cachedMapping?.anilistData?.favourites != null)
          InfoLabel(
            label: 'Favourites',
            labelStyle: Manager.bodyStrongStyle,
            child: Text('${_cachedMapping!.anilistData!.favourites}'),
          ): false,
        if (nodeMeta?.duration != null && nodeMeta!.duration.inSeconds > 0)
          InfoLabel(
            label: 'Duration',
            labelStyle: Manager.bodyStrongStyle,
            child: Text(nodeMeta.durationFormatted),
          ): true,
      };
    }

    return {
      InfoLabel(
        label: 'Seasons',
        labelStyle: Manager.bodyStrongStyle,
        child: Text('${series.numberOfSeasons}'),
      ): false,
      InfoLabel(
        label: 'Episodes',
        labelStyle: Manager.bodyStrongStyle,
        child: Text('${progressManager.getTotalEpisodes(series)}'),
      ): false,
      if (series.folders.isNotEmpty)
        InfoLabel(
          label: 'Folders',
          labelStyle: Manager.bodyStrongStyle,
          child: Text('${series.folders.length}'),
        ): false,
      if (series.effectiveStatus != null)
        InfoLabel(
          label: 'Status',
          labelStyle: Manager.bodyStrongStyle,
          child: Text(series.effectiveStatus!),
        ): false,
      if (series.formats != null)
        InfoLabel(
          label: 'Formats',
          labelStyle: Manager.bodyStrongStyle,
          child: Text(series.formats!),
        ): true,
      if (series.seasonAndSeasonYearRange != null)
        InfoLabel(
          label: 'Years',
          labelStyle: Manager.bodyStrongStyle,
          child: Text('${series.seasonAndSeasonYearRange}'),
        ): true,
      if (anilistProvider.getHighestUserScore(series) != null && anilistProvider.getHighestUserScore(series)! > 0)
        InfoLabel(
          label: 'User Score',
          labelStyle: Manager.bodyStrongStyle,
          child: ScoreWidget(
            score: anilistProvider.getHighestUserScore(series),
            format: anilistProvider.scoreFormat,
          ),
        ): false,
      if (series.metadata?.duration != null && series.metadata!.duration.inSeconds > 0)
        InfoLabel(
          label: 'Duration',
          labelStyle: Manager.bodyStrongStyle,
          child: Text(series.metadata!.durationFormatted),
        ): true,
    };
  }

  @override
  void initState() {
    super.initState();
    _vm = context.read<SeriesViewModel>();
    _navManager = context.read<NavigationManager>();
    _navManager.restoreNotifier.addListener(_onRestoreFromHistory);

    if (widget.seriesPath != null) _openSeriesAndLoad(widget.seriesPath!, seedHistory: true);
    parser = SimpleHtmlParser(context);
  }

  @override
  didUpdateWidget(covariant SeriesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.seriesPath != oldWidget.seriesPath && widget.seriesPath != null) //
      _openSeriesAndLoad(widget.seriesPath!, seedHistory: true);
  }

  /// Opens [path] in the VM at the drill-down level saved in history
  /// (root on first entry; the same folder/mapping when re-entering via Back/Forward), then loads its AniList data.
  /// [seedHistory] seeds the root viewState so it's restorable later and is set only on first entry.
  void _openSeriesAndLoad(PathString path, {bool seedHistory = false}) {
    deferredPointerLink ??= DeferredPointerHandlerLink();
    _vm.openSeries(path, initialStack: _decodeNodeStack(_navManager.currentView?.viewStateSection(seriesNodeStackNamespace)));
    if (seedHistory) _navManager.seedCurrentViewState({seriesNodeStackNamespace: {'nodeStack': <String>[]}});

    nextFrame(() {
      if (mounted) _vm.loadAnilistDataForCurrentSeries();
    });
  }

  void _onViewTypeChanged(ViewType newViewType) => _vm.onViewTypeChanged(newViewType);

  /// Called by [Library.reloadOpenedSeries] after a library reload.
  /// Delegates to the ViewModel, which re-derives everything from the live series.
  void refreshFromLibrary() {
    if (!mounted) return;
    _vm.refreshFromLibrary();
  }

  @override
  void dispose() {
    _navManager.restoreNotifier.removeListener(_onRestoreFromHistory);
    // The VM outlives this screen, so hand the series back:
    // it drops the cached tree/episodes and  makes in-flight loads for this series no-ops
    _vm.close(widget.seriesPath);
    deferredPointerLink?.dispose();
    super.dispose();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    // If series changes while dependencies change, reload Anilist data
    final series = _vm.cachedSeries;
    if (widget.seriesPath != null && series != null && !series.isLinked) {
      nextFrame(() {
        if (mounted) _vm.loadAnilistDataForCurrentSeries();
      });
    }
  }

  ColorFilter get colorFilter => ColorFilter.matrix([
        // Scale down RGB channels (darken)
        0.7, 0, 0, 0, 0,
        0, 0.7, 0, 0, 0,
        0, 0, 0.7, 0, 0,
        0, 0, 0, 1, 0,
      ]);

  void _openManageEpisodesDialog(Series series) {
    if (_sonarrEpisodes == null) return;
    logTrace('[SeriesScreen] Opening ManageEpisodes dialog for "${series.name}" (sonarrId=$_sonarrSeriesId, ${_sonarrEpisodes!.length} cached eps)');
    showPaddedDialog(
      context,
      navigationItem: DialogNavigationItem(id: 'series:manage-episodes', title: 'Manage Episodes'),
      builder: (context, item, options) {
        return PaddedDialog.custom(
          navigationItem: item,
          barrierOptions: options,
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
          contentBuilder: (_, __) => ManageEpisodesDialog(
            sonarrEpisodes: _sonarrEpisodes!,
            localSeries: series,
            seriesTitle: series.name,
            sonarrSeriesId: _sonarrSeriesId,
          ),
        );
      },
    );
  }

  Future<void> _setupSonarrLink(Series series) async {
    final anilistId = series.primaryAnilistId;
    if (anilistId == null) return;

    final titleObj = series.anilistData?.title;
    final title = AnilistTitle(
      romaji: titleObj?.romaji,
      english: titleObj?.english,
      userPreferred: titleObj?.userPreferred,
    );

    showPaddedDialog(
      context,
      navigationItem: DialogNavigationItem(id: 'sonarr:manual-link', title: 'Link to Sonarr Series'),
      builder: (context, item, options) {
        return PaddedDialog.custom(
          navigationItem: item,
          barrierOptions: options,
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
          contentBuilder: (_, __) => SonarrManualLinkDialog(
            animeId: anilistId,
            animeTitle: title,
            onLinked: () {
              if (mounted) _vm.fetchSonarrEpisodes();
            },
          ),
        );
      },
    );
  }

  Future<ImageProvider?> _getMappingImage({required bool banner}) => _vm.getMappingImage(banner: banner);

  void _playEpisode(Episode episode) => _vm.playEpisode(episode);

  /// Passed to [linkWithAnilist] as its data-loader callback.
  Future<void> _loadAnilistData(List<int> ids, {bool force = false}) => _vm.loadAnilistData(ids, force: force);

  /// Force reload for the given IDs. Called externally via [seriesScreenKey] by
  /// the image-selection dialog after linking.
  Future<void> loadAnilistData(List<int> ids) => _vm.loadAnilistDataForced(ids);

  /// Change the primary AniList ID. Called externally via [seriesScreenKey] by
  /// the AniList link dialog.
  Future<void> changePrimaryId(int id) => _vm.changePrimaryId(id);

  @override
  Widget build(BuildContext context) {
    // Rebuild when the ViewModel notifies (node drill-down, Sonarr loads, AniList refresh, etc.)
    final vm = context.watch<SeriesViewModel>();

    if (widget.seriesPath == null)
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No series selected', style: Manager.subtitleStyle),
            VDiv(16),
            StandardButton.label(
              onPressed: widget.onBack,
              tooltip: 'Go back to the library',
              label: 'Back to Library',
            ),
          ],
        ),
      );

    // Use context.select to listen to changes in this specific series
    final series = context.select<Library, Series?>((library) => library.getSeriesByPath(widget.seriesPath!));

    // Keep the VM's cached series reference aligned with the reactive value.
    vm.syncSeries(series);

    if (series == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Series not found', style: Manager.subtitleStyle),
            VDiv(16),
            StandardButton.label(
              onPressed: widget.onBack,
              tooltip: 'Go back to the library',
              label: 'Back to Library',
            ),
          ],
        ),
      );
    }

    // Resolve the folder node to render (root, or a sub-folder for nesting),
    // walking a memoized tree so hover/color rebuilds don't reconstruct it.
    final resolvedNode = vm.resolveNode(series);

    if (resolvedNode == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Folder not found', style: Manager.subtitleStyle),
            VDiv(8),
            Text('This folder may have been moved or removed.', style: Manager.captionStyle, textAlign: TextAlign.center),
            VDiv(16),
            StandardButton.label(
              onPressed: widget.onBack,
              tooltip: 'Go back',
              label: 'Back',
            ),
          ],
        ),
      );
    }

    // Compute the file-level mappings at this node once per build (used by both
    // the card grid and the episode-grid exclusion).
    vm.recomputeFileMappings(series, resolvedNode);

    // One-time, node-dependent loads (view type, episode titles, Sonarr)
    if (vm.consumeNodeInit()) nextFrame(() => vm.initNodeData());

    // Key is stable per-series (NOT per-node), so drilling into a folder/mapping
    // keeps the same scaffold/sticky-header and crossfades the inner content
    // instead of replacing (and re-animating) the whole page.
    return DeferredPointerHandler(
      key: ValueKey('series:${series.path}'),
      link: deferredPointerLink,
      child: MiruRyoikiTemplatePage(
        headerWidget: _buildHeader(context, series),
        infobar: (_) => _buildInfoBar(context, series),
        content: _buildNodeContent(context, series),
        backgroundColor: Manager.currentDominantColor,
        onHeaderCollapse: () => _descriptionController.collapse(),
        scrollableContent: false,
      ),
    );
  }

  /// A stable key for the currently rendered node, used to drive the crossfade
  /// [AnimatedSwitcher]s when drilling between the series root and its folders.
  Key get _nodeSwitchKey => ValueKey('node:${_vm.currentNodePath?.path ?? 'root'}');

  /// Top-left-anchored layout (cards-only nodes sit at the top-left of the content
  /// area rather than floating in the middle), shared by the node content grid and
  /// header image [AnimatedSwitcher]s.
  static final _topLeftLayout = stackLayoutBuilder(alignment: Alignment.topLeft);

  /// [AnimatedSwitcher] crossfade shared by the node content grid and header image,
  /// both of which crossfade when drilling into a folder/mapping.
  Widget _nodeCrossfade({required Widget child}) {
    return AnimatedSwitcher(
      duration: nodeCrossfadeDuration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: _topLeftLayout,
      child: child,
    );
  }

  /// The node's content grid, crossfaded when the current node changes.
  Widget _buildNodeContent(BuildContext context, Series series) {
    return _nodeCrossfade(
      child: KeyedSubtree(
        key: _nodeSwitchKey,
        child: _buildContentGrid(context, series),
      ),
    );
  }

  HeaderWidget _buildHeader(BuildContext context, Series series) {
    final isMapping = isMappingMode;
    final title = isMapping ? (_resolvedNode?.displayName ?? series.displayTitle) : series.displayTitle;
    final description = isMapping ? _cachedMapping?.anilistData?.description : series.description;
    final imageFuture = isMapping ? _getMappingImage(banner: true) : series.getBannerImage();

    return HeaderWidget(
      image_widget: _nodeCrossfade(
        child: FutureBuilder(
          key: _nodeSwitchKey,
          future: imageFuture,
          builder: (context, snapshot) {
          return Stack(
            children: [
              // Banner
              ShiftClickableHover(
                color: Manager.currentDominantColor,
                enabled: !isMapping && _isBannerHovering && !bannerChangeDisabled,
                onTap: (context) => selectSeriesImage(context, isBanner: true, series: _cachedSeries),
                onEnter: bannerChangeDisabled ? () {} : () => setState(() => _isBannerHovering = true),
                onExit: () {
                  StatusBarManager().hide();
                  setState(() => _isBannerHovering = false);
                },
                onHover: bannerChangeDisabled ? null : () => StatusBarManager().show(KeyboardState.shiftPressedNotifier.value ? 'Click to change Banner' : 'Shift-click to change Banner', autoHideDuration: Duration.zero),
                finalChild: (BuildContext context, bool enabled) {
                  return Stack(
                    children: [
                      AnimatedOpacity(
                        duration: shortStickyHeaderDuration,
                        opacity: enabled ? 0.75 : 1,
                        child: AnimatedContainer(
                          duration: shortStickyHeaderDuration,
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
                            color: enabled ? (Manager.currentDominantColor ?? Manager.accentColor).withOpacity(0.75) : Colors.transparent,
                            image: _getBannerDecoration(snapshot.data),
                          ),
                          padding: const EdgeInsets.only(bottom: 16.0),
                          alignment: Alignment.bottomLeft,
                          child: Builder(builder: (context) {
                            if (snapshot.data != null) return SizedBox.shrink();

                            return Center(
                              child: Stack(
                                children: [
                                  AnimatedOpacity(
                                    duration: shortStickyHeaderDuration,
                                    opacity: enabled ? 0 : 1,
                                    child: Icon(FluentIcons.picture, size: 48, color: Colors.white),
                                  ),
                                  AnimatedOpacity(
                                    duration: shortStickyHeaderDuration,
                                    opacity: enabled ? 1 : 0,
                                    child: Icon(FluentIcons.add, size: 48, color: Colors.white),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                      ...[
                        AnimatedOpacity(
                          duration: shortStickyHeaderDuration,
                          opacity: enabled && snapshot.data != null ? 1 : 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Colors.black.withOpacity(.95),
                                  Colors.black.withOpacity(0),
                                ],
                                radius: 0.5,
                                center: Alignment.center,
                                focal: Alignment.center,
                              ),
                            ),
                            child: Center(
                              child: Icon(FluentIcons.edit, size: 35, color: Colors.white),
                            ),
                          ),
                        ),
                        AnimatedOpacity(
                          duration: shortStickyHeaderDuration,
                          opacity: enabled && snapshot.data != null ? 1 : 0,
                          child: Center(
                            child: Icon(FluentIcons.edit, size: 35, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              // temp buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackButton(onTap: _handleBack, label: _vm.canPopNode ? 'Back' : 'Back to Library', child: const Icon(FluentIcons.back)),
                  // ... other buttons
                ],
              )
            ],
          );
        },
        ),
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
            child: parser.parse(description, selectable: true),
          ),
          VDiv(8),
        ],
      ],
    );
  }

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

  MiruRyoikiInfobar _buildInfoBar(BuildContext context, Series series) {
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
    final isMapping = isMappingMode;
    final posterImage = isMapping ? _getMappingImage(banner: false) : series.getPosterImage();

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
        StandardButton(
          label: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(mat.Icons.folder_open),
              HDiv(4),
              Text(
                isMapping ? 'Open Folder' : 'Open Series Folder',
                style: getStyleBasedOnAccent(false),
              ),
            ],
          ),
          expand: true,
          tooltip: 'Open this folder in your file explorer',
          onPressed: () => ShellUtils.openFolder(isMapping ? (_resolvedNode?.path.path ?? series.path.path) : series.path.path),
        ),
        if (isMapping && _cachedMapping != null && _cachedMapping!.anilistData != null) ...[
          SizedBox(height: 6.0),
          StandardButton(
            label: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(mat.Icons.edit_note),
                HDiv(4),
                Text(
                  'Edit AniList Entry',
                  style: getStyleBasedOnAccent(false),
                ),
              ],
            ),
            expand: true,
            tooltip: 'Edit this entry on AniList',
            isButtonDisabled: anilistProvider.isOffline || !anilistProvider.isLoggedIn,
            onPressed: () => openEntryEditorForMapping(context, _cachedMapping!),
          ),
        ],
        // Unlinked folder node → offer to link it directly (pre-targeted to this folder)
        if (isMapping && _cachedMapping == null && _resolvedNode?.collection != null) ...[
          SizedBox(height: 6.0),
          StandardButton(
            label: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FluentIcons.add_link),
                HDiv(4),
                Text(
                  'Link to AniList',
                  style: getStyleBasedOnAccent(false),
                ),
              ],
            ),
            expand: true,
            tooltip: 'Link this folder to an AniList entry',
            isButtonDisabled: anilistProvider.isOffline || !anilistProvider.isLoggedIn,
            onPressed: () => linkWithAnilist(
              context,
              series,
              _loadAnilistData,
              setState,
              initialLocalPath: _resolvedNode!.path,
              lockLocal: true,
              startInAddMode: true,
              explorerOptions: FileExplorerOptions(
                allowCreateFolder: true,
                allowRename: true,
                allowCurrentFolder: true,
                allowDelete: true,
              ),
            ),
          ),
        ],
        if (!isMapping) ...[
          SizedBox(height: 6.0),
          _buildManageLinksButton(anilistProvider, series),
          if (series.isLinked && series.anilistData != null && TorrentManager.isEnabled) ...[
            SizedBox(height: 6.0),
            if (_sonarrSeriesId != null && _sonarrEpisodes != null)
              StandardButton(
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(mat.Icons.playlist_add_check),
                    HDiv(4),
                    Text(
                      'Manage Episodes',
                      style: getStyleBasedOnAccent(false),
                    ),
                  ],
                ),
                expand: true,
                tooltip: 'Manage episode file links with Sonarr',
                onPressed: () => _openManageEpisodesDialog(series),
              )
            else
              StandardButton(
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(mat.Icons.link),
                    HDiv(4),
                    Text(
                      'Link to Sonarr',
                      style: getStyleBasedOnAccent(false),
                    ),
                  ],
                ),
                expand: true,
                tooltip: 'Set up Sonarr series link for episode management',
                onPressed: () => _setupSonarrLink(series),
              ),
          ],
        ],
      ],
      poster: ({required imageProvider, required width, required height, required squareness, required offset}) {
        return DeferPointer(
          link: deferredPointerLink,
          paintOnTop: true,
          child: SizedBox(
            height: height - offset,
            width: width,
            child: ShiftClickableHover(
              color: Manager.currentDominantColor,
              enabled: !isMapping && _isPosterHovering && !posterChangeDisabled,
              onTap: (context) => selectSeriesImage(context, isBanner: false, series: _cachedSeries),
              onEnter: posterChangeDisabled ? () {} : () => setState(() => _isPosterHovering = true),
              onExit: () {
                setState(() => _isPosterHovering = false);
                StatusBarManager().hide();
              },
              onHover: posterChangeDisabled ? null : () => StatusBarManager().show(KeyboardState.shiftPressedNotifier.value ? 'Click to change Poster' : 'Shift-click to change Poster', autoHideDuration: Duration.zero),
              finalChild: (BuildContext context, bool enabled) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
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
                              colorFilter: series.posterImage != null ? ColorFilter.mode(Colors.black.withOpacity(0), BlendMode.darken) : null,
                              blurSigma: 0,
                              shadowColorOpacity: 0,
                            ),
                          );

                        // No image -> image + plus to add first
                        return Center(
                          child: Stack(
                            children: [
                              AnimatedOpacity(
                                duration: shortStickyHeaderDuration,
                                opacity: enabled ? 0 : 1,
                                child: Icon(FluentIcons.picture, size: 48, color: Colors.white),
                              ),
                              AnimatedOpacity(
                                duration: shortStickyHeaderDuration,
                                opacity: enabled ? 1 : 0,
                                child: Icon(FluentIcons.add, size: 48, color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    // Edit poster
                    ...[
                      AnimatedOpacity(
                        duration: shortStickyHeaderDuration,
                        opacity: enabled && imageProvider != null ? 1 : 0,
                        child: AnimatedContainer(
                          width: width,
                          height: height,
                          duration: shortStickyHeaderDuration,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
                            gradient: RadialGradient(
                              colors: [
                                Colors.black.withOpacity(.95),
                                (Manager.currentDominantColor ?? Manager.accentColor).withOpacity(.2),
                              ],
                              radius: 0.5,
                              center: Alignment.center,
                              focal: Alignment.center,
                            ),
                          ),
                          child: Center(
                            child: Icon(FluentIcons.edit, size: 35, color: Colors.white),
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                        duration: shortStickyHeaderDuration,
                        opacity: enabled && imageProvider != null ? 1 : 0,
                        child: Center(child: Icon(FluentIcons.edit, size: 35, color: Colors.white)),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Builder _buildManageLinksButton(AnilistProvider anilistProvider, Series series) {
    return Builder(
      builder: (context) {
        // Compute tooltip with switch-case outside of the widget
        String tooltipKey;
        if (!anilistProvider.isLoggedIn)
          tooltipKey = 'notLoggedIn';
        // else if (isIndexing)
        //   tooltipKey = 'indexing';
        else if (!series.isLinked)
          tooltipKey = 'notLinked';
        else
          tooltipKey = 'linked';

        String tooltipText = switch (tooltipKey) {
          // 'indexing' => 'Cannot link while library is indexing, please wait.',
          'notLinked' => 'Link with Anilist',
          'linked' => 'Manage Anilist Links',
          'notLoggedIn' => 'You must be logged in to Anilist to link series.',
          _ => '',
        };

        return StandardButton(
          expand: true,
          tooltip: tooltipText,
          label: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(series.isLinked ? FluentIcons.link : FluentIcons.add_link),
              HDiv(4),
              Text(
                !series.isLinked ? 'Link with Anilist' : 'Manage Anilist Links',
                style: getStyleBasedOnAccent(false),
              ),
            ],
          ),
          onPressed: () {
            // // Check if the action should be disabled during indexing
            // if (library.lockManager.shouldDisableAction(UserAction.anilistOperations)) {
            //   snackBar(
            //     library.lockManager.getDisabledReason(UserAction.anilistOperations),
            //     severity: InfoBarSeverity.warning,
            //   );
            //   return;
            // }

            linkWithAnilist(context, series, _loadAnilistData, setState,
                explorerOptions: FileExplorerOptions(
                  allowCreateFolder: true,
                  allowRename: true,
                  allowCurrentFolder: true,
                  allowDelete: true,
                ));
          },
          isButtonDisabled: anilistProvider.isOffline,
        );
      },
    );
  }

  Widget _buildInfoBarContent(Series series) {
    final infos_ = infos(series);
    final isMapping = isMappingMode;
    final genres = isMapping ? (_cachedMapping?.anilistData?.genres ?? []) : series.genres;
    final watchedPercentage = isMapping ? (_resolvedNode?.watchedPercentage ?? 0) : series.watchedPercentage;
    final nodeMeta = _resolvedNode?.collection?.metadata;

    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Series metadata
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: () {
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
          ),

          // Genre tags
          if (genres.isNotEmpty) ...[
            VDiv(16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: genres.map((genre) => Chip(text: (color) => Text(genre, style: Manager.bodyStyle.copyWith(color: color)))).toList(),
            ),
          ],

          // Progress bar
          VDiv(16),
          SizedBox(
            width: 300,
            child: AnimatedColor(
                color: Manager.currentDominantColor,
                duration: gradientChangeDuration,
                builder: (color) {
                  return ProgressBar(
                    value: watchedPercentage * 100,
                    activeColor: color,
                    backgroundColor: Colors.white.withOpacity(.3),
                  );
                }),
          ),

          if (isMapping ? (nodeMeta != null) : (series.metadata != null)) ...[
            VDiv(16),
            Wrap(alignment: WrapAlignment.spaceBetween, spacing: 8, runSpacing: 8, children: [
              InfoLabel(
                label: 'Path',
                child: Text(
                  _libraryRelativePath(isMapping ? (_resolvedNode?.path.path ?? series.path.path) : series.path.path),
                  style: Manager.captionStyle,
                ),
              ),
              InfoLabel(
                label: 'Size',
                child: Text(isMapping ? nodeMeta!.fileSize() : series.metadata!.fileSize(), style: Manager.captionStyle),
              ),
              InfoLabel(
                label: 'First Downloaded',
                child: Text(isMapping ? nodeMeta!.creationTime.pretty() : series.metadata!.creationTime.pretty(), style: Manager.captionStyle),
              ),
              InfoLabel(
                label: 'Last Modified',
                child: Text(isMapping ? nodeMeta!.lastModified.pretty() : series.metadata!.lastModified.pretty(), style: Manager.captionStyle),
              ),
            ]),
            VDiv(16),
          ],
        ],
      );
    });
  }

  Widget _buildContentGrid(BuildContext context, Series series) {
    final node = _resolvedNode;
    if (node == null) return const SizedBox.shrink();

    final cards = _buildNodeCards(node, series);
    final hasCards = cards.isNotEmpty;
    final hasEpisodes = _mergedEpisodes.isNotEmpty;

    // Genuinely empty node
    if (!hasCards && !hasEpisodes) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FluentIcons.fabric_folder, size: 48, color: Manager.accentColor.lighter),
              VDiv(16),
              Text('No episodes found in this folder', style: Manager.subtitleStyle),
            ],
          ),
        ),
      );
    }

    // Pure episode node (a season / leaf folder): the classic episode-grid layout.
    if (!hasCards) return _buildEpisodeSection(context, series, nested: false);

    // Folder container: a grid of folder/file cards, with the episode grid below
    // it when the node also holds loose episodes (e.g. the series root).
    return LayoutBuilder(
      builder: (context, constraints) {
        return ScrollConfiguration(
          behavior: ScrollBehavior().copyWith(overscroll: false, scrollbars: false),
          child: SmoothScroll(
            enableSmoothScroll: Manager.animationsEnabled,
            builder: (context, controller, physics) {
              return SingleChildScrollView(
                controller: controller,
                physics: physics,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ScreenUtils.crossAxisCount(constraints.maxWidth),
                        childAspectRatio: ScreenUtils.kDefaultAspectRatio,
                        crossAxisSpacing: ScreenUtils.cardPadding,
                        mainAxisSpacing: ScreenUtils.cardPadding,
                      ),
                      children: cards,
                    ),
                    if (hasEpisodes) ...[
                      VDiv(16),
                      _buildEpisodeSection(context, series, nested: true),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Cards for the node's child sub-folders plus any file-level (single-file)
  /// AniList mappings located directly in this node (e.g. a mapped movie).
  List<Widget> _buildNodeCards(FolderNode node, Series series) {
    final cards = <Widget>[];

    for (final child in node.children) {
      cards.add(FolderCard(
        key: ValueKey('folder:${child.path}'),
        node: child,
        series: series,
        onTap: () => navigateToNode(child),
      ));
    }

    for (final (m, target) in _fileMappingsAtNode) {
      cards.add(MappingCard(
        key: ValueKey('file:${m.localPath}:${m.anilistId}'),
        target: target,
        series: series,
        mapping: m,
        onTap: () {
          final ep = target.asEpisode;
          if (ep != null) _playEpisode(ep);
        },
      ));
    }

    return cards;
  }

  /// The episode-grid section for the current node. [nested] embeds it inside a
  /// parent scroll view (folder-container layout); otherwise it fills the
  /// remaining space (classic season layout).
  Widget _buildEpisodeSection(BuildContext context, Series series, {required bool nested}) {
    final headerHeight = 45.0;
    final borderRadius = ScreenUtils.kStatCardBorderRadius;

    // Presentational text colors for the view-type switcher, derived from the
    // current dominant color.
    final textColor = Colors.white;
    final selectedTextColor = getTextColor(Manager.currentDominantColor ?? Manager.accentColor);

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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HDiv(6),
            ViewTypeSwitcher(
              useBorder: false,
              currentViewType: _currentViewType,
              textColor: textColor,
              selectedTextColor: selectedTextColor,
              onViewTypeChanged: _onViewTypeChanged,
            ),
            HDiv(3.5),
          ],
        ),
      ),
    );

    final card = Card(
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
          child: EpisodeGrid(
            collapsable: false,
            nested: nested,
            episodes: _mergedEpisodes,
            onTap: (uiEpisode) => _onEpisodeTap(uiEpisode, series),
            series: series,
            mapping: _cachedMapping,
            padding: EdgeInsets.only(right: 14),
          ),
        ),
      ),
    );

    if (nested) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [visibleHeader, SizedBox(height: 4), card],
      );
    }

    return Column(
      children: [visibleHeader, SizedBox(height: 4), Expanded(child: card)],
    );
  }

  void _onEpisodeTap(UIEpisode uiEpisode, Series series) {
    // If the episode can be played, play it
    if (uiEpisode.canPlay) {
      _playEpisode(uiEpisode.localEpisode!);
      return;
    }

    // If the episode is released or in the future, open search dialog
    if (uiEpisode.state == EpisodeState.released || uiEpisode.state == EpisodeState.future) {
      final controller = TorrentManager.downloadController;
      if (controller == null) {
        snackBar('Download client not configured. Set up qBittorrent in Settings.', severity: InfoBarSeverity.warning);
        return;
      }

      final titleObj = _cachedMapping?.anilistData?.title ?? _cachedSeries?.anilistData?.title; // TODO get name from Sonarr, as it's "simpler" and more likely to be correct for the episode search than the AniList title which is not guaranteed to be accurate for the series as a whole (especially for mappings that are not the first season)
      final titles = <String>{
        if (titleObj?.userPreferred != null) titleObj!.userPreferred!,
        if (titleObj?.romaji != null) titleObj!.romaji!,
        if (titleObj?.english != null) titleObj!.english!,
      }.where((t) => t.trim().isNotEmpty).toList();

      if (titles.isEmpty) titles.add(series.displayTitle);

      final sonarrEp = uiEpisode.sonarrEpisode;
      final seasonNum = sonarrEp?.seasonNumber ?? _resolvedNode?.seasonNumber;

      showPaddedDialog(
        context,
        navigationItem: DialogNavigationItem(
          id: 'knaben:episode-search',
          title: 'Episode Search',
        ),
        builder: (context, item, options) {
          return PaddedDialog.custom(
            navigationItem: item,
            barrierOptions: options,
            constraints: const BoxConstraints(maxWidth: 900, maxHeight: 900),
            contentBuilder: (_, __) => KnabenSearchDialog(
              item: item,
              controller: controller,
              seriesTitles: titles,
              season: seasonNum,
              episode: sonarrEp?.episodeNumber ?? uiEpisode.episodeNumber,
              episodeTitle: uiEpisode.isSpecial ? uiEpisode.displayTitle : null,
              sonarrEpisodeId: sonarrEp?.id,
              sonarrSeriesId: _sonarrSeriesId,
              series: series,
            ),
          );
        },
      );
    }
  }
}

void selectSeriesImage(BuildContext context, {required bool isBanner, Series? series}) {
  final library = Provider.of<Library>(context, listen: false);
  if (series == null) return;

  // Check if the action should be disabled during indexing
  if (library.lockManager.shouldDisableAction(UserAction.seriesImageSelection)) {
    snackBar(
      library.lockManager.getDisabledReason(UserAction.seriesImageSelection),
      severity: InfoBarSeverity.warning,
    );
    return;
  }

  showPaddedDialog(
    context,
    navigationItem: DialogNavigationItem(
      id: isBanner ? 'series:banner-selection:${series.path}' : 'series:poster-selection:${series.path}',
      title: isBanner ? 'Select Banner' : 'Select Poster',
      dialogDoPopCheck: () => true,
    ),
    builder: (ctx, item, options) {
      const boxConstraints = BoxConstraints(maxWidth: 1000, maxHeight: 700);
      return PaddedDialog.custom(
        navigationItem: item,
        barrierOptions: options,
        constraints: boxConstraints,
        alignment: Alignment.center,
        contentBuilder: (context, _) => ImageSelectionContent(
          series: series,
          constraints: boxConstraints,
          isBanner: isBanner,
          onSave: (source, path) async {
            // Save the selection
            final library = Provider.of<Library>(context, listen: false);

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

            final seriesScreenState = seriesScreenKey.currentState;
            if (seriesScreenState != null) {
              // log('Disabling poster/banner change buttons');
              seriesScreenState.posterChangeDisabled = !isBanner;
              seriesScreenState.bannerChangeDisabled = isBanner;
            }

            Provider.of<LibraryScreenViewModel>(context, listen: false).updateSeriesInSortCache(updatedSeries);
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
              final seriesScreenState = seriesScreenKey.currentState;
              if (seriesScreenState != null) {
                // log('Enabling poster/banner change buttons');
                seriesScreenState.posterChangeDisabled = false;
                seriesScreenState.bannerChangeDisabled = false;
              }
              Manager.setState();
            });
          },
        ),
      );
    },
  ).then((source) {
    if (context.mounted) Manager.setState();
  });
}
