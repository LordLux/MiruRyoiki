import 'dart:async';
import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:miruryoiki/widgets/acrylic_header.dart';
import 'package:miruryoiki/widgets/file_explorer.dart';
import 'package:provider/provider.dart';
import 'package:defer_pointer/defer_pointer.dart';

import '../main.dart';
import '../models/anilist/anime.dart';
import '../services/connectivity/connectivity_service.dart';
import '../services/downloads/torrent_manager.dart';
import '../services/library/library_provider.dart';
import '../services/lock_manager.dart';
import '../services/navigation/dialogs2.dart';
import '../services/episode_navigation/anilist_progress_manager.dart';
import '../services/navigation/show_info.dart';
import '../services/navigation/statusbar.dart';
import '../utils/color.dart';
import '../utils/path.dart';
import '../utils/shell.dart';
import '../utils/text.dart';
import '../widgets/animated_color_wrapper.dart';
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
import '../models/season.dart';
import '../models/series.dart';
import '../services/anilist/linking.dart';
import '../services/navigation/navigation.dart';
import '../services/navigation/shortcuts.dart';
import '../utils/logging.dart';
import '../utils/error_handling.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import '../widgets/dialogs/show_dialog.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/infobar.dart';
import '../widgets/page/page_template.dart';
import '../widgets/cards/mapping_card.dart';
import '../widgets/cards/folder_card.dart';
import '../models/folder_node.dart';
import 'package:path/path.dart' as p;
import '../widgets/shift_clickable_hover.dart';
import '../widgets/shrinker.dart';
import '../widgets/simple_html_parser.dart';
import '../widgets/transparency_shadow_image.dart';
import '../models/mapping_target.dart';
import 'package:recase/recase.dart';
import '../services/file_system/cache.dart';
import '../widgets/viewtype_switcher.dart';
import 'anilist_settings.dart';
import '../models/episode.dart';
import '../models/ui_episode.dart';
import '../models/sonarr/sonarr_episode.dart';
import '../widgets/dialogs/knaben_search.dart';
import '../widgets/episode_grid.dart';
import '../widgets/dialogs/manage_episodes_dialog.dart';
import '../widgets/dialogs/sonarr_manual_link_dialog.dart';

/// Duration for which AniList data is considered fresh and doesn't need refetching
const Duration kAnilistCacheDuration = Duration(days: 1);

class SeriesScreen extends StatefulWidget {
  final PathString? seriesPath;
  final VoidCallback onBack;

  /// The folder node to render. Null (or == seriesPath) means the series root.
  /// Any deeper path renders that sub-folder as its own node (recursive nesting).
  final PathString? nodePath;

