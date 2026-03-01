import 'package:provider/provider.dart';

import '../../settings.dart';
import '../mapping/plex_anibridge_service.dart';
import '../../models/sonarr/sonarr_episode.dart';
import '../../models/sonarr/sonarr_quality_profile.dart';
import '../sonarr/sonarr_service.dart';
import '../../manager.dart';
import '../../models/anilist/anime.dart';
import '../library/library_provider.dart';

class DownloadController {
  final SonarrRepository _sonarr;
  final PlexAniBridgeService _mappingService;

  DownloadController(this._sonarr, this._mappingService);

  /// Fetch available quality profiles from Sonarr API
  Future<List<SonarrQualityProfile>> getQualityProfiles() async => await _sonarr.getQualityProfiles();

  Future<(int, List<SonarrEpisode>)> syncAndFetchEpisodes(AnilistAnime anime) async {
    final library = Provider.of<Library>(Manager.context, listen: false);
    final settings = SettingsManager();

    final mapping = await _mappingService.getMapping(anime.id);
    if (mapping == null) throw Exception("Mapping not found");

    final qualityProfileId = settings.sonarrQualityProfileId;
    if (qualityProfileId == 0) {
      throw Exception("No quality profile selected! Configure one in Settings > Sonarr or select one in the Downloads screen");
    }

    final rootFolderPath = settings.sonarrRootFolderPath.isNotEmpty
        ? settings.sonarrRootFolderPath
        : library.libraryDockerPath!;

    // Ensure Series Exists
    final sonarrSeriesId = await _sonarr.ensureSeriesExists(
      tvdbId: mapping.tvdbId,
      title: anime.title.romaji ?? "Unknown",
      rootFolderPath: rootFolderPath,
      qualityProfileId: qualityProfileId,
    );

    if (sonarrSeriesId == null) throw Exception("Failed to sync series");

    // Fetch Episodes list
    final episodes = await _sonarr.getEpisodes(sonarrSeriesId);

    return (sonarrSeriesId, episodes);
  }
}
