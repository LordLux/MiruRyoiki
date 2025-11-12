part of 'anilist_provider.dart';

extension AnilistProviderAuthentication on AnilistProvider {
  /// Initiate the login flow
  Future<void> login() async {
    await _anilistService.login();
    notifyListeners();
  }

  /// Cancel the login attempt
  void cancelLogin() {
    _isLoading = false;
    notifyListeners();
    logInfo('User cancelled Anilist login attempt');
  }

  /// Handle auth callback
  Future<bool> handleAuthCallback(Uri callbackUri) async {
    _isLoading = true;
    notifyListeners();

    logInfo('Handling Anilist auth callback: $callbackUri');

    final success = await _anilistService.handleAuthCallback(callbackUri);

    // User data will be loaded during initializeOnlineFeatures
    // if (success) {
    //   if (_connectivityService.isInitialized)
    //     await _loadUserData();
    //   else
    //     logInfo('Connectivity service not initialized yet, deferring user data loading');
    // }

    _isLoading = false;
    notifyListeners();

    return success;
  }

  /// Load user data and lists
  Future<bool> _loadUserData() async {
    _currentUser = await _anilistService.getCurrentUser();

    // Also load detailed user data
    if (_currentUser != null) {
      final userData = await _anilistService.getCurrentUserData();
      // Update the current user with the detailed data
      if (userData != null) {
        _currentUser = AnilistUser(
          id: _currentUser!.id,
          name: _currentUser!.name,
          avatar: _currentUser!.avatar,
          bannerImage: _currentUser!.bannerImage,
          userData: userData,
        );
      }

      await _saveCurrentUserToCache();
    }

    return await _loadUserLists();
  }

  Future<bool> _loadUserLists() async {
    final newLists = await _anilistService.getUserAnimeLists(userId: _currentUser?.id, userName: _currentUser?.name);

    // Only update the user lists if we successfully got data
    // This prevents overriding existing data with empty results on API failure
    if (newLists.isNotEmpty) {
      _userLists = newLists;
      notifyListeners();
      Manager.setState();
      return true;
    } else if (_userLists.isEmpty) {
      // If we have no existing data and got empty results, still update
      // (this handles the case where the user truly has no lists)
      _userLists = newLists;
      notifyListeners();
      Manager.setState();
      return true;
    } else {
      logWarn('Failed to load user lists - preserving existing data (${_userLists.length} lists)');
      return false;
    }
  }

  Future<void> refreshUserData() async {
    if (!isLoggedIn) return;

    final lastRefreshDuration = _lastUserDataRefreshTime != null //
        ? now.difference(_lastUserDataRefreshTime!)
        : const Duration(minutes: 1); // Default to a long time if null

    if (lastRefreshDuration.inSeconds < 15) {
      _isLoading = false;
      return;
    }
    _lastUserDataRefreshTime = now;

    _isLoading = true;
    notifyListeners();

    final isOnline = await _checkConnectivity();

    if (isOnline) {
      // Get basic user info
      final basicUser = await _anilistService.getCurrentUser();

      if (basicUser != null) {
        try {
          // Get detailed user data
          final userData = await _anilistService.getCurrentUserData();

          if (userData != null) {
            // Update the current user with the detailed data
            _currentUser = AnilistUser(
              id: basicUser.id,
              name: basicUser.name,
              avatar: basicUser.avatar,
              bannerImage: basicUser.bannerImage,
              userData: userData,
            );
          } else {
            logWarn('Failed to load detailed user data');
          }

          await _saveCurrentUserToCache();
        } catch (e, stackTrace) {
          logErr('Error refreshing user data', e, stackTrace);
        }
      }
    } else {
      // If offline, try to load from cache
      await _loadCurrentUserFromCache();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Logout from Anilist
  Future<void> logout() async {
    await _anilistService.logout();
    _currentUser = null;
    _userLists = {};
    _animeCache = {};
    _upcomingEpisodesCache = {};
    _lastUpcomingEpisodesFetch = null;
    notifyListeners();
  }

  /// Load current user from database
  Future<bool> _loadCurrentUserFromCache() async {
    try {
      // Get database instance from context
      final library = Provider.of<Library>(rootNavigatorKey.currentContext!, listen: false);
      final userCacheDao = library.database.userCacheDao;

      _currentUser = await userCacheDao.getCachedUser();
      
      if (_currentUser != null) {
        logDebug('Loaded Anilist user from database (${_currentUser?.name})');
        return true;
      }
      return false;
    } catch (e) {
      logErr('Error loading Anilist user from database', e);
      return false;
    }
  }


  /// Save current user to database cache
  Future<void> _saveCurrentUserToCache() async {
    if (!isLoggedIn || _currentUser == null) return;

    try {
      // Get database instance from context
      final library = Provider.of<Library>(rootNavigatorKey.currentContext!, listen: false);
      final userCacheDao = library.database.userCacheDao;

      await userCacheDao.upsertUser(_currentUser!);
      logTrace('Anilist user cached successfully to database');
    } catch (e) {
      logErr('Error caching Anilist user to database', e);
    }
  }
}