  const SeriesScreen({
    super.key,
    required this.seriesPath,
    required this.onBack,
    this.nodePath,
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

  List<SonarrEpisode>? _sonarrEpisodes;
  int? _sonarrSeriesId;

  /// Sonarr episodes filtered to the current target season only
  ///
  /// Returns null for EpisodeTargets as single-episode mappings don't use Sonarr
  List<SonarrEpisode>? get _sonarrEpisodesForTarget {
    if (_sonarrEpisodes == null) return null;
    if (_cachedTarget == null || _cachedTarget!.isEpisode) return null;

    final seasonNum = (_cachedTarget!.asCollection is Season) ? (_cachedTarget!.asCollection as Season).seasonNumber : null;
    if (seasonNum == null) return _sonarrEpisodes;

    return _sonarrEpisodes!.where((e) => e.seasonNumber == seasonNum).toList();
  }

  bool _isPosterHovering = false;
  bool _isBannerHovering = false;
  DeferredPointerHandlerLink? deferredPointerLink;

  /// Cached reference to the current series, updated via Selector in build()
  Series? _cachedSeries;

  /// The folder node currently rendered (root or a sub-folder). Re-derived from
  /// the live [Series] each build via [resolveNode] — no manual cache invalidation.
  FolderNode? _resolvedNode;

  bool _nodeInitialized = false;

  /// The AniList mapping (if any) attached to the current node.
  AnilistMapping? get _cachedMapping => _resolvedNode?.mapping;

  /// A [MappingTarget] for the current node's collection, or null for the root /
  /// synthesized intermediate folders that have no collection of their own.
  MappingTarget? get _cachedTarget {
    final c = _resolvedNode?.collection;
    return c != null ? MappingTarget.collection(c) : null;
  }

  /// Memoized folder tree. Rebuilt only when the series instance, its data
  /// version, or its mapping count changes — NOT on hover/color/setState
  /// rebuilds, which previously reconstructed the whole tree every frame.
  FolderNode? _treeRoot;
  Series? _treeSeries;
  int _treeVersion = -1;
  int _treeMappingCount = -1;

  FolderNode _buildOrGetTree(Series series, int dataVersion) {
    if (_treeRoot != null && //
        identical(_treeSeries, series) &&
        _treeVersion == dataVersion &&
        _treeMappingCount == series.anilistMappings.length) {
      return _treeRoot!;
    }
    _treeRoot = buildFolderTree(series);
    _treeSeries = series;
    _treeVersion = dataVersion;
    _treeMappingCount = series.anilistMappings.length;
    return _treeRoot!;
  }

  /// Cached merged episodes list to avoid recomputing on every build
  List<UIEpisode>? _cachedMergedEpisodes;
  String? _lastMergeNodePath;
  int _lastMergeLocalCount = -1;
  int _lastMergeSonarrCount = -1;

  /// File-level (single-file) AniList mappings located directly inside the
  /// current node — they render as their own cards and are excluded from the
  /// episode grid. Computed once per build in [build] via [_recomputeFileMappings]
  /// (single source of truth for both the cards and the grid exclusion).
  List<(AnilistMapping, MappingTarget)> _fileMappingsAtNode = const [];
  Set<String> _fileMappingPaths = const {};

  void _recomputeFileMappings(Series series, FolderNode node) {
    final list = <(AnilistMapping, MappingTarget)>[];
    final paths = <String>{};
    for (final m in series.anilistMappings) {
      final lp = m.localPath.pathMaybe;
      if (lp == null) continue;
      final t = series.getTargetForMapping(m);
      if (t != null && t.isEpisode && p.equals(p.dirname(lp), node.path.path)) {
        list.add((m, t));
        paths.add(lp);
      }
    }
    _fileMappingsAtNode = list;
    _fileMappingPaths = paths;
  }

  /// Episodes shown in the current node's episode grid: the node's direct
  /// episodes minus any that are themselves file-level AniList mappings.
  List<Episode> get _gridEpisodes {
    final node = _resolvedNode;
    if (node == null) return const [];
    if (_fileMappingPaths.isEmpty) return node.directEpisodes;
    return node.directEpisodes.where((e) => !_fileMappingPaths.contains(e.path.pathMaybe)).toList();
  }

  List<UIEpisode> get _mergedEpisodes {
    final localEps = _gridEpisodes;
    // Sonarr episodes are season-scoped — only merge them inside a folder/season
    // node, never into the series root's loose-files grid.
    final sonarrEps = isMappingMode ? _sonarrEpisodesForTarget : null;
    final localCount = localEps.length;
    final sonarrCount = sonarrEps?.length ?? -1;
    final nodePath = _resolvedNode?.path.pathMaybe;

    if (_cachedMergedEpisodes != null && //
        _lastMergeNodePath == nodePath &&
        _lastMergeLocalCount == localCount &&
        _lastMergeSonarrCount == sonarrCount) {
      return _cachedMergedEpisodes!;
    }

    _lastMergeNodePath = nodePath;
    _lastMergeLocalCount = localCount;
    _lastMergeSonarrCount = sonarrCount;
    _cachedMergedEpisodes = UIEpisode.merge(localEps, sonarrEps);
    return _cachedMergedEpisodes!;
  }

  void _invalidateMergedEpisodes() => _cachedMergedEpisodes = null;

  ViewType _currentViewType = ViewType.grid;

  late Color _textColor;
  late Color _selectedTextColor;

  bool get isMappingMode => !(_resolvedNode?.isRoot ?? true);

  /// Push a child folder node onto the navigation stack as its own page,
  /// enabling root → folder → sub-folder → … navigation with a real back stack.
  void navigateToNode(FolderNode node) {
    if (!mounted) return;

    context.read<NavigationManager>().pushPage(
      '/mapping:${node.path}',
      node.displayName,
      data: {
        'seriesPath': widget.seriesPath,
        'nodePath': node.path,
      },
    );
  }

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

  //

  void _loadColors() {
    _textColor = Colors.white;
    _selectedTextColor = getTextColor(Manager.currentDominantColor ?? Manager.accentColor);
  }

  @override
  void initState() {
    super.initState();
    _loadColors();
    if (widget.seriesPath != null) {
      deferredPointerLink = DeferredPointerHandlerLink();
      nextFrame(() => _loadAnilistDataForCurrentSeries());
    }
    _invalidateMergedEpisodes();
    parser = SimpleHtmlParser(context);
  }

  /// Kicks off node-dependent data loads (view type, episode titles, Sonarr)
  /// once the node has been resolved in [build]. Runs once per node.
  void _initNodeData() {
    if (_currentViewType == ViewType.grid && _resolvedNode?.mapping?.viewType != null) //
      _currentViewType = _resolvedNode!.mapping!.viewType!;

    if (isMappingMode)
      _initializeMappingData();
    else if (TorrentManager.isEnabled) //
      _fetchSonarrEpisodes();
  }

  @override
  didUpdateWidget(covariant SeriesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.seriesPath != oldWidget.seriesPath) {
      // Series changed, load new data
      if (widget.seriesPath != null) {
        deferredPointerLink ??= DeferredPointerHandlerLink();
        nextFrame(() => _loadAnilistDataForCurrentSeries());
      }
    }

    // Node (or series) changed → re-init node-dependent data on next build
    if (widget.nodePath != oldWidget.nodePath || widget.seriesPath != oldWidget.seriesPath) {
      _nodeInitialized = false;
      _invalidateMergedEpisodes();
      if (!isMappingMode) //
        Manager.setState(() => Manager.currentDominantColor = Manager.seriesDominantColor ?? Manager.accentColor);
    }
  }

  void _onViewTypeChanged(ViewType newViewType) {
    setState(() => _currentViewType = newViewType);

    final mapping = _resolvedNode?.mapping;
    if (mapping != null) {
      final library = Provider.of<Library>(context, listen: false);
      library.updateMappingViewType(mapping.anilistId, newViewType);
    }
  }

  /// Called by [Library.reloadOpenedSeries] after a library reload. The folder
  /// node is re-derived from the live series in [build], so this just refreshes
  /// AniList data and colors and triggers a rebuild.
  void refreshFromLibrary() {
    if (!mounted) return;

    final library = Provider.of<Library>(context, listen: false);
    final series = library.getSeriesByPath(widget.seriesPath!);
    if (series == null) return;

    _cachedSeries = series;
    _invalidateMergedEpisodes();

    _loadAnilistDataForCurrentSeries();
    _loadColors();

    if (mounted) setState(() {});
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
    if (widget.seriesPath != null && _cachedSeries != null && !_cachedSeries!.isLinked) {
      nextFrame(() => _loadAnilistDataForCurrentSeries());
    }
  }

  ColorFilter get colorFilter => ColorFilter.matrix([
        // Scale down RGB channels (darken)
        0.7, 0, 0, 0, 0,
        0, 0.7, 0, 0, 0,
        0, 0, 0.7, 0, 0,
        0, 0, 0, 1, 0,
      ]);

  /// Initialize mapping data
  Future<void> _initializeMappingData() async {
    if (!mounted || _cachedMapping == null) return;

    final mapping = _cachedMapping!;

    // Calculate dominant color from the mapping's anilistData
    final dominantColor = await mapping.effectivePrimaryColor(forceRecalculate: false);
    if (!mounted) return;

    Manager.setState(() => Manager.currentDominantColor = dominantColor);

    // Fetch episode titles from AniList
    try {
      final (newSeries, episodeTitlesUpdated) = await Manager.episodeTitleService.fetchAndUpdateEpisodeTitlesFromMapping(mapping);
      if (episodeTitlesUpdated && mounted) {
        logTrace('Episode titles updated, refreshing UI');
        setState(() {}); // Refresh UI to show updated episode titles
      }

      if (newSeries != null && libraryScreenKey.currentState != null) {
        libraryScreenKey.currentState!.updateSeriesInSortCache(newSeries);
      }
    } catch (e) {
      logErr('Error fetching episode titles', e);
    }

    _fetchSonarrEpisodes();
  }

  Future<void> _fetchSonarrEpisodes() async {
    final torrentController = TorrentManager.downloadController;
    if (torrentController == null) return;

    final anilistId = _cachedMapping?.anilistId ?? _cachedSeries?.primaryAnilistId;
    if (anilistId == null) return;

    final titleObj = _cachedMapping?.anilistData?.title ?? _cachedSeries?.anilistData?.title;
    final fallbackTitle = titleObj?.userPreferred ?? titleObj?.english ?? titleObj?.romaji ?? "";

    logTrace('[SeriesScreen] Fetching Sonarr episodes: anilistId=$anilistId, title="$fallbackTitle"');
    if (!mounted) return;

    try {
      var result = await torrentController.syncAndFetchEpisodes(animeId: anilistId, altTitle: fallbackTitle);

      // If Sonarr just added the series, episodes may not be available yet — retry once
      if (result.$2.isEmpty) {
        logTrace('[SeriesScreen] No episodes returned, retrying after 3s...');
        await Future.delayed(const Duration(seconds: 3));
        if (!mounted) return;
        result = await torrentController.syncAndFetchEpisodes(animeId: anilistId, altTitle: fallbackTitle);
      }

      logTrace('[SeriesScreen] Got sonarrSeriesId=${result.$1}, ${result.$2.length} episodes');
      if (mounted) {
        setState(() {
          _sonarrSeriesId = result.$1;
          _sonarrEpisodes = result.$2;
          _invalidateMergedEpisodes();
        });
      }
    } catch (e, stack) {
      logErr('[SeriesScreen] Failed to fetch sonarr episodes', e, stack);
    }
  }

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
              if (mounted) _fetchSonarrEpisodes();
            },
          ),
        );
      },
    );
  }

  Future<ImageProvider?> _getMappingImage({required bool banner}) async {
    final mapping = _cachedMapping;
    if (mapping == null) return null;

    final imageUrl = banner ? mapping.anilistData?.bannerImage : mapping.anilistData?.posterImage;
    if (imageUrl == null || imageUrl.isEmpty) return null;

    return await ImageCacheService().getImageProvider(imageUrl);
  }

  void _playEpisode(Episode episode) {
    final library = Provider.of<Library>(context, listen: false);
    library.playEpisode(episode);
  }

  Future<void> _loadAnilistDataForCurrentSeries() async {
    final series = _cachedSeries; // get current series
    if (!mounted || widget.seriesPath == null || series == null) return;

    if (!series.isLinked) {
      // Clear any Anilist data references to ensure UI updates
      series.anilistData = null;
      if (homeKey.currentContext?.mounted ?? false) setState(() {});
      _loadColors();
      return;
    }

    // Load data for all mappings
    await _loadAnilistData(anilistIDs);
  }

  List<int> get anilistIDs => _cachedSeries?.anilistMappings.map((e) => e.anilistId).whereType<int>().toSet().toList() ?? [];

  Future<void> loadAnilistData(List<int> ids) async => await _loadAnilistData(ids, force: true); // force reload for single ID

  /// Change the primary AniList ID for the current series
  ///
  /// Assumes the anilistData of the mapping is already loaded
  Future<void> changePrimaryId(int id) async {
    final series = _cachedSeries;
    if (series == null) return;

    final mapping = series.anilistMappings.firstWhere(
      (m) => m.anilistId == id,
      orElse: () => series.anilistMappings.first, // fallback, shouldn't happen
    );

    setState(() {
      series.primaryAnilistId = mapping.anilistId;
      series.anilistData = mapping.anilistData;
      final newColor = mapping.effectivePrimaryColorSync();
      Manager.currentDominantColor = newColor;
      Manager.seriesDominantColor = newColor;
    });

    // Save the updated series to the library
    final BuildContext? ctx;
    if (mounted)
      ctx = context;
    else
      ctx = rootNavigatorKey.currentContext;

    if (ctx != null && ctx.mounted) {
      try {
        final library = Provider.of<Library>(ctx, listen: false);

        // Update the series mappings with the new primary ID
        await library.updateSeriesMappings(series, series.anilistMappings);

        // Also update the series
        await library.updateSeries(series, invalidateCache: false);

        if (libraryScreenKey.currentState != null) libraryScreenKey.currentState!.updateSeriesInSortCache(series);

        logTrace('Changed primary AniList ID to $id, saved to library');
      } catch (e) {
        logErr('Error updating series primary AniList ID: $e');
      }
    }
  }

  Future<void> _loadAnilistData(List<int> anilistIDs, {bool force = false}) async {
    final series = _cachedSeries;
    if (series == null) return;

    // Identify IDs that need fetching
    final currentTime = now;
    final idsToFetch = anilistIDs.where((id) {
      final mapping = series.anilistMappings.firstWhereOrNull((m) => m.anilistId == id);
      if (mapping == null) return false;

      return force || //
          mapping.lastSynced == null ||
          currentTime.difference(mapping.lastSynced!) > kAnilistCacheDuration ||
          mapping.anilistData?.posterImage == null ||
          mapping.anilistData?.bannerImage == null;
    }).toList();

    if (idsToFetch.isEmpty) return;

    logTrace('Fetching AniList data for ${idsToFetch.length} IDs: ${idsToFetch.join(', ')}');

    try {
      final Map<int, AnilistAnime?> fetchedData = await SeriesLinkService().fetchMultipleAnimeDetails(idsToFetch);
      if (!mounted) return;

      final library = Provider.of<Library>(context, listen: false);

      bool needsFullSave = false;
      bool dominantColorChanged = false;
      final List<Future<void> Function()> pendingPartialUpdates = [];

      for (final entry in fetchedData.entries) {
        final anilistId = entry.key;
        final anilistAnime = entry.value;

        if (anilistAnime == null) {
          if (ConnectivityService().isOffline)
            logWarn('Failed to fetch AniList details for ID $anilistId: device is offline');
          else
            logErr('Failed to load Anilist data for ID: $anilistId');

          continue;
        }

        final mapping = series.anilistMappings.firstWhereOrNull((m) => m.anilistId == anilistId);
        if (mapping == null) continue;

        final oldData = mapping.anilistData;
        final bool isPrimary = series.primaryAnilistId == anilistId || series.primaryAnilistId == null;

        // Update in memory
        mapping.anilistData = anilistAnime;
        mapping.lastSynced = currentTime;

        // Check for image changes | non primary mappings use updateMappingAnilistData whose update includes the new images
        if (isPrimary && (oldData?.posterImage != anilistAnime.posterImage || oldData?.bannerImage != anilistAnime.bannerImage)) //
          needsFullSave = true;

        // Check for dominant color changes
        if (isPrimary) {
          final oldColor = Manager.currentDominantColor;
          // Force recalculate because mapping data changed
          final newColor = await series.effectivePrimaryColor(forceRecalculate: true);

          if (oldColor?.value != newColor?.value) {
            dominantColorChanged = true;
            needsFullSave = true;

            if (!isMappingMode) {
              // In series mode, update both current and series dominant colors
              Manager.currentDominantColor = newColor;
              Manager.seriesDominantColor = newColor;
            } else {
              // In mapping mode, only update seriesDominantColor
              Manager.seriesDominantColor = newColor;
            }
          }
        }

        // Queue partial update if
        if (!needsFullSave) {
          if (oldData != anilistAnime)
            pendingPartialUpdates.add(() => library.updateMappingAnilistData(series, anilistId, anilistAnime, currentTime));
          else
            pendingPartialUpdates.add(() => library.updateMappingLastSynced(series, anilistId, currentTime));
        }
      }

      if (needsFullSave) {
        Series seriesToSave = series;
        final primaryMapping = series.anilistMappings.firstWhereOrNull((m) => m.anilistId == series.primaryAnilistId);

        if (primaryMapping?.anilistData != null) {
          seriesToSave = series.copyWith(
            anilistPoster: primaryMapping!.anilistData!.posterImage,
            anilistBanner: primaryMapping.anilistData!.bannerImage,
          );
        }

        await library.updateSeriesMappings(seriesToSave, seriesToSave.anilistMappings);
        await library.updateSeries(seriesToSave, invalidateCache: false);
        logTrace('Performed full series update due to image/color changes.');
      } else {
        // Execute partial updates
        await Future.wait(pendingPartialUpdates.map((update) => update()));
        if (pendingPartialUpdates.isNotEmpty) logTrace('Performed ${pendingPartialUpdates.length} partial updates.');
      }

      // Finalize UI
      if (dominantColorChanged) {
        _loadColors();
        Manager.setState();
      }

      if (libraryScreenKey.currentState != null) libraryScreenKey.currentState!.updateSeriesInSortCache(series);

      if (mounted) setState(() {});
    } catch (e) {
      if (!isExpectedOfflineError(e)) logErr('Failed to load Anilist data', e);
    }
  }

  @override
  Widget build(BuildContext context) {
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

    // Update the cached series reference
    _cachedSeries = series;

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
    final tree = _buildOrGetTree(series, context.read<Library>().dataVersion);
    _resolvedNode = findNodeInTree(tree, widget.nodePath ?? series.path);

    if (_resolvedNode == null) {
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
    _recomputeFileMappings(series, _resolvedNode!);

    // One-time, node-dependent loads (view type, episode titles, Sonarr)
    if (!_nodeInitialized) {
      _nodeInitialized = true;
      nextFrame(() => _initNodeData());
    }

    return DeferredPointerHandler(
      key: ValueKey('${series.path}|${_resolvedNode!.path}'),
      link: deferredPointerLink,
      child: MiruRyoikiTemplatePage(
        headerWidget: _buildHeader(context, series),
        infobar: (_) => _buildInfoBar(context, series),
        content: _buildContentGrid(context, series),
        backgroundColor: Manager.currentDominantColor,
        onHeaderCollapse: () => _descriptionController.collapse(),
        scrollableContent: false,
      ),
    );
  }

  HeaderWidget _buildHeader(BuildContext context, Series series) {
    final isMapping = isMappingMode;
    final title = isMapping ? (_resolvedNode?.displayName ?? series.displayTitle) : series.displayTitle;
    final description = isMapping ? _cachedMapping?.anilistData?.description : series.description;
    final imageFuture = isMapping ? _getMappingImage(banner: true) : series.getBannerImage();

    return HeaderWidget(
      image_widget: FutureBuilder(
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
                  BackButton(onTap: widget.onBack, label: 'Back to Library', child: const Icon(FluentIcons.back)),
                  // ... other buttons
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
                  isMapping ? (_resolvedNode?.path.path ?? series.path.path) : series.path.path,
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
          child: SingleChildScrollView(
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
              textColor: _textColor,
              selectedTextColor: _selectedTextColor,
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
