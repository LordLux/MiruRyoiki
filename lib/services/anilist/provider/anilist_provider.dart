import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import '../../../../models/anilist/user_list.dart';
import '../../../../models/anilist/anime.dart';
import '../../../main.dart';
import '../../../manager.dart';
import '../../../models/anilist/mutation.dart';
import '../../../models/notification.dart';
import '../../../utils/time_utils.dart';
import '../../../utils/path_utils.dart';
import '../../../utils/logging.dart';
import '../../library/library_provider.dart';
import '../../navigation/show_info.dart';
import '../../connectivity/connectivity_service.dart';
import '../queries/anilist_service.dart';

// Include all the parts
part 'initialization.dart';
part 'authentication.dart';
part 'lists_management.dart';
part 'anime_cache.dart';
part 'mutations.dart';
part 'background_sync.dart';

class AnilistProvider extends ChangeNotifier with WidgetsBindingObserver {
  final AnilistService _anilistService;
  final ConnectivityService _connectivityService;

  AnilistUser? _currentUser;
  Map<String, AnilistUserList> _userLists = {};
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isOffline = false;

  bool _isReady = false;
  bool get isReady => _isReady;

  // Background sync
  Timer? _syncTimer;
  Timer? _userDataRefreshTimer;
  final Duration _syncInterval = const Duration(minutes: 30);
  bool _isSyncing = false;
  ValueNotifier<String?> syncStatusMessage = ValueNotifier(null);
  DateTime? _lastUserDataRefreshTime;
  DateTime? _lastNotificationRefresh;

  /// Cache
  DateTime? _lastListsCacheTime;
  Map<int, AnilistAnime> _animeCache = {};
  List<AnilistMutation> _pendingMutations = [];
  final int maxCachedAnimeCount = 250; // TODO make this configurable
  final Duration animeCacheValidityPeriod = Duration(days: 7); // TODO make this configurable
  
  /// Upcoming episodes cache
  Map<int, AiringEpisode?> _upcomingEpisodesCache = {};
  DateTime? _lastUpcomingEpisodesFetch;
  final Duration upcomingEpisodesCacheValidityPeriod = Duration(minutes: 15); // Cache for 15 minutes
  
  // Prevent duplicate requests
  Future<Map<int, AiringEpisode?>>? _currentUpcomingEpisodesRequest;
  final String lists_cache = 'anilist_lists_cache';
  final String user_cache = 'anilist_user_cache';
  final String anime_cache = 'anilist_anime_cache.json';
  final String mutations_queue = 'anilist_mutations_queue.json';

  AnilistProvider({AnilistService? anilistService}) : 
    _anilistService = anilistService ?? AnilistService(),
    _connectivityService = ConnectivityService() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Whether the provider has been initialized
  bool get isInitialized => _isInitialized;

  /// Whether the provider is currently loading data
  bool get isLoading => _isLoading;

  /// Whether the user is logged in
  bool get isLoggedIn => _anilistService.isLoggedIn;

  /// Get the current user and their lists
  AnilistUser? get currentUser => _currentUser;

  // Connectivity status
  bool get isOffline => _isOffline;

  /// Get the user series lists in the format
  ///
  /// { `API Name`: `AUL(Local Name)` }
  Map<String, AnilistUserList> get userLists => _userLists;

  // Last time lists were cached
  DateTime? get lastListsCacheTime => _lastListsCacheTime;

  @override
  void dispose() {
    _syncTimer?.cancel();
    syncStatusMessage.dispose();
    stopBackgroundSync();
    WidgetsBinding.instance.removeObserver(this);
    _connectivityService.isOnlineNotifier.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    handleAppLifecycleStateChange(state);
  }
}
