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

    final hasCredentials = await _anilistService.initialize();
    if (hasCredentials) {
      await _loadCurrentUserFromCache();
      if (!await _loadListsFromCache()) {
        logWarn('   2 | Could not load Anilist lists from cache during offline init.');
      }
    }

    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
    logTrace('2 | AnilistProvider initialization complete.');
  }

  /// Completes initialization by fetching live data from Anilist API and starting sync services.
  Future<void> initializeOnlineFeatures() async {
    logDebug('\n_ | Initializing AnilistService (Online Features)...', splitLines: true);
    _isLoading = true;
    notifyListeners();

    final isOnline = await _checkConnectivity();
    if (isOnline && isLoggedIn) {
      await _loadUserData();
      await _saveListsToCache();
      startBackgroundSync();
    } else {
      logInfo('   _ | Skipping online features: ${!isOnline ? "Offline" : "Not logged in"}');
    }

    _isReady = true;
    _isLoading = false;
    notifyListeners();
    logTrace('_ | AnilistProvider online features initialized.');
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
