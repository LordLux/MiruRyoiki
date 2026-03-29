import 'package:collection/collection.dart';
import 'package:provider/provider.dart';

import '../../models/knaben/knaben_release.dart';
import '../../settings.dart';
import '../../utils/logging.dart';
import '../knaben/knaben_service.dart';
import '../mapping/plex_anibridge_service.dart';
import '../mapping/custom_sonarr_mapping_service.dart';
import '../../models/sonarr/sonarr_episode.dart';
import '../../models/sonarr/sonarr_quality_profile.dart';
import '../sonarr/sonarr_service.dart';
import '../../manager.dart';
import '../library/library_provider.dart';
import 'torrent_client.dart';

class DownloadController {
  static final CustomSonarrMappingService _customMappingService = CustomSonarrMappingService();

  final SonarrRepository _sonarr;
  final PlexAniBridgeService _mappingService;
  final KnabenRepository _knaben;
  final TorrentClient _torrentClient;

  DownloadController(
    this._sonarr,
    this._mappingService,
    this._knaben,
    this._torrentClient,
  );

  KnabenRepository get knaben => _knaben;
  TorrentClient get torrentClient => _torrentClient;
  SonarrRepository get sonarr => _sonarr;
  CustomSonarrMappingService get customMappings => _customMappingService;

  /// Fetch available quality profiles from Sonarr API
  Future<List<SonarrQualityProfile>> getQualityProfiles() async => await _sonarr.getQualityProfiles();

  Future<(int, List<SonarrEpisode>)> syncAndFetchEpisodes({required int animeId, required String altTitle}) async {
    logDebug('[DownloadController] syncAndFetchEpisodes: animeId=$animeId, altTitle="$altTitle"');
    final library = Provider.of<Library>(Manager.context, listen: false);
    final settings = SettingsManager();

    int? tvdbId = await _customMappingService.getCustomTvdbId(animeId);

    if (tvdbId == null) {
      final mapping = await _mappingService.getMapping(animeId);
      if (mapping != null) tvdbId = mapping.tvdbId;
    }

    if (tvdbId == null || tvdbId == 0) {
      // Try matching by splitting on colon (common in anime subtitles)
      if (altTitle.contains(':')) {
        final splitTitle = altTitle.split(':').first.trim();
        try {
          final results = await _sonarr.lookupSeries(splitTitle);
          if (results.isNotEmpty) {
            tvdbId = results.first.tvdbId;
            await _customMappingService.saveCustomTvdbId(animeId, tvdbId);
          }
        } catch (_) {}
      }

      // Throw exception to indicate we failed to map, and should ask the user
      if (tvdbId == null || tvdbId == 0) throw Exception("Mapping not found");
    }

    final qualityProfileId = settings.sonarrQualityProfileId;
    if (qualityProfileId == 0) throw Exception("No quality profile selected! Configure one in Settings > Sonarr or select one in the Downloads screen");

    final rootFolderPath = settings.sonarrRootFolderPath.isNotEmpty //
        ? settings.sonarrRootFolderPath
        : library.libraryDockerPath!;

    final sonarrSeriesId = await _sonarr.ensureSeriesExists(
      tvdbId: tvdbId,
      title: altTitle,
      rootFolderPath: rootFolderPath,
      qualityProfileId: qualityProfileId,
    );

    if (sonarrSeriesId == null) throw Exception("Failed to sync series");

    logTrace('[DownloadController] Sonarr series synced: id=$sonarrSeriesId, tvdbId=$tvdbId');
    final episodes = await _sonarr.getEpisodes(sonarrSeriesId);
    logTrace('[DownloadController] Got ${episodes.length} episodes');

    return (sonarrSeriesId, episodes);
  }

