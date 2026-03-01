import 'package:miruryoiki/utils/text.dart';

import '../../settings.dart';
import '../mapping/plex_anibridge_service.dart';
import '../sonarr/sonarr_service.dart';
import 'download_controller.dart';

class TorrentManager {
  static PlexAniBridgeService? plexBridge;
  static SonarrRepository? sonarrRepository;
  static DownloadController? downloadController;
  
  static void initialize() {
    plexBridge = PlexAniBridgeService();

    final settings = SettingsManager();
    if (!settings.isSonarrConfigured) return; // Not configured yet

    final baseUrl = settings.sonarrBaseUrl.fallbackIfEmpty(SonarrRepository.defaultUrlPort);

    sonarrRepository = SonarrRepository(
      baseUrl: baseUrl,
      apiKey: settings.sonarrApiKey,
    );

    downloadController = DownloadController(sonarrRepository!, plexBridge!);
  }

  /// Re-create the Sonarr client after settings change
  static void reinitialize() {
    sonarrRepository = null;
    downloadController = null;
    initialize();
  }
}
