part of 'anilist_provider.dart';

extension AnilistProviderInitialization on AnilistProvider {
  /// Initialize connectivity service
  Future<void> _initializeConnectivity() async {
    logDebug('Initializing connectivity service...');

    // Initialize connectivity service
    await _connectivityService.initialize();

    // Listen to connectivity changes and update offline status
    _connectivityService.isOnlineNotifier.addListener(_onConnectivityChanged);

    // Sync initial offline status
    _isOffline = !_connectivityService.isOnline;
  }

  /// Handle connectivity changes
  void _onConnectivityChanged() {
    final wasOffline = _isOffline;
    _isOffline = !_connectivityService.isOnline;

    // Only notify if status changed
    if (wasOffline != _isOffline) {
      if (!_isOffline) {
        logInfo('Connectivity restored - triggering data refresh');
        // Connection restored - refresh data if logged in
        if (isLoggedIn && isInitialized) {
          refreshUserData();
          _loadUserLists();
        }
      } else {
        logInfo('Connectivity lost');
      }
      notifyListeners();
    }
  }

  /// Initialize the provider
  Future<void> initialize() async {
    logDebug('\n2 | Initializing AnilistService...', splitLines: true);
    _isLoading = true;
    notifyListeners();

    // Load cached anime first to ensure data availability even offline
    await loadAnimeCacheFromStorage();

    // Load pending mutations from disk
    await loadMutationsQueue();

    // Initialize connectivity service
    await _initializeConnectivity();

    final hasCredentials = await _anilistService.initialize();
    if (hasCredentials) {
      await _loadCurrentUserFromCache();
      int retryCount = 0;
      const maxRetries = 3;
      bool success = false;

      while (retryCount < maxRetries && !success) {
        success = await _loadListsFromCache();
        if (!success) {
          retryCount++;
          if (retryCount < maxRetries) {
            logWarn('   2 | Failed to load Anilist lists from cache (attempt $retryCount/$maxRetries). Retrying...');
            await Future.delayed(Duration(milliseconds: 500 * retryCount)); // Exponential backoff
          } else {
            logWarn('   2 | Could not load Anilist lists from cache after $maxRetries attempts.');
          }
        }
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
    logTrace('_ | AnilistProvider online features initialized.');

    final isOnline = await _connectivityService.getConnectivityStatus();
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
    logTrace('_ | AnilistProvider first sync call successfully done.');
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

  /// Check network connectivity using the connectivity service
  Future<bool> _checkConnectivity() async {
    return await _connectivityService.getConnectivityStatus();
  }
}
