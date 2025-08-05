part of 'anilist_provider.dart';

extension AnilistProviderInitialization on AnilistProvider {
  /// Initialize the provider
  Future<void> initialize() async {
    logDebug('\n2 | Initializing AnilistService...', splitLines: true);
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
      logInfo('   2 | Offline mode, using cached data');

      if (_isInitialized && isLoggedIn) {
        // Try to load user and lists from cache
        await _loadCurrentUserFromCache();
        if (!await _loadListsFromCache()) //
          logWarn('   2 | Failed to load Anilist lists from cache while offline');
      }
    }

    // Start background sync
    startBackgroundSync();

    _isReady = true;
    _isLoading = false;
    notifyListeners();
    logTrace('2 | AnilistProvider initialized: $_isInitialized${isOnline ? '' : ' (Offline)'}');
  }

  // DISPOSE IS IN MAIN FILE

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
      final result = await Future.any([
        InternetAddress.lookup('anilist.co'),
        Future.delayed(Duration(seconds: 15), () => false),
      ]);

      if (result != false && (result as List<InternetAddress>).isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _isOffline = false;
        return true; // is online
      }
      return false; // is offline
    } catch (_) {
      _isOffline = true; // is offline
    }
    return !_isOffline;
  }
}
