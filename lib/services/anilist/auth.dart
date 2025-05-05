import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class AnilistAuthService {
  static const String _authEndpoint = 'https://anilist.co/api/v2/oauth/authorize';
  static const String _tokenEndpoint = 'https://anilist.co/api/v2/oauth/token';
  static const String _redirectUrl = 'mryoiki://auth-callback';

  final String _clientId;
  final String _clientSecret;
  final FlutterSecureStorage _secureStorage;

  oauth2.Client? _client;
  bool get isAuthenticated => _client != null;

  AnilistAuthService({FlutterSecureStorage? secureStorage})
      : _clientId = dotenv.env['ANILIST_CLIENT_ID']!,
        _clientSecret = dotenv.env['ANILIST_CLIENT_SECRET']!,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Initialize auth state from stored credentials
  Future<bool> init() async {
    try {
      final credentialsJson = await _secureStorage.read(key: 'anilist_credentials');
      if (credentialsJson != null) {
        final credentials = oauth2.Credentials.fromJson(credentialsJson);

        // Check if credentials are expired and need refresh
        if (credentials.isExpired && credentials.canRefresh) {
          await _refreshToken(credentials);
        } else if (!credentials.isExpired) {
          _client = oauth2.Client(
            credentials,
            identifier: _clientId,
            secret: _clientSecret,
          );
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error loading Anilist credentials: $e');
      await logout();
    }
    return false;
  }

  /// Start the OAuth authorization flow
  Future<void> login() async {
    final authUrl = Uri.parse('$_authEndpoint'
        '?client_id=$_clientId'
        '&redirect_uri=$_redirectUrl'
        '&response_type=code');

    if (await canLaunchUrl(authUrl)) {
      await launchUrl(authUrl, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch Anilist auth URL');
    }
  }

  /// Handle the authorization callback with code
  Future<bool> handleAuthCallback(Uri callbackUri) async {
    final code = callbackUri.queryParameters['code'];
    if (code == null) return false;

    try {
      final response = await http.post(
        Uri.parse(_tokenEndpoint),
        body: {
          'grant_type': 'authorization_code',
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'redirect_uri': _redirectUrl,
          'code': code,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final credentials = oauth2.Credentials(
          data['access_token'],
          refreshToken: data['refresh_token'],
          expiration: DateTime.now().add(Duration(seconds: data['expires_in'])),
        );

        // Save credentials
        await _secureStorage.write(
          key: 'anilist_credentials',
          value: credentials.toJson(),
        );

        _client = oauth2.Client(credentials, identifier: _clientId, secret: _clientSecret);
        return true;
      }
    } catch (e) {
      debugPrint('Error handling Anilist auth callback: $e');
    }
    return false;
  }

  /// Refresh the access token
  Future<bool> _refreshToken(oauth2.Credentials credentials) async {
    try {
      final response = await http.post(
        Uri.parse(_tokenEndpoint),
        body: {
          'grant_type': 'refresh_token',
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'refresh_token': credentials.refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final newCredentials = oauth2.Credentials(
          data['access_token'],
          refreshToken: data['refresh_token'],
          expiration: DateTime.now().add(Duration(seconds: data['expires_in'])),
        );

        // Save new credentials
        await _secureStorage.write(
          key: 'anilist_credentials',
          value: newCredentials.toJson(),
        );

        _client = oauth2.Client(newCredentials, identifier: _clientId, secret: _clientSecret);
        return true;
      }
    } catch (e) {
      debugPrint('Error refreshing Anilist token: $e');
    }

    return false;
  }

  /// Log out by clearing stored credentials
  Future<void> logout() async {
    await _secureStorage.delete(key: 'anilist_credentials');
    _client = null;
  }

  /// Get the authenticated HTTP client
  oauth2.Client? get client => _client;
}
