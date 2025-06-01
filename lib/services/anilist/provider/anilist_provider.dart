import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../models/anilist/user_list.dart';
import '../../../../models/anilist/anime.dart';
import '../../../models/anilist/mutation.dart';
import '../../../utils/time_utils.dart';
import '../../../utils/path_utils.dart';
import '../../../utils/logging.dart';
import '../queries.dart';

// Include all the parts
part 'initialization.dart';
part 'authentication.dart';
part 'lists_management.dart';
part 'anime_cache.dart';
part 'mutations.dart';
part 'background_sync.dart';

class AnilistProvider extends ChangeNotifier {
  final AnilistService _anilistService;

  AnilistUser? _currentUser;
  Map<String, AnilistUserList> _userLists = {};
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isOffline = false;

  bool _isReady = false;
  bool get isReady => _isReady;

  /// Cache
  DateTime? _lastListsCacheTime;
  Map<int, AnilistAnime> _animeCache = {};
  List<AnilistMutation> _pendingMutations = [];
  final int maxCachedAnimeCount = 200; // TODO make this configurable
  final Duration animeCacheValidityPeriod = Duration(days: 7); // TODO make this configurable
  final String lists_cache = 'anilist_lists_cache';
  final String user_cache = 'anilist_user_cache';
  final String anime_cache = 'anilist_anime_cache.json';
  final String mutations_queue = 'anilist_mutations_queue.json';

  // Background sync
  Timer? _syncTimer;
  bool _isSyncing = false;
  final Duration _syncInterval = Duration(minutes: 15);
  ValueNotifier<String?> syncStatusMessage = ValueNotifier(null);

  AnilistProvider({AnilistService? anilistService}) : _anilistService = anilistService ?? AnilistService();

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

  /// Get the user series lists
  Map<String, AnilistUserList> get userLists => _userLists;

  // Last time lists were cached
  DateTime? get lastListsCacheTime => _lastListsCacheTime;

  @override
  void dispose() {
    _syncTimer?.cancel();
    syncStatusMessage.dispose();
    stopBackgroundSync();
    super.dispose();
  }
}
