import 'package:flutter/material.dart';
import '../../models/series.dart';
import '../../models/anilist/anime.dart';
import 'queries.dart';

class SeriesLinkService {
  final AnilistService _anilistService;

  SeriesLinkService({AnilistService? anilistService}) : _anilistService = anilistService ?? AnilistService();

  /// Try to link a series to Anilist by name
  Future<List<AnilistAnime>> findMatchesByName(Series series) async {
    // Clean up the series name to improve matching
    final searchQuery = _cleanSeriesName(series.name);
    return await _anilistService.searchAnime(searchQuery);
  }

  Future<AnilistAnime?> fetchAnimeDetails(int anilistId) async {
    return await _anilistService.getAnimeDetails(anilistId);
  }

  /// Link a series to a specific Anilist ID
  Future<bool> linkSeries(Series series, int anilistId) async {
    try {
      final anime = await _anilistService.getAnimeDetails(anilistId);
      if (anime != null) {
        series.anilistId = anilistId;
        series.anilistData = anime;
        return true;
      }
    } catch (e) {
      debugPrint('Error linking series to Anilist: $e');
    }
    return false;
  }

  /// Clean up series name for better search results
  String _cleanSeriesName(String name) {
    // Remove common patterns in filenames
    String cleaned = name
        .replaceAll(RegExp(r'\[.*?\]'), '') // Remove text in brackets
        .replaceAll(RegExp(r'\(.*?\)'), '') // Remove text in parentheses
        .replaceAll(RegExp(r'S\d{1,2}'), '') // Remove season indicators
        .replaceAll(RegExp(r'\d{3,4}p'), '') // Remove resolution
        .replaceAll(RegExp(r'BD|BluRay|dvd|webdl|webrip', caseSensitive: false), '')
        .replaceAll(RegExp(r'x\d{3}'), '') // Remove codec info
        .replaceAll('_', ' ')
        .replaceAll('.', ' ')
        .trim();

    // Remove multiple spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    return cleaned;
  }

  /// Refresh metadata for a linked series
  Future<bool> refreshMetadata(Series series) async {
    if (series.anilistId == null) return false;

    try {
      final anime = await _anilistService.getAnimeDetails(series.anilistId!);
      if (anime != null) {
        series.anilistData = anime;
        return true;
      }
    } catch (e) {
      debugPrint('Error refreshing Anilist metadata: $e');
    }
    return false;
  }
}
