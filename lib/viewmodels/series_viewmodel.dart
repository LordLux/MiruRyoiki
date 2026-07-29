import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart' as p;

import '../enums.dart';
import '../manager.dart';
import '../models/anilist/anime.dart';
import '../models/anilist/mapping.dart';
import '../models/episode.dart';
import '../models/folder_node.dart';
import '../models/mapping_target.dart';
import '../models/season.dart';
import '../models/series.dart';
import '../models/sonarr/sonarr_episode.dart';
import '../models/ui_episode.dart';
import '../services/anilist/linking.dart';
import '../services/connectivity/connectivity_service.dart';
import '../services/downloads/torrent_manager.dart';
import '../services/file_system/cache.dart';
import '../services/library/library_provider.dart';
import '../utils/error_handling.dart';
import '../utils/logging.dart';
import '../utils/path.dart';
import '../utils/time.dart';
import 'disposable_view_model.dart';
import 'library_screen_viewmodel.dart';

/// ViewModel for the Series detail screen.
///
/// Owns the screen's *state* (Sonarr episodes, view type, folder-tree resolution, merged-episode memoization) and all
/// *data access / orchestration* (AniList fetch + persistence, primary-ID changes, Sonarr sync, episode playback, mapping-data init).
/// The screen ([SeriesScreen]) keeps only view concerns (scroll, hover, animations, widget building, dialog launching).
///
/// Registered app-wide via
/// `ChangeNotifierProxyProvider2<Library, LibraryScreenViewModel, SeriesViewModel>` in `main.dart`.
///
/// Navigation model: the [SeriesScreen] is a single persistent widget.
/// Drilling into a folder/mapping is *intra-page* and is modelled here as a [nodeStack], so exactly one screen
/// instance maps to this one VM, with no coexisting instances to clobber each other. See [pushNode]/[popNode].
class SeriesViewModel extends DisposableViewModel {
  SeriesViewModel({SeriesLinkService? linkService}) : _linkServiceOverride = linkService;

  final SeriesLinkService? _linkServiceOverride;

  /// Resolved lazily so pure-logic unit tests never construct network services.
  SeriesLinkService get _linkService => _linkServiceOverride ?? SeriesLinkService();

  Library? _library;
  LibraryScreenViewModel? _libraryVM;

  /// Called by the ChangeNotifierProxyProvider whenever a dependency notifies.
  /// Only swaps references (never notifies — it runs during build).
  void update(Library library, LibraryScreenViewModel libraryVM) {
    _library = library;
    _libraryVM = libraryVM;
  }

  // Location
  PathString? _seriesPath;
  final List<PathString> _nodeStack = [];

  /// The path to the series currently being shown, or null if no series is open
  PathString? get seriesPath => _seriesPath;

  /// The node path currently rendered, or null for the series root
  PathString? get currentNodePath => _nodeStack.isEmpty ? null : _nodeStack.last;

  /// Whether there is a drill-down level to pop before leaving the series
  bool get canPopNode => _nodeStack.isNotEmpty;

  /// Whether the current view is the series root
  bool get isAtRoot => _nodeStack.isEmpty;

  /// The current drill-down stack for persisting to history
  List<PathString> get nodeStack => List.unmodifiable(_nodeStack);

  /// The live series for the current [seriesPath], read from the library on demand
  ///
  /// Also cached as [_cachedSeries] so async methods keep a stable ref
  Series? _cachedSeries;
  Series? get cachedSeries => _cachedSeries;

  /// Show a series at the given root, optionally restoring a saved drill-down stack on page re-entry
  ///
  /// Clears all per-series/per-node derived state so nothing bleeds from a previously opened series
  void openSeries(PathString? seriesPath, {List<PathString>? initialStack}) {
    _seriesPath = seriesPath;
    _nodeStack
      ..clear()
      ..addAll(initialStack ?? const []);
    _lastFileMapSeries = null;
    _lastFileMapNodePath = null;
    _lastFileMapMappingCount = -1;
    _resetNodeScopedState();
  }