  // Knaben search
  /// Search Knaben for an episode using multiple title variations to maximize matches
  /// Results are merged and deduplicated by magnet URL
  Future<List<KnabenRelease>> searchEpisode({
    required List<String> titles,
    required int season,
    required int episode,
    KnabenSearchMode? modeOverride,
  }) async {
    final settings = SettingsManager();
    final categories = settings.knabenUseAnimeCategories ? KnabenAnimeCategory.all : null;
    final mode = modeOverride ?? (settings.knabenLiveSearch ? KnabenSearchMode.live : KnabenSearchMode.fast);

    final allResults = <KnabenRelease>[];
    final seenMagnets = <String>{};

    for (final title in titles.toSet()) {
      if (title.trim().isEmpty) continue;
      try {
        final results = await _knaben.searchEpisode(title, season: season, episode: episode, categories: categories, mode: mode);
        for (final r in results) {
          if (!seenMagnets.contains(r.magnetUrl)) {
            seenMagnets.add(r.magnetUrl);
            allResults.add(r);
          }
        }
      } catch (e) {
        logDebug('Knaben episode search failed for title "$title": $e');
      }
    }

    // Sort combined results by seeders descending
    allResults.sort((a, b) => b.seeders.compareTo(a.seeders));
    return allResults;
  }

  /// Search Knaben for a season / batch pack using multiple title variations
  Future<List<KnabenRelease>> searchSeason({
    required List<String> titles,
    required int season,
    KnabenSearchMode? modeOverride,
  }) async {
    final settings = SettingsManager();
    final categories = settings.knabenUseAnimeCategories ? KnabenAnimeCategory.all : null;
    final mode = modeOverride ?? (settings.knabenLiveSearch ? KnabenSearchMode.live : KnabenSearchMode.fast);

    final allResults = <KnabenRelease>[];
    final seenMagnets = <String>{};

    for (final title in titles.toSet()) {
      if (title.trim().isEmpty) continue;
      try {
        final results = await _knaben.searchSeason(title, season: season, categories: categories, mode: mode);
        for (final r in results) {
          if (!seenMagnets.contains(r.magnetUrl)) {
            seenMagnets.add(r.magnetUrl);
            allResults.add(r);
          }
        }
      } catch (e) {
        logDebug('Knaben season search failed for title "$title": $e');
      }
    }

    // Sort combined results by seeders descending
    allResults.sort((a, b) => b.seeders.compareTo(a.seeders));
    return allResults;
  }

  /// Free-text Knaben search
  Future<List<KnabenRelease>> searchKnaben(String query, {KnabenSearchMode? modeOverride}) {
    final settings = SettingsManager();
    final categories = settings.knabenUseAnimeCategories ? KnabenAnimeCategory.all : null;
    final mode = modeOverride ?? (settings.knabenLiveSearch ? KnabenSearchMode.live : KnabenSearchMode.fast);

    return _knaben.search(query, categories: categories, mode: mode);
  }

  /// Send a magnet link to the configured torrent client for download
  ///
  /// When [savePath] is provided (the Sonarr root folder), the torrent downloads straight into the watched directory so Sonarr auto-imports it
  Future<bool> grabMagnet(String magnetUrl, {String? savePath}) async {
    return _torrentClient.addMagnet(magnetUrl, savePath: savePath, category: 'MiruRyoiki');
  }

  /// Converts a local Windows path to the path that Sonarr sees inside its
  /// Docker container, using the known library ↔ Sonarr root folder mapping.
  ///
  /// Example: library = "M:\Videos\Series", sonarrRoot = "/data/Videos/Series"
  ///   "M:\Videos\Series\Show\S01\ep.mkv" → "/data/Videos/Series/Show/S01/ep.mkv"
  String _toSonarrPath(String localPath) {
    final library = Provider.of<Library>(Manager.context, listen: false);
    final settings = SettingsManager();

    final localLibraryPath = library.libraryPath;
    final sonarrRoot = settings.sonarrRootFolderPath.isNotEmpty ? settings.sonarrRootFolderPath : library.libraryDockerPath;

    if (localLibraryPath != null && sonarrRoot != null) {
      final normalizedLocal = localPath.replaceAll('\\', '/').toLowerCase();
      final normalizedLibrary = localLibraryPath.replaceAll('\\', '/').toLowerCase();

      if (normalizedLocal.startsWith(normalizedLibrary)) {
        final relativePath = localPath.replaceAll('\\', '/').substring(localLibraryPath.length);
        final root = sonarrRoot.endsWith('/') ? sonarrRoot.substring(0, sonarrRoot.length - 1) : sonarrRoot;
        final rel = relativePath.startsWith('/') ? relativePath : '/$relativePath';
        logTrace('Path mapping: "$localPath" → "$root$rel"');
        return '$root$rel';
      }
    }

    logTrace('Path mapping fallback for: "$localPath" (library=$localLibraryPath, sonarrRoot=$sonarrRoot)');

    // Fallback: strip drive letter and prepend /data
    final linux = localPath.replaceAll('\\', '/');
    final noDrive = (linux.length > 2 && linux[1] == ':') ? linux.substring(2) : linux;
    return '/data$noDrive';
  }

