import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:miruryoiki/functions.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

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
import '../../services/player_trackers/mpchc.dart';
import '../../services/navigation/show_info.dart';
import '../../utils/logging.dart';
import '../../utils/path_utils.dart';
import '../../utils/time_utils.dart';
import '../isolates/isolate_manager.dart';

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
  bool _isScanning = false;
  final ValueNotifier<(int, int)?> scanProgress = ValueNotifier(null);
  
  late final MPCHCTracker _mpcTracker;
  final SettingsManager _settings;
  late final AppDatabase _db = AppDatabase();
  late final SeriesDao seriesDao = SeriesDao(_db);

  bool _initialized = false;
  bool _cacheValidated = false;
  int _version = 0; // increments on any library content mutation

  List<Series> get series => List.unmodifiable(_series);
  String? get libraryPath => _libraryPath;
  bool get initialized => _initialized;
  bool get isScanning => _isScanning;
  AppDatabase get database => _db;
  int get version => _version;

  static const String settingsFileName = 'settings';
  static const String miruryoikiLibrary = 'library';

  Library(this._settings) {
    _mpcTracker = MPCHCTracker();
    _mpcTracker.onWatchStatusChanged = _updateSpecificEpisodes;
  }

  @override
  void dispose() {
    _mpcTracker.dispose();
    scanProgress.dispose();
    super.dispose();
  }
}
