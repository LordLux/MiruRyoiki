import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'sonarr_exceptions.dart';

import 'package:http/http.dart' as http;
import 'package:miruryoiki/utils/text.dart';
import '../../models/sonarr/sonarr_episode.dart';
import '../../models/sonarr/sonarr_episode_file.dart';
import '../../models/sonarr/sonarr_quality_profile.dart';
import '../../models/torrent_release.dart';
import '../../models/sonarr/sonarr_root_folder.dart';
import '../../models/sonarr/sonarr_series.dart';

class SonarrRepository {
  final String _baseUrl; // e.g., http://localhost:8989
  final String _apiKey;
  final http.Client _client;

  SonarrRepository({
    required String baseUrl,
    required String apiKey,
    http.Client? client,
  })  : _baseUrl = baseUrl.fallbackIfEmpty(defaultUrlPort),
        _apiKey = apiKey,
        _client = client ?? http.Client();

  /// Upper bound for a single request, so an unresponsive host fails instead of hanging forever
  ///
  /// Generous because interactive release searches wait on every indexer
  static const Duration _requestTimeout = Duration(minutes: 2);

  Future<http.Response> _get(Uri uri) async {
    return _request(() => _client.get(uri, headers: {"X-Api-Key": _apiKey}));
  }

  Future<http.Response> _post(Uri uri, {required dynamic body}) async {
    return _request(() => _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-Api-Key': _apiKey,
      },
      body: json.encode(body),
    ));
  }

  Future<http.Response> _put(Uri uri, {required dynamic body}) async {
    return _request(() => _client.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-Api-Key': _apiKey,
      },
      body: json.encode(body),
    ));
  }

  Future<http.Response> _delete(Uri uri) async {
    return _request(() => _client.delete(uri, headers: {"X-Api-Key": _apiKey}));
  }

  Future<http.Response> _request(Future<http.Response> Function() requestFunc) async {
    try {
      final response = await requestFunc().timeout(_requestTimeout);
      _handleError(response);
      return response;
    } on IOException catch (_) {
      // SocketException, TlsException/HandshakeException, ...
      throw SonarrConnectionException();
    } on http.ClientException catch (_) {
      throw SonarrConnectionException();
    } on TimeoutException catch (_) {
      throw SonarrConnectionException('Connection Timed Out');
    }
  }

  /// Decodes a successful response body, e.g. a reverse proxy answering 200 with an HTML login page is not valid JSON
  dynamic _decode(http.Response response) {
    try {
      return json.decode(response.body);
    } on FormatException catch (_) {
      throw SonarrException('Invalid response from Sonarr (${response.statusCode})');
    }
  }

  void _handleError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    if (response.statusCode == 401) {
      throw SonarrUnauthorizedException();
    }
    if (response.statusCode == 404) {
      throw SonarrNotFoundException();
    }
    if (response.statusCode >= 500) {
      throw SonarrServerException();
    }
    if (response.statusCode == 400) {
      String msg = 'Bad Request (400)';
      try {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty && data[0] is Map && data[0].containsKey('errorMessage')) {
          msg = data[0]['errorMessage'];
        } else if (data is Map && data.containsKey('message')) {
          msg = data['message'];
        }
      } catch (_) {}
      throw SonarrBadRequestException(msg);
    }
    throw SonarrException('Unexpected error: ${response.statusCode} - ${response.body}');
  }

  /// Returns the internal Sonarr series ID for a given TVDB ID, or null if not found
  Future<int?> getSeriesIdByTvdbId(int tvdbId) async {
    final uri = Uri.parse('$_baseUrl/api/v3/series?tvdbId=$tvdbId');
    final response = await _get(uri);
    final List<dynamic> data = _decode(response);
    if (data.isNotEmpty) return data.first['id'] as int;
    return null;
  }

  /// Lookups up Series in Sonarr Skyhook
  Future<List<SonarrSeries>> lookupSeries(String term) async {
    final uri = Uri.parse('$_baseUrl/api/v3/series/lookup?term=${Uri.encodeComponent(term)}');
    final response = await _get(uri);

    final List<dynamic> data = _decode(response);
    return data.map((json) => SonarrSeries.fromJson(json)).toList();
  }

  /// Returns the internal Sonarr series ID, adding the series if it doesn't exist yet
  Future<int?> ensureSeriesExists({
    required int tvdbId,
    required String title,
    required String rootFolderPath,
    required int qualityProfileId,
    String? path, // optional custom path
  }) async {
    // logTrace('[Sonarr] ensureSeriesExists: tvdbId=$tvdbId, title="$title"');
    final checkUri = Uri.parse('$_baseUrl/api/v3/series?tvdbId=$tvdbId');
    final checkResponse = await _get(checkUri);

    final List<dynamic> data = _decode(checkResponse);
    if (data.isNotEmpty) {
      return data.first['id'];
    }

    final addUri = Uri.parse('$_baseUrl/api/v3/series');
    final payload = <String, dynamic>{
      "title": title,
      "tvdbId": tvdbId,
      "qualityProfileId": qualityProfileId,
      "rootFolderPath": rootFolderPath,
      "monitored": true,
      "seriesType": "anime",
      "seasonFolder": true,
      "addOptions": {
        "searchForMissingEpisodes": false
      },
      if (path != null) "path": path,
    };

    final addResponse = await _post(addUri, body: payload);

    final addData = _decode(addResponse);
    return addData['id'] as int; // TODO try to match via title, otherwise ask user to add manually
  }

  /// Searches for available releases matching a series, optionally filtered by season/episode
  Future<List<SonarrRelease>> searchReleases({
    required int sonarrSeriesId,
    int? seasonNumber,
    int? episodeNumber,
  }) async {
    String endpoint = '/api/v3/release';
    String params = 'seriesId=$sonarrSeriesId';

    if (episodeNumber != null) params += '&episodeNumber=$episodeNumber';
    if (seasonNumber != null) params += '&seasonNumber=$seasonNumber';

    final uri = Uri.parse('$_baseUrl$endpoint?$params');
    final response = await _get(uri);

    final List<dynamic> data = _decode(response);
    return data.map((json) => SonarrRelease.fromJson(json)).toList();
  }

  Future<List<SonarrRelease>> searchEpisodeReleases(int episodeId) async {
    final uri = Uri.parse('$_baseUrl/api/v3/release?episodeId=$episodeId');
    final response = await _get(uri);

    final List<dynamic> data = _decode(response);
    return data.map((json) => SonarrRelease.fromJson(json)).toList();
  }
  
  Future<List<SonarrEpisode>> getEpisodes(int sonarrSeriesId) async {
    // logTrace('[Sonarr] getEpisodes: seriesId=$sonarrSeriesId');
    final uri = Uri.parse('$_baseUrl/api/v3/episode?seriesId=$sonarrSeriesId');
    final response = await _get(uri);

    final List<dynamic> data = _decode(response);
    return data.map((e) => SonarrEpisode.fromJson(e)).toList();
  }

  /// Returns all episode files Sonarr has imported for a series
  Future<List<SonarrEpisodeFile>> getEpisodeFiles(int seriesId) async {
    // logTrace('[Sonarr] getEpisodeFiles: seriesId=$seriesId');
    final uri = Uri.parse('$_baseUrl/api/v3/episodefile?seriesId=$seriesId');
    final response = await _get(uri);

    final List<dynamic> data = _decode(response);
    return data.map((e) => SonarrEpisodeFile.fromJson(e)).toList();
  }

  Future<void> deleteEpisodeFile(int episodeFileId) async {
    // logTrace('[Sonarr] deleteEpisodeFile: id=$episodeFileId');
    final uri = Uri.parse('$_baseUrl/api/v3/episodefile/$episodeFileId');
    try {
      await _delete(uri);
    } on SonarrNotFoundException catch (_) {
      // 404 is fine for deletion (already gone)
    }
  }

  /// Previews files available for manual import from a given folder
  ///
  /// When [seriesId] is provided, Sonarr cross-references its episode file database — which can crash (500) if any tracked file was deleted from disk
  ///
  /// Omit it to just scan the filesystem
  Future<List<Map<String, dynamic>>> previewManualImport({
    required String folder,
    int? seriesId,
    bool filterExistingFiles = true,
  }) async {
    // logTrace('[Sonarr] previewManualImport: folder="$folder", seriesId=$seriesId, filterExisting=$filterExistingFiles');
    final uri = Uri.parse(
      '$_baseUrl/api/v3/manualimport'
      '?folder=${Uri.encodeComponent(folder)}'
      '${seriesId != null ? '&seriesId=$seriesId' : ''}'
      '&filterExistingFiles=$filterExistingFiles'
      '',
    );
    final response = await _get(uri);

    return (_decode(response) as List).cast<Map<String, dynamic>>();
  }

  /// Triggers a manual import of files, linking them to specific episodes
  ///
  /// Each file item should carry the internal series/episode ids and the `quality` object from [previewManualImport], so Sonarr does not fall back to filename parsing
  ///
  /// [importMode] only matters for files outside the Sonarr series folder: `Copy` leaves the source in place, `Move` relocates it. Files already inside the series folder are registered where they are
  Future<void> manualImport({
    required List<Map<String, dynamic>> files,
    String importMode = 'Copy',
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v3/command');
    final payload = {
      'name': 'ManualImport',
      'importMode': importMode,
      'files': files,
    };

    await _post(uri, body: payload);
  }

  /// Triggers a RescanSeries command so Sonarr re-reads episode files on disk
  Future<void> rescanSeries(int seriesId) async {
    // logTrace('[Sonarr] rescanSeries: seriesId=$seriesId');
    final uri = Uri.parse('$_baseUrl/api/v3/command');
    final payload = {"name": "RescanSeries", "seriesId": seriesId};
    await _post(uri, body: payload);
  }

  Future<List<SonarrQualityProfile>> getQualityProfiles() async {
    final uri = Uri.parse('$_baseUrl/api/v3/qualityprofile');
    final response = await _get(uri);

    final List<dynamic> data = _decode(response);
    return data.map((e) => SonarrQualityProfile.fromJson(e)).toList();
  }

  Future<List<SonarrRootFolder>> getRootFolders() async {
    final uri = Uri.parse('$_baseUrl/api/v3/rootfolder');
    final response = await _get(uri);

    final List<dynamic> data = _decode(response);
    return data.map((e) => SonarrRootFolder.fromJson(e)).toList();
  }

  Future<List<SonarrSeries>> getSeries() async {
    final uri = Uri.parse('$_baseUrl/api/v3/series');
    final response = await _get(uri);

    final List<dynamic> data = _decode(response);
    return data.map((e) => SonarrSeries.fromJson(e)).toList();
  }

  /// Returns the raw JSON for a single Sonarr series by its internal ID
  Future<Map<String, dynamic>> getSeriesById(int seriesId) async {
    // logTrace('[Sonarr] getSeriesById: id=$seriesId');
    final uri = Uri.parse('$_baseUrl/api/v3/series/$seriesId');
    final response = await _get(uri);

    return _decode(response) as Map<String, dynamic>;
  }

  /// Updates the series path in Sonarr via PUT
  ///
  /// [seriesJson] should be the full series object (from [getSeriesById]) with the `path` field changed
  Future<void> updateSeries(Map<String, dynamic> seriesJson) async {
    final id = seriesJson['id'];
    // logTrace('[Sonarr] updateSeries: id=$id, path="${seriesJson['path']}"');
    final uri = Uri.parse('$_baseUrl/api/v3/series/$id');
    await _put(uri, body: seriesJson);
  }

  /// Updates only the `path` field of an existing Sonarr series
  Future<void> updateSeriesPath(int sonarrSeriesId, String newPath) async {
    final seriesJson = await getSeriesById(sonarrSeriesId);
    seriesJson['path'] = newPath;
    await updateSeries(seriesJson);
  }

  Future<bool> testConnection() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v3/system/status');
      final response = await _get(uri);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> grabRelease(String guid, int indexerId) async {
    final uri = Uri.parse('$_baseUrl/api/v3/release');
    final payload = {
      "guid": guid,
      "indexerId": indexerId,
    };

    await _post(uri, body: payload);
  }
  static String get defaultUrlPort => 'http://localhost:8989';
}
