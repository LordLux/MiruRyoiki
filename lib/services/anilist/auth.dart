import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/logging.dart';
import '../../utils/storage.dart';
import '../../utils/time.dart';

const String mRyoikiAnilistScheme = 'mryoiki';
const String redirectUrl = '$mRyoikiAnilistScheme://auth-callback';

class AnilistAuthService {
  // Singleton
  static final AnilistAuthService _instance = AnilistAuthService._internal();
  factory AnilistAuthService() => _instance;
  AnilistAuthService._internal()
      : _clientId = dotenv.env['ANILIST_CLIENT_ID']!,
        _secureStorage = const FlutterSecureStorage();

  static const String _authEndpoint = 'https://anilist.co/api/v2/oauth/authorize';

  final String _clientId;
  final FlutterSecureStorage _secureStorage;

  oauth2.Client? _client;
  bool get isAuthenticated => _client != null;

  /// Initialize auth state from stored credentials
  Future<bool> init() async {
    try {
      final credentialsJson = await _secureStorage.read(key: secureKey('anilist_credentials'));
      if (credentialsJson != null) {
        final credentials = oauth2.Credentials.fromJson(credentialsJson);

        // AniList v2 issues long-lived tokens and has no refresh grant
        // An expired token can only be replaced by logging in again
        if (!credentials.isExpired) {
          _client = oauth2.Client(credentials);
          return true;
        }
        logInfo('Stored Anilist credentials have expired; login required');
      }
    } catch (e) {
      logErr('Error loading Anilist credentials', e);
      await logout();
    }
    return false;
  }

  /// Start the OAuth authorization flow.
  ///
  /// Uses the Implicit Grant (`response_type=token`): AniList returns the access
  /// token directly in the redirect instead of a code that must be exchanged.
  /// AniList documents the implicit grant as the correct flow for exactly this case.
  Future<void> login() async {
    // Built via replace() rather than string interpolation so values are
    // percent-encoded. `redirect_uri` is deliberately omitted: AniList's
    // implicit-grant flow takes only these two parameters and uses the redirect
    // URL registered on the application itself.
    final authUrl = Uri.parse(_authEndpoint).replace(queryParameters: {
      'client_id': _clientId,
      'response_type': 'token',
    });

    if (await canLaunchUrl(authUrl)) {
      await launchUrl(authUrl, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch Anilist auth URL');
    }
  }

  /// Handle the authorization callback.
  ///
  /// The implicit grant returns the token in the URL *fragment*
  /// (`mryoiki://auth-callback/#access_token=...&token_type=Bearer`) rather than
  /// the query string, so there is nothing to exchange and no request to sign.
  ///
  /// Returning false means that the callback carried no usable token
  Future<bool> handleAuthCallback(Uri callbackUri) async {
    try {
      if (callbackUri.fragment.isEmpty) return false;

      final params = Uri.splitQueryString(callbackUri.fragment);
      final accessToken = params['access_token'];
      if (accessToken == null || accessToken.isEmpty) {
        logWarn('Anilist callback carried no access_token');
        return false;
      }

      // expires_in is optional. A null expiration makes oauth2.Credentials treat the token as non-expiring,
      // which is the right default when AniList doesn't say the token's lifetime.
      final expiresIn = int.tryParse(params['expires_in'] ?? '');
      final credentials = oauth2.Credentials(
        accessToken,
        expiration: expiresIn != null ? now.add(Duration(seconds: expiresIn)) : null,
      );

      await _secureStorage.write(
        key: secureKey('anilist_credentials'),
        value: credentials.toJson(),
      );

      _client = oauth2.Client(credentials);
      return true;
    } catch (e, st) {
      logErr('Error handling Anilist auth callback', e, st);
      return false;
    }
  }

  /// Log out by clearing stored credentials
  Future<void> logout() async {
    await _secureStorage.delete(key: secureKey('anilist_credentials'));
    _client = null;
  }

  /// Get the authenticated HTTP client
  oauth2.Client? get client => _client;
}
