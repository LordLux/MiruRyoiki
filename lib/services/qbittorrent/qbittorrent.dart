import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:miruryoiki/utils/text.dart';
import '../downloads/torrent_client.dart';

/// Lightweight client for the qBittorrent Web API v2
///
/// Authenticates via `/api/v2/auth/login` and stores the SID cookie for subsequent requests
class QBittorrentRepository implements TorrentClient {
  static String get defaultUrlPort => 'http://localhost:8080';
  static String get defaultUsername => 'admin';

  final String _baseUrl; // http://localhost:8080
  final String _username;
  final String _password;
  final http.Client _client;

  String? _sid;

  QBittorrentRepository({
    required String baseUrl,
    required String username,
    required String password,
    http.Client? client,
  })  : _baseUrl = (baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl).fallbackIfEmpty(defaultUrlPort),
        _username = username.fallbackIfEmpty(defaultUsername),
        _password = password,
        _client = client ?? http.Client();

  // Auth
  /// Authenticate with qBittorrent and store the SID cookie
  /// Returns `true` on success
  Future<bool> login() async {
    final uri = Uri.parse('$_baseUrl/api/v2/auth/login');
    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Referer': _baseUrl,
      },
      body: 'username=${Uri.encodeComponent(_username)}&password=${Uri.encodeComponent(_password)}',
    );

    if (response.statusCode == 200 && response.body.trim().toUpperCase() == 'OK.') {
      // Extract SID from Set-Cookie header
      final cookies = response.headers['set-cookie'];
      if (cookies != null) {
        final match = RegExp(r'SID=([^;]+)').firstMatch(cookies);
        if (match != null) {
          _sid = match.group(1);
          return true;
        }
      }
      // Some qBittorrent versions return OK without a cookie if already authenticated
      return true;
    }

    return false;
  }

  /// Logout / invalidate the session
  Future<void> logout() async {
    if (_sid == null) return;

    await _client.post(
      Uri.parse('$_baseUrl/api/v2/auth/logout'),
      headers: _authHeaders,
    );
    _sid = null;
  }

  @override
  String get clientName => 'qBittorrent';

  bool get isAuthenticated => _sid != null;

  Map<String, String> get _authHeaders => {
    if (_sid != null) 'Cookie': 'SID=$_sid',
    'Referer': _baseUrl,
  };

  @override
  Future<bool> addMagnet(
    String magnetUrl, {
    String? savePath,
    String? category,
  }) async {
    await _ensureAuthenticated();

    final uri = Uri.parse('$_baseUrl/api/v2/torrents/add');

    http.MultipartRequest buildRequest() {
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(_authHeaders)
        ..fields['urls'] = magnetUrl;

      if (savePath != null && savePath.isNotEmpty) //
        request.fields['savepath'] = savePath;

      if (category != null && category.isNotEmpty) //
        request.fields['category'] = category;

      return request;
    }

    var streamed = await _client.send(buildRequest());

    // Retry on session expiry
    if (streamed.statusCode == 403) {
      _sid = null;
      await _ensureAuthenticated();
      streamed = await _client.send(buildRequest());
    }

    return streamed.statusCode == 200;
  }

  @override
  Future<List<TorrentInfo>> listTorrents({String? filter}) async {
    final params = <String, String>{};
    if (filter != null) params['filter'] = filter;

    final uri = Uri.parse('$_baseUrl/api/v2/torrents/info').replace(queryParameters: params.isNotEmpty ? params : null);
    final response = await _authedGet(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((t) => _parseTorrent(t as Map<String, dynamic>)).toList();
    }

    throw Exception('Failed to list torrents (${response.statusCode})');
  }

  @override
  Future<bool> pauseTorrent(String hash) async {
    final uri = Uri.parse('$_baseUrl/api/v2/torrents/pause');
    final response = await _authedPost(uri,
      extraHeaders: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'hashes=$hash',
    );
    return response.statusCode == 200;
  }

  @override
  Future<bool> resumeTorrent(String hash) async {
    final uri = Uri.parse('$_baseUrl/api/v2/torrents/resume');
    final response = await _authedPost(uri,
      extraHeaders: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'hashes=$hash',
    );
    return response.statusCode == 200;
  }

  @override
  Future<bool> deleteTorrent(String hash, {bool deleteFiles = false}) async {
    final uri = Uri.parse('$_baseUrl/api/v2/torrents/delete');
    final response = await _authedPost(uri,
      extraHeaders: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'hashes=$hash&deleteFiles=$deleteFiles',
    );
    return response.statusCode == 200;
  }

  @override
  Future<bool> testConnection() async {
    try {
      if (!isAuthenticated) {
        final loggedIn = await login();
        if (!loggedIn) return false;
      }

      final uri = Uri.parse('$_baseUrl/api/v2/app/version');
      final response = await _authedGet(uri);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Internal helpers

  /// Ensure we are authenticated before making a request, and attempt to login if not
  Future<void> _ensureAuthenticated() async {
    if (_sid == null) {
      final ok = await login();
      if (!ok) throw Exception('qBittorrent authentication failed');
    }
  }

  /// Re-authenticate if a response indicates session expiry (403)
  Future<http.Response> _authedPost(Uri uri, {Map<String, String>? extraHeaders, String? body}) async {
    await _ensureAuthenticated();
    var response = await _client.post(uri, headers: {
      ..._authHeaders,
      if (extraHeaders != null) ...extraHeaders,
    }, body: body);

    if (response.statusCode == 403) {
      _sid = null;
      await _ensureAuthenticated();
      response = await _client.post(uri, headers: {
        ..._authHeaders,
        if (extraHeaders != null) ...extraHeaders,
      }, body: body);
    }
    return response;
  }

  Future<http.Response> _authedGet(Uri uri) async {
    await _ensureAuthenticated();
    var response = await _client.get(uri, headers: _authHeaders);

    if (response.statusCode == 403) {
      _sid = null;
      await _ensureAuthenticated();
      response = await _client.get(uri, headers: _authHeaders);
    }
    return response;
  }

  /// Map qBittorrent's state string to our normalized enum
  static TorrentState _mapState(String? qbitState) {
    return switch (qbitState) {
      'downloading' || 'forcedDL' || 'metaDL' || 'allocating' => TorrentState.downloading,
      'uploading' || 'forcedUP' => TorrentState.seeding,
      'pausedDL' || 'pausedUP' => TorrentState.paused,
      'queuedDL' || 'queuedUP' => TorrentState.queued,
      'checkingDL' || 'checkingUP' || 'checkingResumeData' => TorrentState.checking,
      'stalledDL' || 'stalledUP' => TorrentState.stalled,
      'moving' => TorrentState.checking,
      'error' || 'missingFiles' => TorrentState.error,
      _ => TorrentState.unknown,
    };
  }

  static String? _formatEta(dynamic seconds) {
    if (seconds == null || seconds is! int || seconds <= 0 || seconds == 8640000) return null;
    final d = Duration(seconds: seconds);
    if (d.inDays > 0) return '${d.inDays}d ${d.inHours.remainder(24)}h';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    return '${d.inSeconds}s';
  }

  static TorrentInfo _parseTorrent(Map<String, dynamic> t) {
    return TorrentInfo(
      hash: t['hash'] as String? ?? '',
      name: t['name'] as String? ?? 'Unknown',
      state: _mapState(t['state'] as String?),
      progress: (t['progress'] as num?)?.toDouble() ?? 0.0,
      size: (t['total_size'] as num?)?.toInt() ?? (t['size'] as num?)?.toInt() ?? 0,
      downloaded: (t['downloaded'] as num?)?.toInt() ?? 0,
      uploaded: (t['uploaded'] as num?)?.toInt() ?? 0,
      downloadSpeed: (t['dlspeed'] as num?)?.toInt() ?? 0,
      uploadSpeed: (t['upspeed'] as num?)?.toInt() ?? 0,
      seeders: (t['num_seeds'] as num?)?.toInt() ?? 0,
      leechers: (t['num_leechs'] as num?)?.toInt() ?? 0,
      eta: _formatEta(t['eta']),
      savePath: t['save_path'] as String? ?? t['content_path'] as String?,
      category: t['category'] as String?,
      addedOn: t['added_on'] != null ? DateTime.fromMillisecondsSinceEpoch((t['added_on'] as int) * 1000) : null,
    );
  }
}
