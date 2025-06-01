import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import '../../../models/anilist/user_list.dart';
import '../../../models/anilist/anime.dart';
import '../../models/anilist/mutation.dart';
import '../../utils/time_utils.dart';
import '../../utils/path_utils.dart';
import '../../utils/logging.dart';
import '../../enums.dart';
import 'queries.dart';

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

  /// Initialize the provider
  Future<void> initialize() async {
    logDebug('2 Initializing AnilistService...');
    _isLoading = true;
    notifyListeners();

    // Load cached anime first to ensure data availability even offline
    await loadAnimeCacheFromStorage();

    // Load pending mutations from disk
    await loadMutationsQueue();

    // Check connectivity
    final isOnline = await _checkConnectivity();

    _isInitialized = await _anilistService.initialize();
    if (isOnline) {
      if (_isInitialized && isLoggedIn) {
        await _loadUserData();
        await _saveListsToCache();
      }
    } else {
      logInfo('Offline mode, using cached data');

      if (_isInitialized && isLoggedIn) {
        // Try to load user and lists from cache
        await _loadCurrentUserFromCache();
        if (!await _loadListsFromCache()) //
          logWarn('Failed to load Anilist lists from cache while offline');
      }
    }

    // Start background sync
    startBackgroundSync();

    _isReady = true;
    _isLoading = false;
    notifyListeners();
    logTrace('2 AnilistProvider initialized: $_isInitialized${isOnline ? '' : ' (Offline)'}');
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    syncStatusMessage.dispose();
    stopBackgroundSync();
    super.dispose();
  }

  /// Ensure the provider is initialized
  Future<bool> ensureInitialized() async {
    if (!_isReady && !_isLoading) {
      await initialize();
      return true;
    }
    return _isReady;
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
  Future<AnilistAnime?> getAnimeDetails(int id, {bool forceRefresh = false}) async {
    // Check cache first
    if (!forceRefresh && _animeCache.containsKey(id)) //
      return _animeCache[id];

    if (!_isOffline) {
      try {
        final anime = await _anilistService.getAnimeDetails(id);
        if (anime != null) {
          _animeCache[id] = anime;
          // Save to disk periodically
          saveAnimeCacheToStorage();
        }
        return anime;
      } catch (e) {
        logErr('Error fetching anime details online', e);
        // Continue with cached version if available
      }
    }

    // If we're offline or the fetch failed, return cached version
    return _animeCache[id];
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
      _lastListsCacheTime = now;
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

      _lastListsCacheTime = DateTime.parse(cache['timestamp']);

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

  //

  //

  //

  //

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

  //

  //

  //

  //

  /// Save anime details to persistent cache
  Future<void> saveAnimeCacheToStorage() async {
    try {
      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/$anime_cache');

      // Sort by MRU and limit to maxCachedAnimeCount
      final sortedCache = Map.fromEntries(_animeCache.entries.take(maxCachedAnimeCount).map((e) => MapEntry(e.key.toString(), {
            'data': e.value.toJson(),
            'timestamp': now.toIso8601String(),
          })));

      await file.writeAsString(jsonEncode(sortedCache));
      logDebug('Cached ${sortedCache.length} anime details to disk');
    } catch (e) {
      logErr('Error caching anime details', e);
    }
  }

  /// Load anime details from persistent cache
  Future<void> loadAnimeCacheFromStorage() async {
    try {
      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/$anime_cache');

      if (!await file.exists()) {
        logDebug('No anime cache file found');
        return;
      }

      final cacheJson = await file.readAsString();
      final cache = jsonDecode(cacheJson) as Map<String, dynamic>;

      for (final entry in cache.entries) {
        try {
          final animeId = int.parse(entry.key);
          final data = entry.value as Map<String, dynamic>;
          final animeData = data['data'] as Map<String, dynamic>;
          final timestamp = DateTime.parse(data['timestamp'] as String);

          // Check if cache is still valid
          if (now.difference(timestamp) <= animeCacheValidityPeriod) {
            _animeCache[animeId] = AnilistAnime.fromJson(animeData);
          }
        } catch (e) {
          logErr('Error parsing cached anime: ${entry.key}', e);
        }
      }

      logDebug('Loaded ${_animeCache.length} anime from cache');
    } catch (e) {
      logErr('Error loading anime cache', e);
    }
  }

  //

  //

  //

  //

  /// Save pending mutations to disk
  Future<void> saveMutationsQueue() async {
    try {
      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/$mutations_queue');

      final mutations = _pendingMutations.map((m) => m.toJson()).toList();
      await file.writeAsString(jsonEncode(mutations));

      logDebug('Saved ${mutations.length} pending mutations to disk');
    } catch (e) {
      logErr('Error saving mutations queue', e);
    }
  }

  /// Load pending mutations from disk
  Future<void> loadMutationsQueue() async {
    try {
      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/$mutations_queue');

      if (!await file.exists()) {
        logDebug('No mutations queue file found');
        return;
      }

      final queueJson = await file.readAsString();
      final queueData = jsonDecode(queueJson) as List;

      _pendingMutations = queueData.map((item) => AnilistMutation.fromJson(item)).toList();

      logDebug('Loaded ${_pendingMutations.length} pending mutations from disk');
    } catch (e) {
      logErr('Error loading mutations queue', e);
    }
  }

  /// Queue a mutation for later sync
  Future<void> queueMutation(String type, int mediaId, Map<String, dynamic> changes) async {
    final mutation = AnilistMutation(
      type: type,
      mediaId: mediaId,
      changes: changes,
    );

    _pendingMutations.add(mutation);
    await saveMutationsQueue();

    _applyMutationToLocalCache(mutation);

    notifyListeners();
  }

  /// Apply a mutation to the local cache
  void _applyMutationToLocalCache(AnilistMutation mutation) {
    for (final list in _userLists.values) {
      final entryIndex = list.entries.indexWhere((e) => e.mediaId == mutation.mediaId);
      if (entryIndex >= 0 && entryIndex < list.entries.length) {
        final entry = list.entries[entryIndex];
        final nowDate = now.millisecondsSinceEpoch ~/ 1000;

        switch (mutation.type) {
          // TODO use enum for mutation types
          case 'progress':
            final newProgress = mutation.changes['progress'] as int?;
            if (newProgress != null) {
              final updatedEntry = entry.copyWith(
                progress: newProgress,
                updatedAt: nowDate,
              );

              list.entries[entryIndex] = updatedEntry;
            }
            break;

          case 'status':
            final newStatus = (mutation.changes['status'] as String?)?.toListStatus();
            if (newStatus != null) {
              final updatedEntry = entry.copyWith(
                status: newStatus,
                updatedAt: nowDate,
              );

              list.entries[entryIndex] = updatedEntry;
            }
            break;

          case 'score':
            final newScore = mutation.changes['score'] as int?;
            if (newScore != null) {
              final updatedEntry = entry.copyWith(
                score: newScore,
                updatedAt: nowDate,
              );

              list.entries[entryIndex] = updatedEntry;
            }
            break;

          // TODO Handle other mutation types
        }

        _saveListsToCache();
        return;
      }
    }
  }

  /// Update progress for an anime (works online or offline)
  Future<bool> updateProgress(int mediaId, int progress) async {
    if (!_isOffline) {
      try {
        // Try to update online
        final success = await _anilistService.updateProgress(mediaId, progress);
        if (success) {
          // Update local cache and return
          await refreshUserLists();
          return true;
        }
      } catch (e) {
        logErr('Error updating progress online', e);
        // Fall through to offline queue
      }
    }

    // Queue for later if offline or online update failed
    await queueMutation('progress', mediaId, {'progress': progress});
    return true; // Return true since we've queued it
  }

  /// Update status for an anime (works online or offline)
  Future<bool> updateStatus(int mediaId, AnilistListStatus status) async {
    if (!_isOffline) {
      try {
        // Try to update online
        final success = await _anilistService.updateStatus(mediaId, status);
        if (success) {
          // Update local cache and return
          await refreshUserLists();
          return true;
        }
      } catch (e) {
        logErr('Error updating status online', e);
        // Fall through to offline queue
      }
    }

    // Queue for later if offline or online update failed
    await queueMutation('status', mediaId, {'status': status.name_});
    return true; // Return true since we've queued it
  }

  //

  //

  //

  //

  /// Start the background sync service
  void startBackgroundSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) => _performBackgroundSync());

    // Also perform an immediate sync
    _performBackgroundSync();
  }

  /// Stop the background sync service
  void stopBackgroundSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Perform a background sync operation
  Future<void> _performBackgroundSync() async {
    // Don't start a new sync if one is already in progress
    if (_isSyncing) return;

    _isSyncing = true;
    try {
      // Check connectivity first
      final isOnline = await _checkConnectivity();
      if (!isOnline) {
        _isSyncing = false;
        return;
      }

      // We're online, notify listeners about connectivity change if it was offline before
      if (_isOffline) {
        _isOffline = false;
        notifyListeners();
      }

      // Process pending mutations
      await processPendingMutations();

      // Refresh user lists if they're stale
      if (_lastListsCacheTime == null || now.difference(_lastListsCacheTime!) > Duration(hours: 3)) {
        syncStatusMessage.value = 'Refreshing Anilist data...';
        await _loadUserLists();
        syncStatusMessage.value = 'Anilist data updated';
        await Future.delayed(Duration(seconds: 3));
        syncStatusMessage.value = null;
      }
    } catch (e) {
      logErr('Error during background sync', e);
      syncStatusMessage.value = 'Sync error: ${e.toString()}';
      await Future.delayed(Duration(seconds: 5));
      syncStatusMessage.value = null;
    } finally {
      _isSyncing = false;
    }
  }

  /// Process all pending mutations
  Future<void> processPendingMutations() async {
    if (_pendingMutations.isEmpty) return;

    // Create a copy to avoid issues if new mutations are added during processing
    final mutations = List<AnilistMutation>.from(_pendingMutations);
    int successCount = 0;

    syncStatusMessage.value = 'Syncing changes...';

    for (final mutation in mutations) {
      try {
        bool success = false;

        switch (mutation.type) {
          // TODO use enum for mutation types
          case 'progress':
            final progress = mutation.changes['progress'] as int?;
            if (progress != null) //
              success = await _anilistService.updateProgress(mutation.mediaId, progress);

            break;

          case 'status':
            final statusStr = mutation.changes['status'] as String?;
            if (statusStr != null) {
              final status = statusStr.toListStatus();
              if (status != null) //
                success = await _anilistService.updateStatus(mutation.mediaId, status);
            }
            break;

          case 'score':
            final score = mutation.changes['score'] as int?;
            if (score != null) //
              success = await _anilistService.updateScore(mutation.mediaId, score);

            break;

          // TODO Handle other mutation types
        }

        if (success) {
          _pendingMutations.remove(mutation);
          successCount++;
        }
      } catch (e) {
        logErr('Error processing mutation', e);
        // Keep the mutation in the queue to try again later
      }
    }

    // Save the updated queue
    if (successCount > 0) {
      await saveMutationsQueue();

      // Refresh lists to ensure consistency
      await _loadUserLists();

      syncStatusMessage.value = 'Synced $successCount changes';
      await Future.delayed(Duration(seconds: 3));
      syncStatusMessage.value = null;
    }
  }

  /// Update score for an anime (works online or offline)
  Future<bool> updateScore(int mediaId, int score) async {
    if (!_isOffline) {
      try {
        final success = await _anilistService.updateScore(mediaId, score);
        if (success) {
          await refreshUserLists();
          return true;
        }
      } catch (e) {
        logErr('Error updating score online', e);
      }
    }

    await queueMutation('score', mediaId, {'score': score});
    return true;
  }
}
