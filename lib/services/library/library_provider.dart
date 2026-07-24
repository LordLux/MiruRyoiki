import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/functions.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../../manager.dart';
import '../../models/mapping_target.dart';
import '../../models/season.dart';

import '../../database/daos/series_dao.dart';
import '../../database/database.dart';
import '../../enums.dart';
import '../../main.dart';
import '../../models/anilist/anime.dart';
import '../../models/anilist/mapping.dart';
import '../../models/episode.dart';
import '../../models/series.dart';
import '../players/media_player_monitor.dart';
import 'scanner/scanner_service.dart';
import '../../services/anilist/linking.dart';
import '../../settings.dart';
import '../../theme.dart';
import '../../widgets/dialogs/splash/progress.dart';
import '../anilist/provider/anilist_provider.dart';
import '../anilist/queries/anilist_service.dart';
import '../anilist/episode_title_service.dart';
import '../episode_navigation/anilist_progress_manager.dart';
import '../file_system/cache.dart';
import '../../services/navigation/show_info.dart';
import '../../utils/logging.dart';
import '../../utils/path.dart';
import '../../utils/time.dart';
import '../isolates/thumbnail_manager.dart';
import '../lock_manager.dart';
import 'hidden_series_service.dart';

// Include all the parts
part 'initialization.dart';
part 'persistence.dart';
part 'scanning.dart';
part 'series_management.dart';
part 'anilist_integration.dart';

class Library with ChangeNotifier {
  /// All series in the library
  List<Series> _series = [];

  /// Path to the library directory
  String? _libraryPath;

  /// Version counter that increments whenever series data changes
  /// (Used to invalidate their caches when library data updates)
  int _dataVersion = 0;

  Set<int> _mappedAnilistIds = {};

  /// A set of all Anilist media IDs linked to a mapped local folder across all series
  Set<int> get mappedAnilistIds => _mappedAnilistIds;

  void _rebuildMappedAnilistIds() {
    _mappedAnilistIds = _series
        .expand((series) => series.anilistMappings)
        .map((mapping) => mapping.anilistId)
        .toSet();
  }

  void _incrementDataVersion() {
    _dataVersion++;
    _rebuildMappedAnilistIds();
  }

  /// Set of series paths that have been modified since last save
  final Set<PathString> _dirtySeries = {};
  Timer? _debouncedSaveTimer;
  /// Whether series were deleted since last save
  bool _hasPendingDeletions = false;

  //
  // Services and utilities
  final SettingsManager _settings;
  final AppDatabase _db;
  late final SeriesDao seriesDao;
  late final LockManager _lockManager = LockManager();
  late final HiddenSeriesService _hiddenSeriesService = HiddenSeriesService();

  //
  // State flags
  /// Whether the library has been initialized
  bool _initialized = false;

  /// Whether the cache has been validated
  bool _cacheValidated = false;

  //
  // Getters
  /// Unmodifiable list of all series in the library
  List<Series> get series => List.unmodifiable(_series);

  /// Path to the library directory
  String? get libraryPath => _libraryPath;

  @visibleForTesting
  set libraryPath(String? path) => _libraryPath = path;

  String? get libraryDockerPath {
    // Transform something like "C:\Videos\Series" to "/data/Videos/Series"
    return PathString("${ps}data$ps${PathUtils.removeDriveLetter(PathString(libraryPath!).linux)}").linux;//remove drive letter for docker
  }

  /// Whether the library has been initialized
  bool get initialized => _initialized;

  /// Whether a scan is currently in progress

  /// Whether this is the first scan after selecting a library path

  /// Database instance
  AppDatabase get database => _db;

  /// Lock manager instance
  LockManager get lockManager => _lockManager;

  /// Service for managing hidden series
  HiddenSeriesService get hiddenSeriesService => _hiddenSeriesService;

  /// Current version of the series data
  ///
  /// Increments whenever series list changes
  int get dataVersion => _dataVersion;

  //
  // Static constants
  /// Settings file name
  static const String settingsFileName = 'settings'; //.json

  /// Library directory name
  static const String miruryoikiLibrary = 'library';

  /// Threshold for considering an episode as watched
  static double progressThreshold = 0.95;

  //
  /// Constructor
  Library(this._settings, this._db) {
    seriesDao = SeriesDao(_db);
    _hiddenSeriesService.init(_settings);
  }

  @override
  void dispose() {
    _debouncedSaveTimer?.cancel();
    super.dispose();
  }
}
