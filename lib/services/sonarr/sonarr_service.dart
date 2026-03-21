import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:miruryoiki/utils/text.dart';
import '../../models/sonarr/sonarr_episode.dart';
import '../../models/sonarr/sonarr_quality_profile.dart';
import '../../models/sonarr/sonarr_release.dart';
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
    final checkUri = Uri.parse('$_baseUrl/api/v3/series?tvdbId=$tvdbId&apikey=$_apiKey');
    final checkResponse = await _client.get(checkUri);

    if (checkResponse.statusCode == 200) {
      final List<dynamic> data = json.decode(checkResponse.body);
      if (data.isNotEmpty) return data.first['id'];
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
    final uri = Uri.parse('$_baseUrl/api/v3/episode?seriesId=$sonarrSeriesId&apikey=$_apiKey');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => SonarrEpisode.fromJson(e)).toList();
    }
    throw Exception('Failed to load episodes');
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
