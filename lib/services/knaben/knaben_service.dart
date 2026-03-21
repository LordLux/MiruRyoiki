import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/knaben/knaben_release.dart';
import '../../utils/logging.dart';

/// Anime sub-category IDs used by Knaben
abstract class KnabenAnimeCategory {
  static const int sub = 6001000;
  static const int dub = 6002000;
  static const int dualAudio = 6003000;
  static const int raw = 6004000;
  static const int musicVideo = 6005000;

  /// All anime categories combined (sub + dub + dual-audio + raw)
  static const List<int> all = [sub, dub, dualAudio, raw];
}

/// Search mode for Knaben queries
enum KnabenSearchMode {
  /// Only queries the local cache
  fast,

  /// Reaches out to all indexers in real time (slower)
  live,
}

/// Repository that wraps the Knaben Database REST API (`https://api.knaben.org/v1`)
///
/// Handles search and returns a list of [KnabenRelease] objects complete with magnet links, seeder counts, sizes, and tracker names
class KnabenRepository {
  static const String _defaultBaseUrl = 'https://api.knaben.org/v1';

  final String _baseUrl;
  final http.Client _client;

  KnabenRepository({
    String? baseUrl,
    http.Client? client,
  })  : _baseUrl = baseUrl ?? _defaultBaseUrl,
        _client = client ?? http.Client();

  /// Search Knaben for torrents matching [query]
  ///
  /// [categories] defaults to all anime categories
  /// [limit] caps the number of results (Knaben's default is 100)
  /// [mode] switches between a cached-only fast search and a live one
  /// [hideUnsafe] filters out unsafe results (enabled by default)
  /// [orderBy] controls result ordering ()`"seeders"` by default)
  Future<List<KnabenRelease>> search(
    String query, {
    List<int>? categories,
    int limit = 100,
    KnabenSearchMode mode = KnabenSearchMode.fast,
    bool hideUnsafe = true,
    String orderBy = 'seeders',
    String searchField = 'title',
    String searchType = '100%',
  }) async {
    final body = <String, dynamic>{
      'search_field': searchField,
      'search_type': searchType,
      'query': query,
      'order_by': orderBy,
      'order_direction': 'desc',
      'hide_unsafe': hideUnsafe,
      'size': limit,
      if (categories != null && categories.isNotEmpty) 'categories': categories,
    };

    final uri = Uri.parse(_baseUrl);
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      // The API may return either a top-level list or an object with a `hits` / `results` key
      final List<dynamic> hits;
      if (decoded is List) {
        hits = decoded;
      } else if (decoded is Map) {
        hits = (decoded['hits'] ?? decoded['results'] ?? decoded['data'] ?? []) as List<dynamic>;
      } else {
        hits = [];
      }

      return hits.map((e) => KnabenRelease.fromJson(e as Map<String, dynamic>)).where((r) => r.magnetUrl.isNotEmpty).toList();
    }

    throw Exception('Knaben search failed (${response.statusCode}): ${response.body}');
  }

  /// Search for a specific episode using multiple strategies to maximize matches
  Future<List<KnabenRelease>> searchEpisode(
    String seriesTitle, {
    required int season,
    required int episode,
    List<int>? categories,
    KnabenSearchMode mode = KnabenSearchMode.fast,
  }) async {
    final s = season.toString().padLeft(2, '0');
    final e = episode.toString().padLeft(2, '0');
    final eShort = episode.toString();
    logDebug('Initiating episode search for $seriesTitle S${s}E$e (also trying with episode as $eShort)');

    // Strict TV match (S01E05)
    var searchString = '$seriesTitle S${s}E$e';
    var results = await search(searchString, categories: [], mode: mode);
    if (results.isNotEmpty) return results;

    // Common Anime numbering (Series - 05) with 100% strictness
    searchString = '$seriesTitle - $e';
    results = await search(searchString, categories: categories, mode: mode);
    if (results.isNotEmpty) return results;

    // Common Anime numbering without pad (Series - 5)
    searchString = '$seriesTitle - $eShort';
    results = await search(searchString, categories: categories, mode: mode);
    if (results.isNotEmpty) return results;

    // Fallback to loose search ('score') but filter results to ensure the episode number is actually in the title
    final looseResults = await search('$seriesTitle $e', categories: categories, mode: mode, searchType: 'score');
    final validLoose = looseResults.where((r) {
      final t = r.title.toLowerCase();
      // Ensure we don't pick up unrelated numbers like "1080p" when searching for "10"
      const episodeNumberPattern = r'\b(?:e|ep|episode|s\d+e)?0?' // Word boundary, optional episode prefix
          r'$episodeNumber'
          r'\b|' // Word boundary
          r'\[$episodeNumber\]' // Bracket format: [10]
          r'|'
          r'\- 0?$episodeNumber\b' // Dash format: - 10 or - 010
          r'|'
          r'0?$episodeNumber\s*\-'; // Episode number at start: 10 - or 010 -
      final regex = RegExp(
        episodeNumberPattern.replaceAll(r'$episodeNumber', eShort),
        caseSensitive: false,
      );
      return regex.hasMatch(t);
    }).toList();

    return validLoose;
  }

  /// Search for an entire season / batch
  Future<List<KnabenRelease>> searchSeason(
    String seriesTitle, {
    required int season,
    List<int>? categories,
    KnabenSearchMode mode = KnabenSearchMode.fast,
  }) {
    final s = season.toString().padLeft(2, '0');
    // Search for season pack without a specific episode number
    final query = '$seriesTitle S$s';

    return search(query, categories: categories, mode: mode);
  }

  /// Quick health check
  Future<bool> testConnection() async {
    try {
      final uri = Uri.parse(_baseUrl);
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'search_field': 'title',
          'search_type': '100%',
          'query': 'test',
          'size': 1,
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
