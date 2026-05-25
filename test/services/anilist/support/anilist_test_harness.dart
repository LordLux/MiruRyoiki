import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/settings.dart';
import 'package:miruryoiki/services/anilist/queries/anilist_service.dart';
import 'package:miruryoiki/services/connectivity/connectivity_service.dart';

import 'real_anilist_env.dart';
import 'real_anilist_client.dart';
import 'account_reset.dart';

export 'real_anilist_env.dart';
export 'real_anilist_client.dart';
export 'account_reset.dart';
export 'test_media.dart';

/// Single access point for the real-AniList test infrastructure.
///
/// Typical usage in a test file:
/// ```dart
/// late RealAnilistContext ctx;
///
/// setUpAll(() async {
///   ctx = await RealAnilist.setUp() ?? (throw TestSkippedException());
/// });
/// ```
///
/// [setUp] returns `null` when no access token is available so callers can
/// skip the whole suite gracefully with [skipIfNoToken].
abstract final class RealAnilist {
  /// Build the full test context: load env, configure services, fetch userId.
  ///
  /// Returns `null` (and prints a skip message) when [test/.env] has no token.
  static Future<RealAnilistContext?> setUp() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // TestWidgetsFlutterBinding installs an HttpOverride that blocks all real
    // HTTP with 400s. We need real network access for the live API tests.
    HttpOverrides.global = null;

    await RealAnilistEnv.load();

    if (!RealAnilistEnv.hasToken) {
      // ignore: avoid_print
      print('[real-api] Skipping: no ACCESS_TOKEN found in test/.env');
      return null;
    }

    Manager.mockSettings = SettingsManager();
    ConnectivityService().setStrategy(_AlwaysOnlineStrategy());

    var built = RealAnilistClient.create(RealAnilistEnv.token!);

    // Fetch the authenticated user's ID; if it fails the token may have been
    // revoked — fall back to an interactive browser login to get a fresh one.
    var viewerResult = await built.client.query(QueryOptions(
      document: gql(r'query { Viewer { id } }'),
      fetchPolicy: FetchPolicy.networkOnly,
    ));

    int? userId = viewerResult.data?['Viewer']?['id'] as int?;
    if (userId == null) {
      // ignore: avoid_print
      print('[real-api] Viewer.id lookup failed — launching interactive token refresh…');
      await RealAnilistEnv.interactiveRefresh();
      built = RealAnilistClient.create(RealAnilistEnv.token!);
      viewerResult = await built.client.query(QueryOptions(
        document: gql(r'query { Viewer { id } }'),
        fetchPolicy: FetchPolicy.networkOnly,
      ));
      userId = viewerResult.data?['Viewer']?['id'] as int?;
      if (userId == null) {
        throw StateError(
          '[real-api] Failed to resolve Viewer.id even after token refresh — '
          'check that the pasted redirect URL contained an access_token.',
        );
      }
    }

    return RealAnilistContext(
      client: built.client,
      service: built.service,
      userId: userId,
      username: RealAnilistEnv.username ?? '',
      reset: AccountReset(
        service: built.service,
        client: built.client,
        userId: userId,
      ),
    );
  }

  /// Call inside [setUpAll]; marks every test in the group as skipped
  /// when no token is available so the suite degrades gracefully.
  static void skipIfNoToken() {
    if (!RealAnilistEnv.hasToken) {
      markTestSkipped('No ACCESS_TOKEN in test/.env — skipping real-API tests');
    }
  }
}

/// Immutable context handed to each real-API test.
class RealAnilistContext {
  final GraphQLClient client;
  final AnilistService service;
  final int userId;
  final String username;
  final AccountReset reset;

  const RealAnilistContext({
    required this.client,
    required this.service,
    required this.userId,
    required this.username,
    required this.reset,
  });
}

/// Connectivity strategy that reports "always online" to bypass the device
/// network check that [ConnectivityService] performs.
class _AlwaysOnlineStrategy implements ConnectivityStrategy {
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.value([ConnectivityResult.wifi]);

  @override
  Future<bool> hasInternetAccess() async => true;
}
