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

    final episodes = await _sonarr.getEpisodes(sonarrSeriesId);

    return (sonarrSeriesId, episodes);
  }

  // Knaben search
  /// Search Knaben for an episode using multiple title variations to maximize matches
  /// Results are merged and deduplicated by magnet URL
  Future<List<KnabenRelease>> searchEpisode({
    required List<String> titles,
    required int season,
    required int episode,
  }) async {
    final settings = SettingsManager();
    final categories = settings.knabenUseAnimeCategories ? KnabenAnimeCategory.all : null;
    final mode = settings.knabenLiveSearch ? KnabenSearchMode.live : KnabenSearchMode.fast;

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
  }) async {
    final settings = SettingsManager();
    final categories = settings.knabenUseAnimeCategories ? KnabenAnimeCategory.all : null;
    final mode = settings.knabenLiveSearch ? KnabenSearchMode.live : KnabenSearchMode.fast;

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
  Future<List<KnabenRelease>> searchKnaben(String query) {
    final settings = SettingsManager();
    final categories = settings.knabenUseAnimeCategories ? KnabenAnimeCategory.all : null;
    final mode = settings.knabenLiveSearch ? KnabenSearchMode.live : KnabenSearchMode.fast;

    return _knaben.search(query, categories: categories, mode: mode);
  }

  /// Send a magnet link to the configured torrent client for download
  ///
  /// When [savePath] is provided (the Sonarr root folder), the torrent downloads straight into the watched directory so Sonarr auto-imports it
  Future<bool> grabMagnet(String magnetUrl, {String? savePath}) async {
    return _torrentClient.addMagnet(magnetUrl, savePath: savePath);
  }

  /// Determine the save path that will land files inside Sonarr's root folder
  String? get sonarrSavePath {
    final settings = SettingsManager();
    if (settings.sonarrRootFolderPath.isNotEmpty) return settings.sonarrRootFolderPath;
    final library = Provider.of<Library>(Manager.context, listen: false);

    return library.libraryDockerPath;
  }
}
