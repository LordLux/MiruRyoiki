import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // For compute()
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../models/mappings/plex_mapping.dart';

class PlexAniBridgeService {
  // Memory Cache for fast O(1) lookups after loading
  Map<int, PlexMapping>? _memoryCache;

  static const String _remoteUrl = 'https://raw.githubusercontent.com/eliasbenb/PlexAniBridge-Mappings/master/mappings.json';
  static const String _localFileName = 'plex_mappings_cache.json';

  /// Returns the mapping for a specific AniList ID, or null if not found.
  Future<PlexMapping?> getMapping(int anilistId) async {
    if (_memoryCache == null) await _initialize();
    return _memoryCache?[anilistId];
  }

  /// Loads data from local cache or downloads if missing/stale
  Future<void> _initialize() async {
    final file = await _getLocalFile();

    if (!(await file.exists())) {
      await forceRefresh();
    } else {
      // TODO: Add logic here to check file age and auto-refresh (e.g., if > 7 days)
      final jsonString = await file.readAsString();
      _memoryCache = await compute(_parseMappings, jsonString);
    }
  }

  /// Force downloads the latest mappings from GitHub
  Future<void> forceRefresh() async {
    try {
      final response = await http.get(Uri.parse(_remoteUrl));
      if (response.statusCode == 200) {
        final file = await _getLocalFile();
        await file.writeAsString(response.body);
        _memoryCache = await compute(_parseMappings, response.body);
      }
    } catch (e) {
      debugPrint('Failed to download mappings: $e');
      // On failure, ensure we assume empty cache rather than crashing
      _memoryCache = {};
    }
  }

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_localFileName');
  }

  // Parses the JSON into a Map of PlexMapping objects
  static Map<int, PlexMapping> _parseMappings(String jsonBody) {
    final Map<String, dynamic> rawMap = json.decode(jsonBody);
    final Map<int, PlexMapping> result = {};

    rawMap.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final mapping = PlexMapping.fromJson(key, value);
        result[mapping.anilistId] = mapping;
      }
    });

    return result;
  }
}
