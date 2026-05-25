import 'package:graphql/client.dart';
import 'anilist_rate_limiter.dart';

/// A GraphQL [Link] that gates every outgoing request through [AnilistRateLimiter].
///
/// Insert this at the head of the link chain so that ALL requests — including
/// raw [GraphQLClient.query]/[mutate] calls made by [AccountReset] helpers —
/// are automatically throttled without any per-call ceremony.
class RateLimitLink extends Link {
  final AnilistRateLimiter _limiter;

  RateLimitLink([AnilistRateLimiter? limiter])
      : _limiter = limiter ?? AnilistRateLimiter.instance;

  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    await _limiter.acquire();
    yield* forward!(request);
  }
}
