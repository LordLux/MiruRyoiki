import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'torrent_client.dart';

enum SpeedMetric {
  totalDownload,
  totalUpload,
  payloadDownload,
  payloadUpload,
  overheadDownload,
  overheadUpload,
  dhtDownload,
  dhtUpload,
  trackerDownload,
  trackerUpload;

  String get label => switch (this) {
        SpeedMetric.totalDownload => 'Total Download',
        SpeedMetric.totalUpload => 'Total Upload',
        SpeedMetric.payloadDownload => 'Payload Download',
        SpeedMetric.payloadUpload => 'Payload Upload',
        SpeedMetric.overheadDownload => 'Overhead Download',
        SpeedMetric.overheadUpload => 'Overhead Upload',
        SpeedMetric.dhtDownload => 'DHT Download',
        SpeedMetric.dhtUpload => 'DHT Upload',
        SpeedMetric.trackerDownload => 'Tracker Download',
        SpeedMetric.trackerUpload => 'Tracker Upload',
      };
}

class SpeedDataPoint {
  final DateTime timestamp;
  final int totalDownload;
  final int totalUpload;
  final int? payloadDownload;
  final int? payloadUpload;
  final int? overheadDownload;
  final int? overheadUpload;
  final int? dhtDownload;
  final int? dhtUpload;
  final int? trackerDownload;
  final int? trackerUpload;

  const SpeedDataPoint({
    required this.timestamp,
    required this.totalDownload,
    required this.totalUpload,
    this.payloadDownload,
    this.payloadUpload,
    this.overheadDownload,
    this.overheadUpload,
    this.dhtDownload,
    this.dhtUpload,
    this.trackerDownload,
    this.trackerUpload,
  });

  int? valueFor(SpeedMetric metric) => switch (metric) {
        SpeedMetric.totalDownload => totalDownload,
        SpeedMetric.totalUpload => totalUpload,
        SpeedMetric.payloadDownload => payloadDownload,
        SpeedMetric.payloadUpload => payloadUpload,
        SpeedMetric.overheadDownload => overheadDownload,
        SpeedMetric.overheadUpload => overheadUpload,
        SpeedMetric.dhtDownload => dhtDownload,
        SpeedMetric.dhtUpload => dhtUpload,
        SpeedMetric.trackerDownload => trackerDownload,
        SpeedMetric.trackerUpload => trackerUpload,
      };
}

class SpeedGraphService extends ChangeNotifier {
  final TorrentClient _client;
  final int updateFrequencySeconds;
  final int timeframeMinutes;

  final Queue<SpeedDataPoint> _points = Queue();
  Timer? _timer;

  SpeedGraphService({
    required TorrentClient client,
    this.updateFrequencySeconds = 1,
    this.timeframeMinutes = 10,
  }) : _client = client {
    _tick();
    _timer = Timer.periodic(Duration(seconds: updateFrequencySeconds), (_) => _tick());
  }

  List<SpeedDataPoint> get points => _points.toList();

  bool get hasData => _points.isNotEmpty;

  /// Returns true if this metric has ever had non-null data (i.e. the API supports it)
  bool isMetricAvailable(SpeedMetric metric) {
    if (metric == SpeedMetric.totalDownload || metric == SpeedMetric.totalUpload) return true;
    return _points.any((p) => p.valueFor(metric) != null);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _tick() async {
    try {
      final info = await _client.getTransferInfo();
      if (info == null) return;
      _points.add(SpeedDataPoint(
        timestamp: DateTime.now(),
        totalDownload: info.downloadSpeed,
        totalUpload: info.uploadSpeed,
        payloadDownload: info.payloadDownloadSpeed,
        payloadUpload: info.payloadUploadSpeed,
        overheadDownload: info.overheadDownloadSpeed,
        overheadUpload: info.overheadUploadSpeed,
        dhtDownload: info.dhtDownloadSpeed,
        dhtUpload: info.dhtUploadSpeed,
        trackerDownload: info.trackerDownloadSpeed,
        trackerUpload: info.trackerUploadSpeed,
      ));
      _trim();
      notifyListeners();
    } catch (_) {
      // Silently ignore — the downloads screen already shows connection errors
    }
  }

  void _trim() {
    final cutoff = DateTime.now().subtract(Duration(minutes: timeframeMinutes));
    while (_points.isNotEmpty && _points.first.timestamp.isBefore(cutoff)) {
      _points.removeFirst();
    }
  }
}
