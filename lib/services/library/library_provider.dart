import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/functions.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import '../../models/mapping_target.dart';
import '../../models/season.dart';
import '../../utils/file.dart';
import '../players/player_manager.dart';
import '../players/factory.dart';
import '../../models/players/mediastatus.dart';

import '../../database/daos/series_dao.dart';
import '../../database/database.dart';
import '../../enums.dart';
import '../../main.dart';
import '../../manager.dart';
import '../../models/anilist/anime.dart';
import '../../models/anilist/mapping.dart';
import '../../models/episode.dart';
import '../../models/metadata.dart';
import '../../models/series.dart';
import '../../services/anilist/linking.dart';
import '../../settings.dart';
import '../../theme.dart';
import '../../widgets/dialogs/splash/progress.dart';
import '../anilist/provider/anilist_provider.dart';
import '../anilist/queries/anilist_service.dart';
import '../anilist/episode_title_service.dart';
import '../file_system/cache.dart';
import '../../services/navigation/show_info.dart';
import '../../utils/color.dart' as color_utils;
import '../../utils/logging.dart';
import '../../utils/path.dart';
import '../../utils/shell.dart';
import '../../utils/time.dart';
import '../isolates/isolate_manager.dart';
import '../isolates/thumbnail_manager.dart';
import '../lock_manager.dart';
import '../processes/monitor.dart' as process_monitor;
import 'hidden_series_service.dart';

// Include all the parts
part 'initialization.dart';
part 'persistence.dart';
part 'scanning.dart';
part 'series_management.dart';
part 'anilist_integration.dart';
part 'media_player_integration.dart';

class Library with ChangeNotifier {
  /// All series in the library
  List<Series> _series = [];

  /// Path to the library directory
  String? _libraryPath;

  /// If a scan is currently in progress
  bool _isScanning = false;

  /// If this is the first scan after selecting a library path
  bool _isInitialScan = false;

  /// (current, total)
  final ValueNotifier<(int, int)?> scanProgress = ValueNotifier(null);

  /// Version counter that increments whenever series data changes
  /// (Used to invalidate their caches when library data updates)
  int _dataVersion = 0;

  //
  // Media player integration fields
  /// Manages media player connections
  PlayerManager? _playerManager;

  /// Timer for periodic connection checks
  Timer? _connectionTimer;

  /// Timer for saving progress
  Timer? _progressSaveTimer;

  /// Timer for forced saves during playback
  Timer? _forcedSaveTimer;

  /// List of detected media players
  final List<DetectedPlayer> _detectedPlayers = [];

  /// Name of the currently connected player
  String? _currentConnectedPlayer;

  /// Subscription to player status updates
  StreamSubscription? _playerStatusSubscription;

  //
  // State tracking for immediate saves
  /// Last file path used for playback
  String? _lastFilePath;

  /// Last known playing state
  bool? _lastPlayingState;

  /// Last episode being played
  Episode? _lastEpisode;

  /// Timestamp of the last immediate save, for throttling
  DateTime? _lastImmediateSaveTime;

  /// Timestamp of when the current playback position was at the last save
  Duration? _lastSavedPosition;

  //
  // Services and utilities
  final SettingsManager _settings;
  late final AppDatabase _db = AppDatabase();
  late final SeriesDao seriesDao = SeriesDao(_db);
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

  String? get libraryDockerPath {
    // Transform something like "C:\Videos\Series" to "/data/Videos/Series"
    return PathString("/data/${PathUtils.removeDriveLetter(PathString(libraryPath!).linux)}").linux;//remove drive letter for docker
  }

  /// Whether the library has been initialized
  bool get initialized => _initialized;

  /// Whether a scan is currently in progress
  bool get isIndexing => _isScanning;

  /// Whether this is the first scan after selecting a library path
  bool get isInitialScan => _isInitialScan; // Also whether shimmer should be shown during scan

  /// Database instance
  AppDatabase get database => _db;

  /// Lock manager instance
  LockManager get lockManager => _lockManager;

  /// Service for managing hidden series
  HiddenSeriesService get hiddenSeriesService => _hiddenSeriesService;

  /// Current version of the series data. Increments whenever series list changes.
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
  Library(this._settings);

  @override
  void dispose() {
    scanProgress.dispose();
    disposeMediaPlayerIntegration();
    super.dispose();
  }
}
