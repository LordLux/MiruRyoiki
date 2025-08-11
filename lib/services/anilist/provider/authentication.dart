// ignore_for_file: invalid_use_of_protected_member

part of 'anilist_provider.dart';

extension AnilistProviderAuthentication on AnilistProvider {
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

    await _loadUserLists();
  }

  Future<void> _loadUserLists() async {
    _userLists = await _anilistService.getUserAnimeLists(userId: _currentUser?.id);
  }

  Future<void> refreshUserData() async {
    if (!isLoggedIn) return;

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
    notifyListeners();
  }

  /// Load current user from cache
  Future<bool> _loadCurrentUserFromCache() async {
    try {
      final dir = miruRyoikiSaveDirectory;
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
      final dir = miruRyoikiSaveDirectory;
      final file = File('${dir.path}/$user_cache.json');

      await file.writeAsString(jsonEncode(_currentUser!.toJson()));
      logDebug('Anilist user cached successfully');
    } catch (e) {
      logErr('Error caching Anilist user', e);
    }
  }
}