  /// Release everything held for the current series.
  ///
  /// [forPath] is the series the caller opened; a mismatch means a newer screen has already taken over, so the close is ignored.
  void close(PathString? forPath) {
    if (_seriesPath != forPath) return;

    _seriesPath = null;
    _nodeStack.clear();
    _cachedSeries = null;
    _treeRoot = null;
    _treeSeries = null;
    _treeKey = null;
    _fileMappingsAtNode = const [];
    _fileMappingPaths = const {};
    _lastFileMapSeries = null;
    _lastFileMapNodePath = null;
    _lastFileMapMappingCount = -1;
    _resetNodeScopedState();
  }

  /// Drill into a child folder/mapping node
  void pushNode(PathString nodePath) {
    _nodeStack.add(nodePath);
    _onNodeChanged();
  }

  /// Pop one drill-down level. Returns false if already at the root.
  bool popNode() {
    if (_nodeStack.isEmpty) return false;
    _nodeStack.removeLast();
    _onNodeChanged();
    return true;
  }

  /// Restore the drill-down stack from navigation history (back/forward or page re-entry)
  void restoreNodeStack(List<PathString> stack) {
    if (const ListEquality<PathString>().equals(_nodeStack, stack)) return;
    _nodeStack
      ..clear()
      ..addAll(stack);
    _onNodeChanged();
  }

  void _onNodeChanged() {
    _resetNodeScopedState();
    notifySafe();
    // The root-re-entry color reset lives in the screen (SeriesScreenState._applySeriesColorIfAtRoot),
    // not here: it needs Manager.setState, whose Flutter bindings the VM stays free of for testability.
  }

  /// Drop everything scoped to a single folder/mapping node.
  ///
  /// Drilling in/out is intra-page, so whatever the previous node loaded has to be dropped here or it bleeds into the next one.
  void _resetNodeScopedState() {
    _nodeInitialized = false;
    _resolvedNode = null;
    _currentViewType = null;
    _sonarrEpisodes = null;
    _sonarrSeriesId = null;
    _lastResolvedTree = null; // Force a re-resolve
    _lastResolvedNodePath = null;
    _invalidateMergedEpisodes();
  }

  /// Keep the cached series reference aligned with the reactive value the screen reads from `Library` in `build`
  void syncSeries(Series? series) => _cachedSeries = series;

  /// True while the VM is still showing this exact series + node.
  /// Async data methods snapshot the location before awaiting and bail via this afterwards,
  /// so a series/node the user navigated away from can't clobber current state.
  bool _stillOn(PathString? seriesPath, PathString? nodePath) => //
      !isDisposed && _seriesPath == seriesPath && currentNodePath == nodePath;

  // Folder-tree resolution + node
  /// The folder node currently resolved for the series + node path, or null if the node no longer exists
  FolderNode? get resolvedNode => _resolvedNode;
  FolderNode? _resolvedNode;

  /// Whether the one-time node data load (view type, episode titles, Sonarr) has been run for this node
  @visibleForTesting
  bool get nodeInitialized => _nodeInitialized;
  bool _nodeInitialized = false;

  /// Marks the one-time node data load as done and reports whether it still needed running
  bool consumeNodeInit() {
    if (_nodeInitialized) return false;
    _nodeInitialized = true;
    return true;
  }

  /// The AniList mapping (if any) attached to the current node
  AnilistMapping? get cachedMapping => _resolvedNode?.mapping;

  /// A [MappingTarget] for the current node's collection,
  /// or null for the root / intermediate folders that have no collection of their own.
  MappingTarget? get cachedTarget {
    final c = _resolvedNode?.collection;
    return c != null ? MappingTarget.collection(c) : null;
  }

  /// Whether the current node is a mapping-mode folder
  bool get isMappingMode => !(_resolvedNode?.isRoot ?? true);

