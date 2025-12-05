import 'package:provider/provider.dart';

import '../mapping/plex_anibridge_service.dart';
import '../../models/sonarr/sonarr_release.dart';
import '../sonarr/sonarr_service.dart';
import '../../manager.dart';
import '../../models/anilist/anime.dart';
import '../library/library_provider.dart';

class DownloadController {
  final SonarrRepository _sonarr;
  final PlexAniBridgeService _mappingService;

  DownloadController(this._sonarr, this._mappingService);

  Future<(int, List<dynamic>)> syncAndFetchEpisodes(AnilistAnime anime) async {
    final mapping = await _mappingService.getMapping(anime.id);
    if (mapping == null) throw Exception("Mapping not found");

    final library = Provider.of<Library>(Manager.context, listen: false);
    
    // 1. Ensure Series Exists (Your existing logic)
    final sonarrSeriesId = await _sonarr.ensureSeriesExists(
      tvdbId: mapping.tvdbId,
      title: anime.title.romaji ?? "Unknown",
      rootFolderPath: library.libraryDockerPath!,
      qualityProfileId: 3, 
    );
    
    if (sonarrSeriesId == null) throw Exception("Failed to sync series");

    // 2. Fetch Episode Metadata (Not downloads yet, just the list)
    final episodes = await _sonarr.getEpisodes(sonarrSeriesId);
    
    return (sonarrSeriesId, episodes);
  }
}
