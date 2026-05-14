import 'package:miruryoiki/utils/text.dart';

import '../../settings.dart';
import '../../utils/logging.dart';
import '../mapping/plex_anibridge_service.dart';
import '../qbittorrent/qbittorrent.dart';
import '../sonarr/sonarr_service.dart';
import '../knaben/knaben_service.dart';
import 'download_controller.dart';
import 'speed_graph_service.dart';
import 'torrent_client.dart';

class TorrentManager {
  static PlexAniBridgeService? plexBridge;
  static SonarrRepository? sonarrRepository;
  static KnabenRepository? knabenRepository;
  static TorrentClient? torrentClient;
  static DownloadController? downloadController;
  static SpeedGraphService? speedGraphService;

  /// Whether the download system is fully configured and operational
  static bool get isEnabled => downloadController != null;

  static void initialize() {
    final settings = SettingsManager();

    if (!settings.isDownloadsFullyConfigured) {
      logDebug('Downloads not fully configured (Sonarr: ${settings.isSonarrConfigured}, torrent client: ${settings.isTorrentClientConfigured}) — skipping initialization');
      return;
    }

    plexBridge = PlexAniBridgeService();
    knabenRepository = KnabenRepository();

    torrentClient = _createTorrentClient(settings);

    speedGraphService = SpeedGraphService(
      client: torrentClient!,
      updateFrequencySeconds: settings.graphUpdateFrequencySeconds,
      timeframeMinutes: settings.graphTimeframeMinutes,
    );

    final baseUrl = settings.sonarrBaseUrl.fallbackIfEmpty(SonarrRepository.defaultUrlPort);
    sonarrRepository = SonarrRepository(
      baseUrl: baseUrl,
      apiKey: settings.sonarrApiKey,
    );

    downloadController = DownloadController(
      sonarrRepository!,
      plexBridge!,
      knabenRepository!,
      torrentClient!,
    );
  }

  /// Create the appropriate torrent client based on settings
  ///
  /// Currently only qBittorrent is supported. Future clients (Deluge,
  /// Transmission, etc.) would be added here as additional branches.
  static TorrentClient _createTorrentClient(SettingsManager settings) {
    // For now, qBittorrent is the only supported client
    return QBittorrentRepository(
      baseUrl: settings.qbitBaseUrl,
      username: settings.qbitUsername,
      password: settings.qbitPassword,
    );
  }

  /// Re-create all clients after settings change
  static void reinitialize() {
    speedGraphService?.dispose();
    speedGraphService = null;
    sonarrRepository = null;
    knabenRepository = null;
    torrentClient = null;
    downloadController = null;
    plexBridge = null;
    initialize();
  }
}