  // Memoized folder tree that gets rebuilt only when the series instance, its data version, or its mapping count changes
  FolderNode? _treeRoot;
  Series? _treeSeries;
  ({int version, int mappingCount})? _treeKey;

  // Builds the folder tree for [series] and caches it
  FolderNode _buildOrGetTree(Series series, int dataVersion) {
    final key = (version: dataVersion, mappingCount: series.anilistMappings.length);
    if (_treeRoot != null && identical(_treeSeries, series) && _treeKey == key) return _treeRoot!;

    _treeRoot = buildFolderTree(series);
    _treeSeries = series;
    _treeKey = key;
    return _treeRoot!;
  }

  // Cache so hover/color rebuilds (same tree instance + same node path) skip the tree walk.
  //The tree itself is memoized in [_buildOrGetTree].
  FolderNode? _lastResolvedTree;
  PathString? _lastResolvedNodePath;

  /// Resolve (and cache) the folder node to render for [series], walking a memoized tree so hover/color rebuilds don't reconstruct it.
  ///
  /// Returns null when the node path no longer exists in the tree.
  FolderNode? resolveNode(Series series) {
    final tree = _buildOrGetTree(series, _library?.dataVersion ?? -1);
    final nodePath = currentNodePath ?? series.path;
    if (identical(tree, _lastResolvedTree) && _lastResolvedNodePath == nodePath) return _resolvedNode;

    _resolvedNode = findNodeInTree(tree, nodePath);
    _lastResolvedTree = tree;
    _lastResolvedNodePath = nodePath;
    return _resolvedNode;
  }

  // File-level (single-file) AniList mappings at the current node
  List<(AnilistMapping, MappingTarget)> _fileMappingsAtNode = const [];
  Set<String> _fileMappingPaths = const {};

  /// The file-level AniList mappings located directly inside the current node, which render as their own cards and are excluded from the episode grid
  List<(AnilistMapping, MappingTarget)> get fileMappingsAtNode => _fileMappingsAtNode;

  // Cache so rebuilds that don't change the series, node, or mapping count skip the O(mappings) rescan
  Series? _lastFileMapSeries;
  String? _lastFileMapNodePath;
  int _lastFileMapMappingCount = -1;

  /// Recompute the file-level mappings located directly inside [node]
  ///
  /// They render as their own cards and are excluded from the episode grid
  void recomputeFileMappings(Series series, FolderNode node) {
    if (identical(series, _lastFileMapSeries) && //
        _lastFileMapNodePath == node.path.path &&
        _lastFileMapMappingCount == series.anilistMappings.length) return;

    _lastFileMapSeries = series;
    _lastFileMapNodePath = node.path.path;
    _lastFileMapMappingCount = series.anilistMappings.length;

    final list = <(AnilistMapping, MappingTarget)>[];
    final paths = <String>{};
    for (final m in series.anilistMappings) {
      final lp = m.localPath.pathMaybe;
      if (lp == null) continue; // skip mappings that don't point to a file

      final t = series.getTargetForMapping(m);
      // Only include file-level mappings that are direct children of this node
      if (t != null && t.isEpisode && p.equals(p.dirname(lp), node.path.path)) {
        list.add((m, t));
        paths.add(lp);
      }
    }
    _fileMappingsAtNode = list;
    _fileMappingPaths = paths;
  }

  /// Episodes shown in the current node's grid: the node's direct episodes minus any that are themselves file-level AniList mappings
  List<Episode> get gridEpisodes {
    final node = _resolvedNode;
    if (node == null) return const [];
    if (_fileMappingPaths.isEmpty) return node.directEpisodes;
    return node.directEpisodes.where((e) => !_fileMappingPaths.contains(e.path.pathMaybe)).toList();
  }

  // Sonarr episodes
  List<SonarrEpisode>? _sonarrEpisodes;
  int? _sonarrSeriesId;

