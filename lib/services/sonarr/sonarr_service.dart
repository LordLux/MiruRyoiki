import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/sonarr/sonarr_release.dart';

class SonarrRepository {
  final String _baseUrl; // e.g., http://localhost:8989
  final String _apiKey;
  final http.Client _client;

  SonarrRepository({
    required String baseUrl,
    required String apiKey,
    http.Client? client,
  })  : _baseUrl = baseUrl,
        _apiKey = apiKey,
        _client = client ?? http.Client();

  // 1. CHECK & ADD SERIES
  // Returns the internal Sonarr Series ID
  Future<int?> ensureSeriesExists({
    required int tvdbId,
    required String title,
    required String rootFolderPath, // You need to store this in user prefs
    required int qualityProfileId, // You need to store this in user prefs
  }) async {
    // A. Check if exists
    final checkUri = Uri.parse('$_baseUrl/api/v3/series?tvdbId=$tvdbId&apikey=$_apiKey');
    final checkResponse = await _client.get(checkUri);

    if (checkResponse.statusCode == 200) {
      final List<dynamic> data = json.decode(checkResponse.body);
      if (data.isNotEmpty) return data.first['id']; // Series exists, return its ID
    }

    // B. If not, Add it (The "Implicit" Step)
    final addUri = Uri.parse('$_baseUrl/api/v3/series?apikey=$_apiKey');
    final payload = {
      "title": title,
      "tvdbId": tvdbId,
      "qualityProfileId": qualityProfileId,
      "rootFolderPath": rootFolderPath,
      "monitored": true,
      "seriesType": "anime", // Critical for Prowlarr/Anime matching
      "seasonFolder": true,
      "addOptions": {
        "searchForMissingEpisodes": false // Don't auto-search everything yet
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

    throw Exception('Failed to add series to Sonarr: ${addResponse.body}'); //TODO try to match via title, otherwise ask user to add manually
  }

  Future<List<SonarrRelease>> searchReleases({
    required int sonarrSeriesId, // Returned from ensureSeriesExists
    int? seasonNumber, // If null, searches whole series? usually need context
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
     // The endpoint is the same, but we pass episodeId instead of seasonNumber
    final uri = Uri.parse('$_baseUrl/api/v3/release?episodeId=$episodeId&apikey=$_apiKey');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SonarrRelease.fromJson(json)).toList();
    }
    throw Exception('Failed to search episode releases');
  }
  
  Future<List<dynamic>> getEpisodes(int sonarrSeriesId) async {
    final uri = Uri.parse('$_baseUrl/api/v3/episode?seriesId=$sonarrSeriesId&apikey=$_apiKey');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load episodes');
  }

  // 3. GRAB (Download)
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
}
