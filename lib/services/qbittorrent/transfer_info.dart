class TransferInfo {
  final int downloadSpeed;
  final int uploadSpeed;
  final int sessionDownload;
  final int sessionUpload;
  final String connectionStatus;
  final int dhtNodes;
  // Detailed breakdown — populated only if the running qBittorrent build exposes them
  final int? payloadDownloadSpeed;
  final int? payloadUploadSpeed;
  final int? overheadDownloadSpeed;
  final int? overheadUploadSpeed;
  final int? dhtDownloadSpeed;
  final int? dhtUploadSpeed;
  final int? trackerDownloadSpeed;
  final int? trackerUploadSpeed;

  const TransferInfo({
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.sessionDownload,
    required this.sessionUpload,
    required this.connectionStatus,
    required this.dhtNodes,
    this.payloadDownloadSpeed,
    this.payloadUploadSpeed,
    this.overheadDownloadSpeed,
    this.overheadUploadSpeed,
    this.dhtDownloadSpeed,
    this.dhtUploadSpeed,
    this.trackerDownloadSpeed,
    this.trackerUploadSpeed,
  });

  factory TransferInfo.fromJson(Map<String, dynamic> j) {
    return TransferInfo(
      downloadSpeed: (j['dl_info_speed'] as num?)?.toInt() ?? 0,
      uploadSpeed: (j['up_info_speed'] as num?)?.toInt() ?? 0,
      sessionDownload: (j['dl_info_data'] as num?)?.toInt() ?? 0,
      sessionUpload: (j['up_info_data'] as num?)?.toInt() ?? 0,
      connectionStatus: j['connection_status'] as String? ?? 'unknown',
      dhtNodes: (j['dht_nodes'] as num?)?.toInt() ?? 0,
      payloadDownloadSpeed: _optInt(j, 'payload_dl_speed') ?? _optInt(j, 'payload_download_speed'),
      payloadUploadSpeed: _optInt(j, 'payload_ul_speed') ?? _optInt(j, 'payload_upload_speed'),
      overheadDownloadSpeed: _optInt(j, 'overhead_dl_speed') ?? _optInt(j, 'overhead_download_speed'),
      overheadUploadSpeed: _optInt(j, 'overhead_ul_speed') ?? _optInt(j, 'overhead_upload_speed'),
      dhtDownloadSpeed: _optInt(j, 'dht_dl_speed') ?? _optInt(j, 'dht_download_speed'),
      dhtUploadSpeed: _optInt(j, 'dht_ul_speed') ?? _optInt(j, 'dht_upload_speed'),
      trackerDownloadSpeed: _optInt(j, 'tracker_dl_speed') ?? _optInt(j, 'tracker_download_speed'),
      trackerUploadSpeed: _optInt(j, 'tracker_ul_speed') ?? _optInt(j, 'tracker_upload_speed'),
    );
  }

  static int? _optInt(Map<String, dynamic> j, String key) {
    final v = j[key];
    if (v == null) return null;
    return (v as num).toInt();
  }
}
