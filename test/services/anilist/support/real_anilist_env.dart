import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const _anilistClientId = '29559';
const _anilistRedirectUri = 'mryoiki://auth-callback';

/// Loads the test/.env file and makes its values available.
///
/// Idempotent — safe to call from multiple setUpAll in one isolate.
class RealAnilistEnv {
  static bool _loaded = false;
  static String? _token;
  static String? _username;

  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    await _readEnvFile();
    _loadDotenv();
  }

  static Future<void> _readEnvFile() async {
    final envFile = File('test/.env');
    if (!envFile.existsSync()) return;
    for (final line in envFile.readAsStringSync().split('\n')) {
      final eqIdx = line.indexOf('=');
      if (eqIdx < 0) continue;
      final key = line.substring(0, eqIdx).trim();
      final value = line.substring(eqIdx + 1).trim();
      if (key == 'ACCESS_TOKEN') _token = value.isEmpty ? null : value;
      if (key == 'USERNAME') _username = value.isEmpty ? null : value;
    }
  }

  static void _loadDotenv() {
    final envFile = File('test/.env');
    final envContent = envFile.existsSync() ? envFile.readAsStringSync() : '';
    // Dummy OAuth credentials are required so AnilistAuthService doesn't crash.
    // Real auth is injected via the Bearer link, not via oauth2.Client.
    dotenv.testLoad(
        fileInput: 'ANILIST_CLIENT_ID=test_ci\nANILIST_CLIENT_SECRET=test_ci\n$envContent');
  }

  /// Opens a browser to the AniList implicit-grant auth page, waits for the
  /// user to paste the redirect URL, extracts the access_token from the
  /// fragment, saves it to test/.env, and updates the in-memory token.
  ///
  /// Called automatically by the harness when a Viewer query fails.
  static Future<void> interactiveRefresh() async {
    final authUrl = 'https://anilist.co/api/v2/oauth/authorize'
        '?client_id=$_anilistClientId'
        '&redirect_uri=${Uri.encodeComponent(_anilistRedirectUri)}'
        '&response_type=token';

    stdout.writeln('\n[real-api] Opening AniList auth page in your browser…');
    stdout.writeln('  $authUrl');

    if (Platform.isWindows) {
      await Process.run('cmd', ['/c', 'start', '', authUrl]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [authUrl]);
    } else {
      await Process.run('xdg-open', [authUrl]);
    }

    stdout.writeln(
      '\n[real-api] After authorizing, AniList will redirect your browser to a\n'
      '  "$_anilistRedirectUri#access_token=..." URL.\n'
      '  Copy the FULL URL from the address bar and paste it below, then press Enter:',
    );
    stdout.write('> ');

    final pasted = stdin.readLineSync()?.trim() ?? '';

    final token = _extractToken(pasted);
    if (token == null || token.isEmpty) {
      throw StateError(
        '[real-api] Could not find access_token in the pasted URL.\n'
        '  Got: $pasted',
      );
    }

    _saveToken(token);
    _token = token;
    stdout.writeln('[real-api] Token saved to test/.env');
  }

  static String? _extractToken(String pasted) {
    // The redirect URL fragment looks like:
    // mryoiki://auth-callback#access_token=eyJ...&token_type=Bearer&expires_in=...
    // Uri.parse can't handle custom schemes well; split on '#' manually.
    final hashIdx = pasted.indexOf('#');
    if (hashIdx < 0) return null;
    final fragment = pasted.substring(hashIdx + 1);
    return Uri.splitQueryString(fragment)['access_token'];
  }

  static void _saveToken(String token) {
    final envFile = File('test/.env');
    final lines = envFile.existsSync()
        ? envFile.readAsStringSync().split('\n').where((l) {
            final idx = l.indexOf('=');
            if (idx < 0) return true;
            return l.substring(0, idx).trim() != 'ACCESS_TOKEN';
          }).toList()
        : <String>[];

    // Remove trailing blank line that split() may produce, then re-add clean.
    while (lines.isNotEmpty && lines.last.trim().isEmpty) {
      lines.removeLast();
    }
    lines.add('ACCESS_TOKEN=$token');
    envFile.writeAsStringSync('${lines.join('\n')}\n');
    // Re-apply dotenv with the updated file so downstream code sees the new value.
    _loadDotenv();
  }

  static String? get token => _token;
  static String? get username => _username;
  static bool get hasToken => _token != null && _token!.isNotEmpty;
}
