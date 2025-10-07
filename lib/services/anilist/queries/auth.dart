part of 'anilist_service.dart';

extension AnilistServiceAuth on AnilistService {
  /// Start the login flow
  Future<void> login() async {
    await _authService.login();
  }

  /// Handle auth callback
  Future<bool> handleAuthCallback(Uri callbackUri) async {
    final success = await _authService.handleAuthCallback(callbackUri);
    if (success) {
      Manager.accounts.add('Anilist');
      // ignore: invalid_use_of_protected_member
      Manager.setState(() {});
      _setupGraphQLClient();

      final anilistProvider = Provider.of<AnilistProvider>(rootNavigatorKey.currentContext!, listen: false);
      await anilistProvider.initializeOnlineFeatures();

      await anilistProvider.refreshUserData();
      
      await anilistProvider.refreshUserLists();
      
      final library = Provider.of<Library>(rootNavigatorKey.currentContext!, listen: false);
      await library.loadAnilistPostersForLibrary(anilistProvider: anilistProvider, onProgress: (loaded, total) {});
      logTrace('Anilist data sync complete after login.');
    } else {
      await logout();
    }

    return success;
  }

  /// Logout from Anilist
  Future<void> logout() async {
    await _authService.logout();
    Manager.accounts.remove('Anilist');
    logInfo('Anilist logged out');
    _client = null;
  }
}
