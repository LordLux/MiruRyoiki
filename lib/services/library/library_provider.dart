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
import '../file_system/cache.dart';
import '../../services/navigation/show_info.dart';
import '../../utils/color.dart' as color_utils;
import '../../utils/logging.dart';
import '../../utils/path.dart';
import '../../utils/time.dart';
import '../isolates/isolate_manager.dart';
import '../isolates/thumbnail_manager.dart';
import '../lock_manager.dart';
import '../processes/monitor.dart' as process_monitor;

// Include all the parts
part 'initialization.dart';
part 'persistence.dart';
part 'scanning.dart';
part 'series_management.dart';
part 'anilist_integration.dart';
part 'media_player_integration.dart';

class Library with ChangeNotifier {
  List<Series> _series = [];
  String? _libraryPath;
  bool _isScanning = false;
  final ValueNotifier<(int, int)?> scanProgress = ValueNotifier(null);
  
  // Media player integration fields
  PlayerManager? _playerManager;
  Timer? _connectionTimer;
  Timer? _progressSaveTimer;
  Timer? _forcedSaveTimer;
  // ignore: prefer_final_fields
  List<DetectedPlayer> _detectedPlayers = [];
  String? _currentConnectedPlayer;
  StreamSubscription? _playerStatusSubscription;
  
  // State tracking for immediate saves
  String? _lastFilePath;
  bool? _lastPlayingState;
  Episode? _lastEpisode;
  
  final SettingsManager _settings;
  late final AppDatabase _db = AppDatabase();
  late final SeriesDao seriesDao = SeriesDao(_db);
  late final LockManager _lockManager = LockManager();

  bool _initialized = false;
  bool _cacheValidated = false;

  List<Series> get series => List.unmodifiable(_series);
  String? get libraryPath => _libraryPath;
  bool get initialized => _initialized;
  bool get isIndexing => _isScanning;
  AppDatabase get database => _db;
  LockManager get lockManager => _lockManager;

  static const String settingsFileName = 'settings';
  static const String miruryoikiLibrary = 'library';

  static double progressThreshold = 0.95;

  Library(this._settings);

  @override
  void dispose() {
    scanProgress.dispose();
    disposeMediaPlayerIntegration();
    super.dispose();
  }
}
