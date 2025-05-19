import 'package:flutter/material.dart';
import '../../utils/logging.dart';
import 'queries.dart';
import '../../../models/anilist/anime.dart';
import '../../../models/anilist/user_list.dart';

class AnilistProvider extends ChangeNotifier {
  final AnilistService _anilistService;

  AnilistUser? _currentUser;
  Map<String, AnilistUserList> _userLists = {};
  Map<int, AnilistAnime> _animeCache = {};
  bool _isInitialized = false;
  bool _isLoading = false;

  bool _isReady = false;
  bool get isReady => _isReady;

  AnilistProvider({AnilistService? anilistService}) : _anilistService = anilistService ?? AnilistService();

  /// Whether the provider has been initialized
  bool get isInitialized => _isInitialized;

  /// Whether the provider is currently loading data
  bool get isLoading => _isLoading;

  /// Whether the user is logged in
  bool get isLoggedIn => _anilistService.isLoggedIn;

  /// Get the current user and their lists
  AnilistUser? get currentUser => _currentUser;

  /// Get the user series lists
  Map<String, AnilistUserList> get userLists => _userLists;

  /// Initialize the provider
  Future<void> initialize() async {
    logDebug('2 Initializing AnilistService...');
    _isLoading = true;
    notifyListeners();

    _isInitialized = await _anilistService.initialize();

    if (_isInitialized && isLoggedIn) //
      await _loadUserData();

    _isReady = true;
    _isLoading = false;
    notifyListeners();
    logTrace('2 AnilistProvider initialized: $_isInitialized');
  }

  Future<bool> ensureInitialized() async {
    if (!_isReady && !_isLoading) {
      await initialize();
      return true;
    }
    return _isReady;
  }

  /// Initiate the login flow
  Future<void> login() async {
    await _anilistService.login();
    notifyListeners();
  }

  /// Handle auth callback
  Future<bool> handleAuthCallback(Uri callbackUri) async {
    _isLoading = true;
    notifyListeners();

    final success = await _anilistService.handleAuthCallback(callbackUri);

    if (success) //
      await _loadUserData();

    _isLoading = false;
    notifyListeners();

    return success;
  }

  /// Load user data and lists
  Future<void> _loadUserData() async {
    _currentUser = await _anilistService.getCurrentUser();
    await _loadUserLists();
  }

  Future<void> _loadUserLists() async {
    _userLists = await _anilistService.getUserAnimeLists(userId: _currentUser?.id);
  }

  /// Logout from Anilist
  Future<void> logout() async {
    await _anilistService.logout();
    _currentUser = null;
    _userLists = {};
    _animeCache = {};
    notifyListeners();
  }

  /// Get anime details, using cache if available
  Future<AnilistAnime?> getAnimeDetails(int id) async {
    // Check cache first
    if (_animeCache.containsKey(id)) {
      return _animeCache[id];
    }

    final anime = await _anilistService.getAnimeDetails(id);

    if (anime != null) {
      _animeCache[id] = anime;
    }

    return anime;
  }

  /// Search for anime by title
  Future<List<AnilistAnime>> searchAnime(String query) async {
    final results = await _anilistService.searchAnime(query);

    // Cache results
    for (final anime in results) {
      _animeCache[anime.id] = anime;
    }

    return results;
  }

  /// Refresh user lists
  Future<void> refreshUserLists() async {
    if (!isLoggedIn) return;

    _isLoading = true;
    notifyListeners();

    await _loadUserLists();

    _isLoading = false;
    notifyListeners();
  }
}
