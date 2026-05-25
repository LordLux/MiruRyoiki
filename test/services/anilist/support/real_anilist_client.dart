import 'package:graphql/client.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:miruryoiki/services/anilist/auth.dart';
import 'package:miruryoiki/services/anilist/queries/anilist_service.dart';
import 'rate_limit_link.dart';

/// Builds a rate-limited, Bearer-authenticated [GraphQLClient] and wires it
/// into the [AnilistService] singleton together with a test-only auth shim.
///
/// Call [RealAnilistClient.create] once in [setUpAll]; the returned [client]
/// and [service] are ready for real API calls.
class RealAnilistClient {
  final GraphQLClient client;
  final AnilistService service;

  RealAnilistClient._({required this.client, required this.service});

  static RealAnilistClient create(String token) {
    final link = RateLimitLink()
        .concat(AuthLink(getToken: () => 'Bearer $token'))
        .concat(HttpLink('https://graphql.anilist.co'));

    final client = GraphQLClient(
      cache: GraphQLCache(),
      link: link,
      defaultPolicies: DefaultPolicies(
        query: Policies(fetch: FetchPolicy.networkOnly),
        mutate: Policies(fetch: FetchPolicy.networkOnly),
      ),
    );

    final service = AnilistService();
    service.client = client;
    service.authService = _TestAuthService();

    return RealAnilistClient._(client: client, service: service);
  }
}

/// Minimal [AnilistAuthService] implementation for tests.
///
/// Auth is handled by the Bearer token injected at the link layer;
/// the service shim just reports [isAuthenticated] = true so that code
/// paths guarded by [AnilistService.isLoggedIn] proceed normally.
class _TestAuthService implements AnilistAuthService {
  @override
  bool get isAuthenticated => true;

  @override
  oauth2.Client? get client => null;

  @override
  Future<bool> init() async => true;

  @override
  Future<void> login() async {}

  @override
  Future<bool> handleAuthCallback(Uri callbackUri) async => true;

  @override
  Future<void> logout() async {}
}