  /// The list of Sonarr episodes fetched for the current series, or null if Sonarr is disabled or not yet fetched
  List<SonarrEpisode>? get sonarrEpisodes => _sonarrEpisodes;

  /// The Sonarr series ID for the current series, or null if Sonarr is disabled or not yet fetched
  int? get sonarrSeriesId => _sonarrSeriesId;

  /// Test-only: seed the fetched Sonarr episodes, bypassing the network sync
  @visibleForTesting
  void debugSetSonarrEpisodes(List<SonarrEpisode>? episodes) {
    _sonarrEpisodes = episodes;
    _invalidateMergedEpisodes();
  }

  /// Sonarr episodes filtered to the current target season only.
  ///
  /// Returns null for EpisodeTargets as single-episode mappings don't use Sonarr.
  List<SonarrEpisode>? get sonarrEpisodesForTarget {
    if (_sonarrEpisodes == null) return null;
    final target = cachedTarget;
    if (target == null || target.isEpisode) return null;

    final seasonNum = (target.asCollection is Season) ? (target.asCollection as Season).seasonNumber : null;
    if (seasonNum == null) return _sonarrEpisodes;

    return _sonarrEpisodes!.where((e) => e.seasonNumber == seasonNum).toList();
  }

  /// Fetch Sonarr episodes for the current series, if Sonarr is enabled and the series has an AniList mapping
  Future<void> fetchSonarrEpisodes() async {
    final torrentController = TorrentManager.downloadController;
    if (torrentController == null) return;

    final anilistId = cachedMapping?.anilistId ?? _cachedSeries?.primaryAnilistId;
    if (anilistId == null) return;

    final titleObj = cachedMapping?.anilistData?.title ?? _cachedSeries?.anilistData?.title;
    final fallbackTitle = titleObj?.userPreferred ?? titleObj?.english ?? titleObj?.romaji ?? "";

    // Snapshot the location: these results are node-scoped,
    // so a navigation away mid-await must not overwrite the new node's state
    final seriesPath = _seriesPath;
    final nodePath = currentNodePath;

    logTrace('[SeriesViewModel] Fetching Sonarr episodes: anilistId=$anilistId, title="$fallbackTitle"');

    try {
      var result = await torrentController.syncAndFetchEpisodes(animeId: anilistId, altTitle: fallbackTitle);
      if (!_stillOn(seriesPath, nodePath)) return;

      // If Sonarr just added the series, episodes may not be available yet — retry once
      if (result.$2.isEmpty) {
        logTrace('[SeriesViewModel] No episodes returned, retrying after 3s...');
        await Future.delayed(const Duration(seconds: 3));
        if (!_stillOn(seriesPath, nodePath)) return;
        result = await torrentController.syncAndFetchEpisodes(animeId: anilistId, altTitle: fallbackTitle);
        if (!_stillOn(seriesPath, nodePath)) return;
      }

      logTrace('[SeriesViewModel] Got sonarrSeriesId=${result.$1}, ${result.$2.length} episodes');
      _sonarrSeriesId = result.$1;
      _sonarrEpisodes = result.$2;
      _invalidateMergedEpisodes();
      notifySafe();
    } catch (e, stack) {
      logErr('[SeriesViewModel] Failed to fetch sonarr episodes', e, stack);
    }
  }

  // Merged (local + Sonarr) episodes
  List<UIEpisode>? _cachedMergedEpisodes;
  ({String? nodePath, int localCount, int sonarrCount})? _lastMergeKey;

  void _invalidateMergedEpisodes() => _cachedMergedEpisodes = null;

  // Sonarr episodes are season-scoped, so only merge them inside a folder/season node, and never into the series root's loose-files grid
  List<UIEpisode> get mergedEpisodes {
    final localEps = gridEpisodes;
    final sonarrEps = isMappingMode ? sonarrEpisodesForTarget : null;
    final key = (nodePath: _resolvedNode?.path.pathMaybe, localCount: localEps.length, sonarrCount: sonarrEps?.length ?? -1);

    if (_cachedMergedEpisodes != null && _lastMergeKey == key) return _cachedMergedEpisodes!;

    _lastMergeKey = key;
    _cachedMergedEpisodes = UIEpisode.merge(localEps, sonarrEps);
    return _cachedMergedEpisodes!;
  }

