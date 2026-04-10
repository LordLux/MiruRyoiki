import 'dart:typed_data';

/// Abstract interface for torrent clients (qBittorrent, Deluge, Transmission, etc.)
///
/// Implementations handle authentication and client-specific API details internally.
/// The download system only interacts through this contract, making it easy to
/// swap or add torrent clients without touching business logic.
abstract class TorrentClient {
  /// Human-readable name of this client (e.g. "qBittorrent", "Deluge")
  String get clientName;

  /// Add a magnet link for download
  ///
  /// [savePath] overrides the default save location when provided
  /// [category] is an optional label for organisation
  /// Returns `true` if the client accepted the torrent
  Future<bool> addMagnet(
    String magnetUrl, {
    String? savePath,
    String? category,
  });

  /// Retrieve a list of current torrents as [TorrentInfo] objects
  ///
  /// [filter] narrows results (e.g. "downloading", "completed") when supported.
  Future<List<TorrentInfo>> listTorrents({String? filter});

  /// Pause a torrent by its hash
  Future<bool> pauseTorrent(String hash);

  /// Resume a torrent by its hash
  Future<bool> resumeTorrent(String hash);

  /// Delete a torrent by its hash
  ///
  /// When [deleteFiles] is true, the downloaded data is also removed from disk.
  Future<bool> deleteTorrent(String hash, {bool deleteFiles = false});

  /// Toggle force-start on a torrent (bypass queue limits)
  Future<bool> forceStartTorrent(String hash, {bool value = true});

  /// Move the torrent's downloaded data to a new location
  Future<bool> setLocation(String hash, String newLocation);

  /// Rename the torrent (display name only — does not rename files on disk)
  Future<bool> renameTorrent(String hash, String newName);

  /// Move the torrent within the queue
  Future<bool> moveQueue(String hash, QueueDirection direction);

  /// Fetch the user-facing comment field associated with a torrent
  Future<String?> getComment(String hash);

  /// Export the `.torrent` file as raw bytes for the given hash
  Future<Uint8List?> exportTorrent(String hash);

  /// Quick health-check — returns `true` if the client is reachable and authenticated
  Future<bool> testConnection();
}

enum QueueDirection { top, up, down, bottom }

/// Normalized torrent info that all client implementations must produce
class TorrentInfo {
  final String hash;
  final String name;
  final TorrentState state;
  final double progress; // 0.0 – 1.0
  final int size; // total bytes
  final int downloaded; // bytes downloaded so far
  final int uploaded; // bytes uploaded so far
  final int downloadSpeed; // bytes/s
  final int uploadSpeed; // bytes/s
  final int seeders;
  final int leechers;
  final String? eta; // human-readable ETA or null
  final String? savePath;
  final String? category;
  final DateTime? addedOn;
  final String? magnetUri;

  const TorrentInfo({
    required this.hash,
    required this.name,
    required this.state,
    required this.progress,
    required this.size,
    this.downloaded = 0,
    this.uploaded = 0,
    this.downloadSpeed = 0,
    this.uploadSpeed = 0,
    this.seeders = 0,
    this.leechers = 0,
    this.eta,
    this.savePath,
    this.category,
    this.addedOn,
    this.magnetUri,
  });
}

enum TorrentState {
  downloading,
  seeding,
  paused,
  queued,
  checking,
  stalled,
  completed,
  error,
  unknown,
}
