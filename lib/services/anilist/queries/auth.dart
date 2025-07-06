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
      accountsKey.currentState?.setState(() {});
      _setupGraphQLClient();
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
