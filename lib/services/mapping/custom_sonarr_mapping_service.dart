import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage custom mappings between Anilist IDs and Sonarr TVDB IDs
class CustomSonarrMappingService {
  static const String _key = 'miru_sonarr_custom_mappings';

  Future<int?> getCustomTvdbId(int anilistId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key) ?? '{}';
    final map = json.decode(jsonStr) as Map<String, dynamic>;
    return map[anilistId.toString()] as int?;
  }

  Future<void> saveCustomTvdbId(int anilistId, int tvdbId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key) ?? '{}';
    final map = json.decode(jsonStr) as Map<String, dynamic>;
    map[anilistId.toString()] = tvdbId;
    await prefs.setString(_key, json.encode(map));
  }
}
