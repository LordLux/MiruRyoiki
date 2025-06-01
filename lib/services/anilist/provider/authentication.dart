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