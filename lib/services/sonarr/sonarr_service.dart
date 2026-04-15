import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:miruryoiki/utils/text.dart';
import '../../models/sonarr/sonarr_episode.dart';
import '../../models/sonarr/sonarr_episode_file.dart';
import '../../models/sonarr/sonarr_quality_profile.dart';
import '../../models/sonarr/sonarr_release.dart';
import '../../models/sonarr/sonarr_root_folder.dart';
import '../../models/sonarr/sonarr_series.dart';
import '../../utils/logging.dart';

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

  /// Returns the internal Sonarr series ID for a given TVDB ID, or null if not found
  Future<int?> getSeriesIdByTvdbId(int tvdbId) async {
    final uri = Uri.parse('$_baseUrl/api/v3/series?tvdbId=$tvdbId&apikey=$_apiKey');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) return data.first['id'] as int;
    }
    return null;
  }

  /// Lookups up Series in Sonarr Skyhook
  Future<List<SonarrSeries>> lookupSeries(String term) async {
    final uri = Uri.parse('$_baseUrl/api/v3/series/lookup?term=${Uri.encodeComponent(term)}&apikey=$_apiKey');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SonarrSeries.fromJson(json)).toList();
    }
    throw Exception('Failed to lookup series');
  }

  /// Returns the internal Sonarr series ID, adding the series if it doesn't exist yet
  Future<int?> ensureSeriesExists({
    required int tvdbId,
    required String title,
    required String rootFolderPath,
    required int qualityProfileId,
  }) async {
    // logTrace('[Sonarr] ensureSeriesExists: tvdbId=$tvdbId, title="$title"');
    final checkUri = Uri.parse('$_baseUrl/api/v3/series?tvdbId=$tvdbId&apikey=$_apiKey');
    final checkResponse = await _client.get(checkUri);

    if (checkResponse.statusCode == 200) {
      final List<dynamic> data = json.decode(checkResponse.body);
      if (data.isNotEmpty) {
        // logTrace('[Sonarr] Series already exists: id=${data.first['id']}');
        return data.first['id'];
      }
    }

    final addUri = Uri.parse('$_baseUrl/api/v3/series?apikey=$_apiKey');
    final payload = {
      "title": title,
      "tvdbId": tvdbId,
      "qualityProfileId": qualityProfileId,
      "rootFolderPath": rootFolderPath,
      "monitored": true,
      "seriesType": "anime",
      "seasonFolder": true,
      "addOptions": {
        "searchForMissingEpisodes": false
      }
    };

    final addResponse = await _client.post(
      addUri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    if (addResponse.statusCode == 201) {
      final data = json.decode(addResponse.body);
      return data['id'];
    }

    throw Exception('Failed to add series to Sonarr: ${addResponse.body}'); // TODO try to match via title, otherwise ask user to add manually
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

    final uri = Uri.parse('$_baseUrl$endpoint?$params&apikey=$_apiKey');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SonarrRelease.fromJson(json)).toList();
    }

    throw Exception('Failed to search releases');
  }

  Future<List<SonarrRelease>> searchEpisodeReleases(int episodeId) async {
    final uri = Uri.parse('$_baseUrl/api/v3/release?episodeId=$episodeId&apikey=$_apiKey');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SonarrRelease.fromJson(json)).toList();
    }
    throw Exception('Failed to search episode releases');
  }
  
  Future<List<SonarrEpisode>> getEpisodes(int sonarrSeriesId) async {
    // logTrace('[Sonarr] getEpisodes: seriesId=$sonarrSeriesId');
    final uri = Uri.parse('$_baseUrl/api/v3/episode?seriesId=$sonarrSeriesId&apikey=$_apiKey');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final episodes = data.map((e) => SonarrEpisode.fromJson(e)).toList();
      // logTrace('[Sonarr] getEpisodes: got ${episodes.length} episodes (${episodes.where((e) => e.hasFile).length} with files)');
      return episodes;
    }
    throw Exception('Failed to load episodes');
  }

  /// Returns all episode files Sonarr has imported for a series
  Future<List<SonarrEpisodeFile>> getEpisodeFiles(int seriesId) async {
    // logTrace('[Sonarr] getEpisodeFiles: seriesId=$seriesId');
    final uri = Uri.parse('$_baseUrl/api/v3/episodefile?seriesId=$seriesId&apikey=$_apiKey');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final files = data.map((e) => SonarrEpisodeFile.fromJson(e)).toList();
      // logTrace('[Sonarr] getEpisodeFiles: got ${files.length} files');
      return files;
    }
    throw Exception('Failed to load episode files');
  }

  /// Deletes an episode file record from Sonarr (unlinks it from the episode).
  /// This does NOT delete the actual file on disk.
  Future<void> deleteEpisodeFile(int episodeFileId) async {
    // logTrace('[Sonarr] deleteEpisodeFile: id=$episodeFileId');
    final uri = Uri.parse('$_baseUrl/api/v3/episodefile/$episodeFileId?apikey=$_apiKey');
    final response = await _client.delete(uri);
    // logTrace('[Sonarr] deleteEpisodeFile: status=${response.statusCode}');

    // 200/204 = deleted, 404 = already gone — both are fine
    if (response.statusCode != 200 && response.statusCode != 204 && response.statusCode != 404) {
      throw Exception('Failed to delete episode file $episodeFileId: ${response.body}');
    }
  }

  /// Previews files available for manual import from a given folder.
  ///
  /// When [seriesId] is provided, Sonarr cross-references its episode file
  /// database — which can crash (500) if any tracked file was deleted from
  /// disk. Omit it to just scan the filesystem.
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
      '&apikey=$_apiKey',
    );
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final results = (json.decode(response.body) as List).cast<Map<String, dynamic>>();
      // logTrace('[Sonarr] previewManualImport: got ${results.length} file previews');
      return results;
    }
    throw Exception('Failed to preview manual import (${response.statusCode}): ${response.body}');
  }

  /// Triggers a manual import of files, linking them to specific episodes
  Future<void> manualImport({
    required List<Map<String, dynamic>> files,
    String importMode = 'Copy',
  }) async {
    // logTrace('[Sonarr] manualImport: ${files.length} files, mode=$importMode');
    final uri = Uri.parse('$_baseUrl/api/v3/command?apikey=$_apiKey');
    final payload = {
      "name": "ManualImport",
      "importMode": importMode,
      "files": files,
    };

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Manual import failed: ${response.body}');
    }
  }

  /// Triggers a RescanSeries command so Sonarr re-reads episode files on disk.
  Future<void> rescanSeries(int seriesId) async {
    // logTrace('[Sonarr] rescanSeries: seriesId=$seriesId');
    final uri = Uri.parse('$_baseUrl/api/v3/command?apikey=$_apiKey');
    final payload = {"name": "RescanSeries", "seriesId": seriesId};
    await _client.post(uri, headers: {'Content-Type': 'application/json'}, body: json.encode(payload));
  }

  Future<List<SonarrQualityProfile>> getQualityProfiles() async {
    final uri = Uri.parse('$_baseUrl/api/v3/qualityprofile?apikey=$_apiKey');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => SonarrQualityProfile.fromJson(e)).toList();
    }
    throw Exception('Failed to load quality profiles');
  }

  Future<List<SonarrRootFolder>> getRootFolders() async {
    final uri = Uri.parse('$_baseUrl/api/v3/rootfolder?apikey=$_apiKey');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => SonarrRootFolder.fromJson(e)).toList();
    }
    throw Exception('Failed to load root folders');
  }

  Future<List<SonarrSeries>> getSeries() async {
    final uri = Uri.parse('$_baseUrl/api/v3/series?apikey=$_apiKey');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => SonarrSeries.fromJson(e)).toList();
    }
    throw Exception('Failed to load series');
  }

  /// Returns the raw JSON for a single Sonarr series by its internal ID
  Future<Map<String, dynamic>> getSeriesById(int seriesId) async {
    // logTrace('[Sonarr] getSeriesById: id=$seriesId');
    final uri = Uri.parse('$_baseUrl/api/v3/series/$seriesId?apikey=$_apiKey');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      // logTrace('[Sonarr] getSeriesById: "${data['title']}", path="${data['path']}"');
      return data;
    }
    throw Exception('Failed to load series $seriesId');
  }

  /// Updates the series path in Sonarr via PUT.
  /// [seriesJson] should be the full series object (from [getSeriesById]) with
  /// the `path` field changed.
  Future<void> updateSeries(Map<String, dynamic> seriesJson) async {
    final id = seriesJson['id'];
    // logTrace('[Sonarr] updateSeries: id=$id, path="${seriesJson['path']}"');
    final uri = Uri.parse('$_baseUrl/api/v3/series/$id?apikey=$_apiKey');
    final response = await _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(seriesJson),
    );

    if (response.statusCode != 200 && response.statusCode != 202) {
      throw Exception('Failed to update series: ${response.body}');
    }
  }

  Future<bool> testConnection() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v3/system/status?apikey=$_apiKey');
      final response = await _client.get(uri);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> grabRelease(String guid, int indexerId) async {
    final uri = Uri.parse('$_baseUrl/api/v3/release?apikey=$_apiKey');
    final payload = {
      "guid": guid,
      "indexerId": indexerId,
    };

    await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
  }
  static String get defaultUrlPort => 'http://localhost:8989';
}
