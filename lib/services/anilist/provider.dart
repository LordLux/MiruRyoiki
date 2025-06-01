import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import '../../../models/anilist/user_list.dart';
import '../../../models/anilist/anime.dart';
import '../../utils/time_utils.dart';
import '../../utils/path_utils.dart';
import '../../utils/logging.dart';
import '../../enums.dart';
import 'queries.dart';

class AnilistProvider extends ChangeNotifier {
  final AnilistService _anilistService;

  AnilistUser? _currentUser;
  Map<String, AnilistUserList> _userLists = {};
  Map<int, AnilistAnime> _animeCache = {};
  DateTime? _lastListsCacheTime;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isOffline = false;

  bool _isReady = false;
  bool get isReady => _isReady;

  final String lists_cache = 'anilist_lists_cache';
  final String user_cache = 'anilist_user_cache';

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

  /// Initialize the provider
  Future<void> initialize() async {
    logDebug('2 Initializing AnilistService...');
    _isLoading = true;
    notifyListeners();

    // Check connectivity
    final isOnline = await _checkConnectivity();

    _isInitialized = await _anilistService.initialize();
    if (isOnline) {
      if (_isInitialized && isLoggedIn) {
        await _loadUserData();
        // Cache the data after successful fetch
        await _saveListsToCache();
      }
    } else {
      logInfo('Offline mode detected, using cached data');

      if (_isInitialized && isLoggedIn) {
        // Try to load user from cache
        await _loadCurrentUserFromCache();

        // Try to load lists from cache
        if (!await _loadListsFromCache()) //
          logWarn('Failed to load Anilist lists from cache while offline');
      }
    }

    _isReady = true;
    _isLoading = false;
    notifyListeners();
    logTrace('2 AnilistProvider initialized: $_isInitialized${isOnline ? '' : ' (Offline)'}');
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

    if (_currentUser != null) await _saveCurrentUserToCache();

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

    // Check connectivity
    final isOnline = await _checkConnectivity();

    if (isOnline) {
      await _loadUserLists();
      // Cache after refresh
      await _saveListsToCache();
    } else {
      // Try loading from cache if offline
      if (!await _loadListsFromCache()) //
        logWarn('Failed to refresh lists: Offline and no cache available');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Save user lists to local cache
  Future<void> _saveListsToCache() async {
    if (!isLoggedIn || _userLists.isEmpty) return;

    try {
      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/$lists_cache.json');

      // Convert user lists to JSON
      final Map<String, dynamic> cache = {
        'timestamp': now.toIso8601String(),
        'userId': _currentUser?.id,
        'lists': _userLists.map((key, list) {
          return MapEntry(key, {
            'name': list.name,
            'status': list.status?.name_,
            'isCustomList': list.isCustomList,
            'entries': list.entries.map((entry) => entry.toJson()).toList(),
          });
        }),
      };

      await file.writeAsString(jsonEncode(cache));
      _lastListsCacheTime = DateTime.now();
      logDebug('Anilist lists cached successfully');
    } catch (e) {
      logErr('Error caching Anilist lists', e);
    }
  }

  /// Load user lists from local cache
  Future<bool> _loadListsFromCache() async {
    try {
      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/$lists_cache.json');

      if (!await file.exists()) {
        logDebug('No Anilist lists cache found');
        return false;
      }

      final cacheJson = await file.readAsString();
      final cache = jsonDecode(cacheJson) as Map<String, dynamic>;

      // Check if cache is for current user
      if (cache['userId'] != _currentUser?.id) {
        logDebug('Cached lists belong to different user');
        return false;
      }

      // Parse timestamp
      _lastListsCacheTime = DateTime.parse(cache['timestamp']);

      // Parse lists
      final cachedLists = cache['lists'] as Map<String, dynamic>;
      final Map<String, AnilistUserList> parsedLists = {};

      cachedLists.forEach((key, value) {
        final entries = (value['entries'] as List).map((e) => AnilistMediaListEntry.fromJson(e)).toList();

        parsedLists[key] = AnilistUserList(
          entries: entries,
          name: value['name'],
          status: value['status']?.toString().toListStatus(),
        );
      });

      _userLists = parsedLists;
      logDebug('Loaded Anilist lists from cache ($_lastListsCacheTime)');
      notifyListeners();
      return true;
    } catch (e) {
      logErr('Error loading Anilist lists from cache', e);
      return false;
    }
  }

  /// Check network connectivity
  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('anilist.co');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _isOffline = false;
        return true;
      }
    } catch (_) {
      _isOffline = true;
    }
    return !_isOffline;
  }

  /// Load current user from cache
  Future<bool> _loadCurrentUserFromCache() async {
    try {
      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/$user_cache.json');

      if (!await file.exists()) {
        logDebug('No Anilist user cache found');
        return false;
      }

      final userJson = await file.readAsString();
      final userData = jsonDecode(userJson) as Map<String, dynamic>;

      _currentUser = AnilistUser.fromJson(userData);
      logDebug('Loaded Anilist user from cache (${_currentUser?.name})');
      return true;
    } catch (e) {
      logErr('Error loading Anilist user from cache', e);
      return false;
    }
  }

  /// Save current user to cache
  Future<void> _saveCurrentUserToCache() async {
    if (!isLoggedIn || _currentUser == null) return;

    try {
      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/$user_cache.json');

      await file.writeAsString(jsonEncode(_currentUser!.toJson()));
      logDebug('Anilist user cached successfully');
    } catch (e) {
      logErr('Error caching Anilist user', e);
    }
  }
}