  // View type
  /// The view type (grid or list) for the current node: the user's choice for this node if they made
  /// one, otherwise the node mapping's persisted type, otherwise grid.
  ///
  /// Resolved on read rather than latched on node change, so each node picks up its own persisted
  /// type as soon as it resolves, so with a single latched field, the first node's type stuck to every
  /// node visited afterwards.
  ViewType get currentViewType => _currentViewType ?? _resolvedNode?.mapping?.viewType ?? ViewType.grid;

  /// The user's explicit choice for the current node, or null while the node's persisted type applies
  ViewType? _currentViewType;

  /// Set the current view type (grid or list) for the current node, and persist it to the library if it's a mapping node
  void onViewTypeChanged(ViewType newViewType) {
    _currentViewType = newViewType;
    notifySafe();

    final mapping = _resolvedNode?.mapping;
    if (mapping != null) _library?.updateMappingViewType(mapping.anilistId, newViewType);
  }

  // One-time, node-dependent data loads

  /// Kicks off per-node data loads once the node has been resolved. Fetches:
  /// - Episode Titles
  /// - Sonarr
  ///
  /// Scheduled once per node by the screen.
  Future<void> initNodeData() async {
    if (isMappingMode)
      await initializeMappingData();
    else if (TorrentManager.isEnabled) //
      await fetchSonarrEpisodes();
  }

  /// Initialize mapping data: dominant color, AniList episode titles, Sonarr
  Future<void> initializeMappingData() async {
    final mapping = cachedMapping;
    if (mapping == null) return;

    // Snapshot the location, so a navigation away mid-await can't apply this mapping's
    // color/titles/episodes to whatever series/node is now showing.
    final seriesPath = _seriesPath;
    final nodePath = currentNodePath;

    // Calculate dominant color from the mapping's anilistData
    final dominantColor = await mapping.effectivePrimaryColor(forceRecalculate: false);
    if (!_stillOn(seriesPath, nodePath)) return;

    Manager.setState(() => Manager.currentDominantColor = dominantColor);

    // Fetch episode titles from AniList
    try {
      final (newSeries, episodeTitlesUpdated) = await Manager.episodeTitleService.fetchAndUpdateEpisodeTitlesFromMapping(mapping);
      if (newSeries != null) _libraryVM?.updateSeriesInSortCache(newSeries);
      if (!_stillOn(seriesPath, nodePath)) return;
      if (episodeTitlesUpdated) {
        logTrace('Episode titles updated, refreshing UI');
        notifySafe(); // Refresh UI to show updated episode titles
      }
    } catch (e) {
      logErr('Error fetching episode titles', e);
    }

    await fetchSonarrEpisodes();
  }

  // Episode playback
  /// Play the given episode
  void playEpisode(Episode episode) => _library?.playEpisode(episode);

  // Mapping images
  /// Fetch the mapping's AniList banner or poster image, if any, and return an ImageProvider for it
  Future<ImageProvider?> getMappingImage({required bool banner}) async {
    final mapping = cachedMapping;
    if (mapping == null) return null;

    final imageUrl = banner ? mapping.anilistData?.bannerImage : mapping.anilistData?.posterImage;
    if (imageUrl == null || imageUrl.isEmpty) return null;

    return await ImageCacheService().getImageProvider(imageUrl);
  }

  // AniList data loading / persistence
  /// The AniList IDs of the current series' mappings, for fetching their data
  List<int> get anilistIDs => _cachedSeries?.anilistMappings.map((e) => e.anilistId).whereType<int>().toSet().toList() ?? [];

