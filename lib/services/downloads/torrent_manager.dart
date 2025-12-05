import '../mapping/plex_anibridge_service.dart';
import '../sonarr/sonarr_service.dart';
import 'download_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TorrentManager {
  static PlexAniBridgeService? plexBridge;
  static SonarrRepository? sonarrRepository;
  static DownloadController? downloadController;
  
  static void initialize() {
    plexBridge = PlexAniBridgeService();

    sonarrRepository = SonarrRepository(
      baseUrl: 'http://localhost:8989', // TODO load from user preferences
      apiKey: dotenv.env['SONARR_API_KEY']!,
    );

    downloadController = DownloadController(sonarrRepository!, plexBridge!);
  }
}
