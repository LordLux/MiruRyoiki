import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../services/file_scanner.dart';
import '../services/player_trackers/mpchc.dart';
import 'series.dart';
import 'episode.dart';

class Library with ChangeNotifier {
  List<Series> _series = [];
  String? _libraryPath;
  bool _isLoading = false;
  late FileScanner _fileScanner;
  late MPCHCTracker _mpcTracker;

  List<Series> get series => List.unmodifiable(_series);
  String? get libraryPath => _libraryPath;
  bool get isLoading => _isLoading;

  Library() {
    _fileScanner = FileScanner();
    _mpcTracker = MPCHCTracker()..addListener(_onMpcTrackerUpdate);
    _loadLibrary();
  }

  @override
  void dispose() {
    _mpcTracker.removeListener(_onMpcTrackerUpdate);
    _mpcTracker.dispose();
    super.dispose();
  }

  void _onMpcTrackerUpdate() async {
    final watchedFiles = await _mpcTracker.checkForUpdates();
    var updated = false;

    // Update watched status for any files that were detected as watched
    for (final filePath in watchedFiles) {
      for (final series in _series) {
        // Check in seasons
        for (final season in series.seasons) {
          for (final episode in season.episodes) {
            if (episode.path == filePath && !episode.watched) {
              episode.watched = true;
              episode.watchedPercentage = 1.0;
              updated = true;
            }
          }
        }

        // Check in related media
        for (final episode in series.relatedMedia) {
          if (episode.path == filePath && !episode.watched) {
            episode.watched = true;
            episode.watchedPercentage = 1.0;
            updated = true;
          }
        }
      }
    }

    if (updated) {
      _saveLibrary();
      notifyListeners();
    }
  }

  Future<void> setLibraryPath(String path) async {
    _libraryPath = path;
    await _saveSettings();
    await scanLibrary();
  }

  Future<void> scanLibrary() async {
    if (_libraryPath == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _series = await _fileScanner.scanLibrary(_libraryPath!);

      // Update watched status from tracker
      _updateWatchedStatus();

      await _saveLibrary();
    } catch (e) {
      debugPrint('Error scanning library: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateWatchedStatus() {
    if (!_mpcTracker.isInitialized) return;

    for (final series in _series) {
      // Update seasons/episodes
      for (final season in series.seasons) {
        for (final episode in season.episodes) {
          episode.watchedPercentage = _mpcTracker.getWatchPercentage(episode.path);
          episode.watched = _mpcTracker.isWatched(episode.path);
        }
      }

      // Update related media
      for (final episode in series.relatedMedia) {
        episode.watchedPercentage = _mpcTracker.getWatchPercentage(episode.path);
        episode.watched = _mpcTracker.isWatched(episode.path);
      }
    }
  }

  Future<void> _loadSettings() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/miruryoiki_settings.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content);
        _libraryPath = data['libraryPath'];
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/miruryoiki_settings.json');

      final data = {
        'libraryPath': _libraryPath,
      };

      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  Future<void> _loadLibrary() async {
    try {
      await _loadSettings();

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/miruryoiki_library.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content) as List;
        _series = data.map((s) => Series.fromJson(s)).toList();
      }

      // Update watched status
      _updateWatchedStatus();
    } catch (e) {
      debugPrint('Error loading library: $e');
    }
    notifyListeners();
  }

  Future<void> _saveLibrary() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/miruryoiki_library.json');

      final data = _series.map((s) => s.toJson()).toList();
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving library: $e');
    }
  }

  Future<void> refreshEpisode(Episode episode) async {
    episode.watchedPercentage = _mpcTracker.getWatchPercentage(episode.path);
    episode.watched = _mpcTracker.isWatched(episode.path);
    await _saveLibrary();
    notifyListeners();
  }

  void markEpisodeWatched(Episode episode, {bool watched = true}) {
    episode.watched = watched;
    episode.watchedPercentage = watched ? 1.0 : 0.0;
    _saveLibrary();
    notifyListeners();
  }

  void markSeasonWatched(Season season, {bool watched = true}) {
    for (final episode in season.episodes) {
      episode.watched = watched;
      episode.watchedPercentage = watched ? 1.0 : 0.0;
    }
    _saveLibrary();
    notifyListeners();
  }

  void markSeriesWatched(Series series, {bool watched = true}) {
    for (final season in series.seasons) {
      for (final episode in season.episodes) {
        episode.watched = watched;
        episode.watchedPercentage = watched ? 1.0 : 0.0;
      }
    }

    for (final episode in series.relatedMedia) {
      episode.watched = watched;
      episode.watchedPercentage = watched ? 1.0 : 0.0;
    }

    _saveLibrary();
    notifyListeners();
  }

  Series? getSeriesByPath(String seriesPath) {
    for (final series in _series) {
      if (series.path == seriesPath) //
        return series;
    }
    return null;
  }
}