  /// Refresh AniList data for the current series (loads all of its mappings)
  Future<void> loadAnilistDataForCurrentSeries() async {
    final series = _cachedSeries;
    if (_seriesPath == null || series == null) return;

    if (!series.isLinked) {
      // Unlinked: drop stale AniList data. Only notify when it actually changed,
      // else repeated calls loop: notify -> rebuild -> didChangeDependencies -> notify.
      if (series.anilistData != null) {
        series.anilistData = null;
        notifySafe();
      }
      return;
    }

    await loadAnilistData(anilistIDs);
  }

  /// Force reload for the given IDs
  Future<void> loadAnilistDataForced(List<int> ids) async => loadAnilistData(ids, force: true);

  /// Change the primary AniList ID for the current series
  ///
  /// (Assumes the anilistData of the mapping is already loaded)
  Future<void> changePrimaryId(int id) async {
    final series = _cachedSeries;
    final library = _library;
    if (series == null || library == null) return;
    final loadingForPath = _seriesPath;

    final mapping = series.anilistMappings.firstWhere(
      (m) => m.anilistId == id,
      orElse: () => series.anilistMappings.first, // fallback, shouldn't happen
    );

    series.primaryAnilistId = mapping.anilistId;
    series.anilistData = mapping.anilistData;
    final newColor = mapping.effectivePrimaryColorSync();
    Manager.currentDominantColor = newColor;
    Manager.seriesDominantColor = newColor;
    notifySafe();

    try {
      // Update the series mappings with the new primary ID
      await library.updateSeriesMappings(series, series.anilistMappings);
      // Also update the series
      await library.updateSeries(series, invalidateCache: false);

      // Skip the UI-side refresh if the user navigated away
      // (the DB writes above already targeted the correct series and stay valid)
      if (isDisposed || _seriesPath != loadingForPath) return;
      _libraryVM?.updateSeriesInSortCache(series);

      logTrace('Changed primary AniList ID to $id, saved to library');
    } catch (e) {
      logErr('Error updating series primary AniList ID: $e');
    }
  }

  /// Load AniList data for the given IDs, skipping any that are already cached and fresh
  Future<void> loadAnilistData(List<int> anilistIDs, {bool force = false}) async {
    final series = _cachedSeries;
    final library = _library;
    if (series == null || library == null) return;

    // Guard against navigating to a different series mid-flight:
    // after the network await we bail if we've left, restoring the pre-VM screen's `mounted` check
    final loadingForPath = _seriesPath;

    // The single mapping that drives series-level image/color updates.
    // With no explicit primary, use the first mapping rather than treating every mapping as primary,
    // which recomputed the (per-series) color once per fetched mapping.
    final effectivePrimaryId = series.primaryAnilistId ?? series.anilistMappings.firstOrNull?.anilistId;

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
      final Map<int, AnilistAnime?> fetchedData = await _linkService.fetchMultipleAnimeDetails(idsToFetch);
      if (isDisposed || _seriesPath != loadingForPath) return;

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
        final bool isPrimary = anilistId == effectivePrimaryId;

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

            // Only push the color to the global UI if we're still on this series
            if (_seriesPath == loadingForPath && !isDisposed) {
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

      _libraryVM?.updateSeriesInSortCache(series);
      if (isDisposed || _seriesPath != loadingForPath) return;
      if (dominantColorChanged) Manager.setState();
      notifySafe();
    } catch (e) {
      if (!isExpectedOfflineError(e)) logErr('Failed to load Anilist data', e);
    }
  }

  // Library reload hook

  /// Called after a library reload. The folder node is re-derived from the live series in the screen's `build`,
  /// so this just refreshes the cached series + its AniList data and triggers a rebuild.
  void refreshFromLibrary() {
    final library = _library;
    if (library == null || _seriesPath == null) return;

    final series = library.getSeriesByPath(_seriesPath!);
    if (series == null) return;

    _cachedSeries = series;
    _invalidateMergedEpisodes();

    loadAnilistDataForCurrentSeries();
    notifySafe();
  }
}
