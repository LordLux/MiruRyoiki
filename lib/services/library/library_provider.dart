import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:provider/provider.dart';

import '../../database/daos/series_dao.dart';
import '../../database/database.dart';
import '../../enums.dart';
import '../../functions.dart';
import '../../main.dart';
import '../../manager.dart';
import '../../models/anilist/anime.dart';
import '../../models/anilist/mapping.dart';
import '../../models/episode.dart';
import '../../models/series.dart';
import '../../services/anilist/linking.dart';
import '../../settings.dart';
import '../../theme.dart';
import '../anilist/provider/anilist_provider.dart';
import '../anilist/queries/anilist_service.dart';
import '../file_system/cache.dart';
import '../file_system/file_scanner.dart';
import '../../services/player_trackers/mpchc.dart';
import '../../services/navigation/show_info.dart';
import '../../utils/logging.dart';
import '../../utils/path_utils.dart';
import '../../utils/time_utils.dart';
import 'library_scanning.dart';

// Include all the parts
part 'initialization.dart';
part 'persistence.dart';
part 'scanning.dart';
part 'series_management.dart';
part 'watch_tracking.dart';
part 'anilist_integration.dart';

class Library with ChangeNotifier {
  List<Series> _series = [];
  String? _libraryPath;
  bool _isLoading = false;
  late final FileScanner _fileScanner;
  late final MPCHCTracker _mpcTracker;
  final SettingsManager _settings;
  late final AppDatabase _db = AppDatabase();
  late final SeriesDao seriesDao = SeriesDao(_db);
  LibraryScannerProgress? _scanProgress;

  bool _initialized = false;
  bool get initialized => _initialized;
  bool _cacheValidated = false;

  Timer? _autoSaveTimer;
  Timer? _saveDebouncer;

  List<Series> get series => List.unmodifiable(_series);
  String? get libraryPath => _libraryPath;
  bool get isLoading => _isLoading;

  static const String settingsFileName = 'settings';
  static const String miruryoikiLibrary = 'library';

  Library(this._settings) {
    _fileScanner = FileScanner();
    _mpcTracker = MPCHCTracker();
    _mpcTracker.onWatchStatusChanged = _updateSpecificEpisodes;
  }

  @override
  void dispose() {
    _mpcTracker.dispose();
    _autoSaveTimer?.cancel();
    _saveDebouncer?.cancel();
    super.dispose();
  }
}