  /// Ensures the Sonarr series path matches the actual local folder so that
  /// manual-import API calls can find the files.
  ///
  /// Call once before a batch of [manualImportFile] calls to avoid redundant
  /// API requests. Returns the (possibly updated) Sonarr series path.
  ///
  /// [localSeriesPath] is the local Windows path to the series folder
  /// (e.g. "M:\Videos\Series\Make Heroine ga Oosugiru!").
  Future<String> ensureSonarrSeriesPath(int sonarrSeriesId, String localSeriesPath) async {
    final expectedPath = _toSonarrPath(localSeriesPath);

    final seriesJson = await _sonarr.getSeriesById(sonarrSeriesId);
    final currentPath = (seriesJson['path'] as String?)?.replaceAll('\\', '/') ?? '';

    if (currentPath != expectedPath) {
      logDebug('Updating Sonarr series path: "$currentPath" → "$expectedPath"');
      seriesJson['path'] = expectedPath;
      await _sonarr.updateSeries(seriesJson);
    }

    return expectedPath;
  }

  /// Imports a local file into Sonarr, linking it to a specific episode.
  ///
  /// Uses the manual import workflow:
  /// 1. GET /manualimport to let Sonarr parse the file (quality, language, etc.)
  /// 2. POST /command ManualImport to actually import it
  ///
  /// **Important**: call [ensureSonarrSeriesPath] once before a batch of imports
  /// so Sonarr's series folder matches the real folder on disk.
  Future<void> manualImportFile({
    required String localFilePath,
    required int sonarrSeriesId,
    required int sonarrEpisodeId,
    required int seasonNumber,
  }) async {
    logTrace('[DownloadController] manualImportFile: "$localFilePath" → seriesId=$sonarrSeriesId, epId=$sonarrEpisodeId, S$seasonNumber');
    final sonarrFilePath = _toSonarrPath(localFilePath);
    final sonarrFolderPath = sonarrFilePath.substring(0, sonarrFilePath.lastIndexOf('/'));

    // Scan the folder without seriesId to avoid Sonarr 500 errors when its
    // episode file database has stale entries for files deleted from disk.
    final previews = await _sonarr.previewManualImport(
      folder: sonarrFolderPath,
      filterExistingFiles: false,
    );

    // Find our file in the preview results
    final match = previews.where((p) {
      final pPath = (p['path'] as String?)?.replaceAll('\\', '/') ?? '';
      return pPath == sonarrFilePath;
    }).firstOrNull;

    if (match == null) {
      throw Exception(
        'Sonarr could not find the file. Make sure Sonarr can access the path:\n'
        '$sonarrFilePath',
      );
    }

    // Build the import payload with our episode override
    final importFile = <String, dynamic>{
      'path': match['path'],
      'seriesId': sonarrSeriesId,
      'seasonNumber': seasonNumber,
      'episodeIds': [sonarrEpisodeId],
      if (match['quality'] != null) 'quality': match['quality'],
      if (match['languages'] != null) 'languages': match['languages'],
      if (match['releaseGroup'] != null) 'releaseGroup': match['releaseGroup'],
      if (match['indexerFlags'] != null) 'indexerFlags': match['indexerFlags'],
    };

    await _sonarr.manualImport(files: [importFile]);
  }

  /// Determine the save path that will land files inside Sonarr's root folder
  String? get sonarrSavePath {
    final settings = SettingsManager();
    if (settings.sonarrRootFolderPath.isNotEmpty) return settings.sonarrRootFolderPath;
    final library = Provider.of<Library>(Manager.context, listen: false);

    return library.libraryDockerPath;
  }
}
